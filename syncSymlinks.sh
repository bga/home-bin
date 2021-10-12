#!/bin/sh
set -eu -o pipefail

srcDir=$1 
srcDir=${srcDir%/} 
# srcDir
destDir=$2
destDir=${destDir%/} 

export MSYS=winsymlinks:nativestrict

echoErr() {
	echo "$*" 1>&2
}
echoUser() {
	echo "$*"
}

lnRel_type() { target=$1;
	if [ -f "$destTarget" ]; then
		echo -n ""
	fi
	if [ -d "$destTarget" ]; then
		echo -n //d
	fi
}

# lnRelDir /x/p/projecr/lib/!cpp p/!cpp //d
lnRel() { link=$1; target=$2; type=$3
	cmd //c mklink "$type" "$(cygpath -w "$link")" \\"$(cygpath -w "$target")"
}

if [ ! -d "$srcDir" ]; then
	echoErr "$srcDir" is not dir
	exit 1
fi
if [ ! -d "$destDir" ]; then
	echoErr "$destDir" is not dir
	exit 1
fi

echo $srcDir
for src in $(find "$srcDir" -type l); do
	target=$(readlink "$src" | sed -E -e 's:^/c/::')
	srcRel=${src#"$srcDir"}
	targetRel=${target#"$srcDir"/}
	dest=$destDir$srcRel
	destTarget=$destDir/$targetRel
	echoUser $dest "->" $targetRel
	# echo $(lnRelDir "$dest" "$targetRel") 
	if [ ! -e "$destTarget" ]; then
		echoErr "$destTarget" does not exist
	else
		lnRel "$dest" "$targetRel" $(lnRel_type $"$destTarget")
	fi
done;
