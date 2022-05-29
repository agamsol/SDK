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
    for %%b in (STRING TO-LOWER TO-UPPER) do (
        if /i "!Arg[%%a]!"=="--%%b" (
            set /a "NextArg=%%a+1"
            for /f "delims=" %%c in ("!NextArg!") do (
                if /i "%%b"=="to-lower" set CLI_MODE=lower
                if /i "%%b"=="to-upper" set CLI_MODE=upper
                if /i "%%b"=="string" (
                    if not defined Arg[%%c] (
                        echo ERROR=String not defined.
                        exit /b 1
                    )
                    set "STRING=!Arg[%%c]!"
                )
            )
        )
    )
)
:: </SDK_SYNC>

if not defined STRING (
    echo ERROR=String not defined.
    exit /b 1
)

if "!CLI_MODE!"=="lower" (
    for %%a in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do call set STRING=%%STRING:%%~a%%
    echo !STRING!
    exit /b 0
)

if "!CLI_MODE!"=="upper" (
    for %%a in ("z=Z" "y=Y" "x=X" "w=W" "v=V" "u=U" "t=T" "s=S" "r=R" "q=Q" "p=P" "o=O" "n=N" "m=M" "l=L" "k=K" "j=J" "i=I" "h=H" "g=G" "f=F" "e=E" "d=D" "c=C" "b=B" "a=A") do call set STRING=%%STRING:%%~a%%
    echo !STRING!
    exit /b 0
)

echo ERROR=Mode not defined, consider using '--to-lower' or '--to-upper'.
exit /b 1
