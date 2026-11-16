@echo off
title Fabricana Supreme - Fix Database and Restore Super Admin
color 0A

set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)

echo ====================================================================
echo     FABRICANA SUPREME - EMERGENCY DATABASE REPAIR AND ADMIN RESTORE
echo ====================================================================
echo.
echo Diagnosing database, releasing file locks, and restoring super admin...
echo.

:: Stop background servers holding database file locks
echo [*] Terminating locking server processes...
taskkill /F /FI "WINDOWTITLE eq Backend Server*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq *FastAPI*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq *Auto Backup*" >nul 2>&1
taskkill /F /IM uvicorn.exe >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8000 .*LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
)
timeout /t 1 /nobreak >nul

:: Detect Python executable
set "PYTHON_EXE="
if exist "%BACKEND_DIR%\venv\Scripts\python.exe" (
    set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
) else if exist "%PROJECT_ROOT%venv\Scripts\python.exe" (
    set "PYTHON_EXE=%PROJECT_ROOT%venv\Scripts\python.exe"
) else (
    where python >nul 2>&1
    if %errorlevel% equ 0 (
        set "PYTHON_EXE=python"
    ) else (
        where py >nul 2>&1
        if %errorlevel% equ 0 (
            set "PYTHON_EXE=py"
        )
    )
)

if "%PYTHON_EXE%"=="" (
    color 0C
    echo [ERROR] Python not found! Please install Python 3.10+ or configure venv.
    echo.
    pause
    exit /b 1
)

cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" scripts\fix_and_restore_admin.py %*

echo.
echo ====================================================================
echo Repair and restore finished. Press any key to exit.
echo ====================================================================
pause >nul
