# ============================================================
# E-Ticaret Dijital Mutabakat ve Karlılık Analizi Platformu
# Karlılık Hesaplama Motoru v1.0
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
        database="eticaret_mutabakat",
        charset="utf8mb4"
    )


# ------------------------------------------------------------
# Net Gelir Hesaplama
# ------------------------------------------------------------

def net_gelir_hesapla(
    siparis_tutari:         Decimal,
    indirim_kupon:          Decimal = Decimal("0"),
    komisyon:               Decimal = Decimal("0"),
    ceza_ek_bedeller:       Decimal = Decimal("0"),
    kargo_kesintisi:        Decimal = Decimal("0"),
    iade_tutari:            Decimal = Decimal("0"),
    iade_komisyon:          Decimal = Decimal("0"),
) -> Decimal:
    """
    Dokümandaki formül:
    Net Gelir = Sipariş Tutarı
                - İndirim/Kupon
                - Komisyon
                - Ceza/Ek Bedeller
                - Pazaryeri Kargo Kesintisi
                - (İade Tutarı + Komisyon ve ek bedel iadeleri)
    """
    net_gelir = (
        siparis_tutari
        - indirim_kupon
        - komisyon
        - ceza_ek_bedeller
        - kargo_kesintisi
        - iade_tutari
        - iade_komisyon
    )
    return net_gelir


# ------------------------------------------------------------
# Net Kâr Hesaplama
# ------------------------------------------------------------

def net_kar_hesapla(
    net_gelir:              Decimal,
    urun_maliyeti:          Decimal = Decimal("0"),
    kargo_maliyeti:         Decimal = Decimal("0"),
    pazaryeri_maliyetleri:  Decimal = Decimal("0"),
) -> Decimal:
    """
    Dokümandaki formül:
    Net Kâr = Net Gelir - (Ürün Maliyeti + Kargo Maliyeti + Pazaryeri Maliyetleri)
    """
    net_kar = (
        net_gelir
        - urun_maliyeti
        - kargo_maliyeti
        - pazaryeri_maliyetleri
    )
    return net_kar


# ------------------------------------------------------------
# Kâr Marjı Hesaplama
# ------------------------------------------------------------

def kar_marji_hesapla(net_kar: Decimal, siparis_tutari: Decimal) -> Decimal:
    """
    Kâr Marjı = Net Kâr / Sipariş Tutarı
    Sipariş tutarı 0 ise 0 döner (sıfıra bölme hatası engellenir).
    """
    if siparis_tutari == Decimal("0"):
        return Decimal("0")
    return (net_kar / siparis_tutari).quantize(Decimal("0.00000001"))


# ------------------------------------------------------------
# Tek Sipariş İçin Tam Hesaplama
# ------------------------------------------------------------

def siparis_karlilik_hesapla(siparis: dict) -> dict:
    """
    Bir siparişin tüm karlılık değerlerini hesaplar.

    Parametre olarak sipariş dict'i alır:
    {
        "siparis_tutari":        849.90,
        "urun_maliyeti":         320.00,
        "kargo_maliyeti":        25.00,
        "komisyon":              127.50,
        "iade_komisyon":         0.00,
        "kargo_kesintisi":       34.99,
        "iade_tutari":           0.00,
        "indirim_kupon":         50.00,
        "ceza_ek_bedeller":      0.00,
        "pazaryeri_maliyetleri": 15.00,
    }
    """

    # Tüm değerleri Decimal'e çevir (float gelirse de çalışsın)
    s = {k: Decimal(str(v)) for k, v in siparis.items()}

    # Net Gelir
    net_gelir = net_gelir_hesapla(
        siparis_tutari   = s.get("siparis_tutari",        Decimal("0")),
        indirim_kupon    = s.get("indirim_kupon",         Decimal("0")),
        komisyon         = s.get("komisyon",              Decimal("0")),
        ceza_ek_bedeller = s.get("ceza_ek_bedeller",      Decimal("0")),
        kargo_kesintisi  = s.get("kargo_kesintisi",       Decimal("0")),
        iade_tutari      = s.get("iade_tutari",           Decimal("0")),
        iade_komisyon    = s.get("iade_komisyon",         Decimal("0")),
    )

    # Net Kâr
    net_kar = net_kar_hesapla(
        net_gelir             = net_gelir,
        urun_maliyeti         = s.get("urun_maliyeti",          Decimal("0")),
        kargo_maliyeti        = s.get("kargo_maliyeti",         Decimal("0")),
        pazaryeri_maliyetleri = s.get("pazaryeri_maliyetleri",  Decimal("0")),
    )

    # Kâr Marjı
    kar_marji = kar_marji_hesapla(net_kar, s.get("siparis_tutari", Decimal("0")))

    # Zarar mı?
    is_loss = net_kar < Decimal("0")

    return {
        "net_gelir":   net_gelir,
        "net_kar":     net_kar,
        "kar_marji":   kar_marji,
        "is_loss":     is_loss,
        "uyari":       "🔴 ZARAR EDEN SİPARİŞ" if is_loss else "✅ Kârlı"
    }


# ------------------------------------------------------------
# Veritabanındaki Siparişleri Hesapla ve Kaydet
# ------------------------------------------------------------

def tum_siparisleri_hesapla(marketplace: str = None) -> dict:
    """
    Veritabanındaki tüm siparişlerin karlılığını hesaplar,
    sonuçları order_items ve profitability_summary tablolarına yazar.

    marketplace parametresi verilirse sadece o pazaryeri işlenir.
    """

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Siparişleri çek
        if marketplace:
            cursor.execute("""
                SELECT o.id, o.marketplace, o.total_amount,
                       oi.id AS item_id, oi.unit_price, oi.product_cost,
                       oi.sale_amount, oi.return_amount,
                       oi.calc_sale_commission, oi.calc_return_commission,
                       oi.calc_cargo_amount
                FROM orders o
                JOIN order_items oi ON o.id = oi.order_id
                WHERE o.marketplace = %s
            """, (marketplace,))
        else:
            cursor.execute("""
                SELECT o.id, o.marketplace, o.total_amount,
                       oi.id AS item_id, oi.unit_price, oi.product_cost,
                       oi.sale_amount, oi.return_amount,
                       oi.calc_sale_commission, oi.calc_return_commission,
                       oi.calc_cargo_amount
                FROM orders o
                JOIN order_items oi ON o.id = oi.order_id
            """)

        satirlar = cursor.fetchall()

    finally:
        cursor.close()
        conn.close()

    # Her satır için hesapla
    ozet = {
        "toplam": len(satirlar),
        "karli":  0,
        "zararli": 0,
        "toplam_net_kar": Decimal("0"),
        "zarar_siparisler": []
    }

    for satir in satirlar:
        siparis_verisi = {
            "siparis_tutari":        satir["total_amount"]            or 0,
            "urun_maliyeti":         satir["product_cost"]            or 0,
            "komisyon":              satir["calc_sale_commission"]     or 0,
            "iade_komisyon":         satir["calc_return_commission"]   or 0,
            "kargo_kesintisi":       satir["calc_cargo_amount"]        or 0,
            "iade_tutari":           satir["return_amount"]            or 0,
            "indirim_kupon":         Decimal("0"),   # CSV gelince doldurulacak
            "ceza_ek_bedeller":      Decimal("0"),   # CSV gelince doldurulacak
            "kargo_maliyeti":        Decimal("0"),   # CSV gelince doldurulacak
            "pazaryeri_maliyetleri": Decimal("0"),   # CSV gelince doldurulacak
        }

        sonuc = siparis_karlilik_hesapla(siparis_verisi)

        # order_items tablosunu güncelle
        _order_item_guncelle(satir["item_id"], sonuc)

        # profitability_summary tablosunu güncelle
        _profitability_summary_guncelle(satir["id"], satir["marketplace"], sonuc)

        # Özeti güncelle
        ozet["toplam_net_kar"] += sonuc["net_kar"]
        if sonuc["is_loss"]:
            ozet["zararli"] += 1
            ozet["zarar_siparisler"].append({
                "order_id": satir["id"],
                "marketplace": satir["marketplace"],
                "net_kar": float(sonuc["net_kar"])
            })
        else:
            ozet["karli"] += 1

    # Özet rapor
    print("\n" + "="*60)
    print(f"  KARLILIK RAPORU — {datetime.now().strftime('%d.%m.%Y %H:%M')}")
    print("="*60)
    print(f"  Toplam sipariş   : {ozet['toplam']}")
    print(f"  ✅ Kârlı          : {ozet['karli']}")
    print(f"  🔴 Zararlı        : {ozet['zararli']}")
    print(f"  💰 Toplam Net Kâr : {ozet['toplam_net_kar']:.2f}₺")
    print("="*60 + "\n")

    if ozet["zarar_siparisler"]:
        print("🔴 ZARAR EDEN SİPARİŞLER:")
        for z in ozet["zarar_siparisler"]:
            print(f"   Order ID: {z['order_id']} | {z['marketplace']} | Net Kâr: {z['net_kar']:.2f}₺")
        print()

    return ozet


# ------------------------------------------------------------
# Yardımcı: Veritabanı Güncelleme Fonksiyonları
# ------------------------------------------------------------

def _order_item_guncelle(item_id: int, sonuc: dict) -> None:
    """order_items tablosundaki net_revenue, net_profit, profit_margin günceller."""
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            UPDATE order_items
            SET net_revenue   = %s,
                net_profit    = %s,
                profit_margin = %s
            WHERE id = %s
        """, (
            sonuc["net_gelir"],
            sonuc["net_kar"],
            sonuc["kar_marji"],
            item_id
        ))
        conn.commit()
    finally:
        cursor.close()
        conn.close()


def _profitability_summary_guncelle(order_id: int, marketplace: str, sonuc: dict) -> None:
    """profitability_summary tablosunu günceller veya yeni satır ekler."""
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO profitability_summary (order_id, marketplace_order_id, barcode,
                marketplace, order_status, order_created_at,
                net_revenue, net_profit, profit_margin, is_loss)
            SELECT o.id, o.marketplace_order_id, o.barcode,
                   o.marketplace, o.status, o.order_created_at,
                   %s, %s, %s, %s
            FROM orders o WHERE o.id = %s
            ON DUPLICATE KEY UPDATE
                net_revenue   = VALUES(net_revenue),
                net_profit    = VALUES(net_profit),
                profit_margin = VALUES(profit_margin),
                is_loss       = VALUES(is_loss)
        """, (
            sonuc["net_gelir"],
            sonuc["net_kar"],
            sonuc["kar_marji"],
            1 if sonuc["is_loss"] else 0,
            order_id
        ))
        conn.commit()
    finally:
        cursor.close()
        conn.close()


# ------------------------------------------------------------
# Çalıştırma
# ------------------------------------------------------------

if __name__ == "__main__":

    # Tek sipariş testi — elle değer girerek dene
    test_siparis = {
        "siparis_tutari":        Decimal("849.90"),
        "urun_maliyeti":         Decimal("320.00"),
        "kargo_maliyeti":        Decimal("25.00"),
        "komisyon":              Decimal("127.50"),
        "iade_komisyon":         Decimal("0.00"),
        "kargo_kesintisi":       Decimal("34.99"),
        "iade_tutari":           Decimal("0.00"),
        "indirim_kupon":         Decimal("50.00"),
        "ceza_ek_bedeller":      Decimal("0.00"),
        "pazaryeri_maliyetleri": Decimal("15.00"),
    }

    sonuc = siparis_karlilik_hesapla(test_siparis)

    print("\n--- TEK SİPARİŞ TEST SONUCU ---")
    print(f"  Net Gelir  : {sonuc['net_gelir']:.2f}₺")
    print(f"  Net Kâr    : {sonuc['net_kar']:.2f}₺")
    print(f"  Kâr Marjı  : %{float(sonuc['kar_marji'])*100:.2f}")
    print(f"  Durum      : {sonuc['uyari']}")

    # Tüm siparişler için çalıştır
    # tum_siparisleri_hesapla()

    # Sadece Trendyol için
    # tum_siparisleri_hesapla(marketplace="Trendyol")
