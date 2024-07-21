#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# July 2024.                                                #
#############################################################



help() {
    echo "Hello, Wordle!"
    echo
    echo "Syntax: get_optimized_dictionary [-a|b|c|d|e|f|i|x]"
    echo "options:"
    echo "a     First letter of the word."
    echo "b     Character at the second position."
    echo "c     Character at the third position."
    echo "d     Character at the fourth position."
    echo "e     Last letter of the word."
    echo "f     Enhanced workbook location, to bypass the dictionary processing steps."
    echo "i     Letters to include."
    echo "x     Letters to exclude."
    echo
}

### ToDo: Input validation.
while getopts ":a:b:c:d:e:f:i:x:" flag
do
    case "${flag}" in
        a) LETTER_AT_1=${OPTARG};;
        b) LETTER_AT_2=${OPTARG};;
        c) LETTER_AT_3=${OPTARG};;
        d) LETTER_AT_4=${OPTARG};;
        e) LETTER_AT_5=${OPTARG};;
        f) FILEPATH_WORKBOOK=${OPTARG};;
        i) LETTERS_INCLUDED=${OPTARG};;
        x) LETTERS_EXCLUDED=${OPTARG};;
        *) help
        exit 1;;
    esac
done



WORD_LENGTH=5

file_dictionary_optimized=$(mktemp)


validate_file_dependency() {
    filename=${1:-""}

    if [ ! -f $filename ]; then
        echo "File '$filename' does not exist."
        exit 1
    else
        return 0
    fi
}

filter_by_character_index() {
    filename_input=${1:-''}
    filename_output=${2:-''}
    character_index=${3:-0}
    character_value=${4:-''}

    validate_file_dependency $filename_input

    if [ -z "$character_value" ]; then
        cp $filename_input $filename_output
    else
        if (( $character_index < 1 || $character_index > "$WORD_LENGTH" )); then
            echo "Error message goes here."
            exit 1
        fi

        character_value=$(echo "$character_value" | tr '[:upper:]' '[:lower:]')
        awk -v s="$character_value" "index(\$0, s) == $character_index" $filename_input > $filename_output
    fi

    cleanup $filename_input
}

insert_unique() {
    word=${1:-""}
    filename=${2:-""}

    validate_file_dependency $filename

    if ! grep -q "$word" "$filename"; then
            echo "$word" >> $filename
        fi
}

cleanup() {
    filename=${1:-""}
    [ -e $filename ] && rm $filename
}



file_tmp_3=$(mktemp)
if [ ! -z "$FILEPATH_WORKBOOK" ] && [ ! $(validate_file_dependency $FILEPATH_WORKBOOK) ]; then
    cp $FILEPATH_WORKBOOK $file_tmp_3
    cat $file_tmp_3 | wc -l

else

    ### ToDo: Curl from repo if missing locally.
    # 1. Check whether the necessary resources files exist before starting.
    file_dictionary_full='./dictionary_full.txt'
    validate_file_dependency $file_dictionary

    file_previous_solutions='./workbook.txt'
    validate_file_dependency $file_previous_solutions



    # 2. Decode the full dictionary.
    file_tmp_1=$(mktemp)
    while read -r line
    do
        echo "$line" | base64 -d >> $file_tmp_1
    done < $file_dictionary_full



    # 3. Decode the workbook, which was encoded to prevent accidental spoilers.
    file_tmp_2=$(mktemp)
    while read -r line
    do
        echo "$line" | base64 -d >> $file_tmp_2
    done < $file_previous_solutions



    # 4. Remove all previous solutions from the working dictionary.
    cat $file_tmp_2 $file_tmp_1 | sort | uniq -u > $file_tmp_3

    cleanup $file_tmp_1
    cleanup $file_tmp_2
fi



# 5. Process hints, if any.
## Letters to exclude.
file_tmp_4=$(mktemp)
if [ -z "$LETTERS_EXCLUDED" ]; then
    cp $file_tmp_3 $file_tmp_4
else
    for (( i=0; i<${#LETTERS_EXCLUDED}; i++ )); do
        grep -iv "${LETTERS_EXCLUDED:$i:1}" $file_tmp_3 > $file_tmp_4
        cp $file_tmp_4 $file_tmp_3
    done
fi
cleanup $file_tmp_3

## Letters to include.
file_tmp_5=$(mktemp)
if [ -z "$LETTERS_INCLUDED" ]; then
    cp $file_tmp_4 $file_tmp_5
else
    for (( i=0; i<${#LETTERS_INCLUDED}; i++ )); do
        grep -i "${LETTERS_INCLUDED:$i:1}" $file_tmp_4 > $file_tmp_5
        cp $file_tmp_5 $file_tmp_4
    done
fi
cleanup $file_tmp_4

## Letters at specific positions.
file_tmp_6=$(mktemp)
filter_by_character_index $file_tmp_5 $file_tmp_6 1 $LETTER_AT_1

file_tmp_7=$(mktemp)
filter_by_character_index $file_tmp_6 $file_tmp_7 2 $LETTER_AT_2

file_tmp_8=$(mktemp)
filter_by_character_index $file_tmp_7 $file_tmp_8 3 $LETTER_AT_3

file_tmp_9=$(mktemp)
filter_by_character_index $file_tmp_8 $file_tmp_9 4 $LETTER_AT_4

filter_by_character_index $file_tmp_9 $file_dictionary_optimized 5 $LETTER_AT_5

echo "$file_dictionary_optimized"
wc -l < "$file_dictionary_optimized"

if [[ $(wc -l < "$file_dictionary_optimized") -lt 20 ]]; then
    cat $file_dictionary_optimized
fi
# cleanup $file_dictionary_optimized # ?



echo "This is done."
