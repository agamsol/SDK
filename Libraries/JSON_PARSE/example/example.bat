@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

REM This library allows you to parse json files using their keys which you can specify, multi key support.

REM NOTE: I use ""..\JSON_PARSE.bat" because we are currently in the \example folder

REM This time we will be parsing example.json
REM The keys we will parse this time are:
REM - about.name
REM - about.last_name
REM - age
REM
REM The command would be:
REM     call "..\JSON_PARSE.bat" --file "example.json" --keys "about.name about.last_name age"

REM Store the results in variables:
for /f "delims=" %%a in ('call "..\JSON_PARSE.bat" --file "example.json" --keys "about.name about.last_name age"') do set %%a

echo %about.name%
echo %about.last_name%
echo %age%

exit /b !errorlevel!