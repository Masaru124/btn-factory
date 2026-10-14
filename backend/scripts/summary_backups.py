import glob
import os
import sqlite3

for f in sorted(glob.glob('backend/backups/*.db')):
    conn = sqlite3.connect(f)
    c = conn.cursor()
    tables = [r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
    order_count = c.execute("SELECT count(*) FROM orders").fetchone()[0] if 'orders' in tables else 0
    cast_count = c.execute("SELECT count(*) FROM casting_process").fetchone()[0] if 'casting_process' in tables else 0
    pack_count = c.execute("SELECT count(*) FROM packing_process").fetchone()[0] if 'packing_process' in tables else 0
    uni_count = c.execute("SELECT count(*) FROM universal_raw_materials").fetchone()[0] if 'universal_raw_materials' in tables else 0
    print(f"{os.path.basename(f)}: orders={order_count}, cast={cast_count}, pack={pack_count}, uni={uni_count}")
