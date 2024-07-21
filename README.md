![GitHub followers](https://img.shields.io/github/followers/rosegaelle?style=social) &nbsp;
![Twitter Followers](https://img.shields.io/twitter/follow/rosegaelle?style=social)  &nbsp;
![https://linkedin.com/in/rosegaelle](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin&labelColor=blue)

# Imladris
Repository for miscellaneous scripts and fun content used at home, a.k.a. "Rivendell".

## Scripts
### [cleanup_by_file_ext](scripts/cleanup_by_file_ext.sh)
Script to cleanup files provided an extension and directory path.<br/>
If no folder is specified, the current directory will be used as default.<br/><br/>
Sample Usage:<br/>
`cleanup_by_file_ext.sh -d "~/Downloads" -e "TMP"`


## Entertainment
### Puzzles
#### [Puzzle 1](puzzles/puzzle_1.py)
<!-- @ToDo: Add description. --> 

#### [Puzzle 2](puzzles/puzzle_2.py)
Also see [FreeGames](http://www.grantjenks.com/docs/freegames/)
<!-- @ToDo: Add description. --> 



### Illustrations
#### [favourite_memes](illustrations/favourite_memes.md)
#### [favourite_comics](illustrations/favourite_comics.md)

- Why?<br/>
- Because I am a proud Millennial. ;-)<br/>
- Seriously, why???<br/>
- Okay, fine! Does <i>this</i> satisfy your curiosity?! [#XKCD712](https://xkcd.com/512)<br/><br/>
![](https://imgs.xkcd.com/comics/alternate_currency.png)

#### [favourite_comics](illustrations/favourite_comics.md)


### Games
#### Wordle
* Workbook last updated on: **2024/07/21**.
```sh
# encode
'echo "$keyword" | base64'

# decode
'echo "$keyword" | -d base64'
```

* To execute:
```sh
# execute
curl -o get_optimized_dictionary.sh "https://github.com/rosegaelle/Imladris/blob/main/wordle/get_optimized_dictionary.sh"

get_optimized_dictionary.sh --help

get_optimized_dictionary.sh [OPTIONAL] -a|b|c|d|e 'CHARACTER_AT_POSITION_1|2|3|4|5' -f 'LOCAL_WORKBOOK_FILEPATH' -i 'LETTERS_TO_INCLUDE' -x 'LETTERS_TO_EXCLUDE
```
