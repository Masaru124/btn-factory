from functools import lru_cache
import json
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=('.env', 'backend/.env'),
        env_file_encoding='utf-8',
        extra='ignore',
    )

    project_name: str = 'Button Factory MES API'
    api_v1_prefix: str = '/api'
    secret_key: str = Field(default='change-me-in-production', alias='SECRET_KEY')
    algorithm: str = 'HS256'
    access_token_expire_minutes: int = 60 * 24
    cors_origins: str | list[str] = Field(default=['*'], alias='CORS_ORIGINS')
    refresh_token_expire_days: int = 7

    @field_validator('cors_origins', mode='before')
    @classmethod
    def parse_cors_origins(cls, v):
        if isinstance(v, str):
            v_stripped = v.strip()
            if v_stripped == '*' or not v_stripped:
                return ['*']
            try:
                parsed = json.loads(v_stripped)
                if isinstance(parsed, list):
                    return parsed
            except Exception:
                pass
            return [x.strip() for x in v_stripped.split(',') if x.strip()]
        return v

    # -------------------------------------------------------------------------
    # 3-Tier Multi-Database Configuration
    # -------------------------------------------------------------------------
    # Tier 1: Local SQLite (Embedded Edge / Offline Fallback)
    sqlite_database_url: str = Field(default='sqlite:///./btn_factory.db', alias='SQLITE_DATABASE_URL')

    # Tier 2: Local PostgreSQL (On-Premises Main DB)
    local_postgres_url: str | None = Field(default=None, alias='LOCAL_POSTGRES_URL')
    postgres_database_url: str | None = Field(default=None, alias='POSTGRES_DATABASE_URL')

    # Tier 3: Neon Serverless Cloud PostgreSQL (Remote DR Backup Replica)
    neon_database_url: str | None = Field(default=None, alias='NEON_DATABASE_URL')

    # Active operational database & active tier selector ('sqlite' | 'postgres' | 'neon')
    active_db_tier: str = Field(default='sqlite', alias='ACTIVE_DB_TIER')
    database_url: str = Field(default='sqlite:///./btn_factory.db', alias='DATABASE_URL')

    # -------------------------------------------------------------------------
    # Local On-Premise Storage (Zero Cloud)
    # -------------------------------------------------------------------------
    media_dir: str = Field(default='./media', alias='MEDIA_DIR')
    media_base_url: str = Field(default='/media', alias='MEDIA_BASE_URL')

    # -------------------------------------------------------------------------
    # Redis Cache & Background Sync
    # -------------------------------------------------------------------------
    redis_url: str = Field(default='redis://localhost:6379/0', alias='REDIS_URL')
    enable_redis: bool = Field(default=False, alias='ENABLE_REDIS')

    # Cloud legacy placeholders (optional / disabled for local hosting)
    cloudinary_cloud_name: str | None = Field(default=None, alias='CLOUDINARY_CLOUD_NAME')
    cloudinary_api_key: str | None = Field(default=None, alias='CLOUDINARY_API_KEY')
    cloudinary_api_secret: str | None = Field(default=None, alias='CLOUDINARY_API_SECRET')
    s3_bucket_name: str | None = Field(default=None, alias='S3_BUCKET_NAME')
    aws_region: str | None = Field(default='ap-south-1', alias='AWS_REGION')

    def get_effective_database_url(self) -> str:
        """Resolve the active database connection string based on ACTIVE_DB_TIER."""
        tier = (self.active_db_tier or 'sqlite').strip().lower()
        if tier == 'neon' and self.neon_database_url:
            return self.neon_database_url
        if tier in ('postgres', 'postgresql', 'local_postgres'):
            url = self.local_postgres_url or self.postgres_database_url
            if url:
                return url
        # If explicitly specified in DATABASE_URL and not default sqlite
        if self.database_url and not self.database_url.startswith('sqlite:///./btn_factory.db'):
            return self.database_url
        return self.sqlite_database_url or self.database_url


@lru_cache
def get_settings() -> Settings:
    return Settings()
