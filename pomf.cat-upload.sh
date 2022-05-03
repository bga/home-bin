#!/usr/bin/env bash
set -eu -o pipefail

fileToPost=$1

postUrl="https://pomf.cat/upload.php"
return_url='http://a.pomf.cat'

echoErr() {
	echo "$@" 2>&1 
}

if [ $# -eq 0 ]; then
	echoErr "Usage: 0x0.st fileToPost\n"
	exit 1
fi


if [ ! -f "$fileToPost" ]; then
	echoErr "File ${fileToPost} not found"
	exit 1
fi

RESPONSE=$(curl -# -k -F "files[]=@${fileToPost}" "${postUrl}")
# RESPONSE='{"success":true,"files":[{"hash":"xxc8d1b1b4b0abee53cb3b407075928bdead5131","name":"sch.png","url":"xxxxxx.png","size":116022}]}'

if [ $(echo "$RESPONSE" | jq .success) != true ]; then
  echoErr "fail"
fi

resultUrl=$return_url/$(echo "$RESPONSE" | jq -r .files[0].url)
echo "${resultUrl}" | clip # to clipboard
echo "${resultUrl}"  # to terminal
