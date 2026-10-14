import sqlite3

conn = sqlite3.connect('backend/backups/btn_factory_20261014_161121.db')
c = conn.cursor()
tables = [r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
for t in tables:
    if t.startswith('sqlite'):
        continue
    rows = c.execute(f"SELECT * FROM {t}").fetchall()
    print(f"\n=== {t} ({len(rows)} rows) ===")
    for r in rows:
        print(r)
