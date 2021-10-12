#!/bin/sh
set -eu -o pipefail

displayUsage() {
	echo -e "$0 FILE"
	echo -e "backup FILE"
	echo -e "cp FILE FILE_BASENAME.bak.N.FILE_LAST_EXT"
}

file=$1

[[ $# -lt 1 ]] && displayUsage && exit;
[[ ! -e "$file" ]] && (echo "$file does not exist") && exit 1;

formatBakFilePath() { file=$1; i=$2;
	# echo "$file.bak$i"
	iZeroPadded=000"$i"
	iZeroPadded=${iZeroPadded:(-3)}
	fileName=${file%.*}
	fileLastExt=${file##*.}
	echo "$fileName.bak.$iZeroPadded.$fileLastExt"
}

i=0
while [ -e $(formatBakFilePath "$file" "$i") ]; do
	let i=i+1
done
# echo $(formatBakFilePath "$file" $i)
cp "$file" $(formatBakFilePath "$file" "$i")
