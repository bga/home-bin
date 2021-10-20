#!/bin/sh
set -eu -o pipefail

file=$1
password=$(cloudPassword.sh backup)
# password=1234
echo $password
cat $file \
	| (command -v pv &> /dev/null && pv -s $(du -sb "$file" | awk '{print $1}') || cat) \
	| gpg --batch --compress-algo none -c --cipher-algo twofish '--passphrase=${password}_twofish' 2> /dev/null \
	| gpg --batch --compress-algo none -c --cipher-algo aes256 '--passphrase=${password}_aes256' 2> /dev/null \
	| gpg --batch --compress-algo none -c --cipher-algo camellia256 '--passphrase=${password}_camellia256' 2> /dev/null \
	| split -d --bytes=2G - ${file}.split
