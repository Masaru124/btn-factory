@echo off
set "PROJECT_ROOT=%~dp0..\"
cd /d "%PROJECT_ROOT%"
call Launch_With_Cloudflare_Tunnel.bat %*
