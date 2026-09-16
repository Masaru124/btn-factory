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

---

## 🏷️ Part 3: Connecting Your Custom Domain (Frontend)

If you purchased a custom domain (e.g. from Namecheap, GoDaddy, Cloudflare, Hostinger, etc.), you can point it to your frontend web app with **free automatic SSL (HTTPS)**.

### Recommended: Using Vercel or Netlify or Cloudflare Pages

#### Option 1: On Vercel (Easiest & Fastest)
1. In your **Vercel Dashboard**, open your deployed frontend project.
2. Go to **Settings** → **Domains**.
3. Type your domain or subdomain:
   - For a root domain: `yourdomain.com`
   - For a subdomain: `mes.yourdomain.com` or `app.yourdomain.com`
4. Click **Add**. Vercel will provide the exact DNS records to enter at your domain registrar:
   - **For Subdomain (`app.yourdomain.com`)**:
     - **Type**: `CNAME`
     - **Name / Host**: `app`
     - **Value / Target**: `cname.vercel-dns.com`
   - **For Root Domain (`yourdomain.com`)**:
     - **Type**: `A`
     - **Name / Host**: `@`
     - **Value / Target**: `76.76.21.21`
5. Vercel automatically generates a free SSL certificate within 2–5 minutes. Your site is live at `https://yourdomain.com`!

#### Option 2: On Netlify
1. In the **Netlify Dashboard**, select your site → **Domain management** → **Add custom domain**.
2. Enter `yourdomain.com` (or `app.yourdomain.com`).
3. Add the DNS records shown by Netlify at your domain registrar (e.g., CNAME to `your-site-name.netlify.app`).

#### Option 3: On Cloudflare Pages
1. Go to your Cloudflare dashboard → **Pages** → your project → **Custom domains**.
2. Click **Set up a custom domain** and enter your domain name.
3. If your domain's nameservers already use Cloudflare, it configures everything with 1 click.

---

## 🛠️ Option C: Complete Nginx Hosting Guide (Frontend + Backend on 1 Server)

This is the standard, production-grade architecture used by companies:
- **Server**: Any Ubuntu / Debian VPS (e.g. Oracle Cloud Free Tier, DigitalOcean, Hetzner, AWS EC2, or your own local Linux server).
- **Domain Mapping**:
  - `https://yourdomain.com` ➔ Serves the Flutter Web frontend.
  - `https://yourdomain.com/api` ➔ Proxies to the FastAPI backend on port 8000.
  - **No CORS issues**: Both frontend and backend share the exact same domain origin!

---

### Step 1: Point Your Domain's DNS to Your Server
Go to your domain registrar (Namecheap, GoDaddy, Cloudflare, etc.) and add:
* **Record**: `A`
* **Host**: `@` (or `app` if using a subdomain like `app.yourdomain.com`)
* **Value**: `YOUR_SERVER_PUBLIC_IP`
* **TTL**: Automatic (or 300s)

---

### Step 2: Install Nginx, Certbot & Docker on Your Server
SSH into your server and run:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx certbot python3-certbot-nginx git curl
```

Install Docker & Docker Compose (if not already installed):
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

---

### Step 3: Start the Backend (with Persistent SQLite)
Clone the repository onto your server:
```bash
git clone https://github.com/Masaru124/btn-factory.git /var/www/btn_factory_app
cd /var/www/btn_factory_app
```

Start the backend container:
```bash
docker compose up -d --build
```
Verify that the backend is healthy:
```bash
curl http://127.0.0.1:8000/health
# Should return: {"status":"ok"}
```
*(All SQLite data is automatically persisted in the `backend_data` volume at `/app/data/btn_factory.db`).*

---

### Step 4: Build and Deploy Flutter Web
On your development machine (or directly on the server if Flutter is installed):
```bash
cd btn_factory
flutter build web --release --dart-define=API_BASE_URL=https://yourdomain.com/api
```

Copy the built `build/web` folder to your server at `/var/www/btn_factory/web`:
```bash
# On your server, create the directory:
sudo mkdir -p /var/www/btn_factory/web

# Set permissions so Nginx can read it:
sudo chown -R www-data:www-data /var/www/btn_factory
sudo chmod -R 755 /var/www/btn_factory
```
*(If building on your PC, you can copy files to the server using SCP: `scp -r build/web/* user@your-server-ip:/var/www/btn_factory/web/`)*.

---

### Step 5: Configure Nginx
Create a new Nginx site configuration:
```bash
sudo nano /etc/nginx/sites-available/btn_factory
```

Paste the following production configuration (replace `yourdomain.com` with your actual domain):

```nginx
# Gzip Compression for fast Flutter Web loading
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml application/json application/javascript application/wasm image/svg+xml;

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Allow larger image uploads (for button and PO images)
    client_max_body_size 50M;

    # 1. FRONTEND: Serve Flutter Web Single Page Application (SPA)
    root /var/www/btn_factory/web;
    index index.html;

    location / {
        # Critical for Flutter Web routing (GoRouter)
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets (JS, WebAssembly, fonts, icons)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|wasm)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # 2. BACKEND: Reverse Proxy to FastAPI on port 8000
    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_http_version 1.1;

        # Standard Proxy Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket / Connection upgrade headers (if needed)
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts for heavy processing / file uploads
        proxy_connect_timeout 60s;
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
    }

    # Optional: Proxy health endpoint
    location /health {
        proxy_pass http://127.0.0.1:8000/health;
    }
}
```

Enable the configuration and test it:
```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/btn_factory /etc/nginx/sites-enabled/

# Remove the default Nginx welcome site (if present)
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx syntax
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

### Step 6: Enable Free SSL (HTTPS) with Certbot
Run Certbot to automatically issue and configure a free SSL certificate from Let's Encrypt:
```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```
* Certbot will ask for your email (for renewal notices) and whether to redirect HTTP to HTTPS (choose **Yes / Redirect**).
* Certbot automatically updates your Nginx configuration with HTTPS on port 443!

Test automatic SSL renewal:
```bash
sudo certbot renew --dry-run
```

---

### Step 7: How to Update in the Future

* **To update the Backend**:
  ```bash
  cd /var/www/btn_factory_app
  git pull
  docker compose up -d --build
  ```
* **To update the Frontend**:
  ```bash
  cd btn_factory
  flutter build web --release --dart-define=API_BASE_URL=https://yourdomain.com/api
  # Copy new files to /var/www/btn_factory/web
  ```

---

## 👤 Default Initial Login Credentials

Upon the first startup, the backend automatically seeds the super administrator account:
- **Email**: `admin@factory.com`
- **Password**: `Admin@123`
- **Role**: `super_admin`

Once logged in as Super Admin, you can create accounts for other staff members and assign them roles (e.g. `Raw Material`, `Casting`, `Turning`, `Polish`, `Packing`).

