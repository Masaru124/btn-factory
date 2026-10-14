@echo off
title Button Factory MES - Database Repair & Multi-Tier Sync
color 0A

set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)

echo ====================================================================
echo      BUTTON FACTORY MES - DATABASE REPAIR & MULTI-TIER SYNC
echo ====================================================================
echo Inspecting SQLite & historical snapshots...
echo Repairing corrupted records and syncing to Local PostgreSQL and Neon...
echo.

cd /d "%BACKEND_DIR%"
python scripts\repair_and_sync_db.py %*

echo.
echo ====================================================================
echo Database repair & synchronization complete. Press any key to exit.
echo ====================================================================
pause >nul
