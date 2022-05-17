@echo off
if "%~1"=="UPDATER" (
    echo this version is now up to date.
    pause
)
setlocal enabledelayedexpansion
pushd %~dp0

set SDK_VERSION=1.0.0.0
set "SDK_CONFIG=config.ini"

:: <REPO SETTINGS>
set "REPO_BASE_URL=https://github.com/"
set "REPO_USER=agamsol/DOSLib-SDK"
set "REPO_BRANCH=!SDK_VERSION!"
set "REPO_FULL=!REPO_BASE_URL!!REPO_USER!/raw/!REPO_BRANCH!"
:: <REPO SETTINGS>

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

:: <CHECK FOR SDK UPDATES>
 if not "!CHECKED_AT!"=="!DATE!" (
     set "CHECKED_AT=!DATE!"
     call :CREATE_CONFIG
     for /f "delims=" %%a in ('curl -sLk "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK-Version.ini"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set SERVER_%%a
     if defined SERVER_SDK_VERSION (
         if not "!SDK_VERSION!"=="!SERVER_SDK_VERSION!" (
         if exist "SDK-[NEW].bat" del "SDK-[NEW].bat"
         curl.exe -fLs#ko "SDK-[NEW].bat" "!REPO_BASE_URL!!REPO_USER!/raw/latest/SDK.bat"

         if not exist "SDK-[NEW].bat" (
             echo:
             echo ERROR=Failed to update the SDK.
             exit /b 1
         )

         REM START THE NEW UPDATE
            (
                >nul move /y "SDK-[NEW].bat" "%~f0"
                "%~f0" UPDATER
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

if not "!CHECKED_AT!"=="!DATE!" (
    if exist "%temp%\DOSLib\Libraries.ini" (
        del /s /q "%temp%\DOSLib\Libraries.ini">nul
    )
)
if not exist "%temp%\DOSLib\Libraries.ini" (
    echo Downloading Library DATA . . .
    >nul curl --create-dirs -Lks "!REPO_FULL!/Libraries/Libraries.ini" -o "%temp%\DOSLib\Libraries.ini"
)

call :LOAD_CONFIG "%temp%\DOSLib\Libraries.ini"

for %%a in (!LIBRARIES!) do (
    REM CHECK IF THE LIBRARY IS ENABLED
    if /i not "!%%a!"=="false" (
        if exist "Libraries\%%a\META.ini" (
            set VERSION=
            set SERVER_VERSION=
            call :LOAD_CONFIG "Libraries\%%a\META.ini"

            for /f "delims=" %%a in ('curl -Lsk "!REPO_FULL!/Libraries/%%a/META.ini"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set SERVER_%%a

            if not "!VERSION!"=="!SERVER_VERSION!" (
                REM INSTALL THE UPDATE OF THE LIBRARY
                del /s /q "Libraries\%%a\*">nul
                for %%b in (META.ini "%%a.bat") do <nul curl --create-dirs -#Lkso "Libraries\%%a\%%~b" "!REPO_FULL!/Libraries/%%a/%%~b"
            )
        ) else (
            REM INSTALL LIBRARY
            for %%b in (META.ini "%%a.bat") do <nul curl --create-dirs -#Lkso "Libraries\%%a\%%~b" "!REPO_FULL!/Libraries/%%a/%%~b"
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

:: <CREATE_CONFIG>
:CREATE_CONFIG
>"!SDK_CONFIG!" (
    echo ; SOFTWARE DEVELOPMENT KIT AUTOMATED CONFIG
    echo [UPDATES]
    echo CHECKED_AT=!CHECKED_AT!
)
exit /b
:: </CREATE_CONFIG>

