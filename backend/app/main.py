import logging
import os
import time
import uuid

from fastapi import FastAPI, HTTPException, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text

from app.api.router import api_router
from app.core.config import get_settings
from app.core.database import Base, SessionLocal, engine
from app.core.redis_client import cache_client
from app.models import order, user  # noqa: F401
from app.services.auth_service import AuthService

logger = logging.getLogger('mes.api')
settings = get_settings()
cors_origins = getattr(settings, 'cors_origins', ['*'])

app = FastAPI(
    title=settings.project_name,
    description='Industrial Manufacturing Execution System for Button Factory',
    version='2.1.0',
)

# 1. CORS Configuration
if cors_origins == ['*'] or '*' in cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origin_regex=r'^https?://.*',
        allow_credentials=True,
        allow_methods=['*'],
        allow_headers=['*'],
    )
else:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=['*'],
        allow_headers=['*'],
    )


# 2. Request Correlation ID & Latency Timing Middleware
@app.middleware('http')
async def trace_and_timing_middleware(request: Request, call_next) -> Response:
    request_id = request.headers.get('X-Request-ID') or str(uuid.uuid4())
    start_time = time.perf_counter()

    response = await call_next(request)

    process_time = (time.perf_counter() - start_time) * 1000  # ms
    response.headers['X-Request-ID'] = request_id
    response.headers['X-Process-Time'] = f'{process_time:.2f}ms'
    return response


# 3. Global Exception Handlers
@app.exception_handler(HTTPException)
async def custom_http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    request_id = request.headers.get('X-Request-ID', 'unknown')
    return JSONResponse(
        status_code=exc.status_code,
        content={
            'error': True,
            'status_code': exc.status_code,
            'detail': exc.detail,
            'request_id': request_id,
        },
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    request_id = request.headers.get('X-Request-ID', 'unknown')
    logger.exception('Unhandled exception on %s %s [Request-ID: %s]: %s', request.method, request.url.path, request_id, exc)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            'error': True,
            'status_code': 500,
            'detail': 'An unexpected server error occurred. Please contact the factory system admin.',
            'request_id': request_id,
        },
    )


# 4. Mount Static Media Directory for Local Media Storage
media_dir = os.path.abspath(settings.media_dir)
os.makedirs(media_dir, exist_ok=True)
app.mount('/media', StaticFiles(directory=media_dir), name='media')

# 5. Include API Routes
app.include_router(api_router, prefix=settings.api_v1_prefix)


# 6. Lifecycle Events
@app.on_event('startup')
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)
    from app.core.migrations import sync_database_schema

    sync_database_schema(engine)

    db = SessionLocal()
    try:
        AuthService(db).ensure_seed_admin()
    finally:
        db.close()

    # Trigger automated local snapshot & cloud disaster recovery sync in background
    from app.services.backup_service import run_background_backup
    run_background_backup()


# 7. Comprehensive Health & Readiness Check
@app.get('/health')
def health_check() -> dict[str, object]:
    db_ok = False
    try:
        with engine.connect() as conn:
            conn.execute(text('SELECT 1'))
            db_ok = True
    except Exception as e:
        logger.error('Health check database error: %s', e)

    return {
        'status': 'healthy' if db_ok else 'degraded',
        'database': 'connected' if db_ok else 'unreachable',
        'redis': 'connected' if cache_client.is_connected else 'fallback_in_memory',
        'media_store': 'ready' if os.path.exists(media_dir) else 'missing',
    }
