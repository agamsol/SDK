## 📚 Batch Software Development Kit - 1.0.0.3
> A script to sync all libraries that your scripts use often, preventing code duplications and syncing all libraries with variables that bring windows 7 compatible with most libraries and the SDK itself

## Table of contents
* [How does this work?](https://github.com/agamsol/SDK/tree/1.0.0.3#how-does-this-work)
* [Libraries](https://github.com/agamsol/SDK/tree/1.0.0.3#libraries)
    * [JSON_PARSE](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/JSON_PARSE)
    * [RENTRY](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/RENTRY)
    * [DISCORD_WEBHOOK_CHECKER](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/DISCORD_WEBHOOK_CHECKER)
    * [HEXADECIMAL](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/HEXADECIMAL)
    * [NETWORK](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/NETWORK)
    * [CHANGE_CASE](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/CHANGE_CASE)
    * [STARTUP_TOOLS](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/STARTUP_TOOLS)
    * [STICKBUG](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/STICKBUG)
    * [RICK_ROLL](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/RICK_ROLL)
    * [WINVER](https://github.com/agamsol/SDK/tree/1.0.0.3/Libraries/WINVER)
* [Change Log](https://github.com/agamsol/SDK/tree/1.0.0.3#change-log)
* [Installation](https://github.com/agamsol/SDK/tree/1.0.0.3#installation)
    * [Compatibility](https://github.com/agamsol/SDK/tree/1.0.0.3#compatibility)
    * [Installing the SDK](https://github.com/agamsol/SDK/tree/1.0.0.3#installing-the-sdk)
        * [STEP 1](https://github.com/agamsol/SDK/tree/1.0.0.3#step-1)
        * [STEP 2](https://github.com/agamsol/SDK/tree/1.0.0.3#step-2)
        * [STEP 3](https://github.com/agamsol/SDK/tree/1.0.0.3#step-3)
    * [Installing Specific libraries](https://github.com/agamsol/SDK/tree/1.0.0.3#installing-specific-libraries)
* [Using a library](https://github.com/agamsol/SDK/tree/1.0.0.3#using-a-library)
* [Support 💁‍♂️](https://github.com/agamsol/SDK/tree/1.0.0.3#support-%EF%B8%8F)
* [Buy me a coffee ☕](https://github.com/agamsol/SDK/tree/1.0.0.3#buy-me-a-coffee-)

## How does this work
> SDK script which is being called at the start of your batch file is responsible for keeping the SDK and all other libraries up-to-date and returns all paths as INI format so that you can set and use them in your own script.

## Libraries
> Each library is responsible for doing a specific task related to a different topic (Eg. Checking wether a discord webhook URL works or not)

## Change Log
> 1.0.0.3
- [Replace SDK Installer command] Fixed a major bug with updater in version 1.0.0.2
- Fixed a bug with internet connection checker.

> 1.0.0.2
- Majorly improved waiting times for SDK to load.

    This feature includes the following subroutines:
    - Install-Library (Allows to install the library by its name)
    - Load-ConfigInformation (Parses information through INI formatted-files)
- Fixed names of libraries that were incorrect in the documentation

- NOTE: The following libraries has been renamed:
    - `GET_NETWORK` is now known as `NETWORK`
    - `WINDOWS_VER` is now known as `WINVER`

- When the script imports the SDK statistics of fixes and updates will show up.

## Installation
> A part of the SDK installation script is responsible for installing [CURL](https://curl.se/) this dependecy allows to download files on older versions of windows, the other parts are responsible to validate the file installed works and starting the SDK installation

#### Compatibility
> The Software Development Kit importer was built to also bring curl into older versions of windows, for example windows 7 and8.

###### The working windows versions are _(Tested)_
- Windows 11
- Windows 10
- Windows 8
- Windows 7
    > All builds work for 32-Bit and 64-Bit systems.

> Each library may also have custom dependecies which require higher-end compatibilites, each library also lists its compatibility OS - at the bottom of each README file.

### Installing the SDK
> You'd need to have a project file, the process of installation is done through your main working script

### STEP 1
- Make sure you have delayed-expansion in your script. (You probably want to put it at line 2, right after `@echo off`)
```bat
setlocal enabledelayedexpansion
```
- We'd want to paste the settings for the SDK at the TOP of your script, assuming you have a place to paste your main script settings you may also add this one as a setting.

```bat
if defined ProgramFiles(x86) (set SYSTEM_BITS=64) else set SYSTEM_BITS=86
set "SDK_LOCATION=%appdata%\SDK"
```

### STEP 2
- At the very bottom of your script you'd want to paste the code snippet below, this part is responsible to install CURL and the SDK itself. - Make sure that your code never executes this line without calling it as a label

```bat
:: <IMPORT SDK>
:IMPORT_SDK
set SDK_CURL=
if not exist "!SDK_LOCATION!" md "!SDK_LOCATION!"
for /f "delims=" %%a in ('2^>nul where curl.exe ^|^| echo 1') do (
    if %%a neq 1 (
        call :VALIDATE_CURL_INSTALLATION "%%a" && set "SDK_CURL=%%a"
    ) else (
        if exist "!SDK_LOCATION!\curl.exe" call :VALIDATE_CURL_INSTALLATION "!SDK_LOCATION!\curl.exe" && set "SDK_CURL=!SDK_LOCATION!\curl.exe"
    )
)
if not defined SDK_CURL call :IMPORT_CURL || exit /b 1

set "SDK_CORE=%SDK_LOCATION%\SDK.bat"

if not exist "!SDK_CORE!" call "!SDK_CURL!" -L#sko "!SDK_CORE!" "https://raw.githubusercontent.com/agamsol/SDK/latest/SDK.bat"
exit /b 0
:: </IMPORT SDK>

:: <IMPORT CURL>
:IMPORT_CURL
for /f "delims=" %%a in ("https://github.com/agamsol/SDK/raw/latest/curl/x!SYSTEM_BITS!/curl.exe") do (
    set "SDK_CURL=!SDK_LOCATION!\curl.exe"
    >nul chcp 437
    >nul 2>&1 powershell /? && (
        >nul 2>&1 powershell $progressPreference = 'silentlyContinue'; Invoke-WebRequest -Uri "'%%~a'" -OutFile "'!SDK_CURL!'"
        >nul chcp 65001
        call :VALIDATE_CURL_INSTALLATION "!SDK_CURL!" && exit /b 0
    )
    >nul chcp 65001
    >nul bitsadmin /transfer someDownload /download /priority high "%%~a" "!SDK_CURL!"
    call :VALIDATE_CURL_INSTALLATION "!SDK_CURL!" && exit /b 0
    >nul certutil -urlcache -split -f "%%~a" "!SDK_CURL!"
    call :VALIDATE_CURL_INSTALLATION "!SDK_CURL!" && exit /b 0
)
exit /b 1

:VALIDATE_CURL_INSTALLATION "[CURL]"
if not exist "%~1" exit /b 1
call "%~1" --version | findstr /brc:"curl [0-9]*\.[0-9]*\.[0-9]*">nul || (
    >nul 2>&1 del /s /q "%~1"
    exit /b 1
)
exit /b 0
:: </IMPORT CURL>
```

### STEP 3
> This part will make sure that your SDK is executed when your main script starts, you'd need to choose where to place it, before making your decision, I'd recommend you to import it at the very start of your script to also collect variables like `!SDK_CURL!`, this will allow your script to use CURL in lower systems than windows 10, as mentioned in the [Compatibility](https://github.com/agamsol/SDK/tree/latest#compatibility) part.

```bat
:TRY_IMPORT_SDK
call :IMPORT_SDK && (
    echo INFO: Installed SDK.
    REM UPDATER FIX FOR 1.0.0.2
    for /f "delims=" %%a in ('type "!SDK_CORE!" ^| findstr /c:"set SDK_VERSION="') do %%a
    if "!SDK_VERSION!"=="1.0.0.2" (
        >nul 2>&1 del /q "!SDK_CORE!"
        goto :TRY_IMPORT_SDK
    )
    echo INFO: Starting SDK.
    for /f "delims=" %%a in ('call "!SDK_CORE!" --curl "!SDK_CURL!" --install-location "!SDK_LOCATION!" --libraries "!SDK_Libraries!"') do set %%a
)
```

## Installing Specific libraries
> This part will teach you how you can install specific library(ies). interaction with the SDK will be done by changing the `FOR` command at [STEP 3](https://github.com/agamsol/SDK/tree/latest#step-3)

- You can grab the list of libraries that the SDK has by [clicking here](https://github.com/agamsol/SDK/blob/latest/Libraries/Libraries.ini)

* Each ``[Category]`` is a different library and inside that category you'd want to access the KEY named `LIBRARY_NAME`

* Lets say I've chosen 1 specific library to install, the library `HEXADECIMAL`

    What I'd want to do to install only it is make an array and inside i will put the name of the library

    Using the flag `--libraries` I will be able to specify the specific libraries to install

    So this way I will use the following command to install only the library `HEXADECIMAL`
    ```bat
    for /f "delims=" %%a in ('call "!SDK_CORE!" --curl "!SDK_CURL!" --install-location "!SDK_LOCATION!" --libraries "HEXADECIMAL"') do set %%a
    ```

    ### But what if I want to install more than 1 library?

    Thats gonna be easy, in your command you'd want to replace `--libraries "HEXADECIMAL"`

    Lets say I want 2 libraries

    - HEXADECIMAL
    - CHANGE_CASE

    My edited line would be ``--libraries "HEXADECIMAL CHANGE_CASE"``

## Using a library
> To use a library you'd want to read its docs file and understand how it works, some libraries are easy to use and some are complex
> You can visit the [Table of contents](https://github.com/agamsol/SDK/tree/latest#table-of-contents) for all possible libraries and links to them.

- I want to use the library `HEXADECIMAL` for this example

- IF we want to make sure that the library exists we can use the following command
```bat
if not defined SDK[HEXADECIMAL] (
    echo The library does not exists
) else (
    echo this library exists
)
```

- Calling the library to perform the action
```bat
call "!SDK[HEXADECIMAL]!" --plain-to-hex "Hello World"
```
> At this part the output you will get is not set to a variable, to set it you need to put the command above in a for loop and set the output to a variable.

```bat
for /f %%a in ('call "!SDK[HEXADECIMAL]!" --plain-to-hex "Hello World"') do set RESPONSE=%%a
```

- Using the command above will set our output into the variable `RESPONSE` so we can use `!RESPONSE!` to print it if we would like to.


## Support 💁‍♂️
> you can get support for the SDK in my [Discord Server](https://discord.gg/uHvmqReMYa).
Feel free to join and ping me for help, just let me know we are talking about the SDK because I have many more project
OR, you can send a friend request to me
- Testers#1636 (More responses)
- Agam#0001 (May not accept friend requests)

> You also can join the [r/Batch](https://discord.gg/gPMcxXZjkb) discord server and you can find and ping me there, my name in there is `Agam#0001`

## Buy me a coffee ☕
> Feel free to donate me for my hard work, its all just for you ❤️
> Just be sure that you want to donate before you do so, the last thing I want to mess with is refunds

- Click for [PayPal](https://www.paypal.me/agamsolomon0011)
- ETH: `0xf7097d9069d954eD5Be090709A5776F61bb85459`