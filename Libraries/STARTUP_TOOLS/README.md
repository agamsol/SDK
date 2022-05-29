### 📚 Library - Startup Tools

> _Add_, _Remove_ and _Check_ Startup tasks (Start script at user logon)

### Usage:
- `--add` Add a query to startup
- `--command <Command\File>` Only needed for adding new query, specify the file \ command to execute at startup
- `--vbs` Only needed for adding new query, if you are willing to execute a VBS file use this flag and specify your VBS file under the `--command` flag
- `--delete` Delete existing query from startup
- `--if-exist` Check if a query exists using its response errorlevel
- `--name <Query_Name>` Specify the name of the query


### 🔧 Examples

- **Add new query to startup**

```bat
call "STARTUP_TOOLS.bat" --name "Audo" --add --command "%temp%\startup.bat"
```

    Errorlevel (success): 0

- **Add new query to startup (VBS)**

```bat
call "STARTUP_TOOLS.bat" --name "Audo" --add --command "%temp%\startup.vbs" --vbs
```

    Errorlevel (success): 0

- **Delete a query from startup**

```bat
call "STARTUP_TOOLS.bat" --name "Audo" --delete
```

    Errorlevel (success): 0
    Errorlevel (query not found): 1

- **Check if query exists**

```bat
call STARTUP_TOOLS.bat --name "Audo" --delete || echo does not exist
```

    Errorlevel (success): 0
    Errorlevel (query not found): 1

- **Response**

    > This library returns its ERRORS as INI format and at success an empty response with errorlevel 0

#### SDK LIBRARY INFORMATION
> Version: 1.0
>
> Compatibility: Windows 7 - _(untested)_
>
> OFFICIAL SDK APP CREATED BY THE SDK AUTHOR