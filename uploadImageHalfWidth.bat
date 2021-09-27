ping -n 1 127.0.0.1
set imageId=%time::=.%
set tempName="r:\TEMP\uploadImage%imageId%%~x1"
call i_view32.bat %1 /resize=(50p,50p) /aspectratio /resample /convert=%tempName%

:: free working dir (to allow safe eject removable drive)
cd /d r:\TEMP

call uploadImage.bat %tempName%
del %tempName%
