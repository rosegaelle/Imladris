#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: July 2024                             #
#############################################################

source $(dirname $0)/utils.sh


find_anagrams() {
    anagram_dictionary=${1:-''}
    letters_to_match=${2:-''}
    must_fully_match=${3:-true}

    # Reset the output file.
    empty_or_create_file "$FILEPATH_ANAGRAMS"

    validate_file_dependency "$anagram_dictionary"

    if [ -z "$letters_to_match" ]; then
        printf "\nLetters to match specified.\n"
        exit 1
    fi

    if (( $(get_number_of_characters "$letters_to_match") > 0 )); then

        unique_letters_to_match_count=$(get_number_of_characters "$(get_unique_characters "$letters_to_match")")
        (( unique_letters_to_match_count = unique_letters_to_match_count<=WORD_LENGTH ? unique_letters_to_match_count : WORD_LENGTH ))

        while read -r candidate
        do
            common_letters=$(comm -12 <(fold -w1 <<< $letters_to_match | sort -u) <(fold -w1 <<< $candidate | sort -u) | tr -d '\n')
            unique_letters_matched_count=$(get_number_of_characters "$(get_unique_characters "$common_letters")")

            if [ true == $must_fully_match ]; then
                is_match=$((($unique_letters_to_match_count == $unique_letters_matched_count)))
            else
                is_match=$((($unique_letters_matched_count > 0)))
            fi

            if [ 1 == $is_match ]; then
                echo "$candidate" >> $FILEPATH_ANAGRAMS
            fi
        done < "$anagram_dictionary"

        if [[ true == $(is_file_not_empty "$FILEPATH_ANAGRAMS") ]] && (( $(wc -l < "$FILEPATH_ANAGRAMS") < 25 )) ; then
            cat $FILEPATH_ANAGRAMS
            wc -l $FILEPATH_ANAGRAMS
        else
            printf "\n'$letters_to_match' does not have a resulting anagram.\n"
        fi
    fi
}
