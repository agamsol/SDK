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
    for %%b in (GET-BITS GET-EDITION) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="get-bits" set GET_BITS=true
                if /i "%%b"=="get-edition" set GET_EDITION=true
            )
        )
    )
)
:: </SDK_SYNC>

REM OS VERSION DETECTION FORK
REM   Credits: Mathieu#4291

 for /f "tokens=4-7delims=[.] " %%A in ('ver') do (
     if /i "%%A"=="version" (
         set "WINDOWS_VERSION=%%B.%%C"
     ) else (
         set "WINDOWS_VERSION=%%A.%%B"
     )
 )

REM /FORK END

if "!WINDOWS_VERSION!"=="5.0" (
    echo OS_VERSION=Windows 2000
) else for %%a in (5.1 5.2) do if "!WINDOWS_VERSION!"=="%%a" (
    echo OS_VERSION=Windows XP
) else if "!WINDOWS_VERSION!"=="6.0" (
    echo OS_VERSION=Windows Vista
) else (
    for /f "tokens=3-4 skip=1" %%a in ('wmic os get caption') do (
        if not defined OS_VERSION (
            set OS_VERSION=1
            echo OS_VERSION=Windows %%a
            if "!GET_EDITION!"=="true" echo OS_EDITION=%%b
        )
    )
)

if "!GET_BITS!"=="true" (
   if defined ProgramFiles^(x86^) (
       echo OS_BITS=64
   ) else echo OS_BITS=86
)