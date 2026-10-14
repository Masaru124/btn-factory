"""Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.

Features:
  1. Safe Local Hot Snapshot:
     - Creates timestamped SQLite backups in backend/backups/.
     - Safely handles SQLite WAL and SHM journal files.
     - Retention policy: Automatically retains the latest 20 snapshots.
  2. Cloud Disaster Recovery Sync (Neon Serverless PostgreSQL):
     - Synchronizes tables and records from local DB into Neon PostgreSQL.
     - Upserts users, orders, processes, and raw materials.
  3. Non-blocking / Thread-Safe:
     - Runs on server launch and scheduled intervals without interrupting API calls.
"""

import os
import shutil
import sqlite3
import threading
import time
from datetime import datetime, timezone
import logging
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import sessionmaker

from app.core.config import get_settings
from app.core.database import Base, normalize_database_url
import app.models  # Ensure all model classes are registered with Base.metadata

logger = logging.getLogger('backup_service')


class BackupService:
    def __init__(self, backend_dir: str | None = None):
        self.settings = get_settings()
        if not backend_dir:
            backend_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        self.backend_dir = backend_dir
        self.backups_dir = os.path.join(self.backend_dir, 'backups')
        os.makedirs(self.backups_dir, exist_ok=True)

    def create_local_snapshot(self) -> dict:
        """Create a safe timestamped copy of the local SQLite database."""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        db_path = os.path.join(self.backend_dir, 'btn_factory.db')

        if not os.path.exists(db_path):
            return {'status': 'SKIPPED', 'message': f'Local SQLite file not found at {db_path}'}

        snapshot_name = f'btn_factory_{timestamp}.db'
        snapshot_path = os.path.join(self.backups_dir, snapshot_name)

        try:
            # Use SQLite backup API if possible for online hot consistency
            src_conn = sqlite3.connect(db_path)
            dst_conn = sqlite3.connect(snapshot_path)
            with dst_conn:
                src_conn.backup(dst_conn, pages=100)
            dst_conn.close()
            src_conn.close()

            # Rotate old backups - keep latest 20
            self._prune_old_snapshots(keep=20)

            size_kb = round(os.path.getsize(snapshot_path) / 1024, 2)
            logger.info('Created local snapshot: %s (%s KB)', snapshot_name, size_kb)
            return {
                'status': 'SUCCESS',
                'file': snapshot_name,
                'path': snapshot_path,
                'size_kb': size_kb,
                'timestamp': timestamp,
            }
        except Exception as e:
            logger.error('Failed to create local snapshot: %s', e)
            # Fallback to copy
            try:
                shutil.copy2(db_path, snapshot_path)
                return {'status': 'SUCCESS_COPY', 'file': snapshot_name, 'path': snapshot_path}
            except Exception as copy_err:
                return {'status': 'FAILED', 'error': str(copy_err)}

    def _prune_old_snapshots(self, keep: int = 20) -> None:
        """Keep only the latest N snapshot files."""
        try:
            files = [
                os.path.join(self.backups_dir, f)
                for f in os.listdir(self.backups_dir)
                if f.startswith('btn_factory_') and f.endswith('.db')
            ]
            files.sort(key=os.path.getctime, reverse=True)
            for old_file in files[keep:]:
                try:
                    os.remove(old_file)
                except OSError:
                    pass
        except Exception as e:
            logger.warning('Error pruning old snapshots: %s', e)

    def sync_to_postgres(self, raw_url: str | None, target_name: str = 'PostgreSQL') -> dict:
        """Sync schema and data from local database to a PostgreSQL target (Local Postgres or Neon Cloud)."""
        if not raw_url:
            return {'status': 'SKIPPED', 'message': f'{target_name} URL not configured'}

        # Ensure sslmode=require for Neon Cloud
        target_url = raw_url
        if 'neon.tech' in target_url and 'sslmode' not in target_url:
            sep = '&' if '?' in target_url else '?'
            target_url = f'{target_url}{sep}sslmode=require'

        norm_url = normalize_database_url(target_url)

        try:
            pg_engine = create_engine(norm_url, connect_args={'connect_timeout': 10}, pool_pre_ping=True)
            # 1. Ensure all tables exist in target PostgreSQL
            Base.metadata.create_all(bind=pg_engine)

            # 2. Sync core tables
            local_db_path = os.path.join(self.backend_dir, 'btn_factory.db')
            if not os.path.exists(local_db_path):
                return {'status': 'SKIPPED', 'message': 'Local database file not found for sync'}

            local_conn = sqlite3.connect(local_db_path)
            local_conn.row_factory = sqlite3.Row
            cursor = local_conn.cursor()

            # Tables to sync in dependency order
            tables_to_sync = [
                'users',
                'orders',
                'universal_raw_materials',
                'raw_materials',
                'casting_process',
                'blanking_process',
                'turning_process',
                'polishing_process',
                'packing_process',
                'token_counter',
            ]

            synced_counts = {}
            with pg_engine.connect() as remote_conn:
                for table in tables_to_sync:
                    try:
                        # Check if table exists in local DB
                        cursor.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table}'")
                        if not cursor.fetchone():
                            continue

                        rows = cursor.execute(f'SELECT * FROM {table}').fetchall()
                        if not rows:
                            synced_counts[table] = 0
                            continue

                        # Inspect columns
                        cols = rows[0].keys()
                        col_names = ', '.join([f'"{c}"' for c in cols])
                        placeholders = ', '.join([f':{c}' for c in cols])

                        # Build PostgreSQL UPSERT (ON CONFLICT DO NOTHING or UPDATE)
                        pk = 'token' if table == 'token_counter' else 'id'
                        if pk in cols:
                            update_cols = [f'"{c}" = EXCLUDED."{c}"' for c in cols if c != pk]
                            update_stmt = ', '.join(update_cols) if update_cols else ''
                            if update_stmt:
                                sql = f'INSERT INTO "{table}" ({col_names}) VALUES ({placeholders}) ON CONFLICT ("{pk}") DO UPDATE SET {update_stmt}'
                            else:
                                sql = f'INSERT INTO "{table}" ({col_names}) VALUES ({placeholders}) ON CONFLICT ("{pk}") DO NOTHING'
                        else:
                            sql = f'INSERT INTO "{table}" ({col_names}) VALUES ({placeholders}) ON CONFLICT DO NOTHING'

                        # Sanitize data types (e.g. SQLite integer booleans to python bool)
                        table_obj = Base.metadata.tables.get(table)
                        data = []
                        for r in rows:
                            row_dict = dict(r)
                            for k, v in row_dict.items():
                                if v is None:
                                    continue
                                is_bool = False
                                if table_obj is not None and k in table_obj.columns:
                                    try:
                                        is_bool = table_obj.columns[k].type.python_type is bool
                                    except Exception:
                                        is_bool = k.startswith('is_')
                                else:
                                    is_bool = k.startswith('is_')
                                if is_bool:
                                    row_dict[k] = bool(v)
                            data.append(row_dict)

                        # Execute batch upsert in dedicated transaction
                        with remote_conn.begin():
                            remote_conn.execute(text(sql), data)
                        synced_counts[table] = len(data)
                    except Exception as tbl_err:
                        logger.warning('Could not sync table %s to %s: %s', table, target_name, tbl_err)

            local_conn.close()
            logger.info('%s backup sync complete: %s', target_name, synced_counts)
            return {'status': 'SUCCESS', 'target': target_name, 'synced': synced_counts}

        except Exception as e:
            logger.error('%s sync failed: %s', target_name, e)
            return {'status': 'FAILED', 'target': target_name, 'error': str(e)}

    def sync_to_local_postgres(self) -> dict:
        """Sync schema and data from local database to on-premises Local PostgreSQL."""
        return self.sync_to_postgres(self.settings.local_postgres_url, target_name='Local PostgreSQL')

    def sync_to_neon(self) -> dict:
        """Sync schema and data from local database to Neon Cloud PostgreSQL."""
        return self.sync_to_postgres(self.settings.neon_database_url, target_name='Neon Cloud')

    def run_full_backup(self) -> dict:
        """Run local snapshot creation, Local Postgres sync, and Neon cloud sync."""
        start = time.perf_counter()
        snapshot_res = self.create_local_snapshot()
        local_pg_res = self.sync_to_local_postgres()
        neon_res = self.sync_to_neon()
        elapsed = round((time.perf_counter() - start) * 1000, 2)

        summary = {
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'elapsed_ms': elapsed,
            'local_snapshot': snapshot_res,
            'local_postgres_sync': local_pg_res,
            'neon_cloud_sync': neon_res,
        }

        # Write to backup log
        log_file = os.path.join(self.backups_dir, 'backup.log')
        try:
            with open(log_file, 'a', encoding='utf-8') as f:
                f.write(
                    f"[{datetime.now().isoformat()}] Snapshot: {snapshot_res.get('status')} | Local PG: {local_pg_res.get('status')} | Neon Sync: {neon_res.get('status')} ({elapsed}ms)\n"
                )
        except Exception:
            pass

        return summary


def run_background_backup():
    """Helper to launch backup in a separate thread so it never blocks startup."""
    def _worker():
        try:
            service = BackupService()
            service.run_full_backup()
        except Exception as e:
            logger.warning('Background backup task error: %s', e)

    t = threading.Thread(target=_worker, daemon=True, name='DbAutoBackupWorker')
    t.start()
