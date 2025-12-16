#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/dictionary.sh"
source "$(dirname "$0")/anagrammer.sh"


set -euo pipefail

# Initialize global variables to avoid "unbound variable" errors
LETTER_AT_1=""
LETTER_AT_2=""
LETTER_AT_3=""
LETTER_AT_4=""
LETTER_AT_5=""
FILEPATH_WORKBOOK=""
LETTERS_INCLUDED=""
LETTERS_NOT_AT_1=""
LETTERS_NOT_AT_2=""
LETTERS_NOT_AT_3=""
LETTERS_NOT_AT_4=""
LETTERS_NOT_AT_5=""
SKIP_ANAGRAMMER=""
LETTERS_EXCLUDED=""
ZAP_LETTERS_INCLUDED_FROM_OUTPUT=""
unique_letters_by_occurence=""


help() {
    echo "Hello, Wordle!"
    echo
    echo "Syntax: hint_helper [-a|b|c|d|e|f|i|m|n|o|p|q|s|x|z]"
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
    echo "s     Whether the anagrammer should be skipped or not."
    echo "x     Letters to exclude."
    echo "z     Whether to reset the output or not."
    echo
}

while getopts ":a:b:c:d:e:f:i:m:n:o:p:q:s:x:z:" flag
do
    case "${flag}" in
        a) LETTER_AT_1=$(sanitize_input "${OPTARG}");;
        b) LETTER_AT_2=$(sanitize_input "${OPTARG}");;
        c) LETTER_AT_3=$(sanitize_input "${OPTARG}");;
        d) LETTER_AT_4=$(sanitize_input "${OPTARG}");;
        e) LETTER_AT_5=$(sanitize_input "${OPTARG}");;
        f) FILEPATH_WORKBOOK="${OPTARG}";;
        i) LETTERS_INCLUDED=$(sanitize_input "${OPTARG}");;
        m) LETTERS_NOT_AT_1=$(sanitize_input "${OPTARG}");;
        n) LETTERS_NOT_AT_2=$(sanitize_input "${OPTARG}");;
        o) LETTERS_NOT_AT_3=$(sanitize_input "${OPTARG}");;
        p) LETTERS_NOT_AT_4=$(sanitize_input "${OPTARG}");;
        q) LETTERS_NOT_AT_5=$(sanitize_input "${OPTARG}");;
        s) SKIP_ANAGRAMMER="${OPTARG}";;
        x) LETTERS_EXCLUDED=$(sanitize_input "${OPTARG}");;
        z) ZAP_LETTERS_INCLUDED_FROM_OUTPUT=$(sanitize_input "${OPTARG:-false}");;
        *) help
        exit 1;;
    esac
done


SKIP_ANAGRAMMER=${SKIP_ANAGRAMMER:-true}
HINT_THRESHOLD=5


filter_by_character_index() {
    local character_index=${1:-0}
    local character_value=${2:-''}
    local is_included=${3:-true}

    if [ -n "$character_value" ]; then
        if (( character_index < 1 || character_index > WORD_LENGTH )); then
            print_message "Character index out of bound!"
            return 1
        fi

        local file_tmp=$(mktemp) || return 1

        if [[ "$is_included" == true ]]; then
            #- awk '{print substr($0,'$character_index', '$character_index' - 1) ~ /'$character_value'/, $0}' < <(grep $character_value $FILEPATH_HINT_LIST) | grep 1 | awk '{print $2}' > $file_tmp #-
            #+ awk -v s="$character_value" "index(\$0, s) == $character_index" $FILEPATH_HINT_LIST > $file_tmp #+

            local ch=${character_value:0:1}
            ##+ awk -v s="$character_value" "index(\$0, s) == $character_index" $FILEPATH_HINT_LIST > $file_tmp #+
            awk -v idx="$character_index" -v s="$ch" 'substr($0, idx, 1) == s { print $0 }' "$FILEPATH_HINT_LIST" > "$file_tmp" ###+
        else
            local work="$FILEPATH_HINT_LIST"
            for (( i=0; i<$(get_word_length "$character_value"); i++ )); do
                local ch=$(get_character_at "$character_value" "$i")
                awk -v idx="$character_index" -v s="$ch" 'substr($0, idx, 1) != s { print $0 }' "$work" > "$file_tmp"
                move_file "$file_tmp" "$work"
            done
        fi

        move_file "$file_tmp" "$FILEPATH_HINT_LIST"
    fi
}


search_anagrams() {
    local letters_to_match=${1:-''}

    for (( i=$WORD_LENGTH, j=$(get_file_line_count "$FILEPATH_ANAGRAMS"); i<((1 + ${#letters_to_match})) && 0==$j; i++, j=$(get_file_line_count "$FILEPATH_ANAGRAMS"))); do
        word="${letters_to_match:0:i}"

        if [[ true == $(has_vowel "$word") ]]; then
            find_anagrams "$FILEPATH_WORKBOOK" "${letters_to_match:0:i}" false true
        fi
    done
}


basetime=$(date +%s000)
date -r $(($basetime / 1000))


# Reset the output file.
empty_or_create_file "$FILEPATH_HINT_LIST"

# Checking or creating the enhanced dictionary file.
prepare_dictionary "$FILEPATH_WORKBOOK"

# Making a working copy in the event the original file needs to be reused in subsequent runs.
file_tmp_1=$(mktemp)
copy_file "$FILEPATH_ENHANCED_DICTIONARY" "$file_tmp_1"


# Processing hints, if any.

# Safety check, in case of manual user input errors.
LETTERS_INCLUDED=$(echo "$LETTERS_INCLUDED$LETTER_AT_1$LETTER_AT_2$LETTER_AT_3$LETTER_AT_4$LETTER_AT_5$LETTERS_NOT_AT_1$LETTERS_NOT_AT_2$LETTERS_NOT_AT_3$LETTERS_NOT_AT_4$LETTERS_NOT_AT_5" | grep -o . | sort -u | tr -d "\n")
if [ ! -z "$LETTERS_INCLUDED" ]; then
    LETTERS_EXCLUDED=$(echo "$LETTERS_EXCLUDED" | sed "s/[$LETTERS_INCLUDED]//g")
fi

## Letters to exclude.
file_tmp_2=$(mktemp)
file_after_exclude=""
if [ -z "$LETTERS_EXCLUDED" ]; then
    copy_file "$file_tmp_1" "$file_tmp_2"
    file_after_exclude="$file_tmp_2"
else
    work="$file_tmp_1"
    for (( i=0; i<${#LETTERS_EXCLUDED}; i++ )); do
        ch=$(get_character_at "$LETTERS_EXCLUDED" "$i")
        file_tmp_2=$(mktemp)
        grep -ivF -- "$ch" "$work" > "$file_tmp_2" || true
        if [ "$work" != "$file_tmp_1" ]; then
            cleanup_file "$work"
        fi
        work="$file_tmp_2"
    done
    file_after_exclude="$work"
fi
cleanup_file "$file_tmp_1"

## Letters to include.
if [ -z "$LETTERS_INCLUDED" ]; then
    copy_file "$file_after_exclude" "$FILEPATH_HINT_LIST"
else
    work="$file_after_exclude"

    for (( i=0; i<${#LETTERS_INCLUDED}; i++ )); do
        ch=$(get_character_at "$LETTERS_INCLUDED" "$i")
        file_tmp_inc=$(mktemp)
        grep -iF -- "$ch" "$work" > "$file_tmp_inc" || true
        if [ "$work" != "$file_after_exclude" ]; then
            cleanup_file "$work"
        fi
        work="$file_tmp_inc"
    done

    move_file "$work" "$FILEPATH_HINT_LIST"
fi
cleanup_file "$file_after_exclude"

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


if [[ "${SKIP_ANAGRAMMER:-true}" != "true" ]] && (( HINT_THRESHOLD < $(get_file_line_count "$FILEPATH_HINT_LIST") )); then
    # Parsing possible solutions and suggesting potential next guess(es).
    print_message "Deriving anagrams based on the most occuring letters."

    unique_letters=$(grep -o . "$FILEPATH_HINT_LIST" | sort -u | tr -d '\n')
    file_tmp_3=$(mktemp)
    for (( i=0; i<${#unique_letters}; i++ )); do
        ch=$(get_character_at "$unique_letters" "$i")
        grep -o -i -e "$ch" "$FILEPATH_HINT_LIST" | sort | uniq -c >> "$file_tmp_3" || true
    done

    unique_letters_by_occurence=$(sort -rk1 "$file_tmp_3" | awk '{ print $2 }' | tr -d '\n' || true)
    print_message "Unique letters by occurence: '$unique_letters_by_occurence'."
    cleanup_file "$file_tmp_3"

    unique_letters_by_occurence_unconfirmed=$unique_letters_by_occurence
    for (( i=0; i<${#LETTERS_INCLUDED}; i++ )); do
        unique_letters_by_occurence_unconfirmed=$(echo "$unique_letters_by_occurence_unconfirmed" | sed "s/$(get_character_at "$LETTERS_INCLUDED" "$i")//")
    done

    empty_or_create_file "$FILEPATH_ANAGRAMS"

    if [[ "${ZAP_LETTERS_INCLUDED_FROM_OUTPUT:-false}" == "true" ]]; then
        search_anagrams "$unique_letters_by_occurence_unconfirmed"
    else
        search_anagrams "$unique_letters_by_occurence"
    fi
fi


# Displaying the top possibilities.
sort_by_rank "$FILEPATH_HINT_LIST" "$unique_letters_by_occurence"
if [[ "$(is_file_not_empty "$FILEPATH_HINT_LIST")" == "true" ]] && (( HINT_THRESHOLD >= $(get_file_line_count "$FILEPATH_HINT_LIST") )); then
    if (( 1 == $(get_file_line_count "$FILEPATH_HINT_LIST") )); then
        print_message "Eureka!"
        alert "Eureka !"
        toUpperCase "$(cat "$FILEPATH_HINT_LIST")"
    else
        print_message "Ranked top $(get_file_line_count "$FILEPATH_HINT_LIST") possibilities:"
        cat "$FILEPATH_HINT_LIST"
    fi
else
    show_file_line_count "$FILEPATH_HINT_LIST"
fi

runtime=$(get_runtime "$basetime")
print_message "Runtime: $runtime milliseconds $(convert_time "$runtime")."

print_message "It is done."
date -r $(( (($basetime + $runtime)) / 1000))
alert "C'est fini !"
