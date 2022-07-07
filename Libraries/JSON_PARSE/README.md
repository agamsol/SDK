### 📚 Library - Json Parser

> Parse keys from JSON DATA files - API Tools

> As for version 1.2 - [JQ](https://stedolan.github.io/jq/) is integrated into version 1.2
>
> **to use it you'd need to use the `--new-version` parameter.**

### Usage:
- **Parse 1 data key**

> Parsing file: `file.txt`
>
> Parsing a key from json: `name`
```bat
call "JSON_PARSE.bat" --file "file.json" --keys "name" [--new-version]
```

- **Parse more than 1 data key**

> Parsing file: `file.txt`
>
> Parsing keys from json: `name`, `last_name`, `work.name`

```bat
call "JSON_PARSE.bat" --file "file.json" --keys "name last_name work.name" [--new-version]
```

- For more information about keys in version **1.2** read the documentation for [JQ](https://stedolan.github.io/jq/)

    **Basics:**
    - **NOTE: IT IS CASE-SENSETIVE**
    - Normal: `key`
    - Parse array of strings: `key[0]` or `key[1]` or `key[0,1,2]` or even select from-to `key[0:3]`
    - Parse array of objects: `[].key.object_name` or `[].key.object_name.even_depper`

- **Response**

    > This library returns its values using INI format.

#### SDK LIBRARY INFORMATION
> Version: 1.2
>
> Compatibility: Windows 8.1 and above (_tested_)
>
> OFFICIAL SDK APP CREATED BY THE SDK AUTHOR WITH THE HELP OF [JQ](https://stedolan.github.io/jq/)
>
> NEW IN 1.2: Using JQ