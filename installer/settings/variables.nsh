; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe Un/Installer: Variables
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

; Product Information:

!define version "RC 1" ; Make sure version is also set in onInit
!define version2 "16.10"

!define name "UltraStar Deluxe WorldParty"
!define publisher "UltraStar España"
!define homepage "http://ultrastar-es.org"


!define exe "ultrastardx"

!define license ".\dependencies\documents\license.txt"

; Icons

!define img_install "install.ico"
!define img_uninstall "uninstall.ico"

; Header Images

!define img_header "header.bmp" ; Header image (150x57)
!define img_side "side.bmp" ; Side image (162x314)

; Registry for Start menu entries:

!define PRODUCT_NAME "${name} ${version}"
!define PRODUCT_VERSION "${version}"
!define PRODUCT_PUBLISHER "${publisher}"
!define PRODUCT_WEB_SITE "${homepage}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${name} ${version}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; Download URLs for Songs and Themes:

; SONGS

; THEMES
; (removed theme section - currently no additional skins available for this usdx version)
