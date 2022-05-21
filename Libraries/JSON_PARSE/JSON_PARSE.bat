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
    for %%b in (FILE KEYS) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="file" (
                    if not defined Arg[%%c] (
                        echo ERROR=File not specified.
                        exit /b 1
                    )
                    if not exist "!Arg[%%c]!" (
                        echo ERROR=File not found.
                        exit /b 1
                    )
                    set "JsonParse_FILE=!Arg[%%c]!"
                )
                if /i "%%b"=="keys" (
                    if not defined Arg[%%c] (
                        echo ERROR=No keys specified to parse.
                        exit /b 1
                    )
                    set "JsonParse_KEYS=!Arg[%%c]!"
                )
            )
        )
    )
)
:: </SDK_SYNC>

for %%a in (FILE KEYS) do if not defined JsonParse_%%a (
    echo ERROR=You must specify 'file' and 'keys' using parameters.
    exit /b 1
)

for %%a in (!JsonParse_KEYS!) do (
    set "JsonParse_COMMAND=!JsonParse_COMMAND!; if ($Fully.%%~a -is [bool]) { $Fully.%%~a = $Fully.%%~a.ToString().ToLower() } ;  $Result = '%%~a=' + $Fully.%%~a ; $Result"
)

for /f "delims=" %%a in ('powershell "$Fully = (Get-Content -raw '!JsonParse_FILE!' | ConvertFrom-Json) !JsonParse_COMMAND!"') do echo %%a
exit /b