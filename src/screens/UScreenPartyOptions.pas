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


unit UScreenPartyOptions;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  UScreenJukeboxPlaylist;

type
  TScreenPartyOptions = class(UScreenJukeboxPlaylist.TScreenJukeboxPlaylist)
    private
      SelectMode: cardinal;
      Mode: integer;
    protected
      procedure SetPlaylistsItems();
    public
      constructor CreateExtra(); override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
  end;

implementation

uses
  sdl2,
  UDisplay,
  UGraphic,
  UIni,
  ULanguage,
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
    // check special keys
    case PressedKey of
      SDLK_BACKSPACE, SDLK_DOWN, SDLK_ESCAPE, SDLK_LEFT, SDLK_RIGHT, SDLK_UP:
        inherited;
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
                  UGraphic.ScreenPartyTournamentRounds := UScreenPartyTournamentRounds.TScreenPartyTournamentRounds.Create();
                  UGraphic.ScreenPartyTournamentPlayer := UScreenPartyTournamentPlayer.TScreenPartyTournamentPlayer.Create();
                  UGraphic.ScreenPartyTournamentOptions := UScreenPartyTournamentOptions.TScreenPartyTournamentOptions.Create();
                  UGraphic.ScreenPartyTournamentWin := UScreenPartyTournamentWin.TScreenPartyTournamentWin.Create();
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
    end;
  end;
end;

constructor TScreenPartyOptions.CreateExtra();
begin
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
begin
  if Self.Mode > 0 then
  begin
    Self.SelectsS[Self.SelectPlayList].Visible := false;
    Self.SelectsS[Self.SelectPlayListItems].Visible := false;
    Self.PlayListItems := 0;
  end
  else
    inherited;
end;

procedure TScreenPartyOptions.OnShow();
begin
  inherited;
  if not Assigned(UGraphic.ScreenPartyNewRound) then //load the screens only the first time
  begin
    UGraphic.ScreenPartyNewRound := UScreenPartyNewRound.TScreenPartyNewRound.Create();
    UGraphic.ScreenPartyScore := UScreenPartyScore.TScreenPartyScore.Create();
    UGraphic.ScreenPartyWin := UScreenPartyWin.TScreenPartyWin.Create();
    UGraphic.ScreenPartyPlayer := UScreenPartyPlayer.TScreenPartyPlayer.Create();
    UGraphic.ScreenPartyRounds := UScreenPartyRounds.TScreenPartyRounds.Create();
  end;
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

end.
