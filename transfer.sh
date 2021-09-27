fileToUpload=$1
shift
# fileToUploadUnixPath="`cygpath -u ${fileName}`"
fileName=$(basename "${fileToUpload}")
echo ${fileName}
curl   -H "Connection: keep-alive" \
	-H "Accept-Encoding: identity" \
	-H "Accept-Language: en-US" \
	-H "User-Agent: Mozilla/5.0"  \
	--upload-file "${fileToUpload}" "https://transfer.sh/${fileName}" "$@" | (xclip 2> NUL || clip)
# read -p "..."
