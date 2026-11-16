@echo off
title Button Factory MES - Launch with IIS and Backend
color 0B

:: Current directory is backend
set "BACKEND_DIR=%~dp0"
set "PROJECT_ROOT=%~dp0..\"

cd /d "%PROJECT_ROOT%"
call Launch_With_IIS.bat %*
