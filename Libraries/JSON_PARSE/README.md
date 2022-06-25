### 📚 Library - Json Parser

> Parse keys from JSON DATA files - API Tools

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
> Version: 1.1
>
> Compatibility: Windows 8.1 and above (_tested_)
>
> OFFICIAL SDK APP CREATED BY THE SDK AUTHOR
>
> 