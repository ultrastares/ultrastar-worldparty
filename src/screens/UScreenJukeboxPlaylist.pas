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


unit UScreenJukeboxPlaylist;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  UMenu;

type
  TScreenJukeboxPlaylist = class(TMenu)
    protected
      PlayList: integer;
      PlayListItems: integer;
      PlayListItemsStrings: array of UTF8String;
      SelectPlayList: integer;
      SelectPlayListItems: integer;
      procedure SetPlaylistsItems(); //sets playlist and playlist items slider
    public
      constructor Create(); override;
      constructor CreateExtra(); virtual;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow(); override;
  end;

implementation

uses
  sdl2,
  SysUtils,
  UGraphic,
  UIni,
  ULanguage,
  ULog,
  UMusic,
  UPlaylist,
  USong,
  USongs,
  UScreenJukebox,
  UThemes,
  UUnicodeUtils;

function TScreenJukeboxPlaylist.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var
  I: integer;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        Self.FadeTo(@ScreenMain, UMusic.SoundLib.Back);
      SDLK_RETURN:
        begin
          SetLength(UGraphic.ScreenJukebox.JukeboxSongsList, 0);
          SetLength(UGraphic.ScreenJukebox.JukeboxVisibleSongs, 0);
          UGraphic.ScreenJukebox.ActualInteraction := 0;
          UGraphic.ScreenJukebox.CurrentSongList := 0;
          UGraphic.ScreenJukebox.ListMin := 0;
          UGraphic.ScreenJukebox.Interaction := 0;
          case Self.Playlist of
            0: ;
            1:
              begin
                if Length(UPlaylist.PlaylistMan.Playlists) = 0 then
                  Exit();

                USongs.CatSongs.ShowPlaylist(Self.PlayListItems);
                UPlaylist.PlaylistMan.SetPlayList(Self.PlayListItems);
              end;
            11:
              begin
                Self.FadeTo(@UGraphic.ScreenSong, UMusic.SoundLib.Start);
                Exit();
              end;
            else
              USongs.CatSongs.ShowCategory(Self.PlayListItems + 1);
          end;
          try
            for I := 0 to High(USongs.CatSongs.Song) do
              if USongs.CatSongs.Song[I].Visible then
                UGraphic.ScreenJukebox.AddSongToJukeboxList(I);

            UGraphic.ScreenJukebox.CurrentSongID := UGraphic.ScreenJukebox.JukeboxVisibleSongs[0];
            FadeTo(@UGraphic.ScreenJukebox, UMusic.SoundLib.Start);
          except
            Log.LogWarn('Starting jukebox failed. Most likely no folder / empty folder / paylist with not available songs was selected.', 'UScreenJokeboxPlaylist.ParseInput');
          end;
        end;
      SDLK_DOWN:
        Self.InteractNext();
      SDLK_UP:
        Self.InteractPrev();
      SDLK_RIGHT:
        begin
          UMusic.AudioPlayback.PlaySound(UMusic.SoundLib.Option);
          Self.InteractInc();
          Self.SetPlaylistsItems();
        end;
      SDLK_LEFT:
        begin
          UMusic.AudioPlayback.PlaySound(UMusic.SoundLib.Option);
          Self.InteractDec();
          Self.SetPlaylistsItems();
        end;
    end;
  end;
end;

constructor TScreenJukeboxPlaylist.Create();
begin
  inherited;
  Self.CreateExtra();
end;

constructor TScreenJukeboxPlaylist.CreateExtra();
begin
  Self.LoadFromTheme(UThemes.Theme.JukeboxPlaylist);
  Self.SelectPlayList := Self.AddSelectSlide(UThemes.Theme.JukeboxPlaylist.SelectPlayList, Self.PlayList, [
    ULanguage.Language.Translate('PARTY_PLAYLIST_ALL'),
    ULanguage.Language.Translate('PARTY_PLAYLIST_PLAYLIST'),
    ULanguage.Language.Translate('OPTION_VALUE_EDITION'),
    ULanguage.Language.Translate('OPTION_VALUE_GENRE'),
    ULanguage.Language.Translate('OPTION_VALUE_LANGUAGE'),
    ULanguage.Language.Translate('OPTION_VALUE_FOLDER'),
    ULanguage.Language.Translate('OPTION_VALUE_TITLE'),
    ULanguage.Language.Translate('OPTION_VALUE_ARTIST'),
    ULanguage.Language.Translate('OPTION_VALUE_ARTIST2'),
    ULanguage.Language.Translate('OPTION_VALUE_YEAR'),
    ULanguage.Language.Translate('OPTION_VALUE_DECADE'),
    ULanguage.Language.Translate('PARTY_PLAYLIST_MANUAL')
  ]);
  Self.SelectPlayListItems := Self.AddSelectSlide(UThemes.Theme.JukeboxPlaylist.SelectPlayListItems, Self.PlayListItems, Self.PlayListItemsStrings);
end;

procedure TScreenJukeboxPlaylist.OnShow();
begin
  inherited;
  Self.Interaction := 0;
  if not Assigned(UGraphic.ScreenJukebox) then //load the screen only the first time
    UGraphic.ScreenJukebox := TScreenJukebox.Create();

  Self.SetPlaylistsItems();
end;

procedure TScreenJukeboxPlaylist.SetPlaylistsItems();
var
  I, J: integer;
begin
  Self.SelectsS[Self.SelectPlayList].Visible := true;
  Self.SelectsS[Self.SelectPlayListItems].Visible := true;
  case Self.Playlist of
    0, 11: //all or manual selection
      begin
        UGraphic.ScreenSong.Refresh(UIni.Ini.Sorting, false, false);
        Self.SelectsS[Self.SelectPlayListItems].Visible := false;
      end;
    1: //playlist
      begin
        UGraphic.ScreenSong.Refresh(UIni.Ini.Sorting, false, false);
        if Length(UPlaylist.PlaylistMan.Playlists) > 0 then
        begin
          SetLength(Self.PlayListItemsStrings, Length(UPlaylist.PlaylistMan.Playlists));
          UPlaylist.PlaylistMan.GetNames(Self.PlayListItemsStrings);
        end
        else
        begin
          SetLength(Self.PlayListItemsStrings, 1);
          Self.PlayListItemsStrings[0] := ULanguage.Language.Translate('SONG_MENU_PLAYLIST_NOEXISTING');
        end;
      end;
    else //categories
      UGraphic.ScreenSong.Refresh(Self.Playlist - 2, true, false);
      SetLength(Self.PlayListItemsStrings, 0);
      for I := 0 to High(USongs.CatSongs.Song) do
        if USongs.CatSongs.Song[I].Main then
        begin
          J := Length(Self.PlayListItemsStrings);
          SetLength(Self.PlayListItemsStrings, J + 1);
          Self.PlayListItemsStrings[J] := USongs.CatSongs.Song[I].Artist+' ('+IntToStr(USongs.CatSongs.Song[I].CatNumber)+')';
        end;
  end;
  Self.UpdateSelectSlideOptions(UThemes.Theme.JukeboxPlaylist.SelectPlayListItems, Self.SelectPlayListItems, Self.PlayListItemsStrings, Self.PlayListItems);
end;

end.
