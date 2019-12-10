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


unit UScreenMain;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  MD5,
  sdl2,
  SysUtils,
  UDisplay,
  UFiles,
  UMenu,
  UMusic,
  ULog,
  USong,
  UTexture,
  UThemes;

type
  TScreenMain = class(TMenu)
    public
      constructor Create(); override;
      function ParseInput(PressedKey: Cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      function Draw: boolean; override;
      procedure OnShow; override;
      procedure ReloadSongs(ScreenReturn: boolean = true);
      procedure SetInteraction(Num: integer); override;
      procedure SetAnimationProgress(Progress: real); override;
    private
      ReturnToSongScreenAfterLoadSongs: boolean;
      TextDescription, TextDescriptionLong, TextProgressSongs: integer;
      function CheckSongs(): boolean;
  end;

implementation

uses
  dglOpenGL,
  UGraphic,
  UNote,
  UIni,
  USongs,
  ULanguage,
  UParty,
  UScreenPlayerSelection,
  UScreenSong,
  UScreenPartyOptions,
  UScreenJukeboxPlaylist,
  UScreenOptions,
  UScreenStatMain,
  UScreenAbout,
  UUnicodeUtils;

const
  ITEMS_PER_ROW = 3;   // Number of buttons for row of buttons in Main menu.

function TScreenMain.ParseInput(PressedKey: Cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin
    //check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    //check special keys
    case PressedKey of
      SDLK_ESCAPE, SDLK_BACKSPACE:
        Result := false;
      SDLK_RETURN:
        begin
          if (Interaction < 3) and (not Assigned(UGraphic.ScreenSong)) then //loaded in draw, but a fast interaction can finish here in crash
            UGraphic.ScreenSong := TScreenSong.Create();

          //reset
          Party.bPartyGame := false;
          case Interaction of
            0: //solo
            begin
              if Self.CheckSongs() then
              begin
                UGraphic.ScreenSong.Mode := smNormal;
                if (Ini.Players >= 0) and (Ini.Players <= 3) then
                  UNote.PlayersPlay := Ini.Players + 1;
                if (Ini.Players = 4) then
                  UNote.PlayersPlay := 6;

                if Ini.OnSongClick = sSelectPlayer then
                  FadeTo(@ScreenSong)
                else
                begin
                  if not Assigned(UGraphic.ScreenPlayerSelector) then
                    UGraphic.ScreenPlayerSelector := TScreenPlayerSelector.Create();

                  UGraphic.ScreenPlayerSelector.Goto_SingScreen := false;
                  FadeTo(@UGraphic.ScreenPlayerSelector, SoundLib.Start);
                end;
              end;
            end;
            1: //party
            begin
              if Self.CheckSongs() then
              begin
                if not Assigned(UGraphic.ScreenPartyOptions) then //load the screens only the first time
                  UGraphic.ScreenPartyOptions := TScreenPartyOptions.Create();

                Party.bPartyGame := true;
                FadeTo(@ScreenPartyOptions, SoundLib.Start);
              end
            end;
            2: //jukebox
            begin
              if not Assigned(UGraphic.ScreenJukeboxPlaylist) then //load the screens only the first time
                UGraphic.ScreenJukeboxPlaylist := TScreenJukeboxPlaylist.Create();

              if Self.CheckSongs() then
                FadeTo(@ScreenJukeboxPlaylist, SoundLib.Start);
            end;
            3: //stats
            begin
              if not Assigned(UGraphic.ScreenStatMain) then //load the screens only the first time
                UGraphic.ScreenStatMain := TScreenStatMain.Create();

              if Self.CheckSongs() then
                FadeTo(@ScreenStatMain, SoundLib.Start);
            end;
            4: //options
            begin
              if not Assigned(UGraphic.ScreenOptions) then //load the screens only the first time
                UGraphic.ScreenOptions := TScreenOptions.Create();

              FadeTo(@UGraphic.ScreenOptions, SoundLib.Start);
            end;
            5: //exit
              Result := false;
            6: //about
            begin
              if not Assigned(UGraphic.ScreenAbout) then //load the screens only the first time
                UGraphic.ScreenAbout := TScreenAbout.Create();

              FadeTo(@ScreenAbout, SoundLib.Start);
            end;
          end;
        end;
      SDLK_DOWN:
        InteractMainNextRow(ITEMS_PER_ROW);
      SDLK_UP:
        InteractMainPrevRow(ITEMS_PER_ROW);
      SDLK_RIGHT:
        InteractNext;
      SDLK_LEFT:
        InteractPrev;
      SDLK_F5:
        Self.ReloadSongs();
    end;
  end
end;

constructor TScreenMain.Create();
begin
  inherited Create();
{**
 * Attention ^^:
 * New Creation Order needed because of LoadFromTheme
 * and Button Collections.
 * At First Custom Texts and Statics
 * Then LoadFromTheme
 * after LoadFromTheme the Buttons and Selects
 *}
  TextDescription := AddText(Theme.Main.TextDescription);
  TextDescriptionLong := AddText(Theme.Main.TextDescriptionLong);
  TextProgressSongs := AddText(Theme.Main.ProgressSongsText);

  LoadFromTheme(Theme.Main);

  AddButton(Theme.Main.ButtonSolo);
  AddButton(Theme.Main.ButtonMulti);
  AddButton(Theme.Main.ButtonJukebox);

  AddButton(Theme.Main.ButtonStat);
  AddButton(Theme.Main.ButtonOptions);
  AddButton(Theme.Main.ButtonExit);

  AddButton(Theme.Main.ButtonAbout);
  Interaction := 0;
  Self.ReturnToSongScreenAfterLoadSongs := false;
end;

function TScreenMain.Draw: boolean;
var
  ProgressSong: TProgressSong;
begin
  inherited Draw;
  Result := true;
  ProgressSong := USongs.Songs.GetLoadProgress();
  if not ProgressSong.Finished then //while song loading show progress
    Self.Text[Self.TextProgressSongs].Text := ProgressSong.Folder+': '+IntToStr(ProgressSong.Total)+'\n\n'+ProgressSong.FolderProcessed
  else if not Self.Text[Self.TextDescriptionLong].Visible then //after finish song loading, return to normal mode and close popup
  begin
    FreeAndNil(UGraphic.ScreenSong);
    UGraphic.ScreenSong := TScreenSong.Create();
    if Self.ReturnToSongScreenAfterLoadSongs then
    begin
      Self.ReturnToSongScreenAfterLoadSongs := false;
      if Self.CheckSongs() then
      begin
        UDisplay.Display.AbortScreenChange();
        Self.FadeTo(@UGraphic.ScreenSong);
      end;
    end;
    Self.Text[Self.TextDescriptionLong].Visible := true;
    Self.Text[Self.TextProgressSongs].Visible := false;
    if ProgressSong.Total > 0 then
      UGraphic.ScreenPopupError.Visible := false;
  end;
end;

procedure TScreenMain.OnShow;
begin
  inherited;
  Self.Text[Self.TextProgressSongs].Visible := true;
  Self.Text[Self.TextDescriptionLong].Visible := false;
  SoundLib.StartBgMusic;

 {**
  * Clean up TPartyGame here
  * at the moment there is no better place for this
  *}
  Party.Clear;

end;

procedure TScreenMain.SetInteraction(Num: integer);
begin
  inherited SetInteraction(Num);
  Text[TextDescription].Text     := Theme.Main.Description[Interaction];
  Text[TextDescriptionLong].Text := Theme.Main.DescriptionLong[Interaction];
end;

procedure TScreenMain.SetAnimationProgress(Progress: real);
begin
  Statics[0].Texture.ScaleW := Progress;
  Statics[0].Texture.ScaleH := Progress;
end;

function TScreenMain.CheckSongs(): boolean;
begin
  Result := false;
  if USongs.Songs.GetLoadProgress().Folder <> '' then
    UGraphic.ScreenPopupError.ShowPopup(Language.Translate('ERROR_LOADING_SONGS'))
  else if Songs.SongList.Count = 0 then
    UGraphic.ScreenPopupError.ShowPopup(Language.Translate('ERROR_NO_SONGS'))
  else
    Result := true;
end;

procedure TScreenMain.ReloadSongs(ScreenReturn: boolean = true);
begin
  UIni.Ini.Load();
  FreeAndNil(USongs.CatSongs);
  FreeAndNil(USongs.Songs);
  USongs.CatSongs := TCatSongs.Create();
  USongs.Songs := TSongs.Create();
  Self.ReturnToSongScreenAfterLoadSongs := ScreenReturn;
end;

end.
