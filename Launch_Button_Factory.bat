@echo off
title Button Factory MES Launcher
color 0A

:: Automatically detect root and backend directories
set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    if exist "%~dp0app\main.py" (
        set "BACKEND_DIR=%~dp0"
    ) else (
        set "BACKEND_DIR=%CD%"
    )
)

:: Ensure cloudflared is accessible in PATH
set "PATH=%PROJECT_ROOT%;%BACKEND_DIR%;C:\Program Files (x86)\cloudflared;C:\Program Files\cloudflared;%PATH%"

echo ====================================================================
echo             BUTTON FACTORY MES - TRIPLE LAUNCHER
echo ====================================================================
echo Backend Directory : %BACKEND_DIR%
echo Target Port       : 8000 (FastAPI Backend)
echo.

:: 1. Launch FastAPI Backend
echo [1/3] Starting Terminal 1: FastAPI Backend (:8000)...
start "Button Factory - Backend Server (:8000)" cmd /k "title Backend Server [FastAPI :8000] && color 0B && cd /d "%BACKEND_DIR%" && python -m uvicorn app.main:app --port 8000 --reload"

:: 2. Launch ngrok Tunnel
echo [2/3] Starting Terminal 2: ngrok Tunnel (:8000)...
start "Button Factory - ngrok Tunnel (:8000)" cmd /k "title ngrok Tunnel [:8000] && color 0D && ngrok http 8000"

:: 3. Launch Cloudflare Tunnel
echo [3/3] Starting Terminal 3: Cloudflare Public Tunnel (:8000)...
where cloudflared >nul 2>&1
if %errorlevel% equ 0 (
    start "Button Factory - Cloudflare Public Tunnel (:8000)" cmd /k "title Cloudflare Public Tunnel [:8000] && color 0E && cloudflared tunnel --url http://localhost:8000"
) else (
    start "Button Factory - Free Public Tunnel (:8000)" cmd /k "title Free Public Tunnel [:8000] && color 0E && ssh -o StrictHostKeyChecking=no -R 80:localhost:8000 nokey@localhost.run"
)

echo.
echo ====================================================================
echo  [SUCCESS] All 3 terminals launched in separate windows!
echo   1. Backend Server   : http://127.0.0.1:8000 (Docs: /docs)
echo   2. ngrok Tunnel     : Public HTTPS URL via ngrok
echo   3. Cloudflare Tunnel: Free Unlimited Public HTTPS URL via Cloudflare
echo ====================================================================
echo.
echo Closing this launcher in 3 seconds...
timeout /t 3 >nul
exit
