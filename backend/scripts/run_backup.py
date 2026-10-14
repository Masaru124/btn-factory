"""Button Factory MES - Automated Multi-Tier Backup & Cloud Sync Runner."""

import os
import sys

# Ensure backend root is in sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.services.backup_service import BackupService


def main():
    print('=' * 80)
    print('  BUTTON FACTORY MES - AUTOMATED MULTI-TIER BACKUP & SYNC')
    print('=' * 80)

    service = BackupService()
    print('Executing local hot snapshot and cloud disaster-recovery sync...')
    res = service.run_full_backup()

    print('-' * 80)
    snapshot = res.get('local_snapshot', {})
    if snapshot.get('status') in ['SUCCESS', 'SUCCESS_COPY']:
        print(f"[PASS] Local SQLite Snapshot : {snapshot.get('file')} ({snapshot.get('size_kb', 0)} KB)")
        print(f"       Saved to              : {snapshot.get('path')}")
    else:
        print(f"[WARN] Local Snapshot        : {snapshot.get('status')} - {snapshot.get('message') or snapshot.get('error')}")

    local_pg = res.get('local_postgres_sync', {})
    if local_pg.get('status') == 'SUCCESS':
        print(f"[PASS] Local PostgreSQL Sync : CONNECTED & SYNCED")
        synced = local_pg.get('synced', {})
        for tbl, count in synced.items():
            if count > 0:
                print(f'       - {tbl:<24} : {count} rows synced')
    elif local_pg.get('status') == 'SKIPPED':
        print(f"[INFO] Local PostgreSQL Sync : SKIPPED ({local_pg.get('message')})")
    else:
        print(f"[WARN] Local PostgreSQL Sync : FAILED ({local_pg.get('error')})")

    neon = res.get('neon_cloud_sync', {})
    if neon.get('status') == 'SUCCESS':
        print(f"[PASS] Neon Cloud DR Sync    : CONNECTED & SYNCED")
        synced = neon.get('synced', {})
        for tbl, count in synced.items():
            if count > 0:
                print(f'       - {tbl:<24} : {count} rows synced')
    elif neon.get('status') == 'SKIPPED':
        print(f"[INFO] Neon Cloud DR Sync    : SKIPPED ({neon.get('message')})")
    else:
        print(f"[WARN] Neon Cloud DR Sync    : FAILED ({neon.get('error')})")

    print('-' * 80)
    print(f"Total Elapsed Time : {res.get('elapsed_ms')} ms")
    print('=' * 80)


if __name__ == '__main__':
    main()
