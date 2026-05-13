import json
import sys
import os
from datetime import datetime
from flask import Blueprint, request, jsonify
import mysql.connector

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

analiz_bp = Blueprint("analiz", __name__)

DB_CONFIG = {
    "host": "localhost", "user": "root",
    "password": "", "database": "sporthink_mutabakat", "charset": "utf8mb4"
}

def get_conn():
    return mysql.connector.connect(**DB_CONFIG)


# ── Karlılık Özeti Kartları ──
@analiz_bp.route("/karlilik/ozet", methods=["GET"])
def karlilik_ozet():
    pazaryeri = request.args.get("pazaryeri")

    where  = ["1=1"]
    params = []
    if pazaryeri:
        where.append("pazaryeri = %s"); params.append(pazaryeri)

    sql = f"""
        SELECT
            COUNT(*)                              AS toplam_siparis,
            COALESCE(SUM(satis_tutari), 0)        AS toplam_ciro,
            COALESCE(SUM(net_kar), 0)             AS toplam_kar,
            COALESCE(AVG(kar_marji), 0)           AS ort_kar_marji,
            SUM(CASE WHEN zarar_mi=1 THEN 1 ELSE 0 END) AS zarar_siparis,
            SUM(CASE WHEN net_kar>0  THEN 1 ELSE 0 END) AS karli_siparis
        FROM karlilik_ozeti
        WHERE {" AND ".join(where)}
    """
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute(sql, params)
    row = cur.fetchone()
    cur.close(); conn.close()

    # Decimal → float çevir
    for k, v in row.items():
        if v is not None:
            try: row[k] = float(v)
            except: pass
    return jsonify(row)


# ── Karlılık Listesi ──
@analiz_bp.route("/karlilik/liste", methods=["GET"])
def karlilik_liste():
    pazaryeri = request.args.get("pazaryeri")
    durum     = request.args.get("durum")       # zarar / karli / hepsi
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

    w = " AND ".join(where)

    count_sql = f"SELECT COUNT(*) FROM karlilik_ozeti WHERE {w}"
    data_sql  = f"""
        SELECT
            siparis_no, pazaryeri_siparis_no, pazaryeri, siparis_durumu,
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
    import mutabakat as mut_module
    pazaryeri = None
    if request.is_json and request.json:
        pazaryeri = request.json.get("pazaryeri")
    try:
        ozet = mut_module.toplu_mutabakat_hesapla(pazaryeri)
        return jsonify({"basarili": True, "ozet": ozet})
    except Exception as e:
        return jsonify({"basarili": False, "hata": str(e)}), 500


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
            k.siparis_durumu
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
