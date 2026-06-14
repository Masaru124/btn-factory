from datetime import date, datetime

from sqlalchemy.orm import Session

from app.models.order import (
    CastingProcess,
    Order,
    PackingProcess,
    PolishingProcess,
    RawMaterial,
    TurningProcess,
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

        for field, value in payload.model_dump(exclude_unset=True).items():
            setattr(order, field, value)

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

        raw_material = RawMaterial(
            order_id=order.id,
            material_name=payload.material_name,
            quantity=payload.quantity,
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

        casting = CastingProcess(order_id=order.id, **payload.model_dump(exclude={'order_token'}, exclude_unset=True))
        self.orders.upsert_casting(order, casting)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(casting)
        return casting

    def update_turning(self, payload: TurningUpdate) -> TurningProcess | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        turning = TurningProcess(order_id=order.id, **payload.model_dump(exclude={'order_token'}, exclude_unset=True))
        self.orders.upsert_turning(order, turning)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(turning)
        return turning

    def update_polishing(self, payload: PolishingUpdate) -> PolishingProcess | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        polishing = PolishingProcess(order_id=order.id, **payload.model_dump(exclude={'order_token'}, exclude_unset=True))
        self.orders.upsert_polishing(order, polishing)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(polishing)
        return polishing

    def update_packing(self, payload: PackingUpdate) -> PackingProcess | None:
        order = self.orders.get_by_token(payload.order_token)
        if order is None:
            return None

        packing = PackingProcess(order_id=order.id, **payload.model_dump(exclude={'order_token'}, exclude_unset=True))
        self.orders.upsert_packing(order, packing)
        order.status = recompute_order_status(order)
        self.session.commit()
        self.session.refresh(packing)
        return packing
