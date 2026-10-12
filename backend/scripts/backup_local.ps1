# ==============================================================================
# Button Factory MES - Automated Local Dual-Drive Backup Script (Zero Cloud)
# Can be scheduled via Windows Task Scheduler (e.g. every 4 hours or nightly)
# ==============================================================================

param(
    [string]$SourceMediaDir = "C:\Users\User\Desktop\button_factory\backend\media",
    [string]$SourceDbFile   = "C:\Users\User\Desktop\button_factory\backend\btn_factory.db",
    [string]$BackupTarget   = "D:\button_factory_backup"  # Change to secondary SSD / external drive
)

$ErrorActionPreference = "Continue"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Button Factory MES - Local Backup Started at $(Get-Date)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Create backup directories
$DbBackupDir = Join-Path $BackupTarget "database"
$MediaBackupDir = Join-Path $BackupTarget "media"
$LogBackupDir = Join-Path $BackupTarget "logs"

New-Item -ItemType Directory -Force -Path $DbBackupDir | Out-Null
New-Item -ItemType Directory -Force -Path $MediaBackupDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogBackupDir | Out-Null

$LogFile = Join-Path $LogBackupDir "backup_$Timestamp.log"

# 2. Database Backup (Safe hot backup)
if (Test-Path $SourceDbFile) {
    $TargetDbSnapshot = Join-Path $DbBackupDir "btn_factory_$Timestamp.db"
    Write-Host "[1/2] Backing up SQLite database..." -ForegroundColor Yellow
    
    # Copy SQLite DB file (including -wal and -shm if present for WAL mode)
    Copy-Item $SourceDbFile $TargetDbSnapshot -Force
    if (Test-Path "$SourceDbFile-wal") {
        Copy-Item "$SourceDbFile-wal" "$TargetDbSnapshot-wal" -Force
    }
    if (Test-Path "$SourceDbFile-shm") {
        Copy-Item "$SourceDbFile-shm" "$TargetDbSnapshot-shm" -Force
    }
    Write-Host "      Database snapshot saved to: $TargetDbSnapshot" -ForegroundColor Green
} else {
    Write-Host "[1/2] Note: SQLite file not found at $SourceDbFile (PostgreSQL may be in use)." -ForegroundColor Gray
}

# 3. Media Directory Mirroring via Robocopy
if (Test-Path $SourceMediaDir) {
    Write-Host "[2/2] Mirroring local media repository via Robocopy..." -ForegroundColor Yellow
    # /MIR = Mirror directory tree
    # /R:2 /W:5 = Retry 2 times, wait 5 seconds between retries
    # /NP = No progress % in log (cleaner log file)
    robocopy $SourceMediaDir $MediaBackupDir /MIR /R:2 /W:5 /NP /LOG+:$LogFile
    Write-Host "      Media mirrored successfully to: $MediaBackupDir" -ForegroundColor Green
} else {
    Write-Host "[2/2] Warning: Media directory not found at $SourceMediaDir" -ForegroundColor Yellow
}

# 4. Snapshot retention management (Keep latest 14 DB backups)
$OldBackups = Get-ChildItem -Path $DbBackupDir -Filter "btn_factory_*.db" | Sort-Object CreationTime -Descending | Select-Object -Skip 14
foreach ($Old in $OldBackups) {
    Remove-Item $Old.FullName -Force -ErrorAction SilentlyContinue
    Remove-Item "$($Old.FullName)-wal" -Force -ErrorAction SilentlyContinue
    Remove-Item "$($Old.FullName)-shm" -Force -ErrorAction SilentlyContinue
    Write-Host "      Pruned older snapshot: $($Old.Name)" -ForegroundColor DarkGray
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Backup completed successfully at $(Get-Date)" -ForegroundColor Green
Write-Host "Logs available at: $LogFile" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
