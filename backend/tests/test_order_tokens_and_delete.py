from datetime import date

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base
from app.models.order import Order
from app.schemas.order import OrderCreate
from app.services.order_service import OrderService


def setup_test_db():
    engine = create_engine('sqlite:///:memory:', echo=False)
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    return Session()


def _order_payload(company: str = 'Token Co') -> OrderCreate:
    return OrderCreate(company_name=company, po_date=date.today())


def test_tokens_start_at_1001_and_increment():
    session = setup_test_db()
    service = OrderService(session)

    tokens = [service.create_order(_order_payload(f'Co {i}')).token for i in range(4)]

    assert tokens == ['1001', '1002', '1003', '1004']


def test_deleted_tokens_are_not_reused():
    session = setup_test_db()
    service = OrderService(session)

    first = service.create_order(_order_payload('First'))
    second = service.create_order(_order_payload('Second'))
    third = service.create_order(_order_payload('Third'))
    assert [first.token, second.token, third.token] == ['1001', '1002', '1003']

    # Delete the middle order; 1002 must not be handed out again.
    assert service.delete_order(second.token) is True
    assert service.get_order('1002') is None

    fourth = service.create_order(_order_payload('Fourth'))
    assert fourth.token == '1004'

    # Deleting the highest token also must not rewind the sequence.
    assert service.delete_order(fourth.token) is True
    fifth = service.create_order(_order_payload('Fifth'))
    assert fifth.token == '1005'


def test_delete_only_removes_target_order():
    session = setup_test_db()
    service = OrderService(session)

    a = service.create_order(_order_payload('A'))
    b = service.create_order(_order_payload('B'))

    assert service.delete_order(a.token) is True
    assert service.get_order(a.token) is None
    assert service.get_order(b.token) is not None
    assert service.delete_order(a.token) is False  # second delete is a no-op


def test_delete_is_atomic_when_child_rows_exist():
    """Deleting an order with process rows must not leave orphans behind."""
    from app.schemas.order import CastingUpdate

    session = setup_test_db()
    service = OrderService(session)

    order = service.create_order(_order_payload('Cascading'))
    service.update_casting(CastingUpdate(order_token=order.token, total_weight=12.0))

    assert service.delete_order(order.token) is True
    assert service.get_order(order.token) is None

    from sqlalchemy import select

    from app.models.order import CastingProcess

    orphans = session.scalars(select(CastingProcess)).all()
    assert orphans == []


def test_sequence_seeds_past_legacy_numeric_tokens():
    session = setup_test_db()
    session.add(Order(token='9999', company_name='Legacy', po_date=date.today()))
    session.commit()

    service = OrderService(session)
    assert service.create_order(_order_payload('Next')).token == '10000'
