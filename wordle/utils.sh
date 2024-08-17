#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: August 2024.                          #
#############################################################


export WORD_LENGTH=5
export CHARACTERS_MAX=26

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

encode () {
    local word=${1:-''}
    [ ! -z "$word" ] && $(toLowerCase $word) | base64
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


sort_by_rank() {
    local filename_full_list=${1:-''}
    local rank_order=${2:-''}

    #ToDo
}
