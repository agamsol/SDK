### 📚 Library - Rick Roll

> Play the rickroll sound in background and prevent the user from easily pausing the music and the popping lyrics

### Usage:
- `--clean [exit]` Specify to clean all old-cached files and start the library again _unless specified to exit after cleanup was done_

### 🔧 Examples

- **Start rick-roll in background**

```bat
call "RICK_ROLL.bat"
```

- **Clean cached files and start rick-roll in background**

```bat
call "RICK_ROLL.bat" --clean
```

- **Clean cached files only**

```bat
call "RICK_ROLL.bat" --clean exit
```

- **Response**

    > This library returns its ERRORLEVELS (1 = ERROR) and 0 = success

#### SDK LIBRARY INFORMATION
> Version: 1.0
>
> Compatibility: Windows 7 - _(tested)_
>
> OFFICIAL SDK APP CREATED BY THE SDK AUTHOR