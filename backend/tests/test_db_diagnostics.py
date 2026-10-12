from fastapi.testclient import TestClient
from app.main import app
from scripts.test_db_connections import check_sqlite_connection, is_placeholder, mask_url


def test_mask_url():
    assert mask_url('postgresql://user:secret123@localhost:5432/db') == 'postgresql://user:******@localhost:5432/db'
    assert mask_url('sqlite:///./test.db') == 'sqlite:///./test.db'
    assert mask_url(None) == '(none)'


def test_is_placeholder():
    assert is_placeholder('postgresql://user:YOUR_NEON_PASSWORD@neon.tech/db') is True
    assert is_placeholder('postgresql://user:YOUR_LOCAL_PG_PASSWORD@localhost/db') is True
    assert is_placeholder('postgresql://postgres:realpassword123@localhost/btn_factory') is False


def test_sqlite_in_memory_connection():
    res = check_sqlite_connection('sqlite:///:memory:')
    assert res['status'] == 'CONNECTED'
    assert res['tier'] == 'Tier 1: SQLite'


def test_diagnostics_endpoint():
    client = TestClient(app)
    res = client.get('/api/diagnostics/databases')
    assert res.status_code == 200
    data = res.json()
    assert 'active_tier' in data
    assert 'tiers' in data
    assert 'sqlite' in data['tiers']
    assert data['tiers']['sqlite']['status'] == 'CONNECTED'
