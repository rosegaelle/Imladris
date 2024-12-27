#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################

source $(dirname $0)/utils.sh


find_anagrams() {
    local anagram_dictionary=${1:-''}
    local letters_to_match=${2:-''}
    local must_fully_match=${3:-true}
    local skip_duplicate_characters=${4:-false}

    # Reset the output file.
    empty_or_create_file "$FILEPATH_ANAGRAMS"

    validate_file_dependency "$anagram_dictionary"

    if [ -z "$letters_to_match" ]; then
        print_message "Letters to match specified."
        exit 1
    fi

    if (( $(get_number_of_characters "$letters_to_match") > 0 )); then

        unique_letters_to_match_count=$(get_number_of_characters "$(get_unique_characters "$letters_to_match")")
        (( unique_letters_to_match_count = unique_letters_to_match_count<=WORD_LENGTH ? unique_letters_to_match_count : WORD_LENGTH ))

        while read -r candidate
        do
            common_letters=$(comm -12 <(fold -w1 <<< $letters_to_match | sort -u | uniq) <(fold -w1 <<< $candidate | sort -u | uniq) | tr -d '\n')
            unique_letters_matched_count=$(get_number_of_characters "$(get_unique_characters "$common_letters")")

            if [ true == $must_fully_match ]; then
                is_match=$((($unique_letters_to_match_count == $unique_letters_matched_count)))
            else
                if [ true == $skip_duplicate_characters ]; then
                    is_match=$((($unique_letters_matched_count >= $WORD_LENGTH)))
                else
                    is_match=$((($unique_letters_matched_count >= $(get_number_of_characters $(remove_duplicate_characters "$candidate")))))
                fi
            fi

            if [ 1 == $is_match ]; then
                echo "$candidate" >> $FILEPATH_ANAGRAMS
            fi
        done < "$anagram_dictionary"

        if [[ true == $(is_file_not_empty "$FILEPATH_ANAGRAMS") ]]; then
            sort_by_rank "$FILEPATH_ANAGRAMS" "$letters_to_match"

            print_message "$(get_file_line_count "$FILEPATH_ANAGRAMS") anagram(s) found for '$letters_to_match':"
            cat $FILEPATH_ANAGRAMS
        else
            print_message "'$letters_to_match' does not have a resulting anagram."
        fi
    fi
}
