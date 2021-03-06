; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "fsBackup"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "Prefeitura de Rio das Ostras"
!define PRODUCT_WEB_SITE "https://www.riodasostras.rj.gov.br"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\fsbackup.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\uninstall.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "..\..\LICENSE"
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\fsbackup.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "PortugueseBR"


; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "install.exe"
InstallDir "$PROGRAMFILES\fsBackup"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd


Section "Visual Studio Runtime"
  SetOutPath "$INSTDIR"
  File "vcredist_2015_2019_x64.exe"
  DetailPrint "Starting Microsoft Visual Studio Runtime Setup..."
  ExecWait "$INSTDIR\vcredist_2015_2019_x64.exe /install /passive"
  Delete "$INSTDIR\vcredist_2015_2019_x64.exe"
  DetailPrint "Visual Studio Runtime is already installed!"
SectionEnd

Section "principal" SEC01
  SetOutPath "$INSTDIR\data"
  SetOverwrite try
  File "data\app.so"
  SetOutPath "$INSTDIR\data\flutter_assets"
  File "data\flutter_assets\AssetManifest.json"
  SetOutPath "$INSTDIR\data\flutter_assets\assets\icons"

  File "data\flutter_assets\assets\icons\menu_dashbord.svg"
  File "data\flutter_assets\assets\icons\menu_task.svg"
  File "data\flutter_assets\assets\icons\menu_tran.svg"
  
  SetOutPath "$INSTDIR\data\flutter_assets\assets\images"  

  File "data\flutter_assets\assets\images\app_icon.ico"
  File "data\flutter_assets\assets\images\app_icon.png"
  File "data\flutter_assets\assets\images\install.ico"
  File "data\flutter_assets\assets\images\uninstall.ico"
  File "data\flutter_assets\assets\images\logo_small.png"
  File "data\flutter_assets\assets\images\logo.png"

  SetOutPath "$INSTDIR\data\flutter_assets\assets\mongodb"
  File "data\flutter_assets\assets\mongodb\cratedb.js"
  File "data\flutter_assets\assets\mongodb\mongo.exe"
  File "data\flutter_assets\assets\mongodb\mongod.cfg"
  File "data\flutter_assets\assets\mongodb\mongod.exe"
  File "data\flutter_assets\assets\mongodb\mongos.exe"
 
  SetOutPath "$INSTDIR\data\flutter_assets"
  File "data\flutter_assets\FontManifest.json"
  SetOutPath "$INSTDIR\data\flutter_assets\fonts"
  File "data\flutter_assets\fonts\MaterialIcons-Regular.otf"
  SetOutPath "$INSTDIR\data\flutter_assets"
  File "data\flutter_assets\kernel_blob.bin"
  File "data\flutter_assets\NOTICES.Z"
  SetOutPath "$INSTDIR\data\flutter_assets\packages\cupertino_icons\assets"
  File "data\flutter_assets\packages\cupertino_icons\assets\CupertinoIcons.ttf"
  SetOutPath "$INSTDIR\data"
  File "data\icudtl.dat"
  SetOutPath "$INSTDIR"
  File "flutter_windows.dll"
  File "fsbackup.exe"
  CreateDirectory "$SMPROGRAMS\fsBackup"
  CreateShortCut "$SMPROGRAMS\fsBackup\fsBackup.lnk" "$INSTDIR\fsbackup.exe"
  CreateShortCut "$DESKTOP\fsBackup.lnk" "$INSTDIR\fsbackup.exe"
  CreateShortCut "$SMPROGRAMS\fsBackup.lnk" "$INSTDIR\fsbackup.exe"
  File "pscp.dll"
  File "pthreadVC3.dll"
  File "ssh.dll"
  File "url_launcher_windows_plugin.dll"
  File "vcredist_2015_2019_x64.exe"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\fsBackup\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\fsBackup\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\fsbackup.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\fsbackup.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) foi removido com sucesso do seu computador."
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Tem certeza que quer remover completamente $(^Name) e todos os seus componentes?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\vcredist_2015_2019_x64.exe"
  Delete "$INSTDIR\url_launcher_windows_plugin.dll"
  Delete "$INSTDIR\ssh.dll"
  Delete "$INSTDIR\pthreadVC3.dll"
  Delete "$INSTDIR\pscp.dll"
  Delete "$INSTDIR\fsbackup.exe"
  Delete "$INSTDIR\flutter_windows.dll"
  Delete "$INSTDIR\data\icudtl.dat"
  Delete "$INSTDIR\data\flutter_assets\packages\cupertino_icons\assets\CupertinoIcons.ttf"
  Delete "$INSTDIR\data\flutter_assets\NOTICES.Z"
  Delete "$INSTDIR\data\flutter_assets\kernel_blob.bin"
  Delete "$INSTDIR\data\flutter_assets\fonts\MaterialIcons-Regular.otf"
  Delete "$INSTDIR\data\flutter_assets\FontManifest.json"
  Delete "$INSTDIR\data\flutter_assets\assets\mongodb\vcredist_x64.exe"
  Delete "$INSTDIR\data\flutter_assets\assets\mongodb\mongos.exe"
  Delete "$INSTDIR\data\flutter_assets\assets\mongodb\mongod.exe"
  Delete "$INSTDIR\data\flutter_assets\assets\mongodb\mongod.cfg"
  Delete "$INSTDIR\data\flutter_assets\assets\mongodb\mongo.exe"
  Delete "$INSTDIR\data\flutter_assets\assets\mongodb\cratedb.js"

  Delete "data\flutter_assets\assets\icons\menu_dashbord.svg"
  Delete "data\flutter_assets\assets\icons\menu_task.svg"
  Delete "data\flutter_assets\assets\icons\menu_tran.svg"  
  
  Delete "data\flutter_assets\assets\images\app_icon.ico"
  Delete "data\flutter_assets\assets\images\app_icon.png"
  Delete "data\flutter_assets\assets\images\install.ico"
  Delete "data\flutter_assets\assets\images\uninstall.ico"
  Delete "data\flutter_assets\assets\images\logo_small.png"
  Delete "data\flutter_assets\assets\images\logo.png"


  Delete "$INSTDIR\data\flutter_assets\AssetManifest.json"
  Delete "$INSTDIR\data\app.so"

  Delete "$SMPROGRAMS\fsBackup\Uninstall.lnk"
  Delete "$SMPROGRAMS\fsBackup\Website.lnk"
  Delete "$SMPROGRAMS\fsBackup.lnk"
  Delete "$DESKTOP\fsBackup.lnk"
  Delete "$SMPROGRAMS\fsBackup\fsBackup.lnk"

  RMDir "$SMPROGRAMS\fsBackup"
  RMDir "$INSTDIR\data\flutter_assets\packages\cupertino_icons\assets"
  RMDir "$INSTDIR\data\flutter_assets\fonts"
  RMDir "$INSTDIR\data\flutter_assets\assets\mongodb"
  RMDir "$INSTDIR\data\flutter_assets\assets\images"
  RMDir "$INSTDIR\data\flutter_assets\assets\icons"
  RMDir "$INSTDIR\data\flutter_assets"
  RMDir "$INSTDIR\data"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd