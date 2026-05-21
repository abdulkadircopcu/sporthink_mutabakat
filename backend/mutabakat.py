# ============================================================
# E-Ticaret Dijital Mutabakat ve Karlılık Analizi Platformu
# Mutabakat Motoru v2.0
# Sporthink E-Ticaret Departmanı
# ============================================================

import mysql.connector
from collections import defaultdict
from decimal import Decimal
from datetime import datetime
from enum import Enum

from karlilik_hesaplama import get_db_connection, siparis_desi_hesapla


# ------------------------------------------------------------
# Sabitler
# ------------------------------------------------------------

ESLESME_ESIGI = Decimal("10")  # Bu değerin altındaki farklar eşleşti sayılır

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

        # Kargo + desi: önce direkt eşleşme (index kullanır), bulamazsa takip_no formatı
        cursor.execute("""
            SELECT gonderi_iade, COALESCE(SUM(gonderi_ucreti), 0), COALESCE(MAX(desi), 0)
            FROM trendyol_kargo_faturalari
            WHERE siparis_no = %s
            GROUP BY gonderi_iade
        """, (pazaryeri_siparis_no,))
        kargo_rows = cursor.fetchall()
        if not kargo_rows:
            cursor.execute("""
                SELECT gonderi_iade, COALESCE(SUM(gonderi_ucreti), 0), COALESCE(MAX(desi), 0)
                FROM trendyol_kargo_faturalari
                WHERE siparis_no LIKE CONCAT('%%\\_', %s)
                GROUP BY gonderi_iade
            """, (pazaryeri_siparis_no,))
            kargo_rows = cursor.fetchall()
        for gonderi_iade, tutar, desi in kargo_rows:
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
        # Pazarama kargo dosyasindaki siparis_no, komisyon dosyasindan farklı olabilir.
        # Ikisi de ayni takip_no (kargo takip) paylastiginda o alan üzerinden eslestirilir.
        cursor.execute("""
            SELECT siparis_durumu, COALESCE(SUM(satici_borcu), 0), COALESCE(MAX(desi), 0)
            FROM pazarama_kargo_detay
            WHERE siparis_no = %s
               OR (takip_no IS NOT NULL AND takip_no IN (
                   SELECT takip_no FROM pazarama_komisyon_detay
                   WHERE siparis_no = %s AND takip_no IS NOT NULL
               ))
            GROUP BY siparis_durumu
        """, (pazaryeri_siparis_no, pazaryeri_siparis_no))
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

        cursor.execute("""
            SELECT kayit_tipi, COALESCE(SUM(tutar), 0)
            FROM hepsiburada_hakedis
            WHERE siparis_no = %s AND kayit_sinifi LIKE '%kargo%'
            GROUP BY kayit_tipi
        """, (pazaryeri_siparis_no,))
        for kayit_tipi, tutar in cursor.fetchall():
            if kayit_tipi and "iade" in str(kayit_tipi).lower():
                r["faturalanan_iade_kargosu"] += Decimal(str(tutar))
            else:
                r["faturalanan_satis_kargosu"] += Decimal(str(tutar))

    elif pz == "flo":
        cursor.execute("""
            SELECT islem_tipi, COALESCE(SUM(miktar), 0)
            FROM flo_fatura_detay
            WHERE siparis_no = %s
            GROUP BY islem_tipi
        """, (pazaryeri_siparis_no,))
        for islem_tipi, tutar in cursor.fetchall():
            it = str(islem_tipi).lower() if islem_tipi else ""
            if "kargo" in it and "iade" in it:
                r["faturalanan_iade_kargosu"] += Decimal(str(tutar))
            elif "kargo" in it:
                r["faturalanan_satis_kargosu"] += Decimal(str(tutar))
            elif "komisyon" in it:
                r["faturalanan_komisyon"] += Decimal(str(tutar))

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
        try:
            cursor.close()
        except Exception:
            pass
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
        try:
            cursor.close()
        except Exception:
            pass
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


# ------------------------------------------------------------
# Yeni Mutabakat Motoru — Hesaplama Tabanlı
# ------------------------------------------------------------

# Pazaryeri → (kargo desi tablosu, kullanılacak kargo firması kolonu)
_KARGO_CFG = {
    "trendyol":    ("trendyol_kargo_desi_fiyatlari",    "aras"),
    "hepsiburada": ("hepsiburada_kargo_desi_fiyatlari", "hepsijet"),
    "lcw":         ("lcw_kargo_desi_fiyatlari",         "aras_kargo"),
    "n11":         ("n11_kargo_desi_fiyatlari",         "aras_kargo"),
    "pazarama":    ("pazarama_kargo_desi_fiyatlari",    "tutar_kdvsiz"),
    "flo":         ("flo_kargo_desi_fiyatlari",         "aras"),
}


def _beklenen_komisyon_hesapla(
    cursor, pazaryeri: str, kategori: str, satis_tutari: Decimal,
    kupon: Decimal = Decimal("0"), kampanya_indirimi: Decimal = Decimal("0")
) -> Decimal:
    """komisyon_oranlari tablosundan oran çeker; bulunamazsa %10 varsayılan.
    Trendyol hariç indirim ve kupon düşüldükten sonraki tutar üzerinden hesaplanır."""
    cursor.execute("""
        SELECT komisyon_orani FROM komisyon_oranlari
        WHERE pazaryeri_kod = %s AND kategori = %s
        ORDER BY gecerlilik_tarihi DESC LIMIT 1
    """, (pazaryeri, kategori or ""))
    row = cursor.fetchone()
    oran = Decimal(str(row[0])) if row else Decimal("10")

    if pazaryeri.lower() == "trendyol":
        taban = satis_tutari
    else:
        taban = max(satis_tutari - kupon - kampanya_indirimi, Decimal("0"))

    return taban * oran / Decimal("100")


def _hamurlab_degerler_getir(
    cursor, siparis_no: str, barkod: str
) -> tuple:
    """(faturalanan_komisyon, siparis_desisi) döndürür."""
    cursor.execute("""
        SELECT COALESCE(SUM(komisyon), 0), COALESCE(MAX(siparis_desisi), 0)
        FROM hamurlab_siparisler
        WHERE siparis_no = %s AND barkod = %s
    """, (siparis_no, barkod))
    row = cursor.fetchone()
    if row:
        return Decimal(str(row[0])), Decimal(str(row[1]))
    return Decimal("0"), Decimal("0")


def _kategori_desi_getir(cursor, barkod: str, kategori: str) -> Decimal:
    """Önce barkodla, bulamazsa ana_kategori ile tahmini_desi çeker."""
    cursor.execute(
        "SELECT tahmini_desi FROM kategori_desi_listesi WHERE barkod = %s LIMIT 1",
        (barkod,)
    )
    row = cursor.fetchone()
    if row:
        return Decimal(str(row[0]))
    cursor.execute(
        "SELECT tahmini_desi FROM kategori_desi_listesi WHERE ana_kategori = %s LIMIT 1",
        (kategori or "",)
    )
    row = cursor.fetchone()
    return Decimal(str(row[0])) if row else Decimal("0")


def _kargo_fiyati_getir(cursor, pazaryeri: str, desi: Decimal) -> Decimal:
    """Pazaryerinin desi fiyat tablosundan, gerçek desiye göre kargo fiyatı çeker."""
    cfg = _KARGO_CFG.get(pazaryeri.lower())
    if not cfg:
        return Decimal("0")
    tablo, firma = cfg
    # tablo ve firma sabit dict'ten geliyor — SQL injection riski yok
    cursor.execute(
        f"SELECT COALESCE({firma}, 0) FROM {tablo} WHERE desi >= %s ORDER BY desi ASC LIMIT 1",
        (float(desi),)
    )
    row = cursor.fetchone()
    return Decimal(str(row[0])) if row else Decimal("0")


BATCH_LIMIT = 100


def toplu_mutabakat_hesapla(pazaryeri: str = None, after_id: int = 0) -> dict:
    """
    Tüm lookup tablolarını başta tek sorguda çekip Python'da hesaplar.
    700 sorgu/batch yerine ~20 sorgu/batch — ağ gecikmesi sorununu ortadan kaldırır.
    """
    conn   = get_db_connection()
    cursor = conn.cursor(buffered=True)

    try:
        # ── 1. Sipariş listesi ──
        where_parts, params = [], []
        if pazaryeri:
            where_parts.append("pazaryeri = %s"); params.append(pazaryeri)
        if after_id > 0:
            where_parts.append("id > %s"); params.append(after_id)
        where = " AND ".join(where_parts) if where_parts else "1=1"

        cursor.execute(f"""
            SELECT id, siparis_no, barkod, pazaryeri,
                   COALESCE(kategori, ''), COALESCE(satis_tutari, 0),
                   COALESCE(kupon, 0), COALESCE(kampanya_indirimi, 0),
                   COALESCE(pazaryeri_siparis_no, '')
            FROM karlilik_ozeti WHERE {where} ORDER BY id ASC LIMIT {BATCH_LIMIT}
        """, params)
        siparisler = cursor.fetchall()

        son_id = siparisler[-1][0] if siparisler else after_id
        ozet = {
            "toplam": len(siparisler), "eslesdi": 0, "fark_var": 0,
            "hata_sayisi": 0, "hatalar": [],
            "son_id": son_id, "tamamlandi": len(siparisler) < BATCH_LIMIT,
        }
        if not siparisler:
            return ozet

        # ── 2. Lookup: komisyon oranları (tüm tablo) ──
        cursor.execute("SELECT pazaryeri_kod, kategori, komisyon_orani FROM komisyon_oranlari ORDER BY gecerlilik_tarihi DESC")
        komisyon_oran_cache = {}  # (pz, kat) -> Decimal
        for pz_k, kat, oran in cursor.fetchall():
            key = (pz_k.lower(), kat or "")
            if key not in komisyon_oran_cache:
                komisyon_oran_cache[key] = Decimal(str(oran))

        # ── 3. Lookup: kategori/barkod desisi (tüm tablo) ──
        cursor.execute("SELECT barkod, ana_kategori, tahmini_desi FROM kategori_desi_listesi")
        desi_by_barkod, desi_by_kat = {}, {}
        for b, k, d in cursor.fetchall():
            if b: desi_by_barkod[b] = Decimal(str(d))
            if k and k not in desi_by_kat: desi_by_kat[k] = Decimal(str(d))

        # ── 4. Lookup: kargo desi fiyatları (tüm pazaryerleri) ──
        kargo_desi_cache = {}  # pz -> [(desi_float, fiyat_Decimal), ...]
        for pz_key, (tablo, firma) in _KARGO_CFG.items():
            cursor.execute(f"SELECT desi, COALESCE({firma}, 0) FROM {tablo} ORDER BY desi ASC")
            kargo_desi_cache[pz_key] = [(float(d), Decimal(str(f))) for d, f in cursor.fetchall()]

        # ── 5. Lookup: hamurlab siparişler (batch IN) ──
        tum_nos = list(set(r[1] for r in siparisler))
        hamurlab_cache = {}  # (siparis_no, barkod) -> (komisyon, desi)
        ph = ",".join(["%s"] * len(tum_nos))
        cursor.execute(f"""
            SELECT siparis_no, barkod,
                   COALESCE(SUM(komisyon), 0), COALESCE(MAX(siparis_desisi), 0)
            FROM hamurlab_siparisler WHERE siparis_no IN ({ph})
            GROUP BY siparis_no, barkod
        """, tum_nos)
        for sno, barkod, kom, desi in cursor.fetchall():
            hamurlab_cache[(sno, barkod)] = (Decimal(str(kom)), Decimal(str(desi)))

        # ── 6. Lookup: pazaryeri fatura verileri (batch IN, pazaryerine göre) ──
        by_pz = defaultdict(list)
        for row in siparisler:
            by_pz[row[3].lower()].append(row)

        pz_komisyon = {}                    # (pz, siparis_no) -> Decimal
        pz_kargo    = defaultdict(list)     # (pz, siparis_no) -> [(tip, tutar, desi), ...]

        def _ph(lst): return ",".join(["%s"] * len(lst))

        if "trendyol" in by_pz:
            nos = [r[8] for r in by_pz["trendyol"]]
            cursor.execute(f"SELECT siparis_no, COALESCE(SUM(trendyol_hakedis),0) FROM trendyol_komisyon_faturalari WHERE siparis_no IN ({_ph(nos)}) GROUP BY siparis_no", nos)
            for sno, v in cursor.fetchall(): pz_komisyon[("trendyol", sno)] = Decimal(str(v))
            cursor.execute(f"SELECT siparis_no, gonderi_iade, COALESCE(SUM(gonderi_ucreti),0), COALESCE(MAX(desi),0) FROM trendyol_kargo_faturalari WHERE siparis_no IN ({_ph(nos)}) GROUP BY siparis_no, gonderi_iade", nos)
            found_kargo: set = set()
            for sno, gi, t, d in cursor.fetchall():
                pz_kargo[("trendyol", sno)].append((gi, t, d))
                found_kargo.add(sno)
            # LIKE fallback: çoklu koli formatı (ör. "9876_12345678")
            for sno in [n for n in nos if n not in found_kargo]:
                cursor.execute("""
                    SELECT gonderi_iade, COALESCE(SUM(gonderi_ucreti),0), COALESCE(MAX(desi),0)
                    FROM trendyol_kargo_faturalari
                    WHERE siparis_no LIKE CONCAT('%%\\_', %s)
                    GROUP BY gonderi_iade
                """, (sno,))
                for gi, t, d in cursor.fetchall():
                    pz_kargo[("trendyol", sno)].append((gi, t, d))

        if "pazarama" in by_pz:
            nos = [r[8] for r in by_pz["pazarama"]]
            cursor.execute(f"SELECT siparis_no, COALESCE(SUM(satici_komisyon_tutari),0) FROM pazarama_komisyon_detay WHERE siparis_no IN ({_ph(nos)}) GROUP BY siparis_no", nos)
            for sno, v in cursor.fetchall(): pz_komisyon[("pazarama", sno)] = Decimal(str(v))
            cursor.execute(f"SELECT siparis_no, takip_no FROM pazarama_komisyon_detay WHERE siparis_no IN ({_ph(nos)}) AND takip_no IS NOT NULL", nos)
            takip_map = defaultdict(list); all_takip = []
            for sno, tn in cursor.fetchall(): takip_map[sno].append(tn); all_takip.append(tn)
            kargo_cond = [f"siparis_no IN ({_ph(nos)})"]; kargo_p = list(nos)
            if all_takip:
                kargo_cond.append(f"(takip_no IS NOT NULL AND takip_no IN ({_ph(all_takip)}))"); kargo_p += all_takip
            cursor.execute(f"SELECT siparis_no, takip_no, siparis_durumu, COALESCE(SUM(satici_borcu),0), COALESCE(MAX(desi),0) FROM pazarama_kargo_detay WHERE {' OR '.join(kargo_cond)} GROUP BY siparis_no, takip_no, siparis_durumu", kargo_p)
            nos_set = set(nos)
            for rsno, rtn, durum, t, d in cursor.fetchall():
                targets = set()
                if rsno in nos_set: targets.add(rsno)
                if rtn:
                    for sno, tns in takip_map.items():
                        if rtn in tns: targets.add(sno)
                for sno in targets: pz_kargo[("pazarama", sno)].append((durum, t, d))

        if "n11" in by_pz:
            nos = [r[8] for r in by_pz["n11"]]
            cursor.execute(f"SELECT siparis_no, COALESCE(SUM(komisyon_bedeli),0) FROM n11_komisyon_faturalari WHERE siparis_no IN ({_ph(nos)}) GROUP BY siparis_no", nos)
            for sno, v in cursor.fetchall(): pz_komisyon[("n11", sno)] = Decimal(str(v))

        if "lcw" in by_pz:
            nos = [r[8] for r in by_pz["lcw"]]
            cursor.execute(f"SELECT siparis_no, COALESCE(SUM(lcw_komisyon_hakedis),0) FROM lcw_komisyon_faturalari WHERE siparis_no IN ({_ph(nos)}) GROUP BY siparis_no", nos)
            for sno, v in cursor.fetchall(): pz_komisyon[("lcw", sno)] = Decimal(str(v))
            cursor.execute(f"SELECT siparis_no, islem_tipi, COALESCE(SUM(lcw_kargo_hakedis),0), COALESCE(MAX(desi),0) FROM lcw_kargo_faturalari WHERE siparis_no IN ({_ph(nos)}) GROUP BY siparis_no, islem_tipi", nos)
            for sno, tip, t, d in cursor.fetchall(): pz_kargo[("lcw", sno)].append((tip, t, d))

        if "hepsiburada" in by_pz:
            nos = [r[8] for r in by_pz["hepsiburada"]]
            cursor.execute(f"SELECT siparis_no, COALESCE(SUM(CASE WHEN kayit_turu='Gider' THEN tutar ELSE 0 END),0) FROM hepsiburada_hakedis WHERE siparis_no IN ({_ph(nos)}) AND kayit_sinifi LIKE '%komisyon%' GROUP BY siparis_no", nos)
            for sno, v in cursor.fetchall(): pz_komisyon[("hepsiburada", sno)] = Decimal(str(v))
            cursor.execute(f"SELECT siparis_no, kayit_tipi, COALESCE(SUM(tutar),0) FROM hepsiburada_hakedis WHERE siparis_no IN ({_ph(nos)}) AND kayit_sinifi LIKE '%kargo%' GROUP BY siparis_no, kayit_tipi", nos)
            for sno, tip, t in cursor.fetchall(): pz_kargo[("hepsiburada", sno)].append((tip, t, 0))

        if "flo" in by_pz:
            nos = [r[8] for r in by_pz["flo"]]
            cursor.execute(f"SELECT siparis_no, islem_tipi, COALESCE(SUM(miktar),0) FROM flo_fatura_detay WHERE siparis_no IN ({_ph(nos)}) GROUP BY siparis_no, islem_tipi", nos)
            for sno, tip, t in cursor.fetchall(): pz_kargo[("flo", sno)].append((tip, t, 0))

        # ── 7. Hesaplama döngüsü — DB sorgusu YOK ──
        karlilik_rows  = []
        mutabakat_rows = []

        for siparis_id, siparis_no, barkod, pz, kategori, satis_tutari, kupon, kampanya_indirimi, pz_siparis_no in siparisler:
            try:
                satis_tutari      = Decimal(str(satis_tutari))
                kupon             = Decimal(str(kupon))
                kampanya_indirimi = Decimal(str(kampanya_indirimi))
                pz_lower = pz.lower()

                # Beklenen komisyon (cache)
                oran = komisyon_oran_cache.get((pz_lower, kategori or ""), Decimal("10"))
                taban = satis_tutari if pz_lower == "trendyol" else max(satis_tutari - kupon - kampanya_indirimi, Decimal("0"))
                beklenen_komisyon = taban * oran / Decimal("100")

                # Faturalanan komisyon (hamurlab)
                faturalanan_komisyon, _ = hamurlab_cache.get((siparis_no, barkod), (Decimal("0"), Decimal("0")))

                # Gerçekleşen kargo/desi (cache)
                faturalanan_satis_kargosu = Decimal("0")
                faturalanan_iade_kargosu  = Decimal("0")
                faturalanan_desi          = 0
                gerceklesen_komisyon_pz   = pz_komisyon.get((pz_lower, pz_siparis_no), Decimal("0"))

                for tip, tutar_raw, desi_raw in pz_kargo.get((pz_lower, pz_siparis_no), []):
                    tutar    = Decimal(str(tutar_raw))
                    tip_str  = str(tip).lower() if tip else ""
                    desi_int = int(desi_raw or 0)

                    if pz_lower == "flo":
                        if "kargo" in tip_str and "iade" in tip_str: faturalanan_iade_kargosu += tutar
                        elif "kargo" in tip_str:                      faturalanan_satis_kargosu += tutar
                        elif "komisyon" in tip_str:                   gerceklesen_komisyon_pz += tutar
                    else:
                        if "iade" in tip_str: faturalanan_iade_kargosu += tutar
                        else:                  faturalanan_satis_kargosu += tutar

                    faturalanan_desi = max(faturalanan_desi, desi_int)

                # Tahmini desi ve beklenen kargo (cache)
                hesaplanan_desi = desi_by_barkod.get(barkod, desi_by_kat.get(kategori or "", Decimal("0")))
                beklenen_kargo  = Decimal("0")
                for kd, kf in kargo_desi_cache.get(pz_lower, []):
                    if kd >= float(hesaplanan_desi): beklenen_kargo = kf; break

                # Farklar
                kargo_farki       = beklenen_kargo - faturalanan_satis_kargosu
                komisyon_farki    = beklenen_komisyon - faturalanan_komisyon
                beklenen_odeme    = beklenen_komisyon + beklenen_kargo
                gerceklesen_odeme = faturalanan_komisyon + faturalanan_satis_kargosu
                odeme_farki       = beklenen_odeme - gerceklesen_odeme

                fark_var = abs(odeme_farki) >= ESLESME_ESIGI
                durum    = ReconciliationStatus.ESLESDI if not fark_var else ReconciliationStatus.FARK_VAR

                karlilik_rows.append((
                    float(faturalanan_desi), float(hesaplanan_desi),
                    float(beklenen_komisyon), float(faturalanan_komisyon),
                    float(faturalanan_satis_kargosu),
                    durum.value, siparis_id,
                ))
                mutabakat_rows.append((
                    siparis_id, pz,
                    float(beklenen_odeme), float(gerceklesen_odeme), float(odeme_farki),
                    float(beklenen_komisyon), float(faturalanan_komisyon), float(komisyon_farki),
                    float(beklenen_kargo), float(faturalanan_satis_kargosu), float(kargo_farki),
                    durum.value, 1 if fark_var else 0, datetime.now(),
                ))

                if durum == ReconciliationStatus.ESLESDI: ozet["eslesdi"] += 1
                else:                                      ozet["fark_var"] += 1

            except Exception as e:
                ozet["hata_sayisi"] += 1
                if len(ozet["hatalar"]) < 5:
                    ozet["hatalar"].append(f"{siparis_no}: {e}")

        # ── 8. Toplu yazma (2 sorgu) ──
        if karlilik_rows:
            # CASE WHEN ile tek UPDATE sorgusunda tüm satırlar
            # Her sütun için parametre listesi ayrı tutulur, sonra birleştirilir
            when_clause = "WHEN %s THEN %s"
            w_fd, w_td, w_hk, w_fk, w_sk, w_dur = [], [], [], [], [], []
            p_fd, p_td, p_hk, p_fk, p_sk, p_dur = [], [], [], [], [], []
            ids = []
            for fd, td, hk, fk, sk, dur, sid in karlilik_rows:
                w_fd.append(when_clause);  p_fd  += [sid, fd]
                w_td.append(when_clause);  p_td  += [sid, td]
                w_hk.append(when_clause);  p_hk  += [sid, hk]
                w_fk.append(when_clause);  p_fk  += [sid, fk]
                w_sk.append(when_clause);  p_sk  += [sid, sk]
                w_dur.append(when_clause); p_dur += [sid, dur]
                ids.append(sid)
            p_flat = p_fd + p_td + p_hk + p_fk + p_sk + p_dur + ids
            cursor.execute(f"""
                UPDATE karlilik_ozeti SET
                    faturalanan_desi            = CASE id {" ".join(w_fd)}  END,
                    tahmini_desi                = CASE id {" ".join(w_td)}  END,
                    hesaplanan_komisyon_tutari  = CASE id {" ".join(w_hk)}  END,
                    faturalanan_komisyon_tutari = CASE id {" ".join(w_fk)}  END,
                    satis_kargosu               = CASE id {" ".join(w_sk)}  END,
                    mutabakat_durumu            = CASE id {" ".join(w_dur)} END
                WHERE id IN ({",".join(["%s"]*len(ids))})
            """, p_flat)

        if mutabakat_rows:
            cursor.executemany("""
                INSERT INTO mutabakat (
                    siparis_id, pazaryeri,
                    beklenen_odeme, gerceklesen_odeme, odeme_farki,
                    beklenen_komisyon, faturalanan_komisyon, komisyon_farki,
                    beklenen_kargo, faturalanan_satis_kargosu, kargo_farki,
                    mutabakat_durumu, fark_var_mi, mutabakat_tarihi
                ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                ON DUPLICATE KEY UPDATE
                    beklenen_odeme            = VALUES(beklenen_odeme),
                    gerceklesen_odeme         = VALUES(gerceklesen_odeme),
                    odeme_farki               = VALUES(odeme_farki),
                    beklenen_komisyon         = VALUES(beklenen_komisyon),
                    faturalanan_komisyon      = VALUES(faturalanan_komisyon),
                    komisyon_farki            = VALUES(komisyon_farki),
                    beklenen_kargo            = VALUES(beklenen_kargo),
                    faturalanan_satis_kargosu = VALUES(faturalanan_satis_kargosu),
                    kargo_farki               = VALUES(kargo_farki),
                    mutabakat_durumu          = VALUES(mutabakat_durumu),
                    fark_var_mi               = VALUES(fark_var_mi),
                    mutabakat_tarihi          = VALUES(mutabakat_tarihi)
            """, mutabakat_rows)

        conn.commit()
        return ozet

    except Exception as e:
        conn.rollback()
        raise e
    finally:
        try:
            cursor.close()
        except Exception:
            pass
        conn.close()


if __name__ == "__main__":
    sonuc = siparis_mutabakat_yap("9640323216", "Trendyol")
    print(sonuc)
