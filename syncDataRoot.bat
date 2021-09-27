set srcDriveLetter=%1
set destDriveLetter=%2
cp-blocks.exe --stat --progress %srcDriveLetter%protected.truecrypt %destDriveLetter%protected.truecrypt
touch.exe %destDriveLetter%protected.truecrypt -r %srcDriveLetter%protected.truecrypt
Robocopy.exe %srcDriveLetter% %destDriveLetter% /x /unilog+:r:\datacopyLog.txt /tee /mir /xo /xj /xf protected.truecrypt /xd "System Volume Information"
:: syncSymlinks.rb %srcDriveLetter% %destDriveLetter%
