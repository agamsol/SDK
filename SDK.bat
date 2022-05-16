@echo off
setlocal enabledelayedexpansion
pushd %~dp0

if "%~nx0"=="SDK-[NEW].bat" (
    for /f "tokens=2 delims=," %%A in ('2^>nul tasklist /v /nh /fo csv /fi "imagename eq cmd.exe" ^| findstr /c:"SDK-[NEW] - SDK UPDATE"') do (
        >nul 2>&1 taskkill /f /pid "%%~A" /t
    )
    >nul move /y "%~nx0" "SDK.bat" && start "" "SDK.bat" && exit 0
)

set SDK_VERSION=1.0.0.0
set "SDK_CONFIG=config.ini"

:: <REPO SETTINGS>
set "REPO_BASE_URL=https://github.com/"
set "REPO_USER=agamsol/DOSLib-SDK"
set "REPO_BRANCH=!SDK_VERSION!"
set "REPO_FULL=!REPO_BASE_URL!!REPO_USER!/raw/!REPO_BRANCH!"
:: <REPO SETTINGS>

:: <INTERNET CONNECTION CHECK>
ping -n 1 github.com | findstr /c:"TTL">nul || (
    echo:
    echo ERROR=NO CONNECTION
    exit /b 1
)
:: </INTERNET CONNECTION CHECK>

if not exist "!SDK_CONFIG!" (
    set CHECKED_AT=!DATE!
    call :CREATE_CONFIG
)

call :LOAD_CONFIG
:: <CHECK FOR SDK UPDATES>
if not "!CHECKED_AT!"=="!DATE!" (
    set "CHECKED_AT=!DATE!"
    call :CREATE_CONFIG
    for /f "delims=" %%a in ('curl -sLk "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK-Version.ini"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set SERVER_%%a
    if defined SERVER_SDK_VERSION (
        if not "!SDK_VERSION!"=="!SERVER_SDK_VERSION!" (

        curl.exe -Lfs#ko "SDK-[NEW].bat" "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK.bat"

        if not exist "SDK-[NEW].bat" (
            echo:
            echo ERROR=Failed to update the SDK.
            exit /b 1
        )

        title SDK-[NEW] - SDK UPDATE
        start "" "SDK-[NEW].bat" && exit 0

        exit /b 1
        )
    ) else (
        echo:
        echo ERROR=Failed to check for updates.
    )
)
:: </CHECK FOR SDK UPDATES>

echo ended process
pause
exit /b

:: <LOAD CONFIG>
:LOAD_CONFIG
for /f "tokens=*" %%a in ('type "!SDK_CONFIG!"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set %%a
exit /b
:: </LOAD CONFIG>

:: <CREATE_CONFIG>
:CREATE_CONFIG
>"!SDK_CONFIG!" (
    echo ; SOFTWARE DEVELOPMENT KIT AUTOMATED CONFIG
    echo [UPDATES]
    echo CHECKED_AT=!CHECKED_AT!
)
exit /b
:: </CREATE_CONFIG>

