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


unit UScreenSongMenu;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMenu,
  sdl2,
  UDisplay,
  UIni,
  UMusic,
  UFiles,
  SysUtils,
  UThemes;

type
  TScreenSongMenu = class(TMenu)
    private
      CurMenu: byte; // num of the cur. shown menu
    public
      Visible: boolean; // whether the menu should be drawn

      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure MenuShow(sMenu: byte);
      procedure HandleReturn;
      function CountMedleySongs: integer;
  end;

const
  SM_Main = 1;

  SM_PlayList         = 64 or 1;
  SM_Playlist_Add     = 64 or 2;
  SM_Playlist_New     = 64 or 3;

  SM_Playlist_DelItem = 64 or 5;

  SM_Playlist_Load    = 64 or 8 or 1;
  SM_Playlist_Del     = 64 or 8 or 5;

  SM_Party_Main       = 128 or 1;
  SM_Party_Joker      = 128 or 2;
  SM_Party_Free_Main  = 128 or 5;

  SM_Refresh_Scores   = 64 or 6;
  SM_Song             = 64 or 8;
  SM_Medley           = 64 or 16;
  SM_Sorting = 64 or 32;
  SM_Search_new_songs = 64 or 7;

var
  ISelections1: array of UTF8String;
  SelectValue1: integer;

  ISelections2: array of UTF8String;
  SelectValue2: integer;

  ISelections3: array of UTF8String;
  SelectValue3: integer;

implementation

uses
  Math,
  UCommon,
  UDatabase,
  UGraphic,
  UMain,
  UNote,
  UTexture,
  ULanguage,
  UParty,
  UPlaylist,
  USong,
  USongs,
  UUnicodeUtils;

function TScreenSongMenu.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // key down
    if (CurMenu = SM_Playlist_New) and (Interaction=1) then
    begin
      // check normal keys
      if IsAlphaNumericChar(CharCode) or
         (CharCode in [Ord(' '), Ord('-'), Ord('_'), Ord('!'),
                       Ord(','), Ord('<'), Ord('/'), Ord('*'),
                       Ord('?'), Ord(''''), Ord('"')]) then
      begin
        Button[Interaction].Text[0].Text := Button[Interaction].Text[0].Text +
                                            UCS4ToUTF8String(CharCode);
        exit;
      end;

      // check special keys
      case PressedKey of
        SDLK_BACKSPACE:
          begin
            Button[Interaction].Text[0].DeleteLastLetter;
            exit;
          end;
      end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE:
        begin
          AudioPlayback.PlaySound(SoundLib.Back);
          Visible := false;
        end;

      SDLK_RETURN:
        begin
          HandleReturn;
        end;

      SDLK_DOWN: InteractNext;
      SDLK_UP:   InteractPrev;

      SDLK_RIGHT:
        if (Interaction=3) or (Interaction=4) or (Interaction=5)
            or (Interaction=8) or (Interaction=9) or (Interaction=10) then
              InteractInc;
      SDLK_LEFT:
        if (Interaction=3) or (Interaction=4) or (Interaction=5)
          or (Interaction=8) or (Interaction=9) or (Interaction=10) then
            InteractDec;
      SDLK_F10:
        Self.Visible := false;
    end;
  end;
end;

constructor TScreenSongMenu.Create;
begin
  inherited Create;

  // create dummy selectslide entrys
  SetLength(ISelections1, 1);
  ISelections1[0] := 'Dummy';

  SetLength(ISelections2, 1);
  ISelections2[0] := 'Dummy';

  SetLength(ISelections3, 1);
  ISelections3[0] := 'Dummy';

  AddText(Theme.SongMenu.TextMenu);

  LoadFromTheme(Theme.SongMenu);

  AddButton(Theme.SongMenu.Button1);
  if (Length(Button[0].Text) = 0) then
    AddButtonText(14, 20, 'Button 1');

  AddButton(Theme.SongMenu.Button2);
  if (Length(Button[1].Text) = 0) then
    AddButtonText(14, 20, 'Button 2');

  AddButton(Theme.SongMenu.Button3);
  if (Length(Button[2].Text) = 0) then
    AddButtonText(14, 20, 'Button 3');

  AddSelectSlide(Theme.SongMenu.SelectSlide1, SelectValue1, ISelections1);
  AddSelectSlide(Theme.SongMenu.SelectSlide2, SelectValue2, ISelections2);
  AddSelectSlide(Theme.SongMenu.SelectSlide3, SelectValue3, ISelections3);

  AddButton(Theme.SongMenu.Button4);
  if (Length(Button[3].Text) = 0) then
    AddButtonText(14, 20, 'Button 4');

  AddButton(Theme.SongMenu.Button5);
  if (Length(Button[4].Text) = 0) then
    AddButtonText(14, 20, 'Button 5');

  AddButton(Theme.SongMenu.Button6);
  if (Length(Button[5].Text) = 0) then
    AddButtonText(14, 20, 'Button 6');

  Interaction := 0;
end;

function TScreenSongMenu.CountMedleySongs: integer;
var
  Count, I: integer;
begin

  Count := 0;

  for I:= 0 to High(CatSongs.Song) do
  begin

    if (CatSongs.Song[I].Visible) and (CatSongs.Song[I].Medley.Source <> msNone) then
      Count := Count + 1;

    if (Count = 5) then
      break;

  end;

  Result := Count;
end;

procedure TScreenSongMenu.MenuShow(sMenu: byte);
var
  I, MSongs: integer;
begin
  Interaction := 0; // reset interaction
  Visible := true;  // set visible
  case sMenu of
    SM_Main:
      begin
        CurMenu := sMenu;

        Text[0].Text := Language.Translate('SONG_MENU_NAME_MAIN');

        Button[0].Visible := true;
        Button[1].Visible := true;
        Button[2].Visible := true;
        Button[3].Visible := true;
        Button[4].Visible := true;
        Button[5].Visible := ((Length(PlaylistMedley.Song) > 0) or (CatSongs.Song[ScreenSong.Interaction].Medley.Source > msNone));

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        //Reset buttons from other sections
        Button[0].Selectable := true;
        Button[1].Selectable := true;
        Button[2].Selectable := true;
        Button[3].Selectable := true;
        Button[4].Selectable := true;
        Button[5].Selectable := true;

        Button[0].Text[0].Text := Language.Translate('C_SELECT_THIS_SONG');
        Button[1].Text[0].Text := Language.Translate('C_SORT_SONGS');
        Button[2].Text[0].Text := Language.Translate('C_REFRESH_SCORES');
        Button[3].Text[0].Text := Language.Translate('C_SEARCH_NEW_SONGS');
        Button[4].Text[0].Text := Language.Translate('C_OPEN_PLAYLIST');
        Button[5].Text[0].Text := Language.Translate('C_SING_MEDLEY');

      end;
    SM_Song:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_SONG');

        Button[0].Visible := true;
        Button[1].Visible := true;
        Button[2].Visible := true;
        Button[3].Visible := false;
        Button[4].Visible := true;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_PLAY');
        Button[1].Text[0].Text := Language.Translate('SONG_MENU_CHANGEPLAYERS');
        Button[2].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_ADD');
        Button[4].Text[0].Text := Language.Translate('C_BACK');
      end;

    SM_Medley:
      begin
        CurMenu := sMenu;
        MSongs := CountMedleySongs;

        Text[0].Text := Language.Translate('C_MEDLEY');

        Self.Button[0].Visible := (Length(UNote.PlaylistMedley.Song) > 0)
          or (USongs.CatSongs.Song[UGraphic.ScreenSong.Interaction].Medley.Source > msNone);
        Button[1].Visible := MSongs > 1;
        Button[2].Visible := true;
        Button[3].Visible := false;
        Button[4].Visible := false;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_START_MEDLEY');
        Button[1].Text[0].Text := Format(Language.Translate('SONG_MENU_START_5_MEDLEY'), [MSongs]);
        Button[2].Text[0].Text := Language.Translate('C_BACK');
      end;

    SM_Sorting:
      begin
        CurMenu := sMenu;
        Self.Text[0].Text := Language.Translate('C_SORT_SONGS');
        Self.Button[0].Visible := false;
        Self.Button[1].Visible := false;
        Self.Button[2].Visible := false;
        Self.Button[3].Visible := true;
        Self.Button[4].Visible := true;
        Self.Button[5].Visible := false;
        Self.SelectsS[0].Visible := true;
        Self.SelectsS[1].Visible := true;
        Self.SelectsS[2].Visible := true;

        SetLength(ISelections1, 2);

        ISelections1[0] := ULanguage.Language.Translate('SING_OPTIONS_GAME_TABS')+': '+ULanguage.Language.Translate('C_NO');
        ISelections1[1] := ULanguage.Language.Translate('SING_OPTIONS_GAME_TABS')+': '+ULanguage.Language.Translate('C_YES');

        SetLength(ISelections2, Length(UIni.ISorting));
        For I := 0 to High(UIni.ISorting) do
          ISelections2[I] := ULanguage.Language.Translate('SING_OPTIONS_GAME_SORTING')+': '+ULanguage.Language.Translate('OPTION_VALUE_'+UIni.ISorting[I]);

        SetLength(ISelections3, 2);
        ISelections3[0] := ULanguage.Language.Translate('SING_OPTIONS_GAME_DUETS')+': '+ULanguage.Language.Translate('C_YES');
        ISelections3[1] := ULanguage.Language.Translate('SING_OPTIONS_GAME_DUETS')+': '+ULanguage.Language.Translate('C_NO');

        SelectValue1 := UIni.Ini.Tabs;
        SelectValue2 := UIni.Ini.Sorting;
        SelectValue3 := IfThen(UIni.Ini.ShowDuets = 1, 0, 1);
        Self.UpdateSelectSlideOptions(UThemes.Theme.SongMenu.SelectSlide1, 0, ISelections1, SelectValue1);
        Self.UpdateSelectSlideOptions(UThemes.Theme.SongMenu.SelectSlide2, 1, ISelections2, SelectValue2);
        Self.UpdateSelectSlideOptions(UThemes.Theme.SongMenu.SelectSlide3, 2, ISelections3, SelectValue3);

        Self.Button[3].Text[0].Text := ULanguage.Language.Translate('C_APPLY_CHANGES');
        Self.Button[4].Text[0].Text := ULanguage.Language.Translate('C_BACK');

        Self.Interaction := 3;
      end;

    SM_PlayList:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PLAYLIST');

        Button[0].Visible := true;
        Button[1].Visible := true;
        Button[2].Visible := true;
        Button[3].Visible := false;
        Button[4].Visible := false;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_PLAY');
        Button[1].Text[0].Text := Language.Translate('SONG_MENU_CHANGEPLAYERS');
        Button[2].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_DEL');
      end;

    SM_Playlist_Add:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PLAYLIST_ADD');

        Button[0].Visible := true;
        Button[1].Visible := false;
        Button[2].Visible := false;
        Button[3].Visible := true;
        Button[4].Visible := true;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := true;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_ADD_NEW');
        Button[3].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_ADD_EXISTING');
        Button[4].Text[0].Text := Language.Translate('C_BACK');

        I := Length(PlaylistMan.Playlists);
        SetLength(ISelections3, I);
        PlaylistMan.GetNames(ISelections3);
        if I >= 1 then
        begin
          if SelectValue3 >= I then
            SelectValue3 := I - 1;

          UpdateSelectSlideOptions(Theme.SongMenu.SelectSlide3, 2, ISelections3, SelectValue3);
        end
        else
        begin
          Button[3].Visible := false;
          SelectsS[0].Visible := false;
          SelectsS[1].Visible := false;
          SelectsS[2].Visible := false;
          Button[2].Visible := true;
          Button[2].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_NOEXISTING');
        end;
      end;

    SM_Playlist_New:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PLAYLIST_NEW');

        Button[0].Visible := false;
        Button[1].Visible := true;
        Button[2].Visible := false;
        Button[3].Visible := true;
        Button[4].Visible := true;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[1].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_NEW_UNNAMED');
        Button[3].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_NEW_CREATE');
        Button[4].Text[0].Text := Language.Translate('C_BACK');

        Interaction := 1;
      end;

    SM_Playlist_DelItem:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PLAYLIST_DELITEM');

        Button[0].Visible := true;
        Button[1].Visible := false;
        Button[2].Visible := false;
        Button[3].Visible := true;
        Button[4].Visible := false;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_YES');
        Button[3].Text[0].Text := Language.Translate('C_BACK');
      end;

    SM_Playlist_Load:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('C_PLAYLIST');

        // show delete curent playlist button when playlist is opened
        Button[0].Visible := (CatSongs.CatNumShow = -3);

        Button[1].Visible := false;
        Button[2].Visible := false;
        Button[3].Visible := true;
        Button[4].Visible := true;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := true;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_DELCURRENT');
        Button[3].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_LOAD');
        Button[4].Text[0].Text := Language.Translate('C_BACK');

        I := Length(PlaylistMan.Playlists);
        SetLength(ISelections3, I);
        PlaylistMan.GetNames(ISelections3);
        if I >= 1 then
        begin
          if SelectValue3 >= I then
            SelectValue3 := I - 1;

          UpdateSelectSlideOptions(Theme.SongMenu.SelectSlide3, 2, ISelections3, SelectValue3);
          Interaction := 3;
        end
        else
        begin
          SelectsS[0].Visible := false;
          SelectsS[1].Visible := false;

          SelectsS[2].Visible := false;
          Button[2].Visible := true;
          Button[2].Text[0].Text := Language.Translate('SONG_MENU_PLAYLIST_NOEXISTING');
          Button[2].Selectable := false;

          Button[3].Visible := false;

          Interaction := 7;
        end;
      end;

    SM_Playlist_Del:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PLAYLIST_DEL');

        Button[0].Visible := true;
        Button[1].Visible := false;
        Button[2].Visible := false;
        Button[3].Visible := true;
        Button[4].Visible := false;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_YES');
        Button[3].Text[0].Text := Language.Translate('C_BACK');
      end;

    SM_Party_Main:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PARTY_MAIN');

        Button[0].Visible := true;
        Button[1].Visible := false;
        Button[2].Visible := false;
        Button[3].Visible := true;
        Button[4].Visible := false;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_PLAY');
        //Button[1].Text[0].Text := Language.Translate('SONG_MENU_JOKER');
        //Button[2].Text[0].Text := Language.Translate('SONG_MENU_PLAYMODI');
        Button[3].Text[0].Text := Language.Translate('SONG_MENU_JOKER');
      end;

    SM_Party_Joker:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PARTY_JOKER');
        // to-do : Party
        Button[0].Visible := (Length(Party.Teams) >= 1) AND (Party.Teams[0].JokersLeft > 0);
        Button[1].Visible := (Length(Party.Teams) >= 2) AND (Party.Teams[1].JokersLeft > 0);
        Button[2].Visible := (Length(Party.Teams) >= 3) AND (Party.Teams[2].JokersLeft > 0);
        Button[3].Visible := True;
        Button[4].Visible := false;
        Button[5].Visible := false;

        SelectsS[0].Visible := False;
        SelectsS[1].Visible := False;
        SelectsS[2].Visible := False;

        if (Button[0].Visible) then
          Button[0].Text[0].Text := UTF8String(Party.Teams[0].Name);
        if (Button[1].Visible) then
          Button[1].Text[0].Text := UTF8String(Party.Teams[1].Name);
        if (Button[2].Visible) then
          Button[2].Text[0].Text := UTF8String(Party.Teams[2].Name);
        Button[3].Text[0].Text := Language.Translate('C_BACK');

        // set right interaction
        if (not Button[0].Visible) then
        begin
          if (not Button[1].Visible) then
          begin
            if (not Button[2].Visible) then
              Interaction := 4
            else
              Interaction := 2;
          end
          else
            Interaction := 1;
        end;

      end;

    SM_Refresh_Scores:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('C_REFRESH_SCORES');

        Button[0].Visible := false;
        Button[1].Visible := false;
        Button[2].Visible := false;
        Button[3].Visible := true;
        Button[4].Visible := true;
        Button[5].Visible := false;

        SelectsS[0].Visible := true;
        SelectsS[1].Visible := true;
        SelectsS[2].Visible := true;

        Button[3].Text[0].Text := Language.Translate('SONG_MENU_REFRESH_SCORES_REFRESH');
        Button[4].Text[0].Text := Language.Translate('C_BACK');

        if (High(DataBase.NetworkUser) > 0) then
          SetLength(ISelections3, Length(DataBase.NetworkUser) + 1)
        else
          SetLength(ISelections3, Length(DataBase.NetworkUser));

        if (Length(ISelections3) >= 1) then
        begin
          if (High(DataBase.NetworkUser) > 0) then
          begin
            ISelections3[0] := Language.Translate('SONG_MENU_REFRESH_SCORES_ALL_WEB');
            for I := 0 to High(DataBase.NetworkUser) do
              ISelections3[I + 1] := DataBase.NetworkUser[I].Website;
          end
          else
          begin
            for I := 0 to High(DataBase.NetworkUser) do
              ISelections3[I] := DataBase.NetworkUser[I].Website;
          end;

          UpdateSelectSlideOptions(Theme.SongMenu.SelectSlide1, 0, [Language.Translate('SONG_MENU_REFRESH_SCORES_ONLINE'), Language.Translate('SONG_MENU_REFRESH_SCORES_FILE')], SelectValue1);
          UpdateSelectSlideOptions(Theme.SongMenu.SelectSlide2, 1, [Language.Translate('SONG_MENU_REFRESH_SCORES_ONLY_SONG'), Language.Translate('SONG_MENU_REFRESH_SCORES_ALL_SONGS')], SelectValue2);
          UpdateSelectSlideOptions(Theme.SongMenu.SelectSlide3, 2, ISelections3, SelectValue3);

          Interaction := 3;
        end
        else
        begin
          Button[3].Visible := false;
          SelectsS[0].Visible := false;
          SelectsS[1].Visible := false;
          SelectsS[2].Visible := false;
          Button[2].Visible := true;
          Button[2].Text[0].Text := Language.Translate('C_NO_INTERNET_CONNECTION');
          Button[2].Selectable := false;
          Button[3].Text[0].Text := ULanguage.Language.Translate('SING_OPTIONS_NETWORK_DESC');
          Interaction := 7;
        end;
      end;

    SM_Party_Free_Main:
      begin
        CurMenu := sMenu;
        Text[0].Text := Language.Translate('SONG_MENU_NAME_PARTY_MAIN');

        Button[0].Visible := true;
        Button[1].Visible := false;
        Button[2].Visible := false;
        Button[3].Visible := false;
        Button[4].Visible := false;
        Button[5].Visible := false;

        SelectsS[0].Visible := false;
        SelectsS[1].Visible := false;
        SelectsS[2].Visible := false;

        Button[0].Text[0].Text := Language.Translate('SONG_MENU_PLAY');
      end;
	  SM_Search_new_songs:
	    begin
        Self.FadeTo(@UGraphic.ScreenMain);
        UGraphic.ScreenMain.ReloadSongs();
      end;
  end;
end;

procedure TScreenSongMenu.HandleReturn;
begin
  case CurMenu of
    SM_Main:
      begin
        case Interaction of
          0: // button 1
              MenuShow(SM_Song);
          1: // button 2
              Self.MenuShow(SM_Sorting);
          2: // button 3
              // show refresh scores menu
              MenuShow(SM_Refresh_Scores);
          6: // button 4
              MenuShow(SM_Search_new_songs);
          7: // button 5
              MenuShow(SM_Playlist_Load);
          8: // button 6
              MenuShow(SM_Medley);
        end;
      end;

      SM_Song:
      begin
        case Interaction of
          0: // button 1
            begin

              //if (CatSongs.Song[ScreenSong.Interaction].isDuet and ((PlayersPlay=1) or
              //   (PlayersPlay=3) or (PlayersPlay=6))) then
              //  ScreenPopupError.ShowPopup(Language.Translate('SING_ERROR_DUET_NUM_PLAYERS'))
              //else
              //begin
                ScreenSong.StartSong;
                Visible := false;
              //end;
            end;

          1: // button 2
            begin
              // select new players then sing:
              ScreenSong.SelectPlayers;
              Visible := false;
            end;

          2: // button 3
            begin
              // show add to playlist menu
              MenuShow(SM_Playlist_Add);
            end;

          7: // button 5
            begin
              // show main menu (cancel)
              MenuShow(SM_Main);
            end;
          end;
      end;

    SM_Medley:
      case Self.Interaction of
        0:
          begin
            UGraphic.ScreenSong.StartMedley(0, msCalculated);
            Self.Visible := False;
          end;
        1:
          begin
            UGraphic.ScreenSong.StartMedley(5, msCalculated);
            Self.Visible := False;
          end;
        2:
          Self.MenuShow(SM_Main);
      end;
      SM_Sorting:
        begin
          case Self.Interaction of
            6:
              begin
                UIni.Ini.Sorting := SelectValue2;
                UIni.Ini.Tabs := SelectValue1;
                UIni.Ini.ShowDuets := IfThen(SelectValue3 = 1, 0, 1);
                UIni.Ini.Save();
                UGraphic.ScreenSong.OnShow();
                Visible := false;
              end;
            7:
              if USongs.CatSongs.Song[UGraphic.ScreenSong.Interaction].Main then
                Visible := false
              else
                Self.MenuShow(SM_Main);
          end;
        end;

    SM_PlayList:
      begin
        Visible := false;
        case Interaction of
          0: // button 1
            begin
              ScreenSong.StartSong;
              Visible := false;
            end;

          1: // button 2
            begin
              // select new players then sing:
              ScreenSong.SelectPlayers;
              Visible := false;
            end;

          2: // button 3
            begin
              // show add to playlist menu
              MenuShow(SM_Playlist_DelItem);
            end;

          3: // selectslide 1
            begin
              // dummy
            end;

          4: // selectslide 2
            begin
              // dummy
            end;

          5: // selectslide 3
            begin
              // dummy
            end;

        end;
      end;

    SM_Playlist_Add:
      begin
        case Interaction of
          0: // button 1
            begin
              MenuShow(SM_Playlist_New);
            end;

          4: // selectslide 3
            begin
              // dummy
            end;

          6: // button 4
            begin
              PlaylistMan.AddItem(ScreenSong.Interaction, SelectValue3);
              Visible := false;
            end;

          7: // button 5
            begin
              // show song menu
              MenuShow(SM_Song);
            end;

        end;
      end;

      SM_Playlist_New:
      begin
        case Interaction of
          1: // button 1
            begin
              // nothing, button for entering name
            end;

          6: // button 4
            begin
              // create playlist and add song
              PlaylistMan.AddItem(
              ScreenSong.Interaction,
              PlaylistMan.AddPlaylist(Button[1].Text[0].Text));
              Visible := false;
            end;

          7: // button 5
            begin
              // show add song menu
              MenuShow(SM_Playlist_Add);
            end;

        end;
      end;

    SM_Playlist_DelItem:
      begin
        Visible := false;
        case Interaction of
          0: // button 1
            begin
              // delete
              PlayListMan.DelItem(PlayListMan.GetIndexbySongID(ScreenSong.Interaction));
              Visible := false;
            end;

          6: // button 4
            begin
              MenuShow(SM_Playlist);
            end;
        end;
      end;

    SM_Playlist_Load:
      begin
        case Interaction of
          0: // button 1 (Delete playlist)
            begin
              MenuShow(SM_Playlist_Del);
            end;
          6: // button 4
            begin
              // load playlist
              UGraphic.ScreenSong.SetSubselection(SelectValue3, sfPlaylist);
              Visible := false;
            end;
          7: // button 5
			              begin
                Button[4].Selectable := true;
                MenuShow(SM_Main);
              end;
        end;
      end;

    SM_Playlist_Del:
      begin
        Visible := false;
        case Interaction of
          0: // button 1
            begin
              // delete
              PlayListMan.DelPlaylist(PlaylistMan.CurPlayList);
              Visible := false;
            end;

          6: // button 4
            begin
              MenuShow(SM_Playlist_Load);
            end;
        end;
      end;

    SM_Party_Main:
      begin
        case Interaction of
          0: // button 1
            begin
              // start singing
              Party.CallAfterSongSelect;
              Visible := false;
            end;

          6: // button 4
            begin
              // joker
              MenuShow(SM_Party_Joker);
            end;
        end;
      end;

    SM_Party_Free_Main:
    begin
      case Interaction of
        0: // button 1
          begin
            // start singing
            Party.CallAfterSongSelect;
            Visible := false;
          end;
      end;
    end;

    SM_Party_Joker:
      begin
        Visible := false;
        case Interaction of
          0..2:
            UGraphic.ScreenSong.ParseInput(SDLK_1 + Self.Interaction, 0, true);
          6: // button 4
            begin
              // cancel... (go back to old menu)
              MenuShow(SM_Party_Main);
            end;
        end;
      end;

    SM_Refresh_Scores:
      begin
        case Interaction of
          6: // button 5
            begin
              if (Length(ISelections3)>=1) then
              begin
                // Refresh Scores
                Visible := false;
                ScreenPopupScoreDownload.ShowPopup(SelectValue1, SelectValue2, SelectValue3);
              end
              else
              begin
                Button[2].Selectable := true;
                MenuShow(SM_Main);
              end;
            end;
          7:
            Self.MenuShow(SM_Main);
        end;
      end;
  end;
end;

end.
