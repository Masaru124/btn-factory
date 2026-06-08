from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field


class OrderBase(BaseModel):
    company_name: str
    po_number: str
    po_date: date
    casting_type: str | None = None
    thickness: str | None = None
    holes: str | None = None
    box_type: str | None = None
    rate: float | None = None
    quantity: int | None = None
    linings: str | None = None
    laser: str | None = None
    polish_type: str | None = None
    packing_option: str | None = None
    dispatch_date: date | None = None
    po_image: str | None = None
    button_image: str | None = None


class OrderCreate(OrderBase):
    created_by_id: int | None = None


class OrderUpdate(BaseModel):
    company_name: str | None = None
    po_number: str | None = None
    po_date: date | None = None
    casting_type: str | None = None
    thickness: str | None = None
    holes: str | None = None
    box_type: str | None = None
    rate: float | None = None
    quantity: int | None = None
    linings: str | None = None
    laser: str | None = None
    polish_type: str | None = None
    packing_option: str | None = None
    dispatch_date: date | None = None
    po_image: str | None = None
    button_image: str | None = None


class RawMaterialCreate(BaseModel):
    order_token: str
    material_name: str
    quantity: float
    unit: str
    price: float
    created_by_id: int | None = None


class CastingUpdate(BaseModel):
    order_token: str
    sheet_type: str | None = None
    weight: float | None = None
    thickness: str | None = None
    gross_quantity: int | None = None
    machine_no: str | None = None
    start_time: datetime | None = None
    end_time: datetime | None = None
    remarks: str | None = None


class TurningUpdate(BaseModel):
    order_token: str
    machine_no: str | None = None
    hole_size: str | None = None
    weight: float | None = None
    gross_quantity: int | None = None
    semi_finish_thickness: str | None = None
    finish_thickness: str | None = None
    remarks: str | None = None


class PolishingUpdate(BaseModel):
    order_token: str
    polish_type: str | None = None
    feeding_time: datetime | None = None
    out_time: datetime | None = None
    operator: str | None = None
    gross_quantity: int | None = None
    remarks: str | None = None


class PackingUpdate(BaseModel):
    order_token: str
    packed_qty: int | None = None
    rejected_qty: int | None = None
    short_qty: int | None = None
    excess_qty: int | None = None
    remarks: str | None = None


class OrderRead(OrderBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    token: str
    status: str
    created_by_id: int | None = None
    created_at: datetime
    updated_at: datetime


class OrderListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    token: str
    company_name: str
    po_number: str
    status: str
    created_at: datetime


class OrderStatusResponse(BaseModel):
    token: str
    status: str
    message: str = Field(default='Status updated')
