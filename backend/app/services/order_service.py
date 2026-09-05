from datetime import date, datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.order import (
    CastingProcess,
    Order,
    PackingProcess,
    PolishingProcess,
    RawMaterial,
    TurningProcess,
    UniversalRawMaterial,
)
from app.repositories.order import OrderRepository
from app.schemas.order import (
    CastingUpdate,
    OrderCreate,
    OrderUpdate,
    PackingUpdate,
    PolishingUpdate,
    RawMaterialCreate,
    TurningUpdate,
    UniversalRawMaterialCreate,
    UniversalRawMaterialUpdate,
)
from app.services.status_engine import recompute_order_status


class OrderService:
    def __init__(self, session: Session) -> None:
        self.session = session
        self.orders = OrderRepository(session)

    def create_order(self, payload: OrderCreate) -> Order:
        order = Order(
            token=self.orders.next_token(),
            company_name=payload.company_name,
            po_number=payload.po_number,
            po_date=payload.po_date,
            casting_type=payload.casting_type,
            thickness=payload.thickness,
            holes=payload.holes,
            box_type=payload.box_type,
            rate=payload.rate,
            quantity=payload.quantity,
            linings=payload.linings,
            laser=payload.laser,
            polish_type=payload.polish_type,
            packing_option=payload.packing_option,
            dispatch_date=payload.dispatch_date,
            po_image=payload.po_image,
            button_image=payload.button_image,
            created_by_id=payload.created_by_id,
        )
        self.orders.create(order)
        self.session.commit()
        self.session.refresh(order)
        return order

    def update_order(self, token: str, payload: OrderUpdate) -> Order | None:
        order = self.orders.get_by_token(token)
        if order is None:
            return None

        payload_data = payload.model_dump(exclude_unset=True)
        for field, value in payload_data.items():
            setattr(order, field, value)

        if 'status' not in payload_data:
            order.status = recompute_order_status(order)
        self.session.flush()
        self.session.commit()
        self.session.refresh(order)
        return order

    def delete_order(self, token: str) -> bool:
        order = self.orders.get_by_token(token)
        if order is None:
            return False
        self.orders.delete(order)
        self.session.commit()
        return True

    def list_orders(self) -> list[Order]:
        return self.orders.list()

    def get_order(self, token: str) -> Order | None:
        return self.orders.get_by_token(token)

    def add_raw_material(self, payload: RawMaterialCreate, created_by: int | None = None) -> RawMaterial | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        # Check or sync universal raw material
        universal = self.session.scalar(
            select(UniversalRawMaterial).where(UniversalRawMaterial.material_name == payload.material_name)
        )
        if universal is None:
            avail = payload.total_available_quantity if payload.total_available_quantity is not None else payload.quantity
            universal = UniversalRawMaterial(
                material_name=payload.material_name,
                total_available_quantity=avail,
                unit=payload.unit,
                price=payload.price,
            )
            self.session.add(universal)
        else:
            if payload.total_available_quantity is not None:
                universal.total_available_quantity = payload.total_available_quantity
            if payload.unit:
                universal.unit = payload.unit
            if payload.price:
                universal.price = payload.price

        raw_material = RawMaterial(
            order_id=order.id,
            material_name=payload.material_name,
            quantity=payload.quantity,
            total_available_quantity=payload.total_available_quantity if payload.total_available_quantity is not None else universal.total_available_quantity,
            unit=payload.unit,
            price=payload.price,
            created_by_id=created_by or payload.created_by_id,
        )
        self.orders.add_raw_material(order, raw_material)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(raw_material)
        return raw_material

    def update_casting(self, payload: CastingUpdate) -> CastingProcess | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        data = payload.model_dump(exclude={'order_token'}, exclude_unset=True)
        if 'total_weight' in data and 'weight' not in data:
            data['weight'] = data['total_weight']
        elif 'weight' in data and 'total_weight' not in data:
            data['total_weight'] = data['weight']

        if 'blank_thickness' in data and 'thickness' not in data:
            data['thickness'] = data['blank_thickness']
        elif 'thickness' in data and 'blank_thickness' not in data:
            data['blank_thickness'] = data['thickness']

        casting = CastingProcess(order_id=order.id, **data)
        self.orders.upsert_casting(order, casting)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(casting)
        return casting

    def update_turning(self, payload: TurningUpdate) -> TurningProcess | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        data = payload.model_dump(exclude={'order_token'}, exclude_unset=True)
        if 'tool_no' in data and 'art_no' not in data:
            data['art_no'] = data['tool_no']
        elif 'art_no' in data and 'tool_no' not in data:
            data['tool_no'] = data['art_no']

        if 'inward_weight' in data and 'weight' not in data:
            data['weight'] = data['inward_weight']
        elif 'weight' in data and 'inward_weight' not in data:
            data['inward_weight'] = data['weight']

        if 'outward_weight' in data and 'turned_in_kgs' not in data:
            data['turned_in_kgs'] = data['outward_weight']
        elif 'turned_in_kgs' in data and 'outward_weight' not in data:
            data['outward_weight'] = data['turned_in_kgs']

        turning = TurningProcess(order_id=order.id, **data)
        self.orders.upsert_turning(order, turning)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(turning)
        return turning

    def update_polishing(self, payload: PolishingUpdate) -> PolishingProcess | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        data = payload.model_dump(exclude={'order_token'}, exclude_unset=True)
        if 'tool_no' in data and 'art_no' not in data:
            data['art_no'] = data['tool_no']
        elif 'art_no' in data and 'tool_no' not in data:
            data['tool_no'] = data['art_no']

        if 'inward_weight' in data and 'weight' not in data:
            data['weight'] = data['inward_weight']
        elif 'weight' in data and 'inward_weight' not in data:
            data['inward_weight'] = data['weight']

        polishing = PolishingProcess(order_id=order.id, **data)
        self.orders.upsert_polishing(order, polishing)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(polishing)
        return polishing

    def update_packing(self, payload: PackingUpdate) -> PackingProcess | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        data = payload.model_dump(exclude={'order_token'}, exclude_unset=True)
        if 'tool_no' in data and 'art_no' not in data:
            data['art_no'] = data['tool_no']
        elif 'art_no' in data and 'tool_no' not in data:
            data['tool_no'] = data['art_no']

        if 'inward_weight' in data and 'weight' not in data:
            data['weight'] = data['inward_weight']
        elif 'weight' in data and 'inward_weight' not in data:
            data['inward_weight'] = data['weight']

        packing = PackingProcess(order_id=order.id, **data)
        self.orders.upsert_packing(order, packing)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(packing)
        return packing

    def list_universal_raw_materials(self) -> list[UniversalRawMaterial]:
        return list(self.session.scalars(select(UniversalRawMaterial).order_by(UniversalRawMaterial.material_name)).all())

    def upsert_universal_raw_material(self, payload: UniversalRawMaterialCreate) -> UniversalRawMaterial:
        mat = self.session.scalar(
            select(UniversalRawMaterial).where(UniversalRawMaterial.material_name == payload.material_name)
        )
        if mat is None:
            mat = UniversalRawMaterial(
                material_name=payload.material_name,
                total_available_quantity=payload.total_available_quantity,
                unit=payload.unit,
                price=payload.price,
            )
            self.session.add(mat)
        else:
            mat.total_available_quantity = payload.total_available_quantity
            mat.unit = payload.unit
            mat.price = payload.price
        self.session.commit()
        self.session.refresh(mat)
        return mat
