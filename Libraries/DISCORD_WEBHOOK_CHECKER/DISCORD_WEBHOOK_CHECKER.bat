@echo off
setlocal enabledelayedexpansion

:: <SDK_SYNC>
for /f "delims=" %%a in ('dir /s /b "%~dp0..\env.ini"') do set "SDK_ENVIRONMENT=%%~a"

if exist "!SDK_ENVIRONMENT!" (
    for /f "delims=" %%a in ('type "!SDK_ENVIRONMENT!"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set %%a
)

:LOAD_ARGS
if not "%~1"=="" (
    set /a Args_count+=1
    set "Arg[!Args_count!]=%~1"
    SHIFT
    GOTO :LOAD_ARGS
)

for /L %%a in (1 1 !Args_count!) do (
    for %%b in (WEBHOOK) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="webhook" (
                    if not defined Arg[%%c] (
                        echo ERROR=No webhook defined.
                        exit /b 1
                    )
                    set "WEBHOOK=!Arg[%%c]!"
                )
            )
        )
    )
)
:: </SDK_SYNC>

if not defined WEBHOOK (
    echo ERROR=No webhook defined.
    exit /b 1
)

<nul set /p="!WEBHOOK!" | >nul findstr /brc:"https://.*discord.com/api/webhooks/[0-9]*/[a-Z0-9]*" && (
    for /f %%a in ('call "!SDK_CURL!" -f -X GET -sIkw "%%{http_code}" -o nul "!WEBHOOK!"') do (
        if "%%a"=="200" exit /b 0
    )
)
exit /b 1