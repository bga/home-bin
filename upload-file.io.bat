::@echo off
set fileToUpload=%~1
set fileNameForUrl=%~nx1
set "fileNameForUrl=%fileNameForUrl: =-%"
curl -F "file=@%fileToUpload%" -s -w "\n"  https://file.io | jq --raw-output .link | (xclip 2> NUL || clip)
