import glob
import os
import sqlite3

backups_dir = 'backend/backups'
candidate_backups = sorted(glob.glob(os.path.join(backups_dir, 'btn_factory_*.db')), reverse=True)
print(f"Total backups: {len(candidate_backups)}")

for b in candidate_backups:
    try:
        conn = sqlite3.connect(b)
        c = conn.cursor()
        tables = [r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
        if 'orders' in tables and 'casting_process' in tables:
            order_cnt = c.execute("SELECT count(*) FROM orders").fetchone()[0]
            cast_cnt = c.execute("SELECT count(*) FROM casting_process").fetchone()[0]
            print(f"{os.path.basename(b)}: orders={order_cnt}, cast={cast_cnt}")
        conn.close()
    except Exception as e:
        print(f"Err {os.path.basename(b)}: {e}")
