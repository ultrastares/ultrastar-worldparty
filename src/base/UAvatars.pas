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

unit UAvatars;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  SysUtils,
  Classes,
  UIni,
  UPath,
  UTexture;

type
  TAvatar = class
    Id: integer;
    MD5: string;
    Texture: TTexture;
  end;

  TAvatarPlayerTextures = array[1..UIni.IMaxPlayerCount] of TTexture;

  TAvatarList = class
    private
      Avatars: TFPList;
      AvatarPlayerTextures: TAvatarPlayerTextures;
      AvatarPlayerNoTextures: TAvatarPlayerTextures;
    public
      constructor Create();
      function GetAvatars(): TFPList;
      function GetPlayers(): TAvatarPlayerTextures;
      function GetPlayersNo(): TAvatarPlayerTextures;
      procedure LoadConfig(Party: boolean = false);
  end;

function GetAvatarsList(): TAvatarList;
procedure SetAvatarsList();

implementation

uses
  UCommon,
  UFilesystem,
  UGraphic,
  UPathUtils,
  UScreenScore,
  UScreenSingController,
  USkins,
  UThemes,
  md5;

var
  AvatarsList: TAvatarList;

function GetAvatarsList(): TAvatarList;
begin
  Result := AvatarsList;
end;

procedure SetAvatarsList();
begin
  AvatarsList := UAvatars.TAvatarList.Create();
end;

constructor TAvatarList.Create();
var
  I: integer;
  Iterator: IFileIterator;
  Extension: string;
  FileInfo: TFileInfo;
  Path: IPath;
  Avatar: TAvatar;
begin
  inherited Create();
  Self.Avatars := TFPList.Create();
  I := 1;
  for Extension in ['jpg', 'png'] do
  begin
    Iterator := UFilesystem.FileSystem.FileFind(UPathUtils.AvatarsPath.Append('*.' + Extension), 0);
    while Iterator.HasNext() do
    begin
      FileInfo := Iterator.Next();
      Avatar := TAvatar.Create();
      Avatar.Id := I;
      Path := UPathUtils.AvatarsPath.Append(FileInfo.Name);
      Avatar.MD5 := MD5Print(MD5File(Path.ToNative()));
      Avatar.Texture := UTexture.Texture.LoadTexture(Path);
      Self.Avatars.Add(Avatar);
      Inc(I);
    end;
  end;
  for I := 1 to UIni.IMaxPlayerCount do
    Self.AvatarPlayerNoTextures[I] := UTexture.Texture.LoadTexture(USkins.Skin.GetTextureFileName('NoAvatar_P' + IntToStr(I)), TEXTURE_TYPE_TRANSPARENT, $FFFFFF);

  Self.LoadConfig();
end;

function TAvatarList.GetAvatars(): TFPList;
begin
  Result := Self.Avatars;
end;

function TAvatarList.GetPlayers(): TAvatarPlayerTextures;
begin
  Result := Self.AvatarPlayerTextures;
end;

function TAvatarList.GetPlayersNo(): TAvatarPlayerTextures;
begin
  Result := Self.AvatarPlayerNoTextures;
end;

procedure TAvatarList.LoadConfig(Party: boolean = false);
var
  Avatar: TAvatar;
  Col: TRGB;
  I, J: Integer;
begin
  if not Party then
    for I := 0 to Self.Avatars.Count - 1 do
    begin
      Avatar := TAvatar(Self.Avatars[I]);
      J := UCommon.GetArrayIndex(UIni.Ini.PlayerAvatar, Avatar.MD5);
      if J <> -1 then
        Self.AvatarPlayerTextures[J + 1] := Avatar.Texture;
    end;

  for I := 1 to High(Self.AvatarPlayerTextures) do
    if Party or (Self.AvatarPlayerTextures[I].TexNum = 0) then
    begin
      Self.AvatarPlayerTextures[I] := Self.AvatarPlayerNoTextures[I];
      Col := UThemes.GetPlayerColor(UIni.Ini.PlayerColor[I]);
      Self.AvatarPlayerTextures[I].ColR := Col.R;
      Self.AvatarPlayerTextures[I].ColG := Col.G;
      Self.AvatarPlayerTextures[I].ColB := Col.B;
    end;

  UThemes.LoadPlayersColors();
  UThemes.Theme.ThemeScoreLoad();
  if Assigned(UGraphic.ScreenScore) then
  begin
    UGraphic.ScreenScore := UScreenScore.TScreenScore.Create();
    UGraphic.ScreenSing := UScreenSingController.TScreenSingController.Create();
  end;
end;

end.
