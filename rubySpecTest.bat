@echo off
setlocal EnableDelayedExpansion
set moduleFilePath="%~f1"
:loop
if not exist ".stm" (
  set oldCd="!CD!"
  cd ..
  if not !oldCd!=="!CD!" (
    goto :loop
  )
)
@echo on
ruby\specTest.rb %moduleFilePath%