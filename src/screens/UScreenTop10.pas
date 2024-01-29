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


unit UScreenTop10;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  SysUtils,
  sdl2,
  UDisplay,
  ULanguage,
  ULog,
  UMenu,
  UMusic,
  USongs,
  UThemes;

type
  TScreenTop10 = class(TMenu)
    public
      TextArtistTitle: integer;

      TextDate:        array[1..3,1..10] of integer;
      TextName:        array[1..3,1..10] of integer;
      TextScore:       array[1..3,1..10] of integer;

      Fadeout:         boolean;

      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      function Draw: boolean; override;
  end;

implementation

uses
  Math,
  UDataBase,
  UGraphic,
  UMain,
  UIni,
  UNote,
  UUnicodeUtils;

function TScreenTop10.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if PressedDown then
  begin
    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE,
      SDLK_RETURN:
        begin
          if (not Fadeout) then
          begin
            FadeTo(@ScreenSong);
            Fadeout := true;
          end;
        end;
      SDLK_SYSREQ:
        begin
          Display.SaveScreenShot;
        end;
    end;
  end;
end;

constructor TScreenTop10.Create;
var
  I: integer;
begin
  inherited Create;

  LoadFromTheme(Theme.Top10);

  TextArtistTitle := AddText(Theme.Top10.TextArtistTitle);

  // Easy
  for I := 0 to 9 do
  begin
    TextDate[1,I+1]     := AddText  (Theme.Top10.TextDate[I]);
    TextName[1,I+1]     := AddText  (Theme.Top10.TextName[I]);
    TextScore[1,I+1]    := AddText  (Theme.Top10.TextScore[I]);
  end;

  // Medium
  for I := 10 to 19 do
  begin
    TextDate[2,I-9]     := AddText  (Theme.Top10.TextDate[I]);
    TextName[2,I-9]     := AddText  (Theme.Top10.TextName[I]);
    TextScore[2,I-9]    := AddText  (Theme.Top10.TextScore[I]);
  end;

  // Hard
  for I := 20 to 29 do
  begin
    TextDate[3,I-19]     := AddText  (Theme.Top10.TextDate[I]);
    TextName[3,I-19]     := AddText  (Theme.Top10.TextName[I]);
    TextScore[3,I-19]    := AddText  (Theme.Top10.TextScore[I]);
  end;

  AddButton(Theme.Top10.ButtonContinue); 
end;

procedure TScreenTop10.OnShow;
var
  I, J:		integer;
  data:   boolean;
  PMax:		integer;
  sung:		boolean; //score added? otherwise in wasn't sung!
  Report:	string;
begin
  inherited;

  sung := false;
  data := false;
  Fadeout := false;

  PMax := Ini.Players;
  if PMax = 4 then
    PMax := 5;
  for I := 0 to PMax do
  begin
    if (Round(Player[I].ScoreTotalInt) > 0) and (ScreenSing.SungToEnd) then
    begin
      DataBase.AddScore(CurrentSong, Ini.PlayerLevel[I], Ini.Name[I], Round(Player[I].ScoreTotalInt));
      sung:=true;
    end;
  end;

  try
    if sung then
    begin
       DataBase.WriteScore(CurrentSong);
    end;
    DataBase.ReadScore(CurrentSong);
  except
    on E : Exception do
    begin
      Report := 'Writing or reading songscore failed in Top-10-creen. Faulty database file?' + LineEnding +
      'Stacktrace:' + LineEnding;
      if E <> nil then
      begin
	      Report := Report + 'Exception class: ' + E.ClassName + LineEnding +
	      'Message: ' + E.Message + LineEnding;
      end;
      Report := Report + BackTraceStrFunc(ExceptAddr);
      for I := 0 to ExceptFrameCount - 1 do
      begin
	      Report := Report + LineEnding + BackTraceStrFunc(ExceptFrames[I]);
      end;
      Log.LogWarn(Report, 'UScreenTop10.OnShow');
    end;
  end;

  Text[TextArtistTitle].Text := CurrentSong.Artist + ' - ' + CurrentSong.Title;

  for J := 0 to 2 do
  begin
    for I := 1 to Length(CurrentSong.Score[J]) do
    begin
      Text[TextDate[J+1,I]].Visible := true;
      Text[TextName[J+1,I]].Visible := true;
      Text[TextScore[J+1,I]].Visible := true;

      Text[TextDate[J+1,I]].Text := CurrentSong.Score[J, I-1].Date;
      Text[TextName[J+1,I]].Text := CurrentSong.Score[J, I-1].Name;
      Text[TextScore[J+1,I]].Text := IntToStr(CurrentSong.Score[J, I-1].Score);
    end;

    If Length(CurrentSong.Score[J])>0 then
      data := true;
    // Hide no value
    for I := Length(CurrentSong.Score[J]) + 1 to 10 do
    begin
      Text[TextName[J+1,I]].Visible := false;
      Text[TextScore[J+1,I]].Visible := false;
      Text[TextDate[J+1,I]].Visible := false;
    end;
  end;
  // If there are no scores to show, go to next screen
  If (not data) then
    FadeTo(@ScreenSong);
end;

function TScreenTop10.Draw: boolean;
begin
  Result := inherited Draw;
end;

end.
