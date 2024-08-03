#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: August 2024.                          #
#############################################################


source $(dirname $0)/utils.sh
source $(dirname $0)/anagrammer.sh


FILEPATH_WORKBOOK="$WORKSPACE/wordle_enhanced_workbook.txt" #-
declare -a TEST_ANAGRAMS_1 TEST_ANAGRAMS_2 TEST_ANAGRAMS_3 TEST_ANAGRAMS_4 TEST_ANAGRAMS_5


print_test_results() {
    expected=${1:-true}
    actual=${2:-false}

    print_message "Test $([ $expected == $actual ] && echo "passed" || echo "failed")."
}

get_anagram() {
    letters_to_match=${1:-''}
    must_fully_match=${2:-true}

    anagrams=$(find_anagrams "$FILEPATH_WORKBOOK" "$letters_to_match" "$must_fully_match")

    echo "$anagrams"
}

is_anagram() {
    list=${1:-''}
    word_to_check=${2:-''}

    result=false

    if [[ ${list[@]} =~ $word_to_check ]]; then #ToDo: fix!!!
        result=true
    fi

    echo "$result"
}


setup_test() {
    letters_to_match=${1:-''}
    must_fully_match=${2:-false}
    expected_setup_count=${3:-0}
 
    letters_to_match=$(decode "$letters_to_match")
    print_message "'$letters_to_match' should have $expected_setup_count $([ true == $must_fully_match ] && echo "full" || echo "partial") anagrams."
    get_anagram $letters_to_match $must_fully_match #ToDo: fix!!!
    print_test_results $expected_setup_count $(get_file_line_count "$FILEPATH_ANAGRAMS")
    IFS=$'\n' read -d '' -r -a results < $FILEPATH_ANAGRAMS
    print_test_results $expected_setup_count "${#results[@]}"

    echo "${results[@]}"
}

setup() {
    read -a TEST_ANAGRAMS_1 <<< $(setup_test 'YnJpZWYK' true 3)

    read -a TEST_ANAGRAMS_2 <<< $(setup_test 'cmFwaWQK' true 0)

    read -a TEST_ANAGRAMS_3 <<< $(setup_test 'YmNkZmdoaWprbAo=' true 0)

    read -a TEST_ANAGRAMS_4 <<< $(setup_test 'YmNkZmdoaWprbAo=' false 0)

    read -a TEST_ANAGRAMS_5 <<< $(setup_test 'YWlzbGUK' false 0)
}


## FULL Match Check

test_is_full_anagram_1() {
    print_message "[test_is_full_anagram_1]"
    word_to_check=$(decode 'RklCRVIK')

    echo -e "\n'$word_to_check' should be a full anagram in:\n[${TEST_ANAGRAMS_1[@]}]"
    print_test_results true $(is_anagram "${TEST_ANAGRAMS_1[@]}" "$word_to_check")
}

test_is_full_anagram_2() {
    print_message "[test_is_full_anagram_2]"

    word_to_check=$(decode 'UEFSREkK')

    echo -e "\n'$word_to_check' should be a full anagram in:\n[${TEST_ANAGRAMS_2[@]}]"
    print_test_results true $(is_anagram "${TEST_ANAGRAMS_2[@]}" "$word_to_check")
}


test_is_not_full_anagram_1() {
    print_message "[test_is_not_full_anagram_1]"

    word_to_check=$(decode 'Q0hJTEQK')

    echo -e "\n'$word_to_check' should not be a full anagram in:\n[${TEST_ANAGRAMS_3[@]}]"
    print_test_results false $(is_anagram "${TEST_ANAGRAMS_3[@]}" "$word_to_check")
}

test_is_not_full_anagram_2() {
    print_message "[test_is_not_full_anagram_2]"

    word_to_check=$(decode 'RklMQ0gK')

    echo -e "'$word_to_check' should not be a full anagram in:\n[${TEST_ANAGRAMS_3[@]}]"
    print_test_results false $(is_anagram "${TEST_ANAGRAMS_3[@]}" "$word_to_check")
}

test_is_not_full_anagram_3() {
    print_message "[test_is_not_full_anagram_3]"

    word_to_check=$(decode 'RkxJQ0sK')

    echo -e "'$word_to_check' should not be a full anagram in:\n[${TEST_ANAGRAMS_3[@]}]"
    print_test_results false $(is_anagram "${TEST_ANAGRAMS_3[@]}" "$word_to_check")
}


## PARTIAL Match Check

test_is_partial_anagram_1() {
    print_message "[test_is_partial_anagram_1]"

    word_to_check=$(decode 'Q0hJTEQK')

    echo -e "'$word_to_check' should be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    print_test_results true $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check")
}

test_is_partial_anagram_2() {
    print_message "[test_is_partial_anagram_2]"

    word_to_check=$(decode 'RklMQ0gK')

    echo -e "\n'$word_to_check' should be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    print_test_results true $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check")
}

test_is_partial_anagram_3() {
    print_message "[test_is_partial_anagram_3]"

    word_to_check=$(decode 'RkxJQ0sK')

    echo -e "\n'$word_to_check' should be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    print_test_results true $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check")
}


test_is_not_partial_anagram_1() {
    print_message "[test_is_not_partial_anagram_1]"

    word_to_check=$(decode 'Q09VUlQK')

    echo -e "\n'$word_to_check' should not be a partial anagram in:\n[${TEST_ANAGRAMS_5[@]}]"
    print_test_results false $(is_anagram "${TEST_ANAGRAMS_5[@]}" "$word_to_check")
}


# Executing each test case:
setup

test_is_full_anagram_1
test_is_full_anagram_2

test_is_not_full_anagram_1
test_is_not_full_anagram_2
test_is_not_full_anagram_3

test_is_partial_anagram_1
test_is_partial_anagram_2
test_is_partial_anagram_3

test_is_not_partial_anagram_1

print_message "Anagrammer Tests Completed."
