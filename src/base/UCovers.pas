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

unit UCovers;

{
  TODO:
  - adjust database to new song-loading (e.g. use SongIDs)
  - support for deletion of outdated covers
  - support for update of changed covers
  - use paths relative to the song for removable disks support
    (a drive might have a different drive-name the next time it is connected,
     so "H:/songs/..." will not match "I:/songs/...")
}

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  sdl2,
  SQLite3,
  SQLiteTable3,
  SysUtils,
  Classes,
  UImage,
  UThemes,
  UTexture,
  UPath;

type
  ECoverDBException = class(Exception)
  end;

  TCover = class
    private
      ID: int64;
      Filename: IPath;
    public
      constructor Create(ID: int64; Filename: IPath);
      function GetPreviewTexture(): TTexture;
      function GetEmptyTexture(): TTexture;
      function GetTexture(): TTexture;
  end;

  TCoverDatabase = class
    private
      DB: TSQLiteDatabase;
      CoverAdded: Boolean;
      procedure InitCoverDatabase();
      function CreateThumbnail(const Filename: IPath): PSDL_Surface;
      procedure DeleteCover(CoverID: int64);
      procedure Open();
      function GetVersion(): integer;
      procedure SetVersion(Version: integer);
    public
      constructor Create();
      destructor Destroy; override;
      function AddCover(const Filename: IPath): TCover;
      function FindCover(const Filename: IPath): TCover;
      function GetMaxCoverSize(): integer;
  end;

  TBlobWrapper = class(TCustomMemoryStream)
     function Write(const Buffer; Count: Integer): Integer; override;
  end;

var
  Covers: TCoverDatabase;

implementation

uses
  UMain,
  ULog,
  UPlatform,
  UIni,
  Math,
  DateUtils;

const
  COVERDB_FILENAME: UTF8String = 'cover.db';
  COVERDB_VERSION = 02; // 0.2
  COVER_TBL = 'Cover';

{ TBlobWrapper }

function TBlobWrapper.Write(const Buffer; Count: Integer): Integer;
begin
  SetPointer(Pointer(Buffer), Count);
  Result := Count;
end;


{ TCover }

constructor TCover.Create(ID: int64; Filename: IPath);
begin
  Self.ID := ID;
  Self.Filename := Filename;
end;

function TCover.GetPreviewTexture(): TTexture;
begin
  Result := GetTexture();
end;

function TCover.GetEmptyTexture(): TTexture;
begin
  if not (Assigned(Filename)) or (Filename = nil) then Exit;
  FillChar(Result, SizeOf(TTexture), 0);
  Result.Name:= Filename;
end;

function TCover.GetTexture(): TTexture;
begin
  if not (Assigned(Filename)) or (Filename = nil) then Exit;
  Result := Texture.LoadTexture(Filename);
end;


{ TCoverDatabase }

constructor TCoverDatabase.Create();
begin
  inherited;

  Open();
  InitCoverDatabase();
  Self.CoverAdded := false;
end;

destructor TCoverDatabase.Destroy;
begin
  if Self.CoverAdded then
    DB.Commit();

  DB.Free;
  inherited;
end;

function TCoverDatabase.GetVersion(): integer;
begin
  Result := DB.GetTableValue('PRAGMA user_version');
end;

procedure TCoverDatabase.SetVersion(Version: integer);
begin
  DB.ExecSQL(Format('PRAGMA user_version = %d', [Version]));
end;

function TCoverDatabase.GetMaxCoverSize(): integer;
begin
  Result := ITextureSizeVals[Ini.TextureSize];
end;

procedure TCoverDatabase.Open();
var
  Version: integer;
  Filename: IPath;
begin
  Filename := Platform.GetGameUserPath().Append(COVERDB_FILENAME);

  DB := TSQLiteDatabase.Create(Filename.ToUTF8());
  Version := GetVersion();

  // check version, if version is too old/new, delete database file
  if ((Version <> 0) and (Version <> COVERDB_VERSION)) then
  begin
    Log.LogInfo('Outdated cover-database file found', 'TCoverDatabase.Open');
    // close and delete outdated file
    DB.Free;
    if (not Filename.DeleteFile()) then
      raise ECoverDBException.Create('Could not delete ' + Filename.ToNative);
    // reopen
    DB := TSQLiteDatabase.Create(Filename.ToUTF8());
    Version := 0;
  end;

  // set version number after creation
  if (Version = 0) then
    SetVersion(COVERDB_VERSION);

  // speed-up disk-writing. The default FULL-synchronous mode is too slow.
  // With this option disk-writing is approx. 4 times faster but the database
  // might be corrupted if the OS crashes, although this is very unlikely.
  DB.ExecSQL('PRAGMA synchronous = OFF;');

  // the next line rather gives a slow-down instead of a speed-up, so we do not use it
  //DB.ExecSQL('PRAGMA temp_store = MEMORY;');
end;

procedure TCoverDatabase.InitCoverDatabase();
begin
  DB.ExecSQL('CREATE TABLE IF NOT EXISTS '+COVER_TBL+' ('
    +'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    +'filename TEXT UNIQUE NOT NULL, '
    +'thumbnail BLOB NULL)');

  DB.ExecSQL('CREATE INDEX IF NOT EXISTS Cover_Filename_IDX ON '+COVER_TBL+'(filename ASC)');
end;

function TCoverDatabase.FindCover(const Filename: IPath): TCover;
var
  CoverID: int64;
begin
  Result := nil;
  try
    if Filename = nil then
      CoverID := 0
    else
    begin
      CoverID := DB.GetTableValue('SELECT id FROM '+COVER_TBL+' WHERE filename = ?', [Filename.ToUTF8]);
    end;

    if (CoverID > 0) then
      Result := TCover.Create(CoverID, Filename);
  except on E: Exception do
    Log.LogError(E.Message, 'TCoverDatabase.FindCover');
  end;
end;

function TCoverDatabase.AddCover(const Filename: IPath): TCover;
var
  Thumbnail: PSDL_Surface;
  CoverData: TBlobWrapper;
begin
  if not Self.CoverAdded then
  begin
    Self.CoverAdded := true;
    DB.BeginTransaction();
  end;

  Result := nil;

  //if (not FileExists(Filename)) then
  //  Exit;

  // TODO: replace '\' with '/' in filename
  Thumbnail := CreateThumbnail(Filename);
  if not (assigned(Thumbnail)) or (Thumbnail = nil) then
    Exit;

  CoverData := TBlobWrapper.Create;
  CoverData.Write(Thumbnail^.pixels, Thumbnail^.h * Thumbnail^.pitch);

  try
    DB.ExecSQL('INSERT INTO '+COVER_TBL+' (filename, thumbnail) VALUES (?, ?)', [Filename.ToUTF8, CoverData]);
    Result := TCover.Create(DB.GetLastInsertRowID(), Filename);
  except on E: Exception do
    Log.LogError(E.Message, 'TCoverDatabase.AddCover');
  end;

  CoverData.Free;
  SDL_FreeSurface(Thumbnail);
end;

procedure TCoverDatabase.DeleteCover(CoverID: int64);
begin
  DB.ExecSQL(Format('DELETE FROM '+COVER_TBL+' WHERE id = %d', [CoverID]));
end;

(**
 * Returns a pointer to an array of bytes containing the texture data in the
 * requested size
 *)
function TCoverDatabase.CreateThumbnail(const Filename: IPath): PSDL_Surface;
var
  //TargetAspect, SourceAspect: double;
  //TargetWidth, TargetHeight: integer;
  Thumbnail: PSDL_Surface;
  MaxSize: integer;
begin
  Result := nil;
  Thumbnail := UImage.LoadImage(Filename);
  if (not assigned(Thumbnail)) then
  begin
    Log.LogError('Could not load cover: "'+ Filename.ToNative +'"', 'TCoverDatabase.AddCover');
    //Result := CreateThumbnail(UThemes.AThemeStatic.);
    Exit;
  end;

  // Convert pixel format as needed
  UTexture.AdjustPixelFormat(Thumbnail, TEXTURE_TYPE_PLAIN);

  (* TODO: keep aspect ratio
  TargetAspect := Width / Height;
  SourceAspect := TexSurface.w / TexSurface.h;

  // Scale texture to covers dimensions (keep aspect)
  if (SourceAspect >= TargetAspect) then
  begin
    TargetWidth := Width;
    TargetHeight := Trunc(Width / SourceAspect);
  end
  else
  begin
    TargetHeight := Height;
    TargetWidth := Trunc(Height * SourceAspect);
  end;
  *)

  // TODO: do not scale if image is smaller
  MaxSize := Self.GetMaxCoverSize();
  UImage.ScaleImage(Thumbnail, MaxSize, MaxSize);

  Result := Thumbnail;
end;

end.
