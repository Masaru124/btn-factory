from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.core.config import get_settings
from app.core.database import Base, engine
from app.models import order, user  # noqa: F401
from app.services.auth_service import AuthService

settings = get_settings()
cors_origins = getattr(settings, 'cors_origins', ['*'])

app = FastAPI(title=settings.project_name)
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)
app.include_router(api_router, prefix=settings.api_v1_prefix)


@app.on_event('startup')
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)
    from app.core.database import SessionLocal

    db = SessionLocal()
    try:
        AuthService(db).ensure_seed_admin()
    finally:
        db.close()


@app.get('/health')
def health_check() -> dict[str, str]:
    return {'status': 'ok'}
