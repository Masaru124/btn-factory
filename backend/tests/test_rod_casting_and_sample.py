from datetime import datetime, date
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base
from app.models.order import OrderStatus
from app.schemas.order import OrderCreate, OrderUpdate, CastingUpdate
from app.services.order_service import OrderService


def setup_test_db():
    engine = create_engine('sqlite:///:memory:')
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    return Session()


def test_order_creation_with_sample_and_rod_casting():
    session = setup_test_db()
    service = OrderService(session)

    # 1. Create order with separate sample field and casting_type Rod
    order_in = OrderCreate(
        company_name='Imperial Button Works',
        po_date=date.today(),
        casting_type='Rod',
        sample='Golden Vintage Sample Rod #07',
        thickness='2.0 mm',
        holes='4',
        box_type='DD',
        rate=52.0,
        quantity=8000,
        order_type='Sampling',
    )
    order = service.create_order(order_in)
    assert order.id is not None
    assert order.token == '1001'
    assert order.sample == 'Golden Vintage Sample Rod #07'
    assert order.casting_type == 'Rod'
    assert order.status == OrderStatus.CREATED.value

    # 2. Update Rod Casting process with physical sheet fields
    casting_update = CastingUpdate(
        order_token='1001',
        casting_type='Rod',
        sheet='S-14',
        line='L-2',
        total_resin=38.5,
        blank_thickness='2.0 mm',
        remarks='Tested first rod run with standard resin',
        date_of_casting=datetime.utcnow(),
        no_of_rods=95,
        gross_quantity=8200,
        operator='Mahesh Patel',
    )
    casting = service.update_casting(casting_update)
    assert casting is not None
    assert casting.sheet == 'S-14'
    assert casting.line == 'L-2'
    assert casting.total_resin == 38.5
    assert casting.blank_thickness == '2.0 mm'
    assert casting.no_of_rods == 95
    assert casting.gross_quantity == 8200
    assert casting.operator == 'Mahesh Patel'
    assert casting.remarks == 'Tested first rod run with standard resin'

    # 3. Verify order query includes sample and casting details
    refetched = service.get_order('1001')
    assert refetched is not None
    assert refetched.sample == 'Golden Vintage Sample Rod #07'
    assert refetched.casting_process is not None
    assert refetched.casting_process.sheet == 'S-14'
    assert refetched.casting_process.total_resin == 38.5
    assert refetched.casting_process.operator == 'Mahesh Patel'
