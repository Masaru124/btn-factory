from uuid import uuid4
from datetime import date

from app.core.database import engine, SessionLocal, Base
from app.core.security import get_password_hash
from app.models.user import User, UserRole
from app.models.order import Order


def run_seed() -> None:
    print('Creating database tables...')
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        # create admin user if not exists
        admin = db.query(User).filter(User.email == 'admin@example.com').first()
        if admin is None:
            admin = User(
                name='Admin',
                email='admin@example.com',
                password_hash=get_password_hash('password'),
                role=UserRole.SUPER_ADMIN.value,
                department='admin',
            )
            db.add(admin)
            db.commit()
            db.refresh(admin)
            print('Created admin user: admin@example.com / password')
        else:
            print('Admin user already exists')

        # create a sample order
        existing = db.query(Order).filter(Order.po_number == 'PO-0001').first()
        if existing is None:
            order = Order(
                token=uuid4().hex[:20],
                company_name='Seed Co',
                po_number='PO-0001',
                po_date=date.today(),
                casting_type='Pressed',
                thickness='1.2 mm',
                holes='4',
                box_type='Export',
                rate=10.5,
                quantity=1000,
                linings='No',
                laser='Yes',
                polish_type='Mirror',
                packing_option='Carton',
                dispatch_date=None,
                po_image=None,
                button_image=None,
                created_by_id=admin.id,
            )
            db.add(order)
            db.commit()
            print('Created sample order PO-0001')
        else:
            print('Sample order already exists')

    finally:
        db.close()


if __name__ == '__main__':
    run_seed()
