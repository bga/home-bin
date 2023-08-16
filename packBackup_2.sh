#!/usr/bin/env bash
set -eu -o pipefail

displayUsage() {
	echo -e "$0 ACTION sourceDir backupDir"
	echo -e "create sourceDir backupDir"
	echo -e "\tcreate new base image"
	echo -e "diff sourceDir backupDir"
	echo -e "\tcreate new diff from last image"
	echo -e "decryptZip image [diffImage] zip"
	echo -e "\tdecrypt image + optonal diff to zip file"
}

# -- optios
# from gpg
algos=(twofish aes256 camellia256);

storeExts='.jpg:.jpeg:.jpe:.gif:.png:.pdn:.zip:.rar:.7z:.gz:.apk:.a:.avi:.mp4:.ogg:.djvu:.truecrypt:.mp3'
ignoreMasks='\*/Thumbs.db'
splitSize=2G

storeExts=${storeExts}:${storeExts^^}

askPassword() {
	# password=1234
	local password=$(cloudPassword_2.sh backup)
	echo $password
}

# password=1234
password=$(askPassword)

debugOutput() {
	echo $*
}

log() {
	echo [$(date --date=now '+%Y-%m-%d %H:%M:%S')] $*
}

isoMTime() {
  # echo $(TZ='Etc/UTC' date --date="@$(stat -c %Z $1)" +%Y-%m-%d-%H_%M_%S)
  echo $(TZ='Etc/UTC' date --date=now '+%Y-%m-%d-%H_%M_%S')
}

# TODO escape and replace
getLastWordPipe() {
	awk 'NF>1{print $NF}'
}

cutLastExtPipe() {
	sed -e 's/\.[^.]*$//'
}

cutLastExt() {
	echo "$1" | sed -e 's/\.[^.]*$//'
}

getOutImageFileTmpl() {
	printf $backupDir/image%s "$1"
}

getLastImage() {
	echo $(find "$backupDir" -mindepth 1 -maxdepth 1 -name 'image*' -not -name '*-diff*' | sort | tail -1 | cutLastExtPipe)
}
getLastDiffImage() {
	echo $(find "$backupDir" -mindepth 1 -maxdepth 1 -name 'image*-diff*' | sort | tail -1 | cutLastExtPipe)
}

hashPwd() {
	local pwd=$1
	local salt=packBackup_saltX
	# echo -n $pwd | sha1sum | awk '{ printf "%s", $1 }'
	# [https://github.com/P-H-C/phc-winner-argon2/commit/16d3df698db2486dde480b09a732bf9bf48599f9]
	echo -n $pwd | argon2 $salt -i -t 4 -m 19 -p 2 -l 64 -v 13 -r
}

encPipe=$(
	enc() {
		local cipher=$1
		echo "gpg --batch --compress-algo none -c --cipher-algo $cipher '--passphrase=$(hashPwd ${password}_$cipher)' 2> /dev/null"
	};
	ret=""; for algo in ${algos[@]}; do
		wrap=$(enc $algo)
		ret="$ret | $wrap"
	done;

	# remove extra { " | " } at the start
	echo ${ret:3}
)

decPipe=$(
	dec() {
		local cipher=$1
		echo "gpg -d '--passphrase=$(hashPwd ${password}_$cipher)' 2> /dev/null"
	}
	ret=""; for algo in ${algos[@]}; do
		wrap=$(dec $algo)
		ret="$wrap | $ret"
	done

	# remove extra { " | " } at the end
	echo ${ret:0:-3}
)



splitStdOutToFiles() {
	local outFiles=$1
	echo split -d --bytes=$splitSize - "$outFiles".split
}

archiveToFile() {
	local outFile=$1
	# echo bsdtar -cf - "$sourceDir" > $outFile
	echo zip -r -y -Z bzip2 -UN=UTF8 -x "$ignoreMasks" -n "$storeExts" $outFile "$sourceDir"
}

decryptZipToStdOut() {
	local image=$1
	# zipOut=$2
	echo $(cat <<-__CMD
		cat "$image".split* | $decPipe
		__CMD
)
}

cmdAction=$1; shift

if [ "$cmdAction" == "decryptZip" ] && [ $# -eq 2 -o $# -eq 3 ]; then
	# password=$(askPassword)
	image=$1; shift
	if [ ! -f "$image" ]; then
		echo "$image" should exist and  should be a file
		exit 1
	fi
	image=$(echo "$image" | sed -r 's/\.split[0-9]+*$//')

	diffImage=
	if [ $# -eq 2 ]; then
		diffImage=$1; shift
		diffImage=$(echo "$diffImage" | sed -r 's/\.split[0-9]+*$//')
	fi
	zipOut=$1; shift
	if [ -e "$zipOut" ]; then
		echo
		read -p "$zipOut is exist. Overwrite? [Yn]" -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			exit 0
		fi
	fi

	if [ -z $diffImage ]; then
		log decrypting \"$image\" to \"$zipOut\"
		eval $(decryptZipToStdOut "$image") > "$zipOut"
		log Done
	else
		log decrypting $image + $diffImage  to $zipOut
		eval $(cat <<-__CMD
			xdelta3 -f -d -s <($(decryptZipToStdOut "$image")) <(cat "$diffImage".split* | $decPipe) "$zipOut"
		__CMD
)
		log Done
	fi
elif [ $# -eq 2 ];  then
	# set global config vars
	sourceDir=$1; shift
	if [ ! -d "$sourceDir" ]; then
		echo "$sourceDir" should be a directory
		exit 1
	fi

	backupDir=$1; shift
	if [ ! -d "$backupDir" ]; then
		echo "$backupDir" should be a directory
		exit 1
	fi

	if [ "$cmdAction" == "create" ]; then
		# password=$(askPassword)
		echo ${password:0:2}...${password:(-2)}
		image=$(getOutImageFileTmpl $(isoMTime))
		log creating image \"$image\"
		eval $(cat <<-__CMD
			$(archiveToFile -) | $encPipe | $(splitStdOutToFiles "$image");
		__CMD
	)
		# TODO implement
		# genRecoveryRecord "$image".split* &; pid1=$!
		# saveHashSums "$image".split*; pid2=$!
		# wait $pid1
		# wait $pid2
		log Done
	elif [ "$cmdAction" == "diff" ]; then
		# password=$(askPassword)
		image=$(getLastImage)
		imageDiff="$image"-diff$(isoMTime)
		log using last image $image creating diff $imageDiff
		eval $(cat <<-__CMD
			xdelta3 -0 -e -s <($(decryptZipToStdOut "$image")) <($(archiveToFile -)) | $encPipe | $(splitStdOutToFiles "$imageDiff");
		__CMD
	)
		log Done
	else
		displayUsage
	fi
else
	displayUsage
fi
# elif [ "$cmdAction" == "upload" ]; then
	# echo $(cat <<-__CMD
		# cat $outFile | $encPipe | curl ;
		# bsdtar -cf - "$sourceDir" | gzip -9 | $encPipe > $outFile;
	# __CMD
# )

# find ./aa -not -name *.bin -print | sort | zip -@ - > aa.zip
