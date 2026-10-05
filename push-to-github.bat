@echo off
set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\ucrt64\bin;%PATH%"
cd /d "%~dp0"

echo ========================================================
echo Pushing Amal ^& Vimesha Homecoming Invitation to GitHub...
echo Repository: https://github.com/NemikaDG/AmalDay02
echo Branch: main
echo ========================================================
echo.

git push -u origin main

echo.
if %errorlevel% equ 0 (
    echo [SUCCESS] Code pushed to GitHub successfully!
) else (
    echo [ERROR] Push failed with exit code %errorlevel%.
    echo If prompted by your browser or GitHub, please complete the sign-in.
)
echo.
pause
