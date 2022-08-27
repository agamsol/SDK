@echo off
setlocal enabledelayedexpansion

set SDK_VERSION=1.0.0.2
set "SDK_CONFIG=config.ini"
set "DEFAULT_INSTALL_LOCATION=%~dp0"

:: <REPO SETTINGS>
set "REPO_BASE_URL=https://github.com/"
set "REPO_USER=agamsol/SDK"
set "REPO_BRANCH=1.0.0.2"
set "REPO_FULL=!REPO_BASE_URL!!REPO_USER!/raw/!REPO_BRANCH!"
set "CHECK_FOR_UPDATES=latest"
:: <REPO SETTINGS>

:: <LOAD ARGS>
set "ALL_ARGS=%*"
:LOAD_ARGS
if not "%~1"=="" (
    set /a Args_count+=1
    set "Arg[!Args_count!]=%~1"
    SHIFT /1
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
    if exist "!SDK_CONFIG!" call :Load-ConfigInformation "!SDK_CONFIG!" "" "" --NotALibrary
    !AFTER_CONFIG_LOAD!
)

if "!CONFIG_UPDATE!"=="true" call :CREATE_CONFIG

call :Load-ConfigInformation "!SDK_CONFIG!" "" "" --NotALibrary

if "!PRINT_VARIABLES!"=="true" (
    if defined SDK_CUSTOM_ENVIRONMENT_VARIABLES (
        for %%a in (!SDK_CUSTOM_ENVIRONMENT_VARIABLES!) do <nul set /p=%%~a | findstr /c:"=">nul && echo CUSTOM_%%~a
    )
    if "!EXIT!"=="true" exit /b
)

if not exist "Libraries" md "Libraries"

:: <UPDATE ENVIRONMENT VARIABLES>
if exist "Libraries\env.ini" call :Load-ConfigInformation "Libraries\env.ini" "" "" --NotALibrary

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
     for /f "delims=" %%a in ('call "!SDK_CURL!" -sLk "!REPO_BASE_URL!!REPO_USER!/raw/!CHECK_FOR_UPDATES!/SDK-Version.ini"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set SERVER_%%a
     if defined SERVER_SDK_VERSION (
         if not "!SDK_VERSION!"=="!SERVER_SDK_VERSION!" (
         if exist "SDK-[NEW].bat" del "SDK-[NEW].bat"

         "!SDK_CURL!" -fLs#ko "SDK-[NEW].bat" "!REPO_BASE_URL!!REPO_USER!/raw/!CHECK_FOR_UPDATES!/SDK.bat"

         if not exist "SDK-[NEW].bat" (
             echo:
             echo ERROR=Failed to update the SDK.
             exit /b 1
         )

         >nul 2>&1 del /s /q "config.ini"

         pushd "%~dp0"

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
set LIBRARIES_FIXED=0
set LIB_UPDATED=0
if not exist "Libraries\Libraries.ini" (
    call "!SDK_CURL!" -L#sko "Libraries\Libraries.ini" "!REPO_BASE_URL!!REPO_USER!/raw/!CHECK_FOR_UPDATES!/Libraries/Libraries.ini"
)

call :Load-ConfigInformation "Libraries\Libraries.ini" --DontMergeAll "SERVER_"
set SERVER_LIBRARIES=!LIBRARIES!

call :Load-ConfigInformation "Libraries\META.ini" --MergeAll "LOCAL_"

for %%a in (!SERVER_LIBRARIES!) do (

    if not "!SDK_SPECIFIC_LIBRARIES!"=="!SDK_SPECIFIC_LIBRARIES:%%a=!" (

        if /i "!SERVER_LIBRARY[%%a]_ENABLED!"=="true" (

            REM LOOP PER LIBRARY NAME - IF ENABLED
            REM echo Fetching information: %%a

            if exist "Libraries\%%a\META.ini" (

                if not exist "Libraries\%%a\!LOCAL_LIBRARY[%%a]_MAIN_SCRIPT!" (
                    REM LIBRARY SCRIPT IS MISSING - REINSTALL LIBRARY [%%a]
                    set LOCAL_LIBRARY[%%a]_REINSTALLED_NOW=true
                    >nul del /s /q "Libraries\%%a\*"
                    call :Install-Library "%%a"
                    set /a LIBRARIES_FIXED+=1
                )

                if not "!LOCAL_LIBRARY[%%a]_REINSTALLED_NOW!"=="true" (
                    if not "!SERVER_LIBRARY[%%a]_VERSION!"=="!LOCAL_LIBRARY[%%a]_VERSION!" (
                        REM UPDATE LIBRARY
                        >nul del /s /q "Libraries\%%a\*"
                        call :Install-Library "%%a"
                        set /a LIB_UPDATED+=1
                    )
                )

            ) else (
                REM LIBRARY DOES NOT EXIST - INSTALL LIBRARY FOR THE FIRST TIME
                >nul 2>&1 rmdir /s /q "Libraries\%%a"
                call :Install-Library "%%a"
            )
            echo SDK[%%a]=!SDK_INSTALL_LOCATION!\Libraries\%%a\!SERVER_LIBRARY[%%a]_MAIN_SCRIPT!
        )
    )
)

if !LIBRARIES_FIXED! equ 1 (
    set LIBRARIES_FIXED_UNIT=Fixed !LIBRARIES_FIXED! Library
) else (
    set LIBRARIES_FIXED_UNIT=Fixed !LIBRARIES_FIXED! Libraries
)

if !LIB_UPDATED! equ 1 (
    set LIB_UPDATED_UNIT=Updated !LIB_UPDATED! Library
) else (
    set LIB_UPDATED_UNIT=Updated !LIB_UPDATED! Libraries
)
echo SDK_INFORMATION_CHANGES_LOG=!LIBRARIES_FIXED_UNIT! and !LIB_UPDATED_UNIT!.

for %%a in (LIBRARIES_FIXED LIB_UPDATED) do (
    if !%%a! gtr 0 >nul 2>&1 del /s /q "Libraries\Libraries.ini"
)
exit /b 0

:: <INSTALL_LIBRARY>
:Install-Library [LIBRARY_NAME]
    <nul call "!SDK_CURL!" --create-dirs -#Lkso "Libraries\%~1\!SERVER_LIBRARY[%~1]_MAIN_SCRIPT!" "!REPO_BASE_URL!!REPO_USER!/raw/!CHECK_FOR_UPDATES!/Libraries/%~1/!SERVER_LIBRARY[%~1]_MAIN_SCRIPT!"
    >"Libraries\%~1\META.ini" (
        echo [%~1]
        echo VERSION=!SERVER_LIBRARY[%~1]_VERSION!
        echo MAIN_SCRIPT=!SERVER_LIBRARY[%~1]_MAIN_SCRIPT!
    )
exit /b

:: <LOAD_CONFIGURATION_FILES>
:Load-ConfigInformation [FILE] [--MergeAll] [VAR_PREFIX] [--NotALibrary]
    set CURRENT_LIBRARY=Undefined
    set LIBRARIES=
    if /i "%~2"=="--MergeAll" (
        set "isMergeFiles=2>nul dir /b /s "%~1""
    ) else (
        set isMergeFiles=echo "%~1"
    )
    for /f "delims=" %%a in ('!isMergeFiles!') do (
        for /f "delims=" %%b in ('type "%%~a"') do (
            REM CHECK IF CATE - IF CATE GET CATE NAME WITHOUT SQUARED QUOTES AND NAME VARS WITH PREFIX
            <nul set /p=%%b | >nul findstr /ric:"\[*\]" && (
                for /f "tokens=1 delims=[]" %%c in ("%%b") do (
                    set CURRENT_LIBRARY=%%c
                    set LIBRARIES=!LIBRARIES! %%c
                )
            ) || (
                if "%~4"=="--NotALibrary" (
                    set %%b
                ) else (
                    set "%~3LIBRARY[!CURRENT_LIBRARY!]_%%b"
                )
            )
        )
    )
    exit /b
:: </LOAD_CONFIGURATION_FILES>

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
