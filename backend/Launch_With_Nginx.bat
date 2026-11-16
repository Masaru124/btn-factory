@echo off
title Button Factory MES - Launch with Nginx and Backend
color 0A

:: Current directory is backend
set "BACKEND_DIR=%~dp0"
set "PROJECT_ROOT=%~dp0..\"

cd /d "%PROJECT_ROOT%"
call Launch_With_Nginx.bat %*
