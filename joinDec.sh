#!/bin/sh
set -eu -o pipefail

spitFiles=$1
outFile=$2
password=$(cloudPassword.sh backup)
# password=1234
echo $password
cat ${spitFiles}* \
	| gpg -d '--passphrase=${password}_camellia256' 2> /dev/null \
	| gpg -d '--passphrase=${password}_aes256' 2> /dev/null \
	| gpg -d '--passphrase=${password}_twofish' 2> /dev/null \
	> "$outFile"
