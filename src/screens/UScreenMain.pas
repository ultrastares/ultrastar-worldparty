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


unit UScreenMain;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  ULog,
  MD5,
  UMenu,
  sdl2,
  UDisplay,
  UMusic,
  UFiles,
  USong,
  UScreenSong,
  SysUtils,
  UThemes;

type

  TScreenMain = class(TMenu)

  public
    TextDescription:     integer;
    TextDescriptionLong: integer;

    constructor Create; override;
    function ParseInput(PressedKey: Cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
    procedure OnShow; override; 
	procedure SetInteraction(Num: integer); override;
    procedure SetAnimationProgress(Progress: real); override;
//	procedure UpdateTextDescriptionFor(IID: integer); virtual;
	  
 // private
 // ButtonSoloIID, ButtonMultiIID, ButtonJukeboxIID, ButtonStatIID, ButtonOptionsIID, ButtonExitIID, ButtonAboutIID,

 // MapIIDtoDescID: array of integer;
  
  end;

implementation

uses
  UGraphic,
  UNote,
  UIni,
  UTexture,
  USongs,
  ULanguage,
  UParty,
  USkins,
  UUnicodeUtils;
  
const
  ITEMS_PER_ROW = 3;   // Number of buttons for row of buttons in Main menu. 

function TScreenMain.ParseInput(PressedKey: Cardinal; CharCode: UCS4Char;
  PressedDown: boolean): boolean;
var
  SDL_ModState: word;
begin
  Result := true;

  SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT +
    KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT + KMOD_RALT);

  if (PressedDown) then
  begin // Key Down
        // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'): begin
        Result := false;
        Exit;
      end;
   end;
         // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE:
      begin
        Result := false;
      end;

      SDLK_RETURN:
      begin
        // reset
        Party.bPartyGame := false;

        //Solo
        if (Interaction = 0) then
        begin
          if (Songs.SongList.Count >= 1) then
          begin
            if (Ini.Players >= 0) and (Ini.Players <= 3) then
              PlayersPlay := Ini.Players + 1;
            if (Ini.Players = 4) then
              PlayersPlay := 6;

            if Ini.OnSongClick = sSelectPlayer then
              FadeTo(@ScreenSong)
            else
            begin
              ScreenName.Goto_SingScreen := false;
              FadeTo(@ScreenName, SoundLib.Start);
            end;
          end
          else //show error message
            ScreenPopupError.ShowPopup(Language.Translate('ERROR_NO_SONGS'));
        end;

        //Party
        if Interaction = 1 then
        begin
          if (Songs.SongList.Count >= 1) then
          begin
            Party.bPartyGame := true;

            FadeTo(@ScreenPartyOptions, SoundLib.Start);
          end
          else //show error message, No Songs Loaded
            ScreenPopupError.ShowPopup(Language.Translate('ERROR_NO_SONGS'));
        end;

        //Jukebox
        if Interaction = 2 then
        begin
          if (Songs.SongList.Count >= 1) then
          begin
            FadeTo(@ScreenJukeboxPlaylist, SoundLib.Start);
          end
          else //show error message, No Songs Loaded
            ScreenPopupError.ShowPopup(Language.Translate('ERROR_NO_SONGS'));
        end;

        //Stats
        if Interaction = 3 then
        begin
          FadeTo(@ScreenStatMain, SoundLib.Start);
        end;

        //Options
        if Interaction = 4 then
        begin
          FadeTo(@ScreenOptions, SoundLib.Start);
        end;

		//Exit
        if Interaction = 5 then
        begin
          Result := false;
		end;
		  
        //About
        if Interaction = 6 then
        begin
          FadeTo(@ScreenAbout, SoundLib.Start);
        end;        
      end;
      SDLK_DOWN: InteractMainNextRow(ITEMS_PER_ROW);
      SDLK_UP: InteractMainPrevRow(ITEMS_PER_ROW);
      SDLK_RIGHT: InteractNext;
      SDLK_LEFT: InteractPrev;
    end;
  end
end;


constructor TScreenMain.Create;
begin
  inherited Create;
{**
 * Attention ^^:
 * New Creation Order needed because of LoadFromTheme
 * and Button Collections.
 * At First Custom Texts and Statics
 * Then LoadFromTheme
 * after LoadFromTheme the Buttons and Selects
 *}
  TextDescription     := AddText(Theme.Main.TextDescription);
  TextDescriptionLong := AddText(Theme.Main.TextDescriptionLong);

  LoadFromTheme(Theme.Main);

  AddButton(Theme.Main.ButtonSolo);
  AddButton(Theme.Main.ButtonMulti);
  AddButton(Theme.Main.ButtonJukebox);
  
  AddButton(Theme.Main.ButtonStat);
  AddButton(Theme.Main.ButtonOptions);
  AddButton(Theme.Main.ButtonExit);
  
  AddButton(Theme.Main.ButtonAbout);
  
  Interaction := 0;
end;

procedure TScreenMain.OnShow;
begin
  inherited;

  SoundLib.StartBgMusic;

  ScreenSong.Mode := smNormal;

 {**
  * Clean up TPartyGame here
  * at the moment there is no better place for this
  *}
  Party.Clear;

end;

procedure TScreenMain.SetInteraction(Num: integer);
begin
  inherited SetInteraction(Num);
  Text[TextDescription].Text     := Theme.Main.Description[Interaction];
  Text[TextDescriptionLong].Text := Theme.Main.DescriptionLong[Interaction];
end;

procedure TScreenMain.SetAnimationProgress(Progress: real);
begin
  Statics[0].Texture.ScaleW := Progress;
  Statics[0].Texture.ScaleH := Progress;
end;

end.
