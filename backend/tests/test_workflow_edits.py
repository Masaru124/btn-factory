from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base
from app.models.order import (
    CastingProcess,
    Order,
    OrderStatus,
    PackingProcess,
    PolishingProcess,
    RawMaterial,
    TurningProcess,
    UniversalRawMaterial,
)
from app.schemas.order import (
    BlankingUpdate,
    CastingUpdate,
    OrderCreate,
    PackingUpdate,
    PolishingUpdate,
    RawMaterialCreate,
    TurningUpdate,
    UniversalRawMaterialCreate,
)
from app.services.order_service import OrderService


def setup_test_db():
    engine = create_engine('sqlite:///:memory:', echo=False)
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    return Session()


def test_order_creation_and_universal_raw_materials():
    session = setup_test_db()
    service = OrderService(session)

    # 1. Test Order Creation with casting_type
    order_in = OrderCreate(
        company_name='Test Button Co',
        po_date=datetime.now().date(),
        casting_type='Sheet',
        thickness='1.2 mm',
        holes='4',
    )
    order = service.create_order(order_in)
    assert order.id is not None
    assert order.casting_type == 'Sheet'
    assert order.status == OrderStatus.CREATED.value

    # 2. Test Universal Raw Material creation and listing
    uni_mat = service.upsert_universal_raw_material(
        UniversalRawMaterialCreate(
            material_name='Polyester Resin',
            total_available_quantity=500.0,
            unit='kg',
            price=120.0,
        )
    )
    assert uni_mat.id is not None
    assert uni_mat.total_available_quantity == 500.0

    materials = service.list_universal_raw_materials()
    assert len(materials) == 1
    assert materials[0].material_name == 'Polyester Resin'

    # 3. Test adding Raw Material to order with total_available_quantity
    raw = service.add_raw_material(
        RawMaterialCreate(
            order_token=order.token,
            material_name='Polyester Resin',
            quantity=25.0,
            total_available_quantity=500.0,
            unit='kg',
            price=120.0,
        )
    )
    assert raw is not None
    assert raw.quantity == 25.0
    assert raw.total_available_quantity == 500.0
    assert order.status == OrderStatus.RAW_MATERIAL_UPDATED.value


def test_department_field_normalization():
    session = setup_test_db()
    service = OrderService(session)

    order = service.create_order(
        OrderCreate(
            company_name='Acme Buttons',
            po_date=datetime.now().date(),
            casting_type='Rod',
        )
    )

    # Add raw material so status can progress past Created
    service.add_raw_material(
        RawMaterialCreate(
            order_token=order.token,
            material_name='Test Resin',
            quantity=50.0,
            unit='kg',
            price=100.0,
        )
    )

    # 1. Casting with total_weight, blank_thickness, no_of_sheets, date_of_casting
    now = datetime.now()
    casting = service.update_casting(
        CastingUpdate(
            order_token=order.token,
            casting_type='Rod',
            date_of_casting=now,
            total_weight=45.5,
            blank_thickness='2.5 mm',
            no_of_sheets=12,
            no_of_rods=50,
            rejection_weight=1.5,
            operator='Jane Smith',
            end_time=now,
        )
    )
    assert casting is not None
    assert casting.total_weight == 45.5
    assert casting.weight == 45.5
    assert casting.blank_thickness == '2.5 mm'
    assert casting.thickness == '2.5 mm'
    assert casting.no_of_sheets == 12
    assert casting.no_of_rods == 50
    assert casting.rejection_weight == 1.5
    assert casting.operator == 'Jane Smith'
    assert casting.date_of_casting is not None

    # 1b. Blanking with weight, gross_quantity, rejection_weight, operator, blank_thickness
    blanking = service.update_blanking(
        BlankingUpdate(
            order_token=order.token,
            weight=43.5,
            gross_quantity=450,
            rejection_weight=1.2,
            operator='Bob Wilson',
            blank_thickness='2.5 mm',
            remarks='Smooth cut blanks',
        )
    )
    assert blanking is not None
    assert blanking.weight == 43.5
    assert blanking.gross_quantity == 450
    assert blanking.rejection_weight == 1.2
    assert blanking.operator == 'Bob Wilson'
    assert blanking.blank_thickness == '2.5 mm'
    assert order.status == OrderStatus.BLANKING_COMPLETED.value

    # 2. Turning with tool_no, inward_weight, outward_weight, blank_thickness
    turning = service.update_turning(
        TurningUpdate(
            order_token=order.token,
            tool_no='TOOL-99',
            inward_weight=45.5,
            outward_weight=42.0,
            blank_thickness='2.5 mm',
            machine_no='TURN-1',
        )
    )
    assert turning is not None
    assert turning.tool_no == 'TOOL-99'
    assert turning.art_no == 'TOOL-99'
    assert turning.inward_weight == 45.5
    assert turning.weight == 45.5
    assert turning.outward_weight == 42.0
    assert turning.turned_in_kgs == 42.0
    assert turning.blank_thickness == '2.5 mm'
    assert turning.semi_finish_thickness == '2.5 mm'

    # 3. Polishing with tool_no, inward_weight, outward_weight
    polish = service.update_polishing(
        PolishingUpdate(
            order_token=order.token,
            tool_no='TOOL-99',
            inward_weight=42.0,
            outward_weight=41.2,
            operator='John Doe',
        )
    )
    assert polish is not None
    assert polish.tool_no == 'TOOL-99'
    assert polish.art_no == 'TOOL-99'
    assert polish.inward_weight == 42.0
    assert polish.weight == 42.0
    assert polish.outward_weight == 41.2
    assert polish.operator == 'John Doe'

    # 4. Packing with inward_weight, outward_weight, one_gross_weight
    packing = service.update_packing(
        PackingUpdate(
            order_token=order.token,
            inward_weight=41.2,
            outward_weight=40.8,
            one_gross_weight=0.08,
            in_gross=500,
            packed_qty=500,
        )
    )
    assert packing is not None
    assert packing.inward_weight == 41.2
    assert packing.outward_weight == 40.8
    assert packing.one_gross_weight == 0.08
    assert packing.in_gross == 500
