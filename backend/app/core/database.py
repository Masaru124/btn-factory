import os
from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.core.config import get_settings

settings = get_settings()

# Ensure SQLite storage directory exists if using SQLite file path
if settings.database_url.startswith('sqlite:///'):
    sqlite_path = settings.database_url[len('sqlite:///'):]
    if sqlite_path and not sqlite_path.startswith(':memory:'):
        db_dir = os.path.dirname(os.path.abspath(sqlite_path))
        if db_dir:
            os.makedirs(db_dir, exist_ok=True)

connect_args = {'check_same_thread': False} if settings.database_url.startswith('sqlite') else {}
engine = create_engine(settings.database_url, future=True, echo=False, connect_args=connect_args)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


class Base(DeclarativeBase):
    pass



def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
