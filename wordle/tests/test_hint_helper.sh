#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################

source $(dirname $0)/../scripts/utils.sh
source $(dirname $0)/../tests/test_utils.sh


test() {
    local unit_test_to_run=${1:-0}

    source ../tmp/reset.sh #-
    export SKIP_ANAGRAMMER=true

    case $unit_test_to_run in
        1)
            test_0
        ;;

        102)
            test_102
        ;;

        1060)
            test_1060
        ;;

        *)
            test_0
            test_102
            test_1060
        ;;
    esac
}


test_0() {
    print_message "[Test # 0] Placeholder."
}


test_102() {
    local test_start_time=$(get_time)
    local test_description='Repeated Letters: 🟩🟩.'
    capture_test_result "${FUNCNAME[0]}" "<0> $test_description" "" $(get_runtime "$test_start_time")


    local tmp_solution='QUdBVEUK'
    tmp_solution=$(decode "$tmp_solution") && echo $tmp_solution

    local tmp_file=$(mktemp)
    cp $FILEPATH_ENHANCED_DICTIONARY $tmp_file
    FILEPATH_ENHANCED_DICTIONARY="$tmp_file"

    tmp_file=$(mktemp)
    cp $FILEPATH_PREVIOUS_SOLUTIONS $tmp_file
    FILEPATH_PREVIOUS_SOLUTIONS="$tmp_file"

    if ((0 == $(grep -ic "$tmp_solution" $FILEPATH_ENHANCED_DICTIONARY))); then
        print_message "Updating '$FILEPATH_ENHANCED_DICTIONARY'."
        echo "$tmp_solution" >> "$FILEPATH_ENHANCED_DICTIONARY"

        print_message "Updating '$FILEPATH_PREVIOUS_SOLUTIONS'."
        tmp_file=$(mktemp)
        awk "!/$(encode "$tmp_solution")/" $FILEPATH_PREVIOUS_SOLUTIONS > $tmp_file && mv $tmp_file $FILEPATH_PREVIOUS_SOLUTIONS
    fi


    # Guess 1: 
    test_description='Guess # 1: ⬛⬛🟩⬛🟩.'
    local ZAP_LETTERS_INCLUDED_FROM_OUTPUT=true

    local tmp_guess='U09BUkUK'
    tmp_guess=$(decode "$tmp_guess") && echo $tmp_guess

    diff_with_feedback "$tmp_solution" "$tmp_guess"
    transcribe "$tmp_guess" $(generate_diff "$tmp_solution" "$tmp_guess") $is_first_guess

    GUESS_X=$(decode 'T1JTCg==')
    GUESS_I=$(decode 'QUUK')
    GUESS_C=$(decode 'QQo=')
    GUESS_E=$(decode 'RQo=')

    local test_result_expected="File \'$FILEPATH_HINT_LIST\' does not exist."
    local test_result_actual=$(show_file_line_count $FILEPATH_HINT_LIST)
    local test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<1> $test_description" "$test_result" $(get_runtime "$test_start_time")


    eval $cmd_solve

    test_result_expected="68 $FILEPATH_HINT_LIST"
    test_result_actual=$(show_file_line_count $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<2> $test_description" "$test_result" $(get_runtime "$test_start_time")

    test_result_expected='1'
    test_result_actual=$(grep -ic "$tmp_solution" $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<3> $test_description" "$test_result" $(get_runtime "$test_start_time")


    # Guess 2:
    test_description='Guess # 2: ⬛⬛⬛⬛⬛.'
    ZAP_LETTERS_INCLUDED_FROM_OUTPUT=false

    local tmp_guess='TFVOQ0gK'
    tmp_guess=$(decode "$tmp_guess") && echo $tmp_guess

    diff_with_feedback "$tmp_solution" "$tmp_guess"
    transcribe "$tmp_guess" $(generate_diff "$tmp_solution" "$tmp_guess") $is_first_guess

    GUESS_X=$(decode 'Q0hMTk9SU1UK')

    eval $cmd_solve

    test_result_expected="18 $FILEPATH_HINT_LIST"
    test_result_actual=$(show_file_line_count $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<4> $test_description" "$test_result" $(get_runtime "$test_start_time")

    test_result_expected='1'
    test_result_actual=$(grep -ic "$tmp_solution" $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<5> $test_description" "$test_result" $(get_runtime "$test_start_time")


    # Guess 3:
    test_description='Guess # 3: ⬛⬛🟩🟨🟩.'

    local tmp_guess='SU1BR0UK'
    tmp_guess=$(decode "$tmp_guess") && echo $tmp_guess

    diff_with_feedback "$tmp_solution" "$tmp_guess"
    transcribe "$tmp_guess" $(generate_diff "$tmp_solution" "$tmp_guess") $is_first_guess

    GUESS_X=$(decode 'Q0hJTE1OT1JTVQo=')
    GUESS_I=$(decode 'QUVHCg==')
    GUESS_P=$(decode 'Rwo=')

    eval $cmd_solve

    test_result_expected="3 $FILEPATH_HINT_LIST"
    test_result_actual=$(show_file_line_count $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<6> $test_description" "$test_result" $(get_runtime "$test_start_time")

    test_result_expected='1'
    test_result_actual=$(grep -ic "$tmp_solution" $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<7> $test_description" "$test_result" $(get_runtime "$test_start_time")
}


test_1060() {
    print_message "[Test # 1060] Placeholder."

    # 1060
    # 2024/05/14
    # tmp_solution='QU1BU1MK'  
    # transcribe 'U09BUkUK' 'YBGBB' true"
    ### missing!!!
    # transcribe 'VVBMSVQK' 'YBBBB' false"

}


print_message "Executing unit tests for the 'Hint Helper' script."
test "$1"
