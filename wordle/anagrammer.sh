#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: July 2024                             #
#############################################################

source $(dirname $0)/utils.sh



check_full_anagrams() {
    anagram_dictionary=${1:-''}
    word_to_fully_match=${2:-''}

    echo "check_full_anagrams called with: '$word_to_fully_match'" #-

    validate_file_dependency "$anagram_dictionary"

    file_tmp=$(mktemp)
    while read -r candidate
    do
        is_anagram=$(cmp <(grep -o . <<< $word_to_fully_match | sort) <(grep -o . <<< $candidate | sort))
        if [[ "0" == "$is_anagram" ]] || [[ "" == "$is_anagram" ]]; then
            echo $candidate >> $file_tmp
        fi
    done < "$anagram_dictionary"

    if [[ $(wc -l < "$file_tmp") -gt 0 ]]; then
        cat $file_tmp
        wc -l $file_tmp
    else
        printf "\n'$word_to_fully_match' does not have a result anagram.\n"
    fi

    cleanup "$file_tmp"
}


check_partial_anagrams() {
    anagram_dictionary=${1:-''}
    word_to_partially_match=${2:-''}

    validate_file_dependency "$anagram_dictionary"

    #ToDo
    echo "check_partial_anagrams called with: '$word_to_partially_match'" #-
    check_full_anagrams "$anagram_dictionary" "${word_to_partially_match:0:$WORD_LENGTH}" #-
}


find_anagrams() {
    anagram_dictionary=${1:-''}
    letters_all=${2:-''}
    letters_confirmed=${3:-''}

    validate_file_dependency "$anagram_dictionary"

    letters_count=$(echo -n "$letters_all" | wc -c)

    if [ $((WORD_LENGTH==letters_count)) -eq 1 ]; then
        check_full_anagrams "$FILEPATH_HINT_LIST" "$letters_all"
    else
        letters_partial=$letters_all

        for (( i=0; i<${#letters_confirmed}; i++ )); do
            letters_partial=$(echo "$letters_partial" | sed "s/"${letters_confirmed:$i:1}"//")
        done

        check_partial_anagrams "$anagram_dictionary" "$letters_partial"
    fi
}
