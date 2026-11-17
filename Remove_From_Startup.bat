@echo off
title Button Factory MES - Remove from Windows Startup
color 0C

:: Auto-elevate to Administrator to remove protected scheduled tasks
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator privileges to delete startup tasks...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

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
echo        BUTTON FACTORY MES - REMOVE FROM WINDOWS STARTUP
echo ====================================================================
echo.
"%PYTHON_EXE%" "%BACKEND_DIR%\scripts\manage_startup.py" remove

echo.
echo Press any key to exit.
pause >nul
