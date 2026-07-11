from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user, require_roles
from app.models.user import User
from app.schemas.order import CastingUpdate, PackingUpdate, PolishingUpdate, RawMaterialCreate, RawMaterialBatchCreate, TurningUpdate
from app.services.order_service import OrderService

router = APIRouter()


@router.post('/raw-material/add', dependencies=[Depends(require_roles('super_admin', 'raw_material'))])
def add_raw_material(payload: RawMaterialBatchCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    service = OrderService(db)
    for material in payload.materials:
        single_payload = RawMaterialCreate(
            order_token=payload.order_token,
            material_name=material.material_name,
            quantity=material.quantity,
            unit=material.unit,
            price=material.price,
            created_by_id=current_user.id
        )
        created = service.add_raw_material(single_payload, created_by=current_user.id)
        if created is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return {'order_token': payload.order_token, 'message': 'Raw materials updated'}


@router.post('/casting/update', dependencies=[Depends(require_roles('super_admin', 'casting'))])
def update_casting(payload: CastingUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    service = OrderService(db)
    created = service.update_casting(payload)
    if created is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return {'id': created.id, 'order_token': payload.order_token, 'message': 'Casting updated'}


@router.post('/turning/update', dependencies=[Depends(require_roles('super_admin', 'turning'))])
def update_turning(payload: TurningUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    service = OrderService(db)
    created = service.update_turning(payload)
    if created is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return {'id': created.id, 'order_token': payload.order_token, 'message': 'Turning updated'}


@router.post('/polish/update', dependencies=[Depends(require_roles('super_admin', 'polish'))])
def update_polish(payload: PolishingUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    service = OrderService(db)
    created = service.update_polishing(payload)
    if created is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return {'id': created.id, 'order_token': payload.order_token, 'message': 'Polish updated'}


@router.post('/packing/update', dependencies=[Depends(require_roles('super_admin', 'packing'))])
def update_packing(payload: PackingUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    service = OrderService(db)
    created = service.update_packing(payload)
    if created is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Order not found')
    return {'id': created.id, 'order_token': payload.order_token, 'message': 'Packing updated'}
