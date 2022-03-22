#!/bin/sh
set -eu -o pipefail

smdCodeBookLocalPath=/e/books/electronics/books/\!SMD-codes-my.txt

programmPath=$0

print_help() {
	echo "$programmPath code desc"
	echo "add code and desc to local smd code book" 
}

if [ $# -ne 2 -o "$1" = "--help" -o "$1" = "-h" ]; then
	print_help
	exit 0
fi

code=$1
desc=$2

printf "${code}\t${desc}\n" >> "${smdCodeBookLocalPath}"
