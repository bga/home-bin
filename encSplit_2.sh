file=$1
password=$(cloudPassword_2.sh backup)
# password=1234
echo ${password:0:2}...${password:(-2)}
hashPwd() {
	local pwd=$1
	local salt=packBackup_saltX
	# echo -n $pwd | sha1sum | awk '{ printf "%s", $1 }'
	# [https://github.com/P-H-C/phc-winner-argon2/commit/16d3df698db2486dde480b09a732bf9bf48599f9]
	echo -n $pwd | argon2 $salt -i -t 4 -m 19 -p 2 -l 64 -v 13 -r
}

cat $file \
	| gpg --batch --compress-algo none -c --cipher-algo twofish "--passphrase=$(hashPwd ${password}_twofish)" 2> /dev/null \
	| gpg --batch --compress-algo none -c --cipher-algo aes256 "--passphrase=$(hashPwd ${password}_aes256)" 2> /dev/null \
	| gpg --batch --compress-algo none -c --cipher-algo camellia256 "--passphrase=$(hashPwd ${password}_camellia256)" 2> /dev/null \
	| split -d --bytes=2G - ${file}.split
