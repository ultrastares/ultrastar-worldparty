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


unit UScreenPlayerSelector;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  dglOpenGL,
  SysUtils,
  sdl2,
  UAvatars,
  UDisplay,
  UFiles,
  md5,
  UMenu,
  UIni,
  UMusic,
  UNote,
  UScreenScore,
  UScreenSingController,
  ULog,
  UTexture,
  UThemes;

type
  TScreenPlayerSelector = class(TMenu)
    private
      PlayersCount:  cardinal;
      PlayerAvatar:  cardinal;
      PlayerName:    cardinal;
      PlayerColor:   cardinal;
      PlayerSelect:  cardinal;
      PlayerSelectLevel: cardinal;
      SingButtonPressed: boolean; //only change the screen with click on sing button
      SingButton: integer;
      ExitButton: integer;
      CountIndex:   integer;
      PlayerIndex:  integer;
      ColorIndex:   integer;
      LevelIndex:   integer;
      AvatarCurrent: real;
      AvatarTarget:  integer;

      NumVisibleAvatars:      integer;
      DistanceVisibleAvatars: integer;

      isScrolling: boolean;   // true if avatar flow is about to move

      PlayerCurrent:       array [0..UIni.IMaxPlayerCount-1] of integer;
      PlayerCurrentText:   array [0..UIni.IMaxPlayerCount-1] of integer;
      PlayerCurrentAvatar: array [0..UIni.IMaxPlayerCount-1] of integer;

      PlayerNames:   array [0..UIni.IMaxPlayerCount-1] of UTF8String;
      PlayerAvatars: array [0..UIni.IMaxPlayerCount-1] of integer;
      PlayerLevel:   array [0..UIni.IMaxPlayerCount-1] of integer;
      Num: array[0..UIni.IMaxPlayerCount-1] of integer;
      APlayerColor: array of integer;

      PlayerAvatarButton: array of integer;
      PlayerAvatarButtonMD5: array of UTF8String;
    public
      OpenedInOptions: boolean;

      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      function ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean; override;

      procedure OnShow; override;
      procedure OnHide; override;
      function Draw: boolean; override;

      procedure SetAnimationProgress(Progress: real); override;
      procedure SetAvatarScroll;
      procedure SkipTo(Target: cardinal);

      procedure PlayerColorButton(K: integer);
      function NoRepeatColors(ColorP: integer; Interaction: integer; Pos: integer):integer;
      procedure RefreshPlayers();
      procedure RefreshProfile();
      procedure RefreshColor();

      procedure ChangeSelectPlayerPosition(Player: integer);

      procedure GenerateAvatars();
      procedure SetPlayerAvatar(Player: integer);
  end;

const
  PlayerColors: array[0..16] of UTF8String = ('Blue', 'Red', 'Green', 'Yellow', 'Magenta', 'Orange', 'Pink',  'Violet', 'Brown', 'Gray', 'DarkBlue', 'Sky', 'Cyan', 'Flame', 'Orchid', 'Harlequin', 'GreenYellow');

implementation

uses
  Math,
  UCommon,
  UGraphic,
  ULanguage,
  UMenuButton,
  UPath,
  USkins,
  USongs,
  UTime,
  UUnicodeUtils;

function TScreenPlayerSelector.ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean;
var
  I: integer;
begin
  Result := true;
  if BtnDown then
    case MouseButton of
      SDL_BUTTON_LEFT: //only change the screen if sing button is clicked
        Self.SingButtonPressed := Self.Interaction in [6, 7];
      SDL_BUTTON_MIDDLE:
        begin
          Result := Self.ParseInput(SDLK_RETURN, 0, true);
          Exit();
        end;
      SDL_BUTTON_WHEELDOWN, SDL_BUTTON_WHEELUP: //rotate profile or avatar
        if Self.Interaction in [1, 5] then
        begin
          Self.ParseInput(IfThen(MouseButton = SDL_BUTTON_WHEELDOWN, SDLK_RIGHT, SDLK_LEFT), 0, true);
          Exit();
        end;
    end;

  Result := inherited ParseMouse(MouseButton, BtnDown, X, Y);
  Self.TransferMouseCords(X, Y);
  for I := 0 to UIni.IMaxPlayerCount - 1 do //on click change to selected player settings or on mouse hover set the focus
    if
      Self.Statics[Self.PlayerCurrentAvatar[I]].Visible
      and (
        Self.InRegion(X, Y, Self.Statics[Self.PlayerCurrent[I]].GetMouseOverArea())
        or Self.InRegion(X, Y, Self.Text[Self.PlayerCurrentText[I]].GetMouseOverArea())
      )
    then
    begin
      Self.Interaction := 1;
      if BtnDown then
      begin
        Self.PlayerIndex := I;
        Self.SkipTo(Self.PlayerAvatars[I]);
        Self.RefreshProfile();
      end;
      Exit();
    end;

  for I := Self.PlayerAvatarButton[0] to High(Self.PlayerAvatarButton) + Self.PlayerAvatarButton[0] - 1 do //on click change avatar or on mouse hover set the focus
    if Self.Button[I].Visible and InRegion(X, Y, Self.Button[I].GetMouseOverArea()) then
    begin
      Self.Interaction := 5;
      if BtnDown then
        Self.SkipTo(I - Self.PlayerAvatarButton[0]);

      Exit();
    end;
end;

function TScreenPlayerSelector.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var
  CurrentAvatar, PrevAvatar: integer;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    if (not Button[PlayerName].Selected) then
    begin
      // check normal keys
      case UCS4UpperCase(CharCode) of
        Ord('R'):
          begin
            Randomize();
            PrevAvatar := Self.Interaction;
            repeat
              CurrentAvatar := Random(Length(UAvatars.AvatarsList));
            until (CurrentAvatar <> PrevAvatar) and (CurrentAvatar <> 0);
            Self.SkipTo(CurrentAvatar);
          end;
      end;
    end
    else if (Interaction = 2) and (IsPrintableChar(CharCode)) then //pass printable chars to button
    begin
      if Length(Button[PlayerName].Text[0].Text) < 12 then
      begin
        Button[PlayerName].Text[0].Text := Button[PlayerName].Text[0].Text +UCS4ToUTF8String(CharCode);
        PlayerNames[PlayerIndex] := Button[PlayerName].Text[0].Text;
      end;
      Exit;
    end;
    // check special keys
    case PressedKey of

      SDLK_BACKSPACE:
        begin
          if (Interaction = 2) then
          begin
            Button[PlayerName].Text[0].DeleteLastLetter();
            PlayerNames[PlayerIndex] := Button[PlayerName].Text[0].Text;
          end
          else
            Self.ParseInput(SDLK_ESCAPE, CharCode, PressedDown);
        end;
      SDLK_ESCAPE :
          if Self.OpenedInOptions then
            Self.FadeTo(@UGraphic.ScreenOptions, UMusic.SoundLib.Back)
          else
            Self.FadeTo(@UGraphic.ScreenSong);
      SDLK_RETURN:
        begin
          if not Self.SingButtonPressed then
            Exit();

          if Self.SelInteraction in [6, 7] then
            if Self.OpenedInOptions then
              Self.FadeTo(@UGraphic.ScreenOptions, UMusic.SoundLib.Back)
            else if UIni.Ini.OnSongClick = 0 then
              Self.FadeTo(@UGraphic.ScreenSong)
            else
              Self.FadeTo(@UGraphic.ScreenSing);
        end;

      // Up and Down could be done at the same time,
      // but I don't want to declare variables inside
      // functions like this one, called so many times
      SDLK_DOWN:
      begin
        InteractNext;
      end;

      SDLK_UP:
      begin
        InteractPrev;
      end;

      SDLK_RIGHT:
        begin

          if (Interaction in [0, 3, 4]) then
            InteractInc;

          if (Interaction = 1) then // Player selection
            begin //TODO: adapt this to new playersize
              if (PlayerIndex < UIni.IPlayersVals[CountIndex]-1) then
            begin
              PlayerIndex := PlayerIndex + 1;

              RefreshProfile();

              isScrolling := true;
              AvatarTarget := PlayerAvatars[PlayerIndex];
            end;
          end;

          if (Interaction = 0) then //Number of players
            begin
				RefreshPlayers();
				AudioPlayback.PlaySound(SoundLib.Option);
			end;

          if (Interaction = 3) then //Player color
          begin
            RefreshColor();
            SelectsS[PlayerColor].SetSelect(true);
			AudioPlayback.PlaySound(SoundLib.Option);
          end;


          if (Interaction = 4) then //level color
          begin
            PlayerLevel[PlayerIndex] := LevelIndex;
			AudioPlayback.PlaySound(SoundLib.Option);
          end;

          if (Interaction = 5) then  //avatar selection
            Self.SkipTo(IfThen(Self.AvatarTarget + 1 >= Length(UAvatars.AvatarsList), 0, Round(Self.AvatarTarget) + 1));

        end;
      SDLK_LEFT:
        begin

          if (Interaction in [0, 3, 4]) then
            InteractDec;

          if (Interaction = 1) then
          begin
            if (PlayerIndex > 0) then
            begin
              PlayerIndex := PlayerIndex - 1;

              RefreshProfile();

              isScrolling := true;
              AvatarTarget := PlayerAvatars[PlayerIndex];
            end;
          end;


          if (Interaction = 0) then
            begin
				RefreshPlayers();
				AudioPlayback.PlaySound(SoundLib.Option);
			end;

          if (Interaction = 3) then
          begin
            RefreshColor();
            SelectsS[PlayerColor].SetSelect(true);
			AudioPlayback.PlaySound(SoundLib.Option);
          end;

          if (Interaction = 4) then
          begin
            PlayerLevel[PlayerIndex] := LevelIndex;
			AudioPlayback.PlaySound(SoundLib.Option);
          end;


          if (Interaction = 5) then
            Self.SkipTo(IfThen(Self.AvatarTarget - 1 < 0, Length(UAvatars.AvatarsList) - 1, Round(Self.AvatarTarget) - 1));

        end;

    end;
  end;
end;

procedure TScreenPlayerSelector.GenerateAvatars();
var
  I: integer;
  AvatarTexture: TTexture;
  Avatar: TAvatar;
  AvatarFile: IPath;
  Hash: string;
begin

  SetLength(PlayerAvatarButton, Length(AvatarsList) + 1);
  SetLength(PlayerAvatarButtonMD5, Length(AvatarsList) + 1);

  // 1st no-avatar dummy
  for I := 1 to UIni.IMaxPlayerCount do
  begin
    NoAvatarTexture[I] := Texture.LoadTexture(Skin.GetTextureFileName('NoAvatar_P' + IntToStr(I)), TEXTURE_TYPE_TRANSPARENT, $FFFFFF);
  end;

  // create no-avatar
  Self.PlayerAvatarButton[0] := Self.AddButton(UThemes.Theme.PlayerSelector.PlayerAvatar);
  Button[PlayerAvatarButton[0]].Texture := NoAvatarTexture[1];
  Button[PlayerAvatarButton[0]].Selectable := false;
  Button[PlayerAvatarButton[0]].Selected := false;
  Button[PlayerAvatarButton[0]].Visible := false;

  // create avatars buttons
  for I := 1 to High(AvatarsList) do
  begin
    // create avatar
    Self.PlayerAvatarButton[I] := Self.AddButton(UThemes.Theme.PlayerSelector.PlayerAvatar);

    AvatarFile := AvatarsList[I];

    Hash := MD5Print(MD5File(AvatarFile.ToNative));
    PlayerAvatarButtonMD5[I] := UpperCase(Hash);

    // load avatar and cache its texture
    Avatar := Avatars.FindAvatar(AvatarFile);
    if (Avatar = nil) then
      Avatar := Avatars.AddAvatar(AvatarFile);

    if (Avatar <> nil) then
    begin
      AvatarTexture := Avatar.GetTexture();
      Button[PlayerAvatarButton[I]].Texture := AvatarTexture;

      Button[PlayerAvatarButton[I]].Selectable := false;
      Button[PlayerAvatarButton[I]].Selected := false;
      Button[PlayerAvatarButton[I]].Visible := false;
    end;

    Avatar.Free;
  end;

end;

procedure TScreenPlayerSelector.ChangeSelectPlayerPosition(Player: integer);
begin
  Self.Button[Self.PlayerSelect].X := UThemes.Theme.PlayerSelector.PlayerSelect[Player].X + UThemes.Theme.PlayerSelector.PlayerSelectCurrent.X;
  Self.Button[Self.PlayerSelect].Y := UThemes.Theme.PlayerSelector.PlayerSelect[Player].Y;
end;

procedure TScreenPlayerSelector.RefreshPlayers();
var
  Count, I: integer;
  DesCol: TRGB;
begin

  Count := UIni.IPlayersVals[CountIndex];

  while (PlayerIndex > Count-1) do
    PlayerIndex := PlayerIndex - 1;

  // Player Colors
  for I := Count-1 downto 0 do
  begin
    if (Ini.PlayerColor[I] > 0) then
      Num[I] := NoRepeatColors(Ini.PlayerColor[I], I, 1)
    else
      Num[I] := NoRepeatColors(1, I, 1);

    DesCol := GetPlayerColor(Num[I]);

    Statics[PlayerCurrent[I]].Texture.ColR := DesCol.R;
    Statics[PlayerCurrent[I]].Texture.ColG := DesCol.G;
    Statics[PlayerCurrent[I]].Texture.ColB := DesCol.B;
  end;

  for I := 0 to UIni.IMaxPlayerCount-1 do
  begin
    Statics[PlayerCurrent[I]].Visible := I < Count;
    Text[PlayerCurrentText[I]].Visible := I < Count;
    Statics[PlayerCurrentAvatar[I]].Visible := I < Count;
  end;

  // list players
  for I := 0 to Count -1 do
  begin
    Text[PlayerCurrentText[I]].Text := PlayerNames[I];
    SetPlayerAvatar(I);
  end;

  RefreshProfile();

  AvatarTarget := PlayerAvatars[PlayerIndex];
  AvatarCurrent := AvatarTarget;

end;

procedure TScreenPlayerSelector.RefreshProfile();
var
  ITmp: array of UTF8String;
  Count, Max, I, J, Index: integer;
  Used: boolean;
begin
  // no-avatar for current player
  Button[PlayerAvatarButton[0]].Texture.TexNum := NoAvatarTexture[PlayerIndex + 1].TexNum;

  Button[PlayerName].Text[0].Text := PlayerNames[PlayerIndex];

  SelectsS[PlayerSelectLevel].SetSelectOpt(PlayerLevel[PlayerIndex]);

  Count := UIni.IPlayersVals[CountIndex];

  ChangeSelectPlayerPosition(PlayerIndex);
  Self.Text[2].Text := ULanguage.Language.Translate('SING_PLAYER_EDIT')+': '+ULanguage.Language.Translate('OPTION_PLAYER_'+IntToStr(Self.PlayerIndex + 1));
  PlayerColorButton(Num[PlayerIndex]);

  Max := Length(PlayerColors) - Count + 1;
  SetLength(ITmp, Max);

  APlayerColor := nil;
  SetLength(APlayerColor, Max);

  Index := 0;
  for I := 0 to High(PlayerColors) do      //for every color
  begin
    Used := false;

    for J := 0 to Count -1 do      //for every active player
    begin
      if (Num[J] - 1 = I) and (J <> PlayerIndex) then   //check if color is already used for not current player
      begin
        Used := true;
        break;
      end;
    end;

    if not (Used) then
    begin
      ITmp[Index] := ULanguage.Language.Translate('C_COLOR_'+PlayerColors[I]);
      APlayerColor[Index] := I + 1;
      Index := Index + 1;
    end;
  end;

  Self.UpdateSelectSlideOptions(UThemes.Theme.PlayerSelector.SelectPlayerColor, Self.PlayerColor, ITmp, Self.ColorIndex);

  for I := 0 to High(APlayerColor) do
  begin
    if (Num[PlayerIndex] = APlayerColor[I]) then
    begin
      SelectsS[PlayerColor].SetSelectOpt(I);
      break;
    end;
  end;

end;

procedure TScreenPlayerSelector.RefreshColor();
begin

  PlayerColorButton(APlayerColor[ColorIndex]);

end;

function TScreenPlayerSelector.NoRepeatColors(ColorP:integer; Interaction:integer; Pos:integer):integer;
var
  Z, Count:integer;
begin
  Count := UIni.IPlayersVals[CountIndex];

  if (ColorP > Length(PlayerColors)) then
    ColorP := NoRepeatColors(1, Interaction, Pos);

  if (ColorP <= 0) then
    ColorP := NoRepeatColors(High(PlayerColors), Interaction, Pos);

  for Z := Count -1 downto 0 do
  begin
    if (Num[Z] = ColorP) and (Z <> Interaction) then
      ColorP := NoRepeatColors(ColorP + Pos, Interaction, Pos)
  end;

  Result := ColorP;

end;

procedure TScreenPlayerSelector.PlayerColorButton(K: integer);
var
  Col, DesCol: TRGB;
begin

  Col := GetPlayerLightColor(K);

  Button[PlayerName].SelectColR:= Col.R;
  Button[PlayerName].SelectColG:= Col.G;
  Button[PlayerName].SelectColB:= Col.B;

  Button[PlayerAvatar].SelectColR:= Col.R;
  Button[PlayerAvatar].SelectColG:= Col.G;
  Button[PlayerAvatar].SelectColB:= Col.B;

  SelectsS[PlayerColor].SBGColR:= Col.R;
  SelectsS[PlayerColor].SBGColG:= Col.G;
  SelectsS[PlayerColor].SBGColB:= Col.B;

  SelectsS[PlayerSelectLevel].SBGColR:= Col.R;
  SelectsS[PlayerSelectLevel].SBGColG:= Col.G;
  SelectsS[PlayerSelectLevel].SBGColB:= Col.B;

  DesCol := GetPlayerColor(K);

  Statics[PlayerCurrent[PlayerIndex]].Texture.ColR := DesCol.R;
  Statics[PlayerCurrent[PlayerIndex]].Texture.ColG := DesCol.G;
  Statics[PlayerCurrent[PlayerIndex]].Texture.ColB := DesCol.B;

  Button[PlayerName].DeselectColR:= DesCol.R;
  Button[PlayerName].DeselectColG:= DesCol.G;
  Button[PlayerName].DeselectColB:= DesCol.B;

  Button[PlayerAvatar].DeselectColR:= DesCol.R;
  Button[PlayerAvatar].DeselectColG:= DesCol.G;
  Button[PlayerAvatar].DeselectColB:= DesCol.B;

  SelectsS[PlayerColor].SBGDColR := DesCol.R;
  SelectsS[PlayerColor].SBGDColG:= DesCol.G;
  SelectsS[PlayerColor].SBGDColB:= DesCol.B;

  SelectsS[PlayerSelectLevel].SBGDColR := DesCol.R;
  SelectsS[PlayerSelectLevel].SBGDColG:= DesCol.G;
  SelectsS[PlayerSelectLevel].SBGDColB:= DesCol.B;

  Button[PlayerAvatarButton[0]].Texture.ColR := DesCol.R;
  Button[PlayerAvatarButton[0]].Texture.ColG := DesCol.G;
  Button[PlayerAvatarButton[0]].Texture.ColB := DesCol.B;

  if (PlayerAvatars[PlayerIndex] = 0) then
  begin
    Statics[PlayerCurrentAvatar[PlayerIndex]].Texture.ColR := DesCol.R;
    Statics[PlayerCurrentAvatar[PlayerIndex]].Texture.ColG := DesCol.G;
    Statics[PlayerCurrentAvatar[PlayerIndex]].Texture.ColB := DesCol.B;
  end;

  SelectsS[PlayerColor].SetSelect(false);
  SelectsS[PlayerSelectLevel].SetSelect(false);
  Button[PlayerName].SetSelect(false);
  Button[PlayerAvatar].SetSelect(false);

  Num[PlayerIndex] := K;
  Ini.PlayerColor[PlayerIndex] := K;
end;

constructor TScreenPlayerSelector.Create;
var
  I: integer;
begin
  inherited Create;

  Self.LoadFromTheme(UThemes.Theme.PlayerSelector);
  Self.PlayersCount := Self.AddSelectSlide(UThemes.Theme.PlayerSelector.SelectPlayersCount, Self.CountIndex, UIni.IPlayers);
  Self.PlayerSelect := Self.AddButton(UThemes.Theme.PlayerSelector.PlayerSelectCurrent);

  for I := 0 to UIni.IMaxPlayerCount -1 do
  begin
    Self.PlayerCurrentAvatar[I] := Self.AddStatic(UThemes.Theme.PlayerSelector.PlayerSelectAvatar[I]);
    Self.PlayerCurrent[I] := Self.AddStatic(UThemes.Theme.PlayerSelector.PlayerSelect[I]);
    Self.PlayerCurrentText[I] := Self.AddText(UThemes.Theme.PlayerSelector.PlayerSelectText[I]);
  end;


  Self.PlayerName := Self.AddButton(UThemes.Theme.PlayerSelector.PlayerButtonName);
  Button[PlayerName].Text[0].Writable := true;
  Self.PlayerColor := AddSelectSlide(UThemes.Theme.PlayerSelector.SelectPlayerColor, Self.ColorIndex, PlayerColors, 'OPTION_VALUE_');
  Self.PlayerSelectLevel := Self.AddSelectSlide(UThemes.Theme.PlayerSelector.SelectPlayerLevel, Self.LevelIndex, UIni.IDifficulty, 'OPTION_VALUE_');
  Self.PlayerAvatar := Self.AddButton(UThemes.Theme.PlayerSelector.PlayerButtonAvatar);
  Self.ExitButton := Self.AddButton(UThemes.Theme.PlayerSelector.ExitButton);
  Self.SingButton := Self.AddButton(UThemes.Theme.PlayerSelector.SingButton);

  isScrolling := false;
  GenerateAvatars();

  Self.NumVisibleAvatars := UThemes.Theme.PlayerSelector.PlayerScrollAvatar.NumAvatars;
  Self.DistanceVisibleAvatars := UThemes.Theme.PlayerSelector.PlayerScrollAvatar.DistanceAvatars;

  Interaction := 0;
end;

procedure TScreenPlayerSelector.SetPlayerAvatar(Player: integer);
var
  Col: TRGB;
begin
  if (PlayerAvatars[Player] = 0) then
  begin
    Statics[PlayerCurrentAvatar[Player]].Texture := NoAvatarTexture[Player + 1];

    Col := GetPlayerColor(Num[Player]);

    Statics[PlayerCurrentAvatar[Player]].Texture.ColR := Col.R;
    Statics[PlayerCurrentAvatar[Player]].Texture.ColG := Col.G;
    Statics[PlayerCurrentAvatar[Player]].Texture.ColB := Col.B;
  end
  else
    Statics[PlayerCurrentAvatar[Player]].Texture := Button[PlayerAvatarButton[PlayerAvatars[Player]]].Texture;

  Self.Statics[Self.PlayerCurrentAvatar[Player]].Texture.X := UThemes.Theme.PlayerSelector.PlayerSelectAvatar[Player].X;
  Self.Statics[Self.PlayerCurrentAvatar[Player]].Texture.Y := UThemes.Theme.PlayerSelector.PlayerSelectAvatar[Player].Y;
  Self.Statics[Self.PlayerCurrentAvatar[Player]].Texture.W := UThemes.Theme.PlayerSelector.PlayerSelectAvatar[Player].W;
  Self.Statics[Self.PlayerCurrentAvatar[Player]].Texture.H := UThemes.Theme.PlayerSelector.PlayerSelectAvatar[Player].H;
  Self.Statics[Self.PlayerCurrentAvatar[Player]].Texture.Z := UThemes.Theme.PlayerSelector.PlayerSelectAvatar[Player].Z;

  Statics[PlayerCurrentAvatar[Player]].Texture.Int := 1;

end;

procedure TScreenPlayerSelector.OnShow;
var
  I: integer;
begin
  inherited;
  Self.SingButtonPressed := true;
  Self.Button[Self.ExitButton].Visible := Self.OpenedInOptions;
  Self.Button[Self.SingButton].Visible := not Self.OpenedInOptions;

  CountIndex := Ini.Players;

  for I := 0 to UIni.IMaxPlayerCount-1 do
  begin
    PlayerNames[I] := Ini.Name[I];
    PlayerLevel[I] := Ini.PlayerLevel[I];
    PlayerAvatars[I] := GetArrayIndex(PlayerAvatarButtonMD5, Ini.PlayerAvatar[I]);
  end;

  AvatarTarget := PlayerAvatars[PlayerIndex];
  AvatarCurrent := AvatarTarget;

  RefreshPlayers;

  // list players
  for I := 1 to PlayersPlay do
  begin
    Text[PlayerCurrentText[I - 1]].Text := Ini.Name[I - 1];
    SetPlayerAvatar(I - 1);
  end;

  PlayerColorButton(Num[PlayerIndex]);

  SelectsS[PlayersCount].SetSelectOpt(CountIndex);

  Button[PlayerName].Text[0].Text := PlayerNames[PlayerIndex];

  isScrolling := false;

  Interaction := 0;
end;

procedure TScreenPlayerSelector.OnHide();
var
  Col: TRGB;
  I: integer;
begin
  inherited;
  UIni.Ini.Players := Self.CountIndex;
  UNote.PlayersPlay := UIni.IPlayersVals[Self.CountIndex];
  for I := 1 to UIni.IPlayersVals[Self.CountIndex] do
  begin
    UIni.Ini.Name[I - 1] := Self.PlayerNames[I - 1];
    UIni.Ini.PlayerColor[I - 1] := Self.Num[I - 1];
    UIni.Ini.SingColor[I - 1] := Self.Num[I - 1];
    UIni.Ini.PlayerLevel[I - 1] := Self.PlayerLevel[I - 1];
    UIni.Ini.PlayerAvatar[I - 1] := Self.PlayerAvatarButtonMD5[Self.PlayerAvatars[I - 1]];
    if Self.PlayerAvatars[I - 1] = 0 then
    begin
      UAvatars.AvatarPlayerTextures[I] := UAvatars.NoAvatartexture[I];
      Col := UThemes.GetPlayerColor(Self.Num[I - 1]);
      UAvatars.AvatarPlayerTextures[I].ColR := Col.R;
      UAvatars.AvatarPlayerTextures[I].ColG := Col.G;
      UAvatars.AvatarPlayerTextures[I].ColB := Col.B;
    end
    else
    begin
      Self.Button[Self.PlayerAvatarButton[Self.PlayerAvatars[I-1]]].Texture.Int := 1;
      UAvatars.AvatarPlayerTextures[I] := Self.Button[Self.PlayerAvatarButton[Self.PlayerAvatars[I-1]]].Texture;
    end;
  end;
  UIni.Ini.SaveNumberOfPlayers();
  UIni.Ini.SaveNames();
  UIni.Ini.SavePlayerColors();
  UIni.Ini.SavePlayerAvatars();
  UIni.Ini.SavePlayerLevels();
  UThemes.LoadPlayersColors();
  UThemes.Theme.ThemeScoreLoad();
  UGraphic.ScreenScore := UScreenScore.TScreenScore.Create();
  UGraphic.ScreenSing := UScreenSingController.TScreenSingController.Create();
end;

procedure TScreenPlayerSelector.SetAvatarScroll;
var
  B:        integer;
  Angle:    real;
  Pos:      real;
  VS:       integer;
  Padding:  real;
  X:        real;
  Factor:   real;
begin

  VS := Length(AvatarsList);

  case NumVisibleAvatars of
    3: Factor := 1;
    5: Factor := 1.5;
    else Factor := 0;
   end;

  // Update positions of all avatars
  for B := PlayerAvatarButton[0] to PlayerAvatarButton[High(AvatarsList)] do
  begin
    Button[B].Visible := true; // adjust visibility

    // Pos is the distance to the centered avatar in the range [-VS/2..+VS/2]
    Pos := (B - PlayerAvatarButton[0] - AvatarCurrent);
    if (Pos < -VS/2) then
      Pos := Pos + VS
    else if (Pos > VS/2) then
      Pos := Pos - VS;

    // Avoid overlapping of the front avatars.
    // Use an alternate position for the others.
    if (Abs(Pos) < (NumVisibleAvatars/2)) then
    begin
      if (NumVisibleAvatars > 1) then
      begin
        Angle := Pi * (Pos / Min(VS, NumVisibleAvatars)); // Range: (-1/4*Pi .. +1/4*Pi)
        Self.Button[B].H := Abs(UThemes.Theme.PlayerSelector.PlayerAvatar.H * cos(Angle*0.8));
        Self.Button[B].W := Abs(UThemes.Theme.PlayerSelector.PlayerAvatar.W * cos(Angle*0.8));
        Padding := (Self.Button[B].W - UThemes.Theme.PlayerSelector.PlayerAvatar.W)/2;
        X := Sin(Angle*1.3) * 0.9;
        Self.Button[B].X := UThemes.Theme.PlayerSelector.PlayerAvatar.X + (UThemes.Theme.PlayerSelector.PlayerAvatar.W * Factor + DistanceVisibleAvatars) * X - Padding;
        Self.Button[B].Y := (UThemes.Theme.PlayerSelector.PlayerAvatar.Y  + (UThemes.Theme.PlayerSelector.PlayerAvatar.H - Abs(UThemes.Theme.PlayerSelector.PlayerAvatar.H * cos(Angle))) * 0.5);
        Self.Button[B].Z := 0.95 - Abs(Pos) * 0.01;
        Self.Button[B].Texture.Int := IfThen(B <> PlayerAvatarButton[PlayerAvatars[PlayerIndex]], 0.7, 1);
      end
      else
      begin
        Self.Button[B].X := UThemes.Theme.PlayerSelector.PlayerAvatar.X;
        Self.Button[B].Y := UThemes.Theme.PlayerSelector.PlayerAvatar.Y;
        AvatarCurrent := AvatarTarget;
        isScrolling := false;
      end
    end
    else
      Self.Button[B].Visible := false;
  end;
end;

procedure TScreenPlayerSelector.SetAnimationProgress(Progress: real);
begin
end;

procedure TScreenPlayerSelector.SkipTo(Target: cardinal);
begin
  Self.IsScrolling := true;
  if (Target = 0) and (Self.AvatarTarget = Length(UAvatars.AvatarsList) - 1) then //go to initial song if reach the end of subselection list
    Self.AvatarCurrent := -1
  else if (Target = Length(UAvatars.AvatarsList) - 1) and (Self.AvatarTarget = 0) then //go to final song if reach the start of subselection list
    Self.AvatarCurrent := Length(UAvatars.AvatarsList);

  Self.AvatarTarget := Target;
  Self.PlayerAvatars[Self.PlayerIndex] := Self.AvatarTarget;
  Self.SetPlayerAvatar(Self.PlayerIndex);
end;

function TScreenPlayerSelector.Draw: boolean;
var
  dx: real;
  dt: real;
  I: integer;
begin
  //inherited Draw;
  //heres a little Hack, that causes the Statics
  //are Drawn after the Buttons because of some Blending Problems.
  //This should cause no Problems because all Buttons on this screen
  //Has Z Position.
  DrawBG;

  if isScrolling then
  begin
    dx := AvatarTarget - AvatarCurrent;
    dt := TimeSkip * 7;

    if dt > 1 then
      dt := 1;

    AvatarCurrent := AvatarCurrent + dx*dt;

    if SameValue(AvatarCurrent, AvatarTarget, 0.002) and (Length(AvatarsList) > 0) then
    begin
      isScrolling := false;
      AvatarCurrent := AvatarTarget;
    end;
  end;

  SetAvatarScroll;

  // set current name = name in list
  Text[PlayerCurrentText[PlayerIndex]].Text := Button[PlayerName].Text[0].Text;

  //Instead of Draw FG Procedure:
  //We draw Buttons for our own
  for I := 0 to Length(Button) - 1 do
    Button[I].Draw;

  // SelectsS
  for I := 0 to Length(SelectsS) - 1 do
    SelectsS[I].Draw;

  // Statics
  for I := 0 to Length(Statics) - 1 do
    Statics[I].Draw;

  // and texts
  for I := 0 to Length(Text) - 1 do
    Text[I].Draw;

  Result := true;
end;

end.
