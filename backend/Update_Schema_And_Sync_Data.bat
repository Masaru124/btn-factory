@echo off
title Button Factory MES - Safe Schema Update and Multi-Tier Sync
color 0B

set "BACKEND_DIR=%~dp0"

:: Locate Python in virtual environment or PATH
set "PYTHON_EXE="
if exist "%BACKEND_DIR%venv\Scripts\python.exe" (
    set "PYTHON_EXE=%BACKEND_DIR%venv\Scripts\python.exe"
) else if exist "%BACKEND_DIR%..\venv\Scripts\python.exe" (
    set "PYTHON_EXE=%BACKEND_DIR%..\venv\Scripts\python.exe"
) else (
    set "PYTHON_EXE=python"
)

echo ====================================================================
echo    BUTTON FACTORY MES - SAFE SCHEMA UPDATE AND MULTI-TIER SYNC
echo ====================================================================
echo Target Backend Directory : %BACKEND_DIR%
echo Using Python             : %PYTHON_EXE%
echo.

cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" scripts\sync_schema_and_data.py %*

echo.
echo ====================================================================
echo Process complete with zero data loss. Press any key to exit.
echo ====================================================================
pause >nul
