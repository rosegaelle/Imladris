#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: July 2024                             #
#############################################################

source $(dirname $0)/utils.sh
source $(dirname $0)/dictionary.sh
source $(dirname $0)/anagrammer.sh



help() {
    echo "Hello, Wordle!"
    echo
    echo "Syntax: hint_helper [-a|b|c|d|e|f|i|m|n|o|p|q|x]"
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



filter_by_character_index() {
    character_index=${1:-0}
    character_value=${2:-''}
    is_included=${3:-true}

    file_tmp=$(mktemp)
    cp $FILEPATH_HINT_LIST $file_tmp

    if [ ! -z "$character_value" ]; then
        if (( "$character_index" < 1 || "$character_index" > "$WORD_LENGTH" )); then
            echo "Error message goes here."
            exit 1
        fi

        if $is_included; then
            character_value="${character_value:0:1}"
            awk -v s="$character_value" "index(\$0, s) == $character_index" $FILEPATH_HINT_LIST > $file_tmp
        else
            for (( i=0; i<${#character_value}; i++ )); do
                awk -v s="${character_value:$i:1}" "index(\$0, s) != $character_index" $FILEPATH_HINT_LIST > $file_tmp
                cp $file_tmp $FILEPATH_HINT_LIST
            done
        fi
    fi

    mv $file_tmp $FILEPATH_HINT_LIST
}

insert_unique() {
    word=${1:-""}
    filename=${2:-""}

    validate_file_dependency "$filename"

    if ! grep -q "$word" "$filename"; then
            echo $word >> $filename
        fi
}


# Checking or creating the enhanced dictionary file.
prepare_dictionary $FILEPATH_WORKBOOK

# Making a working copy in the event the original file needs to be reused in subsequent runs.
file_tmp_1=$(mktemp)
cp $FILEPATH_ENHANCED_DICTIONARY $file_tmp_1


# Processing hints, if any.

## Letters to exclude.
file_tmp_2=$(mktemp)
if [ -z "$LETTERS_EXCLUDED" ]; then
    cp $file_tmp_1 $file_tmp_2
else
    for (( i=0; i<${#LETTERS_EXCLUDED}; i++ )); do
        grep -iv "${LETTERS_EXCLUDED:$i:1}" $file_tmp_1 > $file_tmp_2
        cp $file_tmp_2 $file_tmp_1
    done
fi
cleanup "$file_tmp_1"

## Letters to include.
LETTERS_INCLUDED=$LETTERS_INCLUDED$LETTER_AT_1$LETTER_AT_2$LETTER_AT_3$LETTER_AT_4$LETTER_AT_5 | grep -o . | sort -u | tr -d "\n"
if [ -z "$LETTERS_INCLUDED" ]; then
    cp $file_tmp_2 $FILEPATH_HINT_LIST
else
    for (( i=0; i<${#LETTERS_INCLUDED}; i++ )); do
        grep -i "${LETTERS_INCLUDED:$i:1}" $file_tmp_2 > $FILEPATH_HINT_LIST
        cp $FILEPATH_HINT_LIST $file_tmp_2
    done
fi
cleanup "$file_tmp_2"

## Letters at specific positions.
filter_by_character_index 1 "$LETTER_AT_1"
filter_by_character_index 2 "$LETTER_AT_2"
filter_by_character_index 3 "$LETTER_AT_3"
filter_by_character_index 4 "$LETTER_AT_4"
filter_by_character_index 5 "$LETTER_AT_5"

## Letters NOT at specific positions.
filter_by_character_index 1 "$LETTERS_NOT_AT_1" false
filter_by_character_index 2 "$LETTERS_NOT_AT_2" false
filter_by_character_index 3 "$LETTERS_NOT_AT_3" false
filter_by_character_index 4 "$LETTERS_NOT_AT_4" false
filter_by_character_index 5 "$LETTERS_NOT_AT_5" false

## Parsing possible solutions and suggesting potential next guess(es).
unique_letters=$(grep -o . $FILEPATH_HINT_LIST | sort -u | tr -d '\n')
file_tmp_3=$(mktemp)
for (( i=0; i<${#unique_letters}; i++ )); do
    grep -o $FILEPATH_HINT_LIST -e "${unique_letters:$i:1}" | sort | uniq -c >> $file_tmp_3
done
cat $file_tmp_3

unique_letters_by_occurences=$(cat $file_tmp_3 | sort -rk4 | uniq -c | awk '{ print $3}' | tr -d '\n')
cleanup "$file_tmp_3"

get_anagrams $unique_letters_by_occurences

# Display the top 5 possibilities
if [[ $(wc -l < "$FILEPATH_HINT_LIST") -le 5 ]]; then
    cat $FILEPATH_HINT_LIST
fi

wc -l $FILEPATH_HINT_LIST

printf "\nIt is done.\n"
