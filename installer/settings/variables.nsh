; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe Un/Installer: Variables
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

; Product Information:

!define VersionStr "16.12"
!define FullVersion "16.12 RC1 Update 2" ; semver compatible. see semver.org

!define installername " Installer"
!define installerexe "WorldParty ${VersionStr} installer"


; generated
!define version "${VersionStr}"
!define meta StrLower($version)


!define name "UltraStar Deluxe WorldParty"
!define publisher "UltraStar España"
!define homepage "http://ultrastar-es.org"

!define exe "WorldParty"
!define exeuninstall "Uninstall"
!define exeupdate "Update"

!define license ".\dependencies\documents\license.txt"
!define music1 ".\dependencies\loop.wav"
!define music2 "$PLUGINSDIR\loop.wav"

; Installer

!define installer_version_path "$LOCALAPPDATA\Temp\WorldParty"
!define installer_exe_path "$LOCALAPPDATA\Temp\WorldPartyupdate.exe"
;!define version_url "http://raw.githubusercontent.com/UltraStar-Deluxe/USDX/release/VERSION"
;!define update_url "https://github.com/UltraStar-Deluxe/USDX/releases/download/%VERSION%/UltraStar.Deluxe_v%VERSIONSTRING%-installer.exe"
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
