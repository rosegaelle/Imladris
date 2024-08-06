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

<b><u>Important Notes</u>:</b><br>
* The full dictionary has **13,112** possible results.
* The most recent enhanced dictionary would reduces this to fewer possibilities.



## Main Command
* Executed in each step below:
```sh
date && $FILEPATH_SCRIPT -x "$GUESS_X" -i "$GUESS_I" -a "$GUESS_A" -b "$GUESS_B" -c "$GUESS_C" -d "$GUESS_D" -e "$GUESS_E" -m "$GUESS_M" -n "$GUESS_N" -o "$GUESS_O" -p "$GUESS_P" -q "$GUESS_Q" -f $FILEPATH_WORKBOOK
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
* Letters by occurence count: `RVNBT1JJTFROVURZQ1BNSEdCS0ZXVlpYSlEK`.
* Anagram candidates, based on `U0VBT1IK`: `QUVST1MK` || `QVJPU0UK` || `U09BUkUK`.
  -  **1,160** ending in `RQo=` vs.  **3,370** ending in `Uwo=` in the full dictionary.
* Statistically, the best first guess is therefore `YWVyb3MK`.



## Guess \#1
```sh
QUVST1MK
```

⬛🟨⬛⬛⬛<br><br>

```sh
GUESS_X='QVJPUwo='
GUESS_I='RQo='
GUESS_N='RQo='
```

<b><u>Results</u>:</b><br>
* Number of possible solutions: **508**.
* Letters by occurence count: `SURMVU5UWUdNQ0hCS1BGV1ZYWkpRCg==`.
* Anagram candidate(s), based on `SURMVU4K`: `VU5MSUQK`.
* Unsurprisingly, the second guess will be `VU5MSUQK`.



## Guess \#2
```sh
VU5MSUQK
```

⬛🟨⬛⬛⬛<br>
🟨⬛⬛🟨⬛<br><br>

```sh
GUESS_X='QVJPU05MRAo='
GUESS_I='RVVJCg=='
GUESS_M='VQo='
GUESS_P='SQo='
```

<b><u>Results</u>:</b><br>
* Number of possible solutions: **4**.
  - `RklRVUUK` || `R0lHVUUK` || `SU1CVUUK` || `SlVJQ0UK`.
    - Verbs are rare.
    - Solutions tend to follow the [KISS Principle](https://www.techopedia.com/definition/20262/keep-it-simple-stupid-principle-kiss-principle).
* Consequently, the best third guess is `SlVJQ0UK`.
  - Should this not work, the next guess will be decided based on the system feedback.
  - Our final possible score is therefore _3 out of 6_ at best, or _4 out of 6_ in the worst case scenario. **Not bad!** 🙃


## Guess \#3
```sh
SlVJQ0UK
```

⬛🟨⬛⬛⬛<br>
🟨⬛⬛🟨⬛<br>
🟩🟩🟩🟩🟩<br><br>



😎
