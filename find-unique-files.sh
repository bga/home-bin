#!/usr/bin/env bash
set -eu -o pipefail

help="cmd jdupesExtraArgs dir1 dir2"

if [ "$#" -lt 2 ]; then
	echo $help 2>&1
	exit 1
fi

DIR1=${@: -2 : 1}
DIR2=${@: -1}
jdupesExtraArgs=${@: 1 : (( $# - 2 ))}

comm -23 \
	<(find "$DIR1" "$DIR2" -type f | sort) \
	<(jdupes -r "$jdupesExtraArgs" "$DIR1" "$DIR2"  | xargs -d $'\n' cygpath -u {}\; | awk -v p1="$DIR1" -v p2="$DIR2" '$0 ~ p1 && $0 ~ p2'  RS="\n\n" ORS="\n\n" | sort)
