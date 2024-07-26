#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: July 2024                             #
#############################################################



WORD_LENGTH=5

FILEPATH_DICTIONARY='https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/dictionary_full.txt'
FILEPATH_PREVIOUS_SOLUTIONS='https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/workbook.txt'
FILEPATH_ENHANCED_DICTIONARY='dictionary_enhanced.tmp'
FILEPATH_HINT_LIST='results.tmp'



validate_file_dependency() {
    filename=${1:-""}

    if [ ! -f $filename ]; then
        echo "File '$filename' does not exist."
        exit 1
    else
        return 0
    fi
}

cleanup() {
    filename=${1:-""}
    [ -e $filename ] && rm "$filename"
}
