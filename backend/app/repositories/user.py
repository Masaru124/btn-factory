from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.user import User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository):
    def __init__(self, session: Session) -> None:
        super().__init__(session)

    def get_by_email(self, email: str) -> User | None:
        if not email:
            return None
        clean_email = email.strip().lower()
        return self.session.scalar(select(User).where(func.lower(User.email) == clean_email))

    def get_by_id(self, user_id: int) -> User | None:
        return self.session.get(User, user_id)

    def create(self, user: User) -> User:
        self.session.add(user)
        self.session.flush()
        return user
