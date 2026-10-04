@echo off
cd /d "%~dp0"
echo ========================================================
echo Pushing Amal ^& Vimesha Wedding Invitation to GitHub...
echo Repository: https://github.com/NemikaDG/Ramesh_Shashika-Wedding-Invitation
echo ========================================================
echo.
"C:\Program Files\Git\cmd\git.exe" push origin master
echo.
if %errorlevel% equ 0 (
    echo [SUCCESS] Code pushed to GitHub successfully!
) else (
    echo [ERROR] Push failed. If prompted, please sign in to GitHub.
)
echo.
pause
