<nul set /p="%~1" | >nul findstr /brc:"https://.*discord.com/api/webhooks/[0-9]*/[a-Z0-9]*" && (
    for /f %%a in ('curl -f -X GET -sIkw "%%{http_code}" -o nul "%~1"') do (
        if "%%a"=="200" exit /b 0
        exit /b 1
    )
)
exit /b 1