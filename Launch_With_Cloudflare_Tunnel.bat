@echo off
title Button Factory MES - Launch with Cloudflare Tunnel (DuckDNS Host Mode)
color 0E

:: Detect project root and backend directory
set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)

:: Ensure cloudflared directories and project root are in PATH
set "PATH=%PROJECT_ROOT%;C:\Program Files (x86)\cloudflared;C:\Program Files\cloudflared;%PATH%"

:: Read PUBLIC_DOMAIN from backend\.env or .env if present
set "PUBLIC_DOMAIN=testtt234e.duckdns.org"
if exist "%BACKEND_DIR%\.env" (
    for /f "usebackq tokens=1,2 delims==" %%A in ("%BACKEND_DIR%\.env") do (
        if /i "%%A"=="PUBLIC_DOMAIN" set "PUBLIC_DOMAIN=%%B"
    )
) else if exist "%PROJECT_ROOT%\.env" (
    for /f "usebackq tokens=1,2 delims==" %%A in ("%PROJECT_ROOT%\.env") do (
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
echo   BUTTON FACTORY MES - CLOUDFLARE TUNNEL (DUCKDNS HOST MODE)
echo ====================================================================
echo Project Root         : %PROJECT_ROOT%
echo Backend Directory    : %BACKEND_DIR%
echo Target Backend Port  : 8000
echo DuckDNS Host Header  : %PUBLIC_DOMAIN%
echo Using Python         : %PYTHON_EXE%
echo.

:: 1. Database Safety Snapshot & Background Cloud Sync
echo [1/3] Running automated database backup...
start "Button Factory - Auto Backup" /min cmd /c "cd /d "%BACKEND_DIR%" && "%PYTHON_EXE%" scripts\run_backup.py"

:: 2. Launch FastAPI Backend on port 8000
echo [2/3] Starting FastAPI Backend on http://127.0.0.1:8000...
start "Button Factory - Backend Server (:8000)" cmd /k "title Backend Server [FastAPI :8000] && color 0B && cd /d "%BACKEND_DIR%" && "%PYTHON_EXE%" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"

:: 3. Locate or download cloudflared.exe
echo [3/3] Checking for Cloudflare Tunnel binary...
where cloudflared >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] cloudflared.exe not found in PATH. Downloading official Cloudflare binary...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile '%PROJECT_ROOT%cloudflared.exe'"
)

where cloudflared >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Starting Cloudflare Public Tunnel with Host Header '%PUBLIC_DOMAIN%'...
    start "Button Factory - Cloudflare Tunnel (:8000)" cmd /k "title Cloudflare Tunnel [%PUBLIC_DOMAIN%] && color 0E && cloudflared tunnel --url http://127.0.0.1:8000 --http-host-header %PUBLIC_DOMAIN%"
) else (
    echo [ERROR] cloudflared command could not be located.
)

echo.
echo ====================================================================
echo  Button Factory Backend is running:
echo   - Local Backend  : http://127.0.0.1:8000 (API Docs: /docs)
echo   - DuckDNS Header : %PUBLIC_DOMAIN%
echo   - Public HTTPS   : Generated in the Cloudflare Tunnel terminal window
echo ====================================================================
echo.
if "%1"=="--startup" exit /b 0
if "%1"=="--silent" exit /b 0
echo Press any key to exit launcher (servers continue running in background).
pause >nul
