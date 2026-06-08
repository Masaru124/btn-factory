# Button Factory

This workspace contains two apps for the Button Factory MES:

- `btn_factory/` - Flutter frontend
- `backend/` - FastAPI backend

## Frontend

The Flutter app lives in `btn_factory/`.

Run it locally:

```powershell
cd btn_factory
flutter pub get
flutter run
```

For web:

```powershell
cd btn_factory
flutter run -d chrome
```

## Backend

The API lives in `backend/`.

Run it locally:

```powershell
cd backend
uvicorn app.main:app --reload --port 8000
```

The backend seeds a demo admin account on startup:

- Email: `admin@example.com`
- Password: `password`

## Notes

- The backend uses a local SQLite database by default.
- The repo-level `.gitignore` excludes Flutter build output, Python caches, virtual environments, and the generated SQLite database.
