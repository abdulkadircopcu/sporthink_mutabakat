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
from importers.hitit_importer import HititSatisImporter, HititIadeImporter
from importers.hammurlab_importer import HamurlabSiparisImporter, HamurlabIptalIadeImporter

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


# -------------------------------------------------------
# ERP Sistemi: Hitit & Hammurlab
# -------------------------------------------------------

# DB bağlantısı (analiz_routes ile aynı config)
_DB_CFG = {
    "host": "localhost", "user": "root",
    "password": "", "database": "sporthink_mutabakat", "charset": "utf8mb4"
}

def _get_db():
    import mysql.connector
    return mysql.connector.connect(**_DB_CFG)


@upload_bp.route("/erp/barkod-uyari", methods=["GET"])
def erp_barkod_uyari():
    """
    Hammurlab'da (siparisler + iptal/iade) olup
    Hitit'te (satislar + iadeler) hiç geçmeyen barkodları döner.
    """
    try:
        conn = _get_db()
        cur  = conn.cursor(dictionary=True)

        # Hitit'teki tüm benzersiz barkodlar
        cur.execute("""
            SELECT DISTINCT barkod FROM hitit_satislar  WHERE barkod IS NOT NULL AND barkod != ''
            UNION
            SELECT DISTINCT barkod FROM hitit_iadeler   WHERE barkod IS NOT NULL AND barkod != ''
        """)
        hitit_barkodlar = {r["barkod"] for r in cur.fetchall()}

        # Hammurlab'daki tüm barkodlar (kaynak bilgisiyle)
        cur.execute("""
            SELECT DISTINCT barkod, 'siparisler' AS kaynak, urun_adi, marka
            FROM hamurlab_siparisler
            WHERE barkod IS NOT NULL AND barkod != ''
            UNION
            SELECT DISTINCT barkod, 'iptal_iade' AS kaynak, urun_adi, marka
            FROM hamurlab_iptal_iade
            WHERE barkod IS NOT NULL AND barkod != ''
        """)
        hamurlab_rows = cur.fetchall()
        cur.close()
        conn.close()

        # Fark: Hammurlab'da olup Hitit'te olmayan
        eksikler = [
            r for r in hamurlab_rows
            if r["barkod"] not in hitit_barkodlar
        ]

        # Tekrarları barkod bazında birleştir
        goruldu = {}
        for r in eksikler:
            b = r["barkod"]
            if b not in goruldu:
                goruldu[b] = {
                    "barkod":   b,
                    "urun_adi": r["urun_adi"] or "-",
                    "marka":    r["marka"]    or "-",
                    "kaynaklar": set(),
                }
            goruldu[b]["kaynaklar"].add(r["kaynak"])

        sonuc = []
        for v in goruldu.values():
            v["kaynaklar"] = list(v["kaynaklar"])
            sonuc.append(v)

        return jsonify({
            "uyari_var": len(sonuc) > 0,
            "eksik_barkod_sayisi": len(sonuc),
            "hitit_barkod_sayisi": len(hitit_barkodlar),
            "eksikler": sonuc[:100]   # Max 100 satır döndür
        })

    except Exception as e:
        return jsonify({"hata": str(e)}), 500

ERP_CONFIG = {
    "hitit": {
        "label": "Hitit ERP",
        "emoji": "🏭",
        "veri_tipleri": [
            {"key": "satislar", "label": "Satışlar"},
            {"key": "iadeler",  "label": "İadeler"},
        ]
    },
    "hammurlab": {
        "label": "Hammurlab",
        "emoji": "📋",
        "veri_tipleri": [
            {"key": "siparisler",  "label": "Siparişler"},
            {"key": "iptal_iade", "label": "İptal / İade"},
        ]
    },
}


def get_erp_importer_method(kaynak, data_type):
    metodlar = {
        "hitit": {
            "satislar": HititSatisImporter().import_satislar,
            "iadeler":  HititIadeImporter().import_iadeler,
        },
        "hammurlab": {
            "siparisler":  HamurlabSiparisImporter().import_siparisler,
            "iptal_iade":  HamurlabIptalIadeImporter().import_iptal_iade,
        },
    }
    src = metodlar.get(kaynak)
    if not src:
        return None
    return src.get(data_type)


@upload_bp.route("/erp/sources", methods=["GET"])
def get_erp_sources():
    return jsonify(ERP_CONFIG)


@upload_bp.route("/erp/upload", methods=["POST"])
def erp_upload():
    kaynak    = request.form.get("kaynak", "").lower().strip()
    data_type = request.form.get("data_type", "").strip()
    dosya     = request.files.get("file")

    if not dosya or dosya.filename == "":
        return jsonify({"basarili": False, "hata": "Dosya secilmedi."}), 400

    if not kaynak or not data_type:
        return jsonify({"basarili": False, "hata": "Kaynak veya veri turu belirtilmedi."}), 400

    if not dosya.filename.endswith((".xlsx", ".xls")):
        return jsonify({"basarili": False, "hata": "Sadece .xlsx veya .xls dosyalari kabul edilir."}), 400

    gecici_yol = os.path.join(current_app.config["UPLOAD_FOLDER"], dosya.filename)
    dosya.save(gecici_yol)

    try:
        metod = get_erp_importer_method(kaynak, data_type)

        if not metod:
            log_yaz(kaynak, data_type, dosya.filename, 0, "hata",
                    f"Tanimsiz kombinasyon: {kaynak}/{data_type}")
            return jsonify({
                "basarili": False,
                "hata": f"Gecersiz kombinasyon: '{kaynak}' / '{data_type}'"
            }), 400

        import pandas as pd
        satir_sayisi = len(pd.read_excel(gecici_yol))
        metod(gecici_yol)

        log_kayit = log_yaz(kaynak, data_type, dosya.filename, satir_sayisi, "basarili")

        return jsonify({
            "basarili": True,
            "mesaj": f"{satir_sayisi} satir basariyla yuklendi.",
            "log": log_kayit
        })

    except Exception as e:
        hata_str = str(e)
        log_kayit = log_yaz(kaynak, data_type, dosya.filename, 0, "hata", hata_str)
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