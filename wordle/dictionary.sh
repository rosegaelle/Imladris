#!/bin/bash

#############################################################
# Author: @rosegaelle                                       #
# Last Modified Date: July 2024                             #
#############################################################

source $(dirname $0)/utils.sh


prepare_dictionary() {
    filepath_workbook=${1:-''}

    if [ ! -z "$filepath_workbook" ] && [ ! $(validate_file_dependency $filepath_workbook) ]; then
        cp $filepath_workbook $FILEPATH_ENHANCED_DICTIONARY

    else

        # 1. Ensure the necessary resources files exist before starting.
        file_dictionary_full=$(mktemp)
        curl -o $file_dictionary_full $FILEPATH_DICTIONARY
        validate_file_dependency "$file_dictionary_full"

        file_previous_solutions=$(mktemp)
        curl -o $file_previous_solutions $FILEPATH_PREVIOUS_SOLUTIONS
        validate_file_dependency "$file_previous_solutions"

        # 2. Decode the full dictionary.
        file_tmp_1=$(mktemp)
        while read -r line
        do
            echo $line | base64 -d >> $file_tmp_1
        done < $file_dictionary_full
        cleanup "$file_dictionary_full"



        # 3. Decode the workbook, which was encoded to prevent accidental spoilers.
        file_tmp_2=$(mktemp)
        while read -r line
        do
            echo $line | base64 -d >> $file_tmp_2
        done < $file_previous_solutions
        cleanup "$file_previous_solutions"



        # 4. Remove all previous solutions from the working dictionary.
        cat $file_tmp_2 $file_tmp_1 | sort | uniq -u > $FILEPATH_ENHANCED_DICTIONARY

        cleanup "$file_tmp_1"
        cleanup "$file_tmp_2"
    fi

    wc -l $FILEPATH_ENHANCED_DICTIONARY
}
