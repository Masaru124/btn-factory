@echo off
title Button Factory MES Launcher
color 0A

:: Automatically detect backend folder (relative to this script, whether in root or inside backend)
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    if exist "%~dp0app\main.py" (
        set "BACKEND_DIR=%~dp0"
    ) else (
        set "BACKEND_DIR=%CD%"
    )
)

echo ====================================================================
echo             BUTTON FACTORY MES - DUAL TERMINAL LAUNCHER
echo ====================================================================
echo Backend Directory: %BACKEND_DIR%
echo.
echo Starting Terminal 1: FastAPI Backend (Direct Python - no venv)...
start "Button Factory - Backend Server (:8000)" cmd /k "title Backend Server [FastAPI :8000] && color 0B && cd /d "%BACKEND_DIR%" && python -m uvicorn app.main:app --port 8000 --reload"

echo Starting Terminal 2: ngrok Tunnel (port 8000)...
start "Button Factory - ngrok Tunnel (:8000)" cmd /k "title ngrok Tunnel [:8000] && color 0E && cd /d "%BACKEND_DIR%" && ngrok http 8000"

echo.
echo ====================================================================
echo  [SUCCESS] Both terminals have been launched in separate windows!
echo  Terminal 1: Uvicorn API Server (http://127.0.0.1:8000)
echo  Terminal 2: ngrok Public Tunnel
echo ====================================================================
echo.
echo Closing this launcher in 3 seconds...
timeout /t 3 >nul
exit
