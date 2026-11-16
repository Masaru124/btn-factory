@echo off
title Button Factory MES - Add to Windows Startup
color 0A

:: Detect project root and backend directory
set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)

:: Locate Python executable
set "PYTHON_EXE="
if exist "%BACKEND_DIR%\venv\Scripts\python.exe" (
    set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
) else if exist "%PROJECT_ROOT%venv\Scripts\python.exe" (
    set "PYTHON_EXE=%PROJECT_ROOT%venv\Scripts\python.exe"
) else (
    set "PYTHON_EXE=python"
)

echo ====================================================================
echo        BUTTON FACTORY MES - CONFIGURE AUTOMATIC WINDOWS STARTUP
echo ====================================================================
echo Project Root : %PROJECT_ROOT%
echo.
echo Choose which configuration to start automatically on Windows boot / restart:
echo.
echo   [1] Launch with Nginx              (Fast, lightweight reverse proxy)
echo   [2] Launch with IIS                (Windows IIS reverse proxy)
echo   [3] Launch with Cloudflare Tunnel  (DuckDNS Host Mode, bypasses routers)
echo   [4] Launch Button Factory          (FastAPI + ngrok / Cloudflare triple)
echo   [5] Cancel
echo.
set /p CHOICE="Select option [1-5] (Default is 1): "

if "%CHOICE%"=="" set "CHOICE=1"
if "%CHOICE%"=="5" (
    echo Operation cancelled.
    timeout /t 2 >nul
    exit /b 0
)

set "SERVER_TYPE=nginx"
if "%CHOICE%"=="2" set "SERVER_TYPE=iis"
if "%CHOICE%"=="3" set "SERVER_TYPE=cloudflare"
if "%CHOICE%"=="4" set "SERVER_TYPE=button_factory"

echo.
"%PYTHON_EXE%" "%BACKEND_DIR%\scripts\manage_startup.py" add %SERVER_TYPE%

echo.
echo Press any key to exit.
pause >nul
