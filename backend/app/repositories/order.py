from datetime import datetime
from itertools import count

from sqlalchemy import func, select
from sqlalchemy.orm import Session, selectinload

from app.models.order import (
    CastingProcess,
    Order,
    PackingProcess,
    PolishingProcess,
    RawMaterial,
    TurningProcess,
)
from app.repositories.base import BaseRepository


class OrderRepository(BaseRepository):
    def __init__(self, session: Session) -> None:
        super().__init__(session)

    def next_token(self) -> str:
        current_year = datetime.utcnow().year
        total = self.session.scalar(select(func.count(Order.id))) or 0
        return f'BTN-{current_year}-{total + 1:04d}'

    def create(self, order: Order) -> Order:
        self.session.add(order)
        self.session.flush()
        return order

    def list(self) -> list[Order]:
        statement = select(Order).options(
            selectinload(Order.raw_materials),
            selectinload(Order.casting_process),
            selectinload(Order.turning_process),
            selectinload(Order.polishing_process),
            selectinload(Order.packing_process),
        ).order_by(Order.created_at.desc())
        return list(self.session.scalars(statement).all())

    def get_by_token(self, token: str) -> Order | None:
        statement = select(Order).where(Order.token == token).options(
            selectinload(Order.raw_materials),
            selectinload(Order.casting_process),
            selectinload(Order.turning_process),
            selectinload(Order.polishing_process),
            selectinload(Order.packing_process),
        )
        return self.session.scalar(statement)

    def delete(self, order: Order) -> None:
        self.session.delete(order)

    def add_raw_material(self, order: Order, raw_material: RawMaterial) -> RawMaterial:
        order.raw_materials.append(raw_material)
        self.session.add(raw_material)
        self.session.flush()
        return raw_material

    def upsert_casting(self, order: Order, casting: CastingProcess) -> CastingProcess:
        order.casting_process = casting
        self.session.add(casting)
        self.session.flush()
        return casting

    def upsert_turning(self, order: Order, turning: TurningProcess) -> TurningProcess:
        order.turning_process = turning
        self.session.add(turning)
        self.session.flush()
        return turning

    def upsert_polishing(self, order: Order, polishing: PolishingProcess) -> PolishingProcess:
        order.polishing_process = polishing
        self.session.add(polishing)
        self.session.flush()
        return polishing

    def upsert_packing(self, order: Order, packing: PackingProcess) -> PackingProcess:
        order.packing_process = packing
        self.session.add(packing)
        self.session.flush()
        return packing
