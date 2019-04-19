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


unit UScreenJukeboxPlaylist;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMenu,
  sdl2,
  UDisplay,
  UMusic,
  UNote,
  ULog,
  UFiles,
  SysUtils,
  UThemes;

type
  TScreenJukeboxPlaylist = class(TMenu)
    private
      SelectPlayList:  cardinal;
      SelectPlayListItems: cardinal;

      IPlaylist:  array of UTF8String;
      IPlayListItems: array of UTF8String;

      PlayList:  integer;
      PlayListItems: integer;

      procedure SetPlaylists;
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure SetAnimationProgress(Progress: real); override;

      procedure InitJukebox;
  end;

implementation

uses
  UGraphic,
  UIni,
  ULanguage,
  UMain,
  UParty,
  UPlaylist,
  USong,
  USongs,
  UScreenJukebox,
  UTexture,
  UUnicodeUtils;

function TScreenJukeboxPlaylist.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenMain);
        end;

      SDLK_RETURN:
        begin
          //Don'T start when Playlist is Selected and there are no Playlists
          if (Playlist = 3) and (Length(PlaylistMan.Playlists) = 0) then
            Exit;

          try
            InitJukebox;
          except
            Log.LogWarn('Starting jukebox failed. Most likely no folder / empty folder / paylist with not available songs was selected.', 'UScreenJokeboxPlaylist.ParseInput');
          end;
        end;
      // Up and Down could be done at the same time,
      // but I don't want to declare variables inside
      // functions like this one, called so many times
      SDLK_DOWN:    InteractNext;
      SDLK_UP:      InteractPrev;
      SDLK_RIGHT:
        begin
          AudioPlayback.PlaySound(SoundLib.Option);
          InteractInc;

          //Change PlayListItems if Playlist is Changed
          if (Interaction = SelectPlayList) then
          begin
            SetPlaylists;
          end;

        end;
      SDLK_LEFT:
        begin
          AudioPlayback.PlaySound(SoundLib.Option);
          InteractDec;

          //Change PlayListItems if Playlist is Changed
          if (Interaction = SelectPlayList) then
          begin
            SetPlaylists;
          end;

        end;
    end;
  end;
end;

constructor TScreenJukeboxPlaylist.Create;
begin
  inherited Create;

  //Clear all Selects
  PlayList := 0;
  PlayListItems := 0;

  // playlist modes
  SetLength(IPlayListItems, 1);
  IPlayListItems[0] := '---';

  SetLength(IPlaylist, 4);

  IPlaylist[0] := Language.Translate('PARTY_PLAYLIST_ALL');
  IPlaylist[1] := Language.Translate('PARTY_PLAYLIST_CATEGORY');
  IPlaylist[2] := Language.Translate('PARTY_PLAYLIST_PLAYLIST');
  IPlaylist[3] := Language.Translate('PARTY_PLAYLIST_MANUAL');

  //Load Screen From Theme
  LoadFromTheme(Theme.JukeboxPlaylist);

  Theme.JukeboxPlaylist.SelectPlayList.oneItemOnly := true;
  Theme.JukeboxPlaylist.SelectPlayList.showArrows := true;
  SelectPlayList  := AddSelectSlide(Theme.JukeboxPlaylist.SelectPlayList, PlayList, IPlaylist);

  Theme.JukeboxPlaylist.SelectPlayListItems.oneItemOnly := true;
  Theme.JukeboxPlaylist.SelectPlayListItems.showArrows := true;
  SelectPlayListItems := AddSelectSlide(Theme.JukeboxPlaylist.SelectPlayListItems, PlayListItems, IPlayListItems);

  Interaction := 0;
end;

procedure TScreenJukeboxPlaylist.SetPlaylists;
var
  I: integer;
begin
  case Playlist of
    0:
      begin
        SetLength(IPlayListItems, 1);
        IPlayListItems[0] := '---';
      end;
    1:
      begin
        SetLength(IPlayListItems, 0);
        for I := 0 to high(CatSongs.Song) do
        begin
          if (CatSongs.Song[I].Main) then
          begin
            SetLength(IPlayListItems, Length(IPlayListItems) + 1);
            IPlayListItems[high(IPlayListItems)] := CatSongs.Song[I].Artist;
          end;
        end;

        if (Length(IPlayListItems) = 0) then
        begin
          SetLength(IPlayListItems, 1);
          IPlayListItems[0] := 'No Categories found';
        end;
      end;
    2:
      begin
        if (Length(PlaylistMan.Playlists) > 0) then
        begin
          SetLength(IPlayListItems, Length(PlaylistMan.Playlists));
          PlaylistMan.GetNames(IPlayListItems);
        end
        else
        begin
          SetLength(IPlayListItems, 1);
          IPlayListItems[0] := 'No Playlists found';
        end;
      end;
    3:
      begin
        SetLength(IPlayListItems, 1);
        IPlayListItems[0] := '---';
      end;
  end;

  PlayListItems := 0;
  UpdateSelectSlideOptions(Theme.PartyOptions.SelectPlayListItems, SelectPlayListItems, IPlayListItems, PlayListItems);
end;

procedure TScreenJukeboxPlaylist.OnShow;
begin
  inherited;
  if not Assigned(UGraphic.ScreenJukebox) then //load the screen only the first time
    UGraphic.ScreenJukebox := TScreenJukebox.Create();
end;

procedure TScreenJukeboxPlaylist.InitJukebox;
var
  I, J: integer;
begin
  ScreenSong.Mode := smJukebox;
  AudioPlayback.PlaySound(SoundLib.Start);

  SetLength(ScreenJukebox.JukeboxSongsList, 0);
  SetLength(ScreenJukebox.JukeboxVisibleSongs, 0);

  ScreenJukebox.ActualInteraction := 0;
  ScreenJukebox.CurrentSongList := 0;
  ScreenJukebox.ListMin := 0;
  ScreenJukebox.Interaction := 0;

  if PlayList = 0 then
  begin
    for I := 0 to High(CatSongs.Song) do
    begin
      if not (CatSongs.Song[I].Main) then
        ScreenJukebox.AddSongToJukeboxList(I);
    end;

    ScreenJukebox.CurrentSongID := ScreenJukebox.JukeboxVisibleSongs[0];

    FadeTo(@ScreenJukebox);
  end;

  if Playlist = 1 then
  begin
    J := -1;
    for I := 0 to high(CatSongs.Song) do
    begin
      if CatSongs.Song[I].Main then
        Inc(J);

      if J = PlayListItems then
      begin
        ScreenJukebox.AddSongToJukeboxList(I);
      end;
    end;

    ScreenJukebox.CurrentSongID := ScreenJukebox.JukeboxVisibleSongs[0];

    FadeTo(@ScreenJukebox);
  end;

  if Playlist = 2 then
  begin
    if(High(PlaylistMan.PlayLists[PlayListItems].Items)>0) then
    begin
    for I := 0 to High(PlaylistMan.PlayLists[PlayListItems].Items) do
    begin
      ScreenJukebox.AddSongToJukeboxList(PlaylistMan.PlayLists[PlayListItems].Items[I].SongID);
    end;

    ScreenJukebox.CurrentSongID := ScreenJukebox.JukeboxVisibleSongs[0];

    FadeTo(@ScreenJukebox);
    end
    else
    begin
      Log.LogWarn('Can not play selected playlist in JukeBox because playlist is empty or no song found.', 'ScreenJukeboxPlaylist.InitJukeBox');
    end;
  end;

  if PlayList = 3 then
  begin
    FadeTo(@ScreenSong);
  end;

end;

procedure TScreenJukeboxPlaylist.SetAnimationProgress(Progress: real);
begin
  //for I := 0 to 6 do
  //  SelectS[I].Texture.ScaleW := Progress;
end;

end.
