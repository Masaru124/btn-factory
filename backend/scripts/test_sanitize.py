import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from decimal import Decimal
from datetime import date, datetime, timezone
import sqlite3
from sqlalchemy import BigInteger, Date, DateTime, Float, Integer, Numeric, String, Text, create_engine, inspect, text
from dotenv import load_dotenv

from app.core.database import Base, normalize_database_url
import app.models

load_dotenv('backend/.env')

local_pg = os.getenv('LOCAL_POSTGRES_URL')
neon = os.getenv('NEON_DATABASE_URL')

def sanitize_value(col, val):
    if val is None:
        return None
    try:
        py_type = col.type.python_type
    except Exception:
        py_type = None

    if py_type is bool or col.name.startswith('is_'):
        return bool(val)

    if py_type in (float, Decimal) or isinstance(col.type, (Float, Numeric)):
        try:
            return float(val)
        except (ValueError, TypeError):
            return 0.0

    if py_type is int or isinstance(col.type, (Integer, BigInteger)):
        try:
            return int(val)
        except (ValueError, TypeError):
            return 0

    if py_type is datetime or isinstance(col.type, DateTime):
        if isinstance(val, datetime):
            return val
        if isinstance(val, (int, float)):
            return datetime.now(timezone.utc)
        if isinstance(val, str):
            try:
                return datetime.fromisoformat(val.replace('Z', '+00:00'))
            except Exception:
                return datetime.now(timezone.utc)
        return datetime.now(timezone.utc)

    if py_type is date or isinstance(col.type, Date):
        if isinstance(val, date):
            return val
        if isinstance(val, str):
            try:
                return date.fromisoformat(val.split('T')[0].split(' ')[0])
            except Exception:
                return date.today()
        return date.today()

    if py_type is str or isinstance(col.type, (String, Text)):
        return str(val)

    return val

# Test corrupt row sanitization
test_corrupt_row = {'id': 1, 'material_name': 3, 'total_available_quantity': '2026-10-14 10:49:51.164000', 'unit': None, 'price': None, 'created_at': 20, 'updated_at': 20}
table_obj = Base.metadata.tables.get('universal_raw_materials')
clean_row = {k: sanitize_value(table_obj.columns[k], v) for k, v in test_corrupt_row.items() if k in table_obj.columns}
print("Cleaned corrupt row:", clean_row)
assert isinstance(clean_row['total_available_quantity'], float), "Must be float"
assert isinstance(clean_row['created_at'], datetime), "Must be datetime"
assert isinstance(clean_row['material_name'], str), "Must be string"
print("Sanitization test passed!")
