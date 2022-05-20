@echo off
setlocal enabledelayedexpansion

set SDK_VERSION=1.0.0.0
set "SDK_SETUP=%~dp0"
set "SDK_CONFIG=!SDK_SETUP!config.ini"

:: <REPO SETTINGS>
set "REPO_BASE_URL=https://github.com/"
set "REPO_USER=agamsol/DOSLib-SDK"
set "REPO_BRANCH=1.0.0.0"
set "REPO_FULL=!REPO_BASE_URL!!REPO_USER!/raw/!REPO_BRANCH!"
:: <REPO SETTINGS>

:: <LOAD ARGS>
:LOAD_ARGS
if not "%~1"=="" (
    set /a Args_count+=1
    set "Arg[!Args_count!]=%~1"
    SHIFT
    GOTO :LOAD_ARGS
)

for /L %%a in (1 1 !Args_count!) do (
    for %%b in (CURL) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="curl" (
                    if not defined Arg[%%c] (
                        echo ERROR=CURL build not specified.
                        exit /b 1
                    )
                    if not exist "!Arg[%%c]!" (
                        echo ERROR=CURL build file not found.
                        exit /b 1
                    )
                    set "SDK_CURL=!Arg[%%c]!"
                    set ENV_UPDATE=true
                )
            )
        )
    )
)
:: </LOAD ARGS>

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

call :LOAD_CONFIG "!SDK_CONFIG!"

if exist "!SDK_SETUP!Libraries\env.ini" call :LOAD_CONFIG "!SDK_SETUP!Libraries\env.ini"

if "!ENV_UPDATE!"=="true" (
    set ENV_UPDATE=false
    call :CREATE_ENVIRONMENT
)

if not defined SDK_CURL set "SDK_CURL=curl.exe"

:: <CHECK FOR SDK UPDATES>
 if not "!CHECKED_AT!"=="!DATE!" (
     if exist "!SDK_SETUP!Libraries\Libraries.ini" (
        del /s /q "!SDK_SETUP!Libraries\Libraries.ini">nul
     )
     set "CHECKED_AT=!DATE!"
     call :CREATE_CONFIG
     for /f "delims=" %%a in ('call "!SDK_CURL!" -sLk "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK-Version.ini"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set SERVER_%%a
     if defined SERVER_SDK_VERSION (
         if not "!SDK_VERSION!"=="!SERVER_SDK_VERSION!" (
         if exist "!SDK_SETUP!SDK-[NEW].bat" del "!SDK_SETUP!SDK-[NEW].bat"

         "!SDK_CURL!" -fLs#ko "!SDK_SETUP!SDK-[NEW].bat" "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK.bat"

         if not exist "!SDK_SETUP!SDK-[NEW].bat" (
             echo:
             echo ERROR=Failed to update the SDK.
             exit /b 1
         )

         REM START THE NEW UPDATE
            (
                >nul move /y "!SDK_SETUP!SDK-[NEW].bat" "%~f0"
                call "%~f0" UPDATER
            )
         REM /START THE NEW UPDATE
         exit /b 0
         )
     ) else (
         echo:
         echo ERROR=Failed to check for updates.
     )
 )
:: </CHECK FOR SDK UPDATES>

:: <UPDATE ALL LIBRARIES>
if not exist "!SDK_SETUP!Libraries\Libraries.ini" (
    >nul call "!SDK_CURL!" --create-dirs -Lkso "!SDK_SETUP!Libraries\Libraries.ini" "!REPO_FULL!/Libraries/Libraries.ini"
)

call :LOAD_CONFIG "!SDK_SETUP!Libraries\Libraries.ini"

for %%a in (!LIBRARIES!) do (
    REM CHECK IF THE LIBRARY IS ENABLED
    if /i not "!%%a!"=="false" (
        if exist "!SDK_SETUP!Libraries\%%a\META.ini" (
            set VERSION=
            set SERVER_VERSION=
            call :LOAD_CONFIG "!SDK_SETUP!Libraries\%%a\META.ini"

            for /f "delims=" %%a in ('call "!SDK_CURL!" -Lsk "!REPO_FULL!/Libraries/%%a/META.ini"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set SERVER_%%a

            if not "!VERSION!"=="!SERVER_VERSION!" (
                REM INSTALL THE UPDATE OF THE LIBRARY
                del /s /q "!SDK_SETUP!Libraries\%%a\*">nul
                for %%b in (META.ini "%%a.bat") do <nul "!SDK_CURL!" --create-dirs -#Lkso "!SDK_SETUP!Libraries\%%a\%%~b" "!REPO_FULL!/Libraries/%%a/%%~b"
            )
        ) else (
            REM INSTALL LIBRARY
            for %%b in (META.ini "%%a.bat") do <nul "!SDK_CURL!" --create-dirs -#Lkso "!SDK_SETUP!Libraries\%%a\%%~b" "!REPO_FULL!/Libraries/%%a/%%~b"
        )
        echo Library[%%a]=%~dp0Libraries\%%a\%%a.bat
    )
)
:: </UPDATE ALL LIBRARIES>
exit /b 0

:: <LOAD CONFIG>
:LOAD_CONFIG
for /f "tokens=*" %%a in ('type "%~1"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set %%a
exit /b
:: </LOAD CONFIG>

:: <CREATE_ENVIRONMENT>
:CREATE_ENVIRONMENT
>"!SDK_SETUP!Libraries\env.ini" (
    echo ; THESE VARIABLES WILL BE APPLIED TO EVERY LIBRARY IN THE SDK
    echo [ENVIRONMENT]
    echo SDK_CURL=!SDK_CURL!
)
exit /b
:: </CREATE_ENVIRONMENT>

:: <CREATE_CONFIG>
:CREATE_CONFIG
>"!SDK_CONFIG!" (
    echo ; SOFTWARE DEVELOPMENT KIT AUTOMATED CONFIG
    echo [UPDATES]
    echo CHECKED_AT=!CHECKED_AT!
)
exit /b
:: </CREATE_CONFIG>
