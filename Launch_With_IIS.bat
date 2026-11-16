@echo off
title Button Factory MES - Launch Backend with IIS Reverse Proxy
color 0B

:: Check for Administrator privileges required to manage IIS
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ELEVATION REQUIRED] Requesting Administrator privileges to configure IIS...
    powershell -Command "Start-Process cmd -ArgumentList '/k \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: Detect project root and backend directory
set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%~dp0backend"
if not exist "%BACKEND_DIR%" (
    set "BACKEND_DIR=%CD%"
)
set "IIS_DIR=%PROJECT_ROOT%iis"
set "APPCMD=%SystemRoot%\System32\inetsrv\appcmd.exe"
set "IIS_PORT=8088"

:: Read PUBLIC_DOMAIN from backend\.env if present
set "PUBLIC_DOMAIN=testtt234e.duckdns.org"
if exist "%BACKEND_DIR%\.env" (
    for /f "usebackq tokens=1,2 delims==" %%A in ("%BACKEND_DIR%\.env") do (
        if /i "%%A"=="PUBLIC_DOMAIN" set "PUBLIC_DOMAIN=%%B"
    )
)

:: Locate or bootstrap Python executable
set "PYTHON_EXE="
if exist "%BACKEND_DIR%\venv\Scripts\python.exe" (
    set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
) else if exist "%PROJECT_ROOT%venv\Scripts\python.exe" (
    set "PYTHON_EXE=%PROJECT_ROOT%venv\Scripts\python.exe"
) else (
    where python >nul 2>&1
    if %errorlevel% equ 0 (
        echo [NEW SYSTEM DETECTED] Creating Python virtual environment...
        python -m venv "%BACKEND_DIR%\venv"
        "%BACKEND_DIR%\venv\Scripts\pip" install -r "%BACKEND_DIR%\requirements.txt"
        if exist "%BACKEND_DIR%\venv\Scripts\python.exe" (
            set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
        ) else (
            set "PYTHON_EXE=python"
        )
    ) else (
        echo [ERROR] Python is not installed or not in PATH. Install Python 3.10+ from python.org
        pause
        exit /b 1
    )
)

echo ====================================================================
echo         BUTTON FACTORY MES - BACKEND ONLY (FASTAPI + IIS PROXY)
echo ====================================================================
echo Project Root        : %PROJECT_ROOT%
echo Backend Directory   : %BACKEND_DIR%
echo IIS Proxy Directory : %IIS_DIR%
echo Public DuckDNS URL  : http://%PUBLIC_DOMAIN%:%IIS_PORT%
echo Using Python        : %PYTHON_EXE%
echo.

:: 1. Database Safety Snapshot & Background Cloud Sync
echo [1/3] Running automated database backup...
start "Button Factory - Auto Backup" /min cmd /c "cd /d "%BACKEND_DIR%" && "%PYTHON_EXE%" scripts\run_backup.py"

:: 2. Ensure IIS backend web.config is generated
echo [2/3] Generating IIS backend reverse proxy web.config...
"%PYTHON_EXE%" "%BACKEND_DIR%\scripts\setup_web_servers.py" iis

:: 3. Launch FastAPI Backend on port 8000
echo [3/3] Starting FastAPI Backend on http://127.0.0.1:8000...
start "Button Factory - Backend Server (:8000)" cmd /k "title Backend Server [FastAPI :8000] && color 0B && cd /d "%BACKEND_DIR%" && "%PYTHON_EXE%" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"

:: 4. Verify and Configure IIS (Internet Information Services)
echo.
echo Checking IIS (W3SVC) status on this machine...

sc query W3SVC >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo --------------------------------------------------------------------
    echo  [NOTE] IIS - World Wide Web Publishing Service is not installed.
    echo  Backend running directly on http://127.0.0.1:8000
    echo --------------------------------------------------------------------
    start http://127.0.0.1:8000/docs
    goto :SUMMARY
)

:: Ensure W3SVC service is started
net start W3SVC >nul 2>&1

:: Check if IIS URL Rewrite and ARR modules are installed
set "HAS_REWRITE=1"
if not exist "%SystemRoot%\System32\inetsrv\rewrite.dll" set "HAS_REWRITE=0"
if not exist "%SystemRoot%\System32\inetsrv\requestRouter.dll" set "HAS_REWRITE=0"

if "%HAS_REWRITE%"=="0" (
    echo.
    echo --------------------------------------------------------------------
    echo  [CRITICAL IIS REQUIREMENT MISSING]
    echo  IIS requires Microsoft URL Rewrite 2.1 and Application Request Routing
    echo  to reverse-proxy to FastAPI.
    echo.
    echo  Please install both official Microsoft IIS modules:
    echo   1. URL Rewrite 2.1 : https://www.iis.net/downloads/microsoft/url-rewrite
    echo   2. ARR 3.0         : https://www.iis.net/downloads/microsoft/application-request-routing
    echo.
    echo  TIP: 'Launch_With_Nginx.bat' runs instantly with zero extra modules!
    echo --------------------------------------------------------------------
)

:: Enable ARR Proxy and configure site
if exist "%APPCMD%" (
    "%APPCMD%" set config -section:system.webServer/proxy /enabled:"True" /commit:apphost >nul 2>&1

    :: Update or register ButtonFactory site in IIS to point to iis proxy folder
    "%APPCMD%" list site "ButtonFactory" >nul 2>&1
    if %errorlevel% equ 0 (
        "%APPCMD%" set site /site.name:"ButtonFactory" /[path='/'].physicalPath:"%IIS_DIR%" >nul 2>&1
    ) else (
        echo Registering 'ButtonFactory' site in IIS on port %IIS_PORT%...
        "%APPCMD%" add site /name:ButtonFactory /port:%IIS_PORT% /physicalPath:"%IIS_DIR%" >nul 2>&1
    )
    "%APPCMD%" start site "ButtonFactory" >nul 2>&1
)

:: Allow port in Windows Defender Firewall
netsh advfirewall firewall show rule name="Button Factory MES (8088)" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="Button Factory MES (8088)" dir=in action=allow protocol=TCP localport=%IIS_PORT% >nul 2>&1
)

echo [PASS] IIS backend reverse proxy is active on port %IIS_PORT%.
ping 127.0.0.1 -n 3 >nul
if not "%1"=="--silent" if not "%1"=="--startup" (
    start http://localhost:%IIS_PORT%/docs
    start http://%PUBLIC_DOMAIN%:%IIS_PORT%/docs
)

:SUMMARY
echo.
echo ====================================================================
echo  Button Factory Backend is running (Backend Only):
echo   - DuckDNS Access: http://%PUBLIC_DOMAIN%:%IIS_PORT% (API Docs: /docs)
echo   - Local Proxy   : http://localhost:%IIS_PORT% (API Docs: /docs)
echo   - Direct Backend: http://127.0.0.1:8000 (API Docs: /docs)
echo   - IIS Config    : %IIS_DIR%\web.config
echo ====================================================================
echo.
if "%1"=="--startup" exit /b 0
if "%1"=="--silent" exit /b 0
echo Press any key to exit launcher (servers continue running in background).
pause >nul
