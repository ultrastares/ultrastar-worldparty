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


unit UScreenPartyOptions;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMenu;

type
  TScreenPartyOptions = class(TMenu)
    private
      SelectMode: cardinal;
      SelectPlayList: cardinal;
      SelectPlayListItems: cardinal;
      PlayListItemsStrings: array of UTF8String;
      PlayList: integer;
      PlayListItems: integer;
      Mode: integer;
      procedure SetPlaylistsItems(); //sets playlist and playlist items slider
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure SetAnimationProgress(Progress: real); override;
  end;

implementation

uses
  sdl2,
  SysUtils,
  UDisplay,
  UGraphic,
  UIni,
  ULanguage,
  UMain,
  UMusic,
  UParty,
  UPlaylist,
  UScreenPartyNewRound,
  UScreenPartyScore,
  UScreenPartyWin,
  UScreenPartyPlayer,
  UScreenPartyRounds,
  UScreenPartyTournamentRounds,
  UScreenPartyTournamentPlayer,
  UScreenPartyTournamentOptions,
  UScreenPartyTournamentWin,
  USong,
  USongs,
  UThemes,
  UUnicodeUtils;

function TScreenPartyOptions.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
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
      SDLK_BACKSPACE:
        Self.FadeTo(@ScreenMain, UMusic.SoundLib.Back);
      SDLK_RETURN:
        begin
          // restart time
          //if (ScreenSong.Mode = smPartyTournament) then
          //  ScreenSong.CurrentPartyTime := 0;

          case Self.Playlist of
            0: ;
            1:
              begin
                if Length(UPlaylist.PlaylistMan.Playlists) = 0 then
                  Exit();

                USongs.CatSongs.ShowPlaylist(Self.PlayListItems);
                UPlaylist.PlaylistMan.SetPlayList(Self.PlayListItems);
              end
            else
              USongs.CatSongs.ShowCategory(Self.PlayListItems + 1);
          end;

          case Self.Mode of
            0:
              begin
                UGraphic.ScreenSong.Mode := smPartyClassic;
                Self.FadeTo(@ScreenPartyPlayer, UMusic.SoundLib.Start);
              end;
            1:
              begin
                UGraphic.ScreenSong.Mode := smPartyFree;
                Self.FadeTo(@ScreenPartyPlayer, UMusic.SoundLib.Start);
              end;
            2:
              begin
                if not Assigned(UGraphic.ScreenPartyTournamentRounds) then //load the screens only the first time
                begin
                  UGraphic.ScreenPartyTournamentRounds := TScreenPartyTournamentRounds.Create();
                  UGraphic.ScreenPartyTournamentPlayer := TScreenPartyTournamentPlayer.Create();
                  UGraphic.ScreenPartyTournamentOptions := TScreenPartyTournamentOptions.Create();
                  UGraphic.ScreenPartyTournamentWin := TScreenPartyTournamentWin.Create();
                end;
                UGraphic.ScreenSong.Mode := smPartyTournament;
                Self.FadeTo(@ScreenPartyTournamentPlayer, UMusic.SoundLib.Start);
              end;
            // 3:
            // begin
            //   UGraphic.ScreenSong.Mode := smPartyChallenge;
            //   UGraphic.ScreenPopupError.ShowPopup(Language.Translate('PARTY_MODE_NOT_AVAILABLE'));
            // end;
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

constructor TScreenPartyOptions.Create;
begin
  inherited Create;
  Self.PlayList := 0;
  Self.PlayListItems := 0;
  Self.Mode := 0;
  Self.LoadFromTheme(UThemes.Theme.PartyOptions);
  Self.SelectMode := Self.AddSelectSlide(UThemes.Theme.PartyOptions.SelectMode, Self.Mode, UThemes.Theme.IMode);
  Self.AddSelectSlide(UThemes.Theme.PartyOptions.SelectLevel, UIni.Ini.Difficulty, UThemes.Theme.ILevel);
  Self.SelectPlayList := Self.AddSelectSlide(UThemes.Theme.PartyOptions.SelectPlayList, Self.PlayList, [
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
    ULanguage.Language.Translate('OPTION_VALUE_DECADE')
  ]);
  Self.SelectPlayListItems := Self.AddSelectSlide(UThemes.Theme.PartyOptions.SelectPlayListItems, Self.PlayListItems, Self.PlayListItemsStrings);
end;

procedure TScreenPartyOptions.SetPlaylistsItems();
var
  I, J: integer;
begin
  if Self.Mode > 0 then
  begin
    Self.SelectsS[Self.SelectPlayList].Visible := false;
    Self.SelectsS[Self.SelectPlayListItems].Visible := false;
    Self.PlayListItems := 0;
  end
  else
  begin
    Self.SelectsS[Self.SelectPlayList].Visible := true;
    Self.SelectsS[Self.SelectPlayListItems].Visible := true;
    case Self.Playlist of
      0: //all
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
    Self.UpdateSelectSlideOptions(UThemes.Theme.PartyOptions.SelectPlayListItems, Self.SelectPlayListItems, Self.PlayListItemsStrings, Self.PlayListItems);
  end;
end;

procedure TScreenPartyOptions.OnShow;
begin
  inherited;
  if not Assigned(UGraphic.ScreenPartyNewRound) then //load the screens only the first time
  begin
    UGraphic.ScreenPartyNewRound := TScreenPartyNewRound.Create();
    UGraphic.ScreenPartyScore := TScreenPartyScore.Create();
    UGraphic.ScreenPartyWin := TScreenPartyWin.Create();
    UGraphic.ScreenPartyPlayer := TScreenPartyPlayer.Create();
    UGraphic.ScreenPartyRounds := TScreenPartyRounds.Create();
  end;
  Self.SetPlaylistsItems();
  Self.Interaction := 0;
  Party.Clear;

  // check if there are loaded modes
  if Party.ModesAvailable then
  begin
    // modes are loaded
    Randomize;
  end
  else
  begin // no modes found
    ScreenPopupError.ShowPopup(Language.Translate('ERROR_NO_PLUGINS'));
    Display.AbortScreenChange;
  end;
end;

procedure TScreenPartyOptions.SetAnimationProgress(Progress: real);
begin
  //for I := 0 to 6 do
  //  SelectS[I].Texture.ScaleW := Progress;
end;

end.
