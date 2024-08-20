#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: August 2024.                          #
#############################################################


source $(dirname $0)/utils.sh
source $(dirname $0)/anagrammer.sh


FILEPATH_WORKBOOK="$WORKSPACE_DIR/wordle_enhanced_workbook.txt"
declare -a TEST_ANAGRAMS_1 TEST_ANAGRAMS_2 TEST_ANAGRAMS_3 TEST_ANAGRAMS_4 TEST_ANAGRAMS_5


get_time() {
    echo $(date +%s000)
}

capture_test_result() {
    local test_name=${1:-''}
    local test_description=${2:-''}
    local test_results=${3:-'failed'}
    local test_duration=${4:--1}

    print_message "[$test_name]"
    print_message "$test_description"
    print_message "$test_result"
    print_message "Runtime: $test_duration milliseconds."

    #ToDo: Save to file --> XML? JSON?
}

get_test_results() {
    local expected=${1:-true}
    local actual=${2:-false}

    echo "Test $([ $expected == $actual ] && echo "passed" || echo "failed")."
}

get_anagram() {
    local letters_to_match=${1:-''}
    local must_fully_match=${2:-true}

    local anagrams=$(find_anagrams "$FILEPATH_WORKBOOK" "$letters_to_match" "$must_fully_match")

    echo "$anagrams"
}

is_anagram() {
    local list=${1:-''}
    local word_to_check=${2:-''}

    local result=false

    if [[ ${list[@]} =~ $word_to_check ]]; then
        result=true
    fi

    echo "$result"
}

setup_test() {
    local letters_to_match=${1:-''}
    local must_fully_match=${2:-false}
    local expected_setup_count=${3:-0}

    local test_start_time=$(get_time)
    letters_to_match=$(decode "$letters_to_match")
    test_description="'$letters_to_match' should have $expected_setup_count $([ true == $must_fully_match ] && echo "full" || echo "partial") anagrams."
    get_anagram $letters_to_match $must_fully_match

    local test_result=$(get_test_results $expected_setup_count $(get_file_line_count "$FILEPATH_ANAGRAMS"))
    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")

    IFS=$'\n' read -d '' -r -a results < $FILEPATH_ANAGRAMS
    test_result=$(get_test_results $expected_setup_count "${#results[@]}")
    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")

    echo "${results[@]}"
}

setup() {
    read -a TEST_ANAGRAMS_1 <<< $(setup_test 'YnJpZWYK' true 2) # 3 in the full dictionary.

    read -a TEST_ANAGRAMS_2 <<< $(setup_test 'cmFwaWQK' true 3)

    read -a TEST_ANAGRAMS_3 <<< $(setup_test 'YmNkZmdoaWprbAo=' true 1)

    read -a TEST_ANAGRAMS_4 <<< $(setup_test 'YmNkZmdoaWprbAo=' false 1)

    read -a TEST_ANAGRAMS_5 <<< $(setup_test 'YWlzbGUK' false 1)
}


## FULL Match Check

test_is_full_anagram_1() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'RklCRVIK')
    local test_description="\n'$word_to_check' should be a full anagram in:\n[${TEST_ANAGRAMS_1[@]}]"
    local test_result=$(get_test_results true $(is_anagram "${TEST_ANAGRAMS_1[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}

test_is_full_anagram_2() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'UEFSREkK')
    local test_description="\n'$word_to_check' should be a full anagram in:\n[${TEST_ANAGRAMS_2[@]}]"
    local test_result=$(get_test_results true $(is_anagram "${TEST_ANAGRAMS_2[@]}" "$word_to_check"))
    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}

test_is_full_anagram_3() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'Q0hJTEQK')
    local test_description="'$word_to_check' should be a full anagram in:\n[${TEST_ANAGRAMS_3[@]}]"
    local test_result=$(get_test_results true $(is_anagram "${TEST_ANAGRAMS_3[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}


test_is_not_full_anagram_1() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'RklMQ0gK')
    local test_description="\n'$word_to_check' should not be a full anagram in:\n[${TEST_ANAGRAMS_3[@]}]"
    local test_result=$(get_test_results false $(is_anagram "${TEST_ANAGRAMS_3[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}

test_is_not_full_anagram_2() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'RkxJQ0sK')
    local test_description="'$word_to_check' should not be a full anagram in:\n[${TEST_ANAGRAMS_3[@]}]"
    local test_result=$(get_test_results false $(is_anagram "${TEST_ANAGRAMS_3[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}


## PARTIAL Match Check

# ToDo: Fix.
test_is_partial_anagram_1() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'Q0hJTEQK')
    local test_description="\n'$word_to_check' should be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    local test_result=$(get_test_results true $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}

test_is_partial_anagram_2() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'RklMQ0gK')
    local test_description="\n'$word_to_check' should be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    local test_result=$(get_test_results true $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}

# ToDo: Fix.
test_is_partial_anagram_3() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'RkxJQ0sK')
    local test_description="\n'$word_to_check' should be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    local test_result=$(get_test_results true $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}


test_is_not_partial_anagram_1() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'Q0hJTEQK')
    local test_description="'$word_to_check' should not be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    local test_result=$(get_test_results false $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}

test_is_not_partial_anagram_2() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'RkxJQ0sK')
    local test_description="\n'$word_to_check' should not be a partial anagram in:\n[${TEST_ANAGRAMS_4[@]}]"
    local test_result=$(get_test_results false $(is_anagram "${TEST_ANAGRAMS_4[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}

test_is_not_partial_anagram_3() {
    local test_start_time=$(get_time)
    local word_to_check=$(decode 'Q09VUlQK')
    local test_description="\n'$word_to_check' should not be a partial anagram in:\n[${TEST_ANAGRAMS_5[@]}]"
    local test_result=$(get_test_results false $(is_anagram "${TEST_ANAGRAMS_5[@]}" "$word_to_check"))

    capture_test_result "${FUNCNAME[0]}" "$test_description" "$test_result" $(get_runtime "$test_start_time")
}


run_tests() {
    test_is_full_anagram_1
    test_is_full_anagram_2
    test_is_full_anagram_3

    test_is_not_full_anagram_1
    test_is_not_full_anagram_2

    test_is_partial_anagram_1
    test_is_partial_anagram_2
    test_is_partial_anagram_3

    test_is_not_partial_anagram_1
    test_is_not_partial_anagram_2
    test_is_not_partial_anagram_3
}


setup
run_tests

print_message "Anagrammer Tests Completed."
