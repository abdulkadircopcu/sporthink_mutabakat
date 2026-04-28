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
    """Yükleme olayını JSON log dosyasına kaydeder."""
    kayit = {
        "tarih": datetime.now().strftime("%d.%m.%Y %H:%M:%S"),
        "marketplace": marketplace,
        "data_type": data_type,
        "dosya": dosya_adi,
        "satir_sayisi": satir_sayisi,
        "durum": durum,          # "basarili" veya "hata"
        "hata": hata_mesaji
    }

    # Mevcut logları oku
    loglar = []
    if os.path.exists(LOG_FILE):
        try:
            with open(LOG_FILE, "r", encoding="utf-8") as f:
                loglar = json.load(f)
        except Exception:
            loglar = []

    # Yeni kaydı başa ekle (en yeni en üstte)
    loglar.insert(0, kayit)

    # Maksimum 200 log tut
    loglar = loglar[:200]

    with open(LOG_FILE, "w", encoding="utf-8") as f:
        json.dump(loglar, f, ensure_ascii=False, indent=2)

    return kayit


# -------------------------------------------------------
# Pazaryeri → veri tipleri haritası
# -------------------------------------------------------
MARKETPLACE_CONFIG = {
    "trendyol": {
        "label": "Trendyol",
        "veri_tipleri": [
            {"key": "kargo_faturasi",      "label": "Kargo Faturası"},
            {"key": "komisyon_faturasi",   "label": "Komisyon Faturası"},
            {"key": "ceza_faturasi",       "label": "Ceza Faturası"},
            {"key": "islem_bedelleri",     "label": "İşlem Bedelleri"},
            {"key": "iptal_listesi",       "label": "İptal Listesi"},
            {"key": "yurtdisi_operasyon",  "label": "Yurt Dışı Operasyon"},
            {"key": "kargo_desi_fiyatlari","label": "Kargo Desi Fiyatları"},
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
            {"key": "hakedis",              "label": "Hakediş Listesi"},
            {"key": "kargo_desi_fiyatlari", "label": "Kargo Desi Fiyatları"},
        ]
    },
    "n11": {
        "label": "N11",
        "veri_tipleri": [
            {"key": "kargo",                "label": "Kargo Listesi"},
            {"key": "komisyon_faturasi",    "label": "Komisyon Faturası"},
            {"key": "kargo_desi_fiyatlari", "label": "Kargo Desi Fiyatları"},
        ]
    },
    "pazarama": {
        "label": "Pazarama",
        "veri_tipleri": [
            {"key": "ceza",                 "label": "Ceza Listesi"},
            {"key": "fatura_ozet",          "label": "Fatura Özeti"},
            {"key": "kargo_detay",          "label": "Kargo Detay"},
            {"key": "komisyon_detay",       "label": "Komisyon Detay"},
            {"key": "kargo_desi_fiyatlari", "label": "Kargo Desi Fiyatları"},
        ]
    },
    "flo": {
        "label": "Flo",
        "veri_tipleri": [
            {"key": "fatura_detay",         "label": "Fatura Detay"},
            {"key": "kargo_desi_fiyatlari", "label": "Kargo Desi Fiyatları"},
        ]
    },
    "lcw": {
        "label": "LCW",
        "veri_tipleri": [
            {"key": "kargo_faturasi",       "label": "Kargo Faturası"},
            {"key": "komisyon_faturasi",    "label": "Komisyon Faturası"},
            {"key": "kargo_desi_fiyatlari", "label": "Kargo Desi Fiyatları"},
        ]
    },
}


# -------------------------------------------------------
# İmporter metodları haritası
# -------------------------------------------------------
def get_importer_method(marketplace, data_type):
    """
    Pazaryeri + veri tipi kombinasyonuna göre
    ilgili importer metodunu döner.
    """
    metodlar = {
        "trendyol": {
            "kargo_faturasi":       TrendyolImporter().import_kargo_faturasi,
            "komisyon_faturasi":    TrendyolImporter().import_komisyon_faturasi,
            "ceza_faturasi":        TrendyolImporter().import_ceza_faturasi,
            "islem_bedelleri":      TrendyolImporter().import_islem_bedelleri,
            "iptal_listesi":        TrendyolImporter().import_iptal_listesi,
            "yurtdisi_operasyon":   TrendyolImporter().import_yurtdisi_operasyon,
            "kargo_desi_fiyatlari": TrendyolImporter().import_kargo_desi_fiyatlari,
        },
        "amazon": {
            "islemler": AmazonImporter().import_islemler,
        },
        "hepsiburada": {
            "hakedis":              HepsiburadaImporter().import_hakedis,
            "kargo_desi_fiyatlari": HepsiburadaImporter().import_kargo_desi_fiyatlari,
        },
        "n11": {
            "kargo":                N11Importer().import_kargo,
            "komisyon_faturasi":    N11Importer().import_komisyon_faturasi,
            "kargo_desi_fiyatlari": N11Importer().import_kargo_desi_fiyatlari,
        },
        "pazarama": {
            "ceza":                 PazaramaImporter().import_ceza,
            "fatura_ozet":          PazaramaImporter().import_fatura_ozet,
            "kargo_detay":          PazaramaImporter().import_kargo_detay,
            "komisyon_detay":       PazaramaImporter().import_komisyon_detay,
            "kargo_desi_fiyatlari": PazaramaImporter().import_kargo_desi_fiyatlari,
        },
        "flo": {
            "fatura_detay":         FloImporter().import_fatura_detay,
            "kargo_desi_fiyatlari": FloImporter().import_kargo_desi_fiyatlari,
        },
        "lcw": {
            "kargo_faturasi":       LcwImporter().import_kargo_faturasi,
            "komisyon_faturasi":    LcwImporter().import_komisyon_faturasi,
            "kargo_desi_fiyatlari": LcwImporter().import_kargo_desi_fiyatlari,
        },
    }

    mkt = metodlar.get(marketplace)
    if not mkt:
        return None
    return mkt.get(data_type)


# -------------------------------------------------------
# Endpoint: Sağlık kontrolü
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
# Endpoint: Dosya yükleme
# -------------------------------------------------------
@upload_bp.route("/upload", methods=["POST"])
def upload():
    # Form alanlarını al
    marketplace = request.form.get("marketplace", "").lower().strip()
    data_type   = request.form.get("data_type", "").strip()
    dosya       = request.files.get("file")

    # Validasyon
    if not dosya or dosya.filename == "":
        return jsonify({"basarili": False, "hata": "Dosya seçilmedi."}), 400

    if not marketplace or not data_type:
        return jsonify({"basarili": False, "hata": "Pazaryeri veya veri türü belirtilmedi."}), 400

    if not dosya.filename.endswith((".xlsx", ".xls")):
        return jsonify({"basarili": False, "hata": "Sadece .xlsx veya .xls dosyaları kabul edilir."}), 400

    # Dosyayı geçici olarak kaydet
    gecici_yol = os.path.join(current_app.config["UPLOAD_FOLDER"], dosya.filename)
    dosya.save(gecici_yol)

    try:
        # İlgili importer metodunu bul ve çalıştır
        metod = get_importer_method(marketplace, data_type)

        if not metod:
            log_yaz(marketplace, data_type, dosya.filename, 0, "hata",
                    f"Tanımsız kombinasyon: {marketplace}/{data_type}")
            return jsonify({
                "basarili": False,
                "hata": f"Geçersiz kombinasyon: '{marketplace}' / '{data_type}'"
            }), 400

        # Aktarımı gerçekleştir — importer'ı satır sayısı döndürecek şekilde
        # wrap ediyoruz (importer'lar void, df boyutunu buradan okuyacağız)
        import pandas as pd
        from importers.base_importer import clean_column_name

        df = pd.read_excel(gecici_yol)
        satir_sayisi = len(df)

        metod(gecici_yol)  # Asıl yükleme

        log_kayit = log_yaz(marketplace, data_type, dosya.filename, satir_sayisi, "basarili")

        return jsonify({
            "basarili": True,
            "mesaj": f"{satir_sayisi} satır başarıyla yüklendi.",
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
        # Geçici dosyayı temizle
        if os.path.exists(gecici_yol):
            os.remove(gecici_yol)


# -------------------------------------------------------
# Endpoint: Log geçmişi
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
