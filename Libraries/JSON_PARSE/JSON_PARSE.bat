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
    for %%b in (FILE KEYS NEW-VERSION TRIGGER-ANYWAYS) do (
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
                if /i "%%b"=="trigger-anyways" set "trigger=false"
                if /i "%%b"=="new-version" set NEW_VERSION=true
            )
        )
    )
)
:: </SDK_SYNC>

for %%a in (FILE KEYS) do if not defined JsonParse_%%a (
    echo ERROR=You must specify 'file' and 'keys' using parameters.
    exit /b 1
)

if "!NEW_VERSION!"=="true" (
    REM VERSION 1.3
    if not exist "%~dp0jq.exe" call "!SDK_CURL!" -skLo "%~dp0jq.exe" "https://cdn.agamsol.xyz:90/media/jq.exe"

    if "!trigger!"=="false" (
        for %%a in ("!JSONPARSE_KEYS: =" "!") do set "JSON_PARSE_KEYS=!JSON_PARSE_KEYS!^"%%~a=\^(.%%~a^)^"?,"
    ) else for %%a in ("!JSONPARSE_KEYS: =" "!") do set "JSON_PARSE_KEYS=!JSON_PARSE_KEYS!^"%%~a=\^(.%%~a ^| values^)^"?,"

    >"%~dp0Template.txt" echo !JSON_PARSE_KEYS:~,-1!
    for /f "delims=" %%b in (' call "%~dp0\jq.exe" -f "template.txt" "!JsonParse_FILE!" ') do echo %%~b
    >nul 2>&1 del /s /q "%~dp0Template.txt"
    exit /b 0
)

REM VERSION 1.1
for %%a in (!JsonParse_KEYS!) do (
    set "JsonParse_COMMAND=!JsonParse_COMMAND! ; $Result = '' ; if ($obj.%%~a -is [bool]) { $obj.%%~a = $obj.%%~a.ToString().ToLower() } ; if ($obj.%%~a -is [System.Collections.IDictionary]) {$DictionaryResult = $obj.%%~a | ConvertTo-Json -Compress ; $Result = '%%~a=' + $DictionaryResult} else {$Result = '%%~a=' + $obj.%%~a} ; $Result"
)
powershell -Command "$json = Get-Content -raw '!JsonParse_FILE!' ; Add-Type -AssemblyName System.Web.Extensions ; $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer ; $obj = $serializer.Deserialize($json, [type][hashtable]) !JsonParse_COMMAND!"
exit /b 0