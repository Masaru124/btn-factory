from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_roles
from app.schemas.reports import DateRangeRequest
from app.services.report_service import ReportService

router = APIRouter()


@router.post('/production', dependencies=[Depends(require_roles('super_admin'))])
def production_report(payload: DateRangeRequest, db: Session = Depends(get_db)) -> dict:
    service = ReportService(db)
    return service.production_summary(payload.start_date, payload.end_date)


@router.get('/revenue', dependencies=[Depends(require_roles('super_admin'))])
def revenue_report(db: Session = Depends(get_db)) -> dict:
    service = ReportService(db)
    return service.revenue_summary()
