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
echo [1/3] Finding and closing any background processes holding database...

:: Stop any process occupying backend port 8000
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr /r ":8000 .*LISTENING"') do (
    echo   - Found server process on port 8000 (PID %%a). Closing it...
    taskkill /F /PID %%a >nul 2>&1
)

:: Stop background auto-backup scripts or backend server console windows
taskkill /F /FI "WINDOWTITLE eq *Auto Backup*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq Backend Server*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq *FastAPI*" >nul 2>&1

:: Pause 1 second for Windows OS to release all file handles
ping 127.0.0.1 -n 2 >nul

echo [2/3] Diagnosing database, healing corruption, and restoring admin...
echo.

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
