#!/bin/sh
set -eu -o pipefail

# outputStream=" 1>&2"
outputStream=" "
if [[ $1 == "--clipboard" ]]; then
  outputStream=' | ( xclip 2> /dev/null || clip )'
  shift
fi

email=$1
# password=1234
echo Generating password for $email 1>&2
read -s -p Password: password; # echo $password
printf "\n" 1>&2

# eval "(echo -n $password ; echo -n $email) | sha1sum  | awk '{ printf \"%s\", \$1 }' | xxd -r -p | base64 | awk '{ printf \"%s\", substr(\$1, 1, 19) \"!\" }' $outputStream"

eval $(cat <<CMD
  (echo -n $password ; echo -n $email) | sha1sum  | awk '{ printf "%s", \$1 }' | xxd -r -p | base64 | awk '{ printf "%s", substr(\$1, 1, 19) "!" }' | tr '/' '*' $outputStream
CMD
)

# echo $cmd

# echo Ok. Password in clipboard 2>&1

# | cut - -c -19 ; echo -n "!"
# | sed -n '1,19c' -
# | awk '{ printf "%f" substr($1, 1, 19) "!" }'
