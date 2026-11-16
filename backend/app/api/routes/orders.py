from datetime import date, datetime
from fastapi import APIRouter, Body, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user, require_roles
from app.core.redis_client import cache_client
from app.models.user import User
from app.schemas.order import (
    BlankingRead,
    CastingRead,
    OrderCreate,
    OrderDispatchRequest,
    OrderRead,
    OrderUpdate,
    PackingRead,
    PolishingRead,
    RawMaterialRead,
    TurningRead,
)
from app.services.order_service import OrderService
from app.services.status_engine import recompute_order_status

router = APIRouter()


def scrub_order_by_role(order_read: OrderRead, role: str) -> OrderRead:
    # All authenticated factory departments need full visibility into
    # process logs for Job Cards, verification, and complete PDF generation.
    return order_read


def safe_validate_order(order, role: str) -> OrderRead:
    try:
        return scrub_order_by_role(OrderRead.model_validate(order), role)
    except Exception:
        fallback_data = {
            'id': getattr(order, 'id', 0),
            'token': getattr(order, 'token', ''),
            'company_name': getattr(order, 'company_name', 'Order'),
            'po_number': getattr(order, 'po_number', None),
            'po_date': getattr(order, 'po_date', date.today()),
            'casting_type': getattr(order, 'casting_type', None),
            'thickness': getattr(order, 'thickness', None),
            'holes': getattr(order, 'holes', None),
            'box_type': getattr(order, 'box_type', None),
            'rate': getattr(order, 'rate', None),
            'quantity': getattr(order, 'quantity', None),
            'weight': getattr(order, 'weight', None),
            'linings': getattr(order, 'linings', None),
            'laser': getattr(order, 'laser', None),
            'polish_type': getattr(order, 'polish_type', None),
            'packing_option': getattr(order, 'packing_option', None),
            'dispatch_date': getattr(order, 'dispatch_date', None),
            'dispatch_quantity': getattr(order, 'dispatch_quantity', None),
            'po_image': getattr(order, 'po_image', None),
            'button_image': getattr(order, 'button_image', None),
            'order_type': getattr(order, 'order_type', 'Production'),
            'sample': getattr(order, 'sample', None),
            'status': getattr(order, 'status', 'In Production'),
            'created_by_id': getattr(order, 'created_by_id', None),
            'created_at': getattr(order, 'created_at', datetime.now()),
            'updated_at': getattr(order, 'updated_at', datetime.now()),
            'raw_materials': [],
            'casting_process': None,
            'blanking_process': None,
            'turning_process': None,
            'polishing_process': None,
            'packing_process': None,
        }
        for rel_name, read_cls in [
            ('casting_process', CastingRead),
            ('blanking_process', BlankingRead),
            ('turning_process', TurningRead),
            ('polishing_process', PolishingRead),
            ('packing_process', PackingRead),
        ]:
            try:
                rel_val = getattr(order, rel_name, None)
                if rel_val:
                    fallback_data[rel_name] = read_cls.model_validate(rel_val)
            except Exception:
                pass
        try:
            rms = getattr(order, 'raw_materials', [])
            if rms:
                fallback_data['raw_materials'] = [RawMaterialRead.model_validate(rm) for rm in rms]
        except Exception:
            pass
        return scrub_order_by_role(OrderRead.model_validate(fallback_data), role)


@router.post('/create', response_model=OrderRead)
def create_order(payload: OrderCreate, request: Request, db: Session = Depends(get_db)) -> OrderRead:
    idempotency_key = request.headers.get('X-Idempotency-Key')
    if idempotency_key and not cache_client.check_idempotency(idempotency_key, ttl=30):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail='Duplicate submission detected. Please wait.',
        )

    service = OrderService(db)
    try:
        order = service.create_order(payload)
        cache_client.delete_pattern('orders:*')
        return OrderRead.model_validate(order)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get('/next-token', response_model=dict)
def get_next_token(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    service = OrderService(db)
    return {'next_token': service.orders.next_token()}


@router.get('/list', response_model=list[OrderRead])
def list_orders(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> list[OrderRead]:
    service = OrderService(db)
    return [safe_validate_order(order, current_user.role) for order in service.list_orders()]


@router.get('/{token}', response_model=OrderRead)
def get_order(token: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return safe_validate_order(order, current_user.role)


@router.put('/update/{token}', response_model=OrderRead, dependencies=[Depends(require_roles('super_admin'))])
def update_order(token: str, payload: OrderUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    try:
        updated = service.update_order(token, payload)
        cache_client.delete_pattern('orders:*')
        return OrderRead.model_validate(updated)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete('/delete/{token}', status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_roles('super_admin'))])
def delete_order(token: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> None:
    service = OrderService(db)
    success = service.delete_order(token)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    cache_client.delete_pattern('orders:*')


@router.post('/dispatch/{token}', response_model=OrderRead, dependencies=[Depends(require_roles('super_admin'))])
def dispatch_order(
    token: str,
    dispatched: bool = Query(True),
    dispatch_quantity: int | None = Query(None),
    payload: OrderDispatchRequest | None = Body(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')

    is_dispatched = payload.dispatched if (payload and payload.dispatched is not None) else dispatched
    qty = payload.dispatch_quantity if (payload and payload.dispatch_quantity is not None) else dispatch_quantity

    if is_dispatched:
        order.status = 'Dispatched'
        if not order.dispatch_date:
            order.dispatch_date = date.today()
        if qty is not None:
            order.dispatch_quantity = qty
        elif order.dispatch_quantity is None:
            order.dispatch_quantity = (
                order.packing_process.packed_qty
                if order.packing_process and order.packing_process.packed_qty
                else order.quantity
            )
    else:
        order.dispatch_date = None
        order.dispatch_quantity = None
        order.status = recompute_order_status(order)
    db.commit()
    db.refresh(order)
    cache_client.delete_pattern('orders:*')
    return OrderRead.model_validate(order)
