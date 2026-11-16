import os
import shutil
import sqlite3
import tempfile
import time
from app.core.config import Settings
from app.services.backup_service import BackupService, HourlyBackupScheduler


def test_custom_backup_and_media_paths(tmp_path):
    # Set up temporary directories
    fake_backend = tmp_path / "backend"
    fake_backend.mkdir()

    # Create dummy sqlite db with real sqlite structure
    db_file = fake_backend / "btn_factory.db"
    conn = sqlite3.connect(str(db_file))
    conn.execute("CREATE TABLE orders (id INTEGER PRIMARY KEY, customer_name TEXT);")
    conn.execute("INSERT INTO orders (customer_name) VALUES ('Acme Buttons');")
    conn.commit()
    conn.close()

    # Create dummy media folder and files
    fake_media = tmp_path / "custom_media"
    fake_media.mkdir()
    sub_folder = fake_media / "orders" / "2026" / "11"
    sub_folder.mkdir(parents=True)
    img_file = sub_folder / "sample_test_image.webp"
    img_file.write_bytes(b"RIFF\x00\x00\x00\x00WEBPVP8 ...")

    # Custom backup folder
    custom_backup_dir = tmp_path / "my_custom_backups"
    custom_backup_media_dir = custom_backup_dir / "media_archive"

    settings = Settings(
        media_dir=str(fake_media),
        backup_dir=str(custom_backup_dir),
        backup_media_dir=str(custom_backup_media_dir),
        backup_interval_minutes=30,
        database_url=f"sqlite:///{db_file}",
        sqlite_database_url=f"sqlite:///{db_file}",
    )

    # Initialize BackupService
    service = BackupService(backend_dir=str(fake_backend))
    service.settings = settings
    service.backups_dir = str(custom_backup_dir)
    service.media_dir = str(fake_media)
    service.backup_media_dir = str(custom_backup_media_dir)

    # 1. Test database snapshot
    snap_res = service.create_local_snapshot()
    assert snap_res["status"] in ("SUCCESS", "SUCCESS_COPY")
    assert os.path.exists(custom_backup_dir)
    assert os.path.exists(os.path.join(custom_backup_dir, snap_res["file"]))
    assert os.path.exists(os.path.join(custom_backup_dir, "btn_factory_latest.db"))

    # 2. Test media backup
    media_res = service.backup_media_files()
    assert media_res["status"] == "SUCCESS"
    assert media_res["files_copied"] == 1
    assert media_res["total_files"] == 1
    archived_file = custom_backup_media_dir / "orders" / "2026" / "11" / "sample_test_image.webp"
    assert archived_file.exists()
    assert archived_file.read_bytes() == img_file.read_bytes()

    # 3. Test incremental backup (no changes -> 0 copied, 1 skipped)
    media_res2 = service.backup_media_files()
    assert media_res2["status"] == "SUCCESS"
    assert media_res2["files_copied"] == 0
    assert media_res2["files_skipped"] == 1

    # 4. Test run_full_backup and log generation
    full_res = service.run_full_backup()
    assert "local_snapshot" in full_res
    assert "media_backup" in full_res
    log_file = os.path.join(custom_backup_dir, "backup.log")
    assert os.path.exists(log_file)
    with open(log_file, "r", encoding="utf-8") as f:
        log_content = f.read()
        assert "DB Snapshot:" in log_content
        assert "Media:" in log_content


def test_hourly_backup_scheduler_start_and_stop():
    HourlyBackupScheduler.stop()
    assert not HourlyBackupScheduler.is_running()

    # Start scheduler with small interval
    HourlyBackupScheduler.start(interval_minutes=60)
    time.sleep(0.3)
    assert HourlyBackupScheduler.is_running()

    # Stop scheduler
    HourlyBackupScheduler.stop()
    time.sleep(0.3)
    assert not HourlyBackupScheduler.is_running()
