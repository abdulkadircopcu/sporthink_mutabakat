# ============================================================
# E-Ticaret Dijital Mutabakat ve Karlılık Analizi Platformu
# Karlılık Hesaplama Motoru v2.0
# Sporthink E-Ticaret Departmanı
# ============================================================

import mysql.connector
from decimal import Decimal
from datetime import datetime


# ------------------------------------------------------------
# Veritabanı Bağlantısı
# ------------------------------------------------------------

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="sporthink_mutabakat",
        charset="utf8mb4"
    )


# ------------------------------------------------------------
# Kural 1: Komisyon Tabanı (Pazaryerine Göre)
#
# Trendyol: Kampanya indirimi olsa bile komisyon,
#           indirimsiz fiyat (toplam_tutar) üzerinden hesaplanır.
# Diğerleri: İndirimden sonraki fiyat üzerinden hesaplanır.
# ------------------------------------------------------------

def komisyon_taban_hesapla(
    pazaryeri:      str,
    indirimli_fiyat: Decimal,
    toplam_tutar:   Decimal,
) -> Decimal:
    if pazaryeri.lower() == "trendyol":
        return toplam_tutar
    return indirimli_fiyat


# ------------------------------------------------------------
# Kural 2: Desi Hesaplama (Sepet Bazlı)
#
# Tüm sipariş kalemlerinin SUM(adet × tahmini_desi) değeri.
# Pazaryerinin faturasındaki desiyle karşılaştırılır.
# ------------------------------------------------------------

def siparis_desi_hesapla(cursor, siparis_id: int) -> int:
    cursor.execute("""
        SELECT COALESCE(SUM(adet * tahmini_desi), 0)
        FROM siparis_kalemleri
        WHERE siparis_id = %s AND tahmini_desi IS NOT NULL
    """, (siparis_id,))
    row = cursor.fetchone()
    return int(row[0]) if row and row[0] else 0


def kategori_desi_getir(
    cursor,
    ana_kategori: str,
    alt_kategori: str = None,
    cinsiyet:     str = None,
) -> int | None:
    cursor.execute("""
        SELECT tahmini_desi
        FROM kategori_desi_listesi
        WHERE ana_kategori = %s
          AND (alt_kategori = %s OR (alt_kategori IS NULL AND %s IS NULL))
          AND (cinsiyet = %s OR (cinsiyet IS NULL AND %s IS NULL))
        LIMIT 1
    """, (ana_kategori, alt_kategori, alt_kategori, cinsiyet, cinsiyet))
    row = cursor.fetchone()
    return int(row[0]) if row else None


# ------------------------------------------------------------
# Net Gelir Hesaplama
#
# Kural 3 (İade): İadelerde platform_hizmet_bedeli ve
#                 pazarlama_hizmet_bedeli alınmaz.
#                 Ekstra iade kargo bedeli kargo_kesintisi içinde gelir.
# ------------------------------------------------------------

def net_gelir_hesapla(
    siparis_tutari:          Decimal,
    indirim_kupon:           Decimal = Decimal("0"),
    komisyon:                Decimal = Decimal("0"),
    ceza_ek_bedeller:        Decimal = Decimal("0"),
    kargo_kesintisi:         Decimal = Decimal("0"),
    iade_tutari:             Decimal = Decimal("0"),
    iade_komisyon:           Decimal = Decimal("0"),
    iade_mi:                 bool    = False,
    platform_hizmet_bedeli:  Decimal = Decimal("0"),
    pazarlama_hizmet_bedeli: Decimal = Decimal("0"),
) -> Decimal:
    if iade_mi:
        platform_hizmet_bedeli  = Decimal("0")
        pazarlama_hizmet_bedeli = Decimal("0")

    return (
        siparis_tutari
        - indirim_kupon
        - komisyon
        - ceza_ek_bedeller
        - kargo_kesintisi
        - iade_tutari
        - iade_komisyon
        - platform_hizmet_bedeli
        - pazarlama_hizmet_bedeli
    )


# ------------------------------------------------------------
# Net Kâr Hesaplama
# ------------------------------------------------------------

def net_kar_hesapla(
    net_gelir:              Decimal,
    urun_maliyeti:          Decimal = Decimal("0"),
    kargo_maliyeti:         Decimal = Decimal("0"),
    pazaryeri_maliyetleri:  Decimal = Decimal("0"),
) -> Decimal:
    return net_gelir - urun_maliyeti - kargo_maliyeti - pazaryeri_maliyetleri


# ------------------------------------------------------------
# Kâr Marjı Hesaplama
# ------------------------------------------------------------

def kar_marji_hesapla(net_kar: Decimal, siparis_tutari: Decimal) -> Decimal:
    if siparis_tutari == Decimal("0"):
        return Decimal("0")
    return (net_kar / siparis_tutari).quantize(Decimal("0.00000001"))


# ------------------------------------------------------------
# Tek Sipariş İçin Tam Hesaplama
# ------------------------------------------------------------

def siparis_karlilik_hesapla(siparis: dict) -> dict:
    """
    Bir siparişin tüm karlılık değerlerini hesaplar.

    Beklenen siparis dict:
    {
        "pazaryeri":              "Trendyol",
        "iade_mi":                False,
        "siparis_tutari":         849.90,   # müşterinin ödediği (indirimli)
        "toplam_tutar":           900.00,   # Trendyol için indirimsiz brüt fiyat
        "urun_maliyeti":          320.00,
        "kargo_maliyeti":         25.00,
        "komisyon_orani":         0.10,     # ondalık (0.10 = %10)
        "iade_komisyon":          0.00,
        "kargo_kesintisi":        34.99,    # iade ise ekstra kargo buraya
        "iade_tutari":            0.00,
        "indirim_kupon":          50.00,
        "ceza_ek_bedeller":       0.00,
        "pazaryeri_maliyetleri":  15.00,
        "platform_hizmet_bedeli": 0.00,
        "pazarlama_hizmet_bedeli":0.00,
    }
    """
    s = {
        k: (Decimal(str(v)) if not isinstance(v, (bool, str)) else v)
        for k, v in siparis.items()
    }

    pazaryeri = siparis.get("pazaryeri", "")
    iade_mi   = bool(siparis.get("iade_mi", False))

    # Komisyon tabanı: Trendyol=indirimsiz, diğerleri=indirimli
    komisyon_taban = komisyon_taban_hesapla(
        pazaryeri       = pazaryeri,
        indirimli_fiyat = s.get("siparis_tutari", Decimal("0")),
        toplam_tutar    = s.get("toplam_tutar", s.get("siparis_tutari", Decimal("0"))),
    )
    komisyon_tutari = komisyon_taban * s.get("komisyon_orani", Decimal("0"))

    net_gelir = net_gelir_hesapla(
        siparis_tutari          = s.get("siparis_tutari",          Decimal("0")),
        indirim_kupon           = s.get("indirim_kupon",           Decimal("0")),
        komisyon                = komisyon_tutari,
        ceza_ek_bedeller        = s.get("ceza_ek_bedeller",        Decimal("0")),
        kargo_kesintisi         = s.get("kargo_kesintisi",         Decimal("0")),
        iade_tutari             = s.get("iade_tutari",             Decimal("0")),
        iade_komisyon           = s.get("iade_komisyon",           Decimal("0")),
        iade_mi                 = iade_mi,
        platform_hizmet_bedeli  = s.get("platform_hizmet_bedeli",  Decimal("0")),
        pazarlama_hizmet_bedeli = s.get("pazarlama_hizmet_bedeli", Decimal("0")),
    )

    net_kar   = net_kar_hesapla(
        net_gelir             = net_gelir,
        urun_maliyeti         = s.get("urun_maliyeti",         Decimal("0")),
        kargo_maliyeti        = s.get("kargo_maliyeti",        Decimal("0")),
        pazaryeri_maliyetleri = s.get("pazaryeri_maliyetleri", Decimal("0")),
    )

    kar_marji = kar_marji_hesapla(net_kar, s.get("siparis_tutari", Decimal("0")))
    is_loss   = net_kar < Decimal("0")

    return {
        "pazaryeri":       pazaryeri,
        "iade_mi":         iade_mi,
        "komisyon_taban":  komisyon_taban,
        "komisyon_tutari": komisyon_tutari,
        "net_gelir":       net_gelir,
        "net_kar":         net_kar,
        "kar_marji":       kar_marji,
        "is_loss":         is_loss,
        "uyari":           "[ZARAR] ZARAR EDEN SIPARIS" if is_loss else "[OK] Karli",
    }


# ------------------------------------------------------------
# Test
# ------------------------------------------------------------

if __name__ == "__main__":

    # --- Trendyol: indirimli müşteri fiyatı 800, brüt 1000, komisyon %10 ---
    print("=== Trendyol testi (indirimsiz=1000, indirimli=800) ===")
    t1 = siparis_karlilik_hesapla({
        "pazaryeri":    "Trendyol",
        "iade_mi":       False,
        "siparis_tutari": 800,
        "toplam_tutar":  1000,   # indirimsiz
        "komisyon_orani": 0.10,
        "urun_maliyeti":  300,
    })
    print(f"  Komisyon taban  : {t1['komisyon_taban']} TL (beklenen: 1000)")
    print(f"  Komisyon tutari : {t1['komisyon_tutari']} TL (beklenen: 100)")
    print(f"  Net Gelir       : {t1['net_gelir']} TL")
    print(f"  Net Kar         : {t1['net_kar']} TL")

    # --- Hepsiburada: indirimden sonra komisyon ---
    print("\n=== Hepsiburada testi (indirimli=800, komisyon %10) ===")
    t2 = siparis_karlilik_hesapla({
        "pazaryeri":    "Hepsiburada",
        "iade_mi":       False,
        "siparis_tutari": 800,
        "toplam_tutar":  1000,
        "komisyon_orani": 0.10,
        "urun_maliyeti":  300,
    })
    print(f"  Komisyon taban  : {t2['komisyon_taban']} TL (beklenen: 800)")
    print(f"  Komisyon tutari : {t2['komisyon_tutari']} TL (beklenen: 80)")

    # --- İade: platform/pazarlama hizmet bedeli sıfırlanmalı ---
    print("\n=== İade testi (platform_hizmet_bedeli silinmeli) ===")
    t3 = siparis_karlilik_hesapla({
        "pazaryeri":              "N11",
        "iade_mi":                 True,
        "siparis_tutari":          500,
        "komisyon_orani":          0.08,
        "urun_maliyeti":           200,
        "kargo_kesintisi":         30,   # iade kargosu
        "platform_hizmet_bedeli":  50,   # iade olduğu için silinecek
        "pazarlama_hizmet_bedeli": 20,   # iade olduğu için silinecek
    })
    print(f"  Komisyon tutari          : {t3['komisyon_tutari']} TL")
    print(f"  Platform hizmet bedeli   : 0 TL (iade nedeniyle silindi)")
    print(f"  Net Gelir                : {t3['net_gelir']} TL")
