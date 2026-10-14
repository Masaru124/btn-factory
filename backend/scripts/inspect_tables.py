import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), '..', 'btn_factory.db')
conn = sqlite3.connect(db_path)
c = conn.cursor()

print("=== SQLITE TABLES ===")
for row in c.execute("SELECT name, sql FROM sqlite_master WHERE type='table'").fetchall():
    table_name, sql = row
    if table_name.startswith('sqlite_'):
        continue
    count = c.execute(f"SELECT count(*) FROM {table_name}").fetchone()[0]
    print(f"\n--- {table_name} (rows: {count}) ---")
    print("Schema:", sql)
    rows = c.execute(f"SELECT * FROM {table_name} LIMIT 3").fetchall()
    print("Sample rows:", rows)
