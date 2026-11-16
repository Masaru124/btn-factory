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


def test_deleted_tokens_are_reused_and_editable():
    session = setup_test_db()
    service = OrderService(session)

    first = service.create_order(_order_payload('First'))
    second = service.create_order(_order_payload('Second'))
    third = service.create_order(_order_payload('Third'))
    assert [first.token, second.token, third.token] == ['1001', '1002', '1003']

    # Delete the middle order; 1002 should be let go and new order takes that number.
    assert service.delete_order(second.token) is True
    assert service.get_order('1002') is None

    fourth = service.create_order(_order_payload('Fourth'))
    assert fourth.token == '1002'

    # Test custom editable token
    custom = service.create_order(OrderCreate(token='CUSTOM-99', company_name='Custom', po_date=date.today()))
    assert custom.token == 'CUSTOM-99'

    # Next automatic token after 1003 (since 1001, 1002, 1003 exist) is 1004
    fifth = service.create_order(_order_payload('Fifth'))
    assert fifth.token == '1004'


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


def test_sequence_fills_available_slots_starting_at_1001():
    session = setup_test_db()
    session.add(Order(token='1001', company_name='Existing', po_date=date.today()))
    session.commit()

    service = OrderService(session)
    assert service.create_order(_order_payload('Next')).token == '1002'


def test_token_and_order_type_editable():
    session = setup_test_db()
    service = OrderService(session)

    order = service.create_order(OrderCreate(
        token='ORD-101',
        company_name='Edit Co',
        po_date=date.today(),
        order_type='Sampling',
    ))
    assert order.token == 'ORD-101'
    assert order.order_type == 'Sampling'

    # Update token and order type
    from app.schemas.order import OrderUpdate
    updated = service.update_order('ORD-101', OrderUpdate(
        token='ORD-102',
        order_type='Stock',
    ))
    assert updated is not None
    assert updated.token == 'ORD-102'
    assert updated.order_type == 'Stock'


def test_order_edit_access_super_admin_only():
    from fastapi.testclient import TestClient
    from sqlalchemy.pool import StaticPool
    from app.main import app
    from app.core.database import Base, get_db
    from app.core.deps import get_current_user
    from app.models.user import User

    engine = create_engine('sqlite:///:memory:', connect_args={'check_same_thread': False}, poolclass=StaticPool)
    Base.metadata.create_all(bind=engine)
    TestingSession = sessionmaker(bind=engine)

    def override_get_db():
        db = TestingSession()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    client = TestClient(app)

    # 1. Seed an order in test DB
    with TestingSession() as session:
        service = OrderService(session)
        service.create_order(OrderCreate(token='BTN-555', company_name='RBAC Co', po_date=date.today()))

    # 2. Test operator (e.g. casting role) attempting to edit order -> HTTP 403 Forbidden
    operator_user = User(id=2, email='operator@test.com', name='Operator', password_hash='hash', role='casting', is_active=True)
    app.dependency_overrides[get_current_user] = lambda: operator_user
    res_operator = client.put('/api/orders/update/BTN-555', json={'company_name': 'Hacked Co'})
    assert res_operator.status_code == 403
    assert 'permission' in res_operator.json()['detail'].lower()

    # 3. Test super_admin editing order -> HTTP 200 OK
    admin_user = User(id=1, email='admin@test.com', name='Admin', password_hash='hash', role='super_admin', is_active=True)
    app.dependency_overrides[get_current_user] = lambda: admin_user
    res_admin = client.put('/api/orders/update/BTN-555', json={'company_name': 'Authorized Admin Edit'})
    assert res_admin.status_code == 200
    assert res_admin.json()['company_name'] == 'Authorized Admin Edit'

    # Cleanup overrides
    app.dependency_overrides.pop(get_current_user, None)
    app.dependency_overrides.pop(get_db, None)

