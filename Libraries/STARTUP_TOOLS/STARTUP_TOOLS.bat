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
    for %%b in (ADD IF-EXIST DELETE NAME COMMAND VBS) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="ADD" set CLI_MODE=add
                if /i "%%b"=="delete" set CLI_MODE=delete
                if /i "%%b"=="if-exist" set CLI_MODE=if-exist
                if /i "%%b"=="vbs" set VBS=true
                if /i "%%b"=="name" (
                    if not defined Arg[%%c] (
                        echo ERROR=Name not defined.
                        exit /b 1
                    )
                    set "TASK_NAME=!Arg[%%c]!"
                )
                if /i "%%b"=="command" (
                    if not defined Arg[%%c] (
                        echo ERROR=Command not defined.
                        exit /b 1
                    )
                    set "TASK_COMMAND=!Arg[%%c]!"
                )
            )
        )
    )
)
:: </SDK_SYNC>

if not defined TASK_NAME (
    echo ERROR=You did not specify a task name.
    exit /b 1
)

set "REGISTRY=HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

if "!CLI_MODE!"=="add" (
    if not defined TASK_COMMAND (
        echo ERROR=You did not specify the task start command or file.
        exit /b
    )

    if "!VBS!"=="true" set "TASK_COMMAND=cmd /c cscript //nologo """!TASK_COMMAND!""""

    reg ADD "!REGISTRY!" /v "!TASK_NAME!" /d "!TASK_COMMAND!" /f>nul 2>&1 || (
        echo ERROR=Unknown, assuming that the command syntax is invalid.
    )
    exit /b 0
)

if "!CLI_MODE!"=="if-exist" (
    reg QUERY "!REGISTRY!" /v "!TASK_NAME!">nul 2>&1 || (
        echo ERROR=The entry specified doesn't exist.
        exit /b 1
    )
    exit /b 0
)

if "!CLI_MODE!"=="delete" (
    reg DELETE "!REGISTRY!" /v "!TASK_NAME!" /f>nul 2>&1 || (
        echo ERROR=The entry specified doesn't exist.
        exit /b 1
    )
    exit /b 0
)

echo ERROR=You did not specify the action to perform.
exit /b 1