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


unit UScreenPartyTournamentPlayer;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMenu,
  sdl2,
  UDisplay,
  UMusic,
  UFiles,
  UPartyTournament,
  SysUtils,
  ULog,
  UThemes;

type
  TScreenPartyTournamentPlayer = class(TMenu)
    private
      SelectPlayers: cardinal;

      procedure UpdateInterface;
      procedure UpdatePartyTournament;
    public
      PlayersName: array of UTF8String;
      CountPlayer:   integer;

      Player1Name: cardinal;
      Player2Name: cardinal;
      Player3Name: cardinal;
      Player4Name: cardinal;
      Player5Name: cardinal;
      Player6Name: cardinal;
      Player7Name: cardinal;
      Player8Name: cardinal;
      Player9Name: cardinal;
      Player10Name: cardinal;
      Player11Name: cardinal;
      Player12Name: cardinal;
      Player13Name: cardinal;
      Player14Name: cardinal;
      Player15Name: cardinal;
      Player16Name: cardinal;

      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure SetAnimationProgress(Progress: real); override;
  end;

const
  ITournamentPlayers: array[0..14] of UTF8String = ('2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16');

implementation

uses
  UGraphic,
  UMain,
  UIni,
  UTexture,
  UUnicodeUtils,
  UScreenPartyOptions,
  ULanguage, Math;

procedure TScreenPartyTournamentPlayer.UpdateInterface;
var
    I: integer;
begin

  for I := 0 to CountPlayer do
    Button[I + 1].Visible := true;

  for I := CountPlayer + 1 to 14 do
    Button[I + 1].Visible := false;

end;

procedure TScreenPartyTournamentPlayer.UpdatePartyTournament;
var
  I, J, R: integer;
  TMP_PlayersName: array of UTF8String;
  TMP2_PlayersName: array of UTF8String;
begin


  SetLength(PlayersName, CountPlayer + 2);
  SetLength(TMP_PlayersName, CountPlayer + 2);

  for I := 0 to CountPlayer + 1 do
    TMP_PlayersName[I] := Button[I].Text[0].Text;

  // random
  for I:= 0 to CountPlayer + 1 do
  begin
    Randomize;
    R := Random(Length(TMP_PlayersName));

    PlayersName[I] := TMP_PlayersName[R];

    // remove
    SetLength(TMP2_PlayersName, 0);
    for J := 0 to High(TMP_PlayersName) do
    begin
      if (R <> J) then
      begin
        SetLength(TMP2_PlayersName, Length(TMP2_PlayersName) + 1);
        TMP2_PlayersName[High(TMP2_PlayersName)] := TMP_PlayersName[J];
      end;
    end;

    // refresh tmp
    SetLength(TMP_PlayersName, Length(TMP2_PlayersName));
    for J := 0 to High(TMP2_PlayersName) do
      TMP_PlayersName[J] := TMP2_PlayersName[J];
  end;

  PartyTournament.PlayersCount := CountPlayer + 2;

end;

function TScreenPartyTournamentPlayer.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var
  SDL_ModState:  word;
  isAlternate: boolean;
  procedure IntNext;
  begin
    repeat
      InteractNext;
    until ((Interactions[Interaction].Typ = iSelectS) and
      SelectsS[Interactions[Interaction].Num].Visible) or
      (Button[Interactions[Interaction].Num].Visible);
  end;
  procedure IntPrev;
  begin
    repeat
      InteractPrev;
    until ((Interactions[Interaction].Typ = iSelectS) and
      SelectsS[Interactions[Interaction].Num].Visible) or
      (Button[Interactions[Interaction].Num].Visible);
  end;
begin
  Result := true;

  if (PressedDown) then
    SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT
        + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT)
  else
    SDL_ModState := 0;

  // Key Down
  // check normal keys
  if (Interactions[Interaction].Typ = iButton) then
  begin

    // check normal keys
    if (IsPrintableChar(CharCode)) then
    begin
      Button[Interactions[Interaction].Num].Text[0].Text := Button[Interactions[Interaction].Num].Text[0].Text +
                                          UCS4ToUTF8String(CharCode);
      Exit;
    end;

    // check special keys
    isAlternate := (SDL_ModState = KMOD_LSHIFT) or (SDL_ModState = KMOD_RSHIFT);
    isAlternate := isAlternate or (SDL_ModState = KMOD_LALT); // legacy key combination
    case PressedKey of

      SDLK_BACKSPACE:
        begin
          Button[Interactions[Interaction].Num].Text[0].DeleteLastLetter;
        end;
    end;
  end;

  case PressedKey of
    SDLK_ESCAPE:
      begin
        Ini.SaveNames;
        AudioPlayback.PlaySound(SoundLib.Back);
        FadeTo(@ScreenPartyOptions);
      end;

    SDLK_RETURN:
      begin
        UpdatePartyTournament;
        FadeTo(@ScreenPartyTournamentOptions, SoundLib.Start);
      end;
    // Up and Down could be done at the same time,
    // but I don't want to declare variables inside
    // functions like this one, called so many times
    SDLK_DOWN:    IntNext;
    SDLK_UP:      IntPrev;
    SDLK_RIGHT:
      begin
        AudioPlayback.PlaySound(SoundLib.Option);
        InteractInc;

        UpdateInterface;
      end;
    SDLK_LEFT:
      begin
        AudioPlayback.PlaySound(SoundLib.Option);
        InteractDec;

        UpdateInterface;
      end;
  end;
end;

constructor TScreenPartyTournamentPlayer.Create;
begin
  inherited Create;

  LoadFromTheme(Theme.PartyTournamentPlayer);

  Theme.PartyTournamentPlayer.SelectPlayers.oneItemOnly := true;
  Theme.PartyTournamentPlayer.SelectPlayers.showArrows := true;
  SelectPlayers := AddSelectSlide(Theme.PartyTournamentPlayer.SelectPlayers, CountPlayer, ITournamentPlayers);

  AddButton(Theme.PartyTournamentPlayer.Player1Name);
  AddButton(Theme.PartyTournamentPlayer.Player2Name);
  AddButton(Theme.PartyTournamentPlayer.Player3Name);
  AddButton(Theme.PartyTournamentPlayer.Player4Name);

  AddButton(Theme.PartyTournamentPlayer.Player5Name);
  AddButton(Theme.PartyTournamentPlayer.Player6Name);
  AddButton(Theme.PartyTournamentPlayer.Player7Name);
  AddButton(Theme.PartyTournamentPlayer.Player8Name);

  AddButton(Theme.PartyTournamentPlayer.Player9Name);
  AddButton(Theme.PartyTournamentPlayer.Player10Name);
  AddButton(Theme.PartyTournamentPlayer.Player11Name);
  AddButton(Theme.PartyTournamentPlayer.Player12Name);

  AddButton(Theme.PartyTournamentPlayer.Player13Name);
  AddButton(Theme.PartyTournamentPlayer.Player14Name);
  AddButton(Theme.PartyTournamentPlayer.Player15Name);
  AddButton(Theme.PartyTournamentPlayer.Player16Name);

  Interaction := 0;

end;

procedure TScreenPartyTournamentPlayer.OnShow;
var
  I:    integer;
begin
  inherited;

  PartyTournament.Clear;

  // Templates for Names Mod
  for I := 0 to 5 do
    Button[I].Text[0].Text := Ini.Name[I];

  UpdateInterface;

end;

procedure TScreenPartyTournamentPlayer.SetAnimationProgress(Progress: real);
// var
//   I:    integer;
begin
  {for I := 0 to high(Button) do
    Button[I].Texture.ScaleW := Progress;   }
end;

end.
