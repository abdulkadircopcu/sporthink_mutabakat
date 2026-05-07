import os
import sys
import json
from datetime import datetime
from flask import Blueprint, request, jsonify, current_app

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from importers.trendyol_importer import TrendyolImporter
from importers.amazon_importer import AmazonImporter
from importers.hepsiburada_importer import HepsiburadaImporter
from importers.n11_importer import N11Importer
from importers.pazarama_importer import PazaramaImporter
from importers.flo_importer import FloImporter
from importers.lcw_importer import LcwImporter

upload_bp = Blueprint("upload", __name__)

# -------------------------------------------------------
# Log dosyası yolu
# -------------------------------------------------------
LOG_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), "upload_logs.json")

def log_yaz(marketplace, data_type, dosya_adi, satir_sayisi, durum, hata_mesaji=None):
    kayit = {
        "tarih": datetime.now().strftime("%d.%m.%Y %H:%M:%S"),
        "marketplace": marketplace,
        "data_type": data_type,
        "dosya": dosya_adi,
        "satir_sayisi": satir_sayisi,
        "durum": durum,
        "hata": hata_mesaji
    }
    loglar = []
    if os.path.exists(LOG_FILE):
        try:
            with open(LOG_FILE, "r", encoding="utf-8") as f:
                loglar = json.load(f)
        except Exception:
            loglar = []
    loglar.insert(0, kayit)
    loglar = loglar[:200]
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        json.dump(loglar, f, ensure_ascii=False, indent=2)
    return kayit


# -------------------------------------------------------
# Pazaryeri → veri tipleri haritası
# Kargo desi fiyatlari veritabaninda sabit tutuluyor,
# disardan dosya yuklenmez.
# -------------------------------------------------------
MARKETPLACE_CONFIG = {
    "trendyol": {
        "label": "Trendyol",
        "veri_tipleri": [
            {"key": "kargo_faturasi",     "label": "Kargo Faturası"},
            {"key": "komisyon_faturasi",  "label": "Komisyon Faturası"},
            {"key": "ceza_faturasi",      "label": "Ceza Faturası"},
            {"key": "islem_bedelleri",    "label": "İşlem Bedelleri"},
            {"key": "iptal_listesi",      "label": "İptal Listesi"},
            {"key": "yurtdisi_operasyon", "label": "Yurt Dışı Operasyon"},
        ]
    },
    "amazon": {
        "label": "Amazon",
        "veri_tipleri": [
            {"key": "islemler", "label": "İşlem Listesi"},
        ]
    },
    "hepsiburada": {
        "label": "Hepsiburada",
        "veri_tipleri": [
            {"key": "hakedis", "label": "Hakediş Listesi"},
        ]
    },
    "n11": {
        "label": "N11",
        "veri_tipleri": [
            {"key": "kargo",             "label": "Kargo Listesi"},
            {"key": "komisyon_faturasi", "label": "Komisyon Faturası"},
        ]
    },
    "pazarama": {
        "label": "Pazarama",
        "veri_tipleri": [
            {"key": "komisyon_kargo", "label": "Pazarama Dosyası"},
        ]
    },
    "flo": {
        "label": "Flo",
        "veri_tipleri": [
            {"key": "fatura_detay", "label": "Fatura Detayı"},
        ]
    },
    "lcw": {
        "label": "LCW",
        "veri_tipleri": [
            {"key": "kargo_faturasi",    "label": "Kargo Faturası"},
            {"key": "komisyon_faturasi", "label": "Komisyon Faturası"},
        ]
    },
}



# -------------------------------------------------------
# Importer metodlari haritasi
# -------------------------------------------------------
def get_importer_method(marketplace, data_type):
    metodlar = {
        "trendyol": {
            "kargo_faturasi":     TrendyolImporter().import_kargo_faturasi,
            "komisyon_faturasi":  TrendyolImporter().import_komisyon_faturasi,
            "ceza_faturasi":      TrendyolImporter().import_ceza_faturasi,
            "islem_bedelleri":    TrendyolImporter().import_islem_bedelleri,
            "iptal_listesi":      TrendyolImporter().import_iptal_listesi,
            "yurtdisi_operasyon": TrendyolImporter().import_yurtdisi_operasyon,
        },
        "amazon": {
            "islemler": AmazonImporter().import_islemler,
        },
        "hepsiburada": {
            "hakedis": HepsiburadaImporter().import_hakedis,
        },
        "n11": {
            "kargo":             N11Importer().import_kargo,
            "komisyon_faturasi": N11Importer().import_komisyon_faturasi,
        },
        "pazarama": {
            # Tek dosyadan 4 sayfa otomatik okunur
            "komisyon_kargo": PazaramaImporter().import_tumu,
        },
        "flo": {
            "fatura_detay": FloImporter().import_fatura_detay,
        },
        "lcw": {
            "kargo_faturasi":    LcwImporter().import_kargo_faturasi,
            "komisyon_faturasi": LcwImporter().import_komisyon_faturasi,
        },
    }
    mkt = metodlar.get(marketplace)
    if not mkt:
        return None
    return mkt.get(data_type)


# -------------------------------------------------------
# Endpoint: Saglik kontrolu
# -------------------------------------------------------
@upload_bp.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "mesaj": "API calisiyor"})


# -------------------------------------------------------
# Endpoint: Pazaryeri + veri tipi listesi
# -------------------------------------------------------
@upload_bp.route("/marketplaces", methods=["GET"])
def get_marketplaces():
    return jsonify(MARKETPLACE_CONFIG)


# -------------------------------------------------------
# Endpoint: Dosya yukleme
# -------------------------------------------------------
# Pazaryeri key → Pipeline pazaryeri ismi eslesimi
PAZARYERI_MAP = {
    "trendyol":    "Trendyol",
    "hepsiburada": "Hepsiburada",
    "n11":         "N11",
    "pazarama":    "Pazarama",
    "flo":         "Flo",
    "lcw":         "LCW",
    "amazon":      "Amazon",
}

@upload_bp.route("/upload", methods=["POST"])
def upload():
    marketplace = request.form.get("marketplace", "").lower().strip()
    data_type   = request.form.get("data_type", "").strip()
    dosya       = request.files.get("file")

    if not dosya or dosya.filename == "":
        return jsonify({"basarili": False, "hata": "Dosya secilmedi."}), 400

    if not marketplace or not data_type:
        return jsonify({"basarili": False, "hata": "Pazaryeri veya veri turu belirtilmedi."}), 400

    if not dosya.filename.endswith((".xlsx", ".xls")):
        return jsonify({"basarili": False, "hata": "Sadece .xlsx veya .xls dosyalari kabul edilir."}), 400

    gecici_yol = os.path.join(current_app.config["UPLOAD_FOLDER"], dosya.filename)
    dosya.save(gecici_yol)

    try:
        metod = get_importer_method(marketplace, data_type)

        if not metod:
            log_yaz(marketplace, data_type, dosya.filename, 0, "hata",
                    f"Tanimsiz kombinasyon: {marketplace}/{data_type}")
            return jsonify({
                "basarili": False,
                "hata": f"Gecersiz kombinasyon: '{marketplace}' / '{data_type}'"
            }), 400

        import pandas as pd

        # Pazarama komisyon_kargo icin satir sayisini tum sayfalardan topla
        if marketplace == "pazarama" and data_type == "komisyon_kargo":
            xl = pd.ExcelFile(gecici_yol)
            satir_sayisi = sum(
                len(pd.read_excel(gecici_yol, sheet_name=s))
                for s in xl.sheet_names
            )
        else:
            satir_sayisi = len(pd.read_excel(gecici_yol))

        metod(gecici_yol)

        log_kayit = log_yaz(marketplace, data_type, dosya.filename, satir_sayisi, "basarili")

        # Pipeline'i arka planda calistir (kullanicinin beklemesine gerek yok)
        import threading
        pz_adi = PAZARYERI_MAP.get(marketplace)
        if pz_adi:
            def _pipeline_bg():
                try:
                    from pipeline import tam_pipeline_calistir
                    tam_pipeline_calistir(pz_adi)
                    print(f"[AUTO-PIPELINE] {pz_adi} tamamlandi.")
                except Exception as pe:
                    print(f"[AUTO-PIPELINE] HATA ({pz_adi}): {pe}")
            threading.Thread(target=_pipeline_bg, daemon=True).start()

        return jsonify({
            "basarili": True,
            "mesaj": f"{satir_sayisi} satir basariyla yuklendi. Karlilik ozeti guncelleniyor...",
            "log": log_kayit
        })

    except Exception as e:
        hata_str = str(e)
        log_kayit = log_yaz(marketplace, data_type, dosya.filename, 0, "hata", hata_str)
        return jsonify({
            "basarili": False,
            "hata": hata_str,
            "log": log_kayit
        }), 500

    finally:
        import time
        time.sleep(0.3)
        try:
            if os.path.exists(gecici_yol):
                os.remove(gecici_yol)
        except PermissionError:
            pass


# -------------------------------------------------------
# Endpoint: Log gecmisi
# -------------------------------------------------------
@upload_bp.route("/logs", methods=["GET"])
def get_logs():
    if not os.path.exists(LOG_FILE):
        return jsonify([])
    try:
        with open(LOG_FILE, "r", encoding="utf-8") as f:
            return jsonify(json.load(f))
    except Exception:
        return jsonify([])