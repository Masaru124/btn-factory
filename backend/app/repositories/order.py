from sqlalchemy import select, update
from sqlalchemy.orm import Session, selectinload

from app.models.order import (
    BlankingProcess,
    CastingProcess,
    Order,
    PackingProcess,
    PolishingProcess,
    RawMaterial,
    TokenCounter,
    TurningProcess,
)
from app.repositories.base import BaseRepository


class OrderRepository(BaseRepository):
    def __init__(self, session: Session) -> None:
        super().__init__(session)

    TOKEN_START = 1001

    def next_token(self) -> str:
        """Return the lowest available numeric order token >= 1001.

        If an order is deleted, its token is freed and automatically taken
        by the next order created or suggested.
        """
        existing_tokens = set()
        for token_val in self.session.scalars(select(Order.token)).all():
            if token_val and token_val.isdigit():
                existing_tokens.add(int(token_val))

        candidate = self.TOKEN_START
        while candidate in existing_tokens:
            candidate += 1
        return str(candidate)

    def create(self, order: Order) -> Order:
        self.session.add(order)
        self.session.flush()
        return order

    def list(self) -> list[Order]:
        statement = select(Order).options(
            selectinload(Order.raw_materials),
            selectinload(Order.casting_process),
            selectinload(Order.blanking_process),
            selectinload(Order.turning_process),
            selectinload(Order.polishing_process),
            selectinload(Order.packing_process),
        ).order_by(Order.created_at.desc())
        return list(self.session.scalars(statement).all())

    def get_by_token(self, token: str) -> Order | None:
        statement = select(Order).where(Order.token == token).options(
            selectinload(Order.raw_materials),
            selectinload(Order.casting_process),
            selectinload(Order.blanking_process),
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

    def upsert_blanking(self, order: Order, blanking: BlankingProcess) -> BlankingProcess:
        order.blanking_process = blanking
        self.session.add(blanking)
        self.session.flush()
        return blanking

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
