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

salt=bga_password_salt

# [https://github.com/P-H-C/phc-winner-argon2/commit/16d3df698db2486dde480b09a732bf9bf48599f9]

eval $(cat <<CMD
  (echo -n $password ; echo -n $email) | argon2 $salt -i -t 4 -m 19 -p 2 -l 16 -v 13 -r | xxd -r -p | base64 | awk '{ printf "%s", substr(\$1, 1, 19) "!" }' | tr '/' '*' $outputStream
CMD
)

# echo $cmd

# echo Ok. Password in clipboard 2>&1

# | cut - -c -19 ; echo -n "!"
# | sed -n '1,19c' -
# | awk '{ printf "%f" substr($1, 1, 19) "!" }'
