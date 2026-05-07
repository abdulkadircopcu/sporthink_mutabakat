import mysql.connector
import traceback

c = mysql.connector.connect(
    host='localhost', user='root', password='',
    database='sporthink_mutabakat', charset='utf8mb4'
)
cur = c.cursor()

print("=== karlilik_ozeti kolonları ===")
cur.execute("DESCRIBE karlilik_ozeti")
for r in cur.fetchall():
    print(r)

print("\n=== siparisler tablosundaki kayitlar ===")
cur.execute("SELECT id, pazaryeri_siparis_no, pazaryeri, toplam_tutar FROM siparisler LIMIT 5")
for r in cur.fetchall():
    print(r)

print("\n=== Pipeline hatası detayi ===")
try:
    from pipeline import karlilik_ozeti_hesapla
    karlilik_ozeti_hesapla("Trendyol")
except Exception as e:
    traceback.print_exc()

cur.close()
c.close()
