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

unit USongs;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  Classes,
  {$IFDEF MSWINDOWS}
    Windows,
    LazUTF8Classes,
  {$ELSE}
    baseunix,
    cthreads,
    cmem,
    {$IFNDEF DARWIN}
    syscall,
    {$ENDIF}
    UnixType,
  {$ENDIF}
  CpuCount,
  sdl2,
  SysUtils,
  UCatCovers,
  UCommon,
  UImage,
  UIni,
  ULog,
  UPath,
  UPlatform,
  UPlaylist,
  USong,
  UTexture;

type
  TSongFilter = (sfAll, sfArtist, sfCategory, sfPlaylist, sfTitle);

  TScore = record
    Name:   UTF8String;
    Score:  integer;
    Length: string;
  end;

  TProgressSong = record
    Folder: UTF8String;
    FolderProcessed: UTF8String;
    Total: integer;
    Finished: boolean;
    CoversPreload: boolean;
  end;

  TSongsParse = class(TThread)
    private
      Event: PRTLEvent; //event to fire parsing songs
      TxtParsed: integer; //number of txts parsed
      TxtsParsed: TList; //list to store all parsed songs as TSong object
      Txts: TList; //list to store only correct songs from TxtsParsed
    protected
      procedure Execute; override;
    public
      constructor Create();
      destructor Destroy(); override;
      procedure AddSong(const TxtFile: IPath);
      function GetTxtParsed(): integer;
      function GetTxts(): TList;
  end;

  TSongs = class(TThread)
    private
      Event: PRTLEvent; //event to fire cover preload
      PreloadCover: boolean;
      ProgressSong: TProgressSong;
      Threads: array of TSongsParse; //threads to parse songs
      Thread: integer; //current thread
      CoresAvailable: integer; //cores available for working threads
      procedure FindTxts(const Dir: IPath);
    protected
      procedure Execute; override;
    public
      SongList: TList; //array of songs
      Selected: integer; //selected song index
      constructor Create();
      destructor Destroy(); override;
      function GetLoadProgress(): TProgressSong;
      procedure PreloadCovers(Preload: boolean);
      procedure Sort(OrderType: TSortingType);
  end;

  TCatSongs = class
    private
      ShowDuets: boolean;
      ShowCategories: boolean;
      Sorting: integer;
      VisibleSongs: integer;
      procedure SortSongs();
    public
      Song: array of TSong; //songs categorized
      Selected: integer; //selected song index
      CatNumShow: integer; //selected category (-1 = all songs/all categories, -3 = playlist)
      CatCount: integer; //number of categories
      constructor Create();
      function FindGlobalIndex(VisibleIndex:integer): integer; //find global index of all songs from a index of visible songs subgroup
      function FindVisibleIndex(Index: integer): integer; //find the index of a song in the subset of all visible songs
      function GetVisibleSongs(): integer; //returns number of visible songs
      function IsFilterApplied(): boolean; //returns if some filter has been applied to song list
      function Refresh(Sort: integer; Categories: boolean; Duets: boolean): boolean; //sets sorting, show or not songs in categories and/or duets refreshing songs array
      function SetFilter(FilterStr: UTF8String; Filter: TSongFilter = sfAll): cardinal;
      function ShowCategory(Index: integer): integer; //show songs of a category
      procedure ShowPlaylist(Index: integer); //show songs of a playlist
  end;

var
  Songs: TSongs; //all songs
  CatSongs: TCatSongs; //categorized songs

implementation

uses
  FileUtil,
  Math,
  StrUtils,
  UFiles,
  UFilesystem,
  UGraphic,
  ULanguage,
  UMain,
  UNote,
  UPathUtils,
  UUnicodeUtils;

constructor TSongsParse.Create();
begin
  inherited Create(false);
  Self.Event := RTLEventCreate();
  Self.FreeOnTerminate := true;
  Self.TxtParsed := 0;
  Self.Txts := TList.Create();
  Self.TxtsParsed := TList.Create();
end;

destructor TSongsParse.Destroy();
begin
  RTLeventDestroy(Self.Event);
  Self.Txts.Free();
  Self.TxtsParsed.Free();
  inherited;
end;

procedure TSongsParse.Execute();
var
  Song: TSong;
  I: integer;
begin
  while not Self.Terminated do
  begin
    RtlEventWaitFor(Self.Event);
    for I := Self.TxtParsed to Self.TxtsParsed.Count - 1 do //start to parse from the last position
    begin
      Song := TSong(Self.TxtsParsed.Items[I]);
      if Song.Analyse() then
        Self.Txts.Add(Song);

      Inc(Self.TxtParsed);
    end;
  end;
end;

procedure TSongsParse.AddSong(const TxtFile: IPath);
begin
  Self.TxtsParsed.Add(USong.TSong.Create(TxtFile));
  RtlEventSetEvent(Self.Event);
end;

function TSongsParse.GetTxtParsed(): integer;
begin
  Result := Self.TxtParsed;
end;

function TSongsParse.GetTxts(): TList;
begin
  Result := Self.Txts;
end;

constructor TSongs.Create();
var
  I: integer;
begin
  inherited Create(false);
  Self.Event := RTLEventCreate();
  Self.FreeOnTerminate := false;
  Self.SongList := TList.Create();
  Self.Thread := 0;
  Self.CoresAvailable := Max(0, CpuCount.GetLogicalCpuCount() - 2); //total core - main and songs threads
  Setlength(Self.Threads, Self.CoresAvailable + 1);
  for I := 0 to Self.CoresAvailable do
    Self.Threads[I] := TSongsParse.Create();
end;

destructor TSongs.Destroy();
begin
  RTLeventDestroy(Self.Event);
  inherited;
end;

{ Search for all files and directories }
procedure TSongs.FindTxts(const Dir: IPath);
var
  FileInfo: TFileInfo;
  Iter: IFileIterator;
begin
  Iter := FileSystem.FileFind(Dir.Append('*'), faAnyFile);
  while Iter.HasNext do //content of current folder
  begin
    FileInfo := Iter.Next; //get file info
    if ((FileInfo.Attr and faDirectory) <> 0) and (not (FileInfo.Name.ToUTF8()[1] = '.')) then //if is a directory try to find more
    begin
      Self.ProgressSong.FolderProcessed := FileInfo.Name.ToNative();
      Self.FindTxts(Dir.Append(FileInfo.Name))
    end
    else if FileInfo.Name.GetExtension().ToNative() = '.txt' then //if is a txt file send to a thread to parse it
    begin
      Inc(Self.ProgressSong.Total);
      Self.Threads[Self.Thread].AddSong(Dir.Append(FileInfo.Name));
      if Self.Thread = Self.CoresAvailable then //each txt to one thread
        Self.Thread := 0
      else
        Inc(Self.Thread)
    end
  end;
end;

{ Create a new thread to load songs and update main screen with progress }
procedure TSongs.Execute();
var
  I, Processed: integer;
  Song: TSong;
begin
  Log.BenchmarkStart(2);
  Log.LogStatus('Searching for songs', 'SongList');
  Self.ProgressSong.Total := 0;
  Self.ProgressSong.Finished := false;
  Self.ProgressSong.CoversPreload := true;
  for I := 0 to UPathUtils.SongPaths.Count - 1 do //find txt files on directories and add songs
  begin
    Self.ProgressSong.Folder := Format(ULanguage.Language.Translate('SING_LOADING_SONGS'), [IPath(UPathUtils.SongPaths[I]).ToNative()]);
    Self.FindTxts(IPath(UPathUtils.SongPaths[I]));
  end;
  while not Self.ProgressSong.Finished do
  begin
    //wait a little to finish parsing last songs
    Processed := 0;
    for I := 0 to Self.CoresAvailable do
      Inc(Processed, Self.Threads[I].GetTxtParsed());

    if Processed = Self.ProgressSong.Total then
    begin
      for I := 0 to Self.CoresAvailable do
      begin
        Self.SongList.AddList(Self.Threads[I].GetTxts()); //add all songs parsed to main list
        Self.Threads[I].Terminate();
      end;

      Log.LogStatus('Search complete: '+IntToStr(Processed)+' songs found ('+IntToStr(Processed - Self.SongList.Count)+' with errors)', 'SongList');
      Self.ProgressSong.Folder := '';
      Self.ProgressSong.Finished := true;
      Log.LogBenchmark('Song loading', 2);

      //preloading covers in HDD cache only touching the file
      Log.BenchmarkStart(3);
      Self.PreloadCover := true;
      for I := 0 to Self.SongList.Count - 1 do
      begin
        Song := TSong(Self.SongList.Items[I]);
        if not Self.PreloadCover then
          RtlEventWaitFor(Self.Event);

        SDL_FreeSurface(UImage.LoadImage(Song.Path.Append(Song.Cover)));
      end;
      Self.ProgressSong.CoversPreload := false;
      Log.LogBenchmark('Cover loading', 3);
    end;
  end;
  Self.Terminate();
end;

function TSongs.GetLoadProgress(): TProgressSong;
begin
  Result := Self.ProgressSong;
end;

{* Start/stop the covers preloading *}
procedure TSongs.PreloadCovers(Preload: boolean);
begin
  Self.PreloadCover := Preload;
  if Preload then
    RtlEventSetEvent(Self.Event);
end;

(*
 * Comparison functions for sorting
 *)

function CompareByEdition(Song1, Song2: Pointer): integer;
begin
  Result := UTF8CompareText(TSong(Song1).Edition, TSong(Song2).Edition);
end;

function CompareByGenre(Song1, Song2: Pointer): integer;
begin
  Result := UTF8CompareText(TSong(Song1).Genre, TSong(Song2).Genre);
end;

function CompareByTitle(Song1, Song2: Pointer): integer;
begin
  Result := UTF8CompareText(TSong(Song1).TitleNoAccent, TSong(Song2).TitleNoAccent);
end;

function CompareByArtist(Song1, Song2: Pointer): integer;
begin
  Result := UTF8CompareText(TSong(Song1).ArtistNoAccent, TSong(Song2).ArtistNoAccent);
end;

function CompareByFolder(Song1, Song2: Pointer): integer;
begin
  Result := UTF8CompareText(TSong(Song1).Folder, TSong(Song2).Folder);
end;

function CompareByLanguage(Song1, Song2: Pointer): integer;
begin
  Result := UTF8CompareText(TSong(Song1).Language, TSong(Song2).Language);
end;

function CompareByYear(Song1, Song2: Pointer): integer;
begin
  if (TSong(Song1).Year > TSong(Song2).Year) then
    Result := 1
  else
    Result := 0;
end;

procedure TSongs.Sort(OrderType: TSortingType);
var
  CompareFunc: TListSortCompare;
begin
  // FIXME: what is the difference between artist and artist2, etc.?
  case OrderType of
    sEdition: // by edition
      CompareFunc := @CompareByEdition;
    sGenre: // by genre
      CompareFunc := @CompareByGenre;
    sTitle: // by title
      CompareFunc := @CompareByTitle;
    sArtist: // by artist
      CompareFunc := @CompareByArtist;
    sFolder: // by folder
      CompareFunc := @CompareByFolder;
    sArtist2: // by artist2
      CompareFunc := @CompareByArtist;
    sLanguage: // by Language
      CompareFunc := @CompareByLanguage;
    sYear: // by Year
      CompareFunc := @CompareByYear;
    sDecade: // by Decade
      CompareFunc := @CompareByYear;
    else
      Log.LogCritical('Unsupported comparison', 'TSongs.Sort');
      Exit; // suppress warning
  end; // case

  // Note: Do not use TList.Sort() as it uses QuickSort which is instable.
  // For example, if a list is sorted by title first and
  // by artist afterwards, the songs of an artist will not be sorted by title anymore.
  // The stable MergeSort guarantees to maintain this order.
  MergeSort(Self.SongList, CompareFunc);
end;

constructor TCatSongs.Create();
begin
  Self.ShowDuets := true;
  Self.ShowCategories := false;
  Self.Sorting := -1;
  Self.VisibleSongs := 0;
end;

procedure TCatSongs.SortSongs();
begin
  case TSortingType(Self.Sorting) of
    sEdition:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist);
        Songs.Sort(sEdition);
      end;
    sGenre:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist);
        Songs.Sort(sGenre);
      end;
    sLanguage:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist);
        Songs.Sort(sLanguage);
      end;
    sFolder:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist);
        Songs.Sort(sFolder);
      end;
    sTitle:
        Songs.Sort(sTitle);
    sArtist:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist);
      end;
    sArtist2:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist2);
      end;
    sYear:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist);
        Songs.Sort(sYear);
      end;
    sDecade:
      begin
        Songs.Sort(sTitle);
        Songs.Sort(sArtist);
        Songs.Sort(sYear);
      end;
  end; // case
end;

{* Find global index of all songs from a index of visible songs subgroup  *}
function TCatSongs.FindGlobalIndex(VisibleIndex:integer): integer;
begin
  if (not Self.IsFilterApplied()) or (Self.GetVisibleSongs() = 0) then
    Result := VisibleIndex
  else
  begin
    Result := -1;
    while VisibleIndex >= 0 do
    begin
      Inc(Result);
      if Self.Song[Result].Visible then
        Dec(VisibleIndex);
    end;
  end;
end;

(* Returns the index of a song in the subset of all visible songs *)
function TCatSongs.FindVisibleIndex(Index: integer): integer;
var
  SongIndex: integer;
begin
  if not Self.IsFilterApplied() then
    Result := Index
  else
  begin
    Result := 0;
    for SongIndex := 0 to Index - 1 do
    begin
      if Self.Song[SongIndex].Visible then
        Inc(Result);
    end;
  end;
end;

{* Returns number of visible songs *}
function TCatSongs.GetVisibleSongs(): integer;
begin
  Result := Self.VisibleSongs;
end;

{* Returns if some filter has been applied to song list *}
function TCatSongs.IsFilterApplied(): boolean;
begin
  Result := Self.VisibleSongs < High(Self.Song) + 1;
end;

{* Sets sorting, show or not songs in categories and/or duets refreshing songs array *}
function TCatSongs.Refresh(Sort: integer; Categories: boolean; Duets: boolean): boolean;
var
  I: integer;
  NewSong, NewCategory: TSong;
  CurCategory, CategoryName, tmpCategory: UTF8String;
begin
  Result := false;
  if (Self.VisibleSongs = 0) or (Self.Sorting <> Sort) or (Self.ShowCategories <> Categories) or (Self.ShowDuets <> Duets) then
  begin
    Result := true;
    Self.Selected := 0;
    Self.Sorting := Sort;
    Self.ShowCategories := Categories;
    Self.ShowDuets := Duets;
    Self.CatCount := 0;
    Self.CatNumShow := -1;
    Self.VisibleSongs := 0;
    Self.SortSongs();
    CurCategory := '';
    SetLength(Self.Song, 0);
    NewCategory := nil;
    for I := 0 to Songs.SongList.Count - 1 do
    begin
      NewSong := TSong(Songs.SongList[I]);
      if Self.ShowDuets or (not NewSong.isDuet) then //add a new song
      begin
        Inc(Self.VisibleSongs);
        if Self.ShowCategories then
        begin
          CategoryName := '';
          case (TSortingType(Self.Sorting)) of
            sEdition:
              if (CompareText(CurCategory, NewSong.Edition) <> 0) then
                CategoryName := NewSong.Edition;
            sGenre:
              if (CompareText(CurCategory, NewSong.Genre) <> 0) then
                CategoryName := NewSong.Genre;
            sLanguage:
              if (CompareText(CurCategory, NewSong.Language) <> 0) then
                CategoryName := NewSong.Language;
            sTitle:
              if (Length(NewSong.TitleNoAccent) > 0) and (UTF8CompareText(CurCategory, NewSong.TitleNoAccent[1]) <> 0) then
                CategoryName := UTF8UpperCase(NewSong.TitleNoAccent[1]);
            sArtist:
              if (Length(NewSong.ArtistNoAccent) > 0) and (UTF8CompareText(CurCategory, NewSong.ArtistNoAccent[1]) <> 0) then
                CategoryName := UTF8UpperCase(NewSong.ArtistNoAccent[1]);
            sFolder:
              if (UTF8CompareText(CurCategory, NewSong.Folder) <> 0) then
                CategoryName := NewSong.Folder;
            sArtist2:
              { this new sorting puts all songs by the same artist into
                a single category }
              if (UTF8CompareText(CurCategory, NewSong.Artist) <> 0) then
                CategoryName := NewSong.Artist;
            sYear:
            begin
               tmpCategory := IfThen(NewSong.Year <> 0, IntToStr(NewSong.Year), '-');
               if (tmpCategory <> CurCategory) then
                 CategoryName := tmpCategory;
             end;
            sDecade:
            begin
              tmpCategory := IfThen(Length(IntToStr(NewSong.Year)) = 4, UTF8Copy(IntToStr(NewSong.Year), 1, 3)+'0', '-');
              if (tmpCategory <> CurCategory) then
                CategoryName := tmpCategory;
            end;
          end;
          if CategoryName <> '' then //add a new category if needed
          begin
            CurCategory := CategoryName;
            Inc(Self.CatCount);
            NewCategory := TSong.Create();
            NewCategory.Artist := CategoryName;
            NewCategory.CatNumber := 0;
            NewCategory.Cover := UCatCovers.CatCovers.GetCover(TSortingType(Self.Sorting), CategoryName);
            NewCategory.Main := true;
            NewCategory.OrderNum := Self.CatCount;
            NewCategory.Visible := true;
            SetLength(Self.Song, Self.VisibleSongs);
            Self.Song[Self.VisibleSongs - 1] := NewCategory;
            Inc(Self.VisibleSongs);
          end;
          Inc(NewCategory.CatNumber);
          NewSong.CatNumber := NewCategory.CatNumber;
          NewSong.OrderNum := Self.CatCount;
          NewSong.Visible := false;
        end
        else
        begin
          NewSong.CatNumber := Self.VisibleSongs;
          NewSong.OrderNum := 0;
          NewSong.Visible := true;
        end;
        NewSong.Main := false;
        SetLength(Self.Song, Self.VisibleSongs);
        Self.Song[Self.VisibleSongs - 1] := NewSong;
      end;
    end;
    UPlaylist.PlayListMan.LoadPlayLists();
  end;
end;

function TCatSongs.SetFilter(FilterStr: UTF8String; Filter: TSongFilter = sfAll): cardinal;
var
  I, J:      integer;
  TmpString: UTF8String;
  WordArray: array of UTF8String;
begin
  Result := 0;
  if FilterStr <> '' then //FIXME required because fails when cancel a search without results
    FilterStr := UCommon.RemoveSpecialChars(FilterStr);

  if FilterStr <> '' then
  begin
    Self.CatNumShow := -2;
    // initialize word array
    SetLength(WordArray, 1);

    // Copy words to SearchStr
    I := Pos(' ', FilterStr);
    while (I <> 0) do
    begin
      WordArray[High(WordArray)] := Copy(FilterStr, 1, I-1);
      SetLength(WordArray, Length(WordArray) + 1);

      FilterStr := TrimLeft(Copy(FilterStr, I+1, Length(FilterStr)-I));
      I := Pos(' ', FilterStr);
    end;

    // Copy last word
    WordArray[High(WordArray)] := FilterStr;

    for I := 0 to High(Song) do
    begin
      if not Song[i].Main then
      begin
        case Filter of
          sfAll:
            TmpString := Song[I].ArtistNoAccent + ' ' + Song[i].TitleNoAccent; //+ ' ' + Song[i].Folder;
          sfTitle:
            TmpString := Song[I].TitleNoAccent;
          sfArtist:
            TmpString := Song[I].ArtistNoAccent;
          else
            TmpString := '';
        end;
        Song[i].Visible := true;
        // Look for every searched word
        for J := 0 to High(WordArray) do
          Song[i].Visible := Song[i].Visible and UTF8ContainsStr(TmpString, WordArray[J]);

        if Song[i].Visible then
          Inc(Result);
      end
      else
        Song[i].Visible := false;
    end
  end
  else
  begin
    Self.CatNumShow := -1;
    for I := 0 to High(Self.Song) do
    begin
      Self.Song[I].Visible := (Self.ShowCategories and Self.Song[I].Main)
        or ((not Self.ShowCategories) and (not Self.Song[I].Main) and (Self.ShowDuets or (not Self.Song[I].IsDuet)));

      if Self.Song[I].Visible then
        Inc(Result);
    end;
  end;
  Self.VisibleSongs := Result;
end;

{* Show songs of a category *}
function TCatSongs.ShowCategory(Index: integer): integer;
var
  I: integer;
begin
  Result := 0;
  Self.CatNumShow := Index;
  Self.VisibleSongs := 0;
  for I := 0 to High(Self.Song) do
  begin
    Self.Song[I].Visible := false;
    if Self.Song[I].OrderNum = Index then
      if Self.Song[I].Main then
      begin
        Result := I;
        Self.VisibleSongs := Self.Song[I].CatNumber
      end
      else
        Self.Song[I].Visible := true
  end
end;

{* Show songs of a playlistt *}
procedure TCatSongs.ShowPlaylist(Index: integer);
var
  I: integer;
begin
  Self.CatNumShow := -3;
  Self.VisibleSongs := Length(UPlaylist.PlayListMan.PlayLists[Index].Items);

  for I := 0 to High(Self.Song) do
    Self.Song[I].Visible := false;

  for I := 0 to Self.VisibleSongs - 1 do
    Self.Song[UPlaylist.PlayListMan.PlayLists[Index].Items[I].SongID].Visible := true;
end;

end.
