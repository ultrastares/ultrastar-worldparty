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


unit UScreenOptionsAdvanced;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UCommon,
  sdl2,
  UMenu,
  UDisplay,
  UMusic,
  UFiles,
  UIni,
  UThemes;
	
type

  TScreenOptionsAdvanced = class(TMenu)
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
  UGraphic,
  UUnicodeUtils,
  SysUtils;

function TScreenOptionsAdvanced.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
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
          FadeTo(@ScreenOptions);
        end;
      SDLK_RETURN:
        begin
          if SelInteraction = 7 then
          begin
            Ini.Save;
            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenOptions);
          end;
        end;
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
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 6) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
        end;
    end;
  end;
end;

constructor TScreenOptionsAdvanced.Create;
begin
  inherited Create;
  
  LoadFromTheme(Theme.OptionsAdvanced);

  Theme.OptionsAdvanced.SelectDebug.showArrows  := true;
  Theme.OptionsAdvanced.SelectDebug.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsAdvanced.SelectDebug, Ini.Debug, IDebugTranslated);
  
  Theme.OptionsAdvanced.SelectOscilloscope.showArrows := true;
  Theme.OptionsAdvanced.SelectOscilloscope.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsAdvanced.SelectOscilloscope, Ini.Oscilloscope, IOscilloscopeTranslated);
  
  Theme.OptionsAdvanced.SelectOnSongClick.showArrows := true;
  Theme.OptionsAdvanced.SelectOnSongClick.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsAdvanced.SelectOnSongClick, Ini.OnSongClick, IOnSongClickTranslated);

  Theme.OptionsAdvanced.SelectAskbeforeDel.showArrows := true;
  Theme.OptionsAdvanced.SelectAskbeforeDel.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsAdvanced.SelectAskbeforeDel, Ini.AskBeforeDel, IAskbeforeDelTranslated);

  Theme.OptionsAdvanced.SelectPartyPopup.showArrows := true;
  Theme.OptionsAdvanced.SelectPartyPopup.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsAdvanced.SelectPartyPopup, Ini.PartyPopup, IPartyPopupTranslated);

  Theme.OptionsAdvanced.SelectSingScores.showArrows := true;
  Theme.OptionsAdvanced.SelectSingScores.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsAdvanced.SelectSingScores, Ini.SingScores, ISingScoresTranslated);

  Theme.OptionsAdvanced.SelectTopScores.showArrows := true;
  Theme.OptionsAdvanced.SelectTopScores.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsAdvanced.SelectTopScores, Ini.TopScores, ITopScoresTranslated);

  AddButton(Theme.OptionsAdvanced.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 6, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);

  Interaction := 0;
end;

procedure TScreenOptionsAdvanced.OnShow;
begin
  inherited;

  Interaction := 0;
end;

end.
