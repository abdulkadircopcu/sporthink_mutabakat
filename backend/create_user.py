"""
Kullanici olusturma / sifre hash aracı.
Kullanim: python create_user.py
"""
import bcrypt
import mysql.connector

DB_CONFIG = {
    "host": "localhost", "user": "root",
    "password": "", "database": "sporthink_mutabakat", "charset": "utf8mb4"
}

def hash_sifre(sifre: str) -> str:
    return bcrypt.hashpw(sifre.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

def kullanici_ekle(ad, soyad, email, sifre, rol="admin"):
    hashed = hash_sifre(sifre)
    conn = mysql.connector.connect(**DB_CONFIG)
    cur  = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO kullanicilar (ad, soyad, email, sifre_hash, rol, aktif_mi)
            VALUES (%s, %s, %s, %s, %s, 1)
        """, (ad, soyad, email, hashed, rol))
        conn.commit()
        print(f"✅ Kullanıcı oluşturuldu: {email} [{rol}]")
    except mysql.connector.IntegrityError:
        print(f"⚠️  Bu email zaten kayıtlı: {email}")
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    print("=== Kullanıcı Oluşturma Aracı ===")
    ad    = input("Ad      : ").strip()
    soyad = input("Soyad   : ").strip()
    email = input("Email   : ").strip().lower()
    sifre = input("Şifre   : ").strip()
    rol   = input("Rol [admin/analist/okuyucu] (enter=admin): ").strip() or "admin"
    kullanici_ekle(ad, soyad, email, sifre, rol)
