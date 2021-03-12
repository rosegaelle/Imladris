#!/bin/bash


print_usage() {
        printf "Usage: $0 [-d directory_to_update] -e file_extension\n"
	exit 1
}

if [ $# -lt 2 ] | [ $# -gt 4 ]
then
	print_usage
else
	WORKING_DIRECTORY='' # optional parameter. Default value is local dir.
	FILE_EXT=''

	while getopts ':d:e:' flag; do
	case "${flag}" in
		d) eval WORKING_DIRECTORY="$OPTARG";;
		e) eval FILE_EXT="$OPTARG";;
		:) echo "Missing argument for option -$OPTARG"; print_usage;;
		\?) echo "Unknown option -$OPTARG"; print_usage;;
		*) print_usage;;
	esac
	done
fi

if [[ -z "${FILE_EXT//}" ]]
then
	print_usage
else
	eval "FILE_EXT=$(echo $FILE_EXT |  tr '[:upper:]' '[:lower:]' )"

	if [[ -z "${WORKING_DIRECTORY//}" ]]
	then
		eval "WORKING_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )""
		printf "$WORKING_DIRECTORY\n"
	else
		if [ ! -d $WORKING_DIRECTORY ]
		then
			printf "\nError: No such directory:\n$WORKING_DIRECTORY\n"
                        exit 1
		else
			printf "Temporarily switching to:\n$WORKING_DIRECTORY\n"
			cd $WORKING_DIRECTORY
		fi
	fi
fi

COUNT=`ls -1 *.$FILE_EXT 2>/dev/null | wc -l | tr -d ' '`
if [ $COUNT -eq 0 ]
then
	printf "No .$FILE_EXT file found.\n"
else
	printf "\nDeleting the following %s:\n" "$([ $COUNT -gt 1 ] && echo "$COUNT .$FILE_EXT files" || echo "file")"
	ls -ltr | grep -i "\.$FILE_EXT"
	rm *.$FILE_EXT
	printf "\n#kthxbai.\n"
fi

