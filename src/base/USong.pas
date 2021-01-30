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

unit USong;

interface
{$IFDEF FPC}
  {$MODE OBJFPC}
{$ENDIF}

{$I switches.inc}

uses
  {$IFDEF MSWINDOWS}
    Windows,
  {$ELSE}
    {$IFNDEF DARWIN}
      syscall,
    {$ENDIF}
    baseunix,
    UnixType,
  {$ENDIF}
  MD5,
  SysUtils,
  Classes,
  {$IFDEF DARWIN}
    cthreads,
  {$ENDIF}
  UCatCovers,
  UCommon,
  UFilesystem,
  ULog,
  UMusic, //needed for TLines
  UPath,
  UPlatform,
  UTexture,
  UTextEncoding,
  UUnicodeUtils;

type

  TSingMode = ( smNormal, smPartyClassic, smPartyFree, smPartyChallenge, smPartyTournament, smPlaylistRandom , smMedley );

  TMedleySource = ( msNone, msCalculated, msTag );

  TMedley = record
    Source:       TMedleySource;  //source of the information
    StartBeat:    integer;        //start beat of medley
    EndBeat:      integer;        //end beat of medley
  end;

  TScore = record
    Name:       UTF8String;
    Score:      integer;
    Date:       UTF8String;
  end;

  TSong = class
  private
    SongFile: TTextFileStream;
    FileLineNo : integer;  // line, which is read last, for error reporting

    function DecodeFilename(Filename: RawByteString): IPath;
    procedure ParseNote(LineNumber: integer; TypeP: char; StartP, DurationP, NoteP: integer; LyricS: UTF8String);
    procedure NewSentence(LineNumberP: integer; Param1: integer);
    procedure FindRefrain(); // tries to find a refrain for the medley mode and preview start

    function ParseLyricStringParam(const Line: RawByteString; var LinePos: integer): RawByteString;
    function ParseLyricIntParam(const Line: RawByteString; var LinePos: integer): integer;
    function ParseLyricText(const Line: RawByteString; var LinePos: integer): RawByteString;

    function GetFolderCategory(const aFileName: IPath): UTF8String;
    function LoadSong(DuetChange: boolean): boolean;
    function ReadTxtHeader(): boolean;
  public
    Path:         IPath; // kust path component of file (only set if file was found)
    FullPath: UTF8String;
    Folder:       UTF8String; // for sorting by folder (only set if file was found)
    FileName:     IPath; // just name component of file (only set if file was found)
    MD5:          string; //MD5 Hash of Current Song

    // filenames
    Cover:      IPath;
    Mp3:        IPath;
    Background: IPath;
    Video:      IPath;

    // sorting methods
    Genre:      UTF8String;
    Edition:    UTF8String;
    Language:   UTF8String;
    Year:       Integer;

    Title:      UTF8String;
    Artist:     UTF8String;

    // use in search
    TitleNoAccent:  UTF8String;
    ArtistNoAccent: UTF8String;

    Creator: UTF8String;
    Fixer: UTF8String;

    CoverTex: TTexture;

    VideoGAP: real;
    Start: real; // in seconds
    Finish: integer; // in miliseconds
    BPM: real;
    GAP: real; // in miliseconds

    Encoding:   TEncoding;
    PreviewStart: real;   // in seconds
    Medley:     TMedley;  // medley params

    Validated: boolean;
    isDuet: boolean;
    DuetNames:  array of UTF8String; // duet singers name
    hasRap: boolean;

    Score:      array[0..2] of array of TScore;

    // these are used when sorting is enabled
    Visible:    boolean; // false if hidden, true if visible
    Main:       boolean; // false for songs, true for category buttons
    OrderNum:   integer; // has a number of category for category buttons and songs
    CatNumber:  integer; // Count of Songs in Category for Cats and Number of Song in Category for Songs

    LastError: AnsiString;
    Lines: array of TLines;
    function  GetErrorLineNo: integer;
    property  ErrorLineNo: integer read GetErrorLineNo;

    constructor Create(); overload;
    constructor Create(const aFileName : IPath); overload;
    function Analyse(DuetChange: boolean = false): boolean;
    procedure SetMedleyMode();
  end;

  TSongOptions = class
    public
      VideoRatioAspect:        integer;
      VideoWidth :             integer;
      VideoHeight:             integer;
      LyricPosition:           integer;
      LyricAlpha:              integer;
      LyricSingFillColor:      string;
      LyricActualFillColor:    string;
      LyricNextFillColor:      string;
      LyricSingOutlineColor:   string;
      LyricActualOutlineColor: string;
      LyricNextOutlineColor:   string;

      constructor Create(RatioAspect, Width, Height, Position, Alpha: integer;
                SingFillColor, ActualFillColor, NextFillColor, SingOutlineColor, ActualOutlineColor, NextOutlineColor: string);
  end;

implementation

uses
  Math,
  StrUtils,
  TextGL,
  UIni,
  UPathUtils,
  USongs,
  UNote;   //needed for Player

constructor TSongOptions.Create(RatioAspect, Width, Height, Position, Alpha: integer;
                SingFillColor, ActualFillColor, NextFillColor, SingOutlineColor, ActualOutlineColor, NextOutlineColor: string);
begin
  inherited Create();

  VideoRatioAspect := RatioAspect;
  VideoWidth := Width;
  VideoHeight := Height;
  LyricPosition := Position;
  LyricAlpha := Alpha;
  LyricSingFillColor := SingFillColor;
  LyricActualFillColor := ActualFillColor;
  LyricNextFillColor := NextFillColor;
  LyricSingOutlineColor := SingOutlineColor;
  LyricActualOutlineColor := ActualOutlineColor;
  LyricNextOutlineColor := NextOutlineColor;

end;

constructor TSong.Create();
begin
  inherited;

  // to-do : special create for category "songs"
  //dirty fix to fix folders=on
  Self.Path     := PATH_NONE();
  Self.FileName := PATH_NONE();
  Self.Cover    := PATH_NONE();
  Self.Mp3      := PATH_NONE();
  Self.Background:= PATH_NONE();
  Self.Video    := PATH_NONE();
end;

// This may be changed, when we rewrite song select code.
// it is some kind of dirty, but imho the best possible
// solution as we do atm not support nested categorys.
// it works like the folder sorting in 1.0.1a
// folder is set to the first folder under the songdir
// so songs ~/.ultrastardx/songs/punk is in the same
// category as songs in shared/ultrastardx/songs are.
// note: folder is just the name of a category it has
//       nothing to do with the path used for file loading
function TSong.GetFolderCategory(const aFileName: IPath): UTF8String;
var
  I: Integer;
  CurSongPath: IPath;
  CurSongPathRel: IPath;
begin
  Result := 'Unknown'; //default folder category, if we can't locate the song dir

  for I := 0 to SongPaths.Count-1 do
  begin
    CurSongPath := SongPaths[I] as IPath;
    if (aFileName.IsChildOf(CurSongPath, false)) then
    begin
      if (aFileName.IsChildOf(CurSongPath, true)) then
      begin
        // songs are in the "root" of the songdir => use songdir for the categorys name
        Result := CurSongPath.RemovePathDelim.ToUTF8;
      end
      else
      begin
        // use the first subdirectory below CurSongPath as the category name
        CurSongPathRel := aFileName.GetRelativePath(CurSongPath.AppendPathDelim);
        Result := CurSongPathRel.SplitDirs[0].RemovePathDelim.ToUTF8;
      end;
      Exit;
    end;
  end;
end;

constructor TSong.Create(const aFileName: IPath);
begin
  inherited Create();
  LastError := '';
  Self.Path := aFileName.GetPath();
  Self.FileName := aFileName.GetName();
  Self.FullPath := aFileName.GetAbsolutePath().ToNative();
  Self.Folder := Self.GetFolderCategory(aFileName);

  //Main Information
  Self.Title  := '';
  Self.Artist := '';

  //Sortings:
  Self.Genre := 'Unknown';
  Self.Edition := 'Unknown';
  Self.Language := 'Unknown';
  Self.Year := 0;

  // set to default encoding
  Self.Encoding := Ini.DefaultEncoding;

  //Required Information
  Self.Mp3 := PATH_NONE;
  Self.BPM := 0;
  Self.GAP := 0;
  Self.Start := 0;
  Self.Finish := 0;

  //Additional Information
  Self.Background := PATH_NONE;
  Self.Cover := PATH_NONE;
  Self.Video := PATH_NONE;
  Self.VideoGAP := 0;
  Self.Creator := '';
  Self.Fixer   := '';
  Self.PreviewStart := 0;
  Self.Medley.Source := msNone;
  Self.Validated := true;
  Self.isDuet := false;
  SetLength(Self.DuetNames, 2);
  Self.DuetNames[0] := 'P1';
  Self.DuetNames[1] := 'P2';
end;

function TSong.DecodeFilename(Filename: RawByteString): IPath;
begin
  Result := UPath.Path(DecodeStringUTF8(Filename, Encoding));
end;

type
  EUSWPParseException = class(Exception);

{**
 * Parses the Line string starting from LinePos for a parameter.
 * Leading whitespace is trimmed, same applies to the first trailing whitespace.
 * After the call LinePos will point to the position after the first trailing
 * whitespace.
 *
 * Raises an EUSWPParseException if no string was found.
 *
 * Example:
 *   ParseLyricParam(Line:'Param0  Param1 Param2', LinePos:8, ...)
 *   -> Param:'Param1', LinePos:16 (= start of 'Param2')
 *}
function TSong.ParseLyricStringParam(const Line: RawByteString; var LinePos: integer): RawByteString;
var
  StartLyric: integer;
  OldLinePos: integer;
const
  Whitespace = [#9, ' '];
begin
  OldLinePos := LinePos;

  StartLyric := 0;
  while (LinePos <= Length(Line)) do
  begin
    if (Line[LinePos] in Whitespace) then
    begin
      // check for end of param
      if (StartLyric > 0) then
        Break;
    end
    // check for beginning of param
    else if (StartLyric = 0) then
    begin
      StartLyric := LinePos;
    end;
    Inc(LinePos);
  end;

  // check if param was found
  if (StartLyric = 0) then
  begin
    LinePos := OldLinePos;
    raise EUSWPParseException.Create('String expected');
  end
  else
  begin
    // copy param without trailing whitespace
    Result := Copy(Line, StartLyric, LinePos-StartLyric);
    // skip first trailing whitespace (if not at EOL)
    if (LinePos <= Length(Line)) then
      Inc(LinePos);
  end;
end;

function TSong.ParseLyricIntParam(const Line: RawByteString; var LinePos: integer): integer;
var
  Str: RawByteString;
  OldLinePos: integer;
begin
  OldLinePos := LinePos;
  Str := ParseLyricStringParam(Line, LinePos);

  if not TryStrToInt(Str, Result) then
  begin // on convert error
    Result := 0;
    LinePos := OldLinePos;
    raise EUSWPParseException.Create('Integer expected');
  end;
end;

{**
 * Returns the rest of the line from LinePos as lyric text.
 * Leading and trailing whitespace is not trimmed.
 *}
function TSong.ParseLyricText(const Line: RawByteString; var LinePos: integer): RawByteString;
begin
  if (LinePos > Length(Line)) then
    Result := ''
  else
  begin
    Result := Copy(Line, LinePos, Length(Line)-LinePos+1);
    LinePos := Length(Line)+1;
  end;
end;

//Load TXT Song
function TSong.LoadSong(DuetChange: boolean): boolean;
var
  CurLine: RawByteString;
  I, LinePos: integer;
  CP: integer; // Current Player (0 or 1)
  Param0: AnsiChar;
  Param1, Param2, Param3: integer;
  ParamLyric: UTF8String;
begin
  Result := false;
  LastError := '';

  try
    Self.SongFile.ReadLine(CurLine);
    if (Length(CurLine) = 0) or not (CurLine[1] in [':', 'F', '*', 'R', 'G', 'P']) then
    begin //Song File Corrupted - No Notes
      Log.LogError('Could not load txt File, no notes found: '+Self.FullPath);
      LastError := 'ERROR_CORRUPT_SONG_NO_NOTES';
      Exit;
    end;

    SetLength(Lines, 0); //very important to delete previous and speed up load
    if (CurLine[1] = 'P') then
    begin
      Self.isDuet := true;
      SetLength(Lines, 2);
      CP := -1;
    end
    else
    begin
      SetLength(Lines, 1);
      CP := 0;
    end;

    for I := 0 to High(Lines) do
    begin
      Lines[I].High := 0;
      Lines[I].Number := 1;
      Lines[I].Current := 0;
      Lines[I].ScoreValue := 0;

      //Add first line and set some standard values to fields
      //see procedure NewSentence for further explantation
      //concerning most of these values
      SetLength(Lines[I].Line, 1);

      Lines[I].Line[0].HighNote := -1;
      Lines[I].Line[0].LastLine := false;
      Lines[I].Line[0].BaseNote := High(Integer);
      Lines[I].Line[0].TotalNotes := 0;
    end;

    Self.MD5 := ''; //it needed because this method is called twice
    repeat
    begin
      LinePos := 1;
      Param0 := CurLine[1];
      Inc(LinePos);
      case Param0 of
        'P': //player selector
          begin
            Param1 := StrToInt(CurLine[IfThen((CurLine[2] = ' '), 3, 2)]);
            if (Param1 = 1) then
              CP := IfThen(not(DuetChange), 0, 1)
            else if (Param1 = 2) then
              CP := IfThen(not(DuetChange), 1, 0)
            else if (Param1 = 3) then
              CP := 2
            else
            begin
              Log.LogError('Wrong P-Number in file: "' + FileName.ToNative + '"; Line '+IntToStr(Self.FileLineNo)+' (LoadSong)');
              Result := False;
              Exit;
            end;
          end;
        ':', '*', 'F', 'R', 'G': //notes
          begin
            // sets the rap icon if the song has rap notes
            if(Param0 in ['R', 'G']) then
              Self.hasRap := true;

            Param1 := ParseLyricIntParam(CurLine, LinePos);
            Param2 := ParseLyricIntParam(CurLine, LinePos);
            Param3 := ParseLyricIntParam(CurLine, LinePos);
            ParamLyric := ParseLyricText(CurLine, LinePos);

            //Check for ZeroNote
            if Param2 = 0 then
            begin
              Log.LogWarn(
                '"'+Self.FullPath+'" in line '+IntToStr(Self.FileLineNo)+': found note with length zero -> converted to FreeStyle',
                'TSong.LoadSong'
              );
              Param0 := 'F';
            end;

            // add notes
            if (CP <> 2) then
            begin // P1 or P2
              if (Lines[CP].High < 0) or (Lines[CP].High > 5000) then
              begin
                Log.LogError('Found faulty song. Did you forget a P1 or P2 tag? "'+Param0+' '+IntToStr(Param1)+
                ' '+IntToStr(Param2)+' '+IntToStr(Param3)+ParamLyric+'" -> '+
                Self.FullPath+' Line:'+IntToStr(Self.FileLineNo));
                Break;
              end;
              ParseNote(CP, Param0, Param1, Param2, Param3, ParamLyric);
            end
            else // P1 + P2
            begin
              ParseNote(0, Param0, Param1, Param2, Param3, ParamLyric);
              ParseNote(1, Param0, Param1, Param2, Param3, ParamLyric);
            end;
          end;
        '-': //end of line
          begin
            Param1 := ParseLyricIntParam(CurLine, LinePos);
            NewSentence(0, Param1);
            if Self.isDuet then
              NewSentence(1, Param1);
          end;
        'E': //it needed for MD5 generation
        else //other character included final E
          Break;
      end;
      Self.MD5 := Self.MD5+CurLine;
      Inc(Self.FileLineNo);
    end
    until not Self.SongFile.ReadLine(CurLine);
  except
    on E: Exception do
    begin
      Log.LogError(Format('Error loading file: "%s" in line %d,%d: %s', [Self.FullPath, Self.FileLineNo, LinePos, E.Message]));
      Exit;
    end;
  end;

  for I := 0 to High(Lines) do
  begin
    if (Length(Lines[I].Line) < 2) then
    begin
      LastError := 'ERROR_CORRUPT_SONG_NO_BREAKS';
      Log.LogError('Error loading file: Can''t find any linebreaks in "'+Self.FullPath+'"');
      Exit;
    end;

    if (Lines[I].Line[Lines[I].High].HighNote < 0) then
    begin
      SetLength(Lines[I].Line, Lines[I].Number - 1);
      Lines[I].High := Lines[I].High - 1;
      Lines[I].Number := Lines[I].Number - 1;
      // HACK DUET ERROR
      if not (Self.isDuet) then
        Log.LogError('Error loading Song, sentence w/o note found in last line before E: '+Self.FullPath);
    end;
  end;

  for I := 0 to High(Lines) do
  begin
    if (High(Lines[I].Line) >= 0) then
      Lines[I].Line[High(Lines[I].Line)].LastLine := true;
  end;

  I := Self.Lines[0].Line[High(Self.Lines[0].Line)].Note[High(Self.Lines[0].Line[High(Self.Lines[0].Line)].Note)].End_;
  if (Self.Medley.StartBeat > I) or (Self.Medley.EndBeat > I) then
  begin
    Log.LogError('Medley out of range: '+Self.FullPath);
    Exit;
  end;

  //TODO idk why do it only in windows
  {$IFDEF MSWINDOWS}
    Self.MD5 := MD5Print(MD5String(Self.MD5));
  {$ELSE}
    Self.MD5 := 'unknown';
  {$ENDIF}
  Result := true;
end;

{**
 * "International" StrToFloat variant. Uses either ',' or '.' as decimal
 * separator.
 *}
function StrToFloatI18n(const Value: string): extended;
var
  TempValue : string;
begin
  TempValue := Value;
  if (Pos(',', TempValue) <> 0) then
    TempValue[Pos(',', TempValue)] := '.';
  Result := StrToFloatDef(TempValue, 0);
end;

function TSong.ReadTxtHeader(): boolean;
var
  Line, Identifier: string;
  Position: integer; //position on file to back to last line after finish read headers
  Value: string;
  SepPos: integer; // separator position
  Done: byte;      // bit-vector of mandatory fields
  MedleyFlags: byte; //bit-vector for medley/preview tags
  EncFile: IPath; // encoded filename
begin
  Result := true;
  Done := 0;
  MedleyFlags := 0;
  Position := 0;
  Self.BPM := 0;

  //Read first Line
  Self.SongFile.ReadLine(Line);
  if (Length(Line) <= 0) then
  begin
    Log.LogError('File starts with empty line: '+Self.FullPath, 'TSong.ReadTXTHeader');
    Result := false;
    Exit;
  end;

  // check if file begins with a UTF-8 BOM, if so set encoding to UTF-8
  if (CheckReplaceUTF8BOM(Line)) then
    Self.Encoding := encUTF8
  else
    Self.Encoding := encAuto;

  //Read Lines while Line starts with # or its empty
  //Log.LogDebug(Line,'TSong.ReadTXTHeader');
  while (Length(Line) > 0) and (Line[1] = '#') do
  begin
    //Increase Line Number
    Inc(Self.FileLineNo);
    SepPos := Pos(':', Line);

    //Line has no Seperator, ignore non header field
    if (SepPos = 0) and not (Self.SongFile.ReadLine(Line)) then
    begin
      Result := false;
      Log.LogError('File incomplete or not Ultrastar txt (A): '+Self.FullPath);
      Break;
    end;

    //Read Identifier and Value
    Identifier := UpperCase(Trim(Copy(Line, 2, SepPos - 2))); //Uppercase is for Case Insensitive Checks
    Value := Trim(Copy(Line, SepPos + 1, Length(Line) - SepPos));

    //Check the Identifier (If Value is given)
    if Length(Value) = 0 then
      Log.LogInfo('Empty field "'+Identifier+'" in file '+Self.FullPath, 'TSong.ReadTxtHeader')
    else
    begin
      case Identifier of
        //required attributes
        'TITLE':
        begin
          Self.Title := DecodeStringUTF8(Value, Encoding);
          Self.TitleNoAccent := UCommon.RemoveSpecialChars(Self.Title);
          Done := Done or 1;
        end;
        'ARTIST':
        begin
          Self.Artist := DecodeStringUTF8(Value, Encoding);
          Self.ArtistNoAccent := UCommon.RemoveSpecialChars(Self.Artist);
          Done := Done or 2;
        end;
        'MP3': //sound source file
        begin
          EncFile := DecodeFilename(Value);
          if (Self.Path.Append(EncFile).IsFile()) then
          begin
            Self.Mp3 := EncFile;
            Done := Done or 4;
          end
          else
            Log.LogError('Can''t find audio file in song: '+Self.FullPath);
        end;
        'BPM': //beats per minute
        begin
          Self.BPM := StrToFloatI18n(Value)*4;
          if Self.BPM <> 0 then
            Done := Done or 8
          else
            Log.LogError('Was not able to convert String '+Self.FullPath+'"'+Value +'" to number.');
        end;
        //additional header information
        'GAP':
          Self.GAP := StrToFloatI18n(Value);
        'COVER': //cover picture
          Self.Cover := DecodeFilename(Value);
        'BACKGROUND': //background picture
          Self.Background := DecodeFilename(Value);
        'VIDEO': //video file
        begin
          EncFile := DecodeFilename(Value);
          if (Self.Path.Append(EncFile).IsFile) then
            Self.Video := EncFile
          else
            Log.LogError('Can''t find video file in song: '+Self.FullPath);
        end;
        'VIDEOGAP': //video gap
          Self.VideoGAP := StrToFloatI18n(Value);
        'GENRE': //genre sorting
          DecodeStringUTF8(Value, Genre, Encoding);
        'EDITION': //edition sorting
          DecodeStringUTF8(Value, Edition, Encoding);
        'LANGUAGE': //language sorting
          DecodeStringUTF8(Value, Language, Encoding);
        'YEAR': //year sorting
          TryStrtoInt(Value, Self.Year);
        'CREATOR': //name or names of song creators
          DecodeStringUTF8(Value, Creator, Encoding);
        'FIXER': //name or names of song fixers
          DecodeStringUTF8(Value, Fixer, Encoding);
        'START': //song start in seconds
          Self.Start := StrToFloatI18n(Value);
        'END': //song end in miliseconds
          TryStrtoInt(Value, Self.Finish);
        'ENCODING': //@deprecated file encoding
          Self.Encoding := ParseEncoding(Value, Ini.DefaultEncoding);
        'MEDLEYSTARTBEAT': //beat position to medley starts
          if TryStrtoInt(Value, Self.Medley.StartBeat) then
            MedleyFlags := MedleyFlags or 2;
        'MEDLEYENDBEAT': //beat position to medley ends
          if TryStrtoInt(Value, Self.Medley.EndBeat) then
            MedleyFlags := MedleyFlags or 4;
        'DUETSINGERP1': //singer name of first voice in a duet
          DecodeStringUTF8(Value, DuetNames[0], Encoding);
        'DUETSINGERP2': //singer name of second voice in a duet
          DecodeStringUTF8(Value, DuetNames[1], Encoding);
      end; // End check for non-empty Value
    end;
    Position := Self.SongFile.Position;
    // read next line
    if not Self.SongFile.ReadLine(Line) then
    begin
      Result := false;
      Log.LogError('File incomplete or not Ultrastar txt (A): '+Self.FullPath);
      Break;
    end;
  end; // while
  Self.SongFile.Position := Position; //back to last header line

  //Check if all Required Values are given
  if (Done <> 15) then
  begin
    Result := false;
    if (Done and 8) = 0 then      //No BPM Flag
      Log.LogError('File contains empty lines or BPM tag missing: '+Self.FullPath)
    else if (Done and 4) = 0 then //No MP3 Flag
      Log.LogError('MP3 tag/file missing: '+Self.FullPath)
    else if (Done and 2) = 0 then //No Artist Flag
      Log.LogError('Artist tag missing: '+Self.FullPath)
    else if (Done and 1) = 0 then //No Title Flag
      Log.LogError('Title tag missing: '+Self.FullPath)
    else //unknown Error
      Log.LogError('File incomplete or not Ultrastar txt (B - '+ inttostr(Done) +'): '+Self.FullPath);
  end
  else
  begin //check medley tags
    if (MedleyFlags and 6) = 6 then //MedleyStartBeat and MedleyEndBeat are both set
    begin
      if Self.Medley.StartBeat >= Self.Medley.EndBeat then
        MedleyFlags := MedleyFlags - 6;
    end;

    if (MedleyFlags and 1) = 0 then //PreviewStart is not set or <=0
    begin
      if (MedleyFlags and 2) = 2 then
        Self.PreviewStart := UNote.GetTimeFromBeat(Self.Medley.StartBeat, Self)  //fallback to MedleyStart
      else
        Self.PreviewStart := 0; //else set it to 0, it will be set in FindRefrainStart
    end;

    if (MedleyFlags and 6) = 6 then
      Self.Medley.Source := msTag
    else
      Self.Medley.Source := msNone;
  end;
end;

function  TSong.GetErrorLineNo: integer;
begin
  if (LastError='ERROR_CORRUPT_SONG_ERROR_IN_LINE') then
    Result := Self.FileLineNo
  else
    Result := -1;
end;

procedure TSong.ParseNote(LineNumber: integer; TypeP: char; StartP, DurationP, NoteP: integer; LyricS: UTF8String);
begin

  with Lines[LineNumber].Line[Lines[LineNumber].High] do
  begin
    SetLength(Note, Length(Note) + 1);
    HighNote := High(Note);

    Note[HighNote].Start := StartP;
    if HighNote = 0 then
    begin
      if Lines[LineNumber].Number = 1 then
        Start := -100;
        //Start := Note[HighNote].Start;
    end;

    Note[HighNote].Length := DurationP;

    // back to the normal system with normal, golden and now freestyle notes
    case TypeP of
      'F':  Note[HighNote].NoteType := ntFreestyle;
      ':':  Note[HighNote].NoteType := ntNormal;
      '*':  Note[HighNote].NoteType := ntGolden;
      'R':  Note[HighNote].NoteType := ntRap;
      'G':  Note[HighNote].NoteType := ntRapGolden;
    end;

    //add this notes value ("notes length" * "notes scorefactor") to the current songs entire value
    Inc(Lines[LineNumber].ScoreValue, Note[HighNote].Length * ScoreFactor[Note[HighNote].NoteType]);

    //and to the current lines entire value
    Inc(TotalNotes, Note[HighNote].Length * ScoreFactor[Note[HighNote].NoteType]);


    Note[HighNote].Tone := NoteP;

    //if a note w/ a deeper pitch then the current basenote is found
    //we replace the basenote w/ the current notes pitch
    if Note[HighNote].Tone < BaseNote then
      BaseNote := Note[HighNote].Tone;

    Note[HighNote].Color := 1; // default color to 1 for editor

    DecodeStringUTF8(LyricS, Note[HighNote].Text, Encoding);
    Lyric := Lyric + Note[HighNote].Text;

    End_ := Note[HighNote].Start + Note[HighNote].Length;
  end; // with
end;

procedure TSong.NewSentence(LineNumberP: integer; Param1: integer);
begin

  if (Lines[LineNumberP].Line[Lines[LineNumberP].High].HighNote  <> -1) then
  begin //create a new line
    SetLength(Lines[LineNumberP].Line, Lines[LineNumberP].Number + 1);
    Inc(Lines[LineNumberP].High);
    Inc(Lines[LineNumberP].Number);
  end
  else
  begin //use old line if it there were no notes added since last call of NewSentence
    // HACK DUET ERROR
    if not (Self.isDuet) then
      Log.LogError('Error loading Song, sentence w/o note found in line '+InttoStr(Self.FileLineNo)+': '+Filename.ToNative);
  end;

  Lines[LineNumberP].Line[Lines[LineNumberP].High].HighNote := -1;

  //set the current lines value to zero
  //it will be incremented w/ the value of every added note
  Lines[LineNumberP].Line[Lines[LineNumberP].High].TotalNotes := 0;

  //basenote is the pitch of the deepest note, it is used for note drawing.
  //if a note with a less value than the current sentences basenote is found,
  //basenote will be set to this notes pitch. Therefore the initial value of
  //this field has to be very high.
  Lines[LineNumberP].Line[Lines[LineNumberP].High].BaseNote := High(Integer);
  Lines[LineNumberP].Line[Lines[LineNumberP].High].Start := Param1;
  Lines[LineNumberP].Line[Lines[LineNumberP].High].LastLine := false;
end;

{* new procedure for preview
   tries find out the beginning of a refrain
   and the end... *}
procedure TSong.FindRefrain();
Const
  MEDLEY_MIN_DURATION = 40;   //minimum duration of a medley-song in seconds

Type
  TSeries = record
    start:    integer; //Start sentence of series
    end_:     integer; //End sentence of series
    len:      integer; //Length of sentence series
  end;

var
  I, J, K, num_lines:   integer;
  sentences:            array of UTF8String;
  series:               array of TSeries;
  temp_series:          TSeries;
  max:                  integer;
  len_lines, len_notes: integer;
  found_end:            boolean;
begin
  if UIni.Ini.FindUnsetMedley = 0 then
    Exit();

  num_lines := Length(Lines[0].Line);
  SetLength(sentences, num_lines);

  //build sentences array
  for I := 0 to num_lines - 1 do
  begin
    sentences[I] := '';
    for J := 0 to Length(Lines[0].Line[I].Note) - 1 do
    begin
      if (Lines[0].Line[I].Note[J].NoteType <> ntFreestyle) then
        sentences[I] := sentences[I] + Lines[0].Line[I].Note[J].Text;
    end;
  end;

  //find equal sentences series
  SetLength(series, 0);

  for I := 0 to num_lines - 2 do
  begin
    for J := I + 1 to num_lines - 1 do
    begin
      if sentences[I] = sentences[J] then
      begin
        temp_series.start := I;
        temp_series.end_  := I;

        if (J + J - I - 1 > num_lines - 1) then
          max:=num_lines-1-J
        else
          max:=J-I-1;

        for K := 1 to max do
        begin
          if sentences[I+K] = sentences[J+K] then
            temp_series.end_ := I+K
          else
            break;
        end;
        temp_series.len := temp_series.end_ - temp_series.start + 1;
        SetLength(series, Length(series)+1);
        series[Length(series)-1] := temp_series;
      end;
    end;
  end;

  //search for longest sequence
  max := 0;
  if Length(series) > 0 then
  begin
    for I := 0 to Length(series) - 1 do
    begin
      if series[I].len > series[max].len then
        max := I;
    end;
  end;

  len_lines := length(Lines[0].Line);

  if (Length(series) > 0) and (series[max].len > 3) then
  begin
    Self.Medley.StartBeat := Lines[0].Line[series[max].start].Note[0].Start;
    len_notes := length(Lines[0].Line[series[max].end_].Note);
    Self.Medley.EndBeat := Lines[0].Line[series[max].end_].Note[len_notes - 1].Start +
      Lines[0].Line[series[max].end_].Note[len_notes - 1].Length;

    found_end := false;

    //set end if duration > MEDLEY_MIN_DURATION
    if UNote.GetTimeFromBeat(Self.Medley.StartBeat) + MEDLEY_MIN_DURATION >
      UNote.GetTimeFromBeat(Self.Medley.EndBeat) then
    begin
      found_end := true;
    end;

    //estimate the end: just go MEDLEY_MIN_DURATION
    //ahead an set to a line end (if possible)
    if not found_end then
    begin
      for I := series[max].start + 1 to len_lines - 1 do
      begin
        len_notes := length(Lines[0].Line[I].Note);
        for J := 0 to len_notes - 1 do
        begin
          if UNote.GetTimeFromBeat(Self.Medley.StartBeat) + MEDLEY_MIN_DURATION >
            UNote.GetTimeFromBeat(Lines[0].Line[I].Note[J].Start +
            Lines[0].Line[I].Note[J].Length) then
          begin
            found_end := true;
            Self.Medley.EndBeat := Lines[0].Line[I].Note[len_notes-1].Start +
              Lines[0].Line[I].Note[len_notes - 1].Length;
            break;
          end;
        end;
      end;
    end;

    if found_end then
      Self.Medley.Source := msCalculated;
  end;

  //set PreviewStart if not set
  if Self.PreviewStart = 0 then
  begin
    if Self.Medley.Source = msCalculated then
      Self.PreviewStart := UNote.GetTimeFromBeat(Self.Medley.StartBeat);
  end;
end;

//sets a song to medley-mode:
//converts all unneeded notes into freestyle
//updates score values
procedure TSong.SetMedleyMode();
var
  pl, line, note: integer;
  cut_line: array of integer;
  foundcut: array of boolean;
  MedleyStart: integer;
  MedleyEnd: integer;
begin
  MedleyStart := Self.Medley.StartBeat;
  MedleyEnd  := Self.Medley.EndBeat;
  SetLength(cut_line, Length(Lines));
  SetLength(foundcut, Length(Lines));

  for pl := 0 to Length(Lines) - 1 do
  begin
    foundcut[pl] := false;
    cut_line[pl] := high(Integer);
    Lines[pl].ScoreValue := 0;
    for line := 0 to Length(Lines[pl].Line) - 1 do
    begin
      Lines[pl].Line[line].TotalNotes := 0;
      for note := 0 to Length(Lines[pl].Line[line].Note) - 1 do
      begin
        if Lines[pl].Line[line].Note[note].Start < MedleyStart then      //check start
        begin
          Lines[pl].Line[line].Note[note].NoteType := ntFreeStyle;
        end else if Lines[pl].Line[line].Note[note].Start>= MedleyEnd then  //check end
        begin
          Lines[pl].Line[line].Note[note].NoteType := ntFreeStyle;
          if not foundcut[pl] then
          begin
            if (note=0) then
              cut_line[pl] := line
            else
              cut_line[pl] := line + 1;
          end;
          foundcut[pl] := true;
        end
        else
        begin
          //add this notes value ("notes length" * "notes scorefactor") to the current songs entire value
          Inc(Lines[pl].ScoreValue, Lines[pl].Line[line].Note[note].Length * ScoreFactor[Lines[pl].Line[line].Note[note].NoteType]);
          //and to the current lines entire value
          Inc(Lines[pl].Line[line].TotalNotes, Lines[pl].Line[line].Note[note].Length * ScoreFactor[Lines[pl].Line[line].Note[note].NoteType]);
        end;
      end;
    end;
  end;

  for pl := 0 to Length(Lines) - 1 do
  begin
    if (foundcut[pl]) and (Length(Lines[pl].Line) > cut_line[pl]) then
    begin
      SetLength(Lines[pl].Line, cut_line[pl]);
      Lines[pl].High := cut_line[pl]-1;
      Lines[pl].Number := Lines[pl].High+1;
    end;
  end;
end;

function TSong.Analyse(DuetChange: boolean): boolean;
begin
  Result := false;

  //Reset LineNo
  Self.FileLineNo := 0;

  //Open File and set File Pointer to the beginning
  try
    Self.SongFile := TMemTextFileStream.Create(Self.Path.Append(Self.FileName), fmOpenRead);
  except
    begin
      LastError := 'ERROR_CORRUPT_SONG_FILE_NOT_FOUND';
      Log.LogError('File not found: "'+Self.Path.Append(Self.FileName).ToNative()+'"', 'TSong.LoadSong()');
      Exit;
    end;
  end;

  try
    Result := Self.ReadTxTHeader() and Self.LoadSong(DuetChange);
    if Result then
    begin
      UNote.CurrentSong := Self;
      if (not Self.isDuet) and (Self.Medley.Source = msNone) then //TODO needed a little bit more work to find refrains in duets
        Self.FindRefrain();
    end;
  except
    Log.LogError('Reading headers from file failed. File incomplete or not Ultrastar txt?: ' + Self.Path.Append(Self.FileName).ToUTF8(true));
  end;
  Self.SongFile.Free;
end;
end.
