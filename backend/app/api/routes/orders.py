from datetime import date
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user, require_roles
from app.core.redis_client import cache_client
from app.models.user import User
from app.schemas.order import OrderCreate, OrderRead, OrderUpdate
from app.services.order_service import OrderService
from app.services.status_engine import recompute_order_status

router = APIRouter()


def scrub_order_by_role(order_read: OrderRead, role: str) -> OrderRead:
    # All authenticated factory departments need full visibility into
    # process logs for Job Cards, verification, and complete PDF generation.
    return order_read


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
    return [scrub_order_by_role(OrderRead.model_validate(order), current_user.role) for order in service.list_orders()]


@router.get('/{token}', response_model=OrderRead)
def get_order(token: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return scrub_order_by_role(OrderRead.model_validate(order), current_user.role)


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
    dispatched: bool = True,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    if dispatched:
        order.status = 'Dispatched'
        if not order.dispatch_date:
            order.dispatch_date = date.today()
    else:
        order.dispatch_date = None
        order.status = recompute_order_status(order)
    db.commit()
    db.refresh(order)
    cache_client.delete_pattern('orders:*')
    return OrderRead.model_validate(order)
