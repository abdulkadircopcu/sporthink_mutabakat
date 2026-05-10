# -*- coding: utf-8 -*-
import os
import sys
from datetime import datetime, timedelta, timezone
from flask import Blueprint, request, jsonify
import mysql.connector
import bcrypt
import jwt

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

auth_bp = Blueprint("auth", __name__)

# JWT ayarları — production'da env variable kullanın
JWT_SECRET  = os.environ.get("JWT_SECRET", "sporthink_jwt_secret_2026")
JWT_ALGO    = "HS256"
JWT_EXPIRE  = 8  # saat

DB_CONFIG = {
    "host": "localhost", "user": "root",
    "password": "", "database": "sporthink_mutabakat", "charset": "utf8mb4"
}

def get_conn():
    return mysql.connector.connect(**DB_CONFIG)


def token_olustur(kullanici_id, email, rol, ad, soyad):
    payload = {
        "sub":   kullanici_id,
        "email": email,
        "rol":   rol,
        "ad":    ad,
        "soyad": soyad,
        "iat":   datetime.now(timezone.utc),
        "exp":   datetime.now(timezone.utc) + timedelta(hours=JWT_EXPIRE),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGO)


def token_dogrula(token):
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGO])
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None


# -------------------------------------------------------
# POST /api/auth/login
# -------------------------------------------------------
@auth_bp.route("/auth/login", methods=["POST"])
def login():
    data  = request.get_json(silent=True) or {}
    email = data.get("email", "").strip().lower()
    sifre = data.get("sifre", "")

    if not email or not sifre:
        return jsonify({"basarili": False, "hata": "Email ve şifre gereklidir."}), 400

    try:
        conn = get_conn()
        cur  = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id, ad, soyad, email, sifre_hash, rol, aktif_mi FROM kullanicilar WHERE email = %s",
            (email,)
        )
        kullanici = cur.fetchone()
        cur.close()
        conn.close()
    except Exception as e:
        return jsonify({"basarili": False, "hata": f"Veritabanı hatası: {str(e)}"}), 500

    if not kullanici:
        return jsonify({"basarili": False, "hata": "Email veya şifre hatalı."}), 401

    if not kullanici["aktif_mi"]:
        return jsonify({"basarili": False, "hata": "Hesabınız devre dışı bırakılmış."}), 403

    # Şifre kontrolü
    try:
        eslesme = bcrypt.checkpw(
            sifre.encode("utf-8"),
            kullanici["sifre_hash"].encode("utf-8")
        )
    except Exception:
        eslesme = False

    if not eslesme:
        return jsonify({"basarili": False, "hata": "Email veya şifre hatalı."}), 401

    # Son giriş güncelle
    try:
        conn = get_conn()
        cur  = conn.cursor()
        cur.execute("UPDATE kullanicilar SET son_giris = NOW() WHERE id = %s", (kullanici["id"],))
        conn.commit()
        cur.close()
        conn.close()
    except Exception:
        pass

    token = token_olustur(
        kullanici["id"], kullanici["email"],
        kullanici["rol"], kullanici["ad"], kullanici["soyad"]
    )

    return jsonify({
        "basarili": True,
        "token": token,
        "kullanici": {
            "id":    kullanici["id"],
            "ad":    kullanici["ad"],
            "soyad": kullanici["soyad"],
            "email": kullanici["email"],
            "rol":   kullanici["rol"],
        }
    })


# -------------------------------------------------------
# GET /api/auth/me  (token ile mevcut kullanici)
# -------------------------------------------------------
@auth_bp.route("/auth/me", methods=["GET"])
def me():
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"basarili": False, "hata": "Token bulunamadı."}), 401

    token   = auth_header[7:]
    payload = token_dogrula(token)
    if not payload:
        return jsonify({"basarili": False, "hata": "Geçersiz veya süresi dolmuş token."}), 401

    return jsonify({
        "basarili": True,
        "kullanici": {
            "id":    payload["sub"],
            "ad":    payload["ad"],
            "soyad": payload["soyad"],
            "email": payload["email"],
            "rol":   payload["rol"],
        }
    })
