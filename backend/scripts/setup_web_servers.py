"""Web Server Configuration Generator for Nginx and IIS (Backend-Only Mode).

Generates production-grade reverse proxy configurations for Button Factory MES:
1. Nginx: nginx/nginx.conf reverse-proxying all requests directly to FastAPI backend.
2. IIS: iis/web.config reverse-proxying all requests directly to FastAPI backend via ARR.
"""

import os
import shutil
import sys
import urllib.request
import zipfile

from dotenv import load_dotenv

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
PROJECT_ROOT = os.path.dirname(BACKEND_DIR)
IIS_DIR = os.path.join(PROJECT_ROOT, 'iis')
NGINX_DIR = os.path.join(PROJECT_ROOT, 'nginx')

# Load environment configuration
load_dotenv(os.path.join(BACKEND_DIR, '.env'))
load_dotenv(os.path.join(PROJECT_ROOT, '.env'))


def get_public_domain() -> str:
    """Retrieve and clean DuckDNS or public domain from environment."""
    raw = os.getenv('PUBLIC_DOMAIN') or os.getenv('DUCKDNS_DOMAIN') or 'testtt234e.duckdns.org'
    cleaned = raw.strip().replace('http://', '').replace('https://', '').split('/')[0].split(':')[0]
    return cleaned if cleaned else 'testtt234e.duckdns.org'


def get_web_port() -> int:
    """Detect available port: port 80 if free, or 8080 if port 80 is occupied (e.g. by IIS)."""
    env_port = os.getenv('WEB_PORT')
    if env_port and env_port.isdigit():
        return int(env_port)
    import socket
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.5)
        if s.connect_ex(('127.0.0.1', 80)) == 0:
            return 8080
    return 80


def ensure_nginx_binary() -> str | None:
    """Ensure nginx.exe is available; auto-downloads official portable Nginx if missing."""
    nginx_exe = os.path.join(NGINX_DIR, 'nginx.exe')
    if os.path.isfile(nginx_exe):
        return nginx_exe

    in_path = shutil.which('nginx')
    if in_path:
        return in_path

    if os.path.isfile(r'C:\nginx\nginx.exe'):
        return r'C:\nginx\nginx.exe'

    print(" [INFO] Nginx binary not found. Downloading official portable Nginx for Windows (2MB)...")
    url = "https://nginx.org/download/nginx-1.26.2.zip"
    zip_path = os.path.join(NGINX_DIR, 'nginx_temp.zip')
    try:
        os.makedirs(NGINX_DIR, exist_ok=True)
        urllib.request.urlretrieve(url, zip_path)
        with zipfile.ZipFile(zip_path, 'r') as zf:
            for member in zf.infolist():
                parts = member.filename.split('/', 1)
                if len(parts) > 1 and parts[1]:
                    target = os.path.join(NGINX_DIR, parts[1])
                    if member.is_dir():
                        os.makedirs(target, exist_ok=True)
                    else:
                        os.makedirs(os.path.dirname(target), exist_ok=True)
                        with zf.open(member) as src, open(target, 'wb') as dst:
                            dst.write(src.read())
        if os.path.exists(zip_path):
            os.remove(zip_path)
        if os.path.isfile(nginx_exe):
            print(" [PASS] Official portable Nginx extracted into nginx/ directory.")
            return nginx_exe
    except Exception as e:
        print(f" [WARN] Could not auto-download Nginx: {e}")
    return None


def generate_nginx_config(port: int | None = None, backend_port: int = 8000) -> str:
    """Generate self-contained nginx.conf as pure backend reverse proxy to FastAPI."""
    os.makedirs(NGINX_DIR, exist_ok=True)
    temp_dir = os.path.join(NGINX_DIR, 'temp')
    logs_dir = os.path.join(NGINX_DIR, 'logs')
    for d in [
        temp_dir,
        os.path.join(temp_dir, 'client_body_temp'),
        os.path.join(temp_dir, 'proxy_temp'),
        os.path.join(temp_dir, 'fastcgi_temp'),
        os.path.join(temp_dir, 'uwsgi_temp'),
        os.path.join(temp_dir, 'scgi_temp'),
        logs_dir,
        os.path.join(NGINX_DIR, 'html'),
    ]:
        os.makedirs(d, exist_ok=True)

    if port is None:
        port = get_web_port()
    domain = get_public_domain()

    # Save active port for launcher script
    with open(os.path.join(NGINX_DIR, 'port.txt'), 'w', encoding='utf-8') as pf:
        pf.write(str(port))

    nginx_conf_content = f"""# Button Factory MES - Backend Reverse Proxy Nginx Configuration
worker_processes  1;

events {{
    worker_connections  1024;
}}

http {{
    include       mime.types;
    default_type  application/octet-stream;

    # Temp directories for portable execution on any drive/PC
    client_body_temp_path  temp/client_body_temp;
    proxy_temp_path        temp/proxy_temp;
    fastcgi_temp_path      temp/fastcgi_temp;
    uwsgi_temp_path        temp/uwsgi_temp;
    scgi_temp_path         temp/scgi_temp;

    sendfile        on;
    keepalive_timeout  65;

    # Gzip Compression for backend JSON and text responses
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript;

    # Upstream FastAPI Backend
    upstream backend_api {{
        server 127.0.0.1:{backend_port};
        keepalive 32;
    }}

    server {{
        listen       {port};
        server_name  {domain} localhost 127.0.0.1;

        # Allow large image and file uploads up to 50MB
        client_max_body_size 50M;

        # Reverse Proxy all traffic directly to FastAPI Backend (:8000)
        location / {{
            proxy_pass http://backend_api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 300s;
            proxy_connect_timeout 60s;
        }}
    }}
}}
"""
    conf_path = os.path.join(NGINX_DIR, 'nginx.conf')
    with open(conf_path, 'w', encoding='utf-8') as f:
        f.write(nginx_conf_content)

    conf_dir = os.path.join(NGINX_DIR, 'conf')
    os.makedirs(conf_dir, exist_ok=True)
    with open(os.path.join(conf_dir, 'nginx.conf'), 'w', encoding='utf-8') as f:
        f.write(nginx_conf_content)

    mime_types_content = """types {
    text/html                             html htm shtml;
    text/css                              css;
    text/xml                              xml;
    image/gif                             gif;
    image/jpeg                            jpeg jpg;
    application/javascript                js;
    image/png                             png;
    image/webp                            webp;
    application/json                      json;
    application/octet-stream              bin exe dll;
}
"""
    mime_path = os.path.join(NGINX_DIR, 'mime.types')
    with open(mime_path, 'w', encoding='utf-8') as f:
        f.write(mime_types_content)

    return conf_path


def generate_iis_config(backend_port: int = 8000) -> str:
    """Generate production web.config for IIS with pure ARR reverse proxy to FastAPI backend."""
    os.makedirs(IIS_DIR, exist_ok=True)

    iis_web_config = f"""<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <!-- Reverse Proxy all requests directly to FastAPI Backend (:{backend_port}) -->
        <rule name="ReverseProxyToBackend" stopProcessing="true">
          <match url=".*" />
          <action type="Rewrite" url="http://127.0.0.1:{backend_port}/{{R:0}}" />
        </rule>
      </rules>
    </rewrite>

    <security>
      <requestFiltering>
        <!-- Allow image uploads up to 50MB (52428800 bytes) -->
        <requestLimits maxAllowedContentLength="52428800" />
      </requestFiltering>
    </security>

    <httpProtocol>
      <customHeaders>
        <add name="X-Frame-Options" value="SAMEORIGIN" />
        <add name="X-Content-Type-Options" value="nosniff" />
      </customHeaders>
    </httpProtocol>
  </system.webServer>
</configuration>
"""
    config_path = os.path.join(IIS_DIR, 'web.config')
    with open(config_path, 'w', encoding='utf-8') as f:
        f.write(iis_web_config)
    return config_path


def main():
    target = sys.argv[1].lower() if len(sys.argv) > 1 else 'all'
    domain = get_public_domain()
    print("=" * 70)
    print("  BUTTON FACTORY MES - BACKEND WEB SERVER CONFIGURATION")
    print(f"  Public / DuckDNS Domain: {domain}")
    print("=" * 70)

    if target in ('nginx', 'all'):
        ensure_nginx_binary()
        conf = generate_nginx_config()
        print(f" [PASS] Nginx backend proxy configuration: {conf}")

    if target in ('iis', 'all'):
        conf = generate_iis_config()
        print(f" [PASS] IIS backend proxy configuration: {conf}")

    print("=" * 70)


if __name__ == '__main__':
    main()
