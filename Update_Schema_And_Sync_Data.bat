@echo off
title Button Factory MES - Safe Schema Update and Multi-Tier Sync
color 0B

set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)

:: Locate Python in virtual environment or PATH
set "PYTHON_EXE="
if exist "%BACKEND_DIR%\venv\Scripts\python.exe" (
    set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
) else if exist "%PROJECT_ROOT%venv\Scripts\python.exe" (
    set "PYTHON_EXE=%PROJECT_ROOT%venv\Scripts\python.exe"
) else (
    set "PYTHON_EXE=python"
)

echo ====================================================================
echo    BUTTON FACTORY MES - SAFE SCHEMA UPDATE AND MULTI-TIER SYNC
echo ====================================================================
echo Target Backend Directory : %BACKEND_DIR%
echo Using Python             : %PYTHON_EXE%
echo.
echo [1] Creating automatic timestamped SQLite safety backup...
echo [2] Updating SQLite, Local PostgreSQL, and Neon schemas safely...
echo [3] Non-destructive data upsert across all database tiers...
echo ====================================================================
echo.

cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" scripts\sync_schema_and_data.py %*

echo.
echo ====================================================================
echo Process complete with zero data loss. Press any key to exit.
echo ====================================================================
pause >nul
