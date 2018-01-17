; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe WorldParty Installer - Language file: English
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

!insertmacro LANGFILE_EXT English

${LangFileString} abort_install "Are you sure to abort installation?"
${LangFileString} abort_uninstall "Are you sure to abort uninstallation?"
${LangFileString} abort_update "Are you sure to abort the update?"
${LangFileString} oninit_running "The installer is already running."
${LangFileString} oninit_updating "An update is already running."
${LangFileString} oninit_installagain "Are you sure you want to install it again?"
${LangFileString} oninit_alreadyinstalled "is already installed"
${LangFileString} oninit_closeWorldParty "cannot be uninstalled while its running! Do you want to close it?"
${LangFileString} oninit_updateWorldParty "Do you want to update the installation from:"
${LangFileString} oninit_uninstall "Do you want to uninstall the old version? (recommended)"

${LangFileString} update_connect "Establish internet connection and check for new version"
${LangFileString} button_next "Next >"
${LangFileString} button_close "Close"

${LangFileString} delete_components "Also delete the following components:"
${LangFileString} delete_covers "Cover"
${LangFileString} delete_highscores "Highscores"
${LangFileString} delete_config "Config"
${LangFileString} delete_screenshots "Screenshots"
${LangFileString} delete_playlists "Playlists"
${LangFileString} delete_songs "Remove songs? WARNING: ALL files within the InstallationDir\songs folder will be removed(!)"

${LangFileString} update_information "You can check if a new version of '${name}' is available. Thereto an internet connection will be established. If a new version is found, it can be installed afterwards."
${LangFileString} button_check_update "Check"

${LangFileString} update_noinstallation_online "You have no version installed. The current installer cannot update your version. Check our website ${homepage} for a new version."
${LangFileString} update_noinstallation_offline "You have no version installed. The current installer/updater cannot install a version. Check our website ${homepage} for a version."
${LangFileString} update_check_offline "Your version $installed_version is up-to-date. The current installer cannot update your version. Visit our project website to get latest news and updates."
${LangFileString} update_check_older "Your version $installed_version is outdated. The new version $online_version of ${name} is available. Choose your option:"
${LangFileString} update_check_equal "Your currently installed version $installed_version is up-to-date. No update needed."
${LangFileString} update_check_newer "Your installed version $installed_version is newer than the $\r$\ncurrent release version $online_version of ${name}. No update needed."
${LangFileString} update_check_no "The current updater/installer won't install a version. Check our website ${homepage} for a new version."
${LangFileString} update_check_failed "The check for a new version failed. Check our website ${homepage} for a new version and manually download a new version."
;${LangFileString} update_download_success "The download of the new version $online_version succeeded.$\r$\n$\r$\nFinish the update by closing this updater. The new installation will be started right after."
;${LangFileString} update_download_failed "The download of the new version $online_version failed. The installer could not be downloaded.$\r$\n$\r$\nPlease, visit our website ${homepage} for the new version."
;${LangFileString} update_download_aborted "The download of the new version $online_version was aborted. Nothing will be updated. Remember, visit our website ${homepage} for latest news and updates."
;${LangFileString} update_download_invalid_installer "The download of the new version $online_version failed. The downloaded installer was invalid. This can happen if the server/website has some issues, does not exist anymore or is in maintenance mode.$\r$\n$\r$\nPlease, visit our website ${homepage} and download the installer manually."
;${LangFileString} update_download_none "No version to download selected. The current installer cannot update your version. Check our website ${homepage} for latest news and updates."
;${LangFileString} update_versions_info "At least one new version of ${name} has been found. Please, select a specific version and choose to update. This version will be downloaded and the installation will be started afterwards."
${LangFileString} update_versions_none "None"

${LangFileString} update_download_downloading "Downloading %s "
${LangFileString} update_download_connecting "Connecting ... "
${LangFileString} update_download_sec "sec"
${LangFileString} update_download_min "min"
${LangFileString} update_download_hour "hour"
${LangFileString} update_download_multi "s"
${LangFileString} update_download_progress "%dkiB (%d%%) of %dkiB @ %d.%02dkiB/s"
${LangFileString} update_download_remaining " (%d %s%s remaining)"
${LangFileString} update_download_remain_sec " (1 second remaining)"
${LangFileString} update_download_remain_min " (1 minute remaining)"
${LangFileString} update_download_remain_hour " (1 hour remaining)"
${LangFileString} update_download_remain_secs " (%u seconds remaining)"
${LangFileString} update_download_remain_mins " (%u minutes remaining)"
${LangFileString} update_download_remain_hours " (%u hours remaining)"

; Welcome Page:

${LangFileString} page_welcome_title_update "Welcome to the ${name} Update Wizard"
${LangFileString} page_welcome_txt_update "This wizard will guide you through the Update process of ${name}. ${name} is a free open source Karaoke game, which can be compared with Singstar.$\r$\n$\r$\nThe ${publisher} wishes you fun.$\r$\n$\r$\nProject website:$\r$\n${homepage}$\r$\n$\r$\nSupport Forum:$\n$\r${forum}"
${LangFileString} page_welcome_title "Welcome to the ${name} Setup Wizard"
${LangFileString} page_welcome_txt "This wizard will guide you through the Installation of ${name}. ${name} is a free open source Karaoke game, which can be compared with Singstar.$\r$\n$\r$\nThe ${publisher} wishes you fun.$\r$\n$\r$\nProject website:$\r$\n${homepage}$\r$\n$\r$\nSupport Forum:$\r$\n${forum}"
${LangFileString} page_un_welcome_title "Welcome to the ${name} uninstall wizard"

; Custom Page

${LangFileString} page_settings_subtitle "Specify your favorite settings for ${name}."
${LangFileString} page_settings_config_title "${name} Configuration (optional)"
${LangFileString} page_settings_config_info "All settings can also be changed in the GUI later."
${LangFileString} page_settings_fullscreen_label "Fullscreen Mode:"
${LangFileString} page_settings_fullscreen_info "Start game in window or fullscreen?"
${LangFileString} page_settings_language_label "Language:"
${LangFileString} page_settings_language_info "Adjust the GUI language."
${LangFileString} page_settings_resolution_label "Resolution:"
${LangFileString} page_settings_resolution_info "Choose screen resolution/window size."
${LangFileString} page_settings_tabs_label "Tabs:"
${LangFileString} page_settings_tabs_info "Employ a virtual folder structure to show songs?"
${LangFileString} page_settings_sorting_label "Sorting:"
${LangFileString} page_settings_sorting_info "Select criterion to sort songs."
${LangFileString} page_settings_songdir_label "SongDir"
${LangFileString} page_settings_songdir_info "Choose additional song directory for ${name}."

; Finish Page:

${LangFileString} page_finish_txt "${name} was installed successfully on your system.$\r$\n$\r$\nVisit our project website to get latest news and updates."
${LangFileString} page_finish_linktxt " >>> ${homepage} <<<"
${LangFileString} page_finish_desktop "Create Desktop Shortcut?"

;unused
${LangFileString} page_finish_txt_update "${name} Update has checked for a new version."


; Start Menu and Shortcuts

${LangFileString} sm_shortcut "Play ${name}"
${LangFileString} sm_uninstall "Uninstall"
${LangFileString} sm_website "Webseite"
${LangFileString} sm_license "License"
${LangFileString} sm_readme "Readme"
${LangFileString} sm_songs "Songs"
${LangFileString} sm_update "Update"
${LangFileString} sm_documentation "Documentation"

${LangFileString} sc_play "Play"
${LangFileString} sc_desktop "Create Desktop Shortcut"

