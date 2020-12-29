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


unit UScreenOptionsThemes;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  UMenu,
  UDisplay,
  UMusic,
  UFiles,
  UIni,
  UConfig,
  UThemes;

type
  TScreenOptionsThemes = class(TMenu)
    private
      procedure ReloadTheme;
    public
      ActualTheme:  Integer;
      ActualSkin:   Integer;
      ActualColor:  Integer;
      SkinSelect: integer;
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure InteractInc; override;
      procedure InteractDec; override;
  end;

implementation

uses
  SysUtils,
  UCommon,
  UGraphic,
  UMain,
  UPathUtils,
  UUnicodeUtils,
  UScreenOptions,
  USkins;

function TScreenOptionsThemes.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);

          // select theme button in new created options screen
          ScreenOptions.Interaction := 4;

          FadeTo(@ScreenOptions);
        end;
      SDLK_RETURN:
        begin
          if SelInteraction = 3 then
          begin
            Ini.Save;
            AudioPlayback.PlaySound(SoundLib.Back);

            // select theme button in new created options screen
            ScreenOptions.Interaction := 4;

            FadeTo(@ScreenOptions);
          end;
        end;
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 2) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 2) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
        end;
    end;
  end;
end;

procedure TScreenOptionsThemes.InteractInc;
begin
  inherited InteractInc;
  ReloadTheme();
end;

procedure TScreenOptionsThemes.InteractDec;
begin
  inherited InteractDec;
  ReloadTheme();
end;

constructor TScreenOptionsThemes.Create;
begin
  inherited Create;

  LoadFromTheme(Theme.OptionsThemes);
  AddSelectSlide(Theme.OptionsThemes.SelectTheme, Ini.Theme, ITheme);
  Self.SkinSelect := AddSelectSlide(UThemes.Theme.OptionsThemes.SelectSkin, UIni.Ini.Skin, UThemes.Theme.Themes[UIni.Ini.Theme].Skins);
  AddSelectSlide(Theme.OptionsThemes.SelectColor, UIni.Ini.Color, UIni.IColor, 'C_COLOR_');

  AddButton(Theme.OptionsThemes.ButtonExit);

end;

procedure TScreenOptionsThemes.ReloadTheme;
begin
  if Self.SelInteraction = 0 then
  begin
    UpdateSelectSlideOptions(UThemes.Theme.OptionsThemes.SelectSkin, Self.SkinSelect, UThemes.Theme.Themes[UIni.Ini.Theme].Skins, UIni.Ini.Skin);
    UIni.Ini.Skin := GetArrayIndex(UThemes.Theme.Themes[UIni.Ini.Theme].Skins, UThemes.Theme.Themes[UIni.Ini.Theme].DefaultSkin);
  end;

  if Self.SelInteraction < 2 then
    UIni.Ini.Color := Skin.GetDefaultColor();

  UGraphic.UnLoadScreens();
  UThemes.Theme.LoadTheme(UIni.Ini.Theme, UIni.Ini.Color);
  UGraphic.LoadScreens();
  UGraphic.ScreenOptions := TScreenOptions.Create();
  UGraphic.ScreenOptionsThemes := TScreenOptionsThemes.Create();
  UGraphic.ScreenOptionsThemes.OnShow(); //to show video background
end;

end.
