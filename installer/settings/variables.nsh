; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar WorldParty Un/Installer: Variables
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

; Product Information:

!define VersionStr "21.02"
!define FullVersion "21.02"

!define installername " Installer"
!define installerexe "WorldParty ${VersionStr} installer"


; generated
!define version "${VersionStr}"
!define meta StrLower($version)


!define name "UltraStar WorldParty"
!define publisher "UltraStar España"
!define homepage "https://ultrastar-es.org"
!define forum "https://ultrastar-es.org/foro"
!define wiki "https://github.com/ultrastares/ultrastar-worldparty/wiki"

!define exe "WorldParty"
!define exe_debug "WorldPartyDebug"
!define exeuninstall "Uninstall"

!define license ".\dependencies\documents\license.txt"

; Installer

!define installer_version_path "$LOCALAPPDATA\Temp\WorldParty"
!define installer_exe_path "$LOCALAPPDATA\Temp\WorldPartyupdate.exe"
;!define version_url "https://github.com/ultrastares/ultrastar-worldparty/blob/master/VERSION"
;!define update_url "https://github.com/ultrastares/ultrastar-worldparty/releases/download/%VERSION%/UltraStar.Deluxe.WorldParty_%VERSIONSTRING%-installer.exe"
!define update_mask_online_version "%VERSION%"
!define update_mask_installer_version "%VERSIONSTRING%"

; Icons

!define img_install "install.ico"
!define img_uninstall "uninstall.ico"

; Header Images

!define img_header "header.bmp" ; Header image (150x57)
!define img_side "side.bmp" ; Side image (162x314)

; Registry for Start menu entries:

!define PRODUCT_NAME "${name}"
!define PRODUCT_VERSION "${version}"
!define PRODUCT_PUBLISHER "${publisher}"
!define PRODUCT_WEB_SITE "${homepage}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${name}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_PATH "$PROGRAMFILES\${name}"
