from datetime import date, datetime, timezone

from app.models.order import Order, OrderStatus


def determine_order_status(order: Order) -> str:
    has_raw_material = len(order.raw_materials) > 0
    has_casting = order.casting_process is not None and order.casting_process.end_time is not None
    has_turning = order.turning_process is not None
    has_polish = order.polishing_process is not None
    has_packing = order.packing_process is not None

    if not has_raw_material:
        return OrderStatus.CREATED.value
    if not has_casting:
        return OrderStatus.RAW_MATERIAL_UPDATED.value
    if not has_turning:
        return OrderStatus.CASTING_COMPLETED.value
    if not has_polish:
        return OrderStatus.TURNING_COMPLETED.value
    if not has_packing:
        return OrderStatus.POLISHING_COMPLETED.value

    packed_qty = (order.packing_process.packed_qty or 0)
    rejected_qty = order.packing_process.rejected_qty or 0
    short_qty = order.packing_process.short_qty or 0
    excess_qty = order.packing_process.excess_qty or 0
    packing_complete = packed_qty > 0 and packed_qty >= max(rejected_qty, short_qty, excess_qty)

    if not packing_complete:
        return OrderStatus.PACKING_COMPLETED.value

    if order.dispatch_date is not None and order.dispatch_date <= datetime.now(timezone.utc).date():
        return OrderStatus.DISPATCHED.value

    return OrderStatus.READY_TO_DISPATCH.value


def recompute_order_status(order: Order) -> str:
    return determine_order_status(order)
