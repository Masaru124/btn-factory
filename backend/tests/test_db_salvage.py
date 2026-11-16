import os
import sqlite3
import pytest

from scripts.fix_and_restore_admin import (
    check_sqlite_integrity,
    deep_salvage_sqlite_database,
    heal_sqlite_database,
    merge_missing_records_from_backups,
)


def test_sqlite_salvage_mechanism(tmp_path):
    db_file = str(tmp_path / "test_corrupt.db")

    # 1. Create a database with multiple tables and records
    conn = sqlite3.connect(db_file)
    conn.execute("CREATE TABLE orders (id INTEGER PRIMARY KEY, token TEXT, customer_name TEXT);")
    conn.execute("CREATE TABLE blanking_process (id INTEGER PRIMARY KEY, order_id INTEGER, weight REAL, remarks TEXT);")
    conn.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT, role TEXT);")
    conn.execute("CREATE INDEX idx_blanking_order ON blanking_process(order_id);")

    conn.execute("INSERT INTO orders VALUES (1, '1001', 'Customer A'), (2, '1002', 'Customer B'), (22, '1022', 'Customer 22');")
    conn.execute("INSERT INTO blanking_process VALUES (1, 1, 10.5, 'Ok'), (2, 2, 20.0, 'Good'), (3, 22, 15.2, 'Target 22');")
    conn.execute("INSERT INTO users VALUES (1, 'admin@example.com', 'super_admin');")
    conn.commit()
    conn.close()

    # Verify initial integrity
    ok, msg = check_sqlite_integrity(db_file)
    assert ok is True

    # 2. Test deep salvage on the database
    salvaged_path = str(tmp_path / "salvaged.db")
    res = deep_salvage_sqlite_database(db_file, salvaged_path)
    assert res is True
    assert os.path.exists(salvaged_path)

    # 3. Verify all records survived in salvaged database
    conn = sqlite3.connect(salvaged_path)
    orders = conn.execute("SELECT count(*) FROM orders;").fetchone()[0]
    blanking = conn.execute("SELECT count(*) FROM blanking_process;").fetchone()[0]
    users = conn.execute("SELECT count(*) FROM users;").fetchone()[0]
    # Check index exists
    idx = conn.execute("SELECT name FROM sqlite_master WHERE type='index' AND name='idx_blanking_order';").fetchone()
    conn.close()

    assert orders == 3
    assert blanking == 3
    assert users == 1
    assert idx is not None


def test_backup_merge_and_cleanup(tmp_path):
    backups_dir = str(tmp_path / "backups")
    os.makedirs(backups_dir, exist_ok=True)

    backup_file = os.path.join(backups_dir, "btn_factory_latest.db")
    target_file = str(tmp_path / "btn_factory.db")

    # 1. Create a historical backup containing order 22 and legitimate materials
    b_conn = sqlite3.connect(backup_file)
    b_conn.execute("CREATE TABLE orders (id INTEGER PRIMARY KEY, token TEXT, company_name TEXT);")
    b_conn.execute("CREATE TABLE blanking_process (id INTEGER PRIMARY KEY, order_id INTEGER, weight REAL);")
    b_conn.execute("CREATE TABLE raw_materials (id INTEGER PRIMARY KEY, material_name TEXT, quantity REAL, unit TEXT);")
    b_conn.execute("INSERT INTO orders VALUES (1, 'T1', 'Comp 1'), (22, 'T22', 'Comp 22');")
    b_conn.execute("INSERT INTO blanking_process VALUES (1, 1, 10.0), (22, 22, 15.5);")
    b_conn.execute("INSERT INTO raw_materials VALUES (1, 'RESIN GALAXY', 50.0, 'kg');")
    b_conn.commit()
    b_conn.close()

    # 2. Create target database missing order 22 and with rogue user in raw_materials
    t_conn = sqlite3.connect(target_file)
    t_conn.execute("CREATE TABLE orders (id INTEGER PRIMARY KEY, token TEXT, company_name TEXT);")
    t_conn.execute("CREATE TABLE blanking_process (id INTEGER PRIMARY KEY, order_id INTEGER, weight REAL);")
    t_conn.execute("CREATE TABLE raw_materials (id INTEGER PRIMARY KEY, material_name TEXT, quantity REAL, unit TEXT);")
    t_conn.execute("INSERT INTO orders VALUES (1, 'T1', 'Comp 1');")
    t_conn.execute("INSERT INTO blanking_process VALUES (1, 1, 10.0);")
    # Rogue user mistakenly inserted into raw_materials
    t_conn.execute("INSERT INTO raw_materials VALUES (1, 'abhit@fsbi.co.in', 0.0, 'turning');")
    t_conn.commit()
    t_conn.close()

    # 3. Run backup merge
    merge_missing_records_from_backups(target_file, backups_dir)

    # 4. Assert order 22 was restored from backup and rogue user row was purged
    conn = sqlite3.connect(target_file)
    orders = conn.execute("SELECT id, token FROM orders ORDER BY id;").fetchall()
    blanking = conn.execute("SELECT id, order_id FROM blanking_process ORDER BY id;").fetchall()
    materials = conn.execute("SELECT material_name, unit FROM raw_materials;").fetchall()
    conn.close()

    assert len(orders) == 2
    assert orders[1][0] == 22
    assert len(blanking) == 2
    assert blanking[1][1] == 22

    # Rogue email is gone, real material from backup is present
    material_names = [m[0] for m in materials]
    assert 'abhit@fsbi.co.in' not in material_names
    assert 'RESIN GALAXY' in material_names
