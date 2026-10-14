from datetime import date, datetime, timezone

from app.models.order import Order, OrderStatus


def determine_order_status(order: Order) -> str:
    has_raw_material = len(order.raw_materials) > 0 if getattr(order, 'raw_materials', None) is not None else False
    has_casting = order.casting_process is not None
    has_blanking = getattr(order, 'blanking_process', None) is not None
    has_turning = order.turning_process is not None
    has_polish = order.polishing_process is not None
    has_packing = order.packing_process is not None

    if not has_raw_material and not has_casting and not has_turning and not has_polish and not has_packing:
        return OrderStatus.CREATED.value
    if not has_casting and not has_turning and not has_polish and not has_packing:
        return OrderStatus.RAW_MATERIAL_UPDATED.value
    if not has_turning and not has_polish and not has_packing:
        if has_blanking:
            return OrderStatus.BLANKING_COMPLETED.value
        return OrderStatus.CASTING_COMPLETED.value
    if not has_polish and not has_packing:
        return OrderStatus.TURNING_COMPLETED.value
    if not has_packing:
        return OrderStatus.POLISHING_COMPLETED.value

    # Packing process is recorded and completed
    if order.dispatch_date is not None and order.dispatch_date <= datetime.now(timezone.utc).date():
        return OrderStatus.DISPATCHED.value

    return OrderStatus.READY_TO_DISPATCH.value


def recompute_order_status(order: Order) -> str:
    return determine_order_status(order)
