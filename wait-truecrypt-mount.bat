:: %~dp0 /l drive ...

call truecrypt %*
:loop
sleep 5
if not exist %2:\ goto loop