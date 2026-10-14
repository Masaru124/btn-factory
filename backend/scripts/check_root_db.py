import sqlite3

conn = sqlite3.connect('btn_factory.db')
c = conn.cursor()
tables = [r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
print("Root btn_factory.db tables:", tables)
for t in tables:
    if not t.startswith('sqlite'):
        print(t, c.execute(f"SELECT count(*) FROM {t}").fetchone()[0])
