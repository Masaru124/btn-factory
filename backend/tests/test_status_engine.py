from types import SimpleNamespace

from app.models.order import OrderStatus
from app.services.status_engine import determine_order_status


def make_order(**overrides):
    defaults = {
        'raw_materials': [],
        'casting_process': None,
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
