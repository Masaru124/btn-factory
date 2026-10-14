import logging
from sqlalchemy import Engine, inspect, text

from app.core.database import Base
import app.models.order  # noqa: F401
import app.models.user  # noqa: F401

logger = logging.getLogger(__name__)


def sync_database_schema(engine: Engine) -> None:
    """Ensure all columns defined in SQLAlchemy models exist in the target database.

    If a column is missing from an existing table, dynamically adds it via ALTER TABLE.
    This prevents 'no such column' errors on SQLite / PostgreSQL without manual migrations.
    """
    inspector = inspect(engine)
    with engine.begin() as conn:
        for table_name, table in Base.metadata.tables.items():
            if not inspector.has_table(table_name):
                continue
            existing_cols = {c['name'] for c in inspector.get_columns(table_name)}
            for col in table.columns:
                if col.name in existing_cols:
                    continue

                col_type = col.type.compile(engine.dialect)
                default_clause = ''
                if col.default is not None and hasattr(col.default, 'arg') and col.default.arg is not None:
                    arg = col.default.arg
                    if callable(arg):
                        pass
                    elif isinstance(arg, str):
                        default_clause = f" DEFAULT '{arg}'"
                    elif isinstance(arg, (int, float)):
                        default_clause = f" DEFAULT {arg}"
                elif col.server_default is not None:
                    default_clause = f" DEFAULT {col.server_default.arg}"

                sql = f"ALTER TABLE {table_name} ADD COLUMN {col.name} {col_type}{default_clause}"
                logger.info(f"Adding missing column: {sql}")
                try:
                    conn.execute(text(sql))
                except Exception as exc:
                    logger.warning(f"Could not add column {col.name} to {table_name}: {exc}")
