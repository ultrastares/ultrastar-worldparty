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

unit USkins;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  IniFiles,
  UCommon,
  UPath;

type
  TSkinTexture = record
    Name:     string;
    FileName: IPath;
  end;

  TSkinEntry = record
    Theme:    string;
    Name:     string;
    Path:     IPath;
    FileName: IPath;
    DefaultColor: integer;
    Creator:  string;
  end;

  TSkin = class
    Color: integer;
    Skin: array of TSkinEntry;
    SkinBase: TMemIniFile;
    SkinIni: TMemIniFile;
    SkinPath: IPath;
    SkinTexture: array of TSkinTexture;
    constructor Create;
    procedure LoadList;
    procedure ParseDir(Dir: IPath);
    procedure LoadHeader(FileName: IPath);
    procedure LoadSkin(Name, Theme: string);
    function GetTextureFileName(TextureName: string): IPath;
    function GetSkinNumber(Name, Theme: string): integer;
    function GetDefaultColor(SkinNo: integer): integer;

    procedure GetSkinsByTheme(Theme: string; out Skins: TUTF8StringDynArray);

    procedure onThemeChange;
  end;

var
  Skin: TSkin;

implementation

uses
  Classes,
  SysUtils,
  Math,
  UFileSystem,
  UIni,
  ULog,
  UMain,
  UPathUtils,
  UThemes;

constructor TSkin.Create;
begin
  inherited;
  LoadList;
//  LoadSkin('...');
//  SkinColor := Color;
end;

procedure TSkin.LoadList;
var
  Iter: IFileIterator;
  DirInfo: TFileInfo;
begin
  Iter := FileSystem.FileFind(SkinsPath.Append('*'), faDirectory);
  while Iter.HasNext do
  begin
    DirInfo := Iter.Next();
    if (not DirInfo.Name.Equals('.')) and (not DirInfo.Name.Equals('..')) then
      ParseDir(SkinsPath.Append(DirInfo.Name, pdAppend));
  end;
end;

procedure TSkin.ParseDir(Dir: IPath);
var
  Iter: IFileIterator;
  IniInfo: TFileInfo;
begin
  Iter := FileSystem.FileFind(Dir.Append('*.ini'), 0);
  while Iter.HasNext do
  begin
    IniInfo := Iter.Next;
    LoadHeader(Dir.Append(IniInfo.Name));
  end;
end;

procedure TSkin.LoadHeader(FileName: IPath);
var
  SkinIni: TMemIniFile;
  S:       integer;
begin
  SkinIni := TMemIniFile.Create(FileName.ToNative);

  S := Length(Skin);
  SetLength(Skin, S+1);

  Skin[S].Path     := FileName.GetPath;
  Skin[S].FileName := FileName.GetName;
  Skin[S].Theme    := SkinIni.ReadString('Skin', 'Theme', '');
  Skin[S].Name     := SkinIni.ReadString('Skin', 'Name', '');
  Skin[S].Creator  := SkinIni.ReadString('Skin', 'Creator', '');
  Skin[S].DefaultColor := Max(0, GetArrayIndex(IColor, SkinIni.ReadString('Skin', 'Color', ''), true));
  SkinIni.Free;
end;

procedure TSkin.LoadSkin(Name, Theme: string);
var
  Textures:      TStringList;
  Texture: UTF8String;
  SkinNumber: integer;
  I: integer;
  SkinsByTheme: TUTF8StringDynArray;
begin
  SkinNumber := Self.GetSkinNumber(Name, Theme);
  Self.SkinPath := Skin[SkinNumber].Path;
  Self.SkinIni := TMemIniFile.Create(Self.SkinPath.Append(Skin[SkinNumber].FileName).ToNative());
  for I := 0 to High(UThemes.Theme.Themes) do
    if Theme = UThemes.Theme.Themes[I].Name then
      Self.SkinBase := TMemIniFile.Create(Self.SkinPath.Append(Skin[UThemes.Theme.Themes[I].DefaultSkin].FileName).ToNative());

  Textures := TStringList.Create();
  Self.SkinBase.ReadSection('Textures', Textures);
  SetLength(SkinTexture, Textures.Count);
  for I := 0 to Textures.Count - 1 do
  begin
    SkinTexture[I].Name := Textures.Strings[I];
    Texture := Self.SkinIni.ReadString('Textures', Textures.Strings[I], '');
    if Texture = '' then
      Texture := Self.SkinBase.ReadString('Textures', Textures.Strings[I], '');

    SkinTexture[I].FileName := Path(Texture);
  end;
  Textures.Free();
  SkinIni.Free();
end;

function TSkin.GetTextureFileName(TextureName: string): IPath;
var
  T: integer;
begin
  Result := PATH_NONE;

  for T := 0 to High(SkinTexture) do
  begin
    if (SkinTexture[T].Name = TextureName) and
       (SkinTexture[T].FileName.IsSet) then
    begin
      Result := SkinPath.Append(SkinTexture[T].FileName);
    end;
  end;

  if (TextureName <> '') and (Result.IsSet) then
  begin
    //Log.LogError('', '-----------------------------------------');
    //Log.LogError('Was not able to retrieve Texture for ' + TextureName + ' - ' + Result.ToNative, 'TSkin.GetTextureFileName');
  end;
end;

function TSkin.GetSkinNumber(Name, Theme: string): integer;
var
  S: integer;
begin
  Result := -1;
  for S := 0 to High(Skin) do
    if (CompareText(Skin[S].Name, Name) = 0) and (CompareText(Skin[S].Theme, Theme) = 0) then
      Result := S;
end;

procedure TSkin.GetSkinsByTheme(Theme: string; out Skins: TUTF8StringDynArray);
  var
    I: Integer;
    Len: integer;
begin
  SetLength(Skins, 0);
  Len := 0;

  for I := 0 to High(Skin) do
    if CompareText(Theme, Skin[I].Theme) = 0 then
    begin
      SetLength(Skins, Len + 1);
      Skins[Len] := Skin[I].Name;
      Inc(Len);
    end;
end;

{ returns number of default color for skin with
  index SkinNo in ISkin (not in the actual skin array) }
function TSkin.GetDefaultColor(SkinNo: integer): integer;
  var
    I: Integer;
begin
  Result := 0;

  for I := 0 to High(Skin) do
    if CompareText(ITheme[Ini.Theme], Skin[I].Theme) = 0 then
    begin
      if SkinNo > 0 then
        Dec(SkinNo)
      else
      begin
        Result := Skin[I].DefaultColor;
        Break;
      end;
    end;
end;

procedure TSkin.onThemeChange;
begin
  Ini.SkinNo:=0;
  GetSkinsByTheme(ITheme[Ini.Theme], ISkin);
end;

end.
