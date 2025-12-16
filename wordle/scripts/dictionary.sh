#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################

source "$(dirname "$0")/utils.sh"

set -euo pipefail

prepare_dictionary() {
    local filepath_workbook=${1:-''}

    # If a workbook path was provided and is valid, copy it to the enhanced dictionary.
    if [ -n "$filepath_workbook" ] && validate_file_dependency "$filepath_workbook"; then
        cp -- "$filepath_workbook" "$FILEPATH_ENHANCED_DICTIONARY"
        show_file_line_count "$FILEPATH_ENHANCED_DICTIONARY"
        return 0
    fi

    # create temporary files and ensure cleanup on exit/interruption
    local file_dictionary_full
    local file_previous_solutions
    local file_tmp_1
    local file_tmp_2

    file_dictionary_full=$(mktemp) || { print_message "Failed to create temp file"; return 1; }
    file_previous_solutions=$(mktemp) || { cleanup_file "$file_dictionary_full"; print_message "Failed to create temp file"; return 1; }
    file_tmp_1=$(mktemp) || { cleanup_file "$file_dictionary_full" "$file_previous_solutions"; print_message "Failed to create temp file"; return 1; }
    file_tmp_2=$(mktemp) || { cleanup_file "$file_dictionary_full" "$file_previous_solutions" "$file_tmp_1"; print_message "Failed to create temp file"; return 1; }

    trap 'cleanup_file "$file_dictionary_full"; cleanup_file "$file_previous_solutions"; cleanup_file "$file_tmp_1"; cleanup_file "$file_tmp_2"; trap - EXIT' EXIT

    # Download dictionary and previous solutions (fail if curl fails)
    if ! curl -fS -o "$file_dictionary_full" "$FILEPATH_DICTIONARY"; then
        print_message "Failed to download dictionary from $FILEPATH_DICTIONARY"
        return 1
    fi
    validate_file_dependency "$file_dictionary_full" || return 1

    if ! curl -fS -o "$file_previous_solutions" "$FILEPATH_PREVIOUS_SOLUTIONS"; then
        print_message "Failed to download previous solutions from $FILEPATH_PREVIOUS_SOLUTIONS"
        return 1
    fi
    validate_file_dependency "$file_previous_solutions" || return 1

    # Decode full dictionary
    while IFS= read -r line; do
        decode "$line" >> "$file_tmp_1"
    done < "$file_dictionary_full"

    # Decode workbook (encoded to prevent spoilers)
    while IFS= read -r line; do
        decode "$line" >> "$file_tmp_2"
    done < "$file_previous_solutions"

    # Remove previous solutions from the working dictionary.
    # Use grep -Fvx -f to remove exact matches from file_tmp_2 in file_tmp_1
    if ! grep -Fvx -f "$file_tmp_2" "$file_tmp_1" > "$FILEPATH_ENHANCED_DICTIONARY"; then
        print_message "No entries written to $FILEPATH_ENHANCED_DICTIONARY"
        return 1
    fi

    # cleanup handled by trap
    show_file_line_count "$FILEPATH_ENHANCED_DICTIONARY"
}
