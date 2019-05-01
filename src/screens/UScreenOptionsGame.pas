{*
    UltraStar Deluxe WorldParty - Karaoke Game

	UltraStar Deluxe WorldParty is the legal property of its developers,
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


unit UScreenOptionsGame;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  UMenu,
  UUnicodeUtils;

type
  TScreenOptionsGame = class(TMenu)
    private
      Language, SongMenu: integer;
      procedure ReloadScreen();
      procedure ReloadScreens();
    protected
      // interaction IDs
      ButtonExitIID: integer;
      SelectJoyPad: integer;
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

function TScreenOptionsGame.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if PressedDown then
  begin // Key Down
    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
          Self.ReloadScreens();
      SDLK_RETURN:
          if SelInteraction = 7 then
            Self.ReloadScreens();
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 6) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;
          if SelInteraction = 0 then
            Self.ReloadScreen();
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 6) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
          if SelInteraction = 0 then
            Self.ReloadScreen();
        end;
    end;
  end;
end;

constructor TScreenOptionsGame.Create;
begin
  inherited Create;

  Self.LoadFromTheme(UThemes.Theme.OptionsGame);
  Self.AddSelectSlide(UThemes.Theme.OptionsGame.SelectLanguage, UIni.Ini.Language, UIni.ILanguage);
  Self.AddSelectSlide(UThemes.Theme.OptionsGame.SelectSongMenu, UIni.Ini.SongMenu, UIni.ISongMenuMode, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGame.SelectDuets, UIni.Ini.ShowDuets, UIni.Switch, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGame.SelectTabs, UIni.Ini.Tabs, UIni.ITabs, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGame.SelectSorting, UIni.Ini.Sorting, UIni.ISorting, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsGame.SelectShowScores, UIni.Ini.ShowScores, UIni.IShowScores, 'OPTION_VALUE_');
  SelectJoyPad := Self.AddSelectSlide(UThemes.Theme.OptionsGame.SelectJoypad, UIni.Ini.Joypad, UIni.IJoypad, 'OPTION_VALUE_');
  Self.AddButton(UThemes.Theme.OptionsGame.ButtonExit);
  if (Length(Self.Button[0].Text) = 0) then
    Self.AddButtonText(20, 5, UThemes.Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);
end;

procedure TScreenOptionsGame.OnShow;
begin
  inherited;
  Self.Language := UIni.Ini.Language;
  Self.SongMenu := UIni.Ini.SongMenu;
  Self.Interaction := 0;
end;

// Reload all screens, after Language changed or screen song after songmenu, sorting or tabs changed
procedure TScreenOptionsGame.ReloadScreens();
begin
  UIni.Ini.Save;
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
    UGraphic.ScreenOptionsGame := TScreenOptionsGame.Create();
  end;
  AudioPlayback.PlaySound(SoundLib.Back);
  FadeTo(@ScreenOptions);
end;

procedure TScreenOptionsGame.ReloadScreen();
begin
  ULanguage.Language.ChangeLanguage(ILanguage[Ini.Language]);
  UThemes.Theme.OptionsGame.SelectLanguage.Text := ULanguage.Language.Translate('SING_OPTIONS_GAME_LANGUAGE');
  UThemes.Theme.OptionsGame.SelectSongMenu.Text := ULanguage.Language.Translate('SING_OPTIONS_GAME_SONGMENU');
  UThemes.Theme.OptionsGame.SelectTabs.Text := ULanguage.Language.Translate('SING_OPTIONS_GAME_TABS');
  UThemes.Theme.OptionsGame.SelectSorting.Text := ULanguage.Language.Translate('SING_OPTIONS_GAME_SORTING');
  UThemes.Theme.OptionsGame.SelectShowScores.Text := ULanguage.Language.Translate('SING_OPTIONS_GAME_SHOWSCORES');
  UThemes.Theme.OptionsGame.SelectJoypad.Text := ULanguage.Language.Translate('SING_OPTIONS_GAME_JOYPAD_SUPPORT');
  // UThemes.Theme.OptionsGame.ButtonExit.Text[0].Text := ULanguage.Language.Translate('SING_OPTIONS_EXIT'); //FIXME idk why silently fails
  UGraphic.ScreenOptionsGame.Free();
  UGraphic.ScreenOptionsGame := TScreenOptionsGame.Create;
end;

end.
