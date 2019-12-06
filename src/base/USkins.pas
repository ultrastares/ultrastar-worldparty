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
    procedure LoadSkin();
    function GetTextureFileName(TextureName: string): IPath;
    function GetSkinNumber(Name: string): integer;
    function GetDefaultColor(): integer;
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

procedure TSkin.LoadSkin();
var
  Textures:      TStringList;
  Texture: UTF8String;
  SkinNumber: integer;
  I: integer;
begin
  SkinNumber := Self.GetSkinNumber(UThemes.Theme.Themes[UIni.Ini.Theme].Skins[UIni.Ini.Skin]);
  Self.SkinPath := Skin[SkinNumber].Path;
  Self.SkinIni := TMemIniFile.Create(Self.SkinPath.Append(Skin[SkinNumber].FileName).ToNative());
  Self.SkinBase := TMemIniFile.Create(Self.SkinPath.Append(Skin[Self.GetSkinNumber(UThemes.Theme.Themes[UIni.Ini.Theme].DefaultSkin)].FileName).ToNative());
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

function TSkin.GetSkinNumber(Name: string): integer;
var
  S: integer;
begin
  Result := -1;
  for S := 0 to High(Skin) do
    if (CompareText(Skin[S].Name, Name) = 0) and (CompareText(Skin[S].Theme, UThemes.Theme.Themes[UIni.Ini.Theme].Name) = 0) then
      Result := S;
end;

{ returns number of default color for skin with
  index SkinNo in ISkin (not in the actual skin array) }
function TSkin.GetDefaultColor(): integer;
var
  I, SkinNo: Integer;
begin
  Result := 0;
  SkinNo := UIni.Ini.Skin;
  for I := 0 to High(Skin) do
    if (CompareText(ITheme[Ini.Theme], Skin[I].Theme) = 0) then
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

end.
