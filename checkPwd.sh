#!/bin/sh
set -eu -o pipefail

# [https://habr.com/ru/post/436420/#comment_19627420]
echo -n 'password' | sha1sum | awk '{prefix=substr($1,1,5); reminder=substr($1,6,35); if(system("curl -s https://api.pwnedpasswords.com/range/" prefix "> ./pwhashes.txt")){print "Error"; exit} cmd="cat ./pwhashes.txt | tr [A-Z] [a-z] | grep \"" reminder "\""; cmd | getline result; close(cmd); split(result,arr,":"); if(!length(arr[2])) print "Password not found"; else print "Password found: " arr[2]}'
