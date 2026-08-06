@echo off
echo ========================================
echo FORCE CLEAN RESTART - REMOVING ALL CACHES
echo ========================================
echo.

echo Step 1: Killing ALL Python processes...
taskkill /F /IM python.exe /T 2>nul
taskkill /F /IM pythonw.exe /T 2>nul
timeout /t 3 >nul

echo Step 2: Deleting Python cache files...
echo    - Deleting __pycache__ directories...
for /d /r . %%d in (__pycache__) do @if exist "%%d" rd /s /q "%%d"

echo    - Deleting .pyc files...
del /S /Q *.pyc 2>nul

echo    - Deleting .pyo files...
del /S /Q *.pyo 2>nul

timeout /t 2 >nul

echo Step 3: Verifying no Python processes...
tasklist | findstr python
if %ERRORLEVEL% EQU 0 (
    echo    WARNING: Python still running! Trying again...
    taskkill /F /IM python.exe /T 2>nul
    timeout /t 2 >nul
) else (
    echo    ✓ All Python processes killed
)

echo.
echo Step 4: Starting bot with fresh code...
echo ========================================
echo.

python bot.py

echo.
echo Bot stopped.
pause
