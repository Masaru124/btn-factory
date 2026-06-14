from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.order import Order, OrderStatus, RawMaterial
from app.models.user import User

router = APIRouter()


@router.get('/dashboard')
def dashboard_stats(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    """Return real-time dashboard metrics computed from the database."""
    total_orders = db.query(func.count(Order.id)).scalar() or 0

    # "Pending" = Created or Raw Material Updated (not yet in production)
    pending_orders = (
        db.query(func.count(Order.id))
        .filter(Order.status.in_([
            OrderStatus.CREATED.value,
            OrderStatus.RAW_MATERIAL_UPDATED.value,
        ]))
        .scalar()
    ) or 0

    # "Completed" = Ready To Dispatch or Dispatched
    completed_orders = (
        db.query(func.count(Order.id))
        .filter(Order.status.in_([
            OrderStatus.READY_TO_DISPATCH.value,
            OrderStatus.DISPATCHED.value,
        ]))
        .scalar()
    ) or 0

    # "Processing" = everything in between
    processing_orders = total_orders - pending_orders - completed_orders

    # Revenue = sum of (rate * quantity) for all orders that have both values
    revenue = (
        db.query(func.sum(Order.rate * Order.quantity))
        .filter(Order.rate.isnot(None), Order.quantity.isnot(None))
        .scalar()
    ) or 0.0

    # Total material cost
    material_cost = db.query(func.sum(RawMaterial.price)).scalar() or 0.0

    return {
        'total_orders': total_orders,
        'pending_orders': pending_orders,
        'processing_orders': processing_orders,
        'completed_orders': completed_orders,
        'revenue': round(float(revenue), 2),
        'material_cost': round(float(material_cost), 2),
    }


@router.get('/orders-trend')
def orders_trend(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    """Monthly order counts from the database."""
    from sqlalchemy import extract

    rows = (
        db.query(
            extract('month', Order.created_at).label('month'),
            func.count(Order.id).label('count'),
        )
        .group_by('month')
        .order_by('month')
        .all()
    )

    month_names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    points = [
        {'label': month_names[int(row.month)], 'value': row.count}
        for row in rows
    ]

    return {'title': 'Orders Trend', 'points': points}


@router.get('/production-trend')
def production_trend(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> dict:
    """Per-status breakdown from the database."""
    rows = (
        db.query(Order.status, func.count(Order.id).label('count'))
        .group_by(Order.status)
        .all()
    )

    points = [{'label': row.status, 'value': row.count} for row in rows]
    return {'title': 'Production Trend', 'points': points}
