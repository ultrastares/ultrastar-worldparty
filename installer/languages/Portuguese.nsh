; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~
; UltraStar Deluxe WorldParty Installer - Language file: Portuguese
; ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~ ~+~

!insertmacro LANGFILE_EXT Portuguese

${LangFileString} abort_install "Tem a certeza que deseja cancelar a instalação?"
${LangFileString} abort_uninstall "Tem a certeza que deseja cancelar a desinstalação?"
;TODO ${LangFileString} abort_update "Are you sure to abort the update?"
${LangFileString} oninit_running "O instalador já está em execução."
;TODO ${LangFileString} oninit_updating "An update is already running."
${LangFileString} oninit_installagain "Tem certeza de que deseja instalá-lo novamente?"
${LangFileString} oninit_alreadyinstalled "já está instalado"
${LangFileString} oninit_closeWorldParty "não pode ser desinstalado enquanto está a correr! Deseja fechá-lo?"
${LangFileString} oninit_updateWorldParty "Você quer atualizar a instalação de:"
${LangFileString} oninit_uninstall "Você quer desinstalar a versão antiga? (recomendado)"

${LangFileString} update_connect "Estabelecer conexão com a internet e verifique se há nova versão"
${LangFileString} button_next "Seguinte >"
${LangFileString} button_close "Fechar"
${LangFileString} update_information "Você pode verificar se uma nova versão do '${name}' está disponível. Uma conexão à internet será estabelecida. Se uma nova versão for encontrada, poderá ser instalada depois."
;TODO ${LangFileString} button_check_update "Check"

${LangFileString} delete_components "Além disso, exclua os seguintes componentes:"
${LangFileString} delete_covers "Capas?"
${LangFileString} delete_highscores "Pontuações?"
${LangFileString} delete_config "Configurações?"
${LangFileString} delete_screenshots "Screenshots?"
${LangFileString} delete_playlists "Playlists?"
${LangFileString} delete_songs "Remover canções? ATENÇÃO: TODOS os arquivos dentro da pasta InstallationDir\songs serão removidos(!)"

;TODO ${LangFileString} update_noinstallation_online "You have no version installed. The current installer cannot update your version. Check our website ${homepage} for a new version."
;TODO ${LangFileString} update_noinstallation_offline "You have no version installed. The current installer/updater cannot install a version. Check our website ${homepage} for a version."
;TODO ${LangFileString} update_check_offline "Your version $installed_version is up-to-date. The current installer cannot update your version. Visit our project website to get latest news and updates."
${LangFileString} update_check_older "A sua versão $installed_version está obsoleta. Uma nova versão (online_version) do ${name} está disponível. Deseja atualizar?"
${LangFileString} update_check_equal "A sua versão atualmente instalada $installed_version está atualizada."
${LangFileString} update_check_newer "A sua versão instalada $installed_version é mais recente que a $\r$\nversão corrente online_version do ${name}. Não necessita de atualização."
;TODO ${LangFileString} update_check_no "The current updater/installer won't install a version. Check our website ${homepage} for a new version."
${LangFileString} update_check_failed "A verificação de uma nova versão falhou. Você quer visitar o site para verificar manualmente?"
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

${LangFileString} page_welcome_title_update "Bem-vindo ao assistente de actualização do ${name}"
${LangFileString} page_welcome_txt_update "Este assistente irá guiá-lo através do processo de atualização do ${name}. ${name} é um jogo de Karaoke livre de código aberto, que pode ser comparado com o Singstar.$\r$\n$\r$\n${publisher} deseja-lhe que se divirta.$\r$\n$\r$\nWebsite do projecto:$\n$\r${homepage}$\r$\n$\r$\nForúm Suporte:$\n$\r${forum}"
${LangFileString} page_welcome_title "Bem-vindo ao assistente de instalação do ${name}"
${LangFileString} page_welcome_txt "Este assistente irá guiá-lo através do processo de instalação do ${name}. ${name} é um jogo de Karaoke livre de código aberto, que pode ser comparado com o Singstar.$\r$\n$\r$\n${publisher} deseja-lhe que se divirta.$\r$\n$\r$\nWebsite do projecto:$\n$\r${homepage}$\r$\n$\r$\nForúm Suporte:$\n$\r${forum}"
${LangFileString} page_un_welcome_title "Bem-vindo ao assistente de desinstalação do ${name}"

; Custom Page

${LangFileString} page_settings_subtitle "Especifique suas configurações favoritas para ${name}."
${LangFileString} page_settings_config_title "Configuração ${name} (opcional)"
${LangFileString} page_settings_config_info "Todas as opções podem ser posteriormente alteradas no jogo."
${LangFileString} page_settings_fullscreen_label "Ecrã Completo:"
${LangFileString} page_settings_fullscreen_info "Iniciar jogo em janela ou ecrã completo."
${LangFileString} page_settings_language_label "Idioma:"
${LangFileString} page_settings_language_info "Seleccione idioma."
${LangFileString} page_settings_resolution_label "Resolução:"
${LangFileString} page_settings_resolution_info "Escolha a resolução."
${LangFileString} page_settings_tabs_label "Subpastas:"
${LangFileString} page_settings_tabs_info "Pastas virtuais para mostrar canções."
${LangFileString} page_settings_sorting_label "Ordenação:"
${LangFileString} page_settings_sorting_info "Seleccione o critério de ordenação das canções."
${LangFileString} page_settings_songdir_label "Directoria das canções:"
${LangFileString} page_settings_songdir_info "Escolha diretório adicional para as canções do ${name}."

; Finish Page:

${LangFileString} page_finish_txt "${name} foi instalado com sucesso no seu sistema.$\r$\n$\r$\nVisite o site do projecto para receber as últimas notícias e actualizações."
${LangFileString} page_finish_linktxt ">>> ${homepage} <<<"
${LangFileString} page_finish_desktop "Criar atalho no Ambiente de Trabalho"

;unused
;TODO ${LangFileString} page_finish_txt_update "${name} Update has checked for a new version."

; Start Menu and Shortcuts

${LangFileString} sm_shortcut "${name}"
${LangFileString} sm_uninstall "Uninstall"
${LangFileString} sm_website "Website"
${LangFileString} sm_license "License"
${LangFileString} sm_readme "Readme"
${LangFileString} sm_songs "Canções"
${LangFileString} sm_update "atualizar"
${LangFileString} sm_documentation "Documentação"

${LangFileString} sc_play "Play"
${LangFileString} sc_desktop "Criar atalho no Ambiente de Trabalho"