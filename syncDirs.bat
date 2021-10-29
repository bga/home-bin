@echo off

if _%1==_ goto :showHelp 
if %1==--help goto :showHelp 

goto :action

:showHelp
  echo syncs d:\music\ and f:\music\ 
  echo %~nx0 --dry-run d:\music\ f:\ ^| less
  echo %~nx0 d:\music\ f:\
  echo !end folder should has same name
goto :eof

:action
  @echo off
  
  set dryRun= 
  if %1==--dry-run (
    set dryRun=--dry-run
    shift
  )
  
  set fromDir=%1 
  set toDir=%2
  
  call :convertToUnixPath %fromDir%
  set fromDirUnix=%ret%

  call :convertToUnixPath %toDir%
  set toDirUnix=%ret%
  
  rsync --recursive --human-readable --progress --perms --update --inplace --fuzzy --copy-links --copy-dirlinks --times --delete-after "--exclude=[Tt][Hh][Uu][Mm][Bb][Ss].[Dd][Bb]" %dryRun% %fromDirUnix% %toDirUnix% 
  
  goto :eof
  
  :: { r:\aa } to { /r/aa }
  :convertToUnixPath
    set a=%1
    set a=%a::=%
    set a=%a:\=/%
    set a=/%a%
    set ret=%a%
  exit /b
  
