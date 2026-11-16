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
        production_completed_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                (Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]))
                | (Order.packing_process != None),  # noqa: E711
            )
            .scalar()
        ) or 0
        dispatch_pending_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                (
                    Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value])
                    | ((Order.packing_process != None) & (Order.status != OrderStatus.DISPATCHED.value))
                ),
            )
            .scalar()
        ) or 0
        dispatched_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                Order.status == OrderStatus.DISPATCHED.value,
            )
            .scalar()
        ) or 0

        return {
            'title': 'Production Report',
            'metrics': [
                {'label': 'Production Completed', 'value': float(production_completed_orders), 'unit': 'orders'},
                {'label': 'Dispatch Pending', 'value': float(dispatch_pending_orders), 'unit': 'orders'},
                {'label': 'Dispatched', 'value': float(dispatched_orders), 'unit': 'orders'},
                {'label': 'Department output', 'value': float(production_completed_orders), 'unit': 'batches'},
            ],
        }

    def revenue_summary(self) -> dict:
        production_completed_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                (Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]))
                | (Order.packing_process != None),  # noqa: E711
            )
            .scalar()
        ) or 0
        dispatch_pending = (
            self.db.query(func.count(Order.id))
            .filter(
                (
                    Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value])
                    | ((Order.packing_process != None) & (Order.status != OrderStatus.DISPATCHED.value))
                )
            )
            .scalar()
        ) or 0
        dispatched = (
            self.db.query(func.count(Order.id))
            .filter(Order.status == OrderStatus.DISPATCHED.value)
            .scalar()
        ) or 0
        return {
            'title': 'Dispatch & Production Summary',
            'metrics': [
                {'label': 'Production Completed', 'value': float(production_completed_orders), 'unit': 'orders'},
                {'label': 'Dispatch Pending', 'value': float(dispatch_pending), 'unit': 'orders'},
                {'label': 'Dispatched', 'value': float(dispatched), 'unit': 'orders'},
            ],
        }

    def reports_summary(self) -> dict:
        # Auto-repair order statuses safely
        try:
            all_orders = self.db.query(Order).order_by(Order.id.desc()).all()
            status_updated = False
            for o in all_orders:
                try:
                    calculated_status = determine_order_status(o)
                    if o.status != calculated_status:
                        o.status = calculated_status
                        status_updated = True
                except Exception:
                    continue
            if status_updated:
                self.db.commit()
        except Exception:
            self.db.rollback()

        # 1. Dispatched orders
        dispatched_orders = (
            self.db.query(func.count(Order.id))
            .filter(Order.status == OrderStatus.DISPATCHED.value)
            .scalar()
        ) or 0

        # 2. Production completed orders (packing finished or marked ready/dispatched)
        production_completed_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                (Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]))
                | (Order.packing_process != None),  # noqa: E711
            )
            .scalar()
        ) or 0

        # 3. Dispatch pending orders (production finished, but not yet dispatched)
        dispatch_pending_orders = (
            self.db.query(func.count(Order.id))
            .filter(
                (
                    Order.status.in_([OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value])
                    | ((Order.packing_process != None) & (Order.status != OrderStatus.DISPATCHED.value))
                )
            )
            .scalar()
        ) or 0

        # 4. Total orders and in-production orders
        total_orders = self.db.query(func.count(Order.id)).scalar() or 0
        in_production_orders = max(0, total_orders - production_completed_orders)
        
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
            universal_materials.append({
                'id': u.id,
                'name': u.material_name,
                'remaining_quantity': round(rem, 3),
                'consumed_quantity': round(cons, 3),
                'initial_quantity': round(rem + cons, 3),
                'unit': u.unit,
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
            # Remove financial metrics from reports
            order_data.pop('rate', None)
            order_data.pop('total_amount', None)

            # Production and dispatch flags
            is_dispatched = (o.status == OrderStatus.DISPATCHED.value)
            is_prod_completed = (
                o.status in [OrderStatus.PACKING_COMPLETED.value, OrderStatus.READY_TO_DISPATCH.value, OrderStatus.DISPATCHED.value]
                or o.packing_process is not None
            )
            is_dispatch_pending = is_prod_completed and not is_dispatched
            is_in_production = not is_prod_completed

            order_data['is_production_completed'] = is_prod_completed
            order_data['is_dispatch_pending'] = is_dispatch_pending
            order_data['is_dispatched'] = is_dispatched
            order_data['is_in_production'] = is_in_production

            if is_dispatched:
                stage = 'Dispatched'
            elif is_dispatch_pending:
                stage = 'Dispatch Pending'
            elif is_prod_completed:
                stage = 'Production Completed'
            else:
                stage = 'In Production'
            order_data['production_stage'] = stage

            for rm in order_data.get('raw_materials', []):
                rm['name'] = rm.get('material_name', '')
                rm.pop('price', None)
            order_reports.append(order_data)

        return {
            'production': {
                'production_completed_orders': int(production_completed_orders),
                'completed_orders': int(production_completed_orders),
                'dispatch_pending_orders': int(dispatch_pending_orders),
                'dispatched_orders': int(dispatched_orders),
                'in_production_orders': int(in_production_orders),
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
            'revenue': {},
            'order_reports': order_reports,
        }


