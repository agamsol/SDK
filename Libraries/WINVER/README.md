### 📚 Library - Windows Version

> Retrive windows _version_, _edition_ and _system bits_

### Usage:
- `--get-edition` Output also edition of windows
- `--get-bits` Output also system-bits

### 🔧 Examples

- **Simple Use**

```bat
call "WINDOWS-VERSION.bat"
```

    Output: OS_VERSION=Windows 10

- **Get All information**

```bat
call "WINDOWS-VERSION.bat" --get-bits --get-edition
```

     Output:
     OS_VERSION=Windows 10
     OS_EDITION=Pro
     OS_BITS=64

- **Response**

    > This library shouldn't return any errors. expected version output (strings)
    > - `Windows 2000`
    > - `Windows XP`
    > - `Windows Vista`
    > - `Windows 7`
    > - `Windows 8`
    > - `Windows 8.1`
    > - `Windows 10`
    > - `Windows 11`

    Expected editions:
    > I have added this just because I was able, its not going to be stable and you shouldn't be using this as a requirement / dependency. (Meaning there's no list or chart I know about)

    Expected System BITS
    > - `64`
    > - `86` (AKA 32-Bits)

#### SDK LIBRARY INFORMATION
> Version: 1.0
>
> Compatibility: Windows 7 - _(tested)_
>
> OFFICIAL SDK APP CREATED BY THE SDK AUTHOR