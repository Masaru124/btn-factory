@echo off
title Button Factory MES - Setup Network & DuckDNS Domain
color 0A

:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ELEVATION REQUIRED] Requesting Administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/k \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" set "BACKEND_DIR=%CD%"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"

:: Read PUBLIC_DOMAIN or DUCKDNS_DOMAIN from backend\.env or .env if present
set "DOMAIN=fasti2.duckdns.org"
if exist "%BACKEND_DIR%\.env" (
    for /f "usebackq tokens=1,2 delims==" %%A in ("%BACKEND_DIR%\.env") do (
        if /i "%%A"=="PUBLIC_DOMAIN" set "DOMAIN=%%B"
        if /i "%%A"=="DUCKDNS_DOMAIN" if not "%%B"=="" set "DOMAIN=%%B"
    )
) else if exist "%PROJECT_ROOT%\.env" (
    for /f "usebackq tokens=1,2 delims==" %%A in ("%PROJECT_ROOT%\.env") do (
        if /i "%%A"=="PUBLIC_DOMAIN" set "DOMAIN=%%B"
        if /i "%%A"=="DUCKDNS_DOMAIN" if not "%%B"=="" set "DOMAIN=%%B"
    )
)

:: Clean DOMAIN string (remove quotes, spaces, http://, https://, trailing slashes)
set "DOMAIN=%DOMAIN:"=%"
set "DOMAIN=%DOMAIN: =%"
set "DOMAIN=%DOMAIN:http://=%"
set "DOMAIN=%DOMAIN:https://=%"
for /f "tokens=1 delims=/: " %%A in ("%DOMAIN%") do set "DOMAIN=%%A"

echo ====================================================================
echo      BUTTON FACTORY MES - SETUP DUCKDNS DOMAIN & FIREWALL
echo ====================================================================
echo.

:: 1. Add DuckDNS Domain to Hosts File
echo [1/3] Checking hosts file for %DOMAIN%...
findstr /i "%DOMAIN%" "%HOSTS_FILE%" >nul 2>&1
if %errorlevel% equ 0 (
    echo  [OK] %DOMAIN% is already in hosts file.
) else (
    echo  Adding 127.0.0.1 %DOMAIN% to %HOSTS_FILE%...
    echo.>> "%HOSTS_FILE%"
    echo 127.0.0.1 %DOMAIN%>> "%HOSTS_FILE%"
    echo  [PASS] Added 127.0.0.1 %DOMAIN% to hosts file.
)

:: 2. Flush DNS Cache
echo.
echo [2/3] Flushing Windows DNS Resolver Cache...
ipconfig /flushdns >nul
echo  [PASS] DNS cache flushed.

:: 3. Open Windows Defender Firewall for ports 8080 and 8088
echo.
echo [3/3] Configuring Windows Defender Firewall...
netsh advfirewall firewall show rule name="Button Factory MES Nginx (80)" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="Button Factory MES Nginx (80)" dir=in action=allow protocol=TCP localport=80 >nul 2>&1
    echo  [PASS] Added inbound firewall rule for Port 80 (HTTP).
) else (
    echo  [OK] Firewall rule for Port 80 already exists.
)

netsh advfirewall firewall show rule name="Button Factory MES Nginx (8080)" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="Button Factory MES Nginx (8080)" dir=in action=allow protocol=TCP localport=8080 >nul 2>&1
    echo  [PASS] Added inbound firewall rule for Port 8080 (Nginx).
) else (
    echo  [OK] Firewall rule for Port 8080 already exists.
)

netsh advfirewall firewall show rule name="Button Factory MES IIS (8088)" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="Button Factory MES IIS (8088)" dir=in action=allow protocol=TCP localport=8088 >nul 2>&1
    echo  [PASS] Added inbound firewall rule for Port 8088 (IIS).
) else (
    echo  [OK] Firewall rule for Port 8088 already exists.
)

:: Detect current local LAN IP
set "LOCAL_LAN_IP=localhost"
for /f "tokens=3" %%i in ('powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -notlike '169.254*' -and $_.IPAddress -notlike '127.*' }).IPAddress[0]" 2^>nul') do (
    if not "%%i"=="" set "LOCAL_LAN_IP=%%i"
)

echo.
echo ====================================================================
echo  [SUCCESS] Configuration Complete!
echo.
echo  You can now access Button Factory MES:
echo   - On this PC:
echo       http://%DOMAIN%:8080/docs
echo       http://localhost:8080/docs
echo.
echo   - From phones/tablets on the same Wi-Fi:
echo       http://%LOCAL_LAN_IP%:8080/docs
echo ====================================================================
echo.
pause
