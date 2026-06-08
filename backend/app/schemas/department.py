from pydantic import BaseModel

from app.schemas.order import CastingUpdate, PackingUpdate, PolishingUpdate, RawMaterialCreate, TurningUpdate


class DepartmentTokenPayload(BaseModel):
    token: str


class RawMaterialUpdateRequest(BaseModel):
    token: str
    payload: RawMaterialCreate


class CastingUpdateRequest(BaseModel):
    token: str
    payload: CastingUpdate


class TurningUpdateRequest(BaseModel):
    token: str
    payload: TurningUpdate


class PolishUpdateRequest(BaseModel):
    token: str
    payload: PolishingUpdate


class PackingUpdateRequest(BaseModel):
    token: str
    payload: PackingUpdate
