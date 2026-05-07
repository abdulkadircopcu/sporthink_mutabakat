# ============================================================
# Mutabakat Pipeline v1.0
# Pazaryeri tablolarından siparisler + karlilik_ozeti'ni doldurur.
#
# Akis:
#   trendyol_komisyon_faturalari  ─┐
#   trendyol_kargo_faturalari     ─┤→ siparisler → karlilik_ozeti
#   pazarama_komisyon_detay       ─┤
#   ...                           ─┘
# ============================================================

import mysql.connector
from decimal import Decimal
from datetime import datetime

from karlilik_hesaplama import get_db_connection, komisyon_taban_hesapla


# ============================================================
# ADIM 1: siparisler_sync
# Pazaryeri fatura tablolarından siparisler'i upsert eder.
# ============================================================

def siparisler_sync(pazaryeri: str = None) -> dict:
    """
    Pazaryeri tablolarindaki fatura verilerini okuyup
    siparisler tablosuna INSERT OR UPDATE yapar.

    Parametreler:
        pazaryeri: "Trendyol", "Pazarama", "N11", "LCW" vb.
                   None → tum pazaryerlerini isle
    """
    conn   = get_db_connection()
    cursor = conn.cursor()
    ozet   = {}

    try:
        hedefler = (
            [pazaryeri] if pazaryeri
            else ["Trendyol", "Pazarama", "N11", "LCW", "Hepsiburada", "Flo", "Amazon"]
        )

        for pz in hedefler:
            try:
                n = _sync_pazaryeri(cursor, pz)
                conn.commit()
                ozet[pz] = {"upsert": n, "hata": None}
                print(f"[{pz}] {n} siparis upsert edildi.")
            except Exception as e:
                conn.rollback()
                ozet[pz] = {"upsert": 0, "hata": str(e)}
                print(f"[{pz}] HATA: {e}")

    finally:
        cursor.close()
        conn.close()

    return ozet


def _sync_pazaryeri(cursor, pazaryeri: str) -> int:
    """Her pazaryeri icin siparisler upsert mantigi."""
    pz = pazaryeri.lower()

    if pz == "trendyol":
        return _sync_trendyol(cursor)
    elif pz == "pazarama":
        return _sync_pazarama(cursor)
    elif pz == "n11":
        return _sync_n11(cursor)
    elif pz == "lcw":
        return _sync_lcw(cursor)
    elif pz == "hepsiburada":
        return _sync_hepsiburada(cursor)
    elif pz == "flo":
        return _sync_flo(cursor)
    elif pz == "amazon":
        return _sync_amazon(cursor)
    else:
        print(f"  [{pazaryeri}] tanimli degil, atlanıyor.")
        return 0


def _upsert_siparis(cursor, kayit: dict) -> None:
    """Tek siparis kaydini siparisler tablosuna upsert eder."""
    cursor.execute("""
        INSERT INTO siparisler (
            siparis_no, pazaryeri_siparis_no, pazaryeri,
            barkod, urun_adi, marka, kategori,
            adet, birim_fiyat, kdv_orani, toplam_tutar, pazaryeri_fiyati,
            durum, siparis_tarihi
        )
        VALUES (%(siparis_no)s, %(pazaryeri_siparis_no)s, %(pazaryeri)s,
                %(barkod)s, %(urun_adi)s, %(marka)s, %(kategori)s,
                %(adet)s, %(birim_fiyat)s, %(kdv_orani)s, %(toplam_tutar)s,
                %(pazaryeri_fiyati)s, %(durum)s, %(siparis_tarihi)s)
        ON DUPLICATE KEY UPDATE
            barkod         = COALESCE(VALUES(barkod),         barkod),
            urun_adi       = COALESCE(VALUES(urun_adi),       urun_adi),
            marka          = COALESCE(VALUES(marka),          marka),
            kategori       = COALESCE(VALUES(kategori),       kategori),
            durum          = VALUES(durum),
            guncelleme_tarihi = NOW()
    """, kayit)


def _sync_trendyol(cursor) -> int:
    """
    trendyol_komisyon_faturalari + trendyol_kargo_faturalari'ndan
    siparisler tablosuna upsert eder.
    Komisyon faturasi: siparis_no, barkod, urun_adi, toplam_tutar, islem_tipi
    """
    cursor.execute("""
        SELECT
            siparis_no,
            barkod,
            urun_adi,
            COALESCE(MAX(toplam_tutar),    0) AS toplam_tutar,
            COALESCE(AVG(komisyon_orani),  0) AS komisyon_orani,
            MAX(siparis_tarihi)               AS siparis_tarihi,
            MAX(islem_tipi)                   AS islem_tipi
        FROM trendyol_komisyon_faturalari
        WHERE siparis_no IS NOT NULL AND siparis_no != ''
        GROUP BY siparis_no, barkod
    """)
    rows = cursor.fetchall()
    n = 0
    for row in rows:
        siparis_no, barkod, urun_adi, toplam_tutar, kom_oran, sip_tarihi, islem_tipi = row
        durum = "iade" if islem_tipi and "iade" in str(islem_tipi).lower() else "teslim_edildi"
        _upsert_siparis(cursor, {
            "siparis_no":          siparis_no,
            "pazaryeri_siparis_no": siparis_no,
            "pazaryeri":           "Trendyol",
            "barkod":              barkod or "",
            "urun_adi":            urun_adi,
            "marka":               None,
            "kategori":            None,
            "adet":                1,
            "birim_fiyat":         toplam_tutar or 0,
            "kdv_orani":           20,
            "toplam_tutar":        toplam_tutar or 0,
            "pazaryeri_fiyati":    toplam_tutar or 0,
            "durum":               durum,
            "siparis_tarihi":      sip_tarihi or datetime.now(),
        })
        n += 1
    return n


def _sync_pazarama(cursor) -> int:
    """pazarama_komisyon_detay'dan siparisler'e upsert."""
    cursor.execute("""
        SELECT
            siparis_no,
            MAX(siparis_tutari)   AS siparis_tutari,
            MAX(siparis_tarihi)   AS siparis_tarihi,
            MAX(siparis_durumu)   AS siparis_durumu
        FROM pazarama_komisyon_detay
        WHERE siparis_no IS NOT NULL AND siparis_no != ''
        GROUP BY siparis_no
    """)
    rows = cursor.fetchall()
    n = 0
    for row in rows:
        siparis_no, tutar, sip_tarihi, durumu = row
        durum = "iade" if durumu and "iade" in str(durumu).lower() else "teslim_edildi"
        _upsert_siparis(cursor, {
            "siparis_no":           siparis_no,
            "pazaryeri_siparis_no": siparis_no,
            "pazaryeri":            "Pazarama",
            "barkod":               "",
            "urun_adi":             None,
            "marka":                None,
            "kategori":             None,
            "adet":                 1,
            "birim_fiyat":          tutar or 0,
            "kdv_orani":            20,
            "toplam_tutar":         tutar or 0,
            "pazaryeri_fiyati":     tutar or 0,
            "durum":                durum,
            "siparis_tarihi":       sip_tarihi or datetime.now(),
        })
        n += 1
    return n


def _sync_n11(cursor) -> int:
    """n11_komisyon_faturalari'ndan siparisler'e upsert."""
    cursor.execute("""
        SELECT
            siparis_no,
            MAX(siparis_tutari)              AS siparis_tutari,
            MAX(siparis_tamamlanma_tarihi)   AS siparis_tarihi,
            MAX(islem_tipi_tanimi)           AS islem_tipi
        FROM n11_komisyon_faturalari
        WHERE siparis_no IS NOT NULL AND siparis_no != ''
        GROUP BY siparis_no
    """)
    rows = cursor.fetchall()
    n = 0
    for row in rows:
        siparis_no, tutar, sip_tarihi, islem_tipi = row
        durum = "iade" if islem_tipi and "iade" in str(islem_tipi).lower() else "teslim_edildi"
        _upsert_siparis(cursor, {
            "siparis_no":           siparis_no,
            "pazaryeri_siparis_no": siparis_no,
            "pazaryeri":            "N11",
            "barkod":               "",
            "urun_adi":             None,
            "marka":                None,
            "kategori":             None,
            "adet":                 1,
            "birim_fiyat":          tutar or 0,
            "kdv_orani":            20,
            "toplam_tutar":         tutar or 0,
            "pazaryeri_fiyati":     tutar or 0,
            "durum":                durum,
            "siparis_tarihi":       sip_tarihi or datetime.now(),
        })
        n += 1
    return n


def _sync_lcw(cursor) -> int:
    """lcw_komisyon_faturalari'ndan siparisler'e upsert."""
    cursor.execute("""
        SELECT
            siparis_no,
            barkod,
            urun_adi,
            marka,
            urun_kategori,
            MAX(satis_tutari)   AS satis_tutari,
            MAX(siparis_tarihi) AS siparis_tarihi,
            MAX(islem_tipi)     AS islem_tipi
        FROM lcw_komisyon_faturalari
        WHERE siparis_no IS NOT NULL AND siparis_no != ''
        GROUP BY siparis_no, barkod
    """)
    rows = cursor.fetchall()
    n = 0
    for row in rows:
        siparis_no, barkod, urun_adi, marka, kategori, tutar, sip_tarihi, islem_tipi = row
        durum = "iade" if islem_tipi and "iade" in str(islem_tipi).lower() else "teslim_edildi"
        _upsert_siparis(cursor, {
            "siparis_no":           siparis_no,
            "pazaryeri_siparis_no": siparis_no,
            "pazaryeri":            "LCW",
            "barkod":               barkod or "",
            "urun_adi":             urun_adi,
            "marka":                marka,
            "kategori":             kategori,
            "adet":                 1,
            "birim_fiyat":          tutar or 0,
            "kdv_orani":            20,
            "toplam_tutar":         tutar or 0,
            "pazaryeri_fiyati":     tutar or 0,
            "durum":                durum,
            "siparis_tarihi":       sip_tarihi or datetime.now(),
        })
        n += 1
    return n

def _sync_flo(cursor) -> int:
    """flo_fatura_detay'dan siparisler'e upsert."""
    cursor.execute("""
        SELECT
            siparis_no,
            MAX(fatura_tarihi)  AS fatura_tarihi,
            SUM(miktar)         AS toplam_miktar,
            MAX(islem_tipi)     AS islem_tipi
        FROM flo_fatura_detay
        WHERE siparis_no IS NOT NULL AND siparis_no != ''
        GROUP BY siparis_no
    """)
    rows = cursor.fetchall()
    n = 0
    for row in rows:
        siparis_no, fatura_tarihi, toplam_miktar, islem_tipi = row
        durum = "iade" if islem_tipi and "iade" in str(islem_tipi).lower() else "teslim_edildi"
        _upsert_siparis(cursor, {
            "siparis_no":           siparis_no,
            "pazaryeri_siparis_no": siparis_no,
            "pazaryeri":            "Flo",
            "barkod":               "",
            "urun_adi":             None,
            "marka":                None,
            "kategori":             None,
            "adet":                 1,
            "birim_fiyat":          toplam_miktar or 0,
            "kdv_orani":            20,
            "toplam_tutar":         toplam_miktar or 0,
            "pazaryeri_fiyati":     toplam_miktar or 0,
            "durum":                durum,
            "siparis_tarihi":       fatura_tarihi or datetime.now(),
        })
        n += 1
    return n


def _sync_amazon(cursor) -> int:
    """amazon_islemler'den siparisler'e upsert."""
    cursor.execute("""
        SELECT
            siparis_no,
            MAX(tarih)                     AS siparis_tarihi,
            MAX(toplam_urun_fiyatlari)     AS urun_fiyati,
            MAX(toplam_try)                AS toplam_tutar,
            MAX(islem_tipi)                AS islem_tipi,
            MAX(urun_detaylari)            AS urun_adi
        FROM amazon_islemler
        WHERE siparis_no IS NOT NULL AND siparis_no != ''
        GROUP BY siparis_no
    """)
    rows = cursor.fetchall()
    n = 0
    for row in rows:
        siparis_no, sip_tarihi, urun_fiyati, toplam_tutar, islem_tipi, urun_adi = row
        durum = "iade" if islem_tipi and "iade" in str(islem_tipi).lower() else "teslim_edildi"
        _upsert_siparis(cursor, {
            "siparis_no":           siparis_no,
            "pazaryeri_siparis_no": siparis_no,
            "pazaryeri":            "Amazon",
            "barkod":               "",
            "urun_adi":             urun_adi,
            "marka":                None,
            "kategori":             None,
            "adet":                 1,
            "birim_fiyat":          urun_fiyati or toplam_tutar or 0,
            "kdv_orani":            20,
            "toplam_tutar":         toplam_tutar or 0,
            "pazaryeri_fiyati":     toplam_tutar or 0,
            "durum":                durum,
            "siparis_tarihi":       sip_tarihi or datetime.now(),
        })
        n += 1
    return n


def _sync_hepsiburada(cursor) -> int:
    """hepsiburada_hakedis'den siparisler'e upsert."""
    cursor.execute("""
        SELECT
            siparis_no,
            urun_no    AS barkod,
            urun_adi,
            MAX(liste_fiyati)   AS liste_fiyati,
            MAX(siparis_tarihi) AS siparis_tarihi,
            MAX(kayit_turu)     AS kayit_turu
        FROM hepsiburada_hakedis
        WHERE siparis_no IS NOT NULL AND siparis_no != ''
        GROUP BY siparis_no, urun_no
    """)
    rows = cursor.fetchall()
    n = 0
    for row in rows:
        siparis_no, barkod, urun_adi, tutar, sip_tarihi, kayit_turu = row
        durum = "iade" if kayit_turu and "gider" in str(kayit_turu).lower() else "teslim_edildi"
        _upsert_siparis(cursor, {
            "siparis_no":           siparis_no,
            "pazaryeri_siparis_no": siparis_no,
            "pazaryeri":            "Hepsiburada",
            "barkod":               barkod or "",
            "urun_adi":             urun_adi,
            "marka":                None,
            "kategori":             None,
            "adet":                 1,
            "birim_fiyat":          tutar or 0,
            "kdv_orani":            20,
            "toplam_tutar":         tutar or 0,
            "pazaryeri_fiyati":     tutar or 0,
            "durum":                durum,
            "siparis_tarihi":       sip_tarihi or datetime.now(),
        })
        n += 1
    return n


# ============================================================
# ADIM 2: karlilik_ozeti_hesapla
# siparisler + fatura tablolarından karlilik_ozeti'ni doldurur.
# ============================================================

def karlilik_ozeti_hesapla(pazaryeri: str = None) -> dict:
    """
    siparisler tablosundaki her siparis icin:
    - Fatura tablolarından komisyon ve kargo değerlerini çeker
    - karlilik_ozeti tablosuna yazar
    """
    from mutabakat import gerceklesen_degerler_hesapla

    conn        = get_db_connection()
    dict_cursor = conn.cursor(dictionary=True)   # siparisler okuma için
    sub_cursor  = conn.cursor()                  # fatura sorguları için (row[0] erişimi)
    ozet        = {"islem": 0, "hata": 0}

    try:
        if pazaryeri:
            dict_cursor.execute("""
                SELECT id, siparis_no, pazaryeri_siparis_no, pazaryeri,
                       barkod, urun_adi, durum, siparis_tarihi,
                       toplam_tutar, birim_fiyat, adet, kdv_orani
                FROM siparisler
                WHERE pazaryeri = %s
            """, (pazaryeri,))
        else:
            dict_cursor.execute("""
                SELECT id, siparis_no, pazaryeri_siparis_no, pazaryeri,
                       barkod, urun_adi, durum, siparis_tarihi,
                       toplam_tutar, birim_fiyat, adet, kdv_orani
                FROM siparisler
            """)

        siparisler = dict_cursor.fetchall()

        for s in siparisler:
            try:
                # Fatura tablolarından gerçekleşen değerleri çek (normal cursor ile)
                gercek = gerceklesen_degerler_hesapla(
                    sub_cursor,
                    pazaryeri_siparis_no = s["pazaryeri_siparis_no"],
                    pazaryeri            = s["pazaryeri"],
                )

                # Beklenen komisyon tabanı
                komisyon_taban = komisyon_taban_hesapla(
                    pazaryeri       = s["pazaryeri"],
                    indirimli_fiyat = Decimal(str(s["birim_fiyat"] or 0)),
                    toplam_tutar    = Decimal(str(s["toplam_tutar"] or 0)),
                )

                sub_cursor.execute("""
                    INSERT INTO karlilik_ozeti (
                        siparis_id, siparis_no, pazaryeri_siparis_no,
                        pazaryeri, barkod, urun_adi,
                        siparis_durumu, siparis_tarihi,
                        siparis_toplam_tutari, pazaryeri_fiyati,
                        faturalanan_komisyon_tutari,
                        faturalanan_desi_tutari,
                        faturalanan_desi,
                        satis_kargosu,
                        iade_kargosu,
                        mutabakat_durumu
                    )
                    VALUES (
                        %(siparis_id)s, %(siparis_no)s, %(pazaryeri_siparis_no)s,
                        %(pazaryeri)s, %(barkod)s, %(urun_adi)s,
                        %(siparis_durumu)s, %(siparis_tarihi)s,
                        %(siparis_toplam_tutari)s, %(pazaryeri_fiyati)s,
                        %(faturalanan_komisyon_tutari)s,
                        %(faturalanan_desi_tutari)s,
                        %(faturalanan_desi)s,
                        %(satis_kargosu)s,
                        %(iade_kargosu)s,
                        'beklemede'
                    )
                    ON DUPLICATE KEY UPDATE
                        faturalanan_komisyon_tutari = VALUES(faturalanan_komisyon_tutari),
                        faturalanan_desi_tutari     = VALUES(faturalanan_desi_tutari),
                        faturalanan_desi            = VALUES(faturalanan_desi),
                        satis_kargosu               = VALUES(satis_kargosu),
                        iade_kargosu                = VALUES(iade_kargosu),
                        mutabakat_durumu            = VALUES(mutabakat_durumu),
                        son_hesaplama_tarihi        = NOW()
                """, {
                    "siparis_id":                  s["id"],
                    "siparis_no":                  s["siparis_no"],
                    "pazaryeri_siparis_no":         s["pazaryeri_siparis_no"],
                    "pazaryeri":                   s["pazaryeri"],
                    "barkod":                      s["barkod"] or "",
                    "urun_adi":                    s["urun_adi"],
                    "siparis_durumu":              s["durum"],
                    "siparis_tarihi":              s["siparis_tarihi"],
                    "siparis_toplam_tutari":        s["toplam_tutar"] or 0,
                    "pazaryeri_fiyati":             s["toplam_tutar"] or 0,
                    "faturalanan_komisyon_tutari":  gercek["faturalanan_komisyon"],
                    "faturalanan_desi_tutari":      (gercek["faturalanan_satis_kargosu"]
                                                    + gercek["faturalanan_iade_kargosu"]),
                    "faturalanan_desi":             gercek["faturalanan_desi"],
                    "satis_kargosu":               gercek["faturalanan_satis_kargosu"],
                    "iade_kargosu":                gercek["faturalanan_iade_kargosu"],
                })
                ozet["islem"] += 1

            except Exception as e:
                ozet["hata"] += 1
                import traceback
                print(f"  [HATA] {s['pazaryeri_siparis_no']}: {e}")
                traceback.print_exc()

        conn.commit()

    finally:
        dict_cursor.close()
        sub_cursor.close()
        conn.close()

    print(f"\n[PIPELINE] karlilik_ozeti guncellendi: {ozet['islem']} kayit, {ozet['hata']} hata")
    return ozet



# ============================================================
# Tam Pipeline — Tek Komutla Çalıştır
# ============================================================

def tam_pipeline_calistir(pazaryeri: str = None) -> dict:
    """
    1. Pazaryeri tablolarından siparisler'i doldurur
    2. Karlilik ozetini hesaplar ve yazar
    Kullanim: tam_pipeline_calistir("Trendyol")
              tam_pipeline_calistir()  # tum pazaryerler
    """
    print(f"\n{'='*55}")
    print(f"  PIPELINE BASLIYOR — {datetime.now().strftime('%d.%m.%Y %H:%M')}")
    if pazaryeri:
        print(f"  Pazaryeri: {pazaryeri}")
    print(f"{'='*55}")

    print("\n[ADIM 1] siparisler sync ediliyor...")
    sync_ozet = siparisler_sync(pazaryeri)

    print("\n[ADIM 2] karlilik_ozeti hesaplaniyor...")
    karlilik_ozet = karlilik_ozeti_hesapla(pazaryeri)

    print(f"\n{'='*55}")
    print(f"  PIPELINE TAMAMLANDI")
    print(f"  Islem: {karlilik_ozet['islem']} | Hata: {karlilik_ozet['hata']}")
    print(f"{'='*55}\n")

    return {
        "siparisler_sync": sync_ozet,
        "karlilik_ozeti":  karlilik_ozet,
    }


if __name__ == "__main__":
    # Tum pazaryerler
    tam_pipeline_calistir()
