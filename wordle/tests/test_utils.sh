#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################

source $(dirname $0)/../../Imladris/wordle/scripts/utils.sh


get_time() {
    echo $(date +%s000)
}


get_test_results() {
    local expected=${1:-true}
    local actual=${2:-false}

    echo "Test $([ $expected == $actual ] && echo "passed" || echo "failed")."
}


compare_test_results() {
    local expected=${1:-'?'}
    local actual=${2:-''}

    print_message "Expected: [$expected]"
    print_message "Actual:   [$actual]"

    echo "Test $([ -z $(diff <(<<< $expected) <(<<< $actual)) ] && echo "passed" || echo "failed")."
}


capture_test_result() {
    local test_name=${1:-''}
    local test_description=${2:-''}
    local test_results=${3:-'failed'}
    local test_duration=${4:--1}

    print_message "[$test_name] $test_description"
    print_message "$test_result"
    print_message "Runtime: $test_duration milliseconds $(convert_time "$test_duration")."

    #ToDo: Save to file --> XML? JSON?
}
