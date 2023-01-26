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
      fDirname:   IPath;
      FolderName, DefaultSongdir, AddFolderButton, DelFolderButton, SaveFoldersButton, RedSaveButton, CurrentFolderSelected: integer;
      bChange, bMaxDir: boolean;

    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure SaveFolders;
      procedure ExitSongdirs;
      procedure LoadFolders(CreateButtons: boolean);
  end;

const
  MAX_DIR = 10;

implementation

uses
  UGraphic,
  UUnicodeUtils,
  USkins,
  SysUtils;

procedure OnEscapeSongdirs(Value: boolean; Data: Pointer);
begin
  Display.CheckOK := Value;
  if (Value) then
  begin
    Display.CheckOK := false;

    ScreenOptionsSongdirs.fDirname := PATH_NONE;
    ScreenOptionsSongdirs.SongPathList := nil;
    ScreenOptionsSongdirs.ExitSongdirs();
  end;
end;

function TScreenOptionsSongdirs.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    if (Interaction = Self.FolderName) and (IsPrintableChar(CharCode)) then //pass printable chars to button
    begin
      if Length(Button[Self.FolderName].Text[0].Text) < 120 then
      begin
        Button[Self.FolderName].Text[0].Text := Button[Self.FolderName].Text[0].Text + UCS4ToUTF8String(CharCode);
      end;
      Exit;
    end
    else if (Interaction > Self.FolderName) then
      begin
WriteLn(Self.Button[Interaction].Text[0].Text);
        //Self.OldFolderSelected := Self.CurrentFolderSelected;   // Deselect last selected folder.
        Self.CurrentFolderSelected := Interaction;
        //Self.Button[Self.CurrentFolderSelected].SetSelect(not Self.Button[Self.CurrentFolderSelected].Selected);
      end;

    // check special keys
    case PressedKey of
      SDLK_BACKSPACE: // del
        begin
          if (Interaction = Self.FolderName) then
          begin
            Self.Button[Self.FolderName].Text[0].DeleteLastLetter();
          end
          else
            Self.ParseInput(SDLK_ESCAPE, CharCode, PressedDown);
        end;

      SDLK_ESCAPE:
        begin
          //Empty Filename and go to last Screen
          if Self.bChange then
            ScreenPopupCheck.ShowPopup('MSG_END_SONGDIRS', @OnEscapeSongdirs, nil, false)
          else
            Self.ExitSongdirs();
        end;
      SDLK_RETURN:
        begin
          if (Interaction = Self.AddFolderButton) then
          begin
            //Add Folder to list
            Self.fDirname := Path(Self.Button[Self.FolderName].Text[0].Text);
WriteLn(High(Self.Button));
WriteLn(Self.fDirname.ToUTF8());
            if (LengthUTF8(Self.fDirname.ToUTF8()) > 0) and not bMaxDir then
            begin
              Self.AddButton(90, 110+((High(Self.Button) - Self.FolderName)*35),600,30,USkins.Skin.GetTextureFileName('Button'));
              Self.AddButtonText(10,5,255,255,255,0,20,0,Self.fDirname.ToUTF8());
              Self.AddStatic(60, 112+((High(Self.Button) - Self.DefaultSongdir)*35),25,25,USkins.Skin.GetTextureFileName('Optionsbuttonsongdirs'));
              //Clean folder name entry text
              Self.fDirname := PATH_NONE;
              Button[Self.FolderName].Text[0].SetText(Self.fDirname.ToUTF8());
              Self.bChange := true;
              Self.Button[Self.SaveFoldersButton].Visible := false;
              Self.Button[Self.RedSaveButton].Visible := true;
              //Block entry button when max folder
              if (Length(Self.Button) - Self.DefaultSongdir = MAX_DIR) then
                Self.bMaxDir := true;
            end;
          end
          else if (Interaction = Self.DelFolderButton) then
          begin
            //Delete selected Folder from list
            if (Self.CurrentFolderSelected > Self.FolderName) then
            begin
WriteLn('Se borra: '+Self.Button[Self.CurrentFolderSelected].Text[0].Text+', Int:'+Self.CurrentFolderSelected.ToString());
              Self.DelButton(Self.CurrentFolderSelected);
              SetLength(Self.Statics,Length(Self.Statics) - 1);
              Self.CurrentFolderSelected := 0;
              Self.bChange := true;
              Self.Button[Self.SaveFoldersButton].Visible := false;
              Self.Button[Self.RedSaveButton].Visible := true;
              if (Length(Self.Button) - Self.DefaultSongdir < MAX_DIR) then
                bMaxDir := false;
            end;
          end
          else if (Interaction = Self.RedSaveButton) then
          begin
            //Save Songdirs
            Self.bChange := false;
            Self.SaveFolders();
          end
          else if SelInteraction = 0 then
          begin
            if Self.bChange then
              ScreenPopupCheck.ShowPopup('MSG_END_SONGDIRS', @OnEscapeSongdirs, nil, false)
            else
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

  Self.bMaxDir := false;
  Self.fDirname := PATH_NONE;

  Self.LoadFromTheme(UThemes.Theme.OptionsSongdirs);

  Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonExit);
  Self.AddFolderButton := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonAdd);
  Self.DelFolderButton := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonDelete);
  Self.SaveFoldersButton := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonSave);
  Self.RedSaveButton := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonSaveRed);

  Self.FolderName := Self.AddButton(UThemes.Theme.OptionsSongdirs.ButtonFolderName);
  Self.DefaultSongdir := Self.FolderName + 1;
  Self.Button[Self.SaveFoldersButton].Selectable := false;

  Self.Interaction := 0;
end;

procedure TScreenOptionsSongdirs.OnShow;
begin
  inherited;

  Self.Interaction := 0;
  Self.bChange := false;
  Self.LoadFolders(true);

  Self.Button[Self.DefaultSongdir].Selectable := false;
  Self.Button[Self.SaveFoldersButton].Visible := true;
  Self.Button[Self.RedSaveButton].Visible := false;
  Self.Button[Self.FolderName].Text[0].Text := Self.fDirname.ToUTF8();
end;

procedure TScreenOptionsSongdirs.SaveFolders;
var
  I: integer;
begin
  UPathUtils.InitializeSongPaths();
  for I := Self.DefaultSongdir to Length(Self.Button) - 1 do
    UPathUtils.AddSongPath(UPath.Path(Self.Button[I].Text[0].Text));

  UIni.Ini.SaveSongdirs();
  Self.LoadFolders(false);
  Self.Button[Self.SaveFoldersButton].Visible := true;
  Self.Button[Self.RedSaveButton].Visible := false;
  UGraphic.ScreenMain.ReloadSongs(false);
end;

procedure TScreenOptionsSongdirs.ExitSongdirs;
var
  I: integer;
begin
  //Delete folder buttons
  for I := Self.DefaultSongdir to Length(Self.Button) - 1 do
  begin
    Self.DelButton(I);
    SetLength(Self.Statics,Length(Self.Statics) - 1);
  end;

  Self.FadeTo(@UGraphic.ScreenOptions, UMusic.SoundLib.Back);
end;

procedure TScreenOptionsSongdirs.LoadFolders(CreateButtons: boolean);
var
  I: integer;
  CurrentPath: IPath;
begin
  // Folder list
  Self.SongPathList := UPathUtils.SongPaths;
WriteLn(Self.SongPathList.Count);
  for I := 0 to Self.SongPathList.Count-1 do
  begin
    If (I > MAX_DIR) then   // Max. Folder
      Exit;
    CurrentPath := Self.SongPathList[I] as IPath;
WriteLn(CurrentPath.ToUTF8());
    if CreateButtons then
    begin
      Self.AddButton(90, 110+((High(Self.Button) - Self.FolderName)*35),600,30,USkins.Skin.GetTextureFileName('Button'));
      Self.AddButtonText(10,5,255,255,255,0,20,0,CurrentPath.GetPath().ToUTF8());
      Self.AddStatic(60, 112+((High(Self.Button) - Self.DefaultSongdir)*35),25,25,USkins.Skin.GetTextureFileName('Optionsbuttonsongdirs'));
    end
    else  // Text refresh
      self.Button[Self.DefaultSongdir + I].Text[0].Text := CurrentPath.GetPath().ToUTF8();
  end;
WriteLn('def: '+Self.DefaultSongdir.ToString());
WriteLn('numb: '+Length(Self.Button).ToString());
  //Delete extra buttons
  if (Self.SongPathList.Count < (Length(Self.Button) - Self.DefaultSongdir)) then
    for I := (Self.SongPathList.Count + Self.DefaultSongdir + 1) to Length(Self.Button) do
    begin
      Self.DelButton(I);
      SetLength(Self.Statics,Length(Self.Statics) - 1);
    end;
  //Block entry button when max folder
  if (Length(Self.Button) - Self.DefaultSongdir = MAX_DIR) then
    Self.bMaxDir := true
  else
    Self.bMaxDir := false;
end;
end.
