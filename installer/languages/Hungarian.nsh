; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar WorldParty Installer - Language file: Hungarian
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; Translation by Gergely BOR <borg42+ultrastardx at gmail.com>.

!insertmacro LANGFILE_EXT Hungarian

${LangFileString} abort_install "Biztosan megszakítja a telepítést?"
${LangFileString} abort_uninstall "Biztosan megszakítja a program eltávolítását?"
;TODO ${LangFileString} abort_update "Are you sure to abort the update?"
${LangFileString} oninit_running "A telepítés már folyamatban van."
;TODO ${LangFileString} oninit_updating "An update is already running."
${LangFileString} oninit_installagain "Biztos abban, hogy még egyszer telepíteni szeretné?"
${LangFileString} oninit_alreadyinstalled "már telepítve van"
${LangFileString} oninit_closeWorldParty "nem eltávolítható, ha még fut! Kívánja a program bezárását?"
${LangFileString} oninit_updateWorldParty "Kívánja-e a programot frissíteni errõl a helyrõl:"
${LangFileString} oninit_uninstall "Do you want to uninstall the old version? (recommended)"

${LangFileString} update_connect "Új verzió keresése az interneten"
${LangFileString} button_next "Tovább >"
${LangFileString} button_close "Bezárás"
${LangFileString} update_information "Ellenõrizheti, hogy van-e új '${name}'-verzió. Ehhez internetkapcsolat szükséges. Ha van új verzió, az ezt követõen telepíthetõ."
;TODO ${LangFileString} button_check_update "Check"

${LangFileString} delete_components "Also delete the following components:"
${LangFileString} delete_covers "Töröljük a borítókat?"
${LangFileString} delete_highscores "Töröljük a pontszámokat?"
${LangFileString} delete_config "Config?"
${LangFileString} delete_screenshots "Screenshots?"
${LangFileString} delete_playlists "Playlists?"
${LangFileString} delete_songs "Töröljük a dalokat is? WARNING: ALL files within the InstallationDir\songs folder will be removed(!)"

;TODO ${LangFileString} update_noinstallation_online "You have no version installed. The current installer cannot update your version. Check our website ${homepage} for a new version."
;TODO ${LangFileString} update_noinstallation_offline "You have no version installed. The current installer/updater cannot install a version. Check our website ${homepage} for a version."
;TODO ${LangFileString} update_check_offline "Your version $installed_version is up-to-date. The current installer cannot update your version. Visit our project website to get latest news and updates."
${LangFileString} update_check_older "Az Ön gépén telepített verziónál ($installed_version) van már újabb (online_version). Kívánja frissíteni?"
${LangFileString} update_check_equal "Az Ön gépén a legfrissebb verzió ($installed_version) van telepítve. Frissítés nem szükséges."
${LangFileString} update_check_newer "Az Ön gépén telepített verzió ($installed_version) frissebb, mint a jelenlegi kiadás (online_version). Frissítés nem szükséges."
;TODO ${LangFileString} update_check_no "The current updater/installer won't install a version. Check our website ${homepage} for a new version."
${LangFileString} update_check_failed "Az ellenõrzés sikertelen. Kívánja betölteni a program weboldalát, hogy ellenõrizhesse hogy van-e frissítés?"
;TODO ${LangFileString} update_download_success "The download of the new version $online_version succeeded.$\r$\n$\r$\nFinish the update by closing this updater. The new installation will be started right after."
;TODO ${LangFileString} update_download_failed "The download of the new version $online_version failed. The installer could not be downloaded.$\r$\n$\r$\nPlease, visit our website ${homepage} for the new version."
;TODO ${LangFileString} update_download_aborted "The download of the new version $online_version was aborted. Nothing will be updated. Remember, visit our website ${homepage} for latest news and updates."
;TODO ${LangFileString} update_download_invalid_installer "The download of the new version $online_version failed. The downloaded installer was invalid. This can happen if the server/website has some issues, does not exist anymore or is in maintenance mode.$\r$\n$\r$\nPlease, visit our website ${homepage} and download the installer manually."
;TODO ${LangFileString} update_download_none "No version to download selected. The current installer cannot update your version. Check our website ${homepage} for latest news and updates."
;TODO ${LangFileString} update_versions_info "At least one new version of ${name} has been found. Please, select a specific version and choose to update. This version will be downloaded and the installation will be started afterwards."
;TODO ${LangFileString} update_versions_none "None"

;TODO ${LangFileString} update_download_downloading "Downloading %s "
;TODO ${LangFileString} update_download_connecting "Connecting ... "
;TODO ${LangFileString} update_download_sec "sec"
;TODO ${LangFileString} update_download_min "min"
;TODO ${LangFileString} update_download_hour "hour"
;TODO ${LangFileString} update_download_multi "s"
;TODO ${LangFileString} update_download_progress "%dkiB (%d%%) of %dkiB @ %d.%02dkiB/s"
;TODO ${LangFileString} update_download_remaining " (%d %s%s remaining)"
;TODO ${LangFileString} update_download_remain_sec " (1 second remaining)"
;TODO ${LangFileString} update_download_remain_min " (1 minute remaining)"
;TODO ${LangFileString} update_download_remain_hour " (1 hour remaining)"
;TODO ${LangFileString} update_download_remain_secs " (%u seconds remaining)"
;TODO ${LangFileString} update_download_remain_mins " (%u minutes remaining)"
;TODO ${LangFileString} update_download_remain_hours " (%u hours remaining)"

; Welcome Page:

${LangFileString} page_welcome_title_update "Üdvözli Önt az ${name} frissítési varázslója!"
${LangFileString} page_welcome_txt_update "Ez a varázsló végigvezeti Önt az ${name} frissítési folyamatán. Az ${name} egy ingyenes és szabad karaokeprogram, olyan mint a Singstar.$\r$\n$\r$\n${publisher} csapata jó szórakozást kíván!$\r$\n$\r$\nA projekt weboldala:$\n$\r${homepage}$\r$\n$\r$\nTámogatás a fórumunkon:$\n$\r${forum}"
${LangFileString} page_welcome_title "Üdvözli Önt az ${name} telepítési varázslója!"
${LangFileString} page_welcome_txt "Ez a varázsló végigvezeti Önt az ${name} telepítési folyamatán. Az ${name} egy ingyenes és szabad karaokeprogram, olyan mint a Singstar.$\r$\n$\r$\n${publisher} csapata jó szórakozást kíván!$\r$\n$\r$\nA projekt weboldala:$\n$\r${homepage}$\r$\n$\r$\nTámogatás a fórumunkon:$\n$\r${forum}"
${LangFileString} page_un_welcome_title "Üdvözli Önt az ${name} eltávolítási varázslója!"

; Custom Page

${LangFileString} page_settings_subtitle "Adja meg a kedvenc ${name}-beállítását."
;TODO ${LangFileString} page_settings_config_title "${name} Configuration (optional)"
;TODO ${LangFileString} page_settings_config_info "All settings can also be changed in the GUI later."
${LangFileString} page_settings_fullscreen_label "Teljes képernyõs üzemmód:"
;TODO ${LangFileString} page_settings_fullscreen_info "Start game in window or fullscreen?"
${LangFileString} page_settings_language_label "Nyelv:"
;TODO ${LangFileString} page_settings_language_info "Adjust the GUI language."
${LangFileString} page_settings_resolution_label "Felbontás:"
;TODO ${LangFileString} page_settings_resolution_info "Choose screen resolution/window size."
;TODO ${LangFileString} page_settings_tabs_label "Tabs:"
;TODO ${LangFileString} page_settings_tabs_info "Employ a virtual folder structure to show songs?"
;TODO ${LangFileString} page_settings_sorting_label "Sorting:"
;TODO ${LangFileString} page_settings_sorting_info "Select criterion to sort songs."
;TODO ${LangFileString} page_settings_songdir_label "SongDir"
;TODO ${LangFileString} page_settings_songdir_info "Choose additional song directory for ${name}."

; Finish Page:

${LangFileString} page_finish_txt "Az ${name} telepítése sikeresen befejezõdött.$\r$\n$\r$\nHa kíváncsi a legfrissebb hírekre és frissítésekre, kérjük látogassa meg projektünk weboldalát."
${LangFileString} page_finish_linktxt ">>> ${homepage} <<<"
${LangFileString} page_finish_desktop "Tegyünk egy parancsikont az asztalra?"

;unused
;TODO ${LangFileString} page_finish_txt_update "${name} Update has checked for a new version."

; Start Menu and Shortcuts

${LangFileString} sm_shortcut "${name} karaoke"
${LangFileString} sm_uninstall "Eltávolítás"
${LangFileString} sm_website "Weboldal"
${LangFileString} sm_license "Licensz"
${LangFileString} sm_readme "OlvassEl"
${LangFileString} sm_songs "Dalok"
;TODO ${LangFileString} sm_update "Update"
${LangFileString} sm_documentation "Dokumentáció"

${LangFileString} sc_play "Játék"
${LangFileString} sc_desktop "Tegyünk egy parancsikont az asztalra?"

