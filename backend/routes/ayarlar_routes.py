# -*- coding: utf-8 -*-
import os
import sys
import json
from flask import Blueprint, request, jsonify
import mysql.connector
import jwt as _jwt
from jwt import jwk as _jwk

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

ayarlar_bp = Blueprint("ayarlar", __name__)

JWT_SECRET = os.environ.get("JWT_SECRET", "sporthink_jwt_secret_2026")
JWT_ALGO   = "HS256"

# Pazaryeri → kargo desi tablosu (whitelist — SQL injection yok)
KARGO_TABLOLARI = {
    "trendyol":    "trendyol_kargo_desi_fiyatlari",
    "hepsiburada": "hepsiburada_kargo_desi_fiyatlari",
    "lcw":         "lcw_kargo_desi_fiyatlari",
    "n11":         "n11_kargo_desi_fiyatlari",
    "pazarama":    "pazarama_kargo_desi_fiyatlari",
    "flo":         "flo_kargo_desi_fiyatlari",
}

GECERSIZ_KOLONLAR = {"id", "olusturma_tarihi"}


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


def _token_dogrula(token: str):
    try:
        key = _jwk.OctetJWK(JWT_SECRET.encode())
        instance = _jwt.JWT()
        return instance.decode(token, key, algorithms={JWT_ALGO})
    except Exception:
        return None


def _auth(gerekli_rol: str = None):
    """Token doğrular; gerekli_rol verilmişse rol de kontrol eder.
    Başarılı → payload dict, başarısız → None."""
    auth = request.headers.get("Authorization", "")
    if not auth.startswith("Bearer "):
        return None
    raw = _token_dogrula(auth[7:])
    if not raw:
        return None
    payload = json.loads(raw) if isinstance(raw, str) else raw
    if gerekli_rol and payload.get("rol") != gerekli_rol:
        return None
    return payload


# ── Kargo Desi Fiyatları ─────────────────────────────────────


@ayarlar_bp.route("/ayarlar/kargo-desi", methods=["GET"])
def kargo_desi_liste():
    pazaryeri = request.args.get("pazaryeri", "").lower()
    tablo = KARGO_TABLOLARI.get(pazaryeri)
    if not tablo:
        return jsonify({"hata": "Geçersiz pazaryeri"}), 400

    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute(f"SELECT * FROM {tablo} ORDER BY desi ASC")
    rows = cur.fetchall()
    cur.close(); conn.close()

    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v)
                except (TypeError, ValueError): row[k] = str(v) if v else v

    sutunlar = [k for k in (rows[0].keys() if rows else []) if k not in GECERSIZ_KOLONLAR]
    return jsonify({"sutunlar": sutunlar, "veriler": rows})


@ayarlar_bp.route("/ayarlar/kargo-desi/<int:row_id>", methods=["PUT"])
def kargo_desi_guncelle(row_id):
    body      = request.get_json(silent=True) or {}
    pazaryeri = body.get("pazaryeri", "").lower()
    tablo     = KARGO_TABLOLARI.get(pazaryeri)
    if not tablo:
        return jsonify({"hata": "Geçersiz pazaryeri"}), 400

    # İzin verilen kolonları DB'den al
    conn = get_conn()
    cur  = conn.cursor()
    cur.execute(f"SELECT * FROM {tablo} WHERE id = %s LIMIT 1", (row_id,))
    cur.fetchone()
    kolonlar = [d[0] for d in cur.description if d[0] not in GECERSIZ_KOLONLAR and d[0] != "id"]

    guncellenecek = {k: v for k, v in body.items() if k in kolonlar}
    if not guncellenecek:
        cur.close(); conn.close()
        return jsonify({"hata": "Güncellenecek alan yok"}), 400

    set_clause = ", ".join(f"`{k}` = %s" for k in guncellenecek)
    cur.execute(
        f"UPDATE {tablo} SET {set_clause} WHERE id = %s",
        list(guncellenecek.values()) + [row_id]
    )
    conn.commit()
    cur.close(); conn.close()
    return jsonify({"basarili": True})


# ── Kategori Desi Listesi ─────────────────────────────────────


@ayarlar_bp.route("/ayarlar/kategori-desi", methods=["GET"])
def kategori_desi_liste():
    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute("""
        SELECT id, ana_kategori, alt_kategori, cinsiyet, tahmini_desi, barkod
        FROM kategori_desi_listesi
        ORDER BY ana_kategori, alt_kategori
    """)
    rows = cur.fetchall()
    cur.close(); conn.close()
    for row in rows:
        for k, v in row.items():
            if v is not None:
                try: row[k] = float(v) if k == "tahmini_desi" else v
                except (TypeError, ValueError): pass
    return jsonify(rows)


@ayarlar_bp.route("/ayarlar/kategori-desi/<int:row_id>", methods=["PUT"])
def kategori_desi_guncelle(row_id):
    body = request.get_json(silent=True) or {}
    izin = {"ana_kategori", "alt_kategori", "cinsiyet", "tahmini_desi", "barkod"}
    guncelle = {k: v for k, v in body.items() if k in izin}
    if not guncelle:
        return jsonify({"hata": "Güncellenecek alan yok"}), 400

    conn = get_conn()
    cur  = conn.cursor()
    set_clause = ", ".join(f"`{k}` = %s" for k in guncelle)
    cur.execute(
        f"UPDATE kategori_desi_listesi SET {set_clause} WHERE id = %s",
        list(guncelle.values()) + [row_id]
    )
    conn.commit()
    cur.close(); conn.close()
    return jsonify({"basarili": True})


# ── Kullanıcı Yönetimi (sadece admin) ────────────────────────


@ayarlar_bp.route("/ayarlar/kategori-desi", methods=["POST"])
def kategori_desi_ekle():
    body = request.get_json(silent=True) or {}
    ana_kategori = (body.get("ana_kategori") or "").strip()
    alt_kategori = (body.get("alt_kategori") or "").strip() or None
    cinsiyet     = (body.get("cinsiyet")     or "").strip() or None
    tahmini_desi = body.get("tahmini_desi")
    barkod       = (body.get("barkod")       or "").strip() or None

    if not ana_kategori:
        return jsonify({"hata": "Ana kategori zorunludur"}), 400
    if tahmini_desi is None:
        return jsonify({"hata": "Tahmini desi zorunludur"}), 400
    try:
        tahmini_desi = int(tahmini_desi)
    except (TypeError, ValueError):
        return jsonify({"hata": "Geçersiz tahmini desi değeri"}), 400

    conn = get_conn()
    cur  = conn.cursor()
    cur.execute("""
        INSERT INTO kategori_desi_listesi (ana_kategori, alt_kategori, cinsiyet, tahmini_desi, barkod)
        VALUES (%s, %s, %s, %s, %s)
    """, (ana_kategori, alt_kategori, cinsiyet, tahmini_desi, barkod))
    conn.commit()
    yeni_id = cur.lastrowid
    cur.close(); conn.close()
    return jsonify({"basarili": True, "id": yeni_id}), 201


@ayarlar_bp.route("/ayarlar/kategori-desi/<int:row_id>", methods=["DELETE"])
def kategori_desi_sil(row_id):
    conn = get_conn()
    cur  = conn.cursor()
    cur.execute("DELETE FROM kategori_desi_listesi WHERE id = %s", (row_id,))
    conn.commit()
    cur.close(); conn.close()
    return jsonify({"basarili": True})


# ── Komisyon Oranları ─────────────────────────────────────────

GECERLI_PAZARYERLER = {"trendyol", "hepsiburada", "lcw", "n11", "pazarama", "flo", "amazon"}


@ayarlar_bp.route("/ayarlar/komisyon-oranlari", methods=["GET"])
def komisyon_oranlari_liste():
    pazaryeri = request.args.get("pazaryeri", "").lower()
    if pazaryeri and pazaryeri not in GECERLI_PAZARYERLER:
        return jsonify({"hata": "Geçersiz pazaryeri"}), 400

    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    if pazaryeri:
        cur.execute("""
            SELECT id, pazaryeri_kod, kategori, alt_kategori, komisyon_orani, gecerlilik_tarihi
            FROM komisyon_oranlari
            WHERE pazaryeri_kod = %s
            ORDER BY kategori, alt_kategori, gecerlilik_tarihi DESC
        """, (pazaryeri,))
    else:
        cur.execute("""
            SELECT id, pazaryeri_kod, kategori, alt_kategori, komisyon_orani, gecerlilik_tarihi
            FROM komisyon_oranlari
            ORDER BY pazaryeri_kod, kategori, alt_kategori, gecerlilik_tarihi DESC
        """)
    rows = cur.fetchall()
    cur.close(); conn.close()
    for row in rows:
        if row.get("komisyon_orani") is not None:
            row["komisyon_orani"] = float(row["komisyon_orani"])
        if row.get("gecerlilik_tarihi") is not None:
            row["gecerlilik_tarihi"] = str(row["gecerlilik_tarihi"])
    return jsonify(rows)


@ayarlar_bp.route("/ayarlar/komisyon-oranlari", methods=["POST"])
def komisyon_oranlari_ekle():
    body = request.get_json(silent=True) or {}
    pazaryeri_kod     = (body.get("pazaryeri_kod") or "").lower()
    kategori          = (body.get("kategori")       or "").strip()
    alt_kategori      = (body.get("alt_kategori")   or "").strip() or None
    komisyon_orani    = body.get("komisyon_orani")
    gecerlilik_tarihi = body.get("gecerlilik_tarihi") or None

    if pazaryeri_kod not in GECERLI_PAZARYERLER:
        return jsonify({"hata": "Geçersiz pazaryeri"}), 400
    if not kategori:
        return jsonify({"hata": "Kategori zorunludur"}), 400
    if komisyon_orani is None:
        return jsonify({"hata": "Komisyon oranı zorunludur"}), 400
    try:
        komisyon_orani = float(komisyon_orani)
    except (TypeError, ValueError):
        return jsonify({"hata": "Geçersiz komisyon oranı"}), 400

    conn = get_conn()
    cur  = conn.cursor()
    cur.execute("""
        INSERT INTO komisyon_oranlari (pazaryeri_kod, kategori, alt_kategori, komisyon_orani, gecerlilik_tarihi)
        VALUES (%s, %s, %s, %s, COALESCE(%s, CURDATE()))
    """, (pazaryeri_kod, kategori, alt_kategori, komisyon_orani, gecerlilik_tarihi))
    conn.commit()
    yeni_id = cur.lastrowid
    cur.close(); conn.close()
    return jsonify({"basarili": True, "id": yeni_id}), 201


@ayarlar_bp.route("/ayarlar/komisyon-oranlari/<int:row_id>", methods=["PUT"])
def komisyon_oranlari_guncelle(row_id):
    body = request.get_json(silent=True) or {}
    izin = {"kategori", "alt_kategori", "komisyon_orani", "gecerlilik_tarihi"}
    guncelle = {k: v for k, v in body.items() if k in izin}

    if "komisyon_orani" in guncelle:
        try:
            guncelle["komisyon_orani"] = float(guncelle["komisyon_orani"])
        except (TypeError, ValueError):
            return jsonify({"hata": "Geçersiz komisyon oranı"}), 400

    if not guncelle:
        return jsonify({"hata": "Güncellenecek alan yok"}), 400

    conn = get_conn()
    cur  = conn.cursor()
    set_clause = ", ".join(f"`{k}` = %s" for k in guncelle)
    cur.execute(
        f"UPDATE komisyon_oranlari SET {set_clause} WHERE id = %s",
        list(guncelle.values()) + [row_id]
    )
    conn.commit()
    cur.close(); conn.close()
    return jsonify({"basarili": True})


@ayarlar_bp.route("/ayarlar/komisyon-oranlari/<int:row_id>", methods=["DELETE"])
def komisyon_oranlari_sil(row_id):
    conn = get_conn()
    cur  = conn.cursor()
    cur.execute("DELETE FROM komisyon_oranlari WHERE id = %s", (row_id,))
    conn.commit()
    cur.close(); conn.close()
    return jsonify({"basarili": True})


# ── Kullanıcı Yönetimi (sadece admin) ────────────────────────


@ayarlar_bp.route("/ayarlar/kullanicilar", methods=["GET"])
def kullanicilar_liste():
    if not _auth("admin"):
        return jsonify({"hata": "Bu işlem için admin yetkisi gerekli"}), 403

    conn = get_conn()
    cur  = conn.cursor(dictionary=True)
    cur.execute("""
        SELECT id, ad, soyad, email, rol, aktif_mi,
               DATE_FORMAT(son_giris, '%d.%m.%Y %H:%i') AS son_giris,
               DATE_FORMAT(olusturma_tarihi, '%d.%m.%Y') AS olusturma_tarihi
        FROM kullanicilar
        ORDER BY olusturma_tarihi ASC
    """)
    rows = cur.fetchall()
    cur.close(); conn.close()
    return jsonify(rows)


@ayarlar_bp.route("/ayarlar/kullanicilar/<int:user_id>/rol", methods=["PUT"])
def kullanici_rol_guncelle(user_id):
    payload = _auth("admin")
    if not payload:
        return jsonify({"hata": "Bu işlem için admin yetkisi gerekli"}), 403

    if int(payload.get("sub", -1)) == user_id:
        return jsonify({"hata": "Kendi rolünüzü değiştiremezsiniz"}), 400

    body = request.get_json(silent=True) or {}
    yeni_rol = body.get("rol", "").lower()
    if yeni_rol not in ("admin", "analist", "okuyucu"):
        return jsonify({"hata": "Geçersiz rol"}), 400

    conn = get_conn()
    cur  = conn.cursor()
    cur.execute("UPDATE kullanicilar SET rol = %s WHERE id = %s", (yeni_rol, user_id))
    conn.commit()
    cur.close(); conn.close()
    return jsonify({"basarili": True})


@ayarlar_bp.route("/ayarlar/kullanicilar/<int:user_id>/aktif", methods=["PUT"])
def kullanici_aktif_guncelle(user_id):
    payload = _auth("admin")
    if not payload:
        return jsonify({"hata": "Bu işlem için admin yetkisi gerekli"}), 403

    body    = request.get_json(silent=True) or {}
    aktif   = 1 if body.get("aktif_mi") else 0

    conn = get_conn()
    cur  = conn.cursor()
    cur.execute("UPDATE kullanicilar SET aktif_mi = %s WHERE id = %s", (aktif, user_id))
    conn.commit()
    cur.close(); conn.close()
    return jsonify({"basarili": True})
