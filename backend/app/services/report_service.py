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
    UniversalRawMaterial,
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
        for o in all_orders:
            order_reports.append({
                'id': o.id,
                'token': o.token,
                'company_name': o.party_name or 'N/A',
                'party_name': o.party_name or 'N/A',
                'product_name': o.product_name or 'N/A',
                'po_number': o.po_number or 'N/A',
                'order_date': o.order_date.isoformat() if o.order_date else None,
                'delivery_date': o.delivery_date.isoformat() if o.delivery_date else None,
                'quantity': o.quantity,
                'unit': o.unit,
                'rate': float(o.rate) if o.rate is not None else None,
                'total_amount': round(float(o.rate * o.quantity), 2) if (o.rate is not None and o.quantity is not None) else None,
                'size': o.size,
                'colour': o.colour,
                'status': o.status,
                'laser': o.laser,
                'button_image': o.sample_image_url,
                'sample_image_url': o.sample_image_url,
                'raw_materials': [
                    {
                        'id': rm.id,
                        'name': rm.material_name,
                        'material_name': rm.material_name,
                        'quantity': float(rm.quantity),
                        'unit': rm.unit,
                        'price': float(rm.price) if rm.price is not None else 0.0,
                    }
                    for rm in o.raw_materials
                ],
                'casting_process': {
                    'casting_type': o.casting_process.casting_type,
                    'date_of_casting': o.casting_process.date_of_casting.isoformat() if o.casting_process.date_of_casting else None,
                    'gross_quantity': o.casting_process.gross_quantity,
                    'no_of_rods': o.casting_process.no_of_rods,
                    'no_of_sheets': o.casting_process.no_of_sheets,
                    'total_weight': o.casting_process.total_weight,
                    'blank_thickness': o.casting_process.blank_thickness,
                    'remarks': o.casting_process.remarks,
                    'operator': o.casting_process.operator,
                } if o.casting_process else None,
                'turning_process': {
                    'tool_no': o.turning_process.tool_no or o.turning_process.art_no,
                    'art_no': o.turning_process.art_no or o.turning_process.tool_no,
                    'gross_quantity': o.turning_process.gross_quantity,
                    'inward_weight': o.turning_process.inward_weight or o.turning_process.weight,
                    'outward_weight': o.turning_process.outward_weight or o.turning_process.turned_in_kgs,
                    'blank_thickness': o.turning_process.blank_thickness,
                    'finish_thickness': o.turning_process.finish_thickness,
                    'machine_no': o.turning_process.machine_no,
                    'laser': o.turning_process.laser or o.laser,
                    'operator': o.turning_process.operator,
                    'remarks': o.turning_process.remarks,
                } if o.turning_process else None,
                'polishing_process': {
                    'receiving_date': o.polishing_process.receiving_date.isoformat() if o.polishing_process.receiving_date else None,
                    'polish_type': o.polishing_process.polish_type,
                    'gross_quantity': o.polishing_process.gross_quantity,
                    'inward_weight': o.polishing_process.inward_weight or o.polishing_process.weight,
                    'outward_weight': o.polishing_process.outward_weight,
                    'operator': o.polishing_process.operator,
                    'remarks': o.polishing_process.remarks,
                } if o.polishing_process else None,
                'packing_process': {
                    'receiving_date': o.packing_process.receiving_date.isoformat() if o.packing_process.receiving_date else None,
                    'in_gross': o.packing_process.in_gross,
                    'packed_qty': o.packing_process.packed_qty,
                    'rejected_qty': o.packing_process.rejected_qty,
                    'rejection_weight': o.packing_process.rejection_weight,
                    'rejection_unit': o.packing_process.rejection_unit or 'g',
                    'inward_weight': o.packing_process.inward_weight or o.packing_process.weight,
                    'inward_weight_unit': o.packing_process.inward_weight_unit or 'kg',
                    'outward_weight': o.packing_process.outward_weight,
                    'outward_weight_unit': o.packing_process.outward_weight_unit or 'kg',
                    'one_gross_weight': o.packing_process.one_gross_weight,
                    'one_gross_weight_unit': o.packing_process.one_gross_weight_unit or 'g',
                    'excess_qty': o.packing_process.excess_qty,
                    'short_qty': o.packing_process.short_qty,
                    'finishing': o.packing_process.finishing,
                    'operator': o.packing_process.operator,
                    'remarks': o.packing_process.remarks,
                } if o.packing_process else None,
            })

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


