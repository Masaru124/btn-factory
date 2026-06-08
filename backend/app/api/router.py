from fastapi import APIRouter

from app.api.routes import analytics, auth, departments, orders, reports

api_router = APIRouter()
api_router.include_router(auth.router, prefix='/auth', tags=['auth'])
api_router.include_router(orders.router, prefix='/orders', tags=['orders'])
api_router.include_router(departments.router, prefix='/department', tags=['department'])
api_router.include_router(reports.router, prefix='/reports', tags=['reports'])
api_router.include_router(analytics.router, prefix='/analytics', tags=['analytics'])
