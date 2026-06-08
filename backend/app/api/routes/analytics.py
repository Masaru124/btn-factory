from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_roles

router = APIRouter()


@router.get('/orders-trend', dependencies=[Depends(require_roles('super_admin'))])
def orders_trend(db: Session = Depends(get_db)) -> dict:
    return {'title': 'Orders Trend', 'points': [{'label': 'Jan', 'value': 24}, {'label': 'Feb', 'value': 32}, {'label': 'Mar', 'value': 40}]}


@router.get('/production-trend', dependencies=[Depends(require_roles('super_admin'))])
def production_trend(db: Session = Depends(get_db)) -> dict:
    return {'title': 'Production Trend', 'points': [{'label': 'Mon', 'value': 110}, {'label': 'Tue', 'value': 120}, {'label': 'Wed', 'value': 128}]}
