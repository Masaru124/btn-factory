# 🚀 Complete Free Self-Hosting & Deployment Guide

This guide explains how to host both the **FastAPI Backend** and the **Flutter Web Frontend** completely **for free**, ensure **100% persistent storage**, and make the system accessible to anyone on the internet.

---

## 💾 Part 1: How Storage Persistence Works

### 1. Frontend Session & Token Persistence
* **What was changed**: On Flutter Web, authentication tokens previously used an in-memory store that wiped logins on every browser reload.
* **Now**: The app automatically uses **Browser LocalStorage** (`SharedPreferencesStorageAdapter`) on Web and hardware Keychain/Keystore on Mobile/Desktop.
* **Result**: Logins, tokens, and active sessions now persist across page reloads, tab closes, and browser restarts.

### 2. Backend Database Persistence
* **When using Docker / VPS / Local**:
  The SQLite database is now stored in `/app/data/btn_factory.db`. The Docker container declares a named volume `backend_data` mapped to `/app/data`. Even if the container stops, restarts, or is rebuilt, your database **never gets erased**.
* **When using Free Cloud Hosting**:
  You can connect a free PostgreSQL database (e.g., [Neon.tech](https://neon.tech) or [Supabase](https://supabase.com)) simply by setting the `DATABASE_URL` environment variable. `psycopg2-binary` is already installed in the backend.

---

## 🌐 Option A: 100% Free Cloud Hosting (Recommended)

Run everything 24/7 in the cloud without keeping your personal computer turned on.

```
┌─────────────────────────────────────────────────────────────┐
│                 FREE ARCHITECTURE OVERVIEW                  │
│                                                             │
│  [ Users Anywhere ]                                         │
│          │                                                  │
│          ▼                                                  │
│  [ Vercel / Netlify / Cloudflare Pages ] (Flutter Web App)  │
│          │                                                  │
│          ▼  HTTPS API Requests                              │
│  [ Render.com / Koyeb ] (FastAPI Python Backend)            │
│          │                                                  │
│          ▼                                                  │
│  [ Neon.tech / Render Disk ] (Persistent PostgreSQL / SQLite│
└─────────────────────────────────────────────────────────────┘
```

### Step 1: Free Persistent Database (Neon.tech)
1. Go to [neon.tech](https://neon.tech) and sign up for a free account.
2. Create a project named `btn-factory`.
3. Copy the **Postgres Connection URI** (e.g., `postgresql://user:password@ep-xyz.aws.neon.tech/neondb?sslmode=require`).

---

### Step 2: Deploy Backend to Render.com (Free)
1. Go to [render.com](https://render.com) and log in with GitHub.
2. Click **New +** → **Web Service**.
3. Select your repository: `Masaru124/btn-factory`.
4. Fill in the settings:
   - **Name**: `btn-factory-api`
   - **Root Directory**: `backend`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port 8000`
   - **Plan**: `Free`
5. Click **Advanced** → **Add Environment Variable**:
   - `DATABASE_URL`: *(paste the Postgres URI from Step 1)*
   - `SECRET_KEY`: *(enter a random 32+ character string)*
   - `CORS_ORIGINS`: `*`
6. Click **Create Web Service**.
7. Once deployed, Render will give you a public URL, for example:  
   `https://btn-factory-api.onrender.com`

---

### Step 3: Deploy Frontend to Vercel or Netlify (Free)

#### Using Vercel:
1. Build the Flutter Web application locally pointing to your Render backend:
   ```bash
   cd btn_factory
   flutter build web --release --dart-define=API_BASE_URL=https://btn-factory-api.onrender.com/api
   ```
2. You can deploy the generated `btn_factory/build/web` folder directly:
   - Install Vercel CLI (or drag-and-drop into [vercel.com](https://vercel.com)):
     ```bash
     cd build/web
     npx vercel deploy --prod
     ```
   - Alternatively, link your GitHub repository to Vercel or Netlify:
     - **Framework Preset**: Other
     - **Build Command**: `flutter/bin/flutter build web --release --dart-define=API_BASE_URL=https://btn-factory-api.onrender.com/api`
     - **Output Directory**: `btn_factory/build/web`

#### Using GitHub Pages:
You can also enable GitHub Pages for `Masaru124/btn-factory`:
1. Build web with base href:
   ```bash
   flutter build web --release --base-href "/btn-factory/" --dart-define=API_BASE_URL=https://btn-factory-api.onrender.com/api
   ```
2. Deploy the `build/web` directory to the `gh-pages` branch.

---

## 🖥️ Option B: Self-Host On Your Own Machine / VPS (Free via Docker & Cloudflare Tunnel)

If you prefer to run the server on your own PC, home lab, or a free VPS and share it with anyone globally without exposing your IP or port forwarding:

### 1. Run Backend with Docker Compose
From the project root:
```bash
docker compose up -d --build
```
* The backend is running on `http://localhost:8000`.
* The database is stored in the Docker volume `backend_data` (persisted on disk).

### 2. Make it Globally Accessible for Free using Cloudflare Tunnel
1. Download [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/).
2. Run a quick tunnel to your backend port:
   ```bash
   cloudflared tunnel --url http://localhost:8000
   ```
3. Cloudflare will give you a free, public HTTPS URL (e.g., `https://random-words.trycloudflare.com`).
4. Anyone on the internet can now access the API securely over HTTPS!

### 3. Build & Serve the Frontend Web App
1. Build the web app pointing to your Cloudflare Tunnel backend URL:
   ```bash
   cd btn_factory
   flutter build web --release --dart-define=API_BASE_URL=https://random-words.trycloudflare.com/api
   ```
2. Serve the `btn_factory/build/web` folder using any static server or Python:
   ```bash
   cd build/web
   python -m http.server 3000
   ```
3. Expose the web frontend via Cloudflare Tunnel as well:
   ```bash
   cloudflared tunnel --url http://localhost:3000
   ```
Now you have two public HTTPS links (Frontend + Backend) that anyone on the web can use simultaneously.

---

## 👤 Default Initial Login Credentials

Upon the first startup, the backend automatically seeds the super administrator account:
- **Email**: `admin@factory.com`
- **Password**: `Admin@123`
- **Role**: `super_admin`

Once logged in as Super Admin, you can create accounts for other staff members and assign them roles (e.g. `Raw Material`, `Casting`, `Turning`, `Polish`, `Packing`).
