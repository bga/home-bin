set dir=%1 
set archive=%2 
rar a -r0 -m0 -htb -rr15p -hp -v2000M -t "-msjpg;jpeg;jpe;gif;png;pdn;zip;rar;7z;gz;apk;a;img;avi;mp4;ogg;djvu;truecrypt" -x*\Thumbs.db %dir% %archive%
