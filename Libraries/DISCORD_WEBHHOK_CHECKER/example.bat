@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

REM This library allows you to check whether a webhook is working or not.

REM METHOD #1
REM Check if the library returned an error (ERRORLEVEL = 1) or success (ERRORLEVEL 0)
set "WEBHOOK=<WEBHOOK_HERE>"
call "DISCORD_WEBHHOK_CHECKER.bat" "%WEBHOOK%" && (
    echo Webhook provided is valid.
) || (
    echo Webhook provided is invalid.
)

exit /b