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

hint_helper.sh [OPTIONAL] -a|b|c|d|e 'CHARACTER_AT_POSITION_1|2|3|4|5' -f 'LOCAL_WORKBOOK_FILEPATH' -i 'LETTERS_TO_INCLUDE' -x 'LETTERS_TO_EXCLUDE

# e.g.
# date && ./hint_helper.sh -f ~/$WORKSPACE/wordle_enhanced_workbook.tmp" -x '' -i '' -a '' -b '' -c '' -d '' -e '' -m '' -n '' -o '' -p '' -q ''
```

* [Example usage](EXAMPLE.md).
