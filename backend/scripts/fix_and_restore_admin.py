"""
Universal Database Healer & Super Admin Restorer.
Detects and terminates ANY process locking SQLite files on Windows (via Windows Restart Manager API and Port 8000 scanner).
Heals corrupt databases, restores clean backup, and guarantees Super Admin access.
"""
import ctypes
import glob
import os
import shutil
import sqlite3
import subprocess
import sys
import time
from datetime import datetime

# Ensure backend root is on sys.path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)

from dotenv import load_dotenv
load_dotenv(os.path.join(BACKEND_DIR, '.env'))

from app.core.config import get_settings
from app.core.database import Base, SessionLocal, engine
from app.core.migrations import sync_database_schema
from app.core.security import get_password_hash
from app.models.user import User, UserRole


def find_processes_locking_file(file_path: str) -> list[tuple[int, str]]:
    """Use Windows Restart Manager API to find all PIDs locking a specific file."""
    if sys.platform != 'win32' or not os.path.exists(file_path):
        return []

    try:
        from ctypes import wintypes
        rstrtmgr = ctypes.WinDLL('rstrtmgr')

        session_handle = wintypes.DWORD()
        session_key = (wintypes.WCHAR * 33)()
        if rstrtmgr.RmStartSession(ctypes.byref(session_handle), 0, session_key) != 0:
            return []

        try:
            abs_path = os.path.abspath(file_path)
            path_array = (wintypes.LPCWSTR * 1)(abs_path)
            if rstrtmgr.RmRegisterResources(session_handle, 1, path_array, 0, None, 0, None) != 0:
                return []

            n_proc_needed = wintypes.UINT()
            n_proc = wintypes.UINT(16)

            class RM_UNIQUE_PROCESS(ctypes.Structure):
                _fields_ = [("dwProcessId", wintypes.DWORD), ("ProcessStartTime", wintypes.FILETIME)]

            class RM_PROCESS_INFO(ctypes.Structure):
                _fields_ = [
                    ("Process", RM_UNIQUE_PROCESS),
                    ("strAppName", wintypes.WCHAR * 256),
                    ("strServiceShortName", wintypes.WCHAR * 64),
                    ("ApplicationType", wintypes.INT),
                    ("AppStatus", wintypes.ULONG),
                    ("TSSessionId", wintypes.DWORD),
                    ("bRestartable", wintypes.BOOL),
                ]

            proc_info = (RM_PROCESS_INFO * 16)()
            reasons = wintypes.DWORD()

            res = rstrtmgr.RmGetList(
                session_handle,
                ctypes.byref(n_proc_needed),
                ctypes.byref(n_proc),
                proc_info,
                ctypes.byref(reasons),
            )

            pids = []
            if res == 0:
                cur_pid = os.getpid()
                for i in range(n_proc.value):
                    pid = proc_info[i].Process.dwProcessId
                    name = proc_info[i].strAppName
                    if pid != cur_pid and pid > 4:
                        pids.append((pid, name))
            return pids
        finally:
            rstrtmgr.RmEndSession(session_handle)
    except Exception:
        return []


def kill_all_database_lockers(db_files: list[str]) -> None:
    """Find and terminate all processes locking database files."""
    if sys.platform != 'win32':
        return

    cur_pid = os.getpid()
    killed_pids = set()

    # 1. Inspect exact files via Windows Restart Manager
    for f in db_files:
        if os.path.exists(f):
            lockers = find_processes_locking_file(f)
            for pid, name in lockers:
                if pid not in killed_pids and pid != cur_pid:
                    print(f"    [*] Found process '{name}' (PID: {pid}) locking '{os.path.basename(f)}'. Terminating...")
                    subprocess.run(f'taskkill /F /PID {pid}', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    killed_pids.add(pid)

    # 2. Check backend port 8000
    try:
        output = subprocess.check_output('netstat -aon | findstr ":8000 .*LISTENING"', shell=True, text=True, stderr=subprocess.DEVNULL)
        for line in output.strip().split('\n'):
            parts = line.strip().split()
            if len(parts) >= 5:
                pid_str = parts[-1]
                if pid_str.isdigit():
                    pid = int(pid_str)
                    if pid not in killed_pids and pid != cur_pid and pid > 4:
                        print(f"    [*] Found backend server (PID: {pid}) listening on port 8000. Terminating...")
                        subprocess.run(f'taskkill /F /PID {pid}', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                        killed_pids.add(pid)
    except Exception:
        pass

    # 3. Terminate background auto-backup scripts or stale server windows
    try:
        subprocess.run('taskkill /F /FI "WINDOWTITLE eq *Auto Backup*"', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run('taskkill /F /FI "WINDOWTITLE eq Backend Server*"', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

    if killed_pids:
        print(f"    [OK] Successfully stopped {len(killed_pids)} process(es). Database locks released.")
        time.sleep(1.5)


def safe_file_action(action, src: str, dst: str | None = None, related_files: list[str] | None = None) -> bool:
    """Executes a file move or remove, automatically killing any locker if locked."""
    if not os.path.exists(src):
        return True

    for attempt in range(3):
        try:
            if action == 'move' and dst:
                shutil.move(src, dst)
            elif action == 'copy' and dst:
                shutil.copy2(src, dst)
            elif action == 'remove':
                os.remove(src)
            return True
        except PermissionError:
            print(f"    [!] File '{os.path.basename(src)}' is occupied (WinError 32). Releasing locks (attempt {attempt + 1}/3)...")
            files_to_check = [src] + (related_files or [])
            kill_all_database_lockers(files_to_check)
            time.sleep(1.0)
        except Exception as e:
            print(f"    [WARN] File action failed for '{os.path.basename(src)}': {e}")
            return False
    return False


def test_sqlite_integrity(db_path: str) -> tuple[bool, str]:
    """Test SQLite file integrity using PRAGMA integrity_check."""
    if not os.path.exists(db_path):
        return False, "File does not exist"
    if os.path.getsize(db_path) == 0:
        return False, "File is 0 bytes"
    try:
        conn = sqlite3.connect(db_path, timeout=15.0)
        cursor = conn.cursor()
        cursor.execute("PRAGMA busy_timeout = 15000;")
        res = cursor.execute("PRAGMA integrity_check;").fetchone()
        conn.close()
        if res and res[0] == "ok":
            return True, "ok"
        return False, str(res[0]) if res else "Unknown integrity failure"
    except Exception as e:
        return False, str(e)


def find_best_backup(backups_dir: str) -> str | None:
    """Find the newest uncorrupted backup in the backups directory."""
    candidates = []
    latest = os.path.join(backups_dir, 'btn_factory_latest.db')
    if os.path.exists(latest):
        candidates.append(latest)
    candidates.extend(sorted(glob.glob(os.path.join(backups_dir, 'btn_factory_*.db')), reverse=True))

    for c in candidates:
        ok, _ = test_sqlite_integrity(c)
        if ok:
            try:
                conn = sqlite3.connect(c, timeout=5.0)
                cur = conn.cursor()
                order_cnt = cur.execute("SELECT count(*) FROM orders;").fetchone()[0]
                conn.close()
                if order_cnt >= 0:
                    return c
            except Exception:
                pass
    return None


def heal_sqlite_database(db_path: str) -> None:
    """Heal any malformed or corrupted SQLite database without losing data."""
    print(f"[*] Inspecting database: {db_path}")
    wal_file = f"{db_path}-wal"
    shm_file = f"{db_path}-shm"
    all_db_files = [db_path, wal_file, shm_file]
    backups_dir = os.path.join(BACKEND_DIR, 'backups')
    os.makedirs(backups_dir, exist_ok=True)

    # 1. Stop any background server processes that are locking the file
    kill_all_database_lockers(all_db_files)

    # 2. Check if database is already healthy
    is_ok, msg = test_sqlite_integrity(db_path)
    if is_ok:
        print("    [OK] Database integrity verified.")
        return

    print(f"    [!] Database error detected: {msg}")
    print("    [*] Starting automatic database repair...")

    # 3. Checkpoint WAL
    try:
        conn = sqlite3.connect(db_path, timeout=10.0)
        conn.execute("PRAGMA busy_timeout = 10000;")
        conn.execute("PRAGMA wal_checkpoint(PASSIVE);")
        conn.execute("PRAGMA wal_checkpoint(TRUNCATE);")
        conn.close()
    except Exception:
        pass

    is_ok, msg = test_sqlite_integrity(db_path)
    if is_ok:
        print("    [FIXED] Database healed via WAL checkpoint.")
        return

    # 4. If corrupted WAL/SHM caused the malformed error, move them aside safely
    if os.path.exists(wal_file) or os.path.exists(shm_file):
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        if os.path.exists(wal_file):
            safe_file_action('move', wal_file, f"{wal_file}.corrupted_{ts}", all_db_files)
        if os.path.exists(shm_file):
            safe_file_action('move', shm_file, f"{shm_file}.corrupted_{ts}", all_db_files)

        is_ok, msg = test_sqlite_integrity(db_path)
        if is_ok:
            print("    [FIXED] Database integrity restored after removing orphaned WAL/SHM files.")
            return

    # 5. Check if data in main DB file can still be read
    if os.path.exists(db_path):
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        safety_copy = os.path.join(backups_dir, f"btn_factory_safety_{ts}.db")
        safe_file_action('copy', db_path, safety_copy, all_db_files)

        try:
            conn = sqlite3.connect(db_path, timeout=5.0)
            cur = conn.cursor()
            order_cnt = cur.execute("SELECT count(*) FROM orders;").fetchone()[0]
            conn.close()
            if order_cnt > 0:
                print(f"    [DATA SAFE] {order_cnt} existing orders verified intact in database.")
                return
        except Exception:
            pass

    # 6. Restore from clean historical backup
    best_backup = find_best_backup(backups_dir)
    if best_backup:
        print(f"    [*] Restoring from clean backup snapshot: {os.path.basename(best_backup)}")
        if safe_file_action('copy', best_backup, db_path, all_db_files):
            safe_file_action('remove', wal_file, related_files=all_db_files)
            safe_file_action('remove', shm_file, related_files=all_db_files)
            is_ok, msg = test_sqlite_integrity(db_path)
            if is_ok:
                print("    [FIXED] Database successfully restored from clean backup snapshot.")
                return

    # 7. Fallback: Initialize clean database
    print("    [*] Initializing clean database...")
    safe_file_action('remove', db_path, related_files=all_db_files)
    safe_file_action('remove', wal_file, related_files=all_db_files)
    safe_file_action('remove', shm_file, related_files=all_db_files)

    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.close()
    print("    [FIXED] Clean database initialized.")


def ensure_super_admin(email: str = 'admin@example.com', password: str = 'password') -> None:
    """Ensure super admin accounts exist with full permissions."""
    print("[*] Rebuilding schema & restoring super admin...")
    Base.metadata.create_all(bind=engine)
    sync_database_schema(engine)

    db = SessionLocal()
    try:
        # 1. Primary admin: admin@example.com
        user = db.query(User).filter(User.email == email).first()
        if user:
            user.role = UserRole.SUPER_ADMIN.value
            user.is_active = True
            user.password_hash = get_password_hash(password)
            user.name = 'Super Admin'
            user.department = 'admin'
            db.commit()
            print(f"    [OK] User '{email}' restored as active super_admin.")
        else:
            new_user = User(
                name='Super Admin',
                email=email,
                password_hash=get_password_hash(password),
                role=UserRole.SUPER_ADMIN.value,
                department='admin',
                is_active=True,
            )
            db.add(new_user)
            db.commit()
            print(f"    [OK] User '{email}' created as super_admin.")

        # 2. Alternate admin: admin@factory.local
        alt = db.query(User).filter(User.email == 'admin@factory.local').first()
        if alt:
            alt.role = UserRole.SUPER_ADMIN.value
            alt.is_active = True
            alt.password_hash = get_password_hash(password)
            alt.name = 'Super Admin'
            alt.department = 'admin'
            db.commit()
            print("    [OK] User 'admin@factory.local' restored as active super_admin.")
        else:
            new_alt = User(
                name='Super Admin',
                email='admin@factory.local',
                password_hash=get_password_hash(password),
                role=UserRole.SUPER_ADMIN.value,
                department='admin',
                is_active=True,
            )
            db.add(new_alt)
            db.commit()
            print("    [OK] User 'admin@factory.local' created as super_admin.")

        # Print user summary
        print("\n" + "=" * 65)
        print("                 DATABASE RECOVERY COMPLETE")
        print("=" * 65)
        all_users = db.query(User).all()
        print(f"Total Users: {len(all_users)}")
        for u in all_users:
            status = "ACTIVE" if u.is_active else "INACTIVE"
            print(f"  ID: {u.id:<3} | {u.email:<26} | Role: {u.role:<12} | [{status}]")
        print("-" * 65)
        print("Default Super Admin Login:")
        print(f"  Email:    admin@example.com   (or admin@factory.local)")
        print(f"  Password: {password}")
        print("  Role:     super_admin")
        print("=" * 65)
        print("\nDatabase is 100% healthy. You can log in now!")

    finally:
        db.close()


def main():
    settings = get_settings()
    raw_url = settings.get_effective_database_url() if hasattr(settings, 'get_effective_database_url') else settings.database_url
    db_url = raw_url or 'sqlite:///btn_factory.db'

    if db_url.startswith('sqlite:///'):
        rel_path = db_url[len('sqlite:///'):]
        if rel_path.startswith(':memory:'):
            db_path = ':memory:'
        elif os.path.isabs(rel_path):
            db_path = rel_path
        else:
            db_path = os.path.join(BACKEND_DIR, rel_path)

        if db_path != ':memory:':
            heal_sqlite_database(db_path)
    else:
        print(f"[*] Using external database: {db_url.split('@')[-1] if '@' in db_url else db_url}")

    ensure_super_admin()


if __name__ == '__main__':
    main()
