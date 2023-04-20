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


unit UScreenOptionsSongdirs;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  Classes,
  UCommon,
  sdl2,
  UMenu,
  UDisplay,
  UMusic,
  UFiles,
  UIni,
  UThemes,
  UPathUtils,
  UPath,
  UScreenMain,
  USongs,
  UTexture;

type

  TScreenOptionsSongdirs = class(TMenu)
    private
      SongPathList: IInterfaceList;
      MakeSongPathList: array[0..5] of boolean;
      fDirname: IPath;
      FolderName, DefaultSongdir, AddFolderButton, ExitButton: integer;
      DirButton: array[1..6] of integer;
      NumFolders, CurrentFolderSelected: integer;
      bMaxDir, bChange: boolean;

    public
      constructor Create; override;
      function ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure AddFolder(bCreateDir: boolean);
      procedure DelFolder;
      procedure SaveFolders;
      procedure ShiftFolders(Current: integer);
      procedure ExitSongdirs;
      procedure LoadFolders(CreateButtons: boolean);
  end;

const
  MAX_DIR = 6;
  MAX_LENGTH = 50;

implementation

uses
  UGraphic,
  UUnicodeUtils,
  USkins,
  SysUtils;

procedure OnFolderNotExist(Value: boolean; Data: Pointer);
var
  bMakedir: boolean;
begin
  Display.CheckOK := Value;
  if (Value) then
  begin
    Display.CheckOK := false;

    //Make folder
    if ScreenOptionsSongdirs.fDirname.Equals(PATH_NONE()) or not ScreenOptionsSongdirs.fDirname.CreateDirectory(true) then
      Exit;
    bMakedir := true;
  end
  else
  begin
    bMakedir := false;
  end;
  //Clean folder name entry text
  ScreenOptionsSongdirs.Button[ScreenOptionsSongdirs.FolderName].Text[0].Text := '';
  ScreenOptionsSongdirs.Button[ScreenOptionsSongdirs.FolderName].Text[1].Visible := true;
  ScreenOptionsSongdirs.AddFolder(bMakedir);
end;

function TScreenOptionsSongdirs.ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean;
var
  I: integer;
begin
  inherited ParseMouse(MouseButton, BtnDown, X, Y);
  Self.TransferMouseCords(X, Y);
  Result := true;

  for I := 1 to Self.NumFolders do
  begin
    // Folder path hover
    if InRegion(X, Y, Button[Self.DirButton[I] + 1].GetMouseOverArea) then
    begin
      if (Self.CurrentFolderSelected > Self.FolderName) then
      begin
        Self.Button[Self.CurrentFolderSelected].SetSelect(false);   // Deselect last selected folder.
        Self.Button[Self.CurrentFolderSelected + 1].Visible := false;
      end;
      Self.CurrentFolderSelected := Self.DirButton[I] + 1;
      Self.Button[Self.CurrentFolderSelected].SetSelect(true);
      if (Self.DirButton[1] <> Self.CurrentFolderSelected - 1) then
        Self.Button[Self.CurrentFolderSelected + 1].Visible := true;
      if (Length(Self.Button[Self.FolderName].Text[0].Text) = 0) then
      begin
        Self.Button[Self.FolderName].Text[1].Visible := true;
      end;
      Break;
    end;
    // Folder img hover
    if InRegion(X, Y, Button[Self.DirButton[I]].GetMouseOverArea) then
    begin
      if (Length(Self.Button[Self.FolderName].Text[0].Text) = 0) then
      begin
        Self.Button[Self.FolderName].Text[1].Visible := true;
      end;
      Break;
    end;
  end;
  // FolderName hover
  if InRegion(X, Y, Button[Self.FolderName].GetMouseOverArea) and (Self.CurrentFolderSelected <> Self.FolderName) then
  begin
    Self.Button[Self.CurrentFolderSelected].SetSelect(false);   // Deselect last selected folder.
    Self.Button[Self.CurrentFolderSelected + 1].Visible := false;
  end;
end;

function TScreenOptionsSongdirs.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    if (Interaction = Self.FolderName) and (not Self.bMaxDir) and (IsPrintableChar(CharCode)) then //pass printable chars to button
    begin
      if (Self.CurrentFolderSelected <> Self.FolderName) then
        Self.Button[Self.CurrentFolderSelected + 1].Visible := false;
      if (Length(Self.Button[Self.FolderName].Text[0].Text) < MAX_LENGTH) then
      begin
        Self.Button[Self.FolderName].Text[0].Text := Self.Button[Self.FolderName].Text[0].Text + UCS4ToUTF8String(CharCode);
      end;
      if (Length(Self.Button[Self.FolderName].Text[0].Text) > 0) then
      begin
        Self.Button[Self.FolderName].Text[1].Visible := false;
      end;
      Exit;
    end;

    // check special keys
    case PressedKey of
      SDLK_BACKSPACE: // del
        begin
          if (Interaction = Self.FolderName) and (not Self.bMaxDir) then
          begin
            if (Self.CurrentFolderSelected <> Self.FolderName) then
              Self.Button[Self.CurrentFolderSelected + 1].Visible := false;
            Self.Button[Self.FolderName].Text[0].DeleteLastLetter();
            if (Length(Self.Button[Self.FolderName].Text[0].Text) = 0) then
            begin
              Self.Button[Self.FolderName].Text[1].Visible := true;
            end;
          end
          else
            Self.ParseInput(SDLK_ESCAPE, CharCode, PressedDown);
        end;

      SDLK_ESCAPE:
        begin
          Self.ExitSongdirs();
        end;

      SDLK_RETURN:
        begin
          if (Self.CurrentFolderSelected <> Self.FolderName) then
            Self.Button[Self.CurrentFolderSelected + 1].Visible := false;
          if (Interaction = Self.FolderName) then
            Self.Button[Self.FolderName].Text[1].Visible := false;
          //Add Folder to list
          if (Interaction = Self.AddFolderButton) then
          begin 
            Self.fDirname := Path(Self.Button[Self.FolderName].Text[0].Text);
            if (LengthUTF8(Self.fDirname.ToUTF8()) > 0) and not Self.bMaxDir then
            begin
              Self.bChange := true;
              Self.fDirname := Self.fDirname.GetAbsolutePath();
              if not Self.fDirname.IsDirectory() then
                ScreenPopupCheck.ShowPopup('SING_OPTIONS_SONGDIRS_NOTEXIST_FOLDER', @OnFolderNotExist, nil, false)
              else
              begin
                Self.AddFolder(false);
                //Clean folder name entry text
                Self.Button[Self.FolderName].Text[0].Text := '';
                Self.Button[Self.FolderName].Text[1].Visible := true;
                Self.Button[Self.DirButton[1] + 1].SetSelect(true);
              end;
            end;
          end
          else // Click on delete song folder button
          if (Interaction > Self.ExitButton) and ((Interaction mod 3) = 2) then
          begin
            //Delete selected Folder from list
            Self.bChange := true;
            Self.DelFolder();
          end
          else // Copy song folder name
          if (Interaction > Self.ExitButton) and (not Self.bMaxDir) and ((Interaction mod 3) = 0) then
          begin
            Self.Button[Self.DefaultSongdir + 1].Selectable := true;
            Self.Button[Self.FolderName].Text[0].Text := Self.Button[Interaction + 1].Text[0].Text;
            Self.Button[Self.FolderName].Text[1].Visible := false;
            Self.Button[Self.DefaultSongdir + 1].Selectable := false;
          end
          else if SelInteraction = Self.ExitButton then
          begin
              Self.ExitSongdirs();
          end;
        end;
      SDLK_LEFT:
      begin
          InteractPrev;
      end;
      SDLK_RIGHT:
      begin
          InteractNext;
      end;
      SDLK_UP:
      begin
          InteractPrev;
      end;
      SDLK_DOWN:
      begin
          InteractNext;
      end;
    end;
  end;
end;

constructor TScreenOptionsSongdirs.Create;
begin
  inherited Create;

  Self.LoadFromTheme(UThemes.Theme.OptionsSongdirs);

  Self.FolderName := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonFolderName);
  Self.Button[Self.FolderName].Text[0].Writable := true;
  Self.AddFolderButton := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonAdd);
  Self.ExitButton := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonExit);

  Self.DirButton[1] := Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderButton1);
  Self.DefaultSongdir := Self.DirButton[1] + 1;
  Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderNameButton1);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.DelFolderButton1);
  Self.AddButtonText(Self.Button[Self.DirButton[1] + 1],10,5,255,255,255,0,20,0,'');
  Self.DirButton[2] := Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderButton2);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderNameButton2);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.DelFolderButton2);
  Self.AddButtonText(Self.Button[Self.DirButton[2] + 1],10,5,255,255,255,0,20,0,'');
  Self.DirButton[3] := Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderButton3);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderNameButton3);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.DelFolderButton3);
  Self.AddButtonText(Self.Button[Self.DirButton[3] + 1],10,5,255,255,255,0,20,0,'');
  Self.DirButton[4] := Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderButton4);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderNameButton4);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.DelFolderButton4);
  Self.AddButtonText(Self.Button[Self.DirButton[4] + 1],10,5,255,255,255,0,20,0,'');
  Self.DirButton[5] := Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderButton5);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderNameButton5);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.DelFolderButton5);
  Self.AddButtonText(Self.Button[Self.DirButton[5] + 1],10,5,255,255,255,0,20,0,'');
  Self.DirButton[6] := Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderButton6);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.FolderNameButton6);
  Self.AddButton(UThemes.Theme.OptionsSongdirs.DelFolderButton6);
  Self.AddButtonText(Self.Button[Self.DirButton[6] + 1],10,5,255,255,255,0,20,0,'');

  Self.Interaction := 0;
end;

procedure TScreenOptionsSongdirs.OnShow;
var
  I: integer;
begin
  inherited;

  Self.bMaxDir := false;
  Self.bChange := false;
  Self.fDirname := PATH_NONE();
  Self.Interaction := 0;

  //Hide folder buttons
  for I := 1 to MAX_DIR do
  begin
    Self.Button[Self.DirButton[I]].Visible := false;
    Self.Button[Self.DirButton[I] + 1].Visible := false;
    Self.Button[Self.DirButton[I] + 2].Visible := false;
  end;

  Self.LoadFolders(true);

  Self.Button[Self.DefaultSongdir].Selectable := false;
  Self.Button[Self.FolderName].Visible := true;
  Self.Button[Self.FolderName].Text[0].Text := '';
  Self.Button[Self.FolderName].Text[1].Visible := true;
  Self.Button[Self.AddFolderButton].Selectable := true;
end;

procedure TScreenOptionsSongdirs.AddFolder(bCreateDir: boolean);
var
  I: integer;
begin
  Self.SongPathList.Add(Self.fDirname);
  Self.MakeSongPathList[Self.NumFolders] := bCreateDir;
  Inc(Self.NumFolders);
  I := Self.DirButton[Self.NumFolders];
  Self.Button[I + 1].Text[0].Text := Self.fDirname.ToUTF8();
  Self.Button[I + 1].Visible := true;
  Self.Button[I].Visible := true;

  //Block entry button when max folder
  if (Self.NumFolders  = MAX_DIR) then
  begin
    Self.bMaxDir := true;
    Self.Button[Self.AddFolderButton].Selectable := false;
    Self.Button[Self.FolderName].Text[0].Writable := false;
  end;
end;

procedure TScreenOptionsSongdirs.DelFolder;
var
  I: integer;
begin
  for I := 0 to Self.SongPathList.Count - 1 do
  begin
    Self.fDirname := Self.SongPathList[I] as IPath;
    if (Self.fDirname.ToUTF8() = Self.Button[Self.CurrentFolderSelected].Text[0].Text) then
    begin
      Self.Button[Self.CurrentFolderSelected + 1].Visible := false;
      Self.Button[Self.CurrentFolderSelected].Text[0].Text := '';
      Self.ShiftFolders(Self.CurrentFolderSelected);
      Self.CurrentFolderSelected := Self.CurrentFolderSelected - 3;
      Self.SongPathList.Delete(I);
      Self.MakeSongPathList[I] := false;
      Dec(Self.NumFolders);
      Break;
    end;
  end;
  if (Self.NumFolders < MAX_DIR) then
  begin
    Self.bMaxDir := false;
    Self.Button[Self.AddFolderButton].Selectable := true;
    Self.Button[Self.FolderName].Text[0].Writable := true;
  end;
end;

procedure TScreenOptionsSongdirs.SaveFolders;
var
  I: integer;
  CurrentPath: IPath;
  bMakeDir: boolean;
begin
    UPathUtils.InitializeSongPaths();
  for I := 0 to Self.SongPathList.Count - 1 do
  begin
    CurrentPath := Self.SongPathList[I] as IPath;
    bMakeDir := Self.MakeSongPathList[I];
    UPathUtils.AddSongPath(CurrentPath, bMakeDir);
  end;

  //Save changes.
  UIni.Ini.SaveSongdirs();
end;

procedure TScreenOptionsSongdirs.ShiftFolders(Current: integer);
var
  I: integer;
begin
  for I := ((Current - 1) Div 3) to (Self.NumFolders - 1) do
    Self.Button[Self.DirButton[I] + 1].Text[0].Text := Self.Button[Self.DirButton[I + 1] + 1].Text[0].Text;

  Self.Button[Current + 1].Visible := false;
  //Clean and hide last folder button
  I := Self.DirButton[Self.NumFolders];
  Self.Button[I].Visible := false;
  Self.Button[I + 1].Visible := false;
  Self.Button[I + 1].Text[0].Text := '';
  Self.Button[I + 2].Visible := false;
end;

procedure TScreenOptionsSongdirs.ExitSongdirs;
begin
  if Self.bChange then
  begin
    Self.SaveFolders();
    //Refresh Songs
    UGraphic.ScreenMain.ReloadSongs(false);
  end;
  Self.FadeTo(@UGraphic.ScreenOptions, UMusic.SoundLib.Back);
end;

procedure TScreenOptionsSongdirs.LoadFolders(CreateButtons: boolean);
var
  I,J: integer;
  CurrentPath: IPath;
begin
  // Folder list
  Self.NumFolders := 0;
  Self.SongPathList := TInterfaceList.Create();
  for I := 0 to UPathUtils.SongPaths.Count - 1 do
  begin
    If (I < MAX_DIR) then   // Max. Folder
    begin
      CurrentPath := UPathUtils.SongPaths[I] as IPath;
      Self.SongPathList.Add(CurrentPath);
    end;
  end;
  for I := 0 to Self.SongPathList.Count - 1 do
  begin
    CurrentPath := Self.SongPathList[I] as IPath;
    if CreateButtons then
    begin
      J := Self.DirButton[I + 1];
      Self.Button[J].Visible := true;
      Self.Button[J + 1].Visible := true;
      Self.Button[J + 1].Text[0].Text := CurrentPath.GetPath().ToUTF8();
      Inc(Self.NumFolders);
    end
    else  // Text refresh
      Self.Button[Self.DirButton[I + 1] + 1].Text[0].Text := CurrentPath.GetPath().ToUTF8();
  end;
  //Block entry button when max folder
  if (Self.NumFolders = MAX_DIR) then
  begin
    Self.bMaxDir := true;
    Self.Button[Self.AddFolderButton].Selectable := false;
    Self.Button[Self.FolderName].Text[0].Writable := false;
  end
  else
  begin
    Self.bMaxDir := false;
    Self.Button[Self.AddFolderButton].Selectable := true;
    Self.Button[Self.FolderName].Text[0].Writable := true;
  end;
end;
end.
