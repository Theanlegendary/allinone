@echo off
echo ========================================
echo RESTARTING BOT
echo ========================================
echo.

echo Step 1: Killing all Python processes...
taskkill /F /IM python.exe /T 2>nul
timeout /t 2 >nul

echo Step 2: Clearing Python cache...
del /S /Q __pycache__ 2>nul
del /S /Q *.pyc 2>nul
timeout /t 1 >nul

echo Step 3: Starting bot...
echo.
python bot.py

echo.
echo Bot stopped.
pause
