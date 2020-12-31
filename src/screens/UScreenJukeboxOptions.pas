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


unit UScreenJukeboxOptions;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  UScreenOptionsLyrics;

type
  TScreenJukeboxOptions = class(UScreenOptionsLyrics.TScreenOptionsLyrics)
    private
      fVisible: boolean;
      OptionClose:   cardinal;
      //Whether the Menu should be Drawn
      //Visible //Whether the Menu should be Drawn
      procedure SetVisible(Value: boolean);
    public
      constructor Create(); override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      function ParseMouse(MouseButton: Integer; BtnDown: Boolean; X, Y: integer): boolean; override;
      function Draw(): boolean; override;
      property Visible: boolean read fVisible write SetVisible;
  end;

implementation

uses
  UGraphic,
  UIni,
  UMain,
  UThemes;

constructor TScreenJukeboxOptions.Create();
begin
  Self.SelectMode := 1;
  Self.LoadFromTheme(UThemes.Theme.Jukebox);
  //same position than parent
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SongOptionsLyricPositionSlide, Self.SelectModeProperty, UIni.JukeboxOffsetLyric);
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SongOptionsLyricFontSlide, Self.SelectFont, UIni.ILyricsFont, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SongOptionsLyricEffectSlide, Self.SelectEffect, UIni.ILyricsEffect, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SongOptionsLyricAlphaSlide, Self.SelectTransparency, UIni.ILyricsAlpha);
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SongOptionsLyricLineSlide, Self.SelectLines, UIni.ILine, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SongOptionsLyricPropertySlide, Self.SelectProperty, UIni.IProperty, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SongOptionsLyricColorSlide, Self.SelectColor, UIni.LineColor, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SelectR, Self.Red, UIni.IRed);
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SelectG, Self.Green, UIni.IGreen);
  Self.AddSelectSlide(UThemes.Theme.Jukebox.SelectB, Self.Blue, UIni.IBlue);
  Self.PointerStart := Self.AddStatic(UThemes.Theme.Jukebox.PointerR);
  Self.AddStatic(UThemes.Theme.Jukebox.PointerG);
  Self.AddStatic(UThemes.Theme.Jukebox.PointerB);
  Self.AddStatic(UThemes.Theme.Jukebox.StaticSongOptionsBackground);
  Self.AddText(UThemes.Theme.Jukebox.SongOptionsVideoText);
  Self.AddText(UThemes.Theme.Jukebox.SongOptionsLyricText);
  Self.OptionClose := AddButton(UThemes.Theme.Jukebox.SongOptionsClose);
  Self.Button[Self.OptionClose].Selectable:= false;
  Self.Lyrics := UGraphic.ScreenJukebox.Lyrics;
  Self.SetModeValues();
  Self.SetValues();
end;

function TScreenJukeboxOptions.ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean;
begin
  Result := true;
  inherited ParseMouse(MouseButton, BtnDown, X, Y);
  Self.TransferMouseCords(X, Y);
  if not BtnDown then
    Self.Button[Self.OptionClose].SetSelect(Self.InRegion(X, Y, Self.Button[Self.OptionClose].GetMouseOverArea())) //hover
  else if Self.InRegion(X, Y, Self.Button[Self.OptionClose].GetMouseOverArea()) then
  begin
    Self.Interaction := 11;
    Self.ParseInput(SDLK_RETURN, 0, true);
  end;
end;

function TScreenJukeboxOptions.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;

  if (PressedDown) then
  begin // Key Down

    // check special keys
    case PressedKey of
      SDLK_O:
        begin
          UIni.Ini.Save();
          Visible := false;
          Exit;
        end;

      SDLK_BACKSPACE,
      SDLK_ESCAPE:
        begin
          UIni.Ini.Save();
          Visible := false;
          Exit;
        end;

      SDLK_SPACE:
        begin
          ScreenJukebox.Pause;
        end;

      SDLK_RETURN:
        begin
          // close
          if Self.Interaction = 11 then
          begin
            UIni.Ini.Save();
            Visible := false;
            ScreenJukebox.CloseClickTime := SDL_GetTicks;
            Exit;
          end;

        end;
      SDLK_DOWN, SDLK_LEFT, SDLK_RIGHT, SDLK_UP:
        inherited ParseInput(PressedKey, CharCode, PressedDown)
    end;
  end;
end;

procedure TScreenJukeboxOptions.SetVisible(Value: boolean);
begin
  //If change from invisible to Visible then OnShow
  if (fVisible = false) and (Value = true) then
    OnShow;

  ScreenJukebox.SongListVisible := false;
  fVisible := Value;
end;

function TScreenJukeboxOptions.Draw: boolean;
var
  I: integer;
begin

  for I := 0 to High(Statics) do
    Statics[I].Draw;

  for I := 0 to High(Text) do
    Text[I].Draw;

  for I := 0 to High(SelectsS) do
    SelectsS[I].Draw;

  for I := 0 to High(Button) do
    Button[I].Draw;

  Result := true;
end;

end.
