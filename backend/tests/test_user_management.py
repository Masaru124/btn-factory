import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base, get_db
from app.core.security import get_password_hash
from app.main import app
from app.models.user import User, UserRole

from sqlalchemy.pool import StaticPool

TEST_DB_URL = "sqlite:///:memory:"
test_engine = create_engine(TEST_DB_URL, connect_args={"check_same_thread": False}, poolclass=StaticPool)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture(scope="module", autouse=True)
def setup_db():
    app.dependency_overrides[get_db] = override_get_db
    Base.metadata.create_all(bind=test_engine)
    db = TestingSessionLocal()
    admin = User(
        name="Super Admin",
        email="admin@example.com",
        password_hash=get_password_hash("password"),
        role=UserRole.SUPER_ADMIN.value,
        department="admin",
        is_active=True,
    )
    db.add(admin)
    db.commit()
    db.close()
    yield
    Base.metadata.drop_all(bind=test_engine)
    app.dependency_overrides.clear()


def test_auth_and_user_crud():
    client = TestClient(app)

    # 1. Login with case-insensitive email
    res = client.post("/api/auth/login", json={"email": "Admin@Example.com", "password": "password"})
    assert res.status_code == 200, res.text
    token = res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Register new superadmin
    res = client.post(
        "/api/auth/register",
        json={
            "name": "Second Super Admin",
            "email": "SecondAdmin@Factory.local",
            "password": "supersecretpassword",
            "role": "super_admin",
            "department": "admin",
        },
        headers=headers,
    )
    assert res.status_code == 200, res.text
    new_admin_id = res.json()["id"]

    # 3. Login with newly registered superadmin
    res = client.post("/api/auth/login", json={"email": "secondadmin@factory.local", "password": "supersecretpassword"})
    assert res.status_code == 200, res.text
    new_token = res.json()["access_token"]
    new_headers = {"Authorization": f"Bearer {new_token}"}

    # 4. Change password using /change-password
    res = client.post(
        "/api/auth/change-password",
        json={"current_password": "supersecretpassword", "new_password": "brandnewpassword"},
        headers=new_headers,
    )
    assert res.status_code == 200, res.text

    # 5. Verify old password fails and new password succeeds
    res_fail = client.post("/api/auth/login", json={"email": "secondadmin@factory.local", "password": "supersecretpassword"})
    assert res_fail.status_code == 401

    res_ok = client.post("/api/auth/login", json={"email": "secondadmin@factory.local", "password": "brandnewpassword"})
    assert res_ok.status_code == 200

    # 6. Update user details & reset password via PUT /users/{id}
    res = client.put(
        f"/api/auth/users/{new_admin_id}",
        json={"name": "Updated Admin Name", "password": "resetbyadminpass"},
        headers=headers,
    )
    assert res.status_code == 200, res.text
    assert res.json()["name"] == "Updated Admin Name"

    # Login with reset password
    res = client.post("/api/auth/login", json={"email": "secondadmin@factory.local", "password": "resetbyadminpass"})
    assert res.status_code == 200

    # 7. Self-deactivation prevention
    res = client.delete("/api/auth/users/1", headers=headers)
    assert res.status_code == 400
    assert "Cannot deactivate your own" in res.json()["detail"]
