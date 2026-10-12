import os
from collections.abc import Generator

from sqlalchemy import create_engine, event
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.core.config import get_settings

settings = get_settings()

is_sqlite = settings.database_url.startswith('sqlite')

# Ensure SQLite storage directory exists if using SQLite file path
if is_sqlite and settings.database_url.startswith('sqlite:///'):
    sqlite_path = settings.database_url[len('sqlite:///'):]
    if sqlite_path and not sqlite_path.startswith(':memory:'):
        db_dir = os.path.dirname(os.path.abspath(sqlite_path))
        if db_dir:
            os.makedirs(db_dir, exist_ok=True)

if is_sqlite:
    engine = create_engine(
        settings.database_url,
        future=True,
        echo=False,
        connect_args={'check_same_thread': False, 'timeout': 15},
    )

    # Enable WAL mode, NORMAL synchronous, and 5000ms busy timeout on every SQLite connection
    @event.listens_for(engine, 'connect')
    def set_sqlite_pragma(dbapi_connection, connection_record):  # noqa: ARG001
        cursor = dbapi_connection.cursor()
        cursor.execute('PRAGMA journal_mode=WAL;')
        cursor.execute('PRAGMA synchronous=NORMAL;')
        cursor.execute('PRAGMA busy_timeout=5000;')
        cursor.close()

else:
    # Production PostgreSQL connection pool tuning
    engine = create_engine(
        settings.database_url,
        future=True,
        echo=False,
        pool_size=20,
        max_overflow=10,
        pool_recycle=1800,
        pool_pre_ping=True,
    )

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


class Base(DeclarativeBase):
    pass


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
