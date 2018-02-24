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


unit UScreenAbout;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMenu,
  sdl2,
  SysUtils,
  UDisplay,
  UMusic,
  UIni,
  UThemes;

type
  TScreenAbout = class(TMenu)
    public
      TextOverview, TextVChecking: integer;
      AboutStaticBghelper: integer;
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure SetAnimationProgress(Progress: real); override;

      procedure SetOverview;
      procedure VersionChecking;
  end;

implementation

uses
  UGraphic,
  UDataBase,
  USongs,
  USong,
  ULanguage,
  UCommon,
  Classes,
  ULog,
  UUnicodeUtils;

function TScreenAbout.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
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
        begin
          Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenMain);
        end;
      SDLK_RETURN:
	      begin
          //Developers Button
          if Interaction = 1 then
          begin
            AudioPlayback.PlaySound(SoundLib.Back);
            ScreenDevelopers.SetOverview('');
            FadeTo(@ScreenDevelopers);
          end;
          //Exit Button Pressed
          if Interaction = 0 then
          begin
            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenMain);
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

constructor TScreenAbout.Create;
begin
  inherited Create;

  TextOverview := AddText(Theme.AboutMain.TextOverview);
  TextVChecking:= AddText(Theme.AboutMain.TextVChecking);

  LoadFromTheme(Theme.AboutMain);

  AboutStaticBghelper := AddStatic(Theme.AboutMain.StaticBghelper);
  AddButton(Theme.AboutMain.ButtonExit);
  AddButton(Theme.AboutMain.ButtonDevelopers);

  Interaction := 0;
end;

procedure TScreenAbout.OnShow;
begin
  inherited;

  //Set Overview Text:
  SetOverview;
  VersionChecking; //**** TODO ****
end;

procedure TScreenAbout.SetOverview;
var
  Overview: UTF8String;
begin
  // Format overview
  Overview := Language.Translate('ABOUT_OVERVIEW');
  Text[0].Text := Overview;
end;

procedure TScreenAbout.VersionChecking;
var
  versioninfo: UTF8String;
begin  
  versioninfo := Language.Translate('ABOUT_CHECK_CHECKING');
  Text[1].Text := versioninfo;
end;

procedure TScreenAbout.SetAnimationProgress(Progress: real);
var
  I: integer;
begin
  for I := 0 to high(Button) do
    Button[I].Texture.ScaleW := Progress;
	Statics[0].Texture.ScaleW := Progress;
    Statics[0].Texture.ScaleH := Progress;
end;

end.
