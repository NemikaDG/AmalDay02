@echo off
cd /d "%~dp0"
echo ========================================================
echo Pushing Amal ^& Vimesha Wedding Invitation to GitHub...
echo Repository: https://github.com/NemikaDG/Amal_Vimesha-Wedding-Invitation
echo Branch: main
echo ========================================================
echo.
"C:\Program Files\Git\cmd\git.exe" push -u origin main
echo.
if %errorlevel% equ 0 (
    echo [SUCCESS] Code pushed to GitHub successfully!
) else (
    echo [ERROR] Push failed. 
    echo If the repository does not exist yet on GitHub, please create it first at:
    echo https://github.com/new?name=Amal_Vimesha-Wedding-Invitation
)
echo.
pause
