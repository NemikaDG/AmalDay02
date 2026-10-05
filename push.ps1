$env:PATH = "C:\Program Files\Git\cmd;C:\Program Files\Git\ucrt64\bin;$env:PATH"
Set-Location -Path $PSScriptRoot

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Pushing Amal & Vimesha Homecoming Invitation to GitHub..." -ForegroundColor Cyan
Write-Host "Repository: https://github.com/NemikaDG/AmalDay02" -ForegroundColor Cyan
Write-Host "Branch: main" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] Code pushed to GitHub successfully!" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Push failed with exit code $LASTEXITCODE." -ForegroundColor Red
}
Write-Host "`nPress Enter to exit..."
Read-Host
