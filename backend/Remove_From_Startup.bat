@echo off
set "PROJECT_ROOT=%~dp0..\"
cd /d "%PROJECT_ROOT%"
call Remove_From_Startup.bat %*
