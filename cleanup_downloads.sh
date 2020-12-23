#!/bin/bash

if [ $# -ne 1 ] | [ -z $1 ]
then
	echo "Please provide a file extension, for example:"
	echo "cleanup_downloads.sh ICA"
	echo "cleanup_downloads.sh rdp"
	exit 1
else
	echo "$1"
fi

eval "EXT=$(echo $1 |  tr '[:upper:]' '[:lower:]' )"

eval "WORKING_DIR=~/Downloads"

echo -e "\nTemporarily switching to:\n$WORKING_DIR\n"
cd $WORKING_DIR

COUNT=`ls -1 *.$EXT 2>/dev/null | wc -l | tr -d ' '`
if [ $COUNT != 0 ]
then
	echo -e "Deleting the following $COUNT .$EXT files:\n"
	ls -ltr | grep -i "\.$EXT"
	rm *.$EXT
	echo -e "\nIt is done.\n"
else
	echo -e "No .$EXT file found.\n"
fi

