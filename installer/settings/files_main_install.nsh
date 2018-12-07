; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe WorldParty Installer: Main components
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

; Remove old files from previous versions


RMDir /r "$INSTDIR\Themes"
RMDir /r "$INSTDIR\Skins"
RMDir /r "$INSTDIR\Plugins"
RMDir /r "$INSTDIR\Languages"
RMDir /r "$INSTDIR\Webs"
RMDir /r "$INSTDIR\Avatars"

; Create Directories:

CreateDirectory $INSTDIR\plugins
CreateDirectory $INSTDIR\covers
CreateDirectory $INSTDIR\songs
CreateDirectory $INSTDIR\avatars

${If} $UseAppData == true

  ; Create folders in appdata for current user
  SetShellVarContext current		
  CreateDirectory $UserDataPath
  CreateDirectory $UserDataPath\screenshots
  CreateDirectory $UserDataPath\playlists

  SetOutPath "$INSTDIR"

  CreateShortCut "screenshots.lnk" "$UserDataPath\screenshots"
  CreateShortCut "playlists.lnk" "$UserDataPath\playlists"
  CreateShortCut "config.ini.lnk" "$ConfigIniPath"

  SetShellVarContext all
${EndIf}

; themes, languages, sounds, fonts, visuals dir

SetOutPath "$INSTDIR"

File /r /x .svn /x .gitignore ..\game\covers
File /r /x .svn /x .gitignore ..\game\themes
File /r /x .svn /x .gitignore ..\game\languages
File /r /x .svn /x .gitignore ..\game\sounds
File /r /x .svn /x .gitignore ..\game\fonts
File /r /x .svn /x .gitignore ..\game\resources
File /r /x .svn /x .gitignore ..\game\visuals
File /r /x .svn /x .gitignore ..\game\webs
File /r /x .svn /x .gitignore ..\game\soundfonts
File /r /x .svn /x .gitignore ..\game\avatars
File /r /x .svn /x .gitignore ..\game\licenses

; Root dir:

File ..\game\*.dll
File ..\game\Readme.txt
File ..\game\WorldParty.exe

; Covers dir:

SetOutPath "$INSTDIR\covers"

IfFileExists $INSTDIR\covers\covers.ini +2 0
File ..\game\covers\covers.ini
File "..\game\covers\*.*"

; Plugins dir:

SetOutPath "$INSTDIR\plugins\"
File "..\game\plugins\*.*"

;SetOutPath "$INSTDIR"
