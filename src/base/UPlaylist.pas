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

unit UPlaylist;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  Classes,
  UIni,
  USong,
  UPath,
  UPathUtils;

type
  TPlaylistItem = record
    Artist: UTF8String;
    Title:  UTF8String;
    SongID: Integer;
  end;

  APlaylistItem = array of TPlaylistItem;

  TPlaylist = record
    Name:     UTF8String;
    Filename: IPath;
    Items:    APlaylistItem;
  end;

  APlaylist = array of TPlaylist;

  //----------
  //TPlaylistManager - Class for Managing Playlists (Loading, Displaying, Saving)
  //----------
  TPlaylistManager = class
    private

    public
      CurPlayList:  integer;
      CurItem:      Cardinal;

      Playlists:    APlaylist;

      constructor Create;
      procedure   LoadPlayLists;
      function    LoadPlayList(Index: Cardinal; const Filename: IPath): Boolean;
      procedure   SavePlayList(Index: Cardinal);

      function SetPlayList(Index: Cardinal): TPlayList;

      function    AddPlaylist(const Name: UTF8String): Cardinal;
      procedure   DelPlaylist(const Index: Cardinal);

      procedure   AddItem(const SongID: Cardinal; const iPlaylist: Integer = -1);
      procedure   DelItem(const iItem: Cardinal; const iPlaylist: Integer = -1);

      procedure   GetNames(var PLNames: array of UTF8String);
      function    GetIndexbySongID(const SongID: Cardinal; const iPlaylist: Integer = -1): Integer;
    end;

  var
    PlayListMan:  TPlaylistManager;


implementation

uses
  LazUTF8,
  SysUtils,
  USongs,
  ULog,
  UMain,
  UFilesystem,
  UGraphic,
  UThemes,
  UUnicodeUtils;

//----------
//Create - Construct Class - Dummy for now
//----------
constructor TPlayListManager.Create;
begin
  inherited;
  Self.CurPlayList := -1;
end;

//----------
//LoadPlayLists - Load list of Playlists from PlayList Folder
//----------
Procedure   TPlayListManager.LoadPlayLists;
var
  Len:  Integer;
  PlayListBuffer: TPlayList;
  Iter: IFileIterator;
  FileInfo: TFileInfo;
begin
  SetLength(Playlists, 0);

  Iter := FileSystem.FileFind(PlayListPath.Append('*.upl'), 0);
  while (Iter.HasNext) do
  begin
    Len := Length(Playlists);
    SetLength(Playlists, Len + 1);

    FileInfo := Iter.Next;

    if not LoadPlayList(Len, FileInfo.Name) then
      SetLength(Playlists, Len)
    else
    begin
      // Sort the Playlists - Insertion Sort
      PlayListBuffer := Playlists[Len];
      Dec(Len);
      while (Len >= 0) AND (CompareText(Playlists[Len].Name, PlayListBuffer.Name) >= 0) do
      begin
          Playlists[Len+1] := Playlists[Len];
          Dec(Len);
      end;
      Playlists[Len+1] := PlayListBuffer;
    end;
  end;
end;

//----------
//LoadPlayList - Load a Playlist in the Array
//----------
function TPlayListManager.LoadPlayList(Index: Cardinal; const Filename: IPath): Boolean;
var
  TextStream: TTextFileStream;
  Line: UTF8String;
  SongID: Integer;
  Len: Integer;
  FilenameAbs: IPath;
  I: Integer;
begin
  //Load File
  try
    FilenameAbs := PlaylistPath.Append(Filename);
    TextStream := TMemTextFileStream.Create(FilenameAbs, fmOpenRead);
  except
    begin
      Log.LogError('Could not load Playlist: ' + FilenameAbs.ToNative);
      Result := False;
      Exit;
    end;
  end;
  Result := True;

  //Set Filename
  Playlists[Index].Filename := Filename;
  Playlists[Index].Name := '';

  //Read Until End of File
  while TextStream.ReadLine(Line) do
  begin
    if (Length(Line) > 0) then
    begin
      if not UUnicodeUtils.IsUTF8String(Line) then //conver to UTF88 if needed to avoid problem with ANSI upl files from Ultrastar Manager
        Line := LazUTF8.WinCPToUTF8(Line);

      //Comment or Name String
      if UUnicodeUtils.UTF8StartsText('#name', Line) then //playlist name
      begin
        PlayLists[Index].Name := Copy(Line, 7, Length(Line) - 5);
        if PlayLists[Index].Name = '' then
          PlayLists[Index].Name := FileName.SetExtension('').ToUTF8;
      end
      else if Pos(' : ', Line) > 0 then //song entry
      begin
        SongID := -1;
        for I := low(CatSongs.Song) to high(CatSongs.Song) do
        begin
          if CatSongs.Song[I].Artist + ' : ' + CatSongs.Song[I].Title = Line then
          begin
            SongID := I;
            Break;
          end;
        end;
        if (SongID <> -1) then
        begin
          Len := Length(PlayLists[Index].Items);
          SetLength(PlayLists[Index].Items, Len + 1);
          PlayLists[Index].Items[Len].SongID := SongID;
          PlayLists[Index].Items[Len].Artist := CatSongs.Song[SongID].Artist;
          PlayLists[Index].Items[Len].Title := CatSongs.Song[SongID].Title;
        end
        else
          Log.LogError('Could not find Song in Playlist: ' + PlayLists[Index].Filename.ToNative + ', ' + Line);
      end;
    end;
  end;
  TextStream.Free;
end;

{**
 * Saves the specified Playlist
 *}
procedure   TPlayListManager.SavePlayList(Index: Cardinal);
var
  TextStream: TTextFileStream;
  PlaylistFile: IPath;
  I: Integer;
begin
  PlaylistFile := PlaylistPath.Append(Playlists[Index].Filename);

  // cannot update read-only file
  if PlaylistFile.IsFile() and PlaylistFile.IsReadOnly() then
    Exit;

  // open file for rewriting
  TextStream := TMemTextFileStream.Create(PlaylistFile, fmCreate);
  try
    // Write version (not nessecary but helpful)
    TextStream.WriteLine('######################################');
    TextStream.WriteLine('#Ultrastar WorldParty');
    TextStream.WriteLine(Format('#Playlist %s with %d Songs.',
                         [ Playlists[Index].Name, Length(Playlists[Index].Items) ]));
    TextStream.WriteLine('######################################');

    // Write name information
    TextStream.WriteLine('#Name: ' + Playlists[Index].Name);

    // Write song information
    TextStream.WriteLine('#Songs:');

    for I := 0 to high(Playlists[Index].Items) do
    begin
      TextStream.WriteLine(Playlists[Index].Items[I].Artist + ' : ' + Playlists[Index].Items[I].Title);
    end;
  except
    Log.LogError('Could not write Playlistfile "' + Playlists[Index].Name + '"');
  end;
  TextStream.Free;
end;

{**
 * Display a Playlist in CatSongs
 *}
function TPlayListManager.SetPlayList(Index: Cardinal): TPlaylist;
begin
  Self.CurPlaylist := Index;
  Result := Self.Playlists[Index];
end;

//----------
//AddPlaylist - Adds a Playlist and Returns the Index
//----------
function TPlayListManager.AddPlaylist(const Name: UTF8String): cardinal;
var
  I: Integer;
  PlaylistFile: IPath;
begin
  Result := Length(Playlists);
  SetLength(Playlists, Result + 1);

  // Sort the Playlists - Insertion Sort
  while (Result > 0) and (CompareText(Playlists[Result - 1].Name, Name) >= 0) do
  begin
    Dec(Result);
    Playlists[Result+1] := Playlists[Result];
  end;
  Playlists[Result].Name := Name;

  // clear playlist items
  SetLength(Playlists[Result].Items, 0);

  I := 1;
  PlaylistFile := PlaylistPath.Append(Name + '.upl');
  while (PlaylistFile.Exists) do
  begin
    Inc(I);
    PlaylistFile := PlaylistPath.Append(Name + InttoStr(I) + '.upl');
  end;
  Playlists[Result].Filename := PlaylistFile.GetName;

  //Save new Playlist
  SavePlayList(Result);
end;

//----------
//DelPlaylist - Deletes a Playlist
//----------
procedure   TPlayListManager.DelPlaylist(const Index: Cardinal);
var
  I: Integer;
  Filename: IPath;
begin
  if Int(Index) > High(Playlists) then
    Exit;

  Filename := PlaylistPath.Append(Playlists[Index].Filename);

  //If not FileExists or File is not Writeable then exit
  if (not Filename.IsFile()) or (Filename.IsReadOnly()) then
    Exit;


  //Delete Playlist from FileSystem
  if not Filename.DeleteFile() then
    Exit;

  //Delete Playlist from Array
  //move all PLs to the Hole
  for I := Index to High(Playlists)-1 do
    PlayLists[I] := PlayLists[I+1];

  //Delete last Playlist
  SetLength (Playlists, High(Playlists));

  //If Playlist is Displayed atm
  //-> Display Songs
  if (CatSongs.CatNumShow = -3) and (Index = CurPlaylist) then
    UGraphic.ScreenSong.SetSubselection();
end;

//----------
//AddItem - Adds an Item to a specific Playlist
//----------
Procedure   TPlayListManager.AddItem(const SongID: Cardinal; const iPlaylist: Integer);
var
  P: Cardinal;
  Len: Cardinal;
begin
  if iPlaylist = -1 then
    P := CurPlaylist
  else if (iPlaylist >= 0) AND (iPlaylist <= high(Playlists)) then
    P := iPlaylist
  else
    exit;

  if (Int(SongID) <= High(CatSongs.Song)) AND (NOT CatSongs.Song[SongID].Main) then
  begin
    Len := Length(Playlists[P].Items);
    SetLength(Playlists[P].Items, Len + 1);

    Playlists[P].Items[Len].SongID  := SongID;
    Playlists[P].Items[Len].Title   := CatSongs.Song[SongID].Title;
    Playlists[P].Items[Len].Artist  := CatSongs.Song[SongID].Artist;

    //Save Changes
    SavePlayList(P);
  end;
end;

//----------
//DelItem - Deletes an Item from a specific Playlist
//----------
Procedure   TPlayListManager.DelItem(const iItem: Cardinal; const iPlaylist: Integer);
var
  I: Integer;
  P: Cardinal;
begin
  if iPlaylist = -1 then
    P := CurPlaylist
  else if (iPlaylist >= 0) AND (iPlaylist <= high(Playlists)) then
    P := iPlaylist
  else
    exit;

  if (Int(iItem) <= high(Playlists[P].Items)) then
  begin
    //Move all entrys behind deleted one to Front
    For I := iItem to High(Playlists[P].Items) - 1 do
      Playlists[P].Items[I] := Playlists[P].Items[I + 1];

    //Delete Last Entry
    SetLength(PlayLists[P].Items, Length(PlayLists[P].Items) - 1);

    //Save Changes
    SavePlayList(P);
  end;

  //Delete Playlist if Last Song is deleted
  if (Length(PlayLists[P].Items) = 0) then
  begin
    DelPlaylist(P);
  end
  //Correct Display when Editing current Playlist
  else if (CatSongs.CatNumShow = -3) and (P = CurPlaylist) then
    UGraphic.ScreenSong.SetSubselection(Self.CurPlaylist, sfPlaylist);
end;

//----------
//GetNames - Writes Playlist Names in a Array
//----------
procedure TPlayListManager.GetNames(var PLNames: array of UTF8String);
var
  I, Len: Integer;
begin
  Len := High(Self.Playlists);
  if (Length(PLNames) <> Len + 1) then
    exit;

  for I := 0 to Len do
    PLNames[I] := Self.Playlists[I].Name+' ('+IntToStr(Length(Self.Playlists[I].Items))+')';
end;

//----------
//GetIndexbySongID - Returns Index in the specified Playlist of the given Song
//----------
Function    TPlayListManager.GetIndexbySongID(const SongID: Cardinal; const iPlaylist: Integer): Integer;
var
  P: Integer;
  I: Integer;
begin
  Result := -1;

  if iPlaylist = -1 then
    P := CurPlaylist
  else if (iPlaylist >= 0) AND (iPlaylist <= high(Playlists)) then
    P := iPlaylist
  else
    exit;

  For I := 0 to high(Playlists[P].Items) do
  begin
    if (Playlists[P].Items[I].SongID = Int(SongID)) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

end.
