:: http://stackoverflow.com/questions/664957/can-i-mask-an-input-text-in-a-bat-file
:: echo off
for /f "delims=" %%i in ('sh -c "read -s -p Password: p; echo $p"') do set password=%%i
echo.
echo on
