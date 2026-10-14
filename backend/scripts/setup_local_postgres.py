"""Universal PostgreSQL Discovery, Credential Resolver, and Schema Initializer.

This script runs on ANY system (Windows, Linux, macOS) to:
  1. Scan and detect active PostgreSQL ports (5432, 5433, etc.).
  2. Auto-discover or resolve PostgreSQL credentials (pgpass, env, common defaults, or interactive).
  3. Ensure the 'btn_factory' database exists (creates it if missing).
  4. Automatically create all tables (via SQLAlchemy Base.metadata & migrations).
  5. Seed the default admin account.
  6. Optionally sync existing records from SQLite into Local PostgreSQL.
  7. Automatically update backend/.env with the working LOCAL_POSTGRES_URL.

Usage:
  python scripts/setup_local_postgres.py
  python scripts/setup_local_postgres.py --set-active
  python scripts/setup_local_postgres.py --port 5432 --user postgres --password 1234
"""

import argparse
import getpass
import os
import re
import socket
import sys
from urllib.parse import quote_plus

# Ensure backend directory is in sys.path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)


def print_banner():
    print("=" * 80)
    print("  BUTTON FACTORY MES - UNIVERSAL LOCAL POSTGRESQL AUTO-SETUP")
    print("=" * 80)


def scan_local_pg_ports(ports=(5432, 5433, 5434, 5435)) -> list[int]:
    """Scan local host for open TCP ports typical for PostgreSQL."""
    open_ports = []
    for port in ports:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(0.3)
                if s.connect_ex(("127.0.0.1", port)) == 0:
                    open_ports.append(port)
        except Exception:
            pass
    return open_ports


def read_pgpass_credentials() -> list[tuple[str, int, str, str]]:
    """Look for credentials in ~/.pgpass (Linux/macOS) or %APPDATA%/postgresql/pgpass.conf (Windows)."""
    creds = []
    candidates = []
    appdata = os.environ.get("APPDATA")
    if appdata:
        candidates.append(os.path.join(appdata, "postgresql", "pgpass.conf"))
    home = os.path.expanduser("~")
    candidates.append(os.path.join(home, ".pgpass"))
    candidates.append(os.path.join(home, "AppData", "Roaming", "postgresql", "pgpass.conf"))

    for p in candidates:
        if os.path.exists(p):
            try:
                with open(p, "r", encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#"):
                            parts = line.split(":")
                            if len(parts) >= 5:
                                host, port_str, db, user, pwd = parts[0], parts[1], parts[2], parts[3], parts[4]
                                try:
                                    port = int(port_str) if port_str != "*" else 5432
                                    creds.append((user, pwd, port))
                                except ValueError:
                                    pass
            except Exception:
                pass
    return creds


def read_existing_env_credentials() -> list[tuple[str, str, int]]:
    """Inspect backend/.env for current configured credentials."""
    creds = []
    env_path = os.path.join(BACKEND_DIR, ".env")
    if os.path.exists(env_path):
        try:
            with open(env_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            match = re.search(r"LOCAL_POSTGRES_URL=postgresql://([^:]+):([^@]+)@([^:/]+):(\d+)/", content)
            if match:
                user, pwd, host, port = match.groups()
                creds.append((user, pwd, int(port)))
        except Exception:
            pass
    return creds


def test_pg_credentials(user: str, pwd: str, host: str, port: int, dbname: str = "postgres"):
    """Attempt connecting with psycopg or psycopg2."""
    driver_tried = []
    try:
        import psycopg
        conn = psycopg.connect(
            host=host,
            port=port,
            user=user,
            password=pwd,
            dbname=dbname,
            connect_timeout=2,
        )
        return conn, "psycopg"
    except ImportError:
        driver_tried.append("psycopg")
    except Exception as e:
        return None, str(e)

    try:
        import psycopg2
        conn = psycopg2.connect(
            host=host,
            port=port,
            user=user,
            password=pwd,
            dbname=dbname,
            connect_timeout=2,
        )
        return conn, "psycopg2"
    except ImportError:
        driver_tried.append("psycopg2")
    except Exception as e:
        return None, str(e)

    raise RuntimeError(f"Neither psycopg nor psycopg2 is installed! Please run: pip install psycopg[binary]")


def update_env_file(local_pg_url: str, set_active: bool = False):
    """Write or update LOCAL_POSTGRES_URL and optionally ACTIVE_DB_TIER in backend/.env."""
    env_path = os.path.join(BACKEND_DIR, ".env")
    if not os.path.exists(env_path):
        content = ""
    else:
        with open(env_path, "r", encoding="utf-8") as f:
            content = f.read()

    # Update or add LOCAL_POSTGRES_URL
    if "LOCAL_POSTGRES_URL=" in content:
        content = re.sub(r"LOCAL_POSTGRES_URL=.*", f"LOCAL_POSTGRES_URL={local_pg_url}", content)
    else:
        content += f"\nLOCAL_POSTGRES_URL={local_pg_url}\n"

    if set_active:
        if "ACTIVE_DB_TIER=" in content:
            content = re.sub(r"ACTIVE_DB_TIER=.*", "ACTIVE_DB_TIER=postgres", content)
        else:
            content += "\nACTIVE_DB_TIER=postgres\n"

    with open(env_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f" [OK] Automatically updated backend/.env:")
    print(f"      LOCAL_POSTGRES_URL={local_pg_url}")
    if set_active:
        print(" [OK] Set ACTIVE_DB_TIER=postgres in backend/.env")


def mask_url(url: str) -> str:
    from urllib.parse import urlparse
    parsed = urlparse(url)
    if parsed.password:
        return url.replace(f":{parsed.password}@", ":******@")
    return url


def main():
    print_banner()
    parser = argparse.ArgumentParser(description="Button Factory MES - Local PostgreSQL Auto-Setup & Table Generator")
    parser.add_argument("--port", type=int, help="Specify PostgreSQL port (e.g. 5432)")
    parser.add_argument("--user", type=str, help="Specify PostgreSQL username (e.g. postgres)")
    parser.add_argument("--password", type=str, help="Specify PostgreSQL password")
    parser.add_argument("--dbname", type=str, default="btn_factory", help="Target database name (default: btn_factory)")
    parser.add_argument("--set-active", action="store_true", help="Set ACTIVE_DB_TIER=postgres in .env")
    parser.add_argument("--sync-data", action="store_true", default=True, help="Sync data from existing SQLite DB")
    parser.add_argument("--no-sync", action="store_false", dest="sync_data", help="Do not sync data from SQLite")
    parser.add_argument("--non-interactive", action="store_true", help="Do not prompt if discovery fails")
    args = parser.parse_args()

    host = "localhost"

    # Step 1: Detect Open Ports
    print("[1/5] Detecting local PostgreSQL ports...")
    if args.port:
        open_ports = [args.port]
    else:
        open_ports = scan_local_pg_ports()

    if not open_ports:
        print(" [WARN] No open PostgreSQL ports found on standard ports (5432-5435).")
        print("        Checking if PostgreSQL service is installed...")
        if not args.non_interactive:
            port_input = input("Enter PostgreSQL port [default 5432]: ").strip()
            open_ports = [int(port_input) if port_input else 5432]
        else:
            open_ports = [5432]

    print(f" [PASS] Detected open PostgreSQL port(s): {open_ports}")

    # Step 2: Build candidate list of credentials
    candidate_creds = []

    # CLI args take first priority
    if args.user and args.password is not None:
        for p in open_ports:
            candidate_creds.append((args.user, args.password, p))

    # Read from existing .env
    for u, p, prt in read_existing_env_credentials():
        if prt in open_ports or not open_ports:
            candidate_creds.append((u, p, prt))

    # Read from pgpass
    for u, p, prt in read_pgpass_credentials():
        if prt in open_ports:
            candidate_creds.append((u, p, prt))

    # Read from environment variables
    env_user = os.environ.get("PGUSER") or "postgres"
    env_pwd = os.environ.get("PGPASSWORD")
    if env_pwd:
        for p in open_ports:
            candidate_creds.append((env_user, env_pwd, p))

    # Common default passwords
    common_passwords = [
        "1234",
        "postgres",
        "admin",
        "root",
        "password",
        "123456",
        "12345",
        "12345678",
        "btn_factory",
        "button_factory",
        "postgres123",
        "",
    ]
    common_users = ["postgres"]
    current_user = os.environ.get("USERNAME") or os.environ.get("USER")
    if current_user and current_user not in common_users:
        common_users.append(current_user)

    for p in open_ports:
        for u in common_users:
            for pwd in common_passwords:
                candidate_creds.append((u, pwd, p))

    # Remove duplicates preserving order
    seen = set()
    unique_candidates = []
    for u, pwd, p in candidate_creds:
        key = (u, pwd, p)
        if key not in seen:
            seen.add(key)
            unique_candidates.append(key)

    # Step 3: Test and find working credentials
    print(f"[2/5] Testing credentials across {len(unique_candidates)} discovery candidates...")
    working_conn = None
    working_user = None
    working_pwd = None
    working_port = None
    driver_name = None

    for u, pwd, p in unique_candidates:
        conn, res = test_pg_credentials(u, pwd, host, p, "postgres")
        if conn is not None:
            working_conn = conn
            working_user = u
            working_pwd = pwd
            working_port = p
            driver_name = res
            break

    # If still not found and interactive, prompt the user
    if working_conn is None and not args.non_interactive:
        print("\n [INFO] Automated credential discovery could not match your local password.")
        target_port = open_ports[0] if open_ports else 5432
        input_user = input(f"Enter PostgreSQL username [postgres]: ").strip() or "postgres"
        input_pwd = getpass.getpass(f"Enter password for '{input_user}' on port {target_port}: ")
        conn, res = test_pg_credentials(input_user, input_pwd, host, target_port, "postgres")
        if conn is not None:
            working_conn = conn
            working_user = input_user
            working_pwd = input_pwd
            working_port = target_port
            driver_name = res
        else:
            print(f" [FAIL] Authentication failed: {res}")
            sys.exit(1)

    if working_conn is None:
        print(" [FAIL] Could not authenticate with any detected credentials.")
        print("        Please provide your password via: python scripts/setup_local_postgres.py --user postgres --password <YOUR_PASSWORD>")
        sys.exit(1)

    print(f" [PASS] Successfully authenticated!")
    print(f"        Driver   : {driver_name}")
    print(f"        Host     : {host}")
    print(f"        Port     : {working_port}")
    print(f"        Username : {working_user}")
    print(f"        Password : {'*' * len(working_pwd) if working_pwd else '(blank)'}")

    # Step 4: Ensure target database exists
    target_db = args.dbname
    print(f"[3/5] Verifying target database '{target_db}'...")
    try:
        working_conn.autocommit = True
        cur = working_conn.cursor()
        cur.execute("SELECT datname FROM pg_database WHERE datistemplate = false;")
        existing_dbs = [row[0] for row in cur.fetchall()]
        if target_db not in existing_dbs:
            print(f"        Database '{target_db}' does not exist. Creating it now...")
            cur.execute(f'CREATE DATABASE "{target_db}";')
            print(f" [PASS] Database '{target_db}' created successfully.")
        else:
            print(f" [PASS] Database '{target_db}' already exists.")
        cur.close()
        working_conn.close()
    except Exception as e:
        print(f" [WARN] Notice while checking database: {e}")

    # Build final LOCAL_POSTGRES_URL
    safe_pwd = quote_plus(working_pwd) if working_pwd else ""
    local_pg_url = f"postgresql://{working_user}:{safe_pwd}@{host}:{working_port}/{target_db}"

    # Update .env file
    update_env_file(local_pg_url, set_active=args.set_active)

    # Step 5: Create all tables via SQLAlchemy models
    print(f"[4/5] Initializing tables and schema in '{target_db}'...")
    from sqlalchemy import create_engine, inspect, text
    from app.core.database import Base, normalize_database_url
    from app.core.migrations import sync_database_schema
    from app.services.auth_service import AuthService
    from sqlalchemy.orm import sessionmaker
    import app.models  # register all models

    norm_url = normalize_database_url(local_pg_url)
    engine = create_engine(norm_url, pool_pre_ping=True)

    # Create tables
    Base.metadata.create_all(bind=engine)
    sync_database_schema(engine)

    # Seed admin user
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    try:
        AuthService(db).ensure_seed_admin()
        print(" [PASS] Default admin user verified / seeded.")
    finally:
        db.close()

    inspector = inspect(engine)
    tables = inspector.get_table_names()
    print(f" [PASS] Schema ready! Found {len(tables)} tables: {', '.join(tables)}")

    # Step 6: Sync data from SQLite if requested
    if args.sync_data:
        print(f"[5/5] Checking for data sync from local SQLite database...")
        from app.services.backup_service import BackupService
        bs = BackupService(backend_dir=BACKEND_DIR)
        sync_res = bs.sync_to_local_postgres()
        if sync_res.get("status") == "SUCCESS":
            synced = sync_res.get("synced", {})
            total_rows = sum(synced.values())
            print(f" [PASS] Synced {total_rows} records from SQLite into Local PostgreSQL:")
            for tbl, count in synced.items():
                if count > 0:
                    print(f"        - {tbl:<24} : {count} rows")
        else:
            print(f" [INFO] Sync status: {sync_res.get('status')} ({sync_res.get('message') or sync_res.get('error')})")
    else:
        print("[5/5] Data sync skipped (--no-sync flag passed).")

    print("=" * 80)
    print("  POSTGRESQL SETUP COMPLETE!")
    print("=" * 80)
    print("  [1] Automatically updated in your backend/.env file:")
    print(f"      LOCAL_POSTGRES_URL={local_pg_url}")
    print()
    print("  [2] Exact line to copy-paste into .env on any system:")
    print(f"      LOCAL_POSTGRES_URL={local_pg_url}")
    print()
    print(f"  [3] Active Operational DB Tier : {'POSTGRES (Primary)' if args.set_active else 'SQLITE (pass --set-active to make Postgres primary)'}")
    print("=" * 80)


if __name__ == "__main__":
    main()
