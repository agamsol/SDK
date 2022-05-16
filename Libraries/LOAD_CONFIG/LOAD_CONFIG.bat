if not exist "%~1" (
    echo:
    echo ERROR=The config file specified does not exist.
    exit /b 1
)
for /f "delims=" %%a in ('type "%~1"') do <nul set /p=%%a | findstr /rc:"^[\[#].*">nul || set %%a
exit /b