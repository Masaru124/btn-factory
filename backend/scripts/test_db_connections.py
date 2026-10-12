"""Button Factory MES - 3-Tier Multi-Database Diagnostic & Connection Tester.

Tests connectivity, latency, schema readiness, and server versions across all 3 tiers:
  1. Tier 1: Local SQLite (Embedded Edge / Offline Fallback)
  2. Tier 2: Local PostgreSQL (On-Premises Main Manufacturing DB)
  3. Tier 3: Neon Serverless PostgreSQL (Cloud DR Replica / Backup)

Usage:
  python scripts/test_db_connections.py
"""

import os
import sys
import time
from urllib.parse import urlparse

from sqlalchemy import create_engine, inspect, text

# Add backend directory to path if running directly
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import get_settings


def mask_url(url: str | None) -> str:
    """Mask password inside connection URI for safe console display."""
    if not url:
        return '(none)'
    try:
        parsed = urlparse(url)
        if parsed.password:
            masked = url.replace(f':{parsed.password}@', ':******@')
            return masked
        return url
    except Exception:
        return '***'


def is_placeholder(url: str | None) -> bool:
    if not url:
        return True
    lower = url.lower()
    placeholders = ['your_neon_password', 'your_local_pg_password', 'password_here', 'sample-123456']
    return any(p in lower for p in placeholders)


def check_sqlite_connection(url: str) -> dict:
    start = time.perf_counter()
    res = {
        'tier': 'Tier 1: SQLite',
        'type': 'SQLite (Local Embedded / Offline Fallback)',
        'url': mask_url(url),
        'status': 'UNKNOWN',
        'latency_ms': 0.0,
        'details': '',
    }
    try:
        engine = create_engine(url, connect_args={'timeout': 10})
        with engine.connect() as conn:
            ver = conn.execute(text('SELECT sqlite_version();')).scalar()
            journal = conn.execute(text('PRAGMA journal_mode;')).scalar()
            inspector = inspect(engine)
            tables = inspector.get_table_names()
            order_count = 0
            if 'orders' in tables:
                order_count = conn.execute(text('SELECT COUNT(*) FROM orders;')).scalar()

        elapsed = (time.perf_counter() - start) * 1000
        res['status'] = 'CONNECTED'
        res['latency_ms'] = round(elapsed, 2)
        res['details'] = f'SQLite v{ver} | WAL Mode: {str(journal).upper()} | Tables: {len(tables)} | Orders: {order_count}'
    except Exception as e:
        elapsed = (time.perf_counter() - start) * 1000
        res['status'] = 'FAILED'
        res['latency_ms'] = round(elapsed, 2)
        res['details'] = f'Error: {e}'
    return res


def check_postgres_connection(url: str | None, label: str, tier_name: str) -> dict:
    start = time.perf_counter()
    res = {
        'tier': tier_name,
        'type': label,
        'url': mask_url(url),
        'status': 'UNKNOWN',
        'latency_ms': 0.0,
        'details': '',
    }

    if not url or is_placeholder(url):
        res['status'] = 'UNCONFIGURED'
        res['details'] = 'Not configured or placeholder secrets in .env'
        return res

    # Ensure Neon or cloud URLs have sslmode=require
    test_url = url
    if 'neon.tech' in test_url and 'sslmode' not in test_url:
        sep = '&' if '?' in test_url else '?'
        test_url = f'{test_url}{sep}sslmode=require'

    # Support either psycopg2 or psycopg 3 seamlessly
    if test_url.startswith('postgresql://') or test_url.startswith('postgres://'):
        try:
            import psycopg2  # type: ignore # noqa: F401
            test_url = test_url.replace('postgres://', 'postgresql://', 1)
        except ImportError:
            try:
                import psycopg  # type: ignore # noqa: F401
                test_url = test_url.replace('postgresql://', 'postgresql+psycopg://', 1).replace('postgres://', 'postgresql+psycopg://', 1)
            except ImportError:
                pass

    try:
        # Connect with short connect_timeout for responsive feedback
        connect_args = {'connect_timeout': 8}
        engine = create_engine(test_url, connect_args=connect_args)
        with engine.connect() as conn:
            ver_raw = conn.execute(text('SELECT version();')).scalar()
            ver = str(ver_raw).split(',')[0].strip() if ver_raw else 'PostgreSQL'
            inspector = inspect(engine)
            tables = inspector.get_table_names()
            order_count = 0
            if 'orders' in tables:
                order_count = conn.execute(text('SELECT COUNT(*) FROM orders;')).scalar()

        elapsed = (time.perf_counter() - start) * 1000
        res['status'] = 'CONNECTED'
        res['latency_ms'] = round(elapsed, 2)
        res['details'] = f'{ver} | Tables: {len(tables)} | Orders: {order_count}'
    except Exception as e:
        elapsed = (time.perf_counter() - start) * 1000
        res['status'] = 'FAILED'
        res['latency_ms'] = round(elapsed, 2)
        err_msg = str(e).strip()
        if 'could not translate host name' in err_msg.lower():
            res['details'] = 'DNS resolution failed - Check hostname / internet connection'
        elif 'password authentication failed' in err_msg.lower():
            res['details'] = 'Authentication failed - Invalid username or password in .env'
        elif 'connection refused' in err_msg.lower():
            res['details'] = 'Connection refused - Local PostgreSQL service is not running on port'
        elif 'database' in err_msg.lower() and 'does not exist' in err_msg.lower():
            res['details'] = 'Database does not exist - Create database with `createdb` first'
        else:
            res['details'] = f'Error: {err_msg[:120]}'
    return res


def main():
    print('=' * 80)
    print('  BUTTON FACTORY MES - 3-TIER MULTI-DATABASE CONNECTION TESTER')
    print('=' * 80)

    settings = get_settings()
    print(f'Active Primary DB Tier : {settings.active_db_tier.upper()}')
    print(f'Effective Database URL : {mask_url(settings.get_effective_database_url())}')
    print('-' * 80)

    results = []

    # 1. Test Tier 1: SQLite
    sqlite_url = settings.sqlite_database_url or settings.database_url or 'sqlite:///./btn_factory.db'
    print(f'\n[1/3] Testing {mask_url(sqlite_url)}...')
    r1 = check_sqlite_connection(sqlite_url)
    results.append(r1)

    # 2. Test Tier 2: Local PostgreSQL
    local_pg = settings.local_postgres_url or settings.postgres_database_url
    print(f'[2/3] Testing Local PostgreSQL: {mask_url(local_pg)}...')
    r2 = check_postgres_connection(local_pg, 'Local PostgreSQL (On-Premises)', 'Tier 2: Local Postgres')
    results.append(r2)

    # 3. Test Tier 3: Neon Serverless Cloud PostgreSQL
    neon_pg = settings.neon_database_url
    print(f'[3/3] Testing Neon Cloud Serverless: {mask_url(neon_pg)}...')
    r3 = check_postgres_connection(neon_pg, 'Neon Serverless Cloud (DR Backup)', 'Tier 3: Neon Cloud')
    results.append(r3)

    print('\n' + '=' * 80)
    print(f"{'TIER':<24} | {'STATUS':<12} | {'LATENCY':<10} | {'DETAILS'}")
    print('-' * 80)

    for r in results:
        status_symbol = {
            'CONNECTED': '[PASS]  CONNECTED',
            'UNCONFIGURED': '[INFO]  UNCONFIGURED',
            'FAILED': '[FAIL]  FAILED',
        }.get(r['status'], r['status'])

        latency = f"{r['latency_ms']} ms" if r['latency_ms'] > 0 else 'N/A'
        print(f"{r['tier']:<24} | {status_symbol:<12} | {latency:<10} | {r['details']}")

    print('=' * 80)
    print('\nHOW TO CONFIGURE CREDENTIALS:')
    print('  1. Open backend/.env in your editor.')
    print('  2. For Local PostgreSQL, set LOCAL_POSTGRES_URL with your username & password.')
    print('  3. For Neon DB, paste your connection string into NEON_DATABASE_URL.')
    print('  4. Set ACTIVE_DB_TIER to sqlite, postgres, or neon to switch active operation.')
    print('  5. Re-run this test: python scripts/test_db_connections.py\n')


if __name__ == '__main__':
    main()
