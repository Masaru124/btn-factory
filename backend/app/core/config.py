from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8', extra='ignore')

    project_name: str = 'Button Factory MES API'
    api_v1_prefix: str = '/api'
    secret_key: str = Field(default='change-me-in-production', alias='SECRET_KEY')
    algorithm: str = 'HS256'
    access_token_expire_minutes: int = 60 * 24
    database_url: str = Field(default='sqlite:///./btn_factory.db', alias='DATABASE_URL')
    refresh_token_expire_days: int = 7
    cloudinary_cloud_name: str | None = Field(default=None, alias='CLOUDINARY_CLOUD_NAME')
    cloudinary_api_key: str | None = Field(default=None, alias='CLOUDINARY_API_KEY')
    cloudinary_api_secret: str | None = Field(default=None, alias='CLOUDINARY_API_SECRET')
    s3_bucket_name: str | None = Field(default=None, alias='S3_BUCKET_NAME')
    aws_region: str | None = Field(default='ap-south-1', alias='AWS_REGION')


@lru_cache
def get_settings() -> Settings:
    return Settings()
