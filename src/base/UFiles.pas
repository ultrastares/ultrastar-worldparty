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

unit UFiles;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
{$I switches.inc}

uses
  SysUtils,
  Classes,
  ULog,
  UMusic,
  USongs,
  USong,
  UPath;

procedure ResetSingTemp;

type
  TSaveSongResult = (ssrOK, ssrFileError, ssrEncodingError);

{**
 * Throws a TEncodingException if the song's fields cannot be encoded in the
 * requested encoding.
 *}
function SaveSong(const Song: TSong; const Lines: TLines; const Name: IPath): TSaveSongResult;

implementation

uses
  TextGL,
  UIni,
  UNote,
  UPlatform,
  UUnicodeUtils,
  UTextEncoding;

//--------------------
// Resets the temporary Sentence Arrays for each Player and some other Variables
//--------------------
procedure ResetSingTemp;
var
  Count:  integer;
begin
  for Count := 0 to High(Player) do begin
    Player[Count].Score := 0;
    Player[Count].LengthNote := 0;
    Player[Count].HighNote := -1;
  end;
end;

//--------------------
// Saves a Song
//--------------------
function SaveSong(const Song: TSong; const Lines: TLines; const Name: IPath): TSaveSongResult;
var
  C:      integer;
  N:      integer;
  S:      AnsiString;
  NoteState: AnsiString;
  SongFile: TTextFileStream;

  function EncodeToken(const Str: UTF8String): RawByteString;
  var
    Success: boolean;
  begin
    Success := EncodeStringUTF8(Str, Result, Song.Encoding);
    if (not Success) then
      SaveSong := ssrEncodingError;
  end;
begin
  Result := ssrOK;

  try
    SongFile := TMemTextFileStream.Create(Name, fmCreate);
    try
      // to-do: should we really write the BOM?
      //        it causes problems w/ older versions
      //        e.g. usdx 1.0.1a or ultrastar < 0.7.0
      if (Song.Encoding = encUTF8) then
        SongFile.WriteString(UTF8_BOM);

      // do not save "auto" encoding tag
      if (Song.Encoding <> encAuto) then
        SongFile.WriteLine('#ENCODING:' + EncodingName(Song.Encoding));
      SongFile.WriteLine('#TITLE:'    + EncodeToken(Song.Title));
      SongFile.WriteLine('#ARTIST:'   + EncodeToken(Song.Artist));

      if Song.Creator     <> ''        then SongFile.WriteLine('#CREATOR:'   + EncodeToken(Song.Creator));
      if Song.Fixer		  <> ''		   then SongFile.WriteLine('#FIXER:'  	 + EncodeToken(Song.Fixer));
      if Song.Edition     <> 'Unknown' then SongFile.WriteLine('#EDITION:'   + EncodeToken(Song.Edition));
      if Song.Genre       <> 'Unknown' then SongFile.WriteLine('#GENRE:'     + EncodeToken(Song.Genre));
      if Song.Language    <> 'Unknown' then SongFile.WriteLine('#LANGUAGE:'  + EncodeToken(Song.Language));
      if Song.Year        <> 0         then SongFile.WriteLine('#YEAR:'      + IntToStr(Song.Year));

      SongFile.WriteLine('#MP3:' + EncodeToken(Song.Mp3.ToUTF8));
      if Song.Cover.IsSet      then    SongFile.WriteLine('#COVER:'       + EncodeToken(Song.Cover.ToUTF8));
      if Song.Background.IsSet then    SongFile.WriteLine('#BACKGROUND:'  + EncodeToken(Song.Background.ToUTF8));
      if Song.Video.IsSet      then    SongFile.WriteLine('#VIDEO:'       + EncodeToken(Song.Video.ToUTF8));

      if Song.VideoGAP    <> 0.0  then    SongFile.WriteLine('#VIDEOGAP:'    + FloatToStr(Song.VideoGAP));
      if Song.Start       <> 0.0  then    SongFile.WriteLine('#START:'       + FloatToStr(Song.Start));
      if Song.Finish      <> 0    then    SongFile.WriteLine('#END:'         + IntToStr(Song.Finish));

      if (Song.Medley.Source=msTag) and (Song.Medley.EndBeat - Song.Medley.StartBeat > 0) then
      begin
        SongFile.WriteLine('#MedleyStartBeat:' + IntToStr(Song.Medley.StartBeat));
        SongFile.WriteLine('#MedleyEndBeat:' + IntToStr(Song.Medley.EndBeat));
      end;

      SongFile.WriteLine('#BPM:' + FloatToStr(Song.BPM / 4));
      SongFile.WriteLine('#GAP:' + FloatToStr(Song.GAP));

      for C := 0 to Lines.High do
      begin
        for N := 0 to Lines.Line[C].HighNote do
        begin
          with Lines.Line[C].Note[N] do
          begin
            //Golden + Freestyle Note Patch
            case Lines.Line[C].Note[N].NoteType of
              ntFreestyle: NoteState := 'F ';
              ntNormal: NoteState := ': ';
              ntGolden: NoteState := '* ';
              ntRap: NoteState:= 'R ';
              ntRapGolden: NoteState:='G ';
            end; // case
            S := NoteState + IntToStr(Start) + ' '
                           + IntToStr(Length) + ' '
                           + IntToStr(Tone) + ' '
                           + EncodeToken(Text);

            SongFile.WriteLine(S);
          end; // with
        end; // N

        if C < Lines.High then // don't write end of last sentence
        begin
          S := '- ' + IntToStr(Lines.Line[C+1].Start);
          SongFile.WriteLine(S);
        end;
      end; // C

      SongFile.WriteLine('E');
    finally
      SongFile.Free;
    end;
  except
    Result := ssrFileError;
  end;
end;

end.
