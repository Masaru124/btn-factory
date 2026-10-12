# ==============================================================================
# Button Factory MES - Master Local Server Startup Script
# Starts: FastAPI Backend, Caddy Gateway (port 80), and displays Tablet LAN URLs
# ==============================================================================

$RootPath = Split-Path -Parent $PSScriptRoot
$BackendPath = Join-Path $RootPath "backend"
$VenvPython = Join-Path $BackendPath "venv\Scripts\python.exe"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   BUTTON FACTORY MANUFACTURING EXECUTION SYSTEM (MES)    " -ForegroundColor Green
Write-Host "   100% On-Premise Local Gateway & Server Manager         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Detect Local LAN IP Address
$LocalIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*" -and 
    $_.InterfaceAlias -notlike "*Loopback*" 
} | Select-Object -First 1).IPAddress

if (-not $LocalIP) {
    $LocalIP = "127.0.0.1"
}

Write-Host ""
Write-Host "[Network Diagnostics]" -ForegroundColor Yellow
Write-Host "  * Factory Host Server IP: $LocalIP" -ForegroundColor White
Write-Host "  * Shop Floor Tablet URL:  http://$LocalIP/" -ForegroundColor Green
Write-Host "  * Local Admin URL:        http://localhost/" -ForegroundColor White
Write-Host "  * Backend API Swagger:    http://127.0.0.1:8000/docs" -ForegroundColor White
Write-Host ""

# 2. Check Python Environment
if (-not (Test-Path $VenvPython)) {
    Write-Host "[ERROR] Python venv not found at $VenvPython" -ForegroundColor Red
    Write-Host "Please ensure backend\venv is configured." -ForegroundColor Red
    Exit 1
}

# 3. Create Media and Log directories
$MediaDir = Join-Path $BackendPath "media"
$LogDir = Join-Path $BackendPath "logs"
New-Item -ItemType Directory -Force -Path $MediaDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

Write-Host "[Services Status]" -ForegroundColor Yellow

# 4. Check Caddy Installation
$CaddyExe = Get-Command "caddy" -ErrorAction SilentlyContinue
if ($CaddyExe) {
    Write-Host "  * Caddy reverse proxy detected. Starting Caddy on Port 80..." -ForegroundColor Green
    Start-Process -FilePath "caddy" -ArgumentList "run --config $RootPath\Caddyfile" -WorkingDirectory $RootPath -WindowStyle Minimized
} else {
    Write-Host "  * Caddy not found in PATH." -ForegroundColor Yellow
    Write-Host "    To run on port 80 with static web & media caching:" -ForegroundColor Gray
    Write-Host "    Download caddy.exe from https://caddyserver.com/download and place in Windows PATH." -ForegroundColor Gray
}

# 5. Start Uvicorn Backend
Write-Host "  * Starting FastAPI / Uvicorn server on 127.0.0.1:8000..." -ForegroundColor Green
Set-Location $BackendPath
& $VenvPython -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
