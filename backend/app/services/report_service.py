from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.order import (
    BlankingProcess,
    CastingProcess,
    Order,
    OrderStatus,
    PackingProcess,
    PolishingProcess,
    RawMaterial,
    TurningProcess,
    UniversalRawMaterial,
)
from app.services.status_engine import determine_order_status


class ReportService:
    def __init__(self, db: Session):
        self.db = db

    def production_summary(self, start_date: date, end_date: date) -> dict:
        completed_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                (Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]))
                | (Order.packing_process != None),  # noqa: E711
            )
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
        completed_count = (
            self.db.query(func.count(Order.id))
            .filter(
                (Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]))
                | (Order.packing_process != None),  # noqa: E711
            )
            .scalar()
        ) or 0
        pending_count = (
            self.db.query(func.count(Order.id))
            .filter(
                ~Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]),
                Order.packing_process == None,  # noqa: E711
            )
            .scalar()
        ) or 0
        return {
            'title': 'Revenue Report',
            'metrics': [
                {'label': 'Completed orders', 'value': float(completed_count), 'unit': 'orders'},
                {'label': 'Pending orders', 'value': float(pending_count), 'unit': 'orders'},
            ],
        }

    def reports_summary(self) -> dict:
        # Auto-repair order statuses so orders never get stuck at Raw Material Updated
        all_orders = self.db.query(Order).order_by(Order.id.desc()).all()
        status_updated = False
        for o in all_orders:
            calculated_status = determine_order_status(o)
            if o.status != calculated_status:
                o.status = calculated_status
                status_updated = True
        if status_updated:
            self.db.commit()

        completed_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                (Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]))
                | (Order.packing_process != None),  # noqa: E711
            )
            .scalar()
        ) or 0
        
        # Casting output: accounts for Rod casting gross, Sheet blanking gross, and Order gross qty
        casting_output = (
            self.db.query(
                func.sum(
                    func.coalesce(
                        CastingProcess.gross_quantity,
                        BlankingProcess.gross_quantity,
                        Order.quantity,
                        0,
                    )
                )
            )
            .select_from(CastingProcess)
            .join(Order, CastingProcess.order_id == Order.id)
            .outerjoin(BlankingProcess, Order.id == BlankingProcess.order_id)
            .scalar()
        ) or 0

        turning_output = (
            self.db.query(
                func.sum(
                    func.coalesce(
                        TurningProcess.gross_quantity,
                        Order.quantity,
                        0,
                    )
                )
            )
            .select_from(TurningProcess)
            .join(Order, TurningProcess.order_id == Order.id)
            .scalar()
        ) or 0

        polishing_output = (
            self.db.query(
                func.sum(
                    func.coalesce(
                        PolishingProcess.gross_quantity,
                        Order.quantity,
                        0,
                    )
                )
            )
            .select_from(PolishingProcess)
            .join(Order, PolishingProcess.order_id == Order.id)
            .scalar()
        ) or 0

        packing_output = (
            self.db.query(
                func.sum(
                    func.coalesce(
                        PackingProcess.packed_qty,
                        PackingProcess.in_gross,
                        Order.quantity,
                        0,
                    )
                )
            )
            .select_from(PackingProcess)
            .join(Order, PackingProcess.order_id == Order.id)
            .scalar()
        ) or 0

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

        total_packed = (
            self.db.query(
                func.sum(
                    func.coalesce(
                        PackingProcess.packed_qty,
                        PackingProcess.in_gross,
                        Order.quantity,
                        0,
                    )
                )
            )
            .select_from(PackingProcess)
            .join(Order, PackingProcess.order_id == Order.id)
            .scalar()
        ) or 0
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
                ~Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]),
                Order.packing_process == None,  # noqa: E711
            )
            .scalar()
        ) or 0.0

        universal_rows = self.db.query(UniversalRawMaterial).order_by(UniversalRawMaterial.material_name).all()
        universal_materials = []
        for u in universal_rows:
            consumed = (
                self.db.query(func.sum(RawMaterial.quantity))
                .filter(func.lower(RawMaterial.material_name) == func.lower(u.material_name))
                .scalar()
            ) or 0.0
            rem = float(u.total_available_quantity or 0.0)
            cons = float(consumed)
            unit_price = float(u.price or 0.0)
            universal_materials.append({
                'id': u.id,
                'name': u.material_name,
                'remaining_quantity': round(rem, 3),
                'consumed_quantity': round(cons, 3),
                'initial_quantity': round(rem + cons, 3),
                'unit': u.unit,
                'price': round(unit_price, 2),
                'total_value': round(rem * unit_price, 2),
            })

        all_orders = self.db.query(Order).order_by(Order.id.desc()).all()
        order_reports = []
        from app.schemas.order import OrderRead
        for o in all_orders:
            order_data = OrderRead.model_validate(o).model_dump(mode='json')
            order_data['party_name'] = o.company_name
            order_data['company_name'] = o.company_name
            order_data['sample_image_url'] = o.button_image
            order_data['button_image'] = o.button_image
            order_data['total_amount'] = round(float(o.rate * o.quantity), 2) if (o.rate is not None and o.quantity is not None) else None
            for rm in order_data.get('raw_materials', []):
                rm['name'] = rm.get('material_name', '')
            order_reports.append(order_data)


        return {
            'production': {
                'completed_orders': int(completed_orders),
                'casting_output': int(casting_output),
                'turning_output': int(turning_output),
                'polishing_output': int(polishing_output),
                'packing_output': int(packing_output),
            },
            'materials': materials,
            'universal_materials': universal_materials,
            'rejection': {
                'total_packed': int(total_packed),
                'total_rejected': int(total_rejected),
                'rejection_rate': round(float(rejection_rate), 2),
            },
            'revenue': {
                'total_revenue': round(float(total_revenue), 2),
                'completed_count': int(completed_orders),
                'pending_revenue': round(float(pending_revenue), 2),
            },
            'order_reports': order_reports,
        }


