@echo off
title Button Factory MES - Database Repair & Multi-Tier Sync
color 0A

cd /d "%~dp0"
python scripts\repair_and_sync_db.py %*

echo.
echo ====================================================================
echo Database repair & synchronization complete. Press any key to exit.
echo ====================================================================
pause >nul
