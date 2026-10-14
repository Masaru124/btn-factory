import glob
import sqlite3

for f in sorted(glob.glob('backend/backups/*.db')):
    try:
        conn = sqlite3.connect(f)
        tables = [r[0] for r in conn.cursor().execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
        has_uni = 'universal_raw_materials' in tables
        rows = conn.cursor().execute('SELECT * FROM universal_raw_materials').fetchall() if has_uni else []
        print(f, "has_uni:", has_uni, "rows:", rows)
    except Exception as e:
        print(f, "error:", e)
