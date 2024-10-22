# Wordle Bot 🎭

* To activate **this** Wordle Bot:
```sh
curl -o hint_helper.sh "https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/scripts/hint_helper.sh"

chmod +x hint_helper.sh
hint_helper.sh --help

hint_helper.sh [OPTIONAL] -a|b|c|d|e 'CHARACTER_AT_POSITION_1|2|3|4|5'
                          -i 'LETTERS_TO_INCLUDE'
                          -f 'LOCAL_WORKBOOK_FILEPATH_IF_ANY'
                          -m|n|o|p|q 'CHARACTERS_NOT_AT_POSITION_1|2|3|4|5'
                          -x 'LETTERS_TO_EXCLUDE'
```

* [Example Usage](documentation/EXAMPLE.md).
   - Also see this [Hint Guide](documentation/EXAMPLE_ADDENDUM.md).
* [Historical Data](documentation/WORKBOOK_TRACKER.md).
