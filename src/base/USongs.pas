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
  SysUtils,
  UCatCovers,
  UCommon,
  UIni,
  ULog,
  UPath,
  UPlatform,
  UPlaylist,
  USong,
  UTexture;

type
  TSongFilter = (
    fltAll,
    fltTitle,
    fltArtist
  );

  TScore = record
    Name:   UTF8String;
    Score:  integer;
    Length: string;
  end;

  TProgressSong = record
    Folder: UTF8String;
    Total: integer;
  end;

  TSongsParse = class(TThread)
    private
      Event: PRTLEvent; //event to fire parsing songs
      Txt: integer; //number of txts parsed
      Txts: TThreadList; //list to store all parsed songs as TSong object
    protected
      procedure Execute; override;
    public
      constructor Create();
      destructor Destroy(); override;
      procedure AddSong(const TxtFile: IPath);
  end;

  TSongs = class(TThread)
    private
      ProgressSong: TProgressSong;
      Threads: array of TSongsParse; //threads to parse songs
      Thread: integer; //current thread
      procedure FindTxts(const Dir: IPath);
    protected
      procedure Execute; override;
    public
      SongList: TList; //array of songs
      Selected: integer; //selected song index
      constructor Create();
      destructor Destroy(); override;
      function GetLoadProgress(): TProgressSong;
      procedure Sort(OrderType: TSortingType);
  end;

  TCatSongs = class
    private
      VisibleSongs: integer;
    public
    Song:       array of TSong; // array of categories with songs
    SongSort:   array of TSong;

    Selected:   integer; // selected song index
    Order:      integer; // order type (0=title)
    CatNumShow: integer; // Category Number being seen
    CatCount:   integer; // Number of Categorys

    procedure SortSongs();
    procedure Refresh;                                      // refreshes arrays by recreating them from Songs array
    procedure ShowCategory(Index: integer);                 // expands all songs in category
    procedure HideCategory(Index: integer);                 // hides all songs in category
    procedure ClickCategoryButton(Index: integer);          // uses ShowCategory and HideCategory when needed
    procedure ShowCategoryList;                             // Hides all Songs And Show the List of all Categorys
    function FindNextVisible(SearchFrom: integer): integer; // Find Next visible Song
    function FindPreviousVisible(SearchFrom: integer): integer; // Find Previous visible Song
    function GetVisibleSongs(): integer; //returns number of visible songs
    procedure SetVisibleSongs(); //sets number of visible songs
    function VisibleIndex(Index: integer): integer;         // returns visible song index (skips invisible)

    function SetFilter(FilterStr: UTF8String; Filter: TSongFilter): cardinal;
  end;

var
  Songs: TSongs; //all songs
  CatSongs: TCatSongs; //categorized songs

const
  IN_ACCESS        = $00000001; //* File was accessed */
  IN_MODIFY        = $00000002; //* File was modified */
  IN_ATTRIB        = $00000004; //* Metadata changed */
  IN_CLOSE_WRITE   = $00000008; //* Writtable file was closed */
  IN_CLOSE_NOWRITE = $00000010; //* Unwrittable file closed */
  IN_OPEN          = $00000020; //* File was opened */
  IN_MOVED_FROM    = $00000040; //* File was moved from X */
  IN_MOVED_TO      = $00000080; //* File was moved to Y */
  IN_CREATE        = $00000100; //* Subfile was created */
  IN_DELETE        = $00000200; //* Subfile was deleted */
  IN_DELETE_SELF   = $00000400; //* Self was deleted */


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
  Self.FreeOnTerminate := true;
  Self.Txts := TThreadList.Create();
  Self.Txt := 0;
  Self.Event := RTLEventCreate();
end;

destructor TSongsParse.Destroy();
begin
  RTLeventDestroy(Self.Event);
  Self.Txts.Destroy();
  inherited;
end;

procedure TSongsParse.Execute();
var
  Song: TSong;
  List: TList;
  I: integer;
begin
  while not Self.Terminated do
  begin
    RtlEventWaitFor(Self.Event);
    List := Self.Txts.LockList();
    try
      for I := Self.Txt to List.Count - 1 do //start to parse from the last position
      begin
        Song := TSong(List.Items[I]);
        if Song.Analyse() then
          Inc(Self.Txt)
        else
          Self.Txts.Remove(Song);
      end;
    finally
      Self.Txts.UnlockList();
    end;
  end;
end;

procedure TSongsParse.AddSong(const TxtFile: IPath);
begin
  Self.Txts.Add(TSong.Create(TxtFile));
  RtlEventSetEvent(Self.Event);
end;

constructor TSongs.Create();
var
  I: integer;
begin
  inherited Create(false);
  Self.FreeOnTerminate := false;
  Self.SongList := TList.Create();
  Self.Thread := 0;
  Setlength(Self.Threads, Max(1, CpuCount.GetLogicalCpuCount() - 2)); //total - main and songs threads
  for I := 0 to High(Self.Threads) do
    Self.Threads[I] := TSongsParse.Create();
end;

destructor TSongs.Destroy();
var
  I: integer;
begin
  for I := 0 to High(Self.Threads) do
    Self.Threads[I].Terminate();

  inherited;
end;

{ Search for all files and directories }
procedure TSongs.FindTxts(const Dir: IPath);
var
  Iter: IFileIterator;
  FileInfo: TFileInfo;
begin
  Iter := FileSystem.FileFind(Dir.Append('*'), faAnyFile);
  while Iter.HasNext do //content of current folder
  begin
    FileInfo := Iter.Next; //get file info
    if ((FileInfo.Attr and faDirectory) <> 0) and (not (FileInfo.Name.ToUTF8()[1] = '.')) then //if is a directory try to find more
      Self.FindTxts(Dir.Append(FileInfo.Name))
    else if FileInfo.Name.GetExtension().ToNative() = '.txt' then //if is a txt file send to a thread to parse it
    begin
      Inc(Self.ProgressSong.Total);
      Self.Threads[Self.Thread].AddSong(Dir.Append(FileInfo.Name));
      if Self.Thread = High(Self.Threads) then //each txt to one thread
        Self.Thread := 0
      else
        Inc(Self.Thread)
    end
  end;
end;

{ Create a new thread to load songs and update main screen with progress }
procedure TSongs.Execute();
var
  I: integer;
  Song: TSong;
begin
  Log.BenchmarkStart(2);
  Log.LogStatus('Searching For Songs', 'SongList');
  Self.ProgressSong.Total := 0;
  for I := 0 to UPathUtils.SongPaths.Count - 1 do //find txt files on directories and add songs
  begin
    Self.ProgressSong.Folder := Format(ULanguage.Language.Translate('SING_LOADING_SONGS'), [IPath(UPathUtils.SongPaths[I]).ToNative()]);
    Self.FindTxts(IPath(UPathUtils.SongPaths[I]));
  end;
  for I := 0 to High(Self.Threads) do //add all songs parsed to main list
    Self.SongList.AddList(Self.Threads[I].Txts.LockList());

  Log.LogStatus('Search Complete', 'SongList');
  CatSongs.Refresh;
  Self.ProgressSong.Folder := '';
  Log.LogBenchmark('Song loading', 2);
end;

function TSongs.GetLoadProgress(): TProgressSong;
begin
  Result := Self.ProgressSong;
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
  Result := UTF8CompareText(TSong(Song1).Title, TSong(Song2).Title);
end;

function CompareByArtist(Song1, Song2: Pointer): integer;
begin
  Result := UTF8CompareText(TSong(Song1).Artist, TSong(Song2).Artist);
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

procedure TCatSongs.SortSongs();
begin
  case TSortingType(Ini.Sorting) of
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

procedure TCatSongs.Refresh;
var
  SongIndex:   integer;
  CurSong:     TSong;
  CatIndex:    integer;    // index of current song in Song
  Letter:      UCS4Char;   // current letter for sorting using letter
  CurCategory: UTF8String; // current edition for sorting using edition, genre etc.
  OrderNum: integer; // number used for ordernum
  LetterTmp:   UCS4Char;
  CatNumber:   integer;    // Number of Song in Category
  tmpCategory: UTF8String; //

  procedure AddCategoryButton(const CategoryName: UTF8String);
  var
    PrevCatBtnIndex: integer;
  begin
    Inc(OrderNum);
    CatIndex := Length(Song);
    SetLength(Song, CatIndex+1);
    Song[CatIndex]          := TSong.Create();
    Song[CatIndex].Artist   := '[' + CategoryName + ']';
    Song[CatIndex].Main     := true;
    Song[CatIndex].OrderTyp := 0;
    Song[CatIndex].OrderNum := OrderNum;
    Song[CatIndex].Cover    := CatCovers.GetCover(TSortingType(Ini.Sorting), CategoryName);
    Song[CatIndex].Visible  := true;

    // set number of songs in previous category
    PrevCatBtnIndex := CatIndex - CatNumber - 1;
    if ((PrevCatBtnIndex >= 0) and Song[PrevCatBtnIndex].Main) then
      Song[PrevCatBtnIndex].CatNumber := CatNumber;

    CatNumber := 0;
  end;

begin
  CatNumShow  := -1;

  SortSongs();

  CurCategory := '';
  OrderNum := 0;
  CatNumber   := 0;

  // Note: do NOT set Letter to ' ', otherwise no category-button will be
  // created for songs beginning with ' ' if songs of this category exist.
  // TODO: trim song-properties so ' ' will not occur as first chararcter.
  Letter      := 0;

  // clear song-list
  for SongIndex := 0 to Songs.SongList.Count - 1 do
  begin
    // free category buttons
    // Note: do NOT delete songs, they are just references to Songs.SongList entries
    CurSong := TSong(Songs.SongList[SongIndex]);
    if (CurSong.Main) then
      CurSong.Free;
  end;
  SetLength(Song, 0);

  for SongIndex := 0 to Songs.SongList.Count - 1 do
  begin
    CurSong := TSong(Songs.SongList[SongIndex]);
    // if tabs are on, add section buttons for each new section
    if (Ini.Tabs = 1) then
    begin
      case (TSortingType(Ini.Sorting)) of
        sEdition: begin
          if (CompareText(CurCategory, CurSong.Edition) <> 0) then
          begin
            CurCategory := CurSong.Edition;

            // add Category Button
            AddCategoryButton(CurCategory);
          end;
        end;

        sGenre: begin
          if (CompareText(CurCategory, CurSong.Genre) <> 0) then
          begin
            CurCategory := CurSong.Genre;
            // add Genre Button
            AddCategoryButton(CurCategory);
          end;
        end;

        sLanguage: begin
          if (CompareText(CurCategory, CurSong.Language) <> 0) then
          begin
            CurCategory := CurSong.Language;
            // add Language Button
            AddCategoryButton(CurCategory);
          end
        end;

        sTitle: begin
          if (Length(CurSong.Title) >= 1) then
          begin
            LetterTmp := UCS4UpperCase(UTF8ToUCS4String(CurSong.Title)[0]);
            { all numbers and some punctuation chars are put into a
              category named '#'
              we can't put the other punctuation chars into this category
              because they are not in order, so there will be two different
              categories named '#' }
            if (LetterTmp in [Ord('!') .. Ord('?')]) then
              LetterTmp := Ord('#')
            else
              LetterTmp := UCS4UpperCase(LetterTmp);
            if (Letter <> LetterTmp) then
            begin
              Letter := LetterTmp;
              // add a letter Category Button
              AddCategoryButton(UCS4ToUTF8String(Letter));
            end;
          end;
        end;

        sArtist: begin
          if (Length(CurSong.Artist) >= 1) then
          begin
            LetterTmp := UCS4UpperCase(UTF8ToUCS4String(CurSong.Artist)[0]);
            { all numbers and some punctuation chars are put into a
              category named '#'
              we can't put the other punctuation chars into this category
              because they are not in order, so there will be two different
              categories named '#' }
            if (LetterTmp in [Ord('!') .. Ord('?')]) then
              LetterTmp := Ord('#')
            else
              LetterTmp := UCS4UpperCase(LetterTmp);

            if (Letter <> LetterTmp) then
            begin
              Letter := LetterTmp;
              // add a letter Category Button
              AddCategoryButton(UCS4ToUTF8String(Letter));
            end;
          end;
        end;

        sFolder: begin
          if (UTF8CompareText(CurCategory, CurSong.Folder) <> 0) then
          begin
            CurCategory := CurSong.Folder;
            // add folder tab
            AddCategoryButton(CurCategory);
          end;
        end;

        sArtist2: begin
          { this new sorting puts all songs by the same artist into
            a single category }
          if (UTF8CompareText(CurCategory, CurSong.Artist) <> 0) then
          begin
            CurCategory := CurSong.Artist;
            // add folder tab
            AddCategoryButton(CurCategory);
          end;
        end;

        sYear: begin
           if (CurSong.Year <> 0) then
             tmpCategory := IntToStr(CurSong.Year)
           else
             tmpCategory := 'Unknown';

           if (tmpCategory <> CurCategory) then
           begin
             CurCategory := tmpCategory;

             // add Category Button
             AddCategoryButton(CurCategory);
           end;
         end;

        sDecade: begin
           if (CurSong.Year <> 0) then
             tmpCategory := IntToStr(Trunc(CurSong.Year/10)*10) + '-' + IntToStr(Trunc(CurSong.Year/10)*10+9)
           else
             tmpCategory := 'Unknown';

           if (tmpCategory <> CurCategory) then
           begin
             CurCategory := tmpCategory;

             // add Category Button
             AddCategoryButton(CurCategory);
           end;
        end;
      end; // case (Ini.Sorting)
    end; // if (Ini.Tabs = 1)

    CatIndex := Length(Song);
    SetLength(Song, CatIndex+1);

    Inc(CatNumber); // increase number of songs in category

    // copy reference to current song
    Song[CatIndex] := CurSong;

    // set song's category info
    CurSong.OrderNum := OrderNum; // assigns category
    CurSong.CatNumber := CatNumber;
    Self.VisibleSongs := 0;
    if UIni.Ini.Tabs = 0 then
    begin
      CurSong.Visible := true;
      Inc(Self.VisibleSongs);
    end
    else
      CurSong.Visible := false;
  end;

  // set CatNumber of last category
  if (UIni.Ini.Tabs = 1) and (High(Song) >= 1) then
  begin
    // set number of songs in previous category
    SongIndex := CatIndex - CatNumber;
    if ((SongIndex >= 0) and Song[SongIndex].Main) then
      Song[SongIndex].CatNumber := CatNumber;
  end;

  // update number of categories
  CatCount := OrderNum;
end;

procedure TCatSongs.ShowCategory(Index: integer);
var
  I: integer;
begin
  Self.VisibleSongs := 0;
  CatNumShow := Index;
  for I := 0 to high(CatSongs.Song) do
  begin
    if (CatSongs.Song[I].OrderNum = Index) and (not CatSongs.Song[I].Main) then
    begin
      CatSongs.Song[I].Visible := true;
      Inc(Self.VisibleSongs);
    end
    else
      CatSongs.Song[I].Visible := false;
  end;
end;

{hides all songs in category}
procedure TCatSongs.HideCategory(Index: integer);
var
  I: integer;
begin
  Self.VisibleSongs := 0;
  for I := 0 to high(CatSongs.Song) do
  begin
    if not CatSongs.Song[I].Main then
      CatSongs.Song[I].Visible := false // hides all at now
    else
      Inc(Self.VisibleSongs);
  end;
end;

procedure TCatSongs.ClickCategoryButton(Index: integer);
var
  Num: integer;
begin
  Num := CatSongs.Song[Index].OrderNum;
  if Num <> CatNumShow then
  begin
    ShowCategory(Num);
  end
  else
  begin
    ShowCategoryList;
  end;
end;

//Hide Categorys when in Category Hack
procedure TCatSongs.ShowCategoryList();
var
  I: integer;
begin
  Self.VisibleSongs := 0;
  for I := 0 to high(CatSongs.Song) do //hide all songs and show all cats
  begin
    CatSongs.Song[I].Visible := CatSongs.Song[I].Main;
    if CatSongs.Song[I].Visible then
      Inc(Self.VisibleSongs);
  end;
  CatSongs.Selected := CatNumShow; //Show last shown Category
  CatNumShow := -1;
end;

// Wrong song selected when tabs on bug
function TCatSongs.FindNextVisible(SearchFrom:integer): integer;// Find next Visible Song
var
  I: integer;
begin
  Result := -1;
  I := SearchFrom;
  while (Result = -1) do
  begin
    Inc (I);

    if (I > High(CatSongs.Song)) then
      I := Low(CatSongs.Song);

    if (I = SearchFrom) then // Make One Round and no song found->quit
      Break;

    if (CatSongs.Song[I].Visible) then
      Result := I;
  end;
end;

function TCatSongs.FindPreviousVisible(SearchFrom:integer): integer;// Find previous Visible Song
var
  I: integer;
begin
  Result := -1;
  I := SearchFrom;
  while (Result = -1) do
  begin
    Dec (I);

    if (I < Low(CatSongs.Song)) then
      I := High(CatSongs.Song);

    if (I = SearchFrom) then // Make One Round and no song found->quit
      Break;

    if (CatSongs.Song[I].Visible) then
      Result := I;
  end;
end;

procedure TCatSongs.SetVisibleSongs();
var
  I: integer;
begin
    Self.VisibleSongs := 0;
    for I := 0 to High(CatSongs.Song) do
        if (CatSongs.Song[I].Visible) then
          Inc(Self.VisibleSongs);
end;

function TCatSongs.GetVisibleSongs(): integer;
begin
  Result := Self.VisibleSongs;
end;


(**
 * Returns the index of a song in the subset of all visible songs.
 * If all songs are visible, the result will be equal to the Index parameter.
 *)
function TCatSongs.VisibleIndex(Index: integer): integer;
var
  SongIndex: integer;
begin
  Result := 0;
  for SongIndex := 0 to Index - 1 do
  begin
    if (CatSongs.Song[SongIndex].Visible) then
      Inc(Result);
  end;
end;

function TCatSongs.SetFilter(FilterStr: UTF8String; Filter: TSongFilter): cardinal;
var
  I, J:      integer;
  TmpString: UTF8String;
  WordArray: array of UTF8String;
begin
  Self.VisibleSongs := 0;
  Result := 0;
  FilterStr := UCommon.GetStringWithNoAccents(Trim(LowerCase(FilterStr)));
  if FilterStr <> '' then
  begin
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
          fltAll:
            TmpString := Song[I].ArtistNoAccent + ' ' + Song[i].TitleNoAccent; //+ ' ' + Song[i].Folder;
          fltTitle:
            TmpString := Song[I].TitleNoAccent;
          fltArtist:
            TmpString := Song[I].ArtistNoAccent;
        end;
        Song[i].Visible := true;
        // Look for every searched word
        for J := 0 to High(WordArray) do
        begin
          Song[i].Visible := Song[i].Visible and UTF8ContainsStr(TmpString, WordArray[J])
        end;
        if Song[i].Visible then
          Inc(Result);
      end
      else
        Song[i].Visible := false;
    end;
    CatNumShow := -2;
  end
  else
  begin
    for I := 0 to High(Song) do
    begin
      Song[I].Visible := (UIni.Ini.Tabs = 1) = Song[I].Main;
      if Song[I].Visible then
        Inc(Result);
    end;
    CatNumShow := -1;
  end;
  Self.VisibleSongs := Result;
end;

// -----------------------------------------------------------------------------

end.
