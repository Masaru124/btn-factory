import sqlite3
import json

conn = sqlite3.connect('backend/backups/btn_factory_20261014_161121.db')
conn.row_factory = sqlite3.Row
c = conn.cursor()

tables = [r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
data = {}
for t in tables:
    if not t.startswith('sqlite'):
        rows = [dict(r) for r in c.execute(f"SELECT * FROM {t}").fetchall()]
        data[t] = rows

print(json.dumps(data, indent=2, default=str))
