set appPath=%1
set exten=%2

ftype MyFileType=%1 "%1"
assoc %2=MyFileType