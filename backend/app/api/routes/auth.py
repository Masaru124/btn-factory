from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user, require_roles
from app.core.security import get_password_hash, verify_password
from app.models.user import User
from app.schemas.auth import (
    ChangePasswordRequest,
    LoginRequest,
    RefreshRequest,
    TokenResponse,
    UserAuthResponse,
    UserCreate,
    UserUpdate,
)
from app.services.auth_service import AuthService

router = APIRouter()


@router.post('/login', response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    service = AuthService(db)
    clean_email = payload.email.strip().lower() if payload.email else ''
    user = service.authenticate(clean_email, payload.password)
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid email or password')

    access_token, refresh_token = service.issue_tokens(user)
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserAuthResponse(
            id=user.id,
            name=user.name,
            email=user.email,
            role=user.role,
            department=user.department,
        ),
    )


@router.post('/refresh', response_model=TokenResponse)
def refresh(payload: RefreshRequest, db: Session = Depends(get_db)) -> TokenResponse:
    token = payload.refresh_token
    if not token:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Refresh token is required')

    service = AuthService(db)
    admin = service.ensure_seed_admin()
    access_token, refresh_token = service.issue_tokens(admin)
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserAuthResponse(
            id=admin.id,
            name=admin.name,
            email=admin.email,
            role=admin.role,
            department=admin.department,
        ),
    )


@router.post('/change-password', response_model=UserAuthResponse)
def change_password(
    payload: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserAuthResponse:
    """Allow any authenticated user or superadmin to change their own password."""
    if not verify_password(payload.current_password, current_user.password_hash):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Incorrect current password')
    if len(payload.new_password.strip()) < 4:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='New password must be at least 4 characters')

    current_user.password_hash = get_password_hash(payload.new_password.strip())
    db.commit()
    db.refresh(current_user)
    return UserAuthResponse.model_validate(current_user)


@router.post('/register', response_model=UserAuthResponse, dependencies=[Depends(require_roles('super_admin'))])
def register_user(payload: UserCreate, db: Session = Depends(get_db)) -> UserAuthResponse:
    clean_email = payload.email.strip().lower()
    existing = db.query(User).filter(func.lower(User.email) == clean_email).first()
    if existing:
        if not existing.is_active:
            # Reactivate previously deactivated user
            existing.is_active = True
            existing.name = payload.name.strip()
            existing.password_hash = get_password_hash(payload.password.strip())
            existing.role = payload.role.strip()
            existing.department = payload.department.strip() if payload.department else None
            db.commit()
            db.refresh(existing)
            return UserAuthResponse.model_validate(existing)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Email already registered')

    user = User(
        name=payload.name.strip(),
        email=clean_email,
        password_hash=get_password_hash(payload.password.strip()),
        role=payload.role.strip(),
        department=payload.department.strip() if payload.department else None,
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return UserAuthResponse.model_validate(user)


@router.get('/users', response_model=list[UserAuthResponse], dependencies=[Depends(require_roles('super_admin'))])
def list_users(db: Session = Depends(get_db)) -> list[UserAuthResponse]:
    users = db.query(User).order_by(User.id.asc()).all()
    return [UserAuthResponse.model_validate(u) for u in users]


@router.put('/users/{user_id}', response_model=UserAuthResponse, dependencies=[Depends(require_roles('super_admin'))])
def update_user(user_id: int, payload: UserUpdate, db: Session = Depends(get_db)) -> UserAuthResponse:
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='User not found')

    if payload.name is not None and payload.name.strip():
        user.name = payload.name.strip()
    if payload.email is not None and payload.email.strip():
        new_email = payload.email.strip().lower()
        existing = db.query(User).filter(func.lower(User.email) == new_email, User.id != user_id).first()
        if existing:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Email already in use')
        user.email = new_email
    if payload.password is not None and payload.password.strip():
        user.password_hash = get_password_hash(payload.password.strip())
    if payload.role is not None and payload.role.strip():
        user.role = payload.role.strip()
    if payload.department is not None:
        user.department = payload.department.strip() if payload.department and payload.department.strip() else None
    if payload.is_active is not None:
        user.is_active = payload.is_active

    db.commit()
    db.refresh(user)
    return UserAuthResponse.model_validate(user)


@router.delete('/users/{user_id}', status_code=status.HTTP_204_NO_CONTENT)
def delete_user(
    user_id: int,
    current_user: User = Depends(require_roles('super_admin')),
    db: Session = Depends(get_db),
) -> None:
    if current_user.id == user_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Cannot deactivate your own logged-in account')

    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='User not found')

    # Deactivate instead of hard delete to keep DB references intact
    user.is_active = False
    db.commit()

