#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################

source $(dirname $0)/../scripts/utils.sh
source $(dirname $0)/../tests/test_utils.sh


test() {
    local unit_test_to_run=${1:-0}

    source ../tmp/reset.sh #-
    SKIP_ANAGRAMMER=true

    case $unit_test_to_run in
        0)
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
    local count=$(get_file_line_count "$FILEPATH_PREVIOUS_SOLUTIONS")
    local test_description="[Test # 0] Placeholder for # $count."
    local test_start_time=$(get_time)
    capture_test_result "${FUNCNAME[0]}" "<0> $test_description" "" $(get_runtime "$test_start_time")



    # Guess # 1
    ZAP_LETTERS_INCLUDED_FROM_OUTPUT=true

    tmp_guess_A1='U09BUkUK'
    tmp_guess_A1=$(decode "$tmp_guess_A1") && echo $tmp_guess_A1

    tmp_guess_feedback_A1='BBYYB'
    transcribe "$tmp_guess_A1" "$tmp_guess_feedback_A1" "$ZAP_LETTERS_INCLUDED_FROM_OUTPUT"

    GUESS_X=$(decode "RU9TCg==")
    GUESS_I=$(decode "QVIK")
    GUESS_O=$(decode "QQo=")
    GUESS_P=$(decode "Ugo=")

    local test_result_expected="File \'$FILEPATH_HINT_LIST\' does not exist."
    local test_result_actual=$(show_file_line_count $FILEPATH_HINT_LIST)
    local test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<1> $test_description" "$test_result" $(get_runtime "$test_start_time")

    SKIP_ANAGRAMMER=true #-
    eval $cmd_solve

    test_result_expected="252 $FILEPATH_HINT_LIST"
    test_result_actual=$(show_file_line_count $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<2> $test_description" "$test_result" $(get_runtime "$test_start_time")


    # Guess # 2
    ZAP_LETTERS_INCLUDED_FROM_OUTPUT=false

    tmp_guess_A2='TUlMVFkK'
    tmp_guess_A2=$(decode "$tmp_guess_A2") && echo $tmp_guess_A2

    tmp_guess_feedback_A2='BGBBB'
    transcribe "$tmp_guess_A2" "$tmp_guess_feedback_A2" "$ZAP_LETTERS_INCLUDED_FROM_OUTPUT"

    GUESS_X=$(decode "RUxNT1NUWQo=")
    GUESS_I=$(decode "QUlSCg==")
    GUESS_B=$(decode "SQo=")
    GUESS_O=$(decode "QQo=")
    GUESS_P=$(decode "Ugo=")

    SKIP_ANAGRAMMER=true # -
    eval $cmd_solve

    test_result_expected="6 $FILEPATH_HINT_LIST"
    test_result_actual=$(show_file_line_count $FILEPATH_HINT_LIST)
    test_result=$(compare_test_results "$test_result_expected" "$test_result_actual")
    capture_test_result "${FUNCNAME[0]}" "<3> $test_description" "$test_result" $(get_runtime "$test_start_time")


    # Guess # 3
    tmp_guess_A3='Q0lHQVIK'
    tmp_guess_A3=$(decode "$tmp_guess_A3") && echo $tmp_guess_A3

    tmp_guess_feedback_A3="$FULL_MATCH"
    transcribe "$tmp_guess_A3" "$tmp_guess_feedback_A3" "$ZAP_LETTERS_INCLUDED_FROM_OUTPUT"


    tmp_solution='Q0lHQVIK'
    tmp_solution=$(decode "$tmp_solution") && echo $tmp_solution

    if [ ! -z "$tmp_solution" ]; then
        tmp_guess_B1='Q1JBTkUK'
        tmp_guess_B1=$(decode "$tmp_guess_B1") && echo $tmp_guess_B1


        # Archive
        tmp_solution=$(toLowerCase "$tmp_solution")

        filename='../documentation/WORKBOOK_TRACKER.md'
        echo "| **$count** | -> | | \`$(encode_upperCase $tmp_guess_A1)\`<br>\`$(encode_upperCase $tmp_guess_A2)\`<br>\`$(encode_upperCase $tmp_guess_A3)\` | $(convert_feedback "$tmp_guess_feedback_A1")<br>$(convert_feedback "$tmp_guess_feedback_A2")<br>$(convert_feedback "$tmp_guess_feedback_A3") | \`$(encode_upperCase $tmp_guess_B1)\`<br>\`?\`<br>\`$(encode_upperCase $tmp_solution)\` | $(diff_with_feedback "$tmp_solution" "$tmp_guess_B1")<br>🟧🟧🟧🟧🟧<br>$(convert_feedback "$FULL_MATCH") | 🏆❓🙋🏾‍♀️🎭🤖🪢 |" >> $filename


        # Cleanup
        filename='wordle_enhanced_workbook.txt'
        print_message "Updating '$filename': REMOVE."
        tmp_solution=$(toLowerCase "$tmp_solution")
        grep -c "$tmp_solution" $filename
        tmp_file=$(mktemp)
        # + awk "!/$tmp_solution/" $filename > $tmp_file && mv $tmp_file $filename
        grep -c "$tmp_solution" "$filename"

        filename='rm_workbook_decoded.tmp'
        print_message "Updating '$filename': ADD."
        tmp_solution=$(toLowerCase "$tmp_solution")
        grep -c "$tmp_solution" $filename
        # + echo "$tmp_solution" >> "$filename"
        grep -c "$tmp_solution" $filename
        sort $filename | uniq -c | sort -nr | grep -v 1 # Checking for potential duplicates

        filename=$FILEPATH_PREVIOUS_SOLUTIONS
        print_message "Updating '$filename': ADD."
        tmp_solution=$(encode $tmp_solution)
        grep -c "$tmp_solution" $filename
        # + echo "$tmp_solution" >> "$filename"
        grep -c "$tmp_solution" $filename
        sort $filename | uniq -c | sort -nr | grep -v 1 # Checking for potential duplicates
    fi
}


test_102() {
    local test_start_time=$(get_time)
    local test_description='Repeated Letters: 🟩🟩.'
    capture_test_result "${FUNCNAME[0]}" "<0> $test_description" "" $(get_runtime "$test_start_time")


    tmp_solution='QUdBVEUK'
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
    ZAP_LETTERS_INCLUDED_FROM_OUTPUT=true

    tmp_guess='U09BUkUK'
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
