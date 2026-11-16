@echo off
title Button Factory MES - Launch Backend with Nginx Reverse Proxy
color 0A

:: Detect project root and backend directory
set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)
set "NGINX_DIR=%PROJECT_ROOT%nginx"
set "NGINX_CONF=%NGINX_DIR%\nginx.conf"

:: Read PUBLIC_DOMAIN from backend\.env if present
set "PUBLIC_DOMAIN=testtt234e.duckdns.org"
if exist "%BACKEND_DIR%\.env" (
    for /f "usebackq tokens=1,2 delims==" %%A in ("%BACKEND_DIR%\.env") do (
        if /i "%%A"=="PUBLIC_DOMAIN" set "PUBLIC_DOMAIN=%%B"
    )
)

:: Locate or bootstrap Python executable
set "PYTHON_EXE="
if exist "%BACKEND_DIR%\venv\Scripts\python.exe" (
    set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
) else if exist "%PROJECT_ROOT%venv\Scripts\python.exe" (
    set "PYTHON_EXE=%PROJECT_ROOT%venv\Scripts\python.exe"
) else (
    where python >nul 2>&1
    if %errorlevel% equ 0 (
        echo [NEW SYSTEM DETECTED] Creating Python virtual environment...
        python -m venv "%BACKEND_DIR%\venv"
        "%BACKEND_DIR%\venv\Scripts\pip" install -r "%BACKEND_DIR%\requirements.txt"
        if exist "%BACKEND_DIR%\venv\Scripts\python.exe" (
            set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
        ) else (
            set "PYTHON_EXE=python"
        )
    ) else (
        echo [ERROR] Python is not installed or not in PATH. Install Python 3.10+ from python.org
        pause
        exit /b 1
    )
)

echo ====================================================================
echo      BUTTON FACTORY MES - BACKEND ONLY (FASTAPI + NGINX PROXY)
echo ====================================================================
echo Project Root        : %PROJECT_ROOT%
echo Backend Directory   : %BACKEND_DIR%
echo Public DuckDNS URL  : http://%PUBLIC_DOMAIN%
echo Using Python        : %PYTHON_EXE%
echo.

:: 1. Database Safety Snapshot & Background Cloud Sync
echo [1/3] Running automated database backup...
start "Button Factory - Auto Backup" /min cmd /c "cd /d "%BACKEND_DIR%" && "%PYTHON_EXE%" scripts\run_backup.py"

:: 2. Generate/Update Nginx backend reverse proxy configuration
echo [2/3] Updating Nginx backend reverse proxy configuration...
"%PYTHON_EXE%" "%BACKEND_DIR%\scripts\setup_web_servers.py" nginx

:: Read active Nginx port (port 80 or 8080 if 80 is occupied)
set "NGINX_PORT=80"
if exist "%NGINX_DIR%\port.txt" (
    set /p NGINX_PORT=<"%NGINX_DIR%\port.txt"
)
if "%NGINX_PORT%"=="80" (
    set "PUBLIC_URL=http://%PUBLIC_DOMAIN%"
    set "LOCAL_URL=http://localhost"
) else (
    set "PUBLIC_URL=http://%PUBLIC_DOMAIN%:%NGINX_PORT%"
    set "LOCAL_URL=http://localhost:%NGINX_PORT%"
)

:: 3. Launch FastAPI Backend on port 8000
echo [3/3] Starting FastAPI Backend on http://127.0.0.1:8000...
start "Button Factory - Backend Server (:8000)" cmd /k "title Backend Server [FastAPI :8000] && color 0B && cd /d "%BACKEND_DIR%" && "%PYTHON_EXE%" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"

:: 4. Locate and Launch Nginx
echo.
echo Checking for Nginx on this machine...
set "NGINX_EXE="
where nginx >nul 2>&1
if %errorlevel% equ 0 (
    set "NGINX_EXE=nginx"
) else if exist "C:\nginx\nginx.exe" (
    set "NGINX_EXE=C:\nginx\nginx.exe"
) else if exist "%NGINX_DIR%\nginx.exe" (
    set "NGINX_EXE=%NGINX_DIR%\nginx.exe"
) else if exist "C:\Program Files\nginx\nginx.exe" (
    set "NGINX_EXE=C:\Program Files\nginx\nginx.exe"
) else if exist "C:\tools\nginx\nginx.exe" (
    set "NGINX_EXE=C:\tools\nginx\nginx.exe"
)

if defined NGINX_EXE (
    echo [Nginx Found] Using: %NGINX_EXE%
    :: Ensure all required Nginx runtime directories exist
    if not exist "%NGINX_DIR%\temp" mkdir "%NGINX_DIR%\temp" >nul 2>&1
    if not exist "%NGINX_DIR%\temp\client_body_temp" mkdir "%NGINX_DIR%\temp\client_body_temp" >nul 2>&1
    if not exist "%NGINX_DIR%\temp\proxy_temp" mkdir "%NGINX_DIR%\temp\proxy_temp" >nul 2>&1
    if not exist "%NGINX_DIR%\temp\fastcgi_temp" mkdir "%NGINX_DIR%\temp\fastcgi_temp" >nul 2>&1
    if not exist "%NGINX_DIR%\temp\uwsgi_temp" mkdir "%NGINX_DIR%\temp\uwsgi_temp" >nul 2>&1
    if not exist "%NGINX_DIR%\temp\scgi_temp" mkdir "%NGINX_DIR%\temp\scgi_temp" >nul 2>&1
    if not exist "%NGINX_DIR%\logs" mkdir "%NGINX_DIR%\logs" >nul 2>&1
    if not exist "%NGINX_DIR%\html" mkdir "%NGINX_DIR%\html" >nul 2>&1

    echo Testing Nginx configuration...
    "%NGINX_EXE%" -t -p "%NGINX_DIR%" -c "%NGINX_CONF%"
    echo Starting Nginx backend reverse proxy on port %NGINX_PORT%...
    start "Button Factory - Nginx Server" "%NGINX_EXE%" -p "%NGINX_DIR%" -c "%NGINX_CONF%"
    ping 127.0.0.1 -n 3 >nul
    if not "%1"=="--silent" if not "%1"=="--startup" start %PUBLIC_URL%/docs
) else (
    echo [WARN] Nginx binary not found. Backend running directly on http://127.0.0.1:8000
    if not "%1"=="--silent" if not "%1"=="--startup" start http://127.0.0.1:8000/docs
)

echo.
echo ====================================================================
echo  Button Factory Backend is running (Nginx Only):
echo   - DuckDNS Access: %PUBLIC_URL% (API Docs: %PUBLIC_URL%/docs)
echo   - Local Proxy   : %LOCAL_URL% (API Docs: %LOCAL_URL%/docs)
echo   - Direct Backend: http://127.0.0.1:8000 (API Docs: /docs)
echo ====================================================================
echo.
if "%1"=="--startup" exit /b 0
if "%1"=="--silent" exit /b 0
echo Press any key to exit launcher (servers continue running in background).
pause >nul
