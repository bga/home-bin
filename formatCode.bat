setlocal
set files=%*
astyle ^
  --style=java ^
  ^
  --indent=tab ^
  --lineend=linux ^
  --fill-empty-lines ^
  ^
  --pad-comma ^
  --pad-oper ^
  --unpad-paren ^
  ^
  --align-pointer=type ^
  --align-reference=type ^
  ^
  --add-braces ^
  --break-closing-braces ^
  --attach-closing-while ^
  --attach-extern-c ^
  --attach-inlines ^
  --attach-return-type ^
  ^
  --indent-switches ^
  --indent-labels ^
  --indent-preproc-block ^
  --indent-col1-comments ^
  %files%
::  --convert-tabs ^
  
endlocal
