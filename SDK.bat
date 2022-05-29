@echo off
setlocal enabledelayedexpansion

set SDK_VERSION=1.0.0.0
set "SDK_CONFIG=config.ini"
set "DEFAULT_INSTALL_LOCATION=%~f0"

:: <REPO SETTINGS>
set "REPO_BASE_URL=https://github.com/"
set "REPO_USER=agamsol/DOSLib-SDK"
set "REPO_BRANCH=1.0.0.0"
set "REPO_FULL=!REPO_BASE_URL!!REPO_USER!/raw/!REPO_BRANCH!"
:: <REPO SETTINGS>

:: <LOAD ARGS>
set "ALL_ARGS=%*"
:LOAD_ARGS
if not "%~1"=="" (
    set /a Args_count+=1
    set "Arg[!Args_count!]=%~1"
    SHIFT
    GOTO :LOAD_ARGS
)

for /L %%a in (1 1 !Args_count!) do (
    for %%b in (CURL LIBRARIES INSTALL-LOCATION GET-VARIABLES ADD-VARIABLE RESET-VARIABLES) do (
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
                if /i "%%b"=="libraries" (
                    if not defined Arg[%%c] (
                        echo ERROR=No libraries defined.
                        exit /b 1
                    )
                    set SDK_SPECIFIC_LIBRARIES=!Arg[%%c]!
                )
                if /i "%%b"=="install-location" (
                    if not defined Arg[%%c] (
                        echo ERROR=You did not specify the location to install the SDK in.
                        exit /b 1
                    )
                    if not exist "!Arg[%%c]!" (
                        echo ERROR=The location specified does not exist.
                        exit /b 1
                    )
                    for /f "delims=" %%d in ("!Arg[%%c]!") do set "SDK_INSTALL_LOCATION=%%~fd"
                    pushd "!Arg[%%c]!"
                )
                if /i "%%b"=="get-variables" (
                    set PRINT_VARIABLES=true
                    if "!Arg[%%c]!"=="exit" set EXIT=true
                )
                if /i "%%b"=="add-variable" (
                    if not defined Arg[%%c] (
                        echo ERROR=No variable defined.
                        exit /b 1
                    )
                    set ARG_REQUIRE_CONFIG=true
                    set "SDK_CUSTOM_ENVIRONMENT_VARIABLES=!SDK_CUSTOM_ENVIRONMENT_VARIABLES! "!Arg[%%c]!""
                    set "AFTER_CONFIG_LOAD=set SDK_CUSTOM_ENVIRONMENT_VARIABLES=!SDK_CUSTOM_ENVIRONMENT_VARIABLES!"
                    set CONFIG_UPDATE=true
                    set ENV_UPDATE=true
                )
                if /i "%%b"=="reset-variables" (
                    set ARG_REQUIRE_CONFIG=true
                    set "AFTER_CONFIG_LOAD=SET SDK_CUSTOM_ENVIRONMENT_VARIABLES="
                    set CONFIG_UPDATE=true
                    set ENV_UPDATE=true
                )
            )
        )
    )
)
:: </LOAD ARGS>

if not defined SDK_INSTALL_LOCATION (
    set "SDK_INSTALL_LOCATION=!DEFAULT_INSTALL_LOCATION!"
    pushd "%~dp0"
)

:: <INTERNET CONNECTION CHECK>
 ping -n 1 github.com | findstr /c:"TTL">nul || (
     echo ERROR=NO CONNECTION
     exit /b 1
 )
:: </INTERNET CONNECTION CHECK>

if not exist "!SDK_CONFIG!" (
    set CHECKED_AT=!DATE!
    set CONFIG_UPDATE=true
)

if "!ARG_REQUIRE_CONFIG!"=="true" (
    if exist "!SDK_CONFIG!" call :LOAD_CONFIG "!SDK_CONFIG!" *
    !AFTER_CONFIG_LOAD!
)

if "!CONFIG_UPDATE!"=="true" call :CREATE_CONFIG

call :LOAD_CONFIG "!SDK_CONFIG!" *

if "!PRINT_VARIABLES!"=="true" (
    if defined SDK_CUSTOM_ENVIRONMENT_VARIABLES (
        for %%a in (!SDK_CUSTOM_ENVIRONMENT_VARIABLES!) do <nul set /p=%%~a | findstr /c:"=">nul && echo CUSTOM_%%~a
    )
    if "!EXIT!"=="true" exit /b
)

if not exist "Libraries" md "Libraries"

:: <UPDATE ENVIRONMENT VARIABLES>
if exist "Libraries\env.ini" call :LOAD_CONFIG "Libraries\env.ini" *

if not "!SDK_CORE!"=="!DEFAULT_INSTALL_LOCATION!" (
    set "SDK_CORE=!DEFAULT_INSTALL_LOCATION!"
    set ENV_UPDATE=true
)

if not defined SDK_CURL (
    for /f "delims=" %%a in ('where curl.exe 2^>nul') do set SDK_CURL=%%a
    if not defined SDK_CURL set "SDK_CURL=curl.exe"
    set ENV_UPDATE=true
)

if "!ENV_UPDATE!"=="true" call :CREATE_ENVIRONMENT

if "!EXIT!"=="true" exit /b

:: </UPDATE ENVIRONMENT VARIABLES>

:: <CHECK FOR SDK UPDATES>
 if not "!CHECKED_AT!"=="!DATE!" (
     >nul 2>&1 del /s /q "Libraries\Libraries.ini"
     set "CHECKED_AT=!DATE!"
     call :CREATE_CONFIG
     for /f "delims=" %%a in ('call "!SDK_CURL!" -sLk "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK-Version.ini"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set SERVER_%%a
     if defined SERVER_SDK_VERSION (
         if not "!SDK_VERSION!"=="!SERVER_SDK_VERSION!" (
         if exist "SDK-[NEW].bat" del "SDK-[NEW].bat"

         "!SDK_CURL!" -fLs#ko "SDK-[NEW].bat" "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK.bat"

         if not exist "SDK-[NEW].bat" (
             echo:
             echo ERROR=Failed to update the SDK.
             exit /b 1
         )

         >nul 2>&1 del /s /q "config.ini"

         REM START THE NEW UPDATE
            (
                >nul move /y "SDK-[NEW].bat" "!DEFAULT_INSTALL_LOCATION!"
                call "!DEFAULT_INSTALL_LOCATION!" !ALL_ARGS!
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
if not exist "Libraries\Libraries.ini" (
    call "!SDK_CURL!" -L#sko "Libraries\Libraries.ini" "!REPO_BASE_URL!!REPO_USER!/raw/latest/Libraries/Libraries.ini"
)

call :LOAD_CONFIG "Libraries\Libraries.ini" Libraries

for %%a in (!LIBRARIES!) do if not "!SDK_SPECIFIC_LIBRARIES!"=="!SDK_SPECIFIC_LIBRARIES:%%a=!" (

        REM echo Fetching information: %%a

    for %%a in (ENABLED VERSION LIBRARY_NAME MAIN_SCRIPT) do (
        set LOCAL_%%a=
        set SERVER_%%a=
    )
    REM CHECK IF THE LIBRARY IS ENABLED
    call :LOAD_CONFIG "Libraries\Libraries.ini" %%a "SERVER_"

    if /i not "!SERVER_ENABLED!"=="false" (

        REM IF THE LIBRARY EXISTS:
        if exist "Libraries\%%a\META.ini" (

            call :LOAD_CONFIG "Libraries\%%a\META.ini" %%a "LOCAL_"

            if not "!LOCAL_VERSION!"=="!SERVER_VERSION!" (
                REM UPDATE LIBRARY
                >nul del /s /q "Libraries\!SERVER_LIBRARY_NAME!\*"
                call <nul "!SDK_CURL!" --create-dirs -#Lkso "Libraries\!SERVER_LIBRARY_NAME!\!SERVER_MAIN_SCRIPT!" "!REPO_BASE_URL!!REPO_USER!/raw/latest/Libraries/!SERVER_LIBRARY_NAME!/!SERVER_MAIN_SCRIPT!"
                >"Libraries\!SERVER_LIBRARY_NAME!\META.ini" (
                    echo [!SERVER_LIBRARY_NAME!]
                    echo VERSION=!SERVER_VERSION!
                    echo LIBRARY_NAME=!SERVER_LIBRARY_NAME!
                    echo MAIN_SCRIPT=!SERVER_MAIN_SCRIPT!
                )
                set /a LIB_UPDATED+=1
            )
        ) else if exist "Libraries\%%a" >nul rmdir /s /q "Libraries\%%a"

        for %%b in (META.ini "!SERVER_MAIN_SCRIPT!") do (
            if not exist "Libraries\!SERVER_LIBRARY_NAME!\%%~b" (
                REM INSTALL LIBRARY
                call <nul "!SDK_CURL!" --create-dirs -#Lkso "Libraries\!SERVER_LIBRARY_NAME!\!SERVER_MAIN_SCRIPT!" "!REPO_BASE_URL!!REPO_USER!/raw/latest/Libraries/!SERVER_LIBRARY_NAME!/!SERVER_MAIN_SCRIPT!"
                >"Libraries\!SERVER_LIBRARY_NAME!\META.ini" (
                    echo [!SERVER_LIBRARY_NAME!]
                    echo VERSION=!SERVER_VERSION!
                    echo LIBRARY_NAME=!SERVER_LIBRARY_NAME!
                    echo MAIN_SCRIPT=!SERVER_MAIN_SCRIPT!
                )
            )
        )
        echo SDK[!SERVER_LIBRARY_NAME!]=!SDK_INSTALL_LOCATION!\Libraries\!SERVER_LIBRARY_NAME!\!SERVER_MAIN_SCRIPT!
    )
)
if !LIB_UPDATED! gtr 0 >nul 2>&1 del /s /q "Libraries\Libraries.ini"
exit /b 0
:: </UPDATE ALL LIBRARIES>

:: <LOAD CONFIG>
:LOAD_CONFIG [FILE] [CATEGORY] [VAR_PREFIX]
for /f "delims= usebackq" %%a in ("%~1") do (
    if !ParseCategory! equ 1 (
        <nul set /p=%%a | findstr /ric:"\[*\]">nul && (
            set ParseCategory=0
        ) || <nul set /p=%%a | findstr /brc:"[#]">nul || set "%~3%%a"
    )
    echo %%a | findstr /ric:"\[%~2\]">nul && set ParseCategory=1
)
exit /b
:: </LOAD CONFIG>

:: <CREATE_ENVIRONMENT>
:CREATE_ENVIRONMENT
>"Libraries\env.ini" (
    echo ; THESE VARIABLES WILL BE APPLIED TO EVERY LIBRARY IN THE SDK
    echo [ENVIRONMENT]
    echo SDK_CORE=!SDK_CORE!
    echo SDK_CURL=!SDK_CURL!
    echo:
    echo [CUSTOM]
    for %%a in (!SDK_CUSTOM_ENVIRONMENT_VARIABLES!) do <nul set /p=%%~a | findstr /c:"=">nul && echo CUSTOM_%%~a
)
exit /b
:: </CREATE_ENVIRONMENT>

:: <CREATE_CONFIG>
:CREATE_CONFIG
>"!SDK_CONFIG!" (
    echo ; SOFTWARE DEVELOPMENT KIT AUTOMATED CONFIG
    echo [UPDATES]
    echo CHECKED_AT=!CHECKED_AT!
    echo:
    echo [VARIABLES]
    echo SDK_CUSTOM_ENVIRONMENT_VARIABLES=!SDK_CUSTOM_ENVIRONMENT_VARIABLES!
)
exit /b
:: </CREATE_CONFIG>
