
#Include %A_ScriptDir%\ahk\process.ahk

FileAppend, Test, *, UTF-16

processImageName = %1%
Process, Exist, processImageName
pid := ErrorLevel
if(pid != 0) {
  SuspendProcess(pid)
  ExitApp, 0
}
else {
  ExitApp, 1
}


  