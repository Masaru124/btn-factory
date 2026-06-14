from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.order import (
    CastingProcess,
    Order,
    OrderStatus,
    PackingProcess,
    PolishingProcess,
    RawMaterial,
    TurningProcess,
)


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

    def reports_summary(self) -> dict:
        completed_orders = (
            self.db.query(func.count(Order.id))
            .filter(Order.status.in_([OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]))
            .scalar()
        ) or 0
        
        casting_output = self.db.query(func.sum(CastingProcess.gross_quantity)).scalar() or 0
        turning_output = self.db.query(func.sum(TurningProcess.gross_quantity)).scalar() or 0
        polishing_output = self.db.query(func.sum(PolishingProcess.gross_quantity)).scalar() or 0
        packing_output = self.db.query(func.sum(PackingProcess.packed_qty)).scalar() or 0

        material_rows = (
            self.db.query(
                RawMaterial.material_name,
                func.sum(RawMaterial.quantity).label('total_qty'),
                RawMaterial.unit
            )
            .group_by(RawMaterial.material_name, RawMaterial.unit)
            .all()
        )
        materials = [
            {
                'name': row.material_name,
                'quantity': float(row.total_qty or 0),
                'unit': row.unit
            }
            for row in material_rows
        ]

        total_packed = self.db.query(func.sum(PackingProcess.packed_qty)).scalar() or 0
        total_rejected = self.db.query(func.sum(PackingProcess.rejected_qty)).scalar() or 0
        total_produced = total_packed + total_rejected
        rejection_rate = (total_rejected / total_produced * 100) if total_produced > 0 else 0.0

        total_revenue = (
            self.db.query(func.sum(Order.rate * Order.quantity))
            .filter(Order.rate.isnot(None), Order.quantity.isnot(None))
            .scalar()
        ) or 0.0

        pending_revenue = (
            self.db.query(func.sum(Order.rate * Order.quantity))
            .filter(
                Order.rate.isnot(None),
                Order.quantity.isnot(None),
                ~Order.status.in_([OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value])
            )
            .scalar()
        ) or 0.0

        return {
            'production': {
                'completed_orders': int(completed_orders),
                'casting_output': int(casting_output),
                'turning_output': int(turning_output),
                'polishing_output': int(polishing_output),
                'packing_output': int(packing_output),
            },
            'materials': materials,
            'rejection': {
                'total_packed': int(total_packed),
                'total_rejected': int(total_rejected),
                'rejection_rate': round(float(rejection_rate), 2),
            },
            'revenue': {
                'total_revenue': round(float(total_revenue), 2),
                'completed_count': int(completed_orders),
                'pending_revenue': round(float(pending_revenue), 2),
            }
        }

