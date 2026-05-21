import json
import sys
import os
from datetime import datetime
from flask import Blueprint, request, jsonify
import mysql.connector

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

analiz_bp = Blueprint("analiz", __name__)

def get_conn():
    cfg = {
        "host":     os.environ.get("DB_HOST", "localhost"),
        "port":     int(os.environ.get("DB_PORT", 3306)),
        "user":     os.environ.get("DB_USER", "root"),
        "password": os.environ.get("DB_PASSWORD", ""),
        "database": os.environ.get("DB_NAME", "sporthink_mutabakat"),
        "charset":  "utf8mb4",
    }
    if os.environ.get("DB_SSL_CA"):
        cfg["ssl_ca"] = os.environ["DB_SSL_CA"]
    else:
        cfg["ssl_disabled"] = True
    return mysql.connector.connect(**cfg)


# ── Karlılık Özeti Kartları ──
@analiz_bp.route("/karlilik/ozet", methods=["GET"])
def karlilik_ozet():
    pazaryeri  = request.args.get("pazaryeri")
    bas_tarih  = request.args.get("bas_tarih")
    bit_tarih  = request.args.get("bit_tarih")

    where  = ["1=1"]
    params = []
    if pazaryeri:
        where.append("pazaryeri = %s"); params.append(pazaryeri)
    if bas_tarih:
        where.append("DATE(siparis_tarihi) >= %s"); params.append(bas_tarih)
    if bit_tarih:
        where.append("DATE(siparis_tarihi) <= %s"); params.append(bit_tarih)

    sql = f"""
        SELECT
            COUNT(*)                                                        AS toplam_siparis,
            COALESCE(SUM(satis_tutari), 0)                                  AS toplam_ciro,
            COALESCE(SUM(urun_maliyeti), 0)                                 AS toplam_maliyet,
            COALESCE(SUM(net_kar), 0)                                       AS toplam_kar,
            COALESCE(AVG(kar_marji), 0)                                     AS ort_kar_marji,
            COALESCE(SUM(faturalanan_komisyon_tutari), 0)                   AS toplam_komisyon,
            COALESCE(SUM(satis_kargosu), 0)                                 AS toplam_kargo,
            COALESCE(AVG(satis_tutari), 0)                                  AS ort_siparis_tutari,
            SUM(CASE WHEN zarar_mi=1 THEN 1 ELSE 0 END)                    AS zarar_siparis,
            SUM(CASE WHEN net_kar>0 AND urun_maliyeti IS NOT NULL
                          AND urun_maliyeti!=0 THEN 1 ELSE 0 END)           AS karli_siparis
        FROM karlilik_ozeti
        WHERE {" AND ".join(where)}
    """
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute(sql, params)
    row = cur.fetchone()
    cur.close(); conn.close()

    for k, v in row.items():
        if v is not None:
            try: row[k] = float(v)
            except: pass
    return jsonify(row)


# ── Karlılık Listesi ──
@analiz_bp.route("/karlilik/liste", methods=["GET"])
def karlilik_liste():
    pazaryeri = request.args.get("pazaryeri")
    durum     = request.args.get("durum")
    bas_tarih = request.args.get("bas_tarih")
    bit_tarih = request.args.get("bit_tarih")
    sayfa     = int(request.args.get("sayfa", 1))
    limit     = int(request.args.get("limit", 20))
    offset    = (sayfa - 1) * limit

    where  = ["1=1"]
    params = []
    if pazaryeri:
        where.append("pazaryeri = %s"); params.append(pazaryeri)
    if durum == "zarar":
        where.append("zarar_mi = 1")
    elif durum == "karli":
        where.append("zarar_mi = 0 AND net_kar > 0")
    if bas_tarih:
        where.append("DATE(siparis_tarihi) >= %s"); params.append(bas_tarih)
    if bit_tarih:
        where.append("DATE(siparis_tarihi) <= %s"); params.append(bit_tarih)

    w = " AND ".join(where)

    count_sql = f"SELECT COUNT(*) FROM karlilik_ozeti WHERE {w}"
    data_sql  = f"""
        SELECT
            siparis_no, pazaryeri_siparis_no, pazaryeri, siparis_durumu,
            DATE_FORMAT(siparis_tarihi, '%d.%m.%Y') AS siparis_tarihi,
            barkod, urun_adi, satis_adeti,
            COALESCE(satis_tutari,0)                AS satis_tutari,
            COALESCE(urun_maliyeti,0)               AS urun_maliyeti,
            COALESCE(faturalanan_komisyon_tutari,0) AS komisyon,
            COALESCE(satis_kargosu,0)               AS kargo,
            COALESCE(net_gelir,0)                   AS net_gelir,
            COALESCE(net_kar,0)                     AS net_kar,
            COALESCE(kar_marji,0)                   AS kar_marji,
            zarar_mi, mutabakat_durumu
        FROM karlilik_ozeti
        WHERE {w}
        ORDER BY id DESC
        LIMIT %s OFFSET %s
    """
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)

    cur.execute(count_sql, params)
    toplam = cur.fetchone()["COUNT(*)"]

    cur.execute(data_sql, params + [limit, offset])
    rows = cur.fetchall()
    cur.close(); conn.close()

    # Decimal → float
    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v)
                except: pass

    return jsonify({
        "toplam": toplam,
        "sayfa": sayfa,
        "limit": limit,
        "veriler": rows
    })


# ── Pazaryeri Karşılaştırma ──
@analiz_bp.route("/karlilik/pazaryeri-karsilastirma", methods=["GET"])
def pazaryeri_karsilastirma():
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute("""
        SELECT
            pazaryeri,
            COUNT(*)                                          AS siparis_sayisi,
            COALESCE(SUM(satis_tutari), 0)                   AS toplam_ciro,
            COALESCE(SUM(net_kar), 0)                        AS toplam_kar,
            COALESCE(AVG(kar_marji), 0)                      AS ort_kar_marji,
            SUM(CASE WHEN zarar_mi = 1 THEN 1 ELSE 0 END)   AS zarar_sayisi,
            SUM(CASE WHEN net_kar >= 0 AND urun_maliyeti IS NOT NULL
                          AND urun_maliyeti != 0 THEN 1 ELSE 0 END) AS karli_sayisi,
            COALESCE(SUM(faturalanan_komisyon_tutari), 0)    AS toplam_komisyon,
            COALESCE(SUM(satis_kargosu), 0)                  AS toplam_kargo,
            COALESCE(SUM(urun_maliyeti), 0)                  AS toplam_maliyet,
            COALESCE(AVG(satis_tutari), 0)                   AS ort_siparis_tutari
        FROM karlilik_ozeti
        GROUP BY pazaryeri
        ORDER BY toplam_ciro DESC
    """)
    rows = cur.fetchall()
    cur.close(); conn.close()

    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v)
                except: pass

    return jsonify(rows)


# ── Mutabakat Hesapla (Toplu) ──
@analiz_bp.route("/mutabakat/hesapla", methods=["POST"])
def mutabakat_hesapla():
    try:
        import mutabakat as mut_module
        pazaryeri = None
        after_id  = 0
        if request.is_json and request.json:
            pazaryeri = request.json.get("pazaryeri")
            after_id  = int(request.json.get("after_id", 0))
        ozet = mut_module.toplu_mutabakat_hesapla(pazaryeri, after_id=after_id)
        return jsonify({"basarili": True, "ozet": ozet})
    except BaseException as e:
        import traceback
        return jsonify({"basarili": False, "hata": str(e), "detay": traceback.format_exc()}), 500


# ── Mutabakat Özeti ──
@analiz_bp.route("/mutabakat/ozet", methods=["GET"])
def mutabakat_ozet():
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute("""
        SELECT
            mutabakat_durumu,
            pazaryeri,
            COUNT(*) AS adet,
            COALESCE(SUM(odeme_farki), 0) AS toplam_fark
        FROM mutabakat
        GROUP BY mutabakat_durumu, pazaryeri
        ORDER BY pazaryeri, mutabakat_durumu
    """)
    rows = cur.fetchall()
    cur.close(); conn.close()
    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v)
                except: pass
    return jsonify(rows)


# ── Mutabakat Tam Liste ──
@analiz_bp.route("/mutabakat/liste", methods=["GET"])
def mutabakat_liste():
    pazaryeri = request.args.get("pazaryeri")
    durum     = request.args.get("durum")
    sayfa     = int(request.args.get("sayfa", 1))
    limit     = int(request.args.get("limit", 50))
    offset    = (sayfa - 1) * limit

    where  = ["1=1"]
    params = []
    if pazaryeri:
        where.append("m.pazaryeri = %s"); params.append(pazaryeri)
    if durum:
        where.append("m.mutabakat_durumu = %s"); params.append(durum)

    w = " AND ".join(where)

    count_sql = f"SELECT COUNT(*) FROM mutabakat m WHERE {w}"
    data_sql  = f"""
        SELECT
            m.id,
            m.siparis_id,
            m.pazaryeri,
            m.mutabakat_durumu,
            m.fark_var_mi,
            m.mukrerrer_mi,
            COALESCE(m.beklenen_odeme,          0) AS beklenen_odeme,
            COALESCE(m.beklenen_komisyon,        0) AS beklenen_komisyon,
            COALESCE(m.beklenen_kargo,           0) AS beklenen_kargo,
            COALESCE(m.gerceklesen_odeme,        0) AS gerceklesen_odeme,
            COALESCE(m.faturalanan_komisyon,     0) AS faturalanan_komisyon,
            COALESCE(m.faturalanan_satis_kargosu,0) AS faturalanan_satis_kargosu,
            COALESCE(m.faturalanan_iade_kargosu, 0) AS faturalanan_iade_kargosu,
            COALESCE(m.odeme_farki,              0) AS odeme_farki,
            COALESCE(m.komisyon_farki,           0) AS komisyon_farki,
            COALESCE(m.kargo_farki,              0) AS kargo_farki,
            m.guven_skoru,
            m.notlar,
            DATE_FORMAT(m.mutabakat_tarihi, '%d.%m.%Y') AS mutabakat_tarihi,
            -- Sipariş bilgileri (karlilik_ozeti'nden)
            k.siparis_no,
            k.pazaryeri_siparis_no,
            k.barkod,
            k.urun_adi,
            k.siparis_durumu,
            DATE_FORMAT(k.siparis_tarihi, '%d.%m.%Y') AS siparis_tarihi
        FROM mutabakat m
        LEFT JOIN karlilik_ozeti k ON k.id = m.siparis_id
        WHERE {w}
        ORDER BY m.id DESC
        LIMIT %s OFFSET %s
    """

    conn = get_conn()
    cur  = conn.cursor(dictionary=True)

    cur.execute(count_sql, params)
    toplam = cur.fetchone()["COUNT(*)"]

    cur.execute(data_sql, params + [limit, offset])
    rows = cur.fetchall()
    cur.close(); conn.close()

    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v)
                except: pass

    return jsonify({
        "toplam": toplam,
        "sayfa":  sayfa,
        "limit":  limit,
        "veriler": rows
    })


# ── Kargo Desi Mutabakatı — Özet (sipariş bazlı) ──
@analiz_bp.route("/kargo-desi/ozet", methods=["GET"])
def kargo_desi_ozet():
    pazaryeri = request.args.get("pazaryeri")

    inner_where  = ["faturalanan_desi IS NOT NULL", "tahmini_desi IS NOT NULL"]
    params = []
    if pazaryeri:
        inner_where.append("pazaryeri = %s"); params.append(pazaryeri)

    iw = " AND ".join(inner_where)
    # Önce sipariş bazlı toplam desi hesapla, sonra aggregate et
    sql = f"""
        SELECT
            COUNT(*)                                              AS toplam,
            SUM(CASE WHEN desi_farki = 0  THEN 1 ELSE 0 END)    AS eslesen,
            SUM(CASE WHEN desi_farki > 0  THEN 1 ELSE 0 END)    AS aleyhimize,
            SUM(CASE WHEN desi_farki < 0  THEN 1 ELSE 0 END)    AS lehimize,
            COALESCE(SUM(desi_farki), 0)                         AS toplam_desi_farki,
            COALESCE(AVG(faturalanan_desi), 0)                   AS ort_faturalanan_desi,
            COALESCE(AVG(toplam_tahmini), 0)                     AS ort_tahmini_desi
        FROM (
            SELECT
                siparis_no,
                pazaryeri,
                MAX(faturalanan_desi)          AS faturalanan_desi,
                SUM(tahmini_desi)              AS toplam_tahmini,
                MAX(faturalanan_desi) - SUM(tahmini_desi) AS desi_farki
            FROM karlilik_ozeti
            WHERE {iw}
            GROUP BY siparis_no, pazaryeri
        ) siparis_ozet
    """
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute(sql, params)
    row = cur.fetchone()
    cur.close(); conn.close()

    for k, v in row.items():
        if v is not None:
            try: row[k] = float(v)
            except: pass
    return jsonify(row)


# ── Kargo Desi Mutabakatı — Liste (sipariş bazlı) ──
@analiz_bp.route("/kargo-desi/liste", methods=["GET"])
def kargo_desi_liste():
    pazaryeri = request.args.get("pazaryeri")
    durum     = request.args.get("durum")
    sayfa     = int(request.args.get("sayfa", 1))
    limit     = int(request.args.get("limit", 10))
    offset    = (sayfa - 1) * limit

    inner_where = ["faturalanan_desi IS NOT NULL", "tahmini_desi IS NOT NULL"]
    params = []
    if pazaryeri:
        inner_where.append("pazaryeri = %s"); params.append(pazaryeri)

    iw = " AND ".join(inner_where)

    # Durum filtresi dışarıdaki subquery sonucuna uygulanır
    outer_where = "1=1"
    if durum == "eslesen":
        outer_where = "desi_farki = 0"
    elif durum == "farkli":
        outer_where = "desi_farki != 0"
    elif durum == "aleyhimize":
        outer_where = "desi_farki > 0"
    elif durum == "lehimize":
        outer_where = "desi_farki < 0"

    subquery = f"""
        SELECT
            siparis_no,
            MAX(pazaryeri_siparis_no)                       AS pazaryeri_siparis_no,
            pazaryeri,
            MAX(urun_adi)                                   AS urun_adi,
            SUM(tahmini_desi)                               AS tahmini_desi,
            MAX(faturalanan_desi)                           AS faturalanan_desi,
            MAX(faturalanan_desi) - SUM(tahmini_desi)       AS desi_farki,
            MAX(satis_kargosu)                              AS satis_kargosu,
            DATE_FORMAT(MAX(siparis_tarihi), '%d.%m.%Y')    AS siparis_tarihi
        FROM karlilik_ozeti
        WHERE {iw}
        GROUP BY siparis_no, pazaryeri
    """

    count_sql = f"SELECT COUNT(*) FROM ({subquery}) t WHERE {outer_where}"
    data_sql  = f"""
        SELECT * FROM ({subquery}) t
        WHERE {outer_where}
        ORDER BY ABS(desi_farki) DESC
        LIMIT %s OFFSET %s
    """

    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute(count_sql, params)
    toplam = cur.fetchone()["COUNT(*)"]
    cur.execute(data_sql, params + [limit, offset])
    rows = cur.fetchall()
    cur.close(); conn.close()

    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v)
                except: pass

    return jsonify({"toplam": toplam, "sayfa": sayfa, "limit": limit, "veriler": rows})


# ── Kargo Desi — Pazaryeri Bazlı Özet (sipariş bazlı) ──
@analiz_bp.route("/kargo-desi/pazaryeri", methods=["GET"])
def kargo_desi_pazaryeri():
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    # İç sorgu: sipariş başına toplam tahmini vs faturalanan
    # Dış sorgu: pazaryeri bazında aggregate
    cur.execute("""
        SELECT
            pazaryeri,
            COUNT(*)                                              AS toplam,
            SUM(CASE WHEN desi_farki = 0 THEN 1 ELSE 0 END)     AS eslesen,
            SUM(CASE WHEN desi_farki != 0 THEN 1 ELSE 0 END)    AS farkli,
            SUM(CASE WHEN desi_farki > 0 THEN 1 ELSE 0 END)     AS aleyhimize,
            SUM(CASE WHEN desi_farki < 0 THEN 1 ELSE 0 END)     AS lehimize,
            COALESCE(SUM(desi_farki), 0)                         AS toplam_desi_farki,
            COALESCE(AVG(faturalanan_desi), 0)                   AS ort_faturalanan_desi,
            COALESCE(AVG(toplam_tahmini), 0)                     AS ort_tahmini_desi
        FROM (
            SELECT
                siparis_no,
                pazaryeri,
                MAX(faturalanan_desi)                    AS faturalanan_desi,
                SUM(tahmini_desi)                        AS toplam_tahmini,
                MAX(faturalanan_desi) - SUM(tahmini_desi) AS desi_farki
            FROM karlilik_ozeti
            WHERE faturalanan_desi IS NOT NULL AND tahmini_desi IS NOT NULL
            GROUP BY siparis_no, pazaryeri
        ) siparis_ozet
        GROUP BY pazaryeri
        ORDER BY ABS(COALESCE(SUM(desi_farki), 0)) DESC
    """)
    rows = cur.fetchall()
    cur.close(); conn.close()
    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v)
                except: pass
    return jsonify(rows)
