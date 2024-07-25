#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: July 2024                             #
#############################################################

help() {
    echo "Hello, Wordle!"
    echo
    echo "Syntax: get_optimized_dictionary [-a|b|c|d|e|f|i|m|n|o|p|q|x]"
    echo "options:"
    echo "a     First letter of the word."
    echo "b     Character at the second position."
    echo "c     Character at the third position."
    echo "d     Character at the fourth position."
    echo "e     Last letter of the word."
    echo "f     Enhanced workbook location, to bypass the dictionary processing steps."
    echo "i     Letters to include."
    echo "m     Letters that cannot be at the start of the word."
    echo "n     Letters that cannot be at the second position."
    echo "o     Letters that cannot be at the third position."
    echo "p     Letters that cannot be at the fourth position."
    echo "q     Letters that cannot be at the end of the word."
    echo "x     Letters to exclude."
    echo
}

sanitize_input() {
    user_input=${1:-''}
    echo $user_input | tr -cd '[:alpha:]'| tr '[:upper:]' '[:lower:]'
}


while getopts ":a:b:c:d:e:f:i:m:n:o:p:q:x:" flag
do
    case "${flag}" in
        a) LETTER_AT_1=$(sanitize_input ${OPTARG});;
        b) LETTER_AT_2=$(sanitize_input ${OPTARG});;
        c) LETTER_AT_3=$(sanitize_input ${OPTARG});;
        d) LETTER_AT_4=$(sanitize_input ${OPTARG});;
        e) LETTER_AT_5=$(sanitize_input ${OPTARG});;
        f) FILEPATH_WORKBOOK=${OPTARG};;
        i) LETTERS_INCLUDED=$(sanitize_input ${OPTARG});;
        m) LETTERS_NOT_AT_1=$(sanitize_input ${OPTARG});;
        n) LETTERS_NOT_AT_2=$(sanitize_input ${OPTARG});;
        o) LETTERS_NOT_AT_3=$(sanitize_input ${OPTARG});;
        p) LETTERS_NOT_AT_4=$(sanitize_input ${OPTARG});;
        q) LETTERS_NOT_AT_5=$(sanitize_input ${OPTARG});;
        x) LETTERS_EXCLUDED=$(sanitize_input ${OPTARG});;
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
    is_included=${5:-true}

    validate_file_dependency "$filename_input"

    if [ -z "$character_value" ]; then
        cp $filename_input $filename_output
    else
        if (( "$character_index" < 1 || "$character_index" > "$WORD_LENGTH" )); then
            echo "Error message goes here."
            exit 1
        fi

        if $is_included; then
            character_value="${character_value:0:1}"
            awk -v s="$character_value" "index(\$0, s) == $character_index" $filename_input > $filename_output
        else
            for (( i=0; i<${#character_value}; i++ )); do
                awk -v s="${character_value:$i:1}" "index(\$0, s) != $character_index" $filename_input > $filename_output
                cp $filename_output $filename_input
            done
        fi
    fi

    cleanup "$filename_input"
}

insert_unique() {
    word=${1:-""}
    filename=${2:-""}

    validate_file_dependency "$filename"

    if ! grep -q "$word" "$filename"; then
            echo $word >> $filename
        fi
}

cleanup() {
    filename=${1:-""}
    [ -e $filename ] && rm "$filename"
}



file_tmp_3=$(mktemp)
if [ ! -z "$FILEPATH_WORKBOOK" ] && [ ! $(validate_file_dependency $FILEPATH_WORKBOOK) ]; then
    cp $FILEPATH_WORKBOOK $file_tmp_3
    wc -l $file_tmp_3

else

    # 1. Ensure the necessary resources files exist before starting.
    file_dictionary_full=$(mktemp)
    curl -o $file_dictionary_full "https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/dictionary_full.txt"
    validate_file_dependency "$file_dictionary_full"

    file_previous_solutions=$(mktemp)
    curl -o $file_previous_solutions "https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/workbook.txt"
    validate_file_dependency "$file_previous_solutions"

    # 2. Decode the full dictionary.
    file_tmp_1=$(mktemp)
    while read -r line
    do
        echo $line | base64 -d >> $file_tmp_1
    done < $file_dictionary_full
    cleanup "$file_dictionary_full"



    # 3. Decode the workbook, which was encoded to prevent accidental spoilers.
    file_tmp_2=$(mktemp)
    while read -r line
    do
        echo $line | base64 -d >> $file_tmp_2
    done < $file_previous_solutions
    cleanup "$file_previous_solutions"



    # 4. Remove all previous solutions from the working dictionary.
    cat $file_tmp_2 $file_tmp_1 | sort | uniq -u > $file_tmp_3

    cleanup "$file_tmp_1"
    cleanup "$file_tmp_2"
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
cleanup "$file_tmp_3"

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
cleanup "$file_tmp_4"

## Letters at specific positions.
file_tmp_6=$(mktemp)
filter_by_character_index $file_tmp_5 $file_tmp_6 1 "$LETTER_AT_1" true

file_tmp_7=$(mktemp)
filter_by_character_index $file_tmp_6 $file_tmp_7 2 "$LETTER_AT_2" true

file_tmp_8=$(mktemp)
filter_by_character_index $file_tmp_7 $file_tmp_8 3 "$LETTER_AT_3" true

file_tmp_9=$(mktemp)
filter_by_character_index $file_tmp_8 $file_tmp_9 4 "$LETTER_AT_4" true

file_tmp_10=$(mktemp)
filter_by_character_index $file_tmp_9 $file_tmp_10 5 "$LETTER_AT_5" true

file_tmp_11=$(mktemp)
filter_by_character_index $file_tmp_10 $file_tmp_11 1 "$LETTERS_NOT_AT_1" false

file_tmp_12=$(mktemp)
filter_by_character_index $file_tmp_11 $file_tmp_12 2 "$LETTERS_NOT_AT_2" false

file_tmp_13=$(mktemp)
filter_by_character_index $file_tmp_12 $file_tmp_13 3 "$LETTERS_NOT_AT_3" false

file_tmp_14=$(mktemp)
filter_by_character_index $file_tmp_13 $file_tmp_14 4 "$LETTERS_NOT_AT_4" false

filter_by_character_index $file_tmp_14 $file_dictionary_optimized 5 "$LETTERS_NOT_AT_5" false


wc -l $file_dictionary_optimized

if [[ $(wc -l < "$file_dictionary_optimized") -lt 20 ]]; then
    cat $file_dictionary_optimized
else
    unique_letters=$(grep -o . $file_dictionary_optimized | sort -u | tr -d '\n')
    for (( i=0; i<${#unique_letters}; i++ )); do
        grep -o $file_dictionary_optimized -e "${unique_letters:$i:1}" | sort | uniq -c
    done
fi

# cleanup "$file_dictionary_optimized" #???


echo "It is done."
