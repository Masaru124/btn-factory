import os
import sys
from sqlalchemy import create_engine, inspect, text
from dotenv import load_dotenv

load_dotenv('backend/.env')

local_pg = os.getenv('LOCAL_POSTGRES_URL')
neon = os.getenv('NEON_DATABASE_URL')

def check_db(name, url):
    print(f"\n--- Checking {name} ---")
    if not url:
        print("No URL configured")
        return
    try:
        engine = create_engine(url, connect_args={'connect_timeout': 5})
        with engine.connect() as conn:
            inspector = inspect(engine)
            tables = inspector.get_table_names()
            print(f"Connected! Tables ({len(tables)}):", tables)
            for t in ['users', 'orders', 'universal_raw_materials', 'raw_materials', 'casting_process', 'blanking_process', 'turning_process', 'polishing_process', 'packing_process']:
                if t in tables:
                    cnt = conn.execute(text(f'SELECT count(*) FROM "{t}"')).scalar()
                    print(f"  {t}: {cnt} rows")
                    if cnt > 0 and cnt <= 5:
                        rows = conn.execute(text(f'SELECT * FROM "{t}"')).fetchall()
                        for r in rows:
                            print(f"    {r}")
    except Exception as e:
        print(f"Failed to connect to {name}: {e}")

check_db("Local PostgreSQL", local_pg)
check_db("Neon Cloud", neon)
