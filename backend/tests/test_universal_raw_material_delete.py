from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base
from app.models.order import UniversalRawMaterial
from app.schemas.order import UniversalRawMaterialCreate
from app.services.order_service import OrderService


def setup_test_db():
    engine = create_engine('sqlite:///:memory:', echo=False)
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    return Session()


def test_upsert_and_delete_universal_raw_material():
    session = setup_test_db()
    service = OrderService(session)

    # 1. Create universal raw material
    created = service.upsert_universal_raw_material(
        UniversalRawMaterialCreate(
            material_name='Copper Rod 10mm',
            total_available_quantity=500.0,
            unit='kg',
            price=450.0,
        )
    )
    assert created.id is not None
    assert created.material_name == 'Copper Rod 10mm'
    assert created.total_available_quantity == 500.0

    # 2. Verify it shows up in list
    items = service.list_universal_raw_materials()
    assert len(items) == 1
    assert items[0].id == created.id

    # 3. Delete non-existent returns False
    assert service.delete_universal_raw_material(99999) is False

    # 4. Delete existing returns True and removes record
    assert service.delete_universal_raw_material(created.id) is True
    assert len(service.list_universal_raw_materials()) == 0
    assert session.get(UniversalRawMaterial, created.id) is None
