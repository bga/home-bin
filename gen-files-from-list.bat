@echo off

set listFile=%1
set outdir=%2

:: # list file format
:: # comment
:: foo https://foo.bar/com # comment
:: bar/file1 https://bar.foo/com1 
:: bar/file2 https://bar.foo/com2

SETLOCAL EnableExtensions EnableDelayedExpansion

for /F "eol=# tokens=1,2" %%a in ( %listFile% ) do ( 
	set url=%%b
	set f=%outdir%\%%a
	
	echo !url! -^> !f!
	
	call :makeDir !f!
	echo !url! > !f!
)

:makeDir
	mkdir "%~dp1" 2>NUL
exit /b
