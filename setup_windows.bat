@echo off
setlocal
cd /d "%~dp0"
python -m pip install -r requirements.txt
if not defined LOCALBRIDGE_BACKEND_BASE_URL set LOCALBRIDGE_BACKEND_BASE_URL=http://127.0.0.1:8888
set /p BACKEND_URL=Backend URL [%LOCALBRIDGE_BACKEND_BASE_URL%]: 
if "%BACKEND_URL%"=="" set BACKEND_URL=%LOCALBRIDGE_BACKEND_BASE_URL%
if not exist "%LOCALAPPDATA%\LocalBridge" mkdir "%LOCALAPPDATA%\LocalBridge"
> "%LOCALAPPDATA%\LocalBridge\backend_url.txt" echo %BACKEND_URL%
echo LocalBridge is ready.
echo Backend: %BACKEND_URL%
echo Open the LocalBridge website, then keep this agent window running while pairing.
python clients\windows\localbridge_agent.py
pause
