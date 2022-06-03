@echo off
setlocal enabledelayedexpansion

:: SETTINGS
if defined ProgramFiles(x86) (set SYSTEM_BITS=64) else set SYSTEM_BITS=86
set "SDK_LOCATION=%appdata%\SDK"
:: [END] SETTINGS

call :IMPORT_SDK && (
    echo INFO: Installed SDK.
    echo INFO: Starting SDK.
    for /f "delims=" %%a in ('call "!SDK_CORE!" --curl "!SDK_CURL!" --install-location "!SDK_LOCATION!"') do set %%a
)

REM Your Script here

exit /b

:: <IMPORT SDK>
:IMPORT_SDK
set SDK_CURL=
if not exist "!SDK_LOCATION!" md "!SDK_LOCATION!"
for /f "delims=" %%a in ('2^>nul where curl.exe ^|^| echo 1') do (
    if %%a neq 1 (
        call :VALIDATE_CURL_INSTALLATION "%%a" && set "SDK_CURL=%%a"
    ) else (
        if exist "!SDK_LOCATION!\curl.exe" call :VALIDATE_CURL_INSTALLATION "!SDK_LOCATION!\curl.exe" && set "SDK_CURL=!SDK_LOCATION!\curl.exe"
    )
)
if not defined SDK_CURL call :IMPORT_CURL || exit /b 1

set "SDK_CORE=%SDK_LOCATION%\SDK.bat"

if not exist "!SDK_CORE!" call "!SDK_CURL!" -L#sko "!SDK_CORE!" "https://raw.githubusercontent.com/agamsol/SDK/latest/SDK.bat"
exit /b 0
:: </IMPORT SDK>

:: <IMPORT CURL>
:IMPORT_CURL
for /f "delims=" %%a in ("https://github.com/agamsol/SDK/raw/latest/curl/x!SYSTEM_BITS!/curl.exe") do (
    set "SDK_CURL=!SDK_LOCATION!\curl.exe"
    >nul chcp 437
    >nul 2>&1 powershell /? && (
        >nul 2>&1 powershell $progressPreference = 'silentlyContinue'; Invoke-WebRequest -Uri "'%%~a'" -OutFile "'!SDK_CURL!'"
        >nul chcp 65001
        call :VALIDATE_CURL_INSTALLATION "!SDK_CURL!" && exit /b 0
    )
    >nul chcp 65001
    >nul bitsadmin /transfer someDownload /download /priority high "%%~a" "!SDK_CURL!"
    call :VALIDATE_CURL_INSTALLATION "!SDK_CURL!" && exit /b 0
    >nul certutil -urlcache -split -f "%%~a" "!SDK_CURL!"
    call :VALIDATE_CURL_INSTALLATION "!SDK_CURL!" && exit /b 0
)
exit /b 1

:VALIDATE_CURL_INSTALLATION "[CURL]"
if not exist "%~1" exit /b 1
call "%~1" --version | findstr /brc:"curl [0-9]*\.[0-9]*\.[0-9]*">nul || (
    >nul 2>&1 del /s /q "%~1"
    exit /b 1
)
exit /b 0
:: </IMPORT CURL>
