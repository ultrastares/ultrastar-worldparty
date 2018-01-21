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

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  sdl2,
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
      Filename: IPath;
    public
      constructor Create(Filename: IPath);
      function GetPreviewTexture(): TTexture;
      function GetEmptyTexture(): TTexture;
      function GetTexture(): TTexture;
  end;

  TCoverDatabase = class
    public
      constructor Create();
      destructor Destroy; override;
      function FindCover(const Filename: IPath): TCover;
      function AddCover(const Filename: IPath): TCover;
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

{ TBlobWrapper }

function TBlobWrapper.Write(const Buffer; Count: Integer): Integer;
begin
  SetPointer(Pointer(Buffer), Count);
  Result := Count;
end;


{ TCover }

constructor TCover.Create(Filename: IPath);
begin
  Self.Filename := Filename;
end;

function TCover.GetPreviewTexture(): TTexture;
begin
  Result := Self.GetTexture();
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
end;

destructor TCoverDatabase.Destroy;
begin
  inherited;
end;

function TCoverDatabase.GetMaxCoverSize(): integer;
begin
  Result := ITextureSizeVals[Ini.TextureSize];
end;

{* TODO delete when change UScreenSong calls *}
function TCoverDatabase.FindCover(const Filename: IPath): TCover;
begin
  Result := AddCover(Filename);
end;

function TCoverDatabase.AddCover(const Filename: IPath): TCover;
begin
  Result := TCover.Create(Filename);
end;
end.
