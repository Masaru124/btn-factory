import enum
from datetime import date, datetime

from sqlalchemy import Date, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class OrderStatus(str, enum.Enum):
    CREATED = 'Created'
    RAW_MATERIAL_UPDATED = 'Raw Material Updated'
    CASTING_COMPLETED = 'Casting Completed'
    TURNING_COMPLETED = 'Turning Completed'
    POLISHING_COMPLETED = 'Polishing Completed'
    PACKING_COMPLETED = 'Packing Completed'
    READY_TO_DISPATCH = 'Ready To Dispatch'
    DISPATCHED = 'Dispatched'


class Order(Base):
    __tablename__ = 'orders'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    token: Mapped[str] = mapped_column(String(40), unique=True, index=True, nullable=False)
    company_name: Mapped[str] = mapped_column(String(255), nullable=False)
    po_number: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    po_date: Mapped[date] = mapped_column(Date, nullable=False)
    casting_type: Mapped[str | None] = mapped_column(String(80), nullable=True)
    thickness: Mapped[str | None] = mapped_column(String(50), nullable=True)
    holes: Mapped[str | None] = mapped_column(String(50), nullable=True)
    box_type: Mapped[str | None] = mapped_column(String(80), nullable=True)
    rate: Mapped[float | None] = mapped_column(Float, nullable=True)
    quantity: Mapped[int | None] = mapped_column(Integer, nullable=True)
    linings: Mapped[str | None] = mapped_column(String(20), nullable=True)
    laser: Mapped[str | None] = mapped_column(String(20), nullable=True)
    polish_type: Mapped[str | None] = mapped_column(String(80), nullable=True)
    packing_option: Mapped[str | None] = mapped_column(String(80), nullable=True)
    dispatch_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    po_image: Mapped[str | None] = mapped_column(String(500), nullable=True)
    button_image: Mapped[str | None] = mapped_column(String(500), nullable=True)
    status: Mapped[str] = mapped_column(String(60), nullable=False, default=OrderStatus.CREATED.value)
    created_by_id: Mapped[int | None] = mapped_column(ForeignKey('users.id'), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    created_by = relationship('User')
    raw_materials = relationship('RawMaterial', back_populates='order', cascade='all, delete-orphan')
    casting_process = relationship('CastingProcess', back_populates='order', uselist=False, cascade='all, delete-orphan')
    turning_process = relationship('TurningProcess', back_populates='order', uselist=False, cascade='all, delete-orphan')
    polishing_process = relationship('PolishingProcess', back_populates='order', uselist=False, cascade='all, delete-orphan')
    packing_process = relationship('PackingProcess', back_populates='order', uselist=False, cascade='all, delete-orphan')


class RawMaterial(Base):
    __tablename__ = 'raw_materials'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey('orders.id'), nullable=False, index=True)
    material_name: Mapped[str] = mapped_column(String(255), nullable=False)
    quantity: Mapped[float] = mapped_column(Float, nullable=False)
    unit: Mapped[str] = mapped_column(String(40), nullable=False)
    price: Mapped[float] = mapped_column(Float, nullable=False)
    created_by_id: Mapped[int | None] = mapped_column(ForeignKey('users.id'), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    order = relationship('Order', back_populates='raw_materials')
    created_by = relationship('User')


class CastingProcess(Base):
    __tablename__ = 'casting_process'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey('orders.id'), nullable=False, index=True)
    sheet_type: Mapped[str | None] = mapped_column(String(100), nullable=True)
    weight: Mapped[float | None] = mapped_column(Float, nullable=True)
    thickness: Mapped[str | None] = mapped_column(String(50), nullable=True)
    gross_quantity: Mapped[int | None] = mapped_column(Integer, nullable=True)
    machine_no: Mapped[str | None] = mapped_column(String(80), nullable=True)
    start_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    end_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    remarks: Mapped[str | None] = mapped_column(Text, nullable=True)

    order = relationship('Order', back_populates='casting_process')


class TurningProcess(Base):
    __tablename__ = 'turning_process'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey('orders.id'), nullable=False, index=True)
    machine_no: Mapped[str | None] = mapped_column(String(80), nullable=True)
    hole_size: Mapped[str | None] = mapped_column(String(80), nullable=True)
    weight: Mapped[float | None] = mapped_column(Float, nullable=True)
    gross_quantity: Mapped[int | None] = mapped_column(Integer, nullable=True)
    semi_finish_thickness: Mapped[str | None] = mapped_column(String(50), nullable=True)
    finish_thickness: Mapped[str | None] = mapped_column(String(50), nullable=True)
    remarks: Mapped[str | None] = mapped_column(Text, nullable=True)

    order = relationship('Order', back_populates='turning_process')


class PolishingProcess(Base):
    __tablename__ = 'polishing_process'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey('orders.id'), nullable=False, index=True)
    polish_type: Mapped[str | None] = mapped_column(String(100), nullable=True)
    feeding_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    out_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    operator: Mapped[str | None] = mapped_column(String(120), nullable=True)
    gross_quantity: Mapped[int | None] = mapped_column(Integer, nullable=True)
    remarks: Mapped[str | None] = mapped_column(Text, nullable=True)

    order = relationship('Order', back_populates='polishing_process')


class PackingProcess(Base):
    __tablename__ = 'packing_process'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey('orders.id'), nullable=False, index=True)
    packed_qty: Mapped[int | None] = mapped_column(Integer, nullable=True)
    rejected_qty: Mapped[int | None] = mapped_column(Integer, nullable=True)
    short_qty: Mapped[int | None] = mapped_column(Integer, nullable=True)
    excess_qty: Mapped[int | None] = mapped_column(Integer, nullable=True)
    remarks: Mapped[str | None] = mapped_column(Text, nullable=True)

    order = relationship('Order', back_populates='packing_process')
