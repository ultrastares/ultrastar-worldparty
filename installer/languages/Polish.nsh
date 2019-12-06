; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar WorldParty Installer - Language file: Polish
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

!insertmacro LANGFILE_EXT Polish

${LangFileString} abort_install "Czy jesteś pewien, że chcesz zatrzymać instalację?"
${LangFileString} abort_uninstall "Czy jesteś pewien, że chcesz zatrzymać odinstalowywanie?"
${LangFileString} abort_update "Czy jesteś pewien, że chcesz przerwać aktualizację?"
${LangFileString} oninit_running "Instalacja jest już uruchomiona."
${LangFileString} oninit_updating "Aktualizacja jest już uruchomiona."
${LangFileString} oninit_installagain "Jesteś pewien, że chcesz zainstalować jeszcze raz?"
${LangFileString} oninit_alreadyinstalled "jest już zainstalowany"
${LangFileString} oninit_closeWorldParty "nie może być odinstalowany dopóki jest uruchomiony! Czy chcesz go zamknąć?"
${LangFileString} oninit_updateWorldParty "Czy chcesz zaktualizować instalację z:"
${LangFileString} oninit_uninstall "Czy chcesz odinstalować starą wersję? (rekomendowane)"

${LangFileString} update_connect "Sprawdź połączenie z Internetem i sprawdź nowe wersje"
${LangFileString} button_next "Dalej >"
${LangFileString} button_close "Zamknij"
${LangFileString} update_information "Możesz sprawdzić czy jest nowsza wersja '${name}'. Aby to zrobić połącz się z internetem. Jeżeli nowa wersja zostanie znaleziona, będzie można ją zainstalować."
${LangFileString} button_check_update "Sprawdź"

${LangFileString} delete_components "Usuń również następujące składniki:"
${LangFileString} delete_covers "Okładka"
${LangFileString} delete_highscores "Wyniki"
${LangFileString} delete_config "Koniguracja"
${LangFileString} delete_screenshots "Zrzuty ekranów"
${LangFileString} delete_playlists "Playlisty"
${LangFileString} delete_songs "Usunąć piosenki? UWAGA: Wszystkie pliki w katalogu InstallationDir\songs będą usunięte(!)"

${LangFileString} update_noinstallation_online "Nie masz zainstalowanej żadnej wersji. Obecny instalator nie może zaktualizować twojej wersji. Odwiedź naszą stronę ${homepage}, aby pobrać nową wersję."
${LangFileString} update_noinstallation_offline "Nie masz zainstalowanej żadnej wersji. Obecny instalator/aktualizator nie może zainstalować wersji. Odwiedź naszą stronę ${homepage}, aby pobrać wersję."
${LangFileString} update_check_offline "Twoja wersja $installed_version jest aktualna. Obecny instalator nie może zaktualizować twojej wersji. Odwiedź stronę naszego projektu, aby uzyskać najnowsze informacje i aktualizacje."
${LangFileString} update_check_older "Twoja wersja $installed_version jest przestarzała. Nowa wersja online_version ${name} jest już dostępna. Czy chcesz dokonać aktualizacji?"
${LangFileString} update_check_equal "Obecnie zainstalowana wersja $installed_version jest najbardziej aktualna. Nie ma nowszych wersji."
${LangFileString} update_check_newer "Twoja obecnie zainstalowana wersja $installed_version jest nowsza niż $\r$\nobecnie wydana wersja online_version ${name}. Nie ma nowszych aktualizacji."
${LangFileString} update_check_no "Obecny aktualizator/instalator nie zainstaluje wersji. Odwiedź naszą stronę ${homepage}, aby pobrać nową wersję."
${LangFileString} update_check_failed "Poszukiwanie nowyszch wersji zakończyło siê błędem. Czy chcesz odwiedzić stronę główną i sprawdzić ręcznie?"
;${LangFileString} update_download_success "Pobieranie nowej wersji $online_version zakończyło się sukcesem.$\r$\n$\r$\nDokończ aktualizację zamykając ten aktualizator. Następnie zostanie uruchomiona nowa instalacja."
;${LangFileString} update_download_failed "Pobieranie nowej wersji $online_version nie powiodło się. Instalator nie może zostać pobrany.$\r$\n$\r$\nProszę, odwiedź naszą stronę ${homepage}, aby pobrać nową wersję."
;${LangFileString} update_download_aborted "Pobieranie nowej wersji $online_version zostało przerwane. Aktualizacja nie zostanie przeprowadzona. Pamiętaj, odwiedź naszą stronę ${homepage}, aby uzyskać najnowsze informacje i aktualizacje."
;${LangFileString} update_download_invalid_installer "Pobieranie nowej wersji $online_version nie powiodło się. Pobrany instalator jest nieprawidłowy. Mogło to nastąpić, jeśli serwer/strona napotkała problemy, już nie istnieje, lub jest w trakcie konserwacji.$\r$\n$\r$\nProszę, odwiedź naszą stronę ${homepage} i pobierz instalator ręcznie."
;${LangFileString} update_download_none "Nie wybrano wersji do pobrania. Instalator nie może zaktualizować twojej wersji. Odwiedź naszą stronę ${homepage}, aby uzyskać najnowsze informacje i aktualizacje."
;${LangFileString} update_versions_info "Przynajmniej jedna nowa wersja ${name} została znaleziona. Proszę, wybierz konkretną wersję do aktualizacji. Ta wersja zostanie pobrana i następnie zostanie uruchomiona instalacja."
${LangFileString} update_versions_none "Brak"

${LangFileString} update_download_downloading "Pobieranie %s "
${LangFileString} update_download_connecting "Nawiązywanie połączenia ... "
${LangFileString} update_download_sec "sek."
${LangFileString} update_download_min "min."
${LangFileString} update_download_hour "godz."
${LangFileString} update_download_multi "s"
${LangFileString} update_download_progress "%dkiB (%d%%) z %dkiB @ %d.%02dkiB/s"
${LangFileString} update_download_remaining " (%d %s%s do końca)"
${LangFileString} update_download_remain_sec " (1 sekunda do końca)"
${LangFileString} update_download_remain_min " (1 minuta do końca)"
${LangFileString} update_download_remain_hour " (1 godzina do końca)"
${LangFileString} update_download_remain_secs " (%u sekund do końca)"
${LangFileString} update_download_remain_mins " (%u minut do końca)"
${LangFileString} update_download_remain_hours " (%u godzin do końca)"

; Welcome Page:

${LangFileString} page_welcome_title_update "Witamy w kreatorze aktualizacji programu ${name}"
${LangFileString} page_welcome_txt_update "Ten kreator przeprowadzi cię przez proces aktualizacji gry ${name}. ${name} jest bezpłatną i Otwartą grą Karaoke, którą można porównać z SingStar'em.$\r$\n$\r$\nZespół ${name} życzy miłej zabawy.$\r$\n$\r$\nStrona projektu:$\n$\r${homepage}$\r$\n$\r$\nForum wsparcia:$\n$\r${forum}"
${LangFileString} page_welcome_title "Witamy w kreatorze instalacji programu ${name}"
${LangFileString} page_welcome_txt "Ten kreator przeprowadzi cię przez proces instalacji gry ${name}. ${name} jest bezpłatną i Otwartą grą Karaoke, którą można porównać z SingStar'em.$\r$\n$\r$\nZespół ${name} życzy miłej zabawy.$\r$\n$\r$\nStrona projektu:$\n$\r${homepage}$\r$\n$\r$\nForum wsparcia:$\n$\r${forum}"
${LangFileString} page_un_welcome_title "Witamy w kreatorze deinstalacji gry ${name}"

; Custom Page

${LangFileString} page_settings_subtitle "Wybierz ustawienia dogodne dla Ciebie."
${LangFileString} page_settings_config_title "Konfiguracja ${name} (opcjonalnie)"
${LangFileString} page_settings_config_info "Wszystkie ustawienia można później zmieniać w grze."
${LangFileString} page_settings_fullscreen_label "Tryb Pełnoekranowy:"
${LangFileString} page_settings_fullscreen_info "Czy uruchamiać grę w oknie czy na pełnym ekranie?"
${LangFileString} page_settings_language_label "Język:"
${LangFileString} page_settings_language_info "Dostosuj język interfejsu graficznego."
${LangFileString} page_settings_resolution_label "Rozdzielczość:"
${LangFileString} page_settings_resolution_info "Wybierz rozdzieczość ekran/okna."
${LangFileString} page_settings_tabs_label "Zakładki:"
${LangFileString} page_settings_tabs_info "Czy chcesz aby piosenki zostały pogrupowane na zakładki?"
${LangFileString} page_settings_sorting_label "Sortowanie:"
${LangFileString} page_settings_sorting_info "Wybierz kryteria sortowania piosenek."
${LangFileString} page_settings_songdir_label "SongDir"
${LangFileString} page_settings_songdir_info "Wybierz katalog w którym znajdują się piosenki?"

; Finish Page:

${LangFileString} page_finish_txt "${name} został poprawnie zainstalowany na twoim komputerze.$\r$\n$\r$\nOdwiedź Naszą stronę aby otrzymać najnowsze wiadomości i aktualizacje."
${LangFileString} page_finish_linktxt ">>> ${homepage} <<<"
${LangFileString} page_finish_desktop "Czy stwórzyć skrót na Pulpicie?"

;unused
;TODO ${LangFileString} page_finish_txt_update "${name} Update has checked for a new version."

; Start Menu and Shortcuts

${LangFileString} sm_shortcut "Graj w ${name}"
${LangFileString} sm_uninstall "Odinstaluj"
${LangFileString} sm_website "Strona Projektu"
${LangFileString} sm_license "Licencja"
${LangFileString} sm_readme "Readme"
${LangFileString} sm_songs "Piosenki"
${LangFileString} sm_update "Aktualizacja"
${LangFileString} sm_documentation "Dokumentacja"

${LangFileString} sc_play "Graj"
${LangFileString} sc_desktop "Czy stwórzyć skrót na Pulpicie?"
