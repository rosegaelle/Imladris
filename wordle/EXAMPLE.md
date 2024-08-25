# Wordle Hint: Sample Usage

## Prep
```sh
export WORKSPACE_DIR="~/$WORKSPACE"

export FILEPATH_SCRIPT="$WORKSPACE_DIR/hint_helper.sh"
wc -l $FILEPATH_SCRIPT
```

* This is an optional step, if you intend to use the `-f` flag.
```sh
export FILEPATH_WORKBOOK="~/$WORKSPACE/$FILEPATH_WORDLE_ENHANCED_WORKBOOK"
wc -l $FILEPATH_WORKBOOK
```

* This is an optional step, if you intend to use the `-s` flag, which defaults to `false`.
```sh
export SKIP_ANAGRAMMER=false
```

<b><u>Important Notes</u>:</b><br>
* The full dictionary has **13,112** possible results.
* The most recent enhanced dictionary would reduces this to fewer possibilities.



## Main Command
* Executed in each step below:
```sh
date && $FILEPATH_SCRIPT -x "$GUESS_X" -i "$GUESS_I" -a "$GUESS_A" -b "$GUESS_B" -c "$GUESS_C" -d "$GUESS_D" -e "$GUESS_E" -m "$GUESS_M" -n "$GUESS_N" -o "$GUESS_O" -p "$GUESS_P" -q "$GUESS_Q" -f "$FILEPATH_WORKBOOK" -s "$SKIP_ANAGRAMMER"
```


## Guess \#0
```sh
GUESS_X=''
GUESS_I=''
GUESS_A=''
GUESS_B=''
GUESS_C=''
GUESS_D=''
GUESS_E=''
GUESS_M=''
GUESS_N=''
GUESS_O=''
GUESS_P=''
GUESS_Q=''
```

<b><u>Results</u>:</b><br>
* Number of possible solutions: **13,112**, if the full dictionary.
* Letters by occurence count: `U0VBT1JJTFROVURZUE1DSEJHS0ZXVlpKWFEK`.
* Anagram candidates, based on `U0VBT1IK`, : `U09BUkUK` || `QUVST1MK` || `QVJPU0UK`.
* As these are ranked by _occurence score_, the best first guess is therefore: `U09BUkUK`.



## Guess \#1
```sh
U09BUkUK

/usr/local/bin/bash -c "source WORKSPACE_DIR/utils.sh; convert_feedback 'BBBBG'"
```

⬛⬛⬛⬛🟩<br><br>

```sh
GUESS_X='U09BUgo='
GUESS_I='RQo='
GUESS_E='RQo='
```

<b><u>Results</u>:</b><br>
* Number of possible solutions: **149**.
* Letters by occurence count: `RUlMVVROR1lCRE1IQ0ZLUFdWWFFaSgo=`.
* Anagram candidate(s), based on `SUxVVE5HCg==`: `R1VJTFQK` || `TFVOR0kK` || `R0xJTlQK`.
  - In the full dictionary, `VU5USUwK` and `VU5MSVQK` would have been the top candidates; however, these guesses have already been exhausted as `#866` and `#595` respectively.
* Following the same strategy as earlier, the second guess will consequently be `R1VJTFQK`.



## Guess \#2
```sh
R1VJTFQK

/usr/local/bin/bash -c "source WORKSPACE_DIR/utils.sh; convert_feedback 'BGGBB'"
```

⬛⬛⬛⬛🟩<br>
⬛🟩🟩⬛⬛<br><br>

```sh
GUESS_X='U09BUkdMVAo='
GUESS_I='RVVJCg=='
GUESS_B='VQo='
GUESS_C='SQo='
GUESS_E='RQo='
```

<b><u>Results</u>:</b><br>
* Number of possible solutions: **2**.
  - `SlVJQ0UK` || `UVVJTkUK`
    - Verbs are rare.
      - In fact, as a rule of thumb: `noun > adjective > verb > adverb > proper noun`.
    - Solutions tend to follow the [KISS Principle](https://www.techopedia.com/definition/20262/keep-it-simple-stupid-principle-kiss-principle).
* Unsurprisingly, the best third guess is `SlVJQ0UK`.
  - Our final possible score is therefore _3 out of 6_ at best, or _4 out of 6_ in the worst case scenario. **Not bad!** 🙃


## Guess \#3
```sh
SlVJQ0UK

/usr/local/bin/bash -c "source WORKSPACE_DIR/utils.sh; convert_feedback 'GGGGG'"
```

⬛⬛⬛⬛🟩<br>
⬛🟩🟩⬛⬛<br>
🟩🟩🟩🟩🟩<br><br>



😎
