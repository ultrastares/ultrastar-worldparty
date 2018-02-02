; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe WorldParty Installer - Language file: German
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

!insertmacro LANGFILE_EXT German

${LangFileString} abort_install "Willst du die Installation wirklich abbrechen?"
${LangFileString} abort_uninstall "Willst du die Deinstallation wirklich abbrechen?"
${LangFileString} abort_update "Willst du das Updaten wirklich abbrechen?"
${LangFileString} oninit_running "Die Installation wird bereits ausgeführt."
${LangFileString} oninit_updating "Eine Aktualisierung wird bereits ausgeführt."
${LangFileString} oninit_installagain "Bist du sicher, dass du es erneut installieren möchtest?"
${LangFileString} oninit_alreadyinstalled "ist bereits installiert"
${LangFileString} oninit_closeWorldParty "kann nicht während der Laufzeit deinstalliert werden. Soll es geschlossen werden?"
${LangFileString} oninit_updateWorldParty "Möchtest du das Programm aktualisieren von"
${LangFileString} oninit_uninstall "Möchtest du die alte Version entfernen? (empfohlen)"

${LangFileString} update_connect "Mit dem Internet verbinden und nach aktueller Version suchen"
${LangFileString} button_next "Weiter >"
${LangFileString} button_close "Beenden"

${LangFileString} delete_components "Folgende Komponenten ebenfalls entfernen:"
${LangFileString} delete_covers "Cover"
${LangFileString} delete_highscores "Statistiken"
${LangFileString} delete_config "Konfiguration"
${LangFileString} delete_screenshots "Screenshots"
${LangFileString} delete_playlists "Playlisten"
${LangFileString} delete_songs "Lieder löschen? WARNUNG: ALLE Dateien im Unterordner 'songs' des Installationsverzeichnisses werden gelöscht(!)"

${LangFileString} update_information "Du kannst nach einer aktuelleren Version von '${name}' suchen. Dazu wird eine Verbindung mit dem Internet hergestellt. Wurde eine aktuellere Version gefunden, kann diese anschließend installiert werden."
${LangFileString} button_check_update "Überprüfen"

${LangFileString} update_noinstallation_online "Du hast keine Version installiert. Diese Installationsroutine kann die aktuelle Version nicht aktualisieren. Besuche unsere Projektwebseite ${homepage} um nach einer aktuellen Version zu suchen."
${LangFileString} update_noinstallation_offline "Du hast keine Version installiert. Diese Installationsroutine kann eine Aktualisierung nicht installieren. Besuche unsere Projektwebseite ${homepage} um nach einer aktuellen Version zu suchen."
${LangFileString} update_check_offline "Deine aktuelle Version $installed_version ist auf dem neusten Stand. se Installationsroutine kann die aktuelle Version nicht aktualisieren. Besuche unsere Projektwebseite ${homepage} um nach einer aktuellen Version zu suchen."
${LangFileString} update_check_older "Deine aktuelle Version $installed_version ist veraltet. Die neueste Version $online_version von ${name} ist verfügbar. Wähle eine Option aus:"
${LangFileString} update_check_equal "Deine aktuelle Version $installed_version ist auf dem neusten Stand.$\n$\rKein Update benötigt."
${LangFileString} update_check_newer "Deine aktuelle Version $installed_version ist neuer als die zurzeit veröffentlichte$\n$\rVersion $online_version von ${name}. Kein Update benötigt."
${LangFileString} update_check_no "Diese Installationsroutine wird keine Version installieren. Besuche unsere Projektwebseite ${homepage} um nach einer aktuellen Version zu suchen."
${LangFileString} update_check_failed "Die Aktualisierungsprüfung ist fehlgeschlagen. Besuche unsere Projektwebseite ${homepage} um nach einer aktuellen Version zu suchen und manuell diese herunterzuladen."
;${LangFileString} update_download_success "Das Herunterladen der neuen Version $online_version war erfolgreich.$\n$\r$\n$\rBeende die Aktualisierung indem du diese Installationsroutine schließt. Die Installation der neuen Version wird am Anschluss gestartet."
;${LangFileString} update_download_failed "Das Herunterladen der neuen Version $online_version ist fehlgeschlagen. Bitte, besuche unsere Projektwebseite ${homepage} um nach einer aktuellen Version zu suchen."
;${LangFileString} update_download_aborted "Das Herunterladen der neuen Version $online_version wurde abgebrochen. Eine Aktualisierung bleibt aus. Denk daran, besuche unsere Projektwebseite ${homepage} um die neusten Updates und News zu erhalten."
;${LangFileString} update_download_invalid_installer "Das Herunterladen der neuen Version $online_version ist fehlgeschlagen. Die heruntergeladene Installationsdatei war fehlerhaft. Dies kann verschiedene Gründe haben wie ein Probleme mit dem Server oder der Webseite, die Datei nicht mehr verfügbar ist oder der Server sich in Wartung befindet.$\n$\r$\n$\rBitte, besuche unsere Projektwebseite ${homepage} um die aktuelle Version manuell herunterzuladen."
;${LangFileString} update_download_none "Keine Version zum Herunterladen ausgewählt. Diese Installationsroutine kann keine Aktualisierung durchführen. Besuche unsere Projektwebseite ${homepage} um die neusten Updates und News zu erhalten."
;${LangFileString} update_versions_info "Es wurde mindestens eine neue Version von ${name} gefunden. Wähle eine aus um diese zu installieren. Diese wird heruntergeladen und anschließend die Installationsroutine der neuen Version gestartet."
${LangFileString} update_versions_none "Keine"

${LangFileString} update_download_downloading "Herunterladen: %s "
${LangFileString} update_download_connecting "Verbinden ... "
${LangFileString} update_download_sec "Sekunde"
${LangFileString} update_download_min "Minute"
${LangFileString} update_download_hour "Stunde"
${LangFileString} update_download_multi "n"
${LangFileString} update_download_progress "%dkB (%d%%) von %dkB @ %d.%01dkB/s"
${LangFileString} update_download_remaining " (%d %s%s verbleibend)"
${LangFileString} update_download_remain_sec " (1 Sekunde verbleibend)"
${LangFileString} update_download_remain_min " (1 Minute verbleibend)"
${LangFileString} update_download_remain_hour " (1 hour verbleibend)"
${LangFileString} update_download_remain_secs " (%u Sekunden verbleibend)"
${LangFileString} update_download_remain_mins " (%u Minuten verbleibend)"
${LangFileString} update_download_remain_hours " (%u Stunden verbleibend)"

; Welcome Page:

${LangFileString} page_welcome_title_update "Willkommen beim Aktualisierungsassistenten von ${name}"
${LangFileString} page_welcome_txt_update "Dieser Assistent wird dich durch die Aktualisierung von ${name} begleiten. ${name} ist ein kostenloses quelloffenes Karaokespiel, welches Singstar ähnelt. $\n$\r$\n$\rDas ${publisher} wünscht viel Spaß.$\n$\r$\n$\rProjektseite:$\n$\r${homepage}$\n$\r$\n$\rSupport Forum:$\n$\r${forum}"
${LangFileString} page_welcome_title "Willkommen zur Installationsroutine von ${name}"
${LangFileString} page_welcome_txt "Dieser Assistent wird dich durch die Installation von ${name} begleiten. ${name} ist ein kostenloses quelloffenes Karaokespiel, welches Singstar ähnelt. $\n$\r$\n$\rDas ${publisher} wünscht viel Spaß.$\n$\r$\n$\rProjektseite:$\n$\r${homepage}$\n$\r$\n$\rSupport Forum:$\n$\r${forum}"
${LangFileString} page_un_welcome_title "Willkommen zur Deinstallation von ${name}"

; Custom Page

${LangFileString} page_settings_subtitle "Lege deine favorisierten Einstellungen für ${name} fest."
${LangFileString} page_settings_config_title "${name} Konfiguration (Optional)"
${LangFileString} page_settings_config_info "Alle Einstellungen können nachträglich im Spielmenü geändert werden."
${LangFileString} page_settings_fullscreen_label "Vollbild Modus:"
${LangFileString} page_settings_fullscreen_info "Spiel im Fenster oder Vollbild starten?"
${LangFileString} page_settings_language_label "Sprache:"
${LangFileString} page_settings_language_info "Passe die Sprache des Menüs an."
${LangFileString} page_settings_resolution_label "Auflösung:"
${LangFileString} page_settings_resolution_info "Wähle die Auflösung/Fenstergröße aus."
${LangFileString} page_settings_tabs_label "Ordnerstruktur:"
${LangFileString} page_settings_tabs_info "Eine virtuelle Ordnerstruktur zum Anzeigen der Lieder verwenden?"
${LangFileString} page_settings_sorting_label "Sortierung:"
${LangFileString} page_settings_sorting_info "Kriterium zum Sortieren der Lieder wählen."
${LangFileString} page_settings_songdir_label "SongDir"
${LangFileString} page_settings_songdir_info "Hier kann ein weiterer Ordner mit Songs für ${name} angegeben werden."

; Finish Page:

${LangFileString} page_finish_txt "${name} wurde erfolgreich auf Ihrem System installiert.$\n$\r$\n$\rBesuche unsere Projektwebseite um die neusten Updates und News zu erhalten."
${LangFileString} page_finish_linktxt ">>> ${homepage} <<<"
${LangFileString} page_finish_desktop "Verknüpfung auf dem Desktop erstellen?"

;unused
${LangFileString} page_finish_txt_update "${name} Update hat nach einer neuen Version gesucht."


; Start Menu and Shortcuts

${LangFileString} sm_shortcut "${name} spielen"
${LangFileString} sm_uninstall "Deinstallieren"
${LangFileString} sm_website "Webseite"
${LangFileString} sm_license "Lizenz"
${LangFileString} sm_readme "Lies mich"
${LangFileString} sm_songs "Songs"
${LangFileString} sm_update "Updaten"
${LangFileString} sm_documentation "Dokumentation"

${LangFileString} sc_play "Spielen"
${LangFileString} sc_desktop "Verknüpfung auf dem Desktop erstellen"

