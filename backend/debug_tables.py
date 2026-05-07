import mysql.connector
c = mysql.connector.connect(host='localhost',user='root',password='',database='sporthink_mutabakat',charset='utf8mb4')
cur = c.cursor()

cur.execute('SHOW TABLES')
tables = [r[0] for r in cur.fetchall()]
print("Flo/Amazon tablolari:")
for t in tables:
    if 'flo' in t or 'amazon' in t:
        print(f"  {t}")
        cur.execute(f'DESCRIBE {t}')
        for col in cur.fetchall():
            print(f"    {col[0]} ({col[1]})")

cur.close(); c.close()
