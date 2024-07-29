#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: July 2024                             #
#############################################################


source $(dirname $0)/utils.sh
source $(dirname $0)/anagrammer.sh


FILEPATH_WORKBOOK='/Users/rosegaelle/Downloads/tmp/wordle_enhanced_workbook.txt' #-
TEST_ANAGRAMS_1=''


print_test_results() {
    expected=${1:-true}
    actual=${2:-false}

    printf "\nTest $([ $expected == $actual ] && echo "passed" || echo "failed")."
}


get_anagram() {
    letters_to_match=${1:-''}
    must_fully_match=${2:-true}

    anagrams=$(find_anagrams "$FILEPATH_WORKBOOK" "$letters_to_match" "$must_fully_match")

    echo "$anagrams"
}

is_anagram() {
    candidate=${1:-''}

    results=false

    if [[ true == $(is_file_not_empty "$FILEPATH_ANAGRAMS") ]]; then
        if grep -q $candidate "$FILEPATH_ANAGRAMS"; then
            results=true
        fi
    fi

    echo "$results"
}


setup() {
    TEST_ANAGRAMS_1=$(get_anagram '???' true)
    # Then, convert to and use array.
}


## FULL Match Check

test_is_full_anagram_1() {
    printf "\n\n[test_is_full_anagram_1]"
    letters_to_match=$(decode 'YnJpZWYK')

    anagrams=$(get_anagram "$letters_to_match" true)

    word_to_check=$(decode 'RklCRVIK')

    printf "\n'$word_to_check' should be a full anagram of '$letters_to_match'."
    print_test_results true $(is_anagram $word_to_check)
}

test_is_full_anagram_2() {
    printf "\n[test_is_full_anagram_2]"
    letters_to_match=$(decode 'cmFwaWQK')

    anagrams=$(get_anagram "$letters_to_match" true)

    word_to_check=$(decode 'UEFSREkK')

    printf "\n'$word_to_check' should be a full anagram of '$letters_to_match'."
    print_test_results true $(is_anagram $word_to_check)
}


test_is_not_full_anagram_1() {
    printf "\n\n[test_is_not_full_anagram_1]"
    letters_to_match=$(decode 'YmNkZmdoaWprbAo=')

    anagrams=$(get_anagram "$letters_to_match" true)

    word_to_check=$(decode 'Q0hJTEQK')

    printf "\n'$word_to_check' should not be a full anagram of '$letters_to_match'."
    print_test_results false $(is_anagram $word_to_check)
}

test_is_not_full_anagram_2() {
    printf "\n\n[test_is_not_full_anagram_2]"
    letters_to_match=$(decode 'YmNkZmdoaWprbAo=')

    anagrams=$(get_anagram "$letters_to_match" true)

    word_to_check=$(decode 'RklMQ0gK')

    printf "\n'$word_to_check' should not be a full anagram of '$letters_to_match'."
    print_test_results false $(is_anagram $word_to_check)
}

test_is_not_full_anagram_3() {
    printf "\n\n[test_is_not_full_anagram_3]"
    letters_to_match=$(decode 'YmNkZmdoaWprbAo=')

    anagrams=$(get_anagram "$letters_to_match" true)

    word_to_check=$(decode 'RkxJQ0sK')

    printf "\n'$word_to_check' should not be a full anagram of '$letters_to_match'."
    print_test_results false $(is_anagram $word_to_check)
}


## PARTIAL Match Check

test_is_partial_anagram_1() {
    printf "\n\n[test_is_partial_anagram_1]"
    letters_to_match=$(decode 'YmNkZmdoaWprbAo=')

    anagrams=$(get_anagram "$letters_to_match" false)

    word_to_check=$(decode 'Q0hJTEQK')

    printf "\n'$word_to_check' should be a partial anagram of '$letters_to_match'."
    print_test_results true $(is_anagram $word_to_check)
}

test_is_partial_anagram_2() {
    printf "\n\n[test_is_partial_anagram_2]"
    letters_to_match=$(decode 'YmNkZmdoaWprbAo=')

    anagrams=$(get_anagram "$letters_to_match" false)

    word_to_check=$(decode 'RklMQ0gK')

    printf "\n'$word_to_check' should be a partial anagram of '$letters_to_match'."
    print_test_results true $(is_anagram $word_to_check)
}

test_is_partial_anagram_3() {
    printf "\n\n[test_is_partial_anagram_3]"
    letters_to_match=$(decode 'YmNkZmdoaWprbAo=')

    anagrams=$(get_anagram "$letters_to_match" false)

    word_to_check=$(decode 'RkxJQ0sK')

    printf "\n'$word_to_check' should not be a partial anagram of '$letters_to_match'."
    print_test_results true $(is_anagram $word_to_check)
}


test_is_not_partial_anagram_1() {
    printf "\n\n[test_is_not_partial_anagram_1]"
    letters_to_match=$(decode 'YWlzbGUK')

    anagrams=$(get_anagram "$letters_to_match" false)

    word_to_check=$(decode 'Q09VUlQK')

    printf "\n'$word_to_check' should not be a partial anagram of '$letters_to_match'."
    print_test_results false $(is_anagram $word_to_check)
}


# Executing each test case:

# ToDo:
#+ setup

test_is_full_anagram_1
test_is_full_anagram_2

test_is_not_full_anagram_1
test_is_not_full_anagram_2
test_is_not_full_anagram_3

test_is_partial_anagram_1
test_is_partial_anagram_2
test_is_partial_anagram_3

test_is_not_partial_anagram_1

printf "\nAnagrammer Tests Completed.\n"
