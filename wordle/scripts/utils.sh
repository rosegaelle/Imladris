#!/usr/local/bin/bash

#############################################################
# Author: @rosegaelle                                       #
#############################################################


export WORD_LENGTH=5
export CHARACTERS_MAX=26

export LETTER_EXCLUDED='B'
export LETTER_NOT_AT='Y'
export LETTER_AT='G'
tmp=$(printf "%$(echo $WORD_LENGTH)s") && export FULL_MATCH=$(echo ${tmp// /$LETTER_AT}) # printf "$LETTER_AT%.0s" {1..$WORD_LENGTH}
tmp=$(printf "%$(echo $WORD_LENGTH)s") && export FULL_MISS=$(echo ${tmp// /$LETTER_EXCLUDED}) # printf "$LETTER_EXCLUDED%.0s" {1..$WORD_LENGTH}

export FILEPATH_DICTIONARY='https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/assets/dictionary_full.txt'
export FILEPATH_PREVIOUS_SOLUTIONS='https://raw.githubusercontent.com/rosegaelle/Imladris/main/wordle/assets/workbook.txt'
export FILEPATH_ENHANCED_DICTIONARY='dictionary_enhanced.tmp'
export FILEPATH_HINT_LIST='results.tmp'
export FILEPATH_ANAGRAMS='anagrams.tmp'


print_message() {
    local message=${1:-''}
    printf "\n$message\n" > /dev/stderr
}


toLowerCase() {
    local user_input=${1:-''}
    printf '%s' "$user_input" | tr '[:upper:]' '[:lower:]'
}


toUpperCase() {
    local user_input=${1:-''}
    printf '%s' "$user_input" | tr '[:lower:]' '[:upper:]'
}


sanitize_input() {
    local user_input=${1:-''}
    toLowerCase "$user_input" | tr -cd '[:alpha:]'
}


encode() {
    local word=${1:-''}
    if [ -n "$word" ]; then
        toLowerCase "$word" | base64
    fi
}


encode_upperCase() {
    local word=${1:-''}
    if [ -n "$word" ]; then
        toUpperCase "$word" | base64
    fi
}


decode() {
    local word=${1:-''}
    if [ -n "$word" ]; then
        printf '%s' "$word" | base64 -d 2>/dev/null | tr '[:upper:]' '[:lower:]'
    fi
}


validate_file_dependency() {
    local filename=${1:-''}

    if [ ! -n "$filename" ] || [ ! -f "$filename" ]; then
        printf "File '%s' does not exist.\n" "$filename" >&2
        return 1
    fi

    return 0
}


move_file() {
    local current_filepath=${1:-''}
    local new_filename=${2:-''}

    if { validate_file_dependency "$current_filepath"; } && [ -n "$new_filename" ]; then
        mv -- "$current_filepath" "$new_filename" || return 1
    else
        printf "Unable to move file '%s' to '%s'.\n" "$current_filepath" "$new_filename" >&2
        #? return 1
    fi
}


copy_file() {
    local current_filepath=${1:-''}
    local new_filename=${2:-''}

    if { validate_file_dependency "$current_filepath"; } && [ -n "$new_filename" ]; then
        cp -- "$current_filepath" "$new_filename" || return 1
    else
        printf "Unable to copy file '%s' to '%s'.\n" "$current_filepath" "$new_filename" >&2
        #? return 1
    fi
}


empty_or_create_file() {
    local filename=${1:-''}

    if [ -e "$filename" ]; then
        : > "$filename"
    else
        touch "$filename"
    fi
}


cleanup_file() {
    local filename=${1:-''}
    [ -e "$filename" ] && rm -f -- "$filename"
}


is_file_not_empty() {
    local filename=${1:-''}

    validate_file_dependency "$filename" || { echo false; return 0; }

    local lines
    lines=$(wc -l < "$filename" | tr -d ' ')
    if (( lines > 0 )); then
        echo true
    else
        echo false
    fi
}


get_file_line_count() {
    local filename=${1:-''}

    validate_file_dependency "$filename" || return 1
    wc -l < "$filename" | tr -d ' '
}


show_file_line_count() {
    local filename=${1:-''}

    validate_file_dependency "$filename" || return 1
    local count
    count=$(wc -l < "$filename" | tr -d ' ')
    printf "%s %s\n" "$count" "$filename"
}


remove_duplicate_characters() {
    local word=${1:-''}
    ### [ ! -z "$word" ] && echo "$word" | sed -f <(printf 's/%s//2g\n' {A..Z})
    [ ! -z "$word" ] && sort <(fold -w1 <<< "$word") | uniq | tr -d '\n'
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

    if [ -z "$word" ]; then
        echo 0
    else
        echo "${#word}"
    fi
}


get_character_at() {
    local word=${1:-''}
    local start_index=${2:-0}

    if [ -z "$word" ] || [[ $start_index -gt $(get_word_length "$word") ]]; then
        echo ''
    else
        echo "${word:$start_index:1}"
    fi
}


sort_by_rank() {
    local filename_full_list=${1:-''}
    local rank_order=${2:-''}

    validate_file_dependency "$filename_full_list"

    if [[ true == $(is_file_not_empty "$filename_full_list") ]]; then
        declare -A scores
        while read -r word; do
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
    fi
}


get_runtime() {
    local basetime=${1:-''}
    echo "scale=3;($(date +%s000) - ${basetime})" | bc
}


# Credit: @ilkkachu
# https://unix.stackexchange.com/users/170373/ilkkachu
# https://unix.stackexchange.com/a/683183
convert_time() {
    local t=${1:-0}

    t=$((t/1000))
    case $t in
        *.*) tfrac=${t##*.}
             t=${t%%.*}
             ;;
          *) tfrac=0
             ;;
    esac

    d=$((t/60/60/24))
    h=$((t/60/60%24))
    m=$((t/60%60))
    s=$((t%60))

    printf "=> "

    if [ $d -gt 0 ]; then
        [ $d = 1 ] && printf "%d day " $d || printf "%d days" $d
    fi

    if [ $h -gt 0 ]; then
        [ $h = 1 ] && printf "%d hour " $h || printf "%d hours" $h
    fi

    if [ $m -gt 0 ]; then
        [ $m = 1 ] && printf "%d minute " $m || printf "%d minutes" $m
    fi

    if [ $d = 0 ] && [ $h = 0 ] && [ $m = 0 ]; then
        [ $s = 1 ] && printf "%d second" $s || printf "%d seconds" $s
    fi
}


# Output [BYG]{0,5}
convert_feedback() {
    local user_input=${1:-''}

    user_input=$(toUpperCase "$user_input")

    local hint_black='⬛'  # 'U+02B1B'
    local hint_yellow='🟨' # 'U+1F7E8'
    local hint_green='🟩'  # 'U+1F7E9'


    if [[ $WORD_LENGTH -ne $(get_number_of_characters "$user_input") ]]; then
        print_message "'$user_input' must be exactly $WORD_LENGTH characters long!"
        exit 0
    else
        print_message "$user_input"
        local regex="^([BYG]){0,$WORD_LENGTH}$"
        [[ $user_input =~ $regex ]] && echo $user_input | sed "s/[B]/$hint_black/g" | sed "s/[G]/$hint_green/g" | sed "s/[Y]/$hint_yellow/g"
    fi
}


generate_diff() {
    local solution=${1:-''}
    local guess=${2:-''}
    local is_input_encoded=${3:-false}

    if [[ true == "$is_input_encoded" ]]; then
        solution=$(decode "$solution")
        guess=$(decode "$guess")
    fi

    solution=$(toUpperCase $(sanitize_input "$solution"))
    guess=$(toUpperCase $(sanitize_input "$guess"))

    if [ -z "$solution" ] || [ -z "$guess" ]; then
        print_message "Invalid input for the word diff: '$solution' vs. '$guess'!"
        exit 0
    else
        if [[ "$solution" == "$guess" ]]; then
            echo $FULL_MATCH
            exit 0
        fi
    fi

    print_message "$solution\t$(encode "$solution")\t$(encode_upperCase "$solution")\n$guess\t$(encode "$guess")\t$(encode_upperCase "$guess")"

    #??? local letters_in_diff=$(generate_diff <(fold -w1 <<< "$solution") <(fold -w1 <<< "$guess") | awk '/[<>]/{printf $2}')
    local letters_in_diff=$(get_unique_characters $(echo $guess | sed "s/[$solution]//g"))

    local result=$guess
    if [ ! -z "$letters_in_diff" ]; then
        result=$(echo $guess | sed "s/[$letters_in_diff]/0/g")
    fi

    local correct_guesses=''
    for (( i=0; i<$WORD_LENGTH; i++ )); do
        char=$(get_character_at "$solution" "$i")
        [[ $char == $(get_character_at "$guess" "$i") ]] && correct_guesses=$correct_guesses$char && result="${result:0:$i}5${result:((i + 1))}"
    done

    #??? local letters_in_common=$(comm -12 <(fold -w1 <<< $solution | sort -u) <(fold -w1 <<< $result | sort -u) | tr -d '\n')
    local letters_in_common=$(echo $solution | sed "s/[$result]//g")

    local fullmatch=$(echo $FULL_MATCH | sed "s/$LETTER_AT/0/g")
    if [ -z "$letters_in_common" ] && [ "$fullmatch" != "$result" ]; then
        letters_in_common=$(echo $result | sed "s/[^015]//g")
    fi

    letters_in_common=$(echo $solution | sed "s/[$letters_in_common]//g")

    if [ ! -z "$correct_guesses" ]; then
        letters_in_common=$(echo $letters_in_common | sed "s/[$correct_guesses]//1")
    fi

    if [ ! -z "$letters_in_common" ]; then
        while read -r letter_in_common; do
            for (( j=0; j<$(get_character_occurence_count "$solution" "$letter_in_common"); j++ )); do
                result=$(echo $result | sed "s/$letter_in_common/1/")
            done

            result=$(echo $result | sed "s/$letter_in_common/0/g")
        done < <(fold -w1 <<< $(grep -o . <<< "$letters_in_common"))
    fi

    result=$(echo $result | sed "s/[^015]/0/g")

    echo $result | sed "s/[0]/$LETTER_EXCLUDED/g" | sed "s/[1]/$LETTER_NOT_AT/g" | sed "s/[5]/$LETTER_AT/g"
}


diff_with_feedback() {
    local solution=${1:-''}
    local guess=${2:-''}
    local is_input_encoded=${3:-false}

    local result=$(generate_diff "$solution" "$guess" "$is_input_encoded")

    convert_feedback "$result"

    print_message "/usr/local/bin/bash -c \"source ../scripts/utils.sh; transcribe '$(toUpperCase $guess)' '$result' false\"\n" #- debug
}


transcribe() {
    local guess=${1:-''}
    local feedback_received=${2:-''}
    local reset=${3:-false}

    guess=$(toUpperCase $(sanitize_input "$guess"))
    feedback_received=$(toUpperCase $(sanitize_input "$feedback_received"))

    print_message "$guess\t$(encode "$guess")\t$(encode_upperCase "$guess")"
    convert_feedback "$feedback_received"

    if [ -z "$guess" ] || [ -z "$feedback_received" ]; then
        print_message "Invalid input: '$guess' vs. '$feedback_received'!"
        exit 0
    fi

    if [[ $WORD_LENGTH -ne $(get_number_of_characters "$guess") ]] || [[ $WORD_LENGTH -ne $(get_number_of_characters "$feedback_received") ]]; then
        print_message "Input must be exactly $WORD_LENGTH characters long!"
        exit 0
    fi

    feedback_received=$(echo $feedback_received | sed "s/[^BYG]/B/g")

    local hint_yellow='Y'
    local hint_green='G'

    local LETTER_AT_1="$GUESS_A"
    local LETTER_AT_2="$GUESS_B"
    local LETTER_AT_3="$GUESS_C"
    local LETTER_AT_4="$GUESS_D"
    local LETTER_AT_5="$GUESS_E"
    local LETTERS_INCLUDED="$GUESS_I"
    local LETTERS_NOT_AT_1="$GUESS_M"
    local LETTERS_NOT_AT_2="$GUESS_N"
    local LETTERS_NOT_AT_3="$GUESS_O"
    local LETTERS_NOT_AT_4="$GUESS_P"
    local LETTERS_NOT_AT_5="$GUESS_Q"
    local LETTERS_EXCLUDED="$GUESS_X"

    if [[ true == "$reset" ]]; then
        LETTER_AT_1=''
        LETTER_AT_2=''
        LETTER_AT_3=''
        LETTER_AT_4=''
        LETTER_AT_5=''
        LETTERS_INCLUDED=''
        LETTERS_NOT_AT_1=''
        LETTERS_NOT_AT_2=''
        LETTERS_NOT_AT_3=''
        LETTERS_NOT_AT_4=''
        LETTERS_NOT_AT_5=''
        LETTERS_EXCLUDED=''
    fi

    for (( i=0; i<$WORD_LENGTH; i++ )); do
        feedback=$(get_character_at "$feedback_received" "$i")
        character=$(get_character_at "$guess" "$i")

        case "$i" in
            0)
                case "$feedback" in
                    "$hint_green")
                        LETTER_AT_1="$LETTER_AT_1$character"
                        ;;
                    "$hint_yellow")
                        LETTERS_NOT_AT_1="$LETTERS_NOT_AT_1$character"
                        ;;
                    *)
                        LETTERS_EXCLUDED="$LETTERS_EXCLUDED$character"
                esac
                ;;
            1)
                case "$feedback" in
                    "$hint_green")
                        LETTER_AT_2="$LETTER_AT_2$character"
                        ;;
                    "$hint_yellow")
                        LETTERS_NOT_AT_2="$LETTERS_NOT_AT_2$character"
                        ;;
                    *)
                        LETTERS_EXCLUDED="$LETTERS_EXCLUDED$character"
                esac
                ;;
            2)
                case "$feedback" in
                    "$hint_green")
                        LETTER_AT_3="$LETTER_AT_3$character"
                        ;;
                    "$hint_yellow")
                        LETTERS_NOT_AT_3="$LETTERS_NOT_AT_3$character"
                        ;;
                    *)
                        LETTERS_EXCLUDED="$LETTERS_EXCLUDED$character"
                esac
                ;;
            3)
                case "$feedback" in
                    "$hint_green")
                        LETTER_AT_4="$LETTER_AT_4$character"
                        ;;
                    "$hint_yellow")
                        LETTERS_NOT_AT_4="$LETTERS_NOT_AT_4$character"
                        ;;
                    *)
                        LETTERS_EXCLUDED="$LETTERS_EXCLUDED$character"
                esac
                ;;
            4)
                case "$feedback" in
                    "$hint_green")
                        LETTER_AT_5="$LETTER_AT_5$character"
                        ;;
                    "$hint_yellow")
                        LETTERS_NOT_AT_5="$LETTERS_NOT_AT_5$character"
                        ;;
                    *)
                        LETTERS_EXCLUDED="$LETTERS_EXCLUDED$character"
                esac
                ;;
            *)
                ;;
        esac
    done

    LETTERS_INCLUDED=$(echo $LETTERS_INCLUDED$LETTER_AT_1$LETTER_AT_2$LETTER_AT_3$LETTER_AT_4$LETTER_AT_5$LETTERS_NOT_AT_1$LETTERS_NOT_AT_2$LETTERS_NOT_AT_3$LETTERS_NOT_AT_4$LETTERS_NOT_AT_5 | grep -o . | sort -u | tr -d "\n")
    if [ ! -z "$LETTERS_INCLUDED" ]; then
        LETTERS_EXCLUDED=$(echo "$LETTERS_EXCLUDED" | sed "s/[$LETTERS_INCLUDED]//g")
    fi

    LETTER_AT_1=$(remove_duplicate_characters "$LETTER_AT_1")
    LETTER_AT_2=$(remove_duplicate_characters "$LETTER_AT_2")
    LETTER_AT_3=$(remove_duplicate_characters "$LETTER_AT_3")
    LETTER_AT_4=$(remove_duplicate_characters "$LETTER_AT_4")
    LETTER_AT_5=$(remove_duplicate_characters "$LETTER_AT_5")
    LETTERS_INCLUDED=$(remove_duplicate_characters "$LETTERS_INCLUDED")
    LETTERS_NOT_AT_1=$(remove_duplicate_characters "$LETTERS_NOT_AT_1")
    LETTERS_NOT_AT_2=$(remove_duplicate_characters "$LETTERS_NOT_AT_2")
    LETTERS_NOT_AT_3=$(remove_duplicate_characters "$LETTERS_NOT_AT_3")
    LETTERS_NOT_AT_4=$(remove_duplicate_characters "$LETTERS_NOT_AT_4")
    LETTERS_NOT_AT_5=$(remove_duplicate_characters "$LETTERS_NOT_AT_5")
    LETTERS_EXCLUDED=$(remove_duplicate_characters "$LETTERS_EXCLUDED")

    print_message "export GUESS_X='$LETTERS_EXCLUDED'\nexport GUESS_I='$LETTERS_INCLUDED'\nexport GUESS_A='$LETTER_AT_1'\nexport GUESS_B='$LETTER_AT_2'\nexport GUESS_C='$LETTER_AT_3'\nexport GUESS_D='$LETTER_AT_4'\nexport GUESS_E='$LETTER_AT_5'\nexport GUESS_M='$LETTERS_NOT_AT_1'\nexport GUESS_N='$LETTERS_NOT_AT_2'\nexport GUESS_O='$LETTERS_NOT_AT_3'\nexport GUESS_P='$LETTERS_NOT_AT_4'\nexport GUESS_Q='$LETTERS_NOT_AT_5'"
}


alert() {
    local message=${1:-''}

    local quasimodo="echo -e '\a\a\a\a\a'"
    eval $quasimodo

    if [ ! -z "$message" ]; then
        say -v Thomas "$message"
    fi

    eval $quasimodo
}


has_vowel() {
    local word=${1:-''}

    # Though 'Y' is considered a consonnant when at the start of a word,
    # Y-starting words in the Wordle dictionary also happen to include other vowels,
    # Hence why there is no need for additional validation in this case.
    ## https://www.merriam-webster.com/grammar/why-y-is-sometimes-a-vowel-usage
    ## https://github.com/rosegaelle/Imladris/blob/main/wordle/assets/dictionary_full.txt
    if [[ "$word" =~ [AEIOUYaeiouy] ]]; then
        echo true
    else 
        print_message "No vowel found in '$word'."
        echo false
    fi
}
