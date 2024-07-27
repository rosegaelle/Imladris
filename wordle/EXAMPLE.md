# Wordle Hint: Sample Usage

## Prep
```sh
FILEPATH_SCRIPT="~/$WORKSPACE/hint_helper.sh"
```

* This is an optional step, if you intend to use the `-f` flag.
```sh
FILEPATH_WORKBOOK="~/$WORKSPACE/$FILEPATH_WORDLE_ENHANCED_WORKBOOK"
wc -l $dico
```

<b><u>Important Notes</u>:</b><br>
* The full dictionary has **13,112** possible results.
* The most recent enhanced dictionary reduces this to **11,982** possibilities.



## Main Command
* Executed in each step below:
```sh
date && $FILEPATH_SCRIPT -f $FILEPATH_WORKBOOK -x "$GUESS_X" -i "$GUESS_I" -a "$GUESS_A" -b "$GUESS_B" -c "$GUESS_C" -d "$GUESS_D" -e "$GUESS_E" -m "$GUESS_M" -n "$GUESS_N" -o "$GUESS_O" -p "$GUESS_P" -q "$GUESS_Q"
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
* Number of possible solutions: **11,982**.
* Letters by occurence count: `c2Vhb3JpbHRudWR5cG1jaGJna2Z3dnpqeHEK`.
* Anagram candidates, based on `c2Vhb3IK`: `YWVyb3MK` || `YXJvc2UK` || `c29hcmUK`.
  -  **1,232** ending in `RQo=` vs.  **3,363** ending in `Uwo=` in the enhanced dictionary.
* Statistically, the best first guess is `YWVyb3MK`.



## Guess \#1
```sh
YWVyb3MK
```

⬛🟨⬛⬛⬛<br><br>

```sh
GUESS_X='QVJPUwo='
GUESS_I='RQo='
GUESS_N='RQo='
```

<b><u>Results</u>:</b><br>
* Number of possible solutions: **508**.
* Letters by occurence count: `aWRsdW50eWdtY2hia3Bmd3Z4empxCg==`.
* Anagram candidate(s), based on `aWRsdW4K`: `dW5saWQK`.
* Unsurprisingly, the second guess will be `dW5saWQK`.



## Guess \#2
```sh
dW5saWQK
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
  - `ZmlxdWUK` || `Z2lndWUK` || `aW1idWUK` || `anVpY2UK`.
    - Verbs are rare.
    - Solutions tend to follow the [KISS Principle](https://www.techopedia.com/definition/20262/keep-it-simple-stupid-principle-kiss-principle).
* Consequently, the best third guess is `anVpY2UK`.
  - Should this not work, the next guess will be decided based on the system feedback.
  - Our final possible score is therefore _3 out of 6_ at best, or _4 out of 6_ in the worst case scenario. **Not bad!** 🙃


## Guess \#3
```sh
anVpY2UK
```

⬛🟨⬛⬛⬛<br>
🟨⬛⬛🟨⬛<br>
🟩🟩🟩🟩🟩<br><br>


😎