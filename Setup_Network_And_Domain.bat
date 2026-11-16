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

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "DOMAIN=testtt234e.duckdns.org"

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

echo.
echo ====================================================================
echo  [SUCCESS] Configuration Complete!
echo.
echo  You can now access Button Factory MES:
echo   - On this PC:
echo       http://%DOMAIN%:8080/
echo       http://localhost:8080/
echo.
echo   - From phones/tablets on the same Wi-Fi:
echo       http://192.168.29.94:8080/
echo ====================================================================
echo.
pause
