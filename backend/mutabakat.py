# ============================================================
# E-Ticaret Dijital Mutabakat ve Karlılık Analizi Platformu
# Mutabakat Motoru (Reconciliation Engine) v1.0
# Sporthink E-Ticaret Departmanı
# ============================================================

import mysql.connector
from decimal import Decimal
from datetime import datetime
from enum import Enum


# ------------------------------------------------------------
# Sabitler
# ------------------------------------------------------------

class ReconciliationStatus(str, Enum):
    ESLESDI          = "eslesdi"
    FARK_VAR         = "fark_var"
    MANUEL_INCELEME  = "manuel_inceleme"
    BEKLEMEDE        = "beklemede"

class AlertLevel(str, Enum):
    NORMAL   = "normal"    # Fark yok
    DUSUK    = "dusuk"     # Biz fazla aldık (pazaryeri lehimize hata yaptı)
    KRITIK   = "kritik"    # Biz az aldık (biz zarar ettik) → uyarı!


# ------------------------------------------------------------
# Veritabanı Bağlantısı
# ------------------------------------------------------------

def get_db_connection():
    """
    MySQL bağlantısı döner.
    Kullanım: conn = get_db_connection()
    """
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",          # WAMP varsayılan şifresi boş
        database="eticaret_mutabakat",
        charset="utf8mb4"
    )


# ------------------------------------------------------------
# Yardımcı Fonksiyonlar
# ------------------------------------------------------------

def hesapla_fark(beklenen: Decimal, gerceklesen: Decimal) -> Decimal:
    """
    Farkı hesaplar.
    Pozitif → biz fazla aldık (iyi)
    Negatif → biz az aldık (kötü, uyarı verilecek)
    """
    return gerceklesen - beklenen


def belirle_alert_seviyesi(fark: Decimal) -> AlertLevel:
    """
    Farka göre uyarı seviyesini belirler.

    Karar mantığı:
      fark == 0   → NORMAL   (tamam, sıkıntı yok)
      fark > 0    → DUSUK    (pazaryeri fazla ödedi, bizim lehimize)
      fark < 0    → KRITIK   (pazaryeri az ödedi, biz zarar ettik → uyarı!)
    """
    if fark == Decimal("0"):
        return AlertLevel.NORMAL
    elif fark > Decimal("0"):
        return AlertLevel.DUSUK
    else:
        return AlertLevel.KRITIK


def belirle_reconciliation_status(fark: Decimal, eslesme_bulundu: bool) -> ReconciliationStatus:
    """
    Mutabakat durumunu belirler.
    """
    if not eslesme_bulundu:
        return ReconciliationStatus.MANUEL_INCELEME
    elif fark == Decimal("0"):
        return ReconciliationStatus.ESLESDI
    else:
        return ReconciliationStatus.FARK_VAR


# ------------------------------------------------------------
# Aşama 1 — Sipariş Eşleştirme
# ------------------------------------------------------------

def siparis_eslestir(cursor, marketplace_order_id: str, marketplace: str) -> dict | None:
    """
    Pazaryeri sipariş numarasına göre orders tablosundan siparişi bulur.

    Önce direkt eşleşme dener.
    Bulamazsa None döner → manuel inceleme kuyruğuna gider.
    """

    # Direkt eşleştirme: sipariş numarası tam eşleşiyor mu?
    cursor.execute("""
        SELECT id, order_id, marketplace, total_amount, status
        FROM orders
        WHERE marketplace_order_id = %s AND marketplace = %s
        LIMIT 1
    """, (marketplace_order_id, marketplace))

    sonuc = cursor.fetchone()

    if sonuc:
        return {
            "id": sonuc[0],
            "order_id": sonuc[1],
            "marketplace": sonuc[2],
            "total_amount": Decimal(str(sonuc[3])),
            "status": sonuc[4],
            "eslesme_yontemi": "direkt"
        }

    # Eşleşme bulunamadı
    return None


# ------------------------------------------------------------
# Aşama 2 — Beklenen Ödeme Hesaplama
# ------------------------------------------------------------

def beklenen_odeme_hesapla(cursor, order_id: int) -> dict:
    """
    Bir sipariş için beklenen (hesaplanan) ödeme tutarlarını döner.
    order_items tablosundaki hesaplanmış değerleri toplar.
    """

    cursor.execute("""
        SELECT
            COALESCE(SUM(calc_sale_commission), 0)   AS komisyon,
            COALESCE(SUM(calc_return_commission), 0) AS iade_komisyon,
            COALESCE(SUM(calc_cargo_amount), 0)      AS kargo,
            COALESCE(SUM(net_revenue), 0)            AS net_gelir
        FROM order_items
        WHERE order_id = %s
    """, (order_id,))

    row = cursor.fetchone()

    return {
        "beklenen_komisyon":       Decimal(str(row[0])),
        "beklenen_iade_komisyon":  Decimal(str(row[1])),
        "beklenen_kargo":          Decimal(str(row[2])),
        "beklenen_net_gelir":      Decimal(str(row[3])),
        # Beklenen toplam ödeme = net gelir - komisyon - kargo
        "beklenen_odeme": (
            Decimal(str(row[3]))
            - Decimal(str(row[0]))
            + Decimal(str(row[1]))   # iade komisyonu gelir olarak eklenir
            - Decimal(str(row[2]))
        )
    }


# ------------------------------------------------------------
# Aşama 3 — Gerçekleşen Ödeme Hesaplama
# ------------------------------------------------------------

def gerceklesen_odeme_hesapla(cursor, order_id: int, marketplace: str) -> dict:
    """
    marketplace_invoices tablosundan gerçekleşen ödeme tutarlarını toplar.
    direction = 'gider' → negatif, 'gelir' → pozitif olarak işlenir.
    """

    cursor.execute("""
        SELECT
            item_type,
            SUM(CASE WHEN direction = 'gelir' THEN amount ELSE -amount END) AS tutar
        FROM marketplace_invoices
        WHERE order_id = %s AND marketplace = %s
        GROUP BY item_type
    """, (order_id, marketplace))

    rows = cursor.fetchall()

    # Kalem tiplerini grupla
    komisyon      = Decimal("0")
    iade_komisyon = Decimal("0")
    kargo         = Decimal("0")
    diger         = Decimal("0")

    for item_type, tutar in rows:
        tutar = Decimal(str(tutar))
        item_type_lower = item_type.lower()

        if "iade komisyon" in item_type_lower:
            iade_komisyon += tutar
        elif "komisyon" in item_type_lower:
            komisyon += tutar
        elif "kargo" in item_type_lower:
            kargo += tutar
        else:
            diger += tutar

    gerceklesen_odeme = komisyon + iade_komisyon + kargo + diger

    return {
        "gerceklesen_komisyon":       komisyon,
        "gerceklesen_iade_komisyon":  iade_komisyon,
        "gerceklesen_kargo":          kargo,
        "gerceklesen_diger":          diger,
        "gerceklesen_odeme":          gerceklesen_odeme
    }


# ------------------------------------------------------------
# Aşama 4 — Mutabakat Kaydını Kaydet
# ------------------------------------------------------------

def mutabakat_kaydet(cursor, order_id: int, marketplace: str,
                     beklenen: dict, gerceklesen: dict,
                     durum: ReconciliationStatus, alert: AlertLevel) -> None:
    """
    Hesaplanan mutabakat sonucunu order_financials tablosuna yazar.
    Kayıt varsa günceller, yoksa yeni ekler.
    """

    net_fark         = hesapla_fark(beklenen["beklenen_odeme"], gerceklesen["gerceklesen_odeme"])
    komisyon_fark    = hesapla_fark(beklenen["beklenen_komisyon"], gerceklesen["gerceklesen_komisyon"])
    kargo_fark       = hesapla_fark(beklenen["beklenen_kargo"], gerceklesen["gerceklesen_kargo"])

    cursor.execute("""
        INSERT INTO order_financials (
            order_id, marketplace,
            expected_payment, actual_payment, payment_diff,
            expected_commission, billed_commission, commission_diff,
            expected_cargo, billed_cargo_sale, cargo_diff,
            reconciliation_status, reconciled_at
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            actual_payment        = VALUES(actual_payment),
            payment_diff          = VALUES(payment_diff),
            billed_commission     = VALUES(billed_commission),
            commission_diff       = VALUES(commission_diff),
            billed_cargo_sale     = VALUES(billed_cargo_sale),
            cargo_diff            = VALUES(cargo_diff),
            reconciliation_status = VALUES(reconciliation_status),
            reconciled_at         = VALUES(reconciled_at)
    """, (
        order_id, marketplace,
        beklenen["beklenen_odeme"], gerceklesen["gerceklesen_odeme"], net_fark,
        beklenen["beklenen_komisyon"], gerceklesen["gerceklesen_komisyon"], komisyon_fark,
        beklenen["beklenen_kargo"], gerceklesen["gerceklesen_kargo"], kargo_fark,
        durum.value,
        datetime.now()
    ))


# ------------------------------------------------------------
# Ana Fonksiyon — Tek Sipariş Mutabakatı
# ------------------------------------------------------------

def siparis_mutabakat_yap(marketplace_order_id: str, marketplace: str) -> dict:
    """
    Tek bir sipariş için mutabakat yapar ve sonucu döner.

    Dönüş değeri örneği:
    {
        "order_id": 123,
        "durum": "fark_var",
        "alert": "kritik",
        "net_fark": -23.20,
        "mesaj": "⚠️ DİKKAT: Pazaryeri eksik ödedi! Fark: -23.20₺"
    }
    """

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Adım 1: Siparişi bul
        siparis = siparis_eslestir(cursor, marketplace_order_id, marketplace)

        if not siparis:
            return {
                "order_id": None,
                "marketplace_order_id": marketplace_order_id,
                "durum": ReconciliationStatus.MANUEL_INCELEME.value,
                "alert": AlertLevel.KRITIK.value,
                "net_fark": None,
                "mesaj": f"🔴 Sipariş bulunamadı: {marketplace_order_id} — Manuel inceleme gerekli"
            }

        order_id = siparis["id"]

        # Adım 2: Beklenen ödemeyi hesapla
        beklenen = beklenen_odeme_hesapla(cursor, order_id)

        # Adım 3: Gerçekleşen ödemeyi hesapla
        gerceklesen = gerceklesen_odeme_hesapla(cursor, order_id, marketplace)

        # Adım 4: Fark ve durum hesapla
        net_fark = hesapla_fark(beklenen["beklenen_odeme"], gerceklesen["gerceklesen_odeme"])
        alert    = belirle_alert_seviyesi(net_fark)
        durum    = belirle_reconciliation_status(net_fark, eslesme_bulundu=True)

        # Adım 5: Veritabanına kaydet
        mutabakat_kaydet(cursor, order_id, marketplace, beklenen, gerceklesen, durum, alert)
        conn.commit()

        # Adım 6: Mesajı oluştur
        if alert == AlertLevel.NORMAL:
            mesaj = f"✅ Mutabakat tamam: {marketplace_order_id}"
        elif alert == AlertLevel.DUSUK:
            mesaj = f"🟡 Bilgi: Pazaryeri fazla ödedi. Fark: +{net_fark}₺ — {marketplace_order_id}"
        else:  # KRITIK
            mesaj = f"🔴 DİKKAT: Pazaryeri eksik ödedi! Fark: {net_fark}₺ — {marketplace_order_id}"

        return {
            "order_id": order_id,
            "marketplace_order_id": marketplace_order_id,
            "durum": durum.value,
            "alert": alert.value,
            "net_fark": float(net_fark),
            "beklenen_odeme": float(beklenen["beklenen_odeme"]),
            "gerceklesen_odeme": float(gerceklesen["gerceklesen_odeme"]),
            "mesaj": mesaj
        }

    except Exception as e:
        conn.rollback()
        raise e

    finally:
        cursor.close()
        conn.close()


# ------------------------------------------------------------
# Toplu Mutabakat — Tüm Bekleyen Siparişler
# ------------------------------------------------------------

def toplu_mutabakat_yap(marketplace: str = None) -> dict:
    """
    Tüm beklemedeki siparişler için mutabakat yapar.
    marketplace parametresi verilirse sadece o pazaryeri işlenir.

    Dönüş: özet rapor
    {
        "toplam": 150,
        "eslesdi": 120,
        "fark_var": 25,
        "manuel_inceleme": 5,
        "kritik_uyarilar": [...],   ← biz zarar edenler
        "dusuk_uyarilar": [...]     ← bizim lehimize fark olanlar
    }
    """

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Beklemedeki siparişleri çek
        if marketplace:
            cursor.execute("""
                SELECT o.marketplace_order_id, o.marketplace
                FROM orders o
                LEFT JOIN order_financials f ON o.id = f.order_id
                WHERE (f.reconciliation_status = 'beklemede' OR f.order_id IS NULL)
                AND o.marketplace = %s
            """, (marketplace,))
        else:
            cursor.execute("""
                SELECT o.marketplace_order_id, o.marketplace
                FROM orders o
                LEFT JOIN order_financials f ON o.id = f.order_id
                WHERE (f.reconciliation_status = 'beklemede' OR f.order_id IS NULL)
            """)

        siparisler = cursor.fetchall()

    finally:
        cursor.close()
        conn.close()

    # Her sipariş için mutabakat yap
    ozet = {
        "toplam": len(siparisler),
        "eslesdi": 0,
        "fark_var": 0,
        "manuel_inceleme": 0,
        "kritik_uyarilar": [],    # Biz zarar edenler → öncelikli takip
        "dusuk_uyarilar": []      # Bizim lehimize fark olanlar
    }

    for marketplace_order_id, mkt in siparisler:
        sonuc = siparis_mutabakat_yap(marketplace_order_id, mkt)

        # Özeti güncelle
        if sonuc["durum"] == ReconciliationStatus.ESLESDI.value:
            ozet["eslesdi"] += 1
        elif sonuc["durum"] == ReconciliationStatus.FARK_VAR.value:
            ozet["fark_var"] += 1
            if sonuc["alert"] == AlertLevel.KRITIK.value:
                ozet["kritik_uyarilar"].append(sonuc)   # 🔴 Biz zarar ettik
            else:
                ozet["dusuk_uyarilar"].append(sonuc)    # 🟡 Bizim lehimize
        elif sonuc["durum"] == ReconciliationStatus.MANUEL_INCELEME.value:
            ozet["manuel_inceleme"] += 1
            ozet["kritik_uyarilar"].append(sonuc)       # Manuel de kritik sayılır

    # Özet raporu yazdır
    print("\n" + "="*60)
    print(f"  MUTABAKAT RAPORU — {datetime.now().strftime('%d.%m.%Y %H:%M')}")
    print("="*60)
    print(f"  Toplam sipariş    : {ozet['toplam']}")
    print(f"  ✅ Eşleşti         : {ozet['eslesdi']}")
    print(f"  ⚠️  Fark var        : {ozet['fark_var']}")
    print(f"  🔴 Manuel inceleme : {ozet['manuel_inceleme']}")
    print(f"  🔴 Kritik uyarı    : {len(ozet['kritik_uyarilar'])}")
    print(f"  🟡 Düşük uyarı     : {len(ozet['dusuk_uyarilar'])}")
    print("="*60 + "\n")

    if ozet["kritik_uyarilar"]:
        print("🔴 KRİTİK UYARILAR (Zarar Eden / Eşleşmeyen Siparişler):")
        for u in ozet["kritik_uyarilar"]:
            print(f"   {u['mesaj']}")
        print()

    return ozet


# ------------------------------------------------------------
# Çalıştırma
# ------------------------------------------------------------

if __name__ == "__main__":
    # Tek sipariş testi
    sonuc = siparis_mutabakat_yap(
        marketplace_order_id="123456789",
        marketplace="Trendyol"
    )
    print(sonuc)

    # Tüm Trendyol siparişlerini mutabakat yap
    # ozet = toplu_mutabakat_yap(marketplace="Trendyol")

    # Tüm pazaryerlerini mutabakat yap
    # ozet = toplu_mutabakat_yap()
