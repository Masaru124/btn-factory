@echo off
title Button Factory MES - PostgreSQL Auto-Setup
color 0B

set "BACKEND_DIR=%~dp0"

echo ====================================================================
echo      BUTTON FACTORY MES - POSTGRESQL AUTO-SETUP & INITIALIZER
echo ====================================================================
echo Running universal PostgreSQL discovery, credential finder, and table creator...
echo.

cd /d "%BACKEND_DIR%"
python scripts\setup_local_postgres.py %*

echo.
echo ====================================================================
echo Setup complete. Press any key to exit.
echo ====================================================================
pause >nul
