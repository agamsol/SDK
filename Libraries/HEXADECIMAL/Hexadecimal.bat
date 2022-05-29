@echo off
setlocal enabledelayedexpansion

rem Arguments:
rem   --plain-to-hex    Convert Plain String to Hex String
rem   --hex-to-plain    Convert hex string to plain string

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
    for %%b in (PLAIN-TO-HEX HEX-TO-PLAIN) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="plain-to-hex" (
                    if not defined Arg[%%c] (
                        echo ERROR=String not defined.
                        exit /b 1
                    )
                    set "PlainString=!Arg[%%c]!"
                    call :PlainToHex
                    exit /b 0
                )
                if /i "%%b"=="hex-to-plain" (
                    if not defined Arg[%%c] (
                        echo ERROR=String not defined.
                        exit /b 1
                    )
                    set "HexString=!Arg[%%c]!"
                    call :HexToPlain
                    exit /b 0
                )
            )
        )
    )
)
:: </SDK_SYNC>

exit /b 1

:PlainToHex
echo !PlainString!>PlainText.hex
certutil -encodehex PlainText.hex output.hex >nul
set "HexString="
for /f "delims=" %%A in (output.hex) do (
    set "line=%%A"
    set "line=!line:~5,48!"
    set "HexString=!HexString!!line!"
)
del PlainText.hex output.hex
set "HexString=!HexString: =!"
echo !HexString!
goto:eof

:HexToPlain
echo !HexString!>HexString.hex
certutil -decodehex HexString.hex output.hex >nul
set /p PlainString=<output.hex
del HexString.hex output.hex
echo !PlainString!
goto:eof