# E-Ticaret Mutabakat - Sunucu Baslatici
$projectRoot = "c:\Users\abdul\Documents\GitHub\e_ticaret_mutabakat"
$venvActivate = "$projectRoot\venv\Scripts\Activate.ps1"
$backendDir = "$projectRoot\backend"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  E-Ticaret Mutabakat Sunucusu Baslatiliyor..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

if (Test-Path $venvActivate) {
    Write-Host "`n[1/2] Virtual environment aktif ediliyor..." -ForegroundColor Yellow
    & $venvActivate
    Write-Host "      Venv aktif!" -ForegroundColor Green
} else {
    Write-Host "`n[HATA] venv bulunamadi!" -ForegroundColor Red
    exit 1
}

Write-Host "`n[2/2] Flask sunucusu baslatiliyor..." -ForegroundColor Yellow
Write-Host "      Adres: http://localhost:5000`n" -ForegroundColor Green

Set-Location $backendDir
$pythonExe = "$projectRoot\venv\Scripts\python.exe"
& $pythonExe app.py
