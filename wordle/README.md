# Wordle
* Workbook last updated on: **2024/07/23**.

* Resources:
```sh
# encode
echo "$keyword" | tr '[:upper:]' '[:lower:]' | base64

# decode
echo "$keyword" | -d base64
```

* To execute:
```sh
# execute
curl -o hint_helper.sh "https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/hint_helper.sh"

chmod +x hint_helper.sh
hint_helper.sh --help

hint_helper.sh [OPTIONAL] -a|b|c|d|e 'CHARACTER_AT_POSITION_1|2|3|4|5' -i 'LETTERS_TO_INCLUDE'
                          -f 'LOCAL_WORKBOOK_FILEPATH'
                          -m|n|o|p|q 'CHARACTERS_NOT_AT_POSITION_1|2|3|4|5' -x 'LETTERS_TO_EXCLUDE'
```

* [Example usage](EXAMPLE.md).
