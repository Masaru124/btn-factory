"""Database diagnostics and health status endpoint."""

from datetime import datetime, timezone
from fastapi import APIRouter
from app.core.config import get_settings
from scripts.test_db_connections import check_postgres_connection, check_sqlite_connection, is_placeholder, mask_url

router = APIRouter()


@router.get('/databases')
def get_database_diagnostics() -> dict:
    """Run connection & latency tests across all 3 configured database tiers."""
    settings = get_settings()

    sqlite_url = settings.sqlite_database_url or settings.database_url or 'sqlite:///./btn_factory.db'
    local_pg = settings.local_postgres_url or settings.postgres_database_url
    neon_pg = settings.neon_database_url

    sqlite_res = check_sqlite_connection(sqlite_url)
    local_pg_res = check_postgres_connection(local_pg, 'Local PostgreSQL', 'Tier 2: Local Postgres')
    neon_res = check_postgres_connection(neon_pg, 'Neon Serverless Cloud', 'Tier 3: Neon Cloud')

    return {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'active_tier': settings.active_db_tier.lower(),
        'effective_database_url': mask_url(settings.get_effective_database_url()),
        'tiers': {
            'sqlite': sqlite_res,
            'local_postgres': local_pg_res,
            'neon': neon_res,
        },
    }
