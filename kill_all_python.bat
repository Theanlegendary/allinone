@echo off
echo Killing ALL Python processes...
taskkill /F /IM python.exe /T 2>nul
echo Done!
timeout /t 2
