; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe Worldparty Installer - Language file: Spanish
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

!insertmacro LANGFILE_EXT Spanish

${LangFileString} abort_install "¿Seguro que quieres salir de la instalación?"
${LangFileString} abort_uninstall "¿Seguro que quieres salir de la desinstalación?"
${LangFileString} abort_update "¿Quieres cancelar la actualización?"
${LangFileString} oninit_running "El instalador ya esta funcionando"
${LangFileString} oninit_updating "La actualización ya esta funcionando"
${LangFileString} oninit_installagain "¿Seguro que quieres reinstalarlo?"
${LangFileString} oninit_alreadyinstalled "Ya esta instalado"
${LangFileString} oninit_closeWorldParty "No puedo desinstalar ultrastar mientras esta funcionando, ¿quieres cerrarlo?"
${LangFileString} oninit_updateWorldParty "¿Quieres actualizar la instalación desde...?"
${LangFileString} oninit_uninstall "¿Quieres desinstalar la antigua versión? (recomendado)"

${LangFileString} update_connect "Estableciendo conexión a internet para comprobar una nueva versión"
${LangFileString} button_next "Siguiente"
${LangFileString} button_close "Cerrar"
${LangFileString} update_information "Puedes comprobar si existe una nueva versión del juego. Si existe una actualización será instalada."
${LangFileString} button_check_update "Comprobar"

${LangFileString} delete_components "También borrar los siguientes componentes:"
${LangFileString} delete_covers "Carátulas"
${LangFileString} delete_highscores "Puntuaciones"
${LangFileString} delete_config "configuración"
${LangFileString} delete_screenshots "Capturas de pantalla"
${LangFileString} delete_playlists "Listas de reproducción"
${LangFileString} delete_songs "¿Eliminar canciones? ADVERTENCIA: se borrarán las canciones que estén dentro del directorio songs"

${LangFileString} update_noinstallation_online "Ninguna versión está instalada. El instalador no puede actualizar tu versión. Comprueba nuestra web ${homepage} para descargar la última versión."
${LangFileString} update_noinstallation_offline "Ninguna versión está instalada. El instalador no puede actualizar tu versión. Comprueba nuestra web ${homepage} para descargar la última versión."
${LangFileString} update_check_offline "$installed_version está actualizado."
${LangFileString} update_check_older "¡Buenas noticias! Hay disponible una nueva versión, ¿Quieres actualizar?"
${LangFileString} update_check_equal "Ya tienes la última versión instalada"
${LangFileString} update_check_newer "Ya tienes la última versión instalada"
${LangFileString} update_check_no "El instalador no puede actualizar tu versión. Comprueba nuestra web ${homepage} para conseguir una nueva versión."
${LangFileString} update_check_failed "La comprobación ha fallado, ¿Quieres visitar la web para comprobar si existe una nueva versión?"
;TODO ${LangFileString} update_download_success "The download of the new version $online_version succeeded.$\r$\n$\r$\nFinish the update by closing this updater. The new installation will be started right after."
;TODO ${LangFileString} update_download_failed "The download of the new version $online_version failed. The installer could not be downloaded.$\r$\n$\r$\nPlease, visit our website ${homepage} for the new version."
;TODO ${LangFileString} update_download_aborted "The download of the new version $online_version was aborted. Nothing will be updated. Remember, visit our website ${homepage} for latest news and updates."
;TODO ${LangFileString} update_download_invalid_installer "The download of the new version $online_version failed. The downloaded installer was invalid. This can happen if the server/website has some issues, does not exist anymore or is in maintenance mode.$\r$\n$\r$\nPlease, visit our website ${homepage} and download the installer manually."
;TODO ${LangFileString} update_download_none "No version to download selected. The current installer cannot update your version. Check our website ${homepage} for latest news and updates."
;TODO ${LangFileString} update_versions_info "At least one new version of ${name} has been found. Please, select a specific version and choose to update. This version will be downloaded and the installation will be started afterwards."
${LangFileString} update_versions_none "Ninguna"

${LangFileString} update_download_downloading "Descargando %s "
${LangFileString} update_download_connecting "conectando ... "
${LangFileString} update_download_sec "seg"
${LangFileString} update_download_min "min"
${LangFileString} update_download_hour "hora"
${LangFileString} update_download_multi "s"
${LangFileString} update_download_progress "%dkiB (%d%%) of %dkiB @ %d.%02dkiB/s"
${LangFileString} update_download_remaining " (%d %s%s restante)"
${LangFileString} update_download_remain_sec " (1 segundo restante)"
${LangFileString} update_download_remain_min " (1 minuto restante)"
${LangFileString} update_download_remain_hour " (1 hora restante)"
${LangFileString} update_download_remain_secs " (%u segundos restantes)"
${LangFileString} update_download_remain_mins " (%u minutos restantes)"
${LangFileString} update_download_remain_hours " (%u horas restantes)"

; Welcome Page:

${LangFileString} page_welcome_title_update "Bienvenido al asistente de instalación de ${name}"
${LangFileString} page_welcome_txt_update "El asistente te guiará a través de este proceso. ${name} es un juego gratuito y libre, con el que podrás emular a tus artistas favoritos.$\n$\r$\n$\r Para más información, visita nuestra página web oficial:$\n$\r$\n$\r${homepage}$\n$\r"
${LangFileString} page_welcome_title "Bienvenido a la instalación de ${name}"
${LangFileString} page_welcome_txt "El asistente te guiará a través de este proceso. ${name} es un juego gratuito y libre, con el que podrás emular a tus artistas favoritos.$\n$\r$\n$\r Para más información, visita nuestra página web oficial:$\n$\r$\n$\r${homepage}$\n$\r"
${LangFileString} page_un_welcome_title "Bienvenido a la desinstalación de ${name}"

; Custom Page

${LangFileString} page_settings_subtitle "Configura rápidamente tu ${name}."
${LangFileString} page_settings_config_title "Configuración de ${name} (opcional)"
${LangFileString} page_settings_config_info "No te preocupes, puedes cambiar estos valores si quieres más tarde."
${LangFileString} page_settings_fullscreen_label "Pantalla completa:"
${LangFileString} page_settings_fullscreen_info "¿Ejecutar el juego en ventana o pantalla completa?"
${LangFileString} page_settings_language_label "Idioma:"
${LangFileString} page_settings_language_info "Elige un idioma."
${LangFileString} page_settings_resolution_label "Resolución:"
${LangFileString} page_settings_resolution_info "Elige una resolución / Tamaño de la ventana."
${LangFileString} page_settings_tabs_label "Etiquetas"
${LangFileString} page_settings_tabs_info "¿Quieres clasificar las canciones en carpetas?"
${LangFileString} page_settings_sorting_label "Ordenar por:"
${LangFileString} page_settings_sorting_info "Selecciona un criterio para ordenar las canciones."
${LangFileString} page_settings_songdir_label "SongDir"
${LangFileString} page_settings_songdir_info "Elige un directorio adicional para tus canciones."

; Finish Page:

${LangFileString} page_finish_txt "${name} ha sido instalado con éxito.$\r$\n$\r$\nVisita nuestra página web para obtener las últimas noticias y actualizaciones."
${LangFileString} page_finish_linktxt " >>> ${homepage} <<<"
${LangFileString} page_finish_desktop "¿Quieres crear un acceso directo?"

;unused
${LangFileString} page_finish_txt_update "Hay una nueva actualización de ${name}"

; Start Menu and Shortcuts

${LangFileString} sm_shortcut "${name}"
${LangFileString} sm_uninstall "Desinstalar"
${LangFileString} sm_website "Página web oficial"
${LangFileString} sm_license "Licencia"
${LangFileString} sm_readme "Léeme"
${LangFileString} sm_songs "Canciones"
${LangFileString} sm_update "Actualizar"
${LangFileString} sm_documentation "Documentación"

${LangFileString} sc_play "Jugar ahora"
${LangFileString} sc_desktop "¿Quieres crear un acceso directo?"
