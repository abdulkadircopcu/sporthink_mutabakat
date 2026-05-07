# ============================================================
# E-Ticaret Dijital Mutabakat ve Karlılık Analizi Platformu
# Mutabakat Motoru v2.0
# Sporthink E-Ticaret Departmanı
# ============================================================

import mysql.connector
from decimal import Decimal
from datetime import datetime
from enum import Enum

from karlilik_hesaplama import get_db_connection, siparis_desi_hesapla


# ------------------------------------------------------------
# Sabitler
# ------------------------------------------------------------

class ReconciliationStatus(str, Enum):
    ESLESDI         = "eslesdi"
    FARK_VAR        = "fark_var"
    MANUEL_INCELEME = "manuel_inceleme"
    BEKLEMEDE       = "beklemede"

class AlertLevel(str, Enum):
    NORMAL = "normal"
    DUSUK  = "dusuk"
    KRITIK = "kritik"


def hesapla_fark(beklenen: Decimal, gerceklesen: Decimal) -> Decimal:
    # Pozitif → fazla geldik (iyi), Negatif → eksik geldik (kötü)
    return gerceklesen - beklenen

def belirle_alert_seviyesi(fark: Decimal) -> AlertLevel:
    if fark == Decimal("0"):
        return AlertLevel.NORMAL
    elif fark > Decimal("0"):
        return AlertLevel.DUSUK
    return AlertLevel.KRITIK

def belirle_reconciliation_status(fark: Decimal, eslesme_bulundu: bool) -> ReconciliationStatus:
    if not eslesme_bulundu:
        return ReconciliationStatus.MANUEL_INCELEME
    elif fark == Decimal("0"):
        return ReconciliationStatus.ESLESDI
    return ReconciliationStatus.FARK_VAR


# ------------------------------------------------------------
# Desi Mutabakatı
#
# Kural: Hesaplanan sepet desisi (SUM adet×tahmini_desi)
#        ile pazaryerinin faturasındaki desi karşılaştırılır.
# ------------------------------------------------------------

def desi_mutabakat(cursor, siparis_id: int, faturalanan_desi: int) -> dict:
    hesaplanan_desi = siparis_desi_hesapla(cursor, siparis_id)
    fark = faturalanan_desi - hesaplanan_desi
    return {
        "hesaplanan_desi":  hesaplanan_desi,
        "faturalanan_desi": faturalanan_desi,
        "desi_farki":       fark,
        "desi_eslesdi":     fark == 0,
        "uyari": f"[DESI_FARK] Fark: {fark:+d} desi" if fark != 0 else "[OK] Desi eslesti",
    }


# ------------------------------------------------------------
# Sipariş Eşleştirme
# Not: Barkod (Hitit) eşleştirmesi ileride eklenecek.
# ------------------------------------------------------------

def siparis_eslestir(cursor, pazaryeri_siparis_no: str, pazaryeri: str) -> dict | None:
    cursor.execute("""
        SELECT id, siparis_no, pazaryeri, toplam_tutar, durum, barkod
        FROM siparisler
        WHERE pazaryeri_siparis_no = %s AND pazaryeri = %s
        LIMIT 1
    """, (pazaryeri_siparis_no, pazaryeri))
    row = cursor.fetchone()
    if row:
        return {
            "id":               row[0],
            "siparis_no":       row[1],
            "pazaryeri":        row[2],
            "toplam_tutar":     Decimal(str(row[3])),
            "durum":            row[4],
            "barkod":           row[5],
            "eslesme_yontemi":  "siparis_no",
        }
    return None


# ------------------------------------------------------------
# Gerçekleşen Değerleri Pazaryeri Faturalarından Çek
# ------------------------------------------------------------

def gerceklesen_degerler_hesapla(
    cursor, pazaryeri_siparis_no: str, pazaryeri: str
) -> dict:
    """
    Pazaryerinin Excel'den import edilmiş fatura tablolarından
    komisyon, satış kargosu, iade kargosu ve desiyi toplar.
    """
    r = {
        "faturalanan_komisyon":      Decimal("0"),
        "faturalanan_satis_kargosu": Decimal("0"),
        "faturalanan_iade_kargosu":  Decimal("0"),
        "faturalanan_desi":          0,
    }
    pz = pazaryeri.lower()

    if pz == "trendyol":
        # Komisyon
        cursor.execute("""
            SELECT COALESCE(SUM(trendyol_hakedis), 0)
            FROM trendyol_komisyon_faturalari
            WHERE siparis_no = %s
        """, (pazaryeri_siparis_no,))
        row = cursor.fetchone()
        r["faturalanan_komisyon"] = Decimal(str(row[0]))

        # Kargo + desi
        cursor.execute("""
            SELECT gonderi_iade, COALESCE(SUM(gonderi_ucreti), 0), COALESCE(MAX(desi), 0)
            FROM trendyol_kargo_faturalari
            WHERE siparis_no = %s
            GROUP BY gonderi_iade
        """, (pazaryeri_siparis_no,))
        for gonderi_iade, tutar, desi in cursor.fetchall():
            if gonderi_iade and "iade" in str(gonderi_iade).lower():
                r["faturalanan_iade_kargosu"] += Decimal(str(tutar))
            else:
                r["faturalanan_satis_kargosu"] += Decimal(str(tutar))
            r["faturalanan_desi"] = max(r["faturalanan_desi"], int(desi or 0))

    elif pz == "pazarama":
        # Komisyon
        cursor.execute("""
            SELECT COALESCE(SUM(satici_komisyon_tutari), 0)
            FROM pazarama_komisyon_detay
            WHERE siparis_no = %s
        """, (pazaryeri_siparis_no,))
        row = cursor.fetchone()
        r["faturalanan_komisyon"] = Decimal(str(row[0]))

        # Kargo + desi
        cursor.execute("""
            SELECT siparis_durumu, COALESCE(SUM(satici_borcu), 0), COALESCE(MAX(desi), 0)
            FROM pazarama_kargo_detay
            WHERE siparis_no = %s
            GROUP BY siparis_durumu
        """, (pazaryeri_siparis_no,))
        for durum, tutar, desi in cursor.fetchall():
            if durum and "iade" in str(durum).lower():
                r["faturalanan_iade_kargosu"] += Decimal(str(tutar))
            else:
                r["faturalanan_satis_kargosu"] += Decimal(str(tutar))
            r["faturalanan_desi"] = max(r["faturalanan_desi"], int(desi or 0))

    elif pz == "n11":
        cursor.execute("""
            SELECT COALESCE(SUM(komisyon_bedeli), 0)
            FROM n11_komisyon_faturalari
            WHERE siparis_no = %s
        """, (pazaryeri_siparis_no,))
        row = cursor.fetchone()
        r["faturalanan_komisyon"] = Decimal(str(row[0]))

    elif pz == "lcw":
        cursor.execute("""
            SELECT COALESCE(SUM(lcw_komisyon_hakedis), 0)
            FROM lcw_komisyon_faturalari
            WHERE siparis_no = %s
        """, (pazaryeri_siparis_no,))
        row = cursor.fetchone()
        r["faturalanan_komisyon"] = Decimal(str(row[0]))

        cursor.execute("""
            SELECT islem_tipi, COALESCE(SUM(lcw_kargo_hakedis), 0), COALESCE(MAX(desi), 0)
            FROM lcw_kargo_faturalari
            WHERE siparis_no = %s
            GROUP BY islem_tipi
        """, (pazaryeri_siparis_no,))
        for islem_tipi, tutar, desi in cursor.fetchall():
            if islem_tipi and "iade" in str(islem_tipi).lower():
                r["faturalanan_iade_kargosu"] += Decimal(str(tutar))
            else:
                r["faturalanan_satis_kargosu"] += Decimal(str(tutar))
            r["faturalanan_desi"] = max(r["faturalanan_desi"], int(desi or 0))

    elif pz == "hepsiburada":
        cursor.execute("""
            SELECT COALESCE(SUM(CASE WHEN kayit_turu = 'Gider' THEN tutar ELSE 0 END), 0)
            FROM hepsiburada_hakedis
            WHERE siparis_no = %s AND kayit_sinifi LIKE '%komisyon%'
        """, (pazaryeri_siparis_no,))
        row = cursor.fetchone()
        r["faturalanan_komisyon"] = Decimal(str(row[0]))

    return r


# ------------------------------------------------------------
# Mutabakat Kaydını Kaydet
# ------------------------------------------------------------

def mutabakat_kaydet(
    cursor,
    siparis_id: int,
    pazaryeri: str,
    beklenen_komisyon: Decimal,
    gerceklesen: dict,
    desi_sonuc: dict,
    durum: ReconciliationStatus,
) -> None:
    komisyon_farki = hesapla_fark(beklenen_komisyon, gerceklesen["faturalanan_komisyon"])
    fark_var = komisyon_farki != Decimal("0") or not desi_sonuc["desi_eslesdi"]

    cursor.execute("""
        INSERT INTO mutabakat (
            siparis_id, pazaryeri,
            beklenen_komisyon, faturalanan_komisyon, komisyon_farki,
            faturalanan_satis_kargosu, faturalanan_iade_kargosu,
            mutabakat_durumu, fark_var_mi, mutabakat_tarihi
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            beklenen_komisyon        = VALUES(beklenen_komisyon),
            faturalanan_komisyon     = VALUES(faturalanan_komisyon),
            komisyon_farki           = VALUES(komisyon_farki),
            faturalanan_satis_kargosu= VALUES(faturalanan_satis_kargosu),
            faturalanan_iade_kargosu = VALUES(faturalanan_iade_kargosu),
            mutabakat_durumu         = VALUES(mutabakat_durumu),
            fark_var_mi              = VALUES(fark_var_mi),
            mutabakat_tarihi         = VALUES(mutabakat_tarihi)
    """, (
        siparis_id, pazaryeri,
        beklenen_komisyon,
        gerceklesen["faturalanan_komisyon"],
        komisyon_farki,
        gerceklesen["faturalanan_satis_kargosu"],
        gerceklesen["faturalanan_iade_kargosu"],
        durum.value,
        1 if fark_var else 0,
        datetime.now(),
    ))


# ------------------------------------------------------------
# Ana Fonksiyon — Tek Sipariş Mutabakatı
# ------------------------------------------------------------

def siparis_mutabakat_yap(pazaryeri_siparis_no: str, pazaryeri: str) -> dict:
    conn   = get_db_connection()
    cursor = conn.cursor()

    try:
        siparis = siparis_eslestir(cursor, pazaryeri_siparis_no, pazaryeri)

        if not siparis:
            return {
                "durum":   ReconciliationStatus.MANUEL_INCELEME.value,
                "alert":   AlertLevel.KRITIK.value,
                "mesaj":   f"[KRITIK] Siparis bulunamadi: {pazaryeri_siparis_no}",
            }

        siparis_id = siparis["id"]

        # Gerçekleşen değerleri faturalardan çek
        gerceklesen = gerceklesen_degerler_hesapla(cursor, pazaryeri_siparis_no, pazaryeri)

        # Desi mutabakatı
        desi_sonuc = desi_mutabakat(cursor, siparis_id, gerceklesen["faturalanan_desi"])

        # Komisyon farkı (beklenen = 0 placeholder, ileride karlilik_hesaplama ile bağlanacak)
        beklenen_komisyon = Decimal("0")
        komisyon_farki    = hesapla_fark(beklenen_komisyon, gerceklesen["faturalanan_komisyon"])
        durum  = belirle_reconciliation_status(komisyon_farki, eslesme_bulundu=True)
        alert  = belirle_alert_seviyesi(komisyon_farki)

        mutabakat_kaydet(cursor, siparis_id, pazaryeri,
                         beklenen_komisyon=beklenen_komisyon,
                         gerceklesen=gerceklesen,
                         desi_sonuc=desi_sonuc,
                         durum=durum)
        conn.commit()

        return {
            "siparis_id":           siparis_id,
            "pazaryeri_siparis_no": pazaryeri_siparis_no,
            "durum":                durum.value,
            "alert":                alert.value,
            "komisyon_farki":       float(komisyon_farki),
            "desi":                 desi_sonuc,
            "mesaj": (
                f"[OK] Mutabakat tamam: {pazaryeri_siparis_no}"
                if alert == AlertLevel.NORMAL else
                f"[{alert.value.upper()}] Komisyon farki: {komisyon_farki:+.2f} TL — {pazaryeri_siparis_no}"
            ),
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

def toplu_mutabakat_yap(pazaryeri: str = None) -> dict:
    conn   = get_db_connection()
    cursor = conn.cursor()

    try:
        if pazaryeri:
            cursor.execute("""
                SELECT s.pazaryeri_siparis_no, s.pazaryeri
                FROM siparisler s
                LEFT JOIN mutabakat m ON s.id = m.siparis_id
                WHERE (m.mutabakat_durumu = 'beklemede' OR m.siparis_id IS NULL)
                  AND s.pazaryeri = %s
            """, (pazaryeri,))
        else:
            cursor.execute("""
                SELECT s.pazaryeri_siparis_no, s.pazaryeri
                FROM siparisler s
                LEFT JOIN mutabakat m ON s.id = m.siparis_id
                WHERE m.mutabakat_durumu = 'beklemede' OR m.siparis_id IS NULL
            """)
        siparisler = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    ozet = {
        "toplam":          len(siparisler),
        "eslesdi":         0,
        "fark_var":        0,
        "manuel_inceleme": 0,
        "kritik_uyarilar": [],
        "dusuk_uyarilar":  [],
    }

    for pazar_siparis_no, pz in siparisler:
        sonuc = siparis_mutabakat_yap(pazar_siparis_no, pz)
        if sonuc["durum"] == ReconciliationStatus.ESLESDI.value:
            ozet["eslesdi"] += 1
        elif sonuc["durum"] == ReconciliationStatus.FARK_VAR.value:
            ozet["fark_var"] += 1
            if sonuc["alert"] == AlertLevel.KRITIK.value:
                ozet["kritik_uyarilar"].append(sonuc)
            else:
                ozet["dusuk_uyarilar"].append(sonuc)
        else:
            ozet["manuel_inceleme"] += 1
            ozet["kritik_uyarilar"].append(sonuc)

    print("\n" + "="*60)
    print(f"  MUTABAKAT RAPORU — {datetime.now().strftime('%d.%m.%Y %H:%M')}")
    print("="*60)
    print(f"  Toplam          : {ozet['toplam']}")
    print(f"  [OK]    Eslesti         : {ozet['eslesdi']}")
    print(f"  [FARK]  Fark var        : {ozet['fark_var']}")
    print(f"  [MNUL]  Manuel inceleme : {ozet['manuel_inceleme']}")
    print(f"  [KRTK]  Kritik uyari    : {len(ozet['kritik_uyarilar'])}")
    print("="*60 + "\n")

    return ozet


if __name__ == "__main__":
    sonuc = siparis_mutabakat_yap("9640323216", "Trendyol")
    print(sonuc)
