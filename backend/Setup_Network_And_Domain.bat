@echo off
set "PROJECT_ROOT=%~dp0..\"
cd /d "%PROJECT_ROOT%"
call Setup_Network_And_Domain.bat %*
