import sqlite3

conn = sqlite3.connect('backend/btn_factory.db')
c = conn.cursor()
tables = [r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
for t in tables:
    if t.startswith('sqlite'):
        continue
    for r in c.execute(f"SELECT * FROM {t}").fetchall():
        if any('10:49:51' in str(v) for v in r):
            print(t, r)
