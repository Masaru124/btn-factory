import os
import sqlite3
import pytest

from scripts.fix_and_restore_admin import check_sqlite_integrity, deep_salvage_sqlite_database, heal_sqlite_database


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
