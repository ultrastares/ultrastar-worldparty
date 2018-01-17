; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe WorldParty Uninstaller: Main components
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

; Remove dirs

 RMDir /r "$INSTDIR\plugins"
 RMDir /r "$INSTDIR\themes"
 RMDir /r "$INSTDIR\fonts"
 RMDir /r "$INSTDIR\languages"
 RMDir /r "$INSTDIR\visuals"
 RMDir /r "$INSTDIR\resources"
 RMDir /r "$INSTDIR\sounds"
 RMDir /r "$INSTDIR\webs"
 RMDir /r "$INSTDIR\soundfonts"
 RMDir /r "$INSTDIR\avatars"
 RMDir /r "$INSTDIR\licenses"

; Delete remaining files
 Delete "$INSTDIR\${exe}.exe"
 Delete "$INSTDIR\${exeupdate}.exe"
 Delete "$INSTDIR\Readme.txt"
 Delete "$INSTDIR\screenshots.lnk"
 Delete "$INSTDIR\playlists.lnk"
 Delete "$INSTDIR\config.ini.lnk"
 
 Delete "$INSTDIR\Error.log"
 Delete "$INSTDIR\cover.db"
 Delete "$INSTDIR\avatar.db"

 Delete "$INSTDIR\*.dll"


 StrCpy $0 "$INSTDIR\songs"
 Call un.DeleteIfEmpty 

 StrCpy $0 "$INSTDIR\covers"
 Call un.DeleteIfEmpty

 StrCpy $0 "$INSTDIR\screenshots"
 Call un.DeleteIfEmpty

 StrCpy $0 "$INSTDIR\playlists"
 Call un.DeleteIfEmpty

 ; Clean up AppData

 SetShellVarContext current

 Delete "$APPDATA\WorldParty\Error.log"
 Delete "$APPDATA\WorldParty\cover.db"
 Delete "$APPDATA\WorldParty\avatar.db"
 
 StrCpy $0 "$APPDATA\WorldParty\covers"
 Call un.DeleteIfEmpty

 StrCpy $0 "$APPDATA\WorldParty\songs"
 Call un.DeleteIfEmpty

 StrCpy $0 "$APPDATA\WorldParty\screenshots"
 Call un.DeleteIfEmpty

 StrCpy $0 "$APPDATA\WorldParty\playlists"
 Call un.DeleteIfEmpty

 StrCpy $0 "$APPDATA\WorldParty"
 Call un.DeleteIfEmpty

 SetShellVarContext all

; Self delete:

 Delete "$INSTDIR\${exeuninstall}.exe"

 StrCpy $0 "$INSTDIR"
 Call un.DeleteIfEmpty