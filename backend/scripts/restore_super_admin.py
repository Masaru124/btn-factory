"""
Restore / Reset Default Super Admin Account(s)
Usage: python scripts/restore_super_admin.py [--email <email>] [--password <password>] [--name <name>]
"""
import argparse
import os
import sys

# Ensure backend root is on sys.path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from app.core.database import Base, SessionLocal, engine
from app.core.security import get_password_hash
from app.models.user import User, UserRole


def restore_admin(email: str = 'admin@example.com', password: str = 'password', name: str = 'Super Admin') -> None:
    # Ensure database is healed from any corruption first
    try:
        from scripts.fix_and_restore_admin import heal_sqlite_database
        from app.core.config import get_settings
        settings = get_settings()
        raw_url = settings.get_effective_database_url() if hasattr(settings, 'get_effective_database_url') else settings.database_url
        if (raw_url or '').startswith('sqlite:///'):
            rel_path = raw_url[len('sqlite:///'):]
            if rel_path and not rel_path.startswith(':memory:'):
                db_path = rel_path if os.path.isabs(rel_path) else os.path.join(backend_dir, rel_path)
                heal_sqlite_database(db_path)
    except Exception as e:
        print(f"[NOTE] Pre-check note: {e}")

    # Ensure tables exist
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if user:
            print(f"[FOUND] User '{email}' exists in database.")
            user.role = UserRole.SUPER_ADMIN.value
            user.is_active = True
            user.password_hash = get_password_hash(password)
            user.name = name
            user.department = 'admin'
            db.commit()
            print(f"[UPDATED] User '{email}' restored as active super_admin with password '{password}'.")
        else:
            new_user = User(
                name=name,
                email=email,
                password_hash=get_password_hash(password),
                role=UserRole.SUPER_ADMIN.value,
                department='admin',
                is_active=True,
            )
            db.add(new_user)
            db.commit()
            print(f"[CREATED] Super admin account '{email}' created with password '{password}'.")

        # Also ensure admin@factory.local is available
        if email != 'admin@factory.local':
            alt_user = db.query(User).filter(User.email == 'admin@factory.local').first()
            if not alt_user:
                alt_user = User(
                    name='Super Admin',
                    email='admin@factory.local',
                    password_hash=get_password_hash(password),
                    role=UserRole.SUPER_ADMIN.value,
                    department='admin',
                    is_active=True,
                )
                db.add(alt_user)
                db.commit()
                print("[CREATED] Alternate super admin account 'admin@factory.local' created.")
            else:
                alt_user.is_active = True
                alt_user.role = UserRole.SUPER_ADMIN.value
                alt_user.password_hash = get_password_hash(password)
                db.commit()
                print("[UPDATED] Alternate super admin account 'admin@factory.local' restored.")

        print("\nAll Current Users in Database:")
        print("-" * 65)
        all_users = db.query(User).all()
        for u in all_users:
            status_str = "ACTIVE" if u.is_active else "INACTIVE"
            print(f"ID: {u.id:<4} | Email: {u.email:<28} | Role: {u.role:<12} | Status: {status_str}")
        print("-" * 65)
        print("\nDefault Super Admin Credentials:")
        print("  Email:    admin@example.com  (or admin@factory.local)")
        print(f"  Password: {password}")
        print("  Role:     super_admin")
        print("\nYou can now log in immediately on Fabricana Supreme!")

    finally:
        db.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Restore default super admin')
    parser.add_argument('--email', default='admin@example.com', help='Admin email (default: admin@example.com)')
    parser.add_argument('--password', default='password', help='Admin password (default: password)')
    parser.add_argument('--name', default='Super Admin', help='Admin name (default: Super Admin)')
    args = parser.parse_args()
    restore_admin(email=args.email, password=args.password, name=args.name)
