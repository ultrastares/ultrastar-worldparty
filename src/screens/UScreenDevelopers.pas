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


unit UScreenDevelopers;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  sdl2,
  StrUtils,
  SysUtils,
  UIni,
  UMenu,
  UMusic,
  UThemes;

type
  TScreenDevelopers = class(TMenu)
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure SetAnimationProgress(Progress: real); override;
    private
      TextOverview: integer;
  end;

implementation

uses
  UGraphic,
  ULanguage,
  UCommon,
  UUnicodeUtils;

function TScreenDevelopers.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
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
          FadeTo(@ScreenAbout);
        end;
      SDLK_RETURN:
        begin
          //Exit Button Pressed
          if Interaction = 0 then
          begin
            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenAbout);
          end;

        end;
      SDLK_LEFT:
      begin
          InteractPrev;
      end;
      SDLK_RIGHT:
      begin
          InteractNext;
      end;
      SDLK_UP:
      begin
          InteractPrev;
      end;
      SDLK_DOWN:
      begin
          InteractNext;
      end;
    end;
  end;
end;

constructor TScreenDevelopers.Create;
begin
  inherited Create;

  Self.TextOverview := Self.AddText(UThemes.Theme.Developers.TextOverview);
  Self.Text[Self.TextOverview].Text := Format(Self.Text[Self.TextOverview].Text, [
    'Zup3r_vock\n\nDaniel20\n\njmfb\n\nTeLiXj',
    'https://ultrastar-es.org'
  ]);

  LoadFromTheme(Theme.Developers);

  AddButton(Theme.Developers.ButtonExit);

  Interaction := 0;
end;

procedure TScreenDevelopers.SetAnimationProgress(Progress: real);
var
  I: integer;
begin
  for I := 0 to high(Button) do
    Button[I].Texture.ScaleW := Progress;
end;
end.
