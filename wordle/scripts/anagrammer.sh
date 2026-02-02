#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################

source "$(dirname "$0")/../scripts/utils.sh"


set -euo pipefail

find_anagrams() {
    local anagram_dictionary=${1:-''}
    local letters_to_match=${2:-''}
    local must_fully_match=${3:-true}
    local skip_duplicate_characters=${4:-false}

    local unique_letters_to_match_count=""
    local unique_letters_matched_count=""
    local common_letters=""
    local is_match=""
    local candidate=""
    local uniq_count_candidate=""

    # Reset the output file.
    empty_or_create_file "$FILEPATH_ANAGRAMS"

    validate_file_dependency "$anagram_dictionary"

    if [ -z "$letters_to_match" ]; then
        print_message "No letters to match specified."
        return 1
    fi

    if (( $(get_number_of_characters "$letters_to_match") > 0 )); then

        unique_letters_to_match_count=$(get_number_of_characters "$(get_unique_characters "$letters_to_match")")
        (( unique_letters_to_match_count = unique_letters_to_match_count<=WORD_LENGTH ? unique_letters_to_match_count : WORD_LENGTH ))

        while IFS= read -r candidate; do
            common_letters=$(comm -12 <(fold -w1 <<< "$letters_to_match" | sort -u) <(fold -w1 <<< "$candidate" | sort -u) | tr -d '\n')
            unique_letters_matched_count=$(get_number_of_characters "$(get_unique_characters "$common_letters")")

            if [[ "${must_fully_match}" == "true" ]]; then
                if (( unique_letters_to_match_count == unique_letters_matched_count )); then
                    is_match=1
                else
                    is_match=0
                fi
            else
                if [[ "${skip_duplicate_characters}" == "true" ]]; then
                    if (( unique_letters_matched_count >= WORD_LENGTH )); then
                        is_match=1
                    else
                        is_match=0
                    fi
                else
                    uniq_count_candidate=$(get_number_of_characters "$(remove_duplicate_characters "$candidate")")
                    if (( unique_letters_matched_count >= uniq_count_candidate )); then
                        is_match=1
                    else
                        is_match=0
                    fi
                fi
            fi

            if (( is_match == 1 )); then
                printf '%s\n' "$candidate" >> "$FILEPATH_ANAGRAMS"
            fi
        done < "$anagram_dictionary"

        if [[ "$(is_file_not_empty "$FILEPATH_ANAGRAMS")" == "true" ]]; then
            sort_by_rank "$FILEPATH_ANAGRAMS" "$letters_to_match"

            print_message "$(get_file_line_count "$FILEPATH_ANAGRAMS") anagram(s) found for '$letters_to_match':"
            cat "$FILEPATH_ANAGRAMS"
        else
            print_message "'$letters_to_match' does not have a resulting anagram."
        fi
    fi
}
