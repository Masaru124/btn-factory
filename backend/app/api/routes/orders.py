from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user, require_roles
from app.models.user import User
from app.schemas.order import OrderCreate, OrderRead, OrderUpdate
from app.services.order_service import OrderService

router = APIRouter()


@router.post('/create', response_model=OrderRead)
def create_order(payload: OrderCreate, db: Session = Depends(get_db)) -> OrderRead:
    service = OrderService(db)
    order = service.create_order(payload)
    return OrderRead.model_validate(order)


@router.get('/list', response_model=list[OrderRead])
def list_orders(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> list[OrderRead]:
    service = OrderService(db)
    return [OrderRead.model_validate(order) for order in service.list_orders()]


@router.get('/{token}', response_model=OrderRead)
def get_order(token: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return OrderRead.model_validate(order)


@router.put('/update/{token}', response_model=OrderRead, dependencies=[Depends(require_roles('super_admin'))])
def update_order(token: str, payload: OrderUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    updated = service.update_order(token, payload)
    return OrderRead.model_validate(updated)


@router.delete('/delete/{token}', status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_roles('super_admin'))])
def delete_order(token: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> None:
    service = OrderService(db)
    success = service.delete_order(token)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')


@router.post('/dispatch/{token}', response_model=OrderRead, dependencies=[Depends(require_roles('super_admin'))])
def dispatch_order(token: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> OrderRead:
    service = OrderService(db)
    order = service.get_order(token)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    order.status = 'Dispatched'
    db.commit()
    db.refresh(order)
    return OrderRead.model_validate(order)
