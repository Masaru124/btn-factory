from types import SimpleNamespace

from app.models.order import OrderStatus
from app.services.status_engine import determine_order_status


def make_order(**overrides):
    defaults = {
        'raw_materials': [],
        'casting_process': None,
        'blanking_process': None,
        'turning_process': None,
        'polishing_process': None,
        'packing_process': None,
        'dispatch_date': None,
    }
    defaults.update(overrides)
    return SimpleNamespace(**defaults)


def test_status_progression_matches_workflow() -> None:
    order = make_order()
    assert determine_order_status(order) == OrderStatus.CREATED.value

    order = make_order(raw_materials=[SimpleNamespace(id=1)])
    assert determine_order_status(order) == OrderStatus.RAW_MATERIAL_UPDATED.value

    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time='2026-06-07T10:00:00Z'),
    )
    assert determine_order_status(order) == OrderStatus.CASTING_COMPLETED.value

    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time='2026-06-07T10:00:00Z'),
        blanking_process=SimpleNamespace(id=15),
    )
    assert determine_order_status(order) == OrderStatus.BLANKING_COMPLETED.value

    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time='2026-06-07T10:00:00Z'),
        turning_process=SimpleNamespace(id=2),
    )
    assert determine_order_status(order) == OrderStatus.TURNING_COMPLETED.value

    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time='2026-06-07T10:00:00Z'),
        turning_process=SimpleNamespace(id=2),
        polishing_process=SimpleNamespace(id=3),
    )
    assert determine_order_status(order) == OrderStatus.POLISHING_COMPLETED.value

    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time='2026-06-07T10:00:00Z'),
        turning_process=SimpleNamespace(id=2),
        polishing_process=SimpleNamespace(id=3),
        packing_process=SimpleNamespace(id=4, packed_qty=100, rejected_qty=10, short_qty=5, excess_qty=0),
    )
    # packing_complete is true: packed_qty (100) > 0 and 100 >= max(10, 5, 0)
    # since dispatch_date is None, returns READY_TO_DISPATCH
    assert determine_order_status(order) == OrderStatus.READY_TO_DISPATCH.value

    from datetime import date, timedelta
    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time='2026-06-07T10:00:00Z'),
        turning_process=SimpleNamespace(id=2),
        polishing_process=SimpleNamespace(id=3),
        packing_process=SimpleNamespace(id=4, packed_qty=100, rejected_qty=10, short_qty=5, excess_qty=0),
        dispatch_date=date.today() - timedelta(days=1),
    )
    assert determine_order_status(order) == OrderStatus.DISPATCHED.value


def test_status_with_null_end_time_progresses_correctly() -> None:
    # In the real application, casting forms don't capture end_time.
    # Casting must progress to CASTING_COMPLETED even when end_time is None.
    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time=None, gross_quantity=None, no_of_sheets=5),
    )
    assert determine_order_status(order) == OrderStatus.CASTING_COMPLETED.value

    # Full manufacturing sequence completed
    order = make_order(
        raw_materials=[SimpleNamespace(id=1)],
        casting_process=SimpleNamespace(end_time=None),
        turning_process=SimpleNamespace(id=2),
        polishing_process=SimpleNamespace(id=3),
        packing_process=SimpleNamespace(id=4, packed_qty=50),
    )
    assert determine_order_status(order) == OrderStatus.READY_TO_DISPATCH.value


def test_reports_summary_with_completed_order() -> None:
    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker
    from app.core.database import Base
    from app.models.order import (
        BlankingProcess,
        CastingProcess,
        Order,
        PackingProcess,
        PolishingProcess,
        TurningProcess,
    )
    from app.services.report_service import ReportService
    from datetime import date

    engine = create_engine('sqlite:///:memory:', echo=False)
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    session = Session()

    # Create an order with all departments completed
    order = Order(
        token='TEST-101',
        company_name='Premier Buttons',
        po_date=date.today(),
        quantity=500,
        rate=2.5,
        status='Raw Material Updated',  # Previously stuck status
    )
    session.add(order)
    session.flush()

    casting = CastingProcess(order_id=order.id, casting_type='Sheet', no_of_sheets=10, end_time=None)
    blanking = BlankingProcess(order_id=order.id, gross_quantity=480)
    turning = TurningProcess(order_id=order.id, gross_quantity=475)
    polish = PolishingProcess(order_id=order.id, gross_quantity=470)
    packing = PackingProcess(order_id=order.id, packed_qty=460, in_gross=460, rejected_qty=10)

    session.add_all([casting, blanking, turning, polish, packing])
    session.commit()

    report_service = ReportService(session)
    summary = report_service.reports_summary()

    # 1. Status auto-repair verified
    refreshed_order = session.query(Order).filter(Order.id == order.id).first()
    assert refreshed_order.status == OrderStatus.READY_TO_DISPATCH.value

    # 2. Production output metrics are non-zero and accurate
    prod = summary['production']
    assert prod['completed_orders'] == 1
    assert prod['casting_output'] == 480  # Coalesced from blanking gross
    assert prod['turning_output'] == 475
    assert prod['polishing_output'] == 470
    assert prod['packing_output'] == 460
