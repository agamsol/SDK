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
    for %%b in (SOME) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="SOME" (
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

for %%a in (status, country, countryCode, region, regionName, city, lat, lon, timezone, currency, isp, proxy, query) do (
    set /a ArrayLine+=1
    set Net[!ArrayLine!]=%%~a
)

for /f "delims=" %%a in ('call "!SDK_CURL!" -sk "http://ip-api.com/line?fields=8578015"') do (
    set /a ValueLine+=1
    for %%b in ("!ValueLine!") do echo !Net[%%~b]!=%%a
)

exit /b 0
