#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################


export WORD_LENGTH=5
export CHARACTERS_MAX=26
tmp=$(printf "%$(echo $WORD_LENGTH)s") && export FULL_MATCH=$(echo ${tmp// /G}) # printf 'G%.0s' {1..5}

export FILEPATH_DICTIONARY='https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/dictionary_full.txt'
export FILEPATH_PREVIOUS_SOLUTIONS='https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/workbook.txt'
export FILEPATH_ENHANCED_DICTIONARY='dictionary_enhanced.tmp'
export FILEPATH_HINT_LIST='results.tmp'
export FILEPATH_ANAGRAMS='anagrams.tmp'


print_message() {
    local message=${1:-''}
    printf "\n$message\n" > /dev/stderr
}


toLowerCase() {
    local user_input=${1:-''}
    echo $user_input | tr '[:upper:]' '[:lower:]'
}


toUpperCase() {
    local user_input=${1:-''}
    echo $user_input | tr '[:lower:]' '[:upper:]'
}


sanitize_input() {
    local user_input=${1:-''}
    echo $(toLowerCase "$user_input") | tr -cd '[:alpha:]'
}

encode() {
    local word=${1:-''}
    [ ! -z "$word" ] && echo $(toLowerCase $word) | base64
}

encode_upperCase() {
    local word=${1:-''}
    [ ! -z "$word" ] && echo $(toUpperCase $word) | base64
}


decode() {
    local word=${1:-''}
    [ ! -z "$word" ] && toLowerCase $(echo "$word" | base64 -d)
}


validate_file_dependency() {
    local filename=${1:-''}

    if [ ! -f $filename ]; then
        echo "File '$filename' does not exist."
        exit 1
    else
        return 0
    fi
}


empty_or_create_file() {
    local filename=${1:-''}

    if [ -e "$filename" ]; then
        true > "$filename"
    else
        touch "$filename"
    fi
}


cleanup_file() {
    local filename=${1:-''}
    [ -e "$filename" ] && $(rm "$filename")
}


is_file_not_empty() {
    local filename=${1:-''}

    validate_file_dependency "$filename"

    if (( $(wc -l < "$filename") > 0 )); then
        echo true
    else
        echo false
    fi
}


get_file_line_count() {
    local filename=${1:-''}

    validate_file_dependency "$filename"
    echo $(wc -l < "$filename")
}


show_file_line_count() {
    local filename=${1:-''}

    validate_file_dependency "$filename"
    echo $(wc -l "$filename")
}


get_unique_characters() {
    local word=${1:-''}

    if [ -z "$word" ]; then
        echo ''
    else
        unique_characters=$(echo "$word" | grep -o . | sort -u | tr -d '\n' | tr -d ' ')
        echo "$unique_characters"
    fi
}


get_number_of_characters() {
    local word=${1:-''}

    if [ -z "$word" ]; then
        echo 0
    else
        num_char=$(echo -n "$word" | wc -c | tr -d ' ')
        echo "$num_char"
    fi
}


get_character_occurence_count() {
    local word=${1:-''}
    local char=${2:-''}

    if [ -z "$word" ] || [ -z "$char" ]; then
        echo 0
    else
        char_count=$(echo $word | tr -cd "$char" | wc -c | tr -d ' ')
        echo "$char_count"
    fi
}


get_word_length() {
    local word=${1:-''}

    if [ -z "$word" ] ; then
        echo 0
    else
        echo "${#word}"
    fi
}


get_character_at() {
    local word=${1:-''}
    local start_index=${2:-0}

    if [ -z "$word" ] || [[ $start_index -gt $(get_word_length "$word") ]] ; then
        echo ''
    else
        echo "${word:$start_index:1}"
    fi
}


sort_by_rank() {
    local filename_full_list=${1:-''}
    local rank_order=${2:-''}

    validate_file_dependency "$filename_full_list"

    declare -A scores
    while read -r word
    do
        score=10

        for (( i=0; i<${#rank_order} ; i++ )); do
            if echo "$word" | grep -q $(get_character_at "$rank_order" "$i"); then
                score=$(( score + 10 * $((${#rank_order} - i )) ))
            fi
        done

        scores+=([$word]=$score)
    done < "$filename_full_list"

    rankings="$(typeset -p scores)"
    echo "${rankings##*(}" | sed -e 's/)//g' | sed -e 's/\[/;\n/g' | sed -e 's/\]=/: /g' | sed -e 's/"//g' | awk -F= '!/ 0;?/ {print $0}' | sort -t: -k 2 -r | cut -d" " -f1 | xargs | sed -e 's/;//g' | sed -e 's/:/\n/g' | tr -d ' ' | awk 'NF' > $filename_full_list
}


get_runtime() {
    local basetime=${1:-''}
    echo "scale=3;($(date +%s000) - ${basetime})" | bc
}


# Output [BGY]{0,5}
convert_feedback() {
    local user_input=${1:-''}

    user_input=$(toUpperCase "$user_input")

    local hint_black='⬛'  # 'U+02B1B'
    local hint_green='🟩'  # 'U+1F7E9'
    local hint_yellow='🟨' # 'U+1F7E8'


    if [[ $WORD_LENGTH -ne $(get_number_of_characters "$user_input") ]]; then
        print_message "'$user_input' must be at least $WORD_LENGTH characters long!."
    else
        print_message "$user_input"
        local regex="^([BGY]){0,$WORD_LENGTH}$"
        [[ $user_input =~ $regex ]] && echo $user_input | sed "s/[B]/$hint_black/g" | sed "s/[G]/$hint_green/g" | sed "s/[Y]/$hint_yellow/g"
    fi
}

diff() {
    local solution=${1:-''}
    local guess=${2:-''}
    local is_input_encoded=${3:-false}

    if [[ true == "$is_input_encoded" ]]; then
        solution=$(decode "$solution")
        guess=$(decode "$guess")
    fi

    solution=$(toUpperCase $(sanitize_input "$solution"))
    guess=$(toUpperCase $(sanitize_input "$guess"))

    if [ -z "$solution" ] || [ -z "$guess" ] ; then
        print_message "Invalid input for the word diff: '$solution' vs. '$guess'!"
        exit 0
    else
        if [[ "$solution" == "$guess" ]] ; then
            echo $FULL_MATCH
            exit 0
        fi
    fi

    print_message "$solution\t$(encode "$solution")\t$(encode_upperCase "$solution")\n$guess\t$(encode "$guess")\t$(encode_upperCase "$guess")"

    #??? local letters_in_diff=$(diff <(fold -w1 <<< "$solution") <(fold -w1 <<< "$guess") | awk '/[<>]/{printf $2}')
    local letters_in_diff=$(get_unique_characters $(echo $guess | sed "s/[$solution]//g"))

    local result=$guess
    if [ ! -z "$letters_in_diff" ] ; then
        result=$(echo $guess | sed "s/[$letters_in_diff]/0/g")
    fi

    for (( i=0; i<$WORD_LENGTH; i++ )); do
        [[ $(get_character_at "$solution" "$i") == $(get_character_at "$guess" "$i") ]] && result="${result:0:$i}5${result:((i + 1))}"
    done

    #??? local letters_in_common=$(comm -12 <(fold -w1 <<< $solution | sort -u) <(fold -w1 <<< $result | sort -u) | tr -d '\n')
    local letters_in_common=$(echo $result | sed "s/[$(echo $result | sed "s/[$solution]//g")]//g")

    if [ ! -z "$letters_in_common" ] ; then
        while read -r letter_in_common; do
            for (( j=0; j<=$(get_character_occurence_count "$result" "$letter_in_common"); j++ )); do
                result=$(echo $result | sed "s/$letter_in_common/1/")
            done

            result=$(echo $result | sed "s/$letter_in_common/0/g")
        done < <(fold -w1 <<< $(grep -o . <<< "$letters_in_common"))
    fi

    echo $result | sed "s/[0]/B/g" | sed "s/[1]/Y/g" | sed "s/[5]/G/g"
}


diff_with_feedback() {
    local solution=${1:-''}
    local guess=${2:-''}
    local is_input_encoded=${3:-false}

    local result=$(diff "$solution" "$guess" "$is_input_encoded")

    convert_feedback "$result"
}


alert() {
    local message=${1:-''}

    local quasimodo="echo -e '\a\a\a\a\a'"
    eval $quasimodo

    if [ ! -z "$message" ] ; then
        say -v Thomas "$message"
    fi

    eval $quasimodo
}
