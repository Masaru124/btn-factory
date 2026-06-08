from sqlalchemy.orm import Session

from app.core.security import create_access_token, create_refresh_token, get_password_hash, verify_password
from app.models.user import User
from app.repositories.user import UserRepository


class AuthService:
    def __init__(self, session: Session) -> None:
        self.session = session
        self.users = UserRepository(session)

    def authenticate(self, email: str, password: str) -> User | None:
        user = self.users.get_by_email(email)
        if user is None or not user.is_active:
            return None
        if not verify_password(password, user.password_hash):
            return None
        return user

    def issue_tokens(self, user: User) -> tuple[str, str]:
        subject = str(user.id)
        return create_access_token(subject), create_refresh_token(subject)

    def ensure_seed_admin(self) -> User:
        existing = self.users.get_by_email('admin@example.com')
        if existing is not None:
            return existing

        admin = User(
            name='Super Admin',
            email='admin@example.com',
            password_hash=get_password_hash('password'),
            role='super_admin',
            department='admin',
            is_active=True,
        )
        self.users.create(admin)
        self.session.commit()
        return admin
