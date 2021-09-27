
#Include %A_ScriptDir%\process.ahk

processImageName = %1
Process, Exist, processImageName
pid := ErrorLevel
if(pid != 0) {
  ResumeProcess(pid)
  ExitApp, 0
}
else {
  ExitApp, 1
}


  