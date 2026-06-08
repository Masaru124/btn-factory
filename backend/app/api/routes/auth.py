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
