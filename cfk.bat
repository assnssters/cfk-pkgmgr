@echo off
setlocal enabledelayedexpansion

set "JSON_URL=https://example.com/packages.json"
set "PKG_NAME=%1"
set "JSON_FILE=%TEMP%\packages.json"
set "DL_FILE=%TEMP%\%PKG_NAME%.exe"

if "%PKG_NAME%"=="" (
    echo Package name required
    exit /b 1
)

powershell -Command "Invoke-WebRequest -Uri '%JSON_URL%' -OutFile '%JSON_FILE%'"

if not exist "%JSON_FILE%" (
    echo Failed to fetch JSON
    exit /b 1
)

for /f "tokens=*" %%i in ('powershell -NoProfile -Command ^
  "$json=Get-Content -Raw -Path '%JSON_FILE%' | ConvertFrom-Json; ^
   $json.%PKG_NAME%.url"') do (
    set "APP_URL=%%i"
)

for /f "tokens=*" %%i in ('powershell -NoProfile -Command ^
  "$json=Get-Content -Raw -Path '%JSON_FILE%' | ConvertFrom-Json; ^
   $json.%PKG_NAME%.install_cmd"') do (
    set "INSTALL_CMD=%%i"
)

if not defined APP_URL (
    echo Package not found
    exit /b 1
)

powershell -Command "Invoke-WebRequest -Uri '!APP_URL!' -OutFile '%DL_FILE%'"

if not exist "%DL_FILE%" (
    echo Download failed
    exit /b 1
)

"%DL_FILE%" !INSTALL_CMD!
exit /b 0
