# Button Factory MES

A modern Manufacturing Execution System (MES) consisting of a **Flutter Web/Mobile frontend** and a **FastAPI backend** with a **3-tier multi-database architecture** (SQLite, Local PostgreSQL, and Neon Cloud Serverless PostgreSQL).

---

## Quick Start (1-Click Triple Launcher)

Double-click `Launch_Button_Factory.bat` in the project root (or `backend/Launch_Backend.bat`).

This opens 3 terminals simultaneously:
1. **FastAPI Backend Server**: Running locally at `http://127.0.0.1:8000` (Swagger docs at `/docs`).
2. **ngrok Tunnel**: Providing a public `https://*.ngrok-free.app` URL.
3. **Cloudflare Tunnel**: Providing a 100% free, unlimited public `https://*.trycloudflare.com` URL (no account or custom domain needed).

---

## Cloudflare Tunnel (`cloudflared`) Installation Guide

If `cloudflared` is not installed on your or your teammate's computer, follow any of these options:

### Option 1: Via Windows Terminal (Recommended - 1 Command)
Open PowerShell or Command Prompt and run:
```powershell
winget install --id Cloudflare.cloudflared
```
*Restart your terminal or batch launcher after the installation completes.*

### Option 2: Direct Download from GitHub Releases
1. Go to the official Cloudflare releases page:  
   👉 **[https://github.com/cloudflare/cloudflared/releases/latest](https://github.com/cloudflare/cloudflared/releases/latest)**
2. Download **`cloudflared-windows-amd64.msi`** and run the installer.
3. *Alternative portable setup:* Download **`cloudflared-windows-amd64.exe`**, rename it to **`cloudflared.exe`**, and paste it directly into this project's root folder or `backend/` folder. The launcher will detect it automatically!

### Option 3: Zero-Install Fallback (Built-in Windows SSH)
If you cannot download or install software on a restricted machine, Windows has built-in OpenSSH that creates a free instant public tunnel without any downloads:
```powershell
ssh -o StrictHostKeyChecking=no -R 80:localhost:8000 nokey@localhost.run
```
*(The launcher automatically falls back to this if `cloudflared` is missing).*

---

## Multi-Tier Database Setup (SQLite, PostgreSQL, Neon Cloud)

Configure credentials in `backend/.env` (see `backend/.env.example` for reference):

```env
# Tier 1: Embedded SQLite (Local edge / Air-gapped fallback)
SQLITE_DATABASE_URL=sqlite:///./btn_factory.db

# Tier 2: Local PostgreSQL (On-Premises Factory Main Database)
LOCAL_POSTGRES_URL=postgresql://postgres:password@localhost:5432/btn_factory

# Tier 3: Neon Serverless Cloud PostgreSQL (Disaster Recovery / Backup)
NEON_DATABASE_URL=postgresql://neondb_owner:password@ep-xxxx.us-east-2.aws.neon.tech/neondb?sslmode=require

# Select Active Database Tier: sqlite | postgres | neon
ACTIVE_DB_TIER=sqlite
```

### 1-Click PostgreSQL Auto-Setup & Table Creator:
To automatically find local PostgreSQL credentials, create the `btn_factory` database, create all tables, seed the default admin, and update `.env` on ANY system:
```powershell
# Option A: 1-Click Batch file
Setup_Postgres.bat

# Option B: Python CLI (cross-platform)
python backend/scripts/setup_local_postgres.py

# Optional: To immediately set PostgreSQL as active primary database:
python backend/scripts/setup_local_postgres.py --set-active
```

### Test All 3 DB Connections:
Run the connection and latency diagnostic tool:
```powershell
cd backend
python scripts/test_db_connections.py
```
Or check real-time JSON diagnostics in your browser:
```text
http://127.0.0.1:8000/api/diagnostics/databases
```

---

## Manual Execution

### Backend (FastAPI)
```powershell
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --port 8000 --reload
```
Default credentials seeded on first startup:
- **Email**: `admin@example.com`
- **Password**: `password`

### Frontend (Flutter Web)
```powershell
cd btn_factory
flutter pub get
flutter run -d chrome
```

For production web deployment via Caddy:
```powershell
cd btn_factory
flutter build web --release
```
Caddy will serve the compiled bundle from `btn_factory/build/web` on port `80`.
