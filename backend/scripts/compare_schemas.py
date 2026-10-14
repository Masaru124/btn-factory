import sqlite3

def get_schemas(db_file):
    conn = sqlite3.connect(db_file)
    c = conn.cursor()
    return dict(c.execute("SELECT name, sql FROM sqlite_master WHERE type='table'").fetchall())

old_schemas = get_schemas('backend/backups/btn_factory_20261014_161121.db')
new_schemas = get_schemas('backend/btn_factory.db')

for t in new_schemas:
    if t in old_schemas and old_schemas[t] != new_schemas[t]:
        print(f"Table {t} CHANGED:")
        print("OLD:", old_schemas[t])
        print("NEW:", new_schemas[t])
    elif t not in old_schemas:
        print(f"Table {t} ADDED")
