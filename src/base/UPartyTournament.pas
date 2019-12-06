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

unit UPartyTournament;

interface

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

{$I switches.inc}

uses
  UIni;

type

  NextPlayers = record
    Player1: integer;
    Player2: integer;
    NamePlayer1: UTF8String;
    NamePlayer2: UTF8String;
  end;

  PosResult = record
    X: real;
    Y: real;
    Text: string;
  end;

type
  TPartyTournament = class

  private


  public
    PlayersCount: integer;
    Rounds: array[0..3] of integer;
    Winner: UTF8String;

    LastPlayer: integer;
    Phase:      integer;
    EliminatedPlayers: array of integer;
    Next: NextPlayers;
    ResultPlayer: array [0..3, 0..15] of PosResult;

    TournamentFinish: boolean;

    constructor Create;
    procedure Clear;
    destructor  Destroy; override;
  end;

var
  PartyTournament: TPartyTournament;

implementation

uses
  UGraphic,
  ULanguage,
  ULog,
  ULuaCore,
  UDisplay,
  USong,
  UNote,
  SysUtils;

//-------------
// Just the constructor
//-------------
constructor TPartyTournament.Create;
begin
  inherited;

  Clear;
end;

destructor TPartyTournament.Destroy;
begin
  inherited;
end;

{ clears all party specific data previously stored }
procedure TPartyTournament.Clear;
var
  I, J: Integer;
begin

  Next.Player1 := -1;
  Next.Player2 := -1;

  LastPlayer := -1;
  SetLength(EliminatedPlayers, 0);
  Phase := 0;
  TournamentFinish := false;
  Winner := '';

  for I := 0 to 3 do
  begin
    for J := 0 to 15 do
    begin
      ResultPlayer[I, J].Text := '';
    end;
  end;
end;

end.
