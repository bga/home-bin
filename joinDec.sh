#!/usr/bin/env bash
set -eu -o pipefail

spitFiles=$1
outFile=$2
password=$(cloudPassword.sh backup)
# password=1234
echo $password
cat ${spitFiles}* \
	| (command -v pv &> /dev/null && pv -s $(du -csb ${spitFiles}* | tail -1 | awk '{print $1}') || cat) \
	| gpg -d '--passphrase=${password}_camellia256' 2> /dev/null \
	| gpg -d '--passphrase=${password}_aes256' 2> /dev/null \
	| gpg -d '--passphrase=${password}_twofish' 2> /dev/null \
	> "$outFile"
