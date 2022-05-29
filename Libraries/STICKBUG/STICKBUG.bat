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
    for %%b in (IMAGE OUTPUT) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="image" (
                    if not defined Arg[%%c] (
                        echo ERROR=Image not defined.
                        exit /b 1
                    )
                    set "IMAGE=!Arg[%%c]!"
                )
                if /i "%%b"=="output" (
                    if not defined Arg[%%c] (
                        echo ERROR=No output file specified.
                        exit /b 1
                    )
                    set "OUTPUT=!Arg[%%c]!"
                )
            )
        )
    )
)
:: </SDK_SYNC>

ping -n 1 nekobot.xyz | >nul findstr /c:"TTL" || (
    echo ERROR=You may seem to not be connected to the internet or nekobot.xyz is offline.
    exit /b 1
)

for %%a in (IMAGE OUTPUT) do if not defined %%a (
    echo ERROR=You did not specify the parameter '%%a'
    exit /b 1
)

for /f delims^=^"^ tokens^=4 %%a in ('curl -s "https://nekobot.xyz/api/imagegen?type=stickbug&url=!IMAGE!"') DO set "URL=%%a"

call "!SDK_CURL!" -s#klo "!OUTPUT!" "!URL!" || (
    echo ERROR=Unknown error, no further information.
    exit /b 1
)

exit /b 0
