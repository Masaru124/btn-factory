from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.auth import LoginRequest, RefreshRequest, TokenResponse, UserAuthResponse
from app.services.auth_service import AuthService

router = APIRouter()


@router.post('/login', response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    service = AuthService(db)
    user = service.authenticate(payload.email, payload.password)
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


from app.core.deps import get_current_user, require_roles
from app.core.security import get_password_hash
from app.models.user import User
from app.schemas.auth import UserCreate, UserUpdate


@router.post('/register', response_model=UserAuthResponse, dependencies=[Depends(require_roles('super_admin'))])
def register_user(payload: UserCreate, db: Session = Depends(get_db)) -> UserAuthResponse:
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Email already registered')
    
    user = User(
        name=payload.name,
        email=payload.email,
        password_hash=get_password_hash(payload.password),
        role=payload.role,
        department=payload.department,
        is_active=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return UserAuthResponse.model_validate(user)


@router.get('/users', response_model=list[UserAuthResponse], dependencies=[Depends(require_roles('super_admin'))])
def list_users(db: Session = Depends(get_db)) -> list[UserAuthResponse]:
    users = db.query(User).all()
    return [UserAuthResponse.model_validate(u) for u in users]


@router.put('/users/{user_id}', response_model=UserAuthResponse, dependencies=[Depends(require_roles('super_admin'))])
def update_user(user_id: int, payload: UserUpdate, db: Session = Depends(get_db)) -> UserAuthResponse:
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='User not found')

    if payload.name is not None:
        user.name = payload.name
    if payload.email is not None:
        existing = db.query(User).filter(User.email == payload.email, User.id != user_id).first()
        if existing:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Email already in use')
        user.email = payload.email
    if payload.password is not None and payload.password.strip() != "":
        user.password_hash = get_password_hash(payload.password)
    if payload.role is not None:
        user.role = payload.role
    if payload.department is not None:
        user.department = payload.department
    if payload.is_active is not None:
        user.is_active = payload.is_active

    db.commit()
    db.refresh(user)
    return UserAuthResponse.model_validate(user)


@router.delete('/users/{user_id}', status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_roles('super_admin'))])
def delete_user(user_id: int, db: Session = Depends(get_db)) -> None:
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='User not found')
    
    # Deactivate instead of hard delete to keep DB references intact
    user.is_active = False
    db.commit()

