@echo off
title Fabricana Supreme - Restore Super Admin Account
color 0B

set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)

echo ====================================================================
echo        FABRICANA SUPREME - RESTORE SUPER ADMIN ACCOUNT
echo ====================================================================
echo.
echo [1/2] Releasing active database locks...

:: Stop any process occupying backend port 8000
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr /r ":8000 .*LISTENING"') do (
    echo   - Closing server process on port 8000 (PID %%a)...
    taskkill /F /PID %%a >nul 2>&1
)
taskkill /F /FI "WINDOWTITLE eq *Auto Backup*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq Backend Server*" >nul 2>&1

:: Pause 1 second for Windows OS to release all file handles
ping 127.0.0.1 -n 2 >nul

echo [2/2] Restoring default super admin...
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
    echo [ERROR] Python not found! Please install Python 3.10+ or ensure venv exists.
    echo.
    pause
    exit /b 1
)

cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" scripts\restore_super_admin.py %*

echo.
echo ====================================================================
echo Super admin restore complete. Press any key to exit.
echo ====================================================================
pause >nul
