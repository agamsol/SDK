### 📚 Library - Json Parser

> Parse json DATA files.

### Usage:
- **Parse 1 data key**

> Parsing file: `file.txt`
>
> Parsing a key from json: `name`
```bat
call "JSON_PARSE.bat" --file "file.json" --keys "name"
```

- **Parse more than 1 data key**

> Parsing file: `file.txt`
>
> Parsing keys from json: `name`, `last_name`, `work.name`

```bat
call "JSON_PARSE.bat" --file "file.json" --keys "name last_name work.name"
```

- **Response**

    > This library returns its values using INI format.

#### SDK LIBRARY INFORMATION
> Version: 1.0
>
> Compatibility: Windows 8
>
> OFFICIAL SDK APP CREATED BY THE SDK AUTHOR