from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.order import Order, OrderStatus


class ReportService:
    def __init__(self, db: Session):
        self.db = db

    def production_summary(self, start_date: date, end_date: date) -> dict:
        completed_orders = (
            self.db.query(func.count(Order.id))
            .filter(Order.created_at >= start_date, Order.created_at <= end_date, Order.status == OrderStatus.DISPATCHED.value)
            .scalar()
        ) or 0

        return {
            'title': 'Production Report',
            'metrics': [
                {'label': 'Orders completed', 'value': float(completed_orders), 'unit': 'orders'},
                {'label': 'Department output', 'value': float(completed_orders), 'unit': 'batches'},
            ],
        }

    def revenue_summary(self) -> dict:
        pending_count = self.db.query(func.count(Order.id)).filter(Order.status != OrderStatus.DISPATCHED.value).scalar() or 0
        completed_count = self.db.query(func.count(Order.id)).filter(Order.status == OrderStatus.DISPATCHED.value).scalar() or 0
        return {
            'title': 'Revenue Report',
            'metrics': [
                {'label': 'Completed orders', 'value': float(completed_count), 'unit': 'orders'},
                {'label': 'Pending orders', 'value': float(pending_count), 'unit': 'orders'},
            ],
        }
