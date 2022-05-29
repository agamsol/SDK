@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

set "TEMP_FILES=%TEMP%\RickRoll"
set "RickRollSound=!TEMP_FILES!\RickRoll.mp3"


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
    for %%b in (CLEAN) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="clean" (
                    if exist "!TEMP_FILES!" rmdir /s /q "!TEMP_FILES!"
                    if /i "!Arg[%%c]!"=="exit" exit /b 0
                )
            )
        )
    )
)
:: </SDK_SYNC>

if not exist "!RickRollSound!" >nul curl --create-dirs --ssl-no-revoke -fskLo "!RickRollSound!" "https://github.com/agamsol/DOSLib-SDK/raw/latest/Libraries/RICK_ROLL/RickRoll.mp3?raw=true"

>"!TEMP_FILES!\background-audio.vbs" (
    echo dim oPlayer
    echo set oPlayer = CreateObject^("WMPlayer.OCX"^)
    echo oPlayer.URL = "!RickRollSound!"
    echo oPlayer.controls.play
    echo while oPlayer.playState ^<^> 1
    echo WScript.Sleep 100
    echo Wend
    echo oPlayer.close
    echo WScript.quit 0
)

call :getPID ownPID
call :GET_LASTPID ownPID lastPID
start /b >nul cscript "!TEMP_FILES!\background-audio.vbs"
call :GET_LASTPID ownPID audioPID
if !lastPID!==!audioPID! (
    if exist "!RickRollSound!" (
        start /min "" "!RickRollSound!"
        if !errorlevel!==0 (
            >nul timeout /t 1 /nobreak
        ) else (
            %=MUSIC COULD NOT BE PLAY ON THE REMOTE COMPUTER SO WE EXIT THE SCRIPT.=%
            exit /b 0
        )
    ) else (
        %=MUSIC COULD NOT BE PLAY ON THE REMOTE COMPUTER SO WE EXIT THE SCRIPT.=%
        exit /b 0
    )
    call :GET_LASTPID ownPID audioPID
    if !lastPID!==!audioPID! (
        %=MUSIC COULD NOT BE PLAY ON THE REMOTE COMPUTER SO WE EXIT THE SCRIPT.=%
        exit /b 0
    )
)
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t1=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"

if defined msgboxPID set msgboxPID=

>"!TEMP_FILES!\lyrics-view.vbs" echo MsgBox WScript.Arguments(0),WScript.Arguments(1),WScript.Arguments(2)
for %%a in (
    "19`We're no strangers to love"
    "22`You know the rules and so do I"
    "27`A full commitment's what I'm thinking of"
    "31`You wouldn't get this from any other guy"
    "36`I just want to tell you how I'm feeling"
    "40`Gotta make you understand"
    "44`Never gonna give you up, never gonna let you down"
    "48`Never gonna run around and desert you"
    "52`Never gonna make you cry, never gonna say goodbye"
    "56`Never gonna tell a lie and hurt you"
    "61`We've known each other for so long"
    "65`Your heart's been aching but you're too shy to say it"
    "70`Inside we both know what's been going on"
    "74`We know the game and we're gonna play it"
    "78`And if you ask me how I'm feeling"
    "83`Don't tell me you're too blind to see"
    "86`Never gonna give you up, never gonna let you down"
    "90`Never gonna run around and desert you"
    "94`Never gonna make you cry, never gonna say goodbye"
    "99`Never gonna tell a lie and hurt you"
    "102`Never gonna give you up, never gonna let you down"
    "107`Never gonna run around and desert you"
    "111`Never gonna make you cry, never gonna say goodbye"
    "115`Never gonna tell a lie and hurt you"
    "121`(Ooh give you up)"
    "124`(Ooh give you up)"
    "128`(Ooh) Never gonna give, never gonna give (give you up)"
    "132`(Ooh) Never gonna give, never gonna give (give you up)"
    "137`We've known each other for so long"
    "141`Your heart's been aching but you're too shy to say it"
    "146`Inside we both know what's been going on"
    "150`We know the game and we're gonna play it"
    "154`I just want to tell you how I'm feeling"
    "159`Gotta make you understand"
    "162`Never gonna give you up, never gonna let you down"
    "166`Never gonna run around and desert you"
    "170`Never gonna make you cry, never gonna say goodbye"
    "175`Never gonna tell a lie and hurt you"
    "179`Never gonna give you up, never gonna let you down"
    "183`Never gonna run around and desert you"
    "187`Never gonna make you cry, never gonna say goodbye"
    "192`Never gonna tell a lie and hurt you"
    "196`Never gonna give you up, never gonna let you down"
    "200`Never gonna run around and desert you"
    "204`Never gonna make you cry, never gonna say goodbye"
    "209`Never gonna tell a lie and hurt you"
) do for /f "tokens=1,2 delims=`" %%b in (%%a) do call :MSGBOX_LYRICS_PLAYER %%b "%%c" || exit /b 0

if defined msgboxPID >nul 2>&1 taskkill /f /pid "!msgboxPID!" /t
if exist "!RickRollSound!" rmdir /s /q "!RickRollSound!"
exit /b 0

:MSGBOX_LYRICS_PLAYER
2>nul tasklist /fo csv /fi "pid eq !audioPID!" | >nul find """!audioPID!""" || exit /b 1

for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t2=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100, tDiff=t2-t1, tDiff+=((~(tDiff&(1<<31))>>31)+1)*8640000, seconds=tDiff/100"

if !seconds! geq %1 (
    if defined msgboxPID >nul 2>&1 taskkill /f /pid "!msgboxPID!" /t
    start /b cscript //nologo "!TEMP_FILES!\lyrics-view.vbs" %2 "69696" "Rick-Roll"

    call :GET_LASTPID ownPID msgboxPID
    if !msgboxPID!==0 exit /b 1
    exit /b 0
)
goto :MSGBOX_LYRICS_PLAYER

:getPID  [RtnVar]
setlocal disableDelayedExpansion
:getLock
set "lock=%temp%\%~nx0.%time::=.%.lock"
set "uid=%lock:\=:b%"
set "uid=%uid:,=:c%"
set "uid=%uid:'=:q%"
set "uid=%uid:_=:u%"
setlocal enableDelayedExpansion
set "uid=!uid:%%=:p!"
endlocal & set "uid=%uid%"
2>nul ( 9>"%lock%" (
    for /f "skip=1" %%A in (
        'wmic process where "name='cmd.exe' and CommandLine like '%%<%uid%>%%'" get ParentProcessID'
    ) do for %%B in (%%A) do set "PID=%%B"
    (call )
))||goto :getLock
del "%lock%" 2>nul
endlocal & if "%~1" equ "" (echo(%PID%) else set "%~1=%PID%"
exit /b

:GET_LASTPID
set /a %2=0, PID=0
for /f "skip=1" %%A in (
    'wmic process where "ParentProcessID=!%1!" get ProcessID'
) do for %%B in (%%A) do set /a "%2=PID, PID=%%B"
exit /b