{*
    UltraStar WorldParty - Karaoke Game

	UltraStar WorldParty is the legal property of its developers,
	whose names	are too numerous to list here. Please refer to the
	COPYRIGHT file distributed with this source distribution.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. Check "LICENSE" file. If not, see
	<http://www.gnu.org/licenses/>.
 *}


unit UScreenOptionsGeneral;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  UMenu,
  UUnicodeUtils;

type
  TScreenOptionsGeneral = class(TMenu)
    private
      Language, SongMenu: integer; static;
      LanguageDesc, SongMenuDesc, DuetsDesc, TabsDesc, SortingDesc, ShowScoresDesc, SingScoresDesc, MedleyCDesc: integer;
      procedure ReloadScreen();
      procedure ReloadScreens();
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
  end;

implementation

uses
  SysUtils,
  UGraphic,
  UIni,
  ULanguage,
  UMusic,
  UScreensong,
  UScreenOptions,
  USongs,
  UThemes;

function TScreenOptionsGeneral.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if PressedDown then
  begin // Key Down
    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
          Self.ReloadScreens();
      SDLK_RETURN:
          if Self.SelInteraction = 8 then
            Self.ReloadScreens();
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_LEFT, SDLK_RIGHT:
        begin
          if (Self.SelInteraction >= 0) and (Self.SelInteraction <= 7) then
          begin
            if Self.SelInteraction = 6 then //rebuild songs arrays with new config
            begin
              UIni.Ini.Save();
              UGraphic.ScreenMain.ReloadSongs(false);
            end;

            AudioPlayback.PlaySound(SoundLib.Option);
            if PressedKey = SDLK_RIGHT then
              Self.InteractInc()
            else
              Self.InteractDec()
          end;
          if Self.SelInteraction = 0 then
            Self.ReloadScreen();
        end;
    end;
  end;
end;

constructor TScreenOptionsGeneral.Create;
begin
  inherited Create;

  Self.LoadFromTheme(UThemes.Theme.OptionsGeneral);
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectLanguage, UIni.Ini.Language, UIni.ILanguage);
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectSongMenu, UIni.Ini.SongMenu, UIni.ISongMenuMode, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectDuets, UIni.Ini.ShowDuets, UIni.Switch, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectTabs, UIni.Ini.Tabs, UIni.Switch, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectSorting, UIni.Ini.Sorting, UIni.ISorting, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectShowScores, UIni.Ini.ShowScores, UIni.IShowScores, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectSingScores, UIni.Ini.SingScores, UIni.ISingScores, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGeneral.SelectFindUnsetMedley, UIni.Ini.FindUnsetMedley, UIni.Switch, 'OPTION_VALUE_');
  Self.AddButton(UThemes.Theme.OptionsGeneral.ButtonExit);

  LanguageDesc := Self.AddText(UThemes.Theme.OptionsGeneral.LanguageDesc);
  SongMenuDesc := Self.AddText(UThemes.Theme.OptionsGeneral.SongMenuDesc);
  DuetsDesc := Self.AddText(UThemes.Theme.OptionsGeneral.DuetsDesc);
  TabsDesc := Self.AddText(UThemes.Theme.OptionsGeneral.TabsDesc);
  SortingDesc := Self.AddText(UThemes.Theme.OptionsGeneral.SortingDesc);
  ShowScoresDesc := Self.AddText(UThemes.Theme.OptionsGeneral.ShowScoresDesc);
  SingScoresDesc := Self.AddText(UThemes.Theme.OptionsGeneral.SingScoresDesc);
  MedleyCDesc := Self.AddText(UThemes.Theme.OptionsGeneral.MedleyCDesc);
end;

procedure TScreenOptionsGeneral.OnShow;
begin
  inherited;
  Self.Language := UIni.Ini.Language;
  Self.SongMenu := UIni.Ini.SongMenu;
  Self.Interaction := 0;
end;

// Reload all screens, after Language changed or screen song after songmenu, sorting or tabs changed
procedure TScreenOptionsGeneral.ReloadScreens();
begin
  UIni.Ini.Save();
  if (Self.SongMenu <> UIni.Ini.SongMenu) then
  begin
    UThemes.Theme.ThemeSongLoad();
    if USongs.Songs.GetLoadProgress().Finished then
    begin
      FreeAndNil(UGraphic.ScreenSong);
      UGraphic.ScreenSong := TScreenSong.Create();
    end;
  end;
  if Self.Language <> UIni.Ini.Language then
  begin
    ULanguage.Language.ChangeLanguage(UIni.ILanguage[Ini.Language]);
    UGraphic.UnLoadScreens();
    UThemes.Theme.LoadTheme(UIni.Ini.Theme, UIni.Ini.Color);
    UGraphic.LoadScreens();
    UGraphic.ScreenOptions := TScreenOptions.Create();
    UGraphic.ScreenOptionsGeneral := TScreenOptionsGeneral.Create();
  end;
  AudioPlayback.PlaySound(SoundLib.Back);
  FadeTo(@ScreenOptions);
end;

procedure TScreenOptionsGeneral.ReloadScreen();
begin
  ULanguage.Language.ChangeLanguage(ILanguage[UIni.Ini.Language]);
  UThemes.Theme.OptionsGeneral.SelectLanguage.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_LANGUAGE');
  UThemes.Theme.OptionsGeneral.SelectSongMenu.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SONGMENU');
  UThemes.Theme.OptionsGeneral.SelectDuets.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_DUETS');
  UThemes.Theme.OptionsGeneral.SelectTabs.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_TABS');
  UThemes.Theme.OptionsGeneral.SelectSorting.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SORTING');
  UThemes.Theme.OptionsGeneral.SelectShowScores.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SHOWSCORES');
  UThemes.Theme.OptionsGeneral.SelectSingScores.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SINGSCORES');
  UThemes.Theme.OptionsGeneral.SelectFindUnsetMedley.Text := ULanguage.Language.Translate('C_MEDLEYC');
  UThemes.Theme.OptionsGeneral.ButtonExit.Text[0].Text := ULanguage.Language.Translate('C_BACK');

  UThemes.Theme.OptionsGeneral.LanguageDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_LANGUAGE_DESC');
  UThemes.Theme.OptionsGeneral.SongMenuDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SONGMENU_DESC');
  UThemes.Theme.OptionsGeneral.DuetsDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_DUETS_DESC');
  UThemes.Theme.OptionsGeneral.TabsDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_TABS_DESC');
  UThemes.Theme.OptionsGeneral.SortingDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SORTING_DESC');
  UThemes.Theme.OptionsGeneral.ShowScoresDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SHOWSCORES_DESC');
  UThemes.Theme.OptionsGeneral.SingScoresDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_SINGSCORES_DESC');
  UThemes.Theme.OptionsGeneral.MedleyCDesc.Text := ULanguage.Language.Translate('SING_OPTIONS_GENERAL_MEDLEYC_DESC');
  FreeAndNil(UGraphic.ScreenOptionsGeneral);
  UGraphic.ScreenOptionsGeneral := TScreenOptionsGeneral.Create();
  UGraphic.ScreenOptionsGeneral.Background.OnShow();
end;

end.
