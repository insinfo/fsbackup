flutter build windows
cp -Force -r C:\MyDartProjects\fsbackup\build\windows\runner\Release\* C:\MyDartProjects\fsbackup\installer\windows
"C:\Program Files (x86)\NSIS\makensis.exe"  /NOTIFYHWND 921098  "C:\MyDartProjects\fsbackup\installer\windows\install.nsi"