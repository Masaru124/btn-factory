from sqlalchemy import select, update
from sqlalchemy.orm import Session, selectinload

from app.models.order import (
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
        """Return the next sequential order token: 1001, 1002, 1003, ...

        The counter lives in the database and is incremented with a single
        atomic UPDATE, so concurrent creations get distinct tokens and the
        sequence only ever moves forward. Deleted tokens are never reused,
        even when the order holding the highest token is removed.
        """
        counter = self._ensure_counter()
        self.session.execute(
            update(TokenCounter)
            .where(TokenCounter.id == counter.id)
            .values(last_value=TokenCounter.last_value + 1)
        )
        self.session.flush()
        self.session.refresh(counter)
        return str(counter.last_value)

    def _ensure_counter(self) -> TokenCounter:
        counter = self.session.get(TokenCounter, 1)
        if counter is None:
            # Seed the sequence past any legacy numeric tokens so the very
            # first generated token can never collide with existing data.
            last_used = self.TOKEN_START - 1
            existing_tokens = self.session.scalars(select(Order.token)).all()
            for existing_token in existing_tokens:
                if existing_token and existing_token.isdigit():
                    last_used = max(last_used, int(existing_token))
            counter = TokenCounter(id=1, last_value=last_used)
            self.session.add(counter)
            self.session.flush()
        return counter

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
