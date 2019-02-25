{*
    UltraStar Deluxe WorldParty - Karaoke Game

    UltraStar Deluxe WorldParty is the legal property of its developers,
    whose names are too numerous to list here. Please refer to the
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


unit UScreenSong;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  SysUtils,
  sdl2,
  UCommon,
  UDataBase,
  UDllManager,
  UPath,
  UIni,
  ULanguage,
  ULog,
  UMenu,
  UMenuEqualizer,
  UMusic,
  USong,
  USongs,
  UTexture,
  UThemes,
  UTime;

type
  TVisArr = array of integer;

  TScreenSong = class(TMenu)
    private
      DefaultCover: TTexture;
      Equalizer: Tms_Equalizer;
      PreviewOpened: Integer; //interaction of the song that is loaded for preview music -1 if nothing is opened
      IsScrolling: boolean;   //true if song flow is about to move
      fCurrentVideo: IVideo;
      MinLine: integer; //current chessboard line
      LastMinLine: integer; //used on list mode
      ListFirstVisibleSongIndex: integer;
      MainListFirstVisibleSongIndex: integer;
      procedure StartMusicPreview();
      procedure StartVideoPreview();
      procedure LoadCover(Const I: integer);
      procedure UnloadCover(Const I: integer);
      procedure LoadMainCover();
    public
      TextArtist:   integer;
      TextTitle:    integer;
      TextNumber:   integer;
      TextYear:     integer;

      MakeMedley:   boolean;

      //Video Icon Mod
      VideoIcon: cardinal;

      //Medley Icons
      MedleyIcon:     cardinal;
      CalcMedleyIcon: cardinal;
      TextMedleyArtist:   array of integer;
      TextMedleyTitle:    array of integer;
      TextMedleyNumber:   array of integer;
      StaticMedley:   array of integer;

      //Duet Icon
      DuetIcon:     cardinal;
      DuetChange:   boolean;

      //Rap Icon
      RapIcon:     cardinal;

      TextCat:   integer;
      StaticCat: integer;

      SongCurrent:  real;
      SongTarget:   real;

      HighSpeed:    boolean;
      CoverFull:    boolean;
      CoverTime:    real;

      is_jump:      boolean; // Jump to Song Mod
      is_jump_title:boolean; //Jump to SOng MOd-YTrue if search for Title

      //Scores
      TextScore:       integer;
      TextMaxScore:    integer;
      TextMediaScore:  integer;
      TextMaxScore2:   integer;
      TextMediaScore2: integer;
      TextScoreUser:   integer;
      TextMaxScoreLocal:    integer;
      TextMediaScoreLocal:  integer;
      TextScoreUserLocal:   integer;

      //Party Mod
      Mode: TSingMode;

      //party Statics (Joker)
      StaticTeam1Joker1: cardinal;
      StaticTeam1Joker2: cardinal;
      StaticTeam1Joker3: cardinal;
      StaticTeam1Joker4: cardinal;
      StaticTeam1Joker5: cardinal;

      StaticTeam2Joker1: cardinal;
      StaticTeam2Joker2: cardinal;
      StaticTeam2Joker3: cardinal;
      StaticTeam2Joker4: cardinal;
      StaticTeam2Joker5: cardinal;

      StaticTeam3Joker1: cardinal;
      StaticTeam3Joker2: cardinal;
      StaticTeam3Joker3: cardinal;
      StaticTeam3Joker4: cardinal;
      StaticTeam3Joker5: cardinal;

      StaticParty:    array of cardinal;
      TextParty:      array of cardinal;
      StaticNonParty: array of cardinal;
      TextNonParty:   array of cardinal;

      // for chessboard songmenu
      MainCover: integer;
      SongSelectionUp: integer;
      SongSelectionDown: integer;

      // for list songmenu
      StaticList: array of integer;

      ListTextArtist:     array of integer;
      ListTextTitle:      array of integer;
      ListTextYear:       array of integer;
      ListVideoIcon:      array of integer;
      ListMedleyIcon:     array of integer;
      ListCalcMedleyIcon: array of integer;
      ListDuetIcon:       array of integer;
      ListRapIcon:        array of integer;

      PlayMidi: boolean;
      MidiFadeIn: boolean;
      FadeTime: cardinal;

      InfoMessageBG: cardinal;
      InfoMessageText: cardinal;

      Static2PlayersDuetSingerP1: cardinal;
      Static2PlayersDuetSingerP2: cardinal;
      Text2PlayersDuetSingerP1: cardinal;
      Text2PlayersDuetSingerP2: cardinal;

      Static3PlayersDuetSingerP1: cardinal;
      Static3PlayersDuetSingerP2: cardinal;
      Static3PlayersDuetSingerP3: cardinal;
      Text3PlayersDuetSingerP1: cardinal;
      Text3PlayersDuetSingerP2: cardinal;
      Text3PlayersDuetSingerP3: cardinal;

      Static4PlayersDuetSingerP3: cardinal;
      Static4PlayersDuetSingerP4: cardinal;

      Static6PlayersDuetSingerP4: cardinal;
      Static6PlayersDuetSingerP5: cardinal;
      Static6PlayersDuetSingerP6: cardinal;

      ColPlayer:  array[0..UIni.IMaxPlayerCount-1] of TRGB;

      //CurrentPartyTime: cardinal;
      //PartyTime: cardinal;
      //TextPartyTime: cardinal;

      MessageTime: cardinal;
      MessageTimeFade: cardinal;

      SongIndex:    integer; //Index of Song that is playing since UScreenScore...

      constructor Create; override;
      procedure SetScroll(force: boolean = false);
      procedure SetRouletteScroll;
      procedure SetChessboardScroll;
      procedure SetCarouselScroll;
      procedure SetSlotMachineScroll;
      procedure SetSlideScroll;
      procedure SetListScroll;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      function ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean; override;
      function Draw: boolean; override;
      procedure FadeMessage();
      procedure CloseMessage();
      procedure OnShow; override;
      procedure OnShowFinish; override;
      procedure OnHide; override;
      procedure SelectNext();
      procedure SelectPrev();
      procedure SelectNextRow;
      procedure SelectPrevRow;
      procedure SkipTo(Target: cardinal; Force: boolean = false);
      procedure ShowCatTL(Cat: integer);// Show Cat in Top left
      procedure ShowCatTLCustom(Caption: UTF8String);// Show Custom Text in Top left
      procedure HideCatTL;// Show Cat in Tob left
      procedure Refresh;//(GiveStats: boolean); //Refresh Song Sorting
      procedure ChangeSorting(Tabs: integer; Duet: boolean; Sorting: integer);
      procedure ChangeMusic;
      function FreeListMode: boolean;

      //Party Mode
      procedure SelectRandomSong;
      procedure SetJoker;
      procedure ColorizeJokers;
      //procedure PartyTimeLimit;
      function PermitCategory(ID: integer): boolean;

      //procedures for Menu
      procedure StartSong;
      procedure DoJoker(Team: integer);
      procedure SelectPlayers;

      procedure OnSongSelect;   // called when song flows movement stops at a song
      procedure OnSongDeSelect; // called before current song is deselected

      procedure SongScore;

      //Medley
      procedure StartMedley(NumSongs: integer; MinSource: TMedleySource);
      function  getVisibleMedleyArr(MinSource: TMedleySource): TVisArr;

      procedure ColorDuetNameSingers;

      procedure StopMusicPreview();
      procedure StopVideoPreview();

      procedure ParseInputNextHorizontal(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);
      procedure ParseInputPrevHorizontal(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);

      procedure ParseInputNextVertical(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);
      procedure ParseInputPrevVertical(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);
  end;

implementation

uses
  Math,
  dglOpenGL,
  StrUtils,
  UGraphic,
  UMain,
  UMenuButton,
  UNote,
  UAudioPlaybackBase,
  UParty,
  UPlaylist,
  UScreenPopup,
  UScreenSongMenu,
  UScreenSongJumpto,
  USkins,
  UUnicodeUtils,
  UMenuStatic;

const
  MAX_TIME = 30;
  MAX_MESSAGE = 3;
  MAX_TIME_MOUSE_SELECT = 800;

// ***** Public methods ****** //
function TScreenSong.FreeListMode: boolean;
begin
  Result := (Mode in [smNormal, smPartyTournament, smPartyFree, smJukebox]);
end;

procedure TScreenSong.ShowCatTLCustom(Caption: UTF8String);// Show Custom Text in Top left
begin
  Text[TextCat].Text := Caption;
  Text[TextCat].Visible := true;
  Statics[StaticCat].Visible := false;
end;

//Show Cat in Top Left Mod
procedure TScreenSong.ShowCatTL(Cat: integer);
begin
  //Change
  Text[TextCat].Text := CatSongs.Song[Cat].Artist;
  //Statics[StaticCat].Texture := Texture.LoadTexture(Button[Cat].Texture.Name, TEXTURE_TYPE_PLAIN, true);

  //Show
  Text[TextCat].Visible := true;
  Statics[StaticCat].Visible := true;
end;

procedure TScreenSong.HideCatTL;
begin
  //Hide
  //Text[TextCat].Visible := false;
  Statics[StaticCat].Visible := false;
  //New -> Show Text specified in Theme
  Text[TextCat].Visible := true;
  Text[TextCat].Text := Theme.Song.TextCat.Text;
end;
//Show Cat in Top Left Mod End

procedure TScreenSong.ParseInputNextHorizontal(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);
var
  SDL_ModState: word;
  I: integer;
begin
  CloseMessage();

  SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT
    + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT);

  if (Songs.SongList.Count > 0) and (FreeListMode) then
  begin
    if (SDL_ModState = KMOD_LCTRL) and (High(DLLMan.Websites) >= 0) then
    begin
      if (Ini.ShowWebScore < High(DLLMan.Websites)) then
        Ini.ShowWebScore := Ini.ShowWebScore + 1
      else
        Ini.ShowWebScore := 0;
      Ini.SaveShowWebScore;
      SongScore;
    end
    else
    begin
      for I := 1 to IfThen(PressedKey = SDLK_PAGEDOWN, Theme.Song.Cover.Rows, 1) do
        Self.SelectNext();
    end;
  end;
end;

procedure TScreenSong.ParseInputPrevHorizontal(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);
var
  SDL_ModState: word;
  I: integer;
begin
  CloseMessage();

  SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT
    + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT);

  if (Songs.SongList.Count > 0) and (FreeListMode) then
  begin
    if (SDL_ModState = KMOD_LCTRL) and (High(DLLMan.Websites) >= 0) then
    begin
      if (Ini.ShowWebScore > 0) then
        Ini.ShowWebScore := Ini.ShowWebScore - 1
      else
        Ini.ShowWebScore := High(DLLMan.Websites);
      Ini.SaveShowWebScore;
      SongScore;
    end
    else
    begin
      for I := 1 to IfThen(PressedKey = SDLK_PAGEUP, Theme.Song.Cover.Rows, 1) do
        Self.SelectPrev();
    end;
  end;
end;

{* Move down songs or rotate to next category if they are active *}
procedure TScreenSong.ParseInputNextVertical(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);
var
  I: integer;
begin
  CloseMessage();

  if (FreeListMode) and not (TSongMenuMode(Ini.SongMenu) in [smList]) then
  begin
    if (TSongMenuMode(Ini.SongMenu) in [smChessboard, smMosaic, smSlotMachine]) then //advance songs
      for I := 1 to IfThen(PressedKey = SDLK_PAGEDOWN, Theme.Song.Cover.Rows, 1) do
        Self.SelectNextRow()
    else if (CatSongs.CatNumShow > -2) and (UIni.Ini.Tabs = 1) then //if categories are activated
    begin
      I := USongs.CatSongs.Song[Self.Interaction].OrderNum; //enter into category if are in category list
      if not USongs.CatSongs.Song[Self.Interaction].Main then //or rotate to next category
        I := IfThen(I = USongs.CatSongs.CatCount, 1, I + 1); //go to first category if end is reached

      USongs.CatSongs.ShowCategory(I);
      Self.ShowCatTL(I);
      Self.SkipTo(0, true);
    end;
  end;
end;

{* Move up songs or rotate to previous category if they are active *}
procedure TScreenSong.ParseInputPrevVertical(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean);
var
  I: integer;
begin
  CloseMessage();

  if (FreeListMode and not (TSongMenuMode(Ini.SongMenu) in [smList])) then
  begin
    if (TSongMenuMode(Ini.SongMenu) in [smChessboard, smMosaic, smSlotMachine]) then //back songs
      for I := 1 to IfThen(PressedKey = SDLK_PAGEUP, Theme.Song.Cover.Rows, 1) do
        Self.SelectPrevRow()
    else if (CatSongs.CatNumShow > -2) and (UIni.Ini.Tabs = 1) then //if categories are activated
    begin
      I := USongs.CatSongs.Song[Self.Interaction].OrderNum; //enter into category if are in category list
      if not USongs.CatSongs.Song[Self.Interaction].Main then //or rotate to previous category
        I := IfThen(I = 1, USongs.CatSongs.CatCount, I - 1); //go to last category if start is reached

      USongs.CatSongs.ShowCategory(I);
      Self.ShowCatTL(I);
      Self.SkipTo(0, true);
    end;
  end;
end;

// Method for input parsing. If false is returned, GetNextWindow
// should be checked to know the next window to load;
function TScreenSong.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var
  I: integer;
  I2: integer;
  SDL_ModState: word;
  PressedKeyEncoded: UTF8String;
  Song: USong.TSong;
  WebList: string;
begin
  Result := true;

  //Song Screen Extensions (Jumpto + Menu)
  if (ScreenSongMenu.Visible) then
  begin
    Result := ScreenSongMenu.ParseInput(PressedKey, CharCode, PressedDown);
    Exit;
  end
  else if (ScreenSongJumpto.Visible) then
  begin
    Result := ScreenSongJumpto.ParseInput(PressedKey, CharCode, PressedDown);
    Exit;
  end;

  if (PressedDown) then
  begin // Key Down
    USongs.Songs.PreloadCovers(false);
    SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT);

    //jump to artist or title letter
    if Self.FreeListMode() and ((SDL_ModState = KMOD_LCTRL) or (SDL_ModState = KMOD_LALT)) then
    begin
      if (PressedKey in ([SDLK_a..SDLK_z, SDLK_0..SDLK_9])) then
      begin
        PressedKeyEncoded := UUnicodeUtils.UCS4ToUTF8String(PressedKey);
        for I2 := 0 to 1 do
        begin
          I := 0;
          for Song in CatSongs.Song do
          begin
            if
              Song.Visible
              and (((I2 = 0) and (I > Interaction)) or ((I2 = 1) and (I < Interaction)))
              and UUnicodeUtils.UTF8StartsText(PressedKeyEncoded, IfThen(SDL_ModState = KMOD_LCTRL, Song.Title, Song.Artist))
            then
            begin
              Self.SkipTo(I);
              Exit;
            end;
            Inc(I);
          end;
        end;
      end;
      Exit;
    end;

    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;

      Ord('K'):
        begin
          UAudioPlaybackBase.ToggleVoiceRemoval();
          StopVideoPreview();
          StopMusicPreview();
          StartMusicPreview();
          StartVideoPreview();
          Exit;
        end;

      Ord('F'):
        begin
          if (Mode = smNormal) and (SDL_ModState = KMOD_LSHIFT) and MakeMedley then
          begin
            if Length(PlaylistMedley.Song)>0 then
            begin
              SetLength(PlaylistMedley.Song, Length(PlaylistMedley.Song)-1);
              PlaylistMedley.NumMedleySongs := Length(PlaylistMedley.Song);
            end;

            if Length(PlaylistMedley.Song)=0 then
              MakeMedley := false;
          end else if (Mode = smNormal) and (CatSongs.Song[Interaction].Medley.Source>=msCalculated) and
            (Length(getVisibleMedleyArr(msCalculated)) > 0) then
          begin
            MakeMedley := true;
            StartMedley(99, msCalculated);
          end;
        end;

      Ord('M'): //Show SongMenu
        begin
          if (Songs.SongList.Count > 0) then
          begin

            if not(MakeMedley) and (FreeListMode) and (Mode <> smPartyFree) and (Mode <> smPartyTournament) then
            begin
              if (not CatSongs.Song[Interaction].Main) then // clicked on Song
              begin
                if CatSongs.CatNumShow = -3 then
                begin
                  ScreenSongMenu.OnShow;

                  if (ScreenSong.Mode = smJukebox) then
                    ScreenSongMenu.MenuShow(SM_Jukebox)
                  else
                    ScreenSongMenu.MenuShow(SM_Playlist);
                end
                else
                begin
                  ScreenSongMenu.OnShow;

                  if (ScreenSong.Mode = smJukebox) then
                    ScreenSongMenu.MenuShow(SM_Jukebox)
                  else
                    ScreenSongMenu.MenuShow(SM_Main);
                end;
              end
              else
              begin
                ScreenSongMenu.OnShow;
                if (ScreenSong.Mode = smJukebox) then
                  ScreenSongMenu.MenuShow(SM_Jukebox)
                else
                  ScreenSongMenu.MenuShow(SM_Playlist_Load);
              end;
            end //Party Mode -> Show Party Menu
            else
            begin

              if (MakeMedley) then
              begin
                ScreenSongMenu.MenuShow(SM_Medley)
              end
              else
              begin
                ScreenSongMenu.OnShow;
                if (Mode <> smPartyFree) and (Mode <> smPartyTournament) then
                  ScreenSongMenu.MenuShow(SM_Party_Main)
                else
                  ScreenSongMenu.MenuShow(SM_Party_Free_Main);
              end;
            end;
          end;
          Exit;
        end;

      Ord('P'): //Show Playlist Menu
        begin
          if (Songs.SongList.Count > 0) and (FreeListMode) then
          begin
            ScreenSongMenu.OnShow;
            ScreenSongMenu.MenuShow(SM_Playlist_Load);
          end;
          Exit;
        end;

      Ord('J'): //Show Jumpto Menu
        begin
          if (Songs.SongList.Count > 0) and (FreeListMode) then
          begin
            ScreenSongJumpto.Visible := true;
          end;
          Exit;
        end;

      Ord('S'):
        begin
          if not (SDL_ModState = KMOD_LSHIFT) and (CatSongs.Song[Interaction].Medley.Source>=msTag)
            and not MakeMedley and (Mode = smNormal) then
            StartMedley(0, msTag)
          else if not MakeMedley and
            (CatSongs.Song[Interaction].Medley.Source>=msCalculated) and
            (Mode = smNormal)then
            StartMedley(0, msCalculated);
        end;

      Ord('D'):
        begin
          if not (SDL_ModState = KMOD_LSHIFT) and (Mode = smNormal) and
            (Length(getVisibleMedleyArr(msTag)) > 0) and not MakeMedley then
            StartMedley(5, msTag)
          else if (Mode = smNormal) and not MakeMedley and
            (length(getVisibleMedleyArr(msCalculated))>0) then
            StartMedley(5, msCalculated);
        end;

      Ord('R'):
        begin
          Randomize;
          if (USongs.CatSongs.GetVisibleSongs() > 0) and Self.FreeListMode then
          begin
            if (SDL_ModState = KMOD_LSHIFT) and (UIni.Ini.Tabs = 1) then //random song of a category
            begin
              repeat
                I := Random(USongs.CatSongs.CatCount) + 1
              until (USongs.CatSongs.CatCount < 2) or (I <> USongs.CatSongs.CatNumShow); //avoid to change to same category
              Self.ShowCatTL(I);
              USongs.CatSongs.ShowCategory(I);
            end;
            repeat
              I := Random(USongs.CatSongs.GetVisibleSongs());
            until (USongs.CatSongs.GetVisibleSongs() < 2) or (I <> USongs.CatSongs.FindVisibleIndex(Self.Interaction)); //avoid to change to same song
            Self.SkipTo(I);
          end;
        end;

      Ord('W'):
        begin

          if not CatSongs.Song[Interaction].Main then
          begin
            WebList := '';

            for I:= 0 to High(Database.NetworkUser) do
            begin
              DllMan.LoadWebsite(I);
              if (DllMan.WebsiteVerifySong(WideString(CatSongs.Song[Interaction].MD5)) = 'OK_SONG') then
                WebList := Database.NetworkUser[I].Website + #13
            end;

            if (WebList <> '') then
              ScreenPopupInfo.ShowPopup(Format(Language.Translate('WEBSITE_EXIST_SONG'), [WebList]))
            else
              ScreenPopupError.ShowPopup(Language.Translate('WEBSITE_NOT_EXIST_SONG'));
          end;
        end;

    end; // normal keys

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          Self.CloseMessage();
          Self.HideCatTL();

          if (FreeListMode) then
          begin
            //On Escape goto Cat-List Hack
            if (UIni.Ini.Tabs = 1) and (USongs.CatSongs.CatNumShow <> -1) then
            begin
              USongs.CatSongs.ShowCategoryList();
              Self.SkipTo(USongs.CatSongs.Selected, true);
            end
            else
            begin
              //On Escape goto Cat-List Hack End
              //Tabs off and in Search or Playlist -> Go back to Song view
              Self.StopMusicPreview();
              if (CatSongs.CatNumShow < -1) then
              begin
                CatSongs.SetFilter('', fltAll);
                Self.SkipTo(0);
                Self.SetScroll(true);
              end
              else
              begin

                //if (Mode = smPartyTournament) then
                //  CurrentPartyTime := MAX_TIME - StrToInt(Text[TextPartyTime].Text);

                case Mode of
                  smPartyFree: FadeTo(@ScreenPartyNewRound);
                  smJukebox: FadeTo(@ScreenJukeboxPlaylist);
                  smPartyTournament: FadeTo(@ScreenPartyTournamentRounds);
                  else FadeTo(@ScreenMain);
                end;

              end;

            end;
          end
          //When in party Mode then Ask before Close
          else if (Mode = smPartyClassic) then
          begin
            CheckFadeTo(@ScreenMain,'MSG_END_PARTY');
          end;

          if (TSongMenuMode(Ini.SongMenu) in [smChessboard, smMosaic, smList, smSlotMachine]) then
            Self.SetScroll(true);

        end;
      SDLK_RETURN:
        begin
          CloseMessage();
          if (Songs.SongList.Count > 0) then
          begin
            if USongs.CatSongs.Song[Interaction].Main then
            begin // clicked on Category Button
              USongs.CatSongs.ShowCategory(USongs.CatSongs.Song[Self.Interaction].OrderNum);
              Self.ShowCatTL(Self.Interaction);
              Self.SkipTo(0, true);
            end
            else
            begin // clicked on song

              // Duets Warning
              if (CatSongs.Song[Interaction].isDuet) and (Mode <> smNormal) then
              begin
                ScreenPopupError.ShowPopup(Language.Translate('SING_ERROR_DUET_MODE_PARTY'));
                Exit;
              end;

              StopVideoPreview;
              StopMusicPreview;

              if (Mode = smNormal) then //Normal Mode -> Start Song
              begin
                if MakeMedley then
                begin
                  Mode := smMedley;

                  //Do the Action that is specified in Ini
                  case Ini.OnSongClick of
                    0: FadeTo(@ScreenSing);
                    1: SelectPlayers;
                    2: FadeTo(@ScreenSing);
                  end;
                end
                else
                begin
                  //Do the Action that is specified in Ini
                  case Ini.OnSongClick of
                    0: StartSong;
                    1: SelectPlayers;
                    2:begin
                        if (CatSongs.CatNumShow = -3) then
                          ScreenSongMenu.MenuShow(SM_Playlist)
                        else
                          ScreenSongMenu.MenuShow(SM_Main);
                      end;
                  end;
                end;
              end
              else
                if (Mode = smPartyClassic) then //PartyMode -> Show Menu
                begin
                  if (Ini.PartyPopup = 1) then
                    ScreenSongMenu.MenuShow(SM_Party_Main)
                  else
                    Party.CallAfterSongSelect;
                end;

                if (Mode = smPartyFree) then
                begin
                  Party.CallAfterSongSelect;
                end;

                if (Mode = smPartyTournament) then
                begin
                  ScreenSong.StartSong;
                end;

                if (Mode = smJukebox) then
                begin
                  if (Length(ScreenJukebox.JukeboxSongsList) > 0) then
                  begin
                    ScreenJukebox.CurrentSongID := ScreenJukebox.JukeboxVisibleSongs[0];
                    FadeTo(@ScreenJukebox);
                  end
                  else
                    ScreenPopupError.ShowPopup(Language.Translate('PARTY_MODE_JUKEBOX_NO_SONGS'));
                end;
              end;
          end;
        end;
      SDLK_DOWN, SDLK_PAGEDOWN:
        begin
          if (TSongMenuMode(Ini.SongMenu) in [smSlotMachine, smList]) then
            ParseInputNextHorizontal(PressedKey, CharCode, PressedDown)
          else
            ParseInputNextVertical(PressedKey, CharCode, PressedDown);
        end;
      SDLK_UP, SDLK_PAGEUP:
        begin
          if (TSongMenuMode(Ini.SongMenu) in [smSlotMachine, smList]) then
            ParseInputPrevHorizontal(PressedKey, CharCode, PressedDown)
          else
            ParseInputPrevVertical(PressedKey, CharCode, PressedDown);
        end;
      SDLK_RIGHT:
        begin
          if (TSongMenuMode(Ini.SongMenu) in [smSlotMachine, smList]) then
            ParseInputNextVertical(PressedKey, CharCode, PressedDown)
          else
            ParseInputNextHorizontal(PressedKey, CharCode, PressedDown);
        end;
      SDLK_LEFT:
        begin
          if (TSongMenuMode(Ini.SongMenu) in [smSlotMachine, smList]) then
            ParseInputPrevVertical(PressedKey, CharCode, PressedDown)
          else
            ParseInputPrevHorizontal(PressedKey, CharCode, PressedDown);
        end;
      SDLK_SPACE:
        begin
          if (Mode = smJukebox) and (not CatSongs.Song[Interaction].Main) then
            ScreenJukebox.AddSongToJukeboxList(Interaction);

          if (Mode = smNormal) and (USongs.CatSongs.Song[Interaction].isDuet) then
          begin
            Self.DuetChange := not Self.DuetChange;
            Self.SetScroll(true);
          end;
        end;
      SDLK_1:
        begin //Joker
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
            end
            else
              DoJoker(0);
            end;
        end;

      SDLK_2:
        begin //Joker
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
            end
            else
              DoJoker(1);
          end;

        end;

      SDLK_3:
        begin //Joker
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
            end
            else
              DoJoker(2);
          end;
      end;
    end;
  end; // if (PressedDown)
end;

function TScreenSong.ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean;
var
  B: integer;
begin
  Result := true;

  //transfer mousecords to the 800x600 raster we use to draw
  Y := Round((Y / ScreenH) * RenderH);
  X := Round((X / (ScreenW / Screens)) * RenderW);
  if (X > RenderW) then
    X := X - RenderW;

  if UGraphic.ScreenSongMenu.Visible then
    Result := UGraphic.ScreenSongMenu.ParseMouse(MouseButton, BtnDown, X, Y)
  else if UGraphic.ScreenSongJumpTo.Visible then
    Result := UGraphic.ScreenSongJumpTo.ParseMouse(MouseButton, BtnDown, X, Y)
  else if BtnDown then
  begin
    USongs.Songs.PreloadCovers(false);
    case MouseButton of
      SDL_BUTTON_LEFT:
      begin
        for B := 0 to High(Self.Button) do
          if Self.Button[B].Visible and (Self.Button[B].Z > 0.9) and Self.InRegion(X, Y, Self.Button[B].GetMouseOverArea()) then //z to roulette mode fix
            if Self.Interaction = B then
              Self.ParseInput(SDLK_RETURN, 0, true)
            else
              Self.SkipTo(B);

        if UIni.TSongMenuMode(UIni.Ini.SongMenu) = smChessboard then
          if Self.InRegion(X, Y, Self.Statics[Self.SongSelectionUp].GetMouseOverArea()) then //arrow to page up
            Self.ParseInput(SDLK_PAGEUP, 0, true)
          else if Self.InRegion(X, Y, Self.Statics[Self.SongSelectionDown].GetMouseOverArea()) then //arrow to page down
            Self.ParseInput(SDLK_PAGEDOWN, 0, true);
      end;
      SDL_BUTTON_RIGHT: //go back
        if Self.RightMbESC then
          Result := Self.ParseInput(SDLK_ESCAPE, 0, true);
      SDL_BUTTON_MIDDLE: //open song menu
        Self.ParseInput(0, Ord('M'), true);
      SDL_BUTTON_WHEELDOWN: //next song
        Self.SelectNext();
      SDL_BUTTON_WHEELUP: //previous song
        Self.SelectPrev();
    end;
  end
  else if UIni.TSongMenuMode(UIni.Ini.SongMenu) = smChessboard then //hover cover
    for B := 0 to High(Self.Button) do
      if Self.Button[B].Visible and Self.InRegion(X, Y, Self.Button[B].GetMouseOverArea()) and (Self.Interaction <> B) then
      begin
        Self.Interaction := B;
        Self.SongTarget := B;
        Self.OnSongDeSelect();
        Self.SetScroll();
      end;
end;

procedure TScreenSong.ColorizeJokers;
var
  StartJoker, I, J: integer;
  Col: TRGB;
begin

  StartJoker := StaticTeam1Joker1;

  for I:= 0 to 2 do
  begin
    Col := GetPlayerColor(Ini.SingColor[I]);

    for J := StartJoker + I * 5 to (StartJoker + I * 5 - 1) + 5  do
    begin
      Statics[J].Texture.ColR := Col.R;
      Statics[J].Texture.ColG := Col.G;
      Statics[J].Texture.ColB := Col.B;
    end;
  end;

end;

constructor TScreenSong.Create;
var
  I, Num, Padding: integer;
  TextArtistY, TextTitleY, TextYearY, StaticMedCY,
  StaticMedMY, StaticVideoY, StaticDuetY, StaticRapY: integer;
  StaticY: real;
begin
  inherited Create;

  Self.DefaultCover := UTexture.Texture.LoadTexture(USkins.Skin.GetTextureFileName('SongCover'));
  for I := 0 to High(USongs.CatSongs.Song) do
    Self.AddButton(
      Theme.Song.Cover.X,
      Theme.Song.Cover.Y,
      Theme.Song.Cover.W,
      Theme.Song.Cover.H,
      PATH_NONE,
      TEXTURE_TYPE_PLAIN,
      Theme.Song.Cover.Reflections
    );

  LoadFromTheme(Theme.Song);

  TextArtist := AddText(Theme.Song.TextArtist);
  TextTitle  := AddText(Theme.Song.TextTitle);
  TextNumber := AddText(Theme.Song.TextNumber);
  TextYear   := AddText(Theme.Song.TextYear);

  //Show Cat in Top Left mod
  TextCat := AddText(Theme.Song.TextCat);
  StaticCat :=  AddStatic(Theme.Song.StaticCat);

  //Show Video Icon Mod
  VideoIcon := AddStatic(Theme.Song.VideoIcon);

  //Meldey Icons
  MedleyIcon := AddStatic(Theme.Song.MedleyIcon);
  CalcMedleyIcon := AddStatic(Theme.Song.CalculatedMedleyIcon);

  //Duet Icon
  DuetIcon := AddStatic(Theme.Song.DuetIcon);

  //Rap Icon
  RapIcon := AddStatic(Theme.Song.RapIcon);

  //Show Scores
  TextScore       := AddText(Theme.Song.TextScore);
  TextMaxScore    := AddText(Theme.Song.TextMaxScore);
  TextMediaScore  := AddText(Theme.Song.TextMediaScore);
  TextMaxScore2   := AddText(Theme.Song.TextMaxScore2);
  TextMediaScore2 := AddText(Theme.Song.TextMediaScore2);
  TextScoreUser   := AddText(Theme.Song.TextScoreUser);
  TextMaxScoreLocal   := AddText(Theme.Song.TextMaxScoreLocal);
  TextMediaScoreLocal := AddText(Theme.Song.TextMediaScoreLocal);
  TextScoreUserLocal  := AddText(Theme.Song.TextScoreUserLocal);

  //Party Mode
  StaticTeam1Joker1 := AddStatic(Theme.Song.StaticTeam1Joker1);
  StaticTeam1Joker2 := AddStatic(Theme.Song.StaticTeam1Joker2);
  StaticTeam1Joker3 := AddStatic(Theme.Song.StaticTeam1Joker3);
  StaticTeam1Joker4 := AddStatic(Theme.Song.StaticTeam1Joker4);
  StaticTeam1Joker5 := AddStatic(Theme.Song.StaticTeam1Joker5);

  StaticTeam2Joker1 := AddStatic(Theme.Song.StaticTeam2Joker1);
  StaticTeam2Joker2 := AddStatic(Theme.Song.StaticTeam2Joker2);
  StaticTeam2Joker3 := AddStatic(Theme.Song.StaticTeam2Joker3);
  StaticTeam2Joker4 := AddStatic(Theme.Song.StaticTeam2Joker4);
  StaticTeam2Joker5 := AddStatic(Theme.Song.StaticTeam2Joker5);

  StaticTeam3Joker1 := AddStatic(Theme.Song.StaticTeam3Joker1);
  StaticTeam3Joker2 := AddStatic(Theme.Song.StaticTeam3Joker2);
  StaticTeam3Joker3 := AddStatic(Theme.Song.StaticTeam3Joker3);
  StaticTeam3Joker4 := AddStatic(Theme.Song.StaticTeam3Joker4);
  StaticTeam3Joker5 := AddStatic(Theme.Song.StaticTeam3Joker5);

  //Load Party or NonParty specific Statics and Texts
  SetLength(StaticParty, Length(Theme.Song.StaticParty));
  for i := 0 to High(Theme.Song.StaticParty) do
    StaticParty[i] := AddStatic(Theme.Song.StaticParty[i]);

  SetLength(TextParty, Length(Theme.Song.TextParty));
  for i := 0 to High(Theme.Song.TextParty) do
    TextParty[i] := AddText(Theme.Song.TextParty[i]);

  SetLength(StaticNonParty, Length(Theme.Song.StaticNonParty));
  for i := 0 to High(Theme.Song.StaticNonParty) do
    StaticNonParty[i] := AddStatic(Theme.Song.StaticNonParty[i]);

  SetLength(TextNonParty, Length(Theme.Song.TextNonParty));
  for i := 0 to High(Theme.Song.TextNonParty) do
    TextNonParty[i] := AddText(Theme.Song.TextNonParty[i]);

  //TextPartyTime := AddText(Theme.Song.TextPartyTime);

  // Randomize Patch
  Randomize;

  Equalizer := Tms_Equalizer.Create(AudioPlayback, Theme.Song.Equalizer);

  PreviewOpened := -1;
  Self.IsScrolling := false;

  fCurrentVideo := nil;

  // Info Message
  InfoMessageBG := AddStatic(Theme.Song.InfoMessageBG);
  InfoMessageText := AddText(Theme.Song.InfoMessageText);

  // Duet Names Singers
  Static4PlayersDuetSingerP3 := AddStatic(Theme.Song.Static4PlayersDuetSingerP3);
  Static4PlayersDuetSingerP4 := AddStatic(Theme.Song.Static4PlayersDuetSingerP4);

  Static6PlayersDuetSingerP4 := AddStatic(Theme.Song.Static6PlayersDuetSingerP4);
  Static6PlayersDuetSingerP5 := AddStatic(Theme.Song.Static6PlayersDuetSingerP5);
  Static6PlayersDuetSingerP6 := AddStatic(Theme.Song.Static6PlayersDuetSingerP6);

  Text2PlayersDuetSingerP1 := AddText(Theme.Song.Text2PlayersDuetSingerP1);
  Text2PlayersDuetSingerP2 := AddText(Theme.Song.Text2PlayersDuetSingerP2);
  Static2PlayersDuetSingerP1 := AddStatic(Theme.Song.Static2PlayersDuetSingerP1);
  Static2PlayersDuetSingerP2 := AddStatic(Theme.Song.Static2PlayersDuetSingerP2);

  Text3PlayersDuetSingerP1 := AddText(Theme.Song.Text3PlayersDuetSingerP1);
  Text3PlayersDuetSingerP2 := AddText(Theme.Song.Text3PlayersDuetSingerP2);
  Text3PlayersDuetSingerP3 := AddText(Theme.Song.Text3PlayersDuetSingerP3);
  Static3PlayersDuetSingerP1 := AddStatic(Theme.Song.Static3PlayersDuetSingerP1);
  Static3PlayersDuetSingerP2 := AddStatic(Theme.Song.Static3PlayersDuetSingerP2);
  Static3PlayersDuetSingerP3 := AddStatic(Theme.Song.Static3PlayersDuetSingerP3);

  // Medley Playlist
  SetLength(TextMedleyArtist, Theme.Song.TextMedleyMax);
  SetLength(TextMedleyTitle, Theme.Song.TextMedleyMax);
  SetLength(TextMedleyNumber, Theme.Song.TextMedleyMax);
  SetLength(StaticMedley, Theme.Song.TextMedleyMax);

  for I := 0 to Theme.Song.TextMedleyMax - 1 do
  begin
    TextMedleyArtist[I] := AddText(Theme.Song.TextArtistMedley[I]);
    TextMedleyTitle[I] := AddText(Theme.Song.TextTitleMedley[I]);
    TextMedleyNumber[I] := AddText(Theme.Song.TextNumberMedley[I]);
    StaticMedley[I] := AddStatic(Theme.Song.StaticMedley[I]);
  end;

  Self.MainCover := AddStatic(
    Theme.Song.Cover.SelectX,
    Theme.Song.Cover.SelectY,
    Theme.Song.Cover.SelectW,
    Theme.Song.Cover.SelectH,
    PATH_NONE
  );
  Self.SongSelectionUp := Self.AddStatic(UThemes.Theme.Song.SongSelectionUp);
  Self.SongSelectionDown := Self.AddStatic(UThemes.Theme.Song.SongSelectionDown);

  Num := Theme.Song.ListCover.Rows;

  SetLength(StaticList, Num);
  for I := 0 to Num - 1 do
  begin
    StaticY := Theme.Song.ListCover.Y + I * (Theme.Song.ListCover.H + Theme.Song.ListCover.Padding);

    StaticList[I] := AddListItem(
      Theme.Song.ListCover.X,
      StaticY,
      Theme.Song.ListCover.W,
      Theme.Song.ListCover.H,
      Theme.Song.ListCover.Z,
      Theme.Song.ListCover.ColR,
      Theme.Song.ListCover.ColG,
      Theme.Song.ListCover.ColB,
      Theme.Song.ListCover.DColR,
      Theme.Song.ListCover.DColG,
      Theme.Song.ListCover.DColB,
      Skin.GetTextureFileName(Theme.Song.ListCover.Tex),
      Skin.GetTextureFileName(Theme.Song.ListCover.DTex),
      Theme.Song.ListCover.Typ,
      Theme.Song.ListCover.Reflection,
      Theme.Song.ListCover.ReflectionSpacing);
  end;

  SetLength(ListTextArtist, Num);
  SetLength(ListTextTitle, Num);
  SetLength(ListTextYear, Num);
  SetLength(ListVideoIcon, Num);
  SetLength(ListMedleyIcon, Num);
  SetLength(ListCalcMedleyIcon, Num);
  SetLength(ListDuetIcon, Num);
  SetLength(ListRapIcon, Num);

  TextArtistY := Theme.Song.TextArtist.Y;
  TextTitleY := Theme.Song.TextTitle.Y;
  TextYearY := Theme.Song.TextYear.Y;

  StaticVideoY := Theme.Song.VideoIcon.Y;
  StaticMedMY := Theme.Song.MedleyIcon.Y;
  StaticMedCY := Theme.Song.CalculatedMedleyIcon.Y;
  StaticDuetY := Theme.Song.DuetIcon.Y;
  StaticRapY := Theme.Song.RapIcon.Y;

  for I := 0 to Num - 1 do
  begin
    Padding := I * (Theme.Song.ListCover.H + Theme.Song.ListCover.Padding);

    Theme.Song.TextArtist.Y  := TextArtistY + Padding;

    ListTextArtist[I] := AddText(Theme.Song.TextArtist);

    Theme.Song.TextTitle.Y  := TextTitleY + Padding;
    ListTextTitle[I]  := AddText(Theme.Song.TextTitle);

    Theme.Song.TextYear.Y  := TextYearY + Padding;
    ListTextYear[I]   := AddText(Theme.Song.TextYear);

    Theme.Song.VideoIcon.Y  := StaticVideoY + Padding;
    ListVideoIcon[I]  := AddStatic(Theme.Song.VideoIcon);

    Theme.Song.MedleyIcon.Y  := StaticMedMY + Padding;
    ListMedleyIcon[I] := AddStatic(Theme.Song.MedleyIcon);

    Theme.Song.CalculatedMedleyIcon.Y  := StaticMedCY + Padding;
    ListCalcMedleyIcon[I] := AddStatic(Theme.Song.CalculatedMedleyIcon);

    Theme.Song.DuetIcon.Y  := StaticDuetY + Padding;
    ListDuetIcon[I] := AddStatic(Theme.Song.DuetIcon);

    Theme.Song.RapIcon.Y  := StaticRapY + Padding;
    ListRapIcon[I] := AddStatic(Theme.Song.RapIcon);
  end;

  Self.MinLine := 0;

  ListFirstVisibleSongIndex := 0;
end;

procedure TScreenSong.ColorDuetNameSingers();
  procedure SetColor(Singer: integer; Color: integer);
  begin
    Self.Statics[Singer].Texture.ColR := ColPlayer[Color].R;
    Self.Statics[Singer].Texture.ColG := ColPlayer[Color].G;
    Self.Statics[Singer].Texture.ColB := ColPlayer[Color].B;
  end;
var
  Col: TRGB;
begin
  case UNote.PlayersPlay of
    1:
      begin
        SetColor(Static2PlayersDuetSingerP1, 0);

        Col := UThemes.GetPlayerLightColor(Ini.SingColor[0]);
        Self.Statics[Static2PlayersDuetSingerP2].Texture.ColR := Col.R;
        Self.Statics[Static2PlayersDuetSingerP2].Texture.ColG := Col.G;
        Self.Statics[Static2PlayersDuetSingerP2].Texture.ColB := Col.B;
      end;
    2:
      begin
        SetColor(Static2PlayersDuetSingerP1, 0);
        SetColor(Static2PlayersDuetSingerP2, 1);
      end;
    3:
      begin
        SetColor(Static3PlayersDuetSingerP1, 0);
        SetColor(Static3PlayersDuetSingerP2, 1);
        SetColor(Static3PlayersDuetSingerP3, 2);
      end;
    4:
      begin
        if UGraphic.Screens = 1 then
        begin
          SetColor(Static2PlayersDuetSingerP1, 0);
          SetColor(Static2PlayersDuetSingerP2, 1);
          SetColor(Static4PlayersDuetSingerP3, 2);
          SetColor(Static4PlayersDuetSingerP4, 3);
        end
        else
        begin
          if UGraphic.ScreenAct = 1 then
          begin
            SetColor(Static2PlayersDuetSingerP1, 0);
            SetColor(Static2PlayersDuetSingerP2, 1);
          end;

          if UGraphic.ScreenAct = 2 then
          begin
            SetColor(Static2PlayersDuetSingerP1, 2);
            SetColor(Static2PlayersDuetSingerP2, 3);
          end;
        end;
      end;
    6:
      begin
        if UGraphic.Screens = 1 then
        begin
          SetColor(Static3PlayersDuetSingerP1, 0);
          SetColor(Static3PlayersDuetSingerP2, 1);
          SetColor(Static3PlayersDuetSingerP3, 2);
          SetColor(Static6PlayersDuetSingerP4, 3);
          SetColor(Static6PlayersDuetSingerP5, 4);
          SetColor(Static6PlayersDuetSingerP6, 5);
        end
        else
        begin
          if UGraphic.ScreenAct = 1 then
          begin
            SetColor(Static3PlayersDuetSingerP1, 0);
            SetColor(Static3PlayersDuetSingerP2, 1);
            SetColor(Static3PlayersDuetSingerP3, 2);
          end;
          if UGraphic.ScreenAct = 2 then
          begin
            SetColor(Static3PlayersDuetSingerP1, 3);
            SetColor(Static3PlayersDuetSingerP2, 4);
            SetColor(Static3PlayersDuetSingerP3, 5);
          end;
        end;
      end;
  end;
end;

{ called when song flows movement stops at a song }
procedure TScreenSong.OnSongSelect;
begin
  Self.SongTarget := Self.Interaction;
  Self.IsScrolling := false;
  if (Ini.PreviewVolume <> 0) then
  begin
    StartMusicPreview;
    StartVideoPreview;
  end;

  // fade in detailed cover
  CoverTime := 0;

  SongIndex := -1;
end;

{ called before current song is deselected }
procedure TScreenSong.OnSongDeSelect;
begin
  Self.IsScrolling := true;
  DuetChange := false;

  CoverTime := 10;
  StopMusicPreview();
  StopVideoPreview();
  PreviewOpened := -1;
end;

procedure TScreenSong.SetScroll(force: boolean = false);
var
  VS, B, SongsInCat: integer;
  DuetPlayer1: UTF8String = '';
  DuetPlayer2: UTF8String = '';
begin
  if not (force or Self.IsScrolling) then //to avoid unnecessary modifications if nothing changes
    Exit;

  VS := USongs.CatSongs.GetVisibleSongs();
  if VS > 0 then
  begin
    case TSongMenuMode(Ini.SongMenu) of
      smRoulette: SetRouletteScroll;
      smChessboard: SetChessboardScroll;
      smCarousel: SetCarouselScroll;
      smSlotMachine: SetSlotMachineScroll;
      smSlide: SetSlideScroll;
      smList: SetListScroll;
      smMosaic: SetChessboardScroll;
    end;

    if (TSongMenuMode(Ini.SongMenu) <> smList) then
    begin
      // Set visibility of video icon
      Statics[VideoIcon].Visible := CatSongs.Song[Interaction].Video.IsSet;

      // Set visibility of medley icons
      Statics[MedleyIcon].Visible := (CatSongs.Song[Interaction].Medley.Source = msTag) and not CatSongs.Song[Interaction].isDuet;
      Statics[CalcMedleyIcon].Visible := (CatSongs.Song[Interaction].Medley.Source = msCalculated) and not CatSongs.Song[Interaction].isDuet;

      //Set Visibility of Duet Icon
      Statics[DuetIcon].Visible := CatSongs.Song[Interaction].isDuet;

      //Set Visibility of Rap Icon
      Statics[RapIcon].Visible := CatSongs.Song[Interaction].hasRap;

      // Set texts
      Text[TextArtist].Text := CatSongs.Song[Interaction].Artist;
      Text[TextTitle].Text  :=  CatSongs.Song[Interaction].Title;
      if ((Ini.Tabs = 0) or (TSortingType(Ini.Sorting) <> sYear))
        and (CatSongs.Song[Interaction].Year <> 0) then
          Text[TextYear].Text  :=  InttoStr(CatSongs.Song[Interaction].Year)
      else
        Text[TextYear].Text  :=  '';
    end;

    // Duet Singers
    if USongs.CatSongs.Song[Interaction].isDuet then
    begin
      if (UNote.PlayersPlay = 3) or (UNote.PlayersPlay = 6) then
      begin
        Text[Text3PlayersDuetSingerP1].Visible := true;
        Text[Text3PlayersDuetSingerP2].Visible := true;
        Text[Text3PlayersDuetSingerP3].Visible := true;
        Statics[Static3PlayersDuetSingerP1].Visible := true;
        Statics[Static3PlayersDuetSingerP2].Visible := true;
        Statics[Static3PlayersDuetSingerP3].Visible := true;
        if (UGraphic.Screens = 1) and (UNote.PlayersPlay = 6) then
        begin
          Statics[Static6PlayersDuetSingerP4].Visible := true;
          Statics[Static6PlayersDuetSingerP5].Visible := true;
          Statics[Static6PlayersDuetSingerP6].Visible := true;
        end;
      end
      else
      begin
        Text[Text2PlayersDuetSingerP1].Visible := true;
        Text[Text2PlayersDuetSingerP2].Visible := true;
        Statics[Static2PlayersDuetSingerP1].Visible := true;
        Statics[Static2PlayersDuetSingerP2].Visible := true;
        if (UGraphic.Screens = 1) and (UNote.PlayersPlay = 4) then
        begin
          Statics[Static4PlayersDuetSingerP3].Visible := true;
          Statics[Static4PlayersDuetSingerP4].Visible := true;
        end;
      end;

      // Set duet texts
      if Self.DuetChange then
      begin
        DuetPlayer1 := CatSongs.Song[Interaction].DuetNames[1];
        DuetPlayer2 := CatSongs.Song[Interaction].DuetNames[0];
      end
      else
      begin
        DuetPlayer1 := CatSongs.Song[Interaction].DuetNames[0];
        DuetPlayer2 := CatSongs.Song[Interaction].DuetNames[1];
      end;
      case UNote.PlayersPlay of
        6:
          begin
            if UGraphic.ScreenAct = 1 then
            begin
              Text[Text3PlayersDuetSingerP1].Text := DuetPlayer1;
              Text[Text3PlayersDuetSingerP2].Text := DuetPlayer2;
              Text[Text3PlayersDuetSingerP3].Text := DuetPlayer1;
            end
            else
            begin
              Text[Text3PlayersDuetSingerP1].Text := DuetPlayer2;
              Text[Text3PlayersDuetSingerP2].Text := DuetPlayer1;
              Text[Text3PlayersDuetSingerP3].Text := DuetPlayer2;
            end
          end;
        3:
          begin
            Text[Text3PlayersDuetSingerP1].Text := DuetPlayer1;
            Text[Text3PlayersDuetSingerP2].Text := DuetPlayer2;
            Text[Text3PlayersDuetSingerP3].Text := DuetPlayer1;
          end;
        else //1 or 2 players
          begin
            Text[Text2PlayersDuetSingerP1].Text := DuetPlayer1;
            Text[Text2PlayersDuetSingerP2].Text := DuetPlayer2;
          end;
      end;
    end
    else
    begin
      Text[Text2PlayersDuetSingerP1].Visible := false;
      Text[Text2PlayersDuetSingerP2].Visible := false;
      Text[Text3PlayersDuetSingerP1].Visible := false;
      Text[Text3PlayersDuetSingerP2].Visible := false;
      Text[Text3PlayersDuetSingerP3].Visible := false;
      Statics[Static2PlayersDuetSingerP1].Visible := false;
      Statics[Static2PlayersDuetSingerP2].Visible := false;
      Statics[Static3PlayersDuetSingerP1].Visible := false;
      Statics[Static3PlayersDuetSingerP2].Visible := false;
      Statics[Static3PlayersDuetSingerP3].Visible := false;
      Statics[Static4PlayersDuetSingerP3].Visible := false;
      Statics[Static4PlayersDuetSingerP4].Visible := false;
      Statics[Static6PlayersDuetSingerP4].Visible := false;
      Statics[Static6PlayersDuetSingerP5].Visible := false;
      Statics[Static6PlayersDuetSingerP6].Visible := false;
    end;

    //Set Song Score
    SongScore;

    if (UIni.Ini.Tabs = 1) and (CatSongs.CatNumShow = -1) then
    begin
      Text[TextNumber].Text := IntToStr(CatSongs.Song[Interaction].OrderNum) + '/' + IntToStr(CatSongs.CatCount);
      SongsInCat := CatSongs.Song[Interaction].CatNumber;
      if (SongsInCat = 1) then
        Text[TextTitle].Text  := '(' + IntToStr(CatSongs.Song[Interaction].CatNumber) + ' ' + Language.Translate('SING_SONG_IN_CAT') + ')'
      else
        Text[TextTitle].Text  := '(' + IntToStr(CatSongs.Song[Interaction].CatNumber) + ' ' + Language.Translate('SING_SONGS_IN_CAT') + ')';
    end
    else if (CatSongs.CatNumShow < -1) then //FIXME includes -2 and -3... but why this CatNumShow?
      Text[TextNumber].Text := IntToStr(CatSongs.FindVisibleIndex(Interaction)+1) + '/' + IntToStr(VS)
    else if (UIni.Ini.Tabs = 1) then
    begin
      Text[TextNumber].Text := IntToStr(CatSongs.Song[Interaction].CatNumber)+ '/' + IntToStr(VS);
      if not Interaction = 0 then Text[TextNumber].Text := Text[TextNumber].Text + '/' + IntToStr(CatSongs.Song[Interaction - CatSongs.Song[Interaction].CatNumber].CatNumber);
    end
    else
      Text[TextNumber].Text := IntToStr(Interaction+1) + '/' + IntToStr(Length(CatSongs.Song));
  end
  else
  begin
    Text[TextNumber].Text := '0/0';
    Text[TextArtist].Text := '';
    Text[TextTitle].Text  := '';
    Text[TextYear].Text  := '';

    Statics[VideoIcon].Visible := false;

    for B := 0 to High(Button) do
      Button[B].Visible := false;

  end;
end;

procedure TScreenSong.SetRouletteScroll;
var
  I, VisibleIndex: integer;
  VS: integer;
  B: TButton;
  Angle, AutoWidthCorrection, Pos: real;
begin
  VS := USongs.CatSongs.GetVisibleSongs();
  AutoWidthCorrection:= (UGraphic.RenderH/UGraphic.ScreenH)*(UGraphic.ScreenW/UGraphic.RenderW); //ToDo basisbit: width for 2-screen-setup
  if Screens > 1 then
   AutoWidthCorrection:= AutoWidthCorrection / 2;

  I := 0;
  VisibleIndex := 0;
  for B in Button do
  begin
    B.Visible := CatSongs.Song[I].Visible; // adjust visibility
    if B.Visible then // Only change pos for visible buttons
    begin
      // Pos is the distance to the centered cover in the range [-VS/2..+VS/2]
      Pos := VisibleIndex - Self.SongCurrent;
      Inc(VisibleIndex);
      if (Pos < -VS / 2) then
        Pos := Pos + VS
      else if (Pos > VS / 2) then
        Pos := Pos - VS;

      // Avoid overlapping of the front covers.
      // Use an alternate position for the five front covers.
      if (Abs(Pos) < 2.5) then
      begin
        Self.LoadCover(I);
        Angle := Pi * (Pos / Min(VS, 5)); // Range: (-1/4*Pi .. +1/4*Pi)
        B.H := Abs(Theme.Song.Cover.H * AutoWidthCorrection * Cos(Angle * 0.8));
        B.W := Abs(Theme.Song.Cover.W * Cos(Angle * 0.8));
        // B.Reflectionspacing := 15 * B.H / Theme.Song.Cover.H;
        B.DeSelectReflectionspacing := 15 * B.H / Theme.Song.Cover.H;
        B.X := Theme.Song.Cover.X + Theme.Song.Cover.W * Sin(Angle * 1.3) * 0.9 * 1.6 - (B.W - Theme.Song.Cover.W) / 2;
        B.Y := ((Theme.Song.Cover.Y) + ((Theme.Song.Cover.H) - Abs(Theme.Song.Cover.H * Cos(Angle))) * 0.5) - (B.H - (B.H / AutoWidthCorrection));
        B.Z := 0.95 - Abs(Pos) * 0.01;
        B.Texture.Alpha := IfThen(VS < 5, 1 - Abs(Pos) / VS * 2, 1);
      end
      //only draw 5 visible covers in the background (the 5 that are on the opposite of the front covers
      else if (VS > 9) and (Abs(Pos) > Floor(VS / 2) - 2.5) then
      begin
        Self.LoadCover(I);
        // Transform Pos to range [-1..-3/4, +3/4..+1]
        { the 5 covers at the back will show up in the gap between the
          front cover and its neighbors
          one cover will be hiddenbehind the front cover,
          but this will not be a lack of performance ;) }
        if Pos < 0 then
          Pos := (Pos - 2 + Ceil(VS / 2)) / 8 - 0.75
        else
          Pos := (Pos + 2 - Floor(VS / 2)) / 8 + 0.75;

        // angle in radians [-2Pi..-Pi, +Pi..+2Pi]
        Angle := 2 * Pi * Pos;
        B.H := 0.6 * (Theme.Song.Cover.H - Abs(Theme.Song.Cover.H * Cos(Angle / 2) * 0.8));
        B.W := 0.6 * (Theme.Song.Cover.W - Abs(Theme.Song.Cover.W * Cos(Angle / 2) * 0.8));
        B.X := Theme.Song.Cover.X + Theme.Song.Cover.W / 2 - B.W / 2 + Theme.Song.Cover.W / 320 * (Theme.Song.Cover.W * Sin(Angle / 2) * 1.52);
        B.Y := Theme.Song.Cover.Y - (B.H - Theme.Song.Cover.H) * 0.75;
        B.Z := (0.4 - Abs(Pos / 4)) - 0.00001; //z < 0.49999 is behind the cover 1 is in front of the covers
        B.Texture.Alpha := 1;
        //B.Reflectionspacing := 15 * B.H / Theme.Song.Cover.H;
        B.DeSelectReflectionspacing := 15 * B.H / Theme.Song.Cover.H;
      end
      else
        Self.UnloadCover(I);
    end;
    Inc(I);
  end;
end;

procedure TScreenSong.SetChessboardScroll;
var
  B, CoverH, CoverW, MaxRow, MaxCol, Line, Index, Count: integer;
begin
  CoverH := Theme.Song.Cover.H;
  CoverW := Theme.Song.Cover.W;
  MaxRow := Theme.Song.Cover.Rows;
  MaxCol := Theme.Song.Cover.Cols;
  Line := 0;
  Index := 0;
  Count := 0;

  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
    Line := Count div MaxCol;
    if Self.Button[B].Visible and (Line < (MaxRow + Self.MinLine)) then //only change position for visible buttons
    begin
      if Line >= Self.MinLine then
      begin
        Self.LoadCover(B);
        Self.Button[B].X := Theme.Song.Cover.X + (CoverW + Theme.Song.Cover.Padding) * (Count mod MaxCol);
        Self.Button[B].Y := Theme.Song.Cover.Y + (CoverH + Theme.Song.Cover.Padding) * (Line - Self.MinLine);
        if Index = Self.Interaction then
        begin
          if Self.Button[B].H < Theme.Song.Cover.ZoomThumbH then //zoom effect in 10 steps
          begin
            if Self.Button[B].H = CoverH then
              Self.LoadMainCover();

            Self.Button[B].H := Self.Button[B].H + ((Theme.Song.Cover.ZoomThumbH - CoverH) / 10);
            Self.Button[B].W := Self.Button[B].W + ((Theme.Song.Cover.ZoomThumbW - CoverW) / 10);
          end
          else //finished zoom effect
            Self.OnSongSelect();

          Self.Button[B].X := Self.Button[B].X - (Self.Button[B].W - CoverW) / 2;
          Self.Button[B].Y := Self.Button[B].Y - (Self.Button[B].H - CoverH) / 2;
          Self.Button[B].Z := 1;
        end
        else
        begin
          Self.Button[B].SetSelect(false);
          Self.Button[B].H := CoverH;
          Self.Button[B].W := CoverW;
          Self.Button[B].Z := 0.9;
        end
      end
      else //hide not visible songs upper than MinLine + MaxRow
      begin
        Self.UnloadCover(B);
        Self.Button[B].H := CoverH; //set H and W is needed with tabs on
        Self.Button[B].W := CoverW;
        Self.Button[B].Z := 0;
      end;
      Inc(Count);
    end
    else //hide not visible songs lower than MinLine
    begin
      Self.UnloadCover(B);
      Self.Button[B].H := CoverH; //set H and W is needed with tabs on
      Self.Button[B].W := CoverW;
      Self.Button[B].Z := 0;
    end;
    Inc(Index);
  end;
  if not Self.Button[Self.Interaction].Visible then
  begin
    Self.MinLine := Ceil((USongs.CatSongs.FindVisibleIndex(Self.Interaction) + 1 - MaxCol * MaxRow) / MaxCol);
    if (Line - Self.MinLine) > MaxRow then //to decrease line when push up (or pag up) key
      Self.MinLine += MaxRow - 1;

    if Self.MinLine < 0 then //to mantain songs on top when use random song in category
      Self.MinLine := 0;
  end;
end;

procedure TScreenSong.SetCarouselScroll;
var
  B, VisibleIndex: integer;
  X: real;
begin
  VisibleIndex := 0;
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
    if Self.Button[B].Visible then
    begin
      X := Theme.Song.Cover.X + (VisibleIndex - Self.SongCurrent) * (Theme.Song.Cover.W + Theme.Song.Cover.Padding);
      Inc(VisibleIndex);
      if not ((X < -Theme.Song.Cover.W) or (X > 800)) then
        Self.LoadCover(B)
      else //hide not visible songs
        Self.UnloadCover(B);

      Self.Button[B].H := Theme.Song.Cover.H;
      Self.Button[B].W := Theme.Song.Cover.W;
      Self.Button[B].X := X; //after load cover to avoid cover flash on change
      Self.Button[B].Y := Theme.Song.Cover.Y;
      Self.Button[B].Z := 0.95; //more than 0.9 to be clicked with mouse and less than 1 to hide reflection
    end;
  end;
end;

procedure TScreenSong.SetSlotMachineScroll;
var
  B, VS, VisibleIndex: integer;
  Angle, Pos:  real;
begin
  VS := USongs.CatSongs.GetVisibleSongs();
  VisibleIndex := 0;
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
    if Self.Button[B].Visible then
    begin
      Pos := (VisibleIndex - Self.SongCurrent);
      Inc(VisibleIndex);
      if (Pos < -VS/2) then
        Pos := Pos + VS
      else if (Pos > VS/2) then
        Pos := Pos - VS;

      if (Abs(Pos) < 2.0) then
      begin
        Self.LoadCover(B);
        Angle := Pi * (Pos / 5);
        Self.Button[B].Texture.Alpha := 1 - Abs(Pos / 1.5);
        Self.Button[B].H := Abs(Theme.Song.Cover.H * cos(Angle * 1.2));
        Self.Button[B].W := Self.Button[B].H;
        Self.Button[B].X := (Theme.Song.Cover.X  + (Theme.Song.Cover.H - Abs(Theme.Song.Cover.H * cos(Angle))) * 0.8);
        Self.Button[B].Y := Theme.Song.Cover.Y + Theme.Song.Cover.W * (Sin(Angle * 1.3) * 0.8) - ((Self.Button[B].H - Theme.Song.Cover.H) / 2);
        Self.Button[B].Z := 1;
        Self.Button[B].DeSelectReflectionspacing := 15 * Self.Button[B].H / Theme.Song.Cover.H;
      end
      else
        Self.UnloadCover(B);
    end;
  end;
end;

{* Coverflow effect *}
procedure TScreenSong.SetSlideScroll;
var
  B, Position, VisibleIndex, VisibleCovers: integer;
  PaddingIncrementX, RightX, Scale, Steps: real;
  FirstCover, LastCover, LeftCover, VisibleCover: boolean;
begin
  VisibleIndex := 0; //counter of visible covers
  VisibleCovers := IfThen(USongs.CatSongs.GetVisibleSongs() <= 11, 5, 7); //5 visible covers in each side plus 2 in background to improve the scroll effect
  Scale := 0.95; //scale to reduce size or inclination of side covers
  Steps := Floor(UIni.Ini.MaxFramerate * 15 / 60); //number of steps for animations
  RightX := (Theme.Song.Cover.W + (Theme.Song.Cover.W - Theme.Song.Cover.W * Scale)) / 2; //correction on X for right covers
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
    if Self.Button[B].Visible then
    begin
      VisibleCover := (VisibleIndex >= Self.SongTarget - VisibleCovers) and (VisibleIndex <= Self.SongTarget + VisibleCovers); //visible songs
      LastCover := (not VisibleCover) and (VisibleIndex < VisibleCovers); //last cover of list
      FirstCover := (not VisibleCover) and (not LastCover) and (VisibleIndex >= USongs.CatSongs.GetVisibleSongs() - VisibleCovers); //first covers of list
      if VisibleCover or LastCover or FirstCover then
      begin
        Self.LoadCover(B);
        Self.Button[B].SetSelect(true);
        Self.Button[B].Y := Theme.Song.Cover.Y;
        Self.Button[B].Z := 0.96;
        if B = Self.Interaction then //main cover
        begin
          Self.Button[B].Reflection := false;
          if //animation from left or right to central position using texture scale, height and width
            (not SameValue(Self.Button[B].H, Theme.Song.Cover.H))
            and (not SameValue(Self.Button[B].X, Theme.Song.Cover.X)) //don't animate if have the initial position
            and (not SameValue(Self.SongCurrent, 0, 0.002)) //to set initial position after apply a filter
          then
          begin
            Self.Button[B].H := Self.Button[B].H + (Theme.Song.Cover.H - Theme.Song.Cover.H * Scale) / Steps;
            Self.Button[B].W := Self.Button[B].W + (Theme.Song.Cover.W - (Theme.Song.Cover.W * Scale) / 2) / Steps;

            //fix horizontal position to start always from same place
            if Self.Button[B].X > Theme.Song.Cover.X + Theme.Song.Cover.Padding + RightX then //right position
              Self.Button[B].X := Theme.Song.Cover.X + Theme.Song.Cover.Padding + RightX
            else if Self.Button[B].X < Theme.Song.Cover.X - Theme.Song.Cover.Padding then //left position
              Self.Button[B].X := Theme.Song.Cover.X - Theme.Song.Cover.Padding;

            //fix scale because sometimes fails animation to leave after cancel a filter
            if (Self.Button[B].Texture.LeftScale = 1) and (Self.Button[B].Texture.RightScale = 1) then
              if CompareValue(Self.Button[B].X, Theme.Song.Cover.X) < 1 then
                Self.Button[B].Texture.RightScale := Scale
              else
                Self.Button[B].Texture.LeftScale := Scale;

            if Self.Button[B].Texture.LeftScale < 1 then //right covers
            begin
              Self.Button[B].X := Self.Button[B].X - (Theme.Song.Cover.Padding + RightX) / Steps;
              Self.Button[B].Texture.LeftScale += (1 - Scale) / Steps;
            end
            else if Self.Button[B].Texture.RightScale < 1 then //left covers
            begin
              Self.Button[B].X := Self.Button[B].X + Theme.Song.Cover.Padding / Steps;
              Self.Button[B].Texture.RightScale += (1 - Scale) / Steps;
            end
          end
          else //initial or final position
          begin
            Self.Button[B].H := Theme.Song.Cover.H;
            Self.Button[B].W := Theme.Song.Cover.W;
            Self.Button[B].X := Theme.Song.Cover.X;
            Self.Button[B].Texture.LeftScale := 1;
            Self.Button[B].Texture.RightScale := 1;
          end
        end
        else //left and right covers
        begin
          Self.Button[B].Reflection := true;
          Self.Button[B].X := Theme.Song.Cover.X;
          LeftCover := ((VisibleIndex < Self.SongTarget) and (not LastCover)) or FirstCover;
          if LeftCover then //put first covers under following
            Self.Button[B].Z := Self.Button[B].Z - (Self.SongTarget - VisibleIndex + IfThen(FirstCover, USongs.CatSongs.GetVisibleSongs(), 0)) * 0.01
          else //put last covers under previous
            Self.Button[B].Z := Self.Button[B].Z - (VisibleIndex - Self.SongTarget + IfThen(LastCover, USongs.CatSongs.GetVisibleSongs(), 0)) * 0.01;

          PaddingIncrementX := VisibleIndex - Self.SongCurrent;
          if not VisibleCover then
            PaddingIncrementX += USongs.CatSongs.GetVisibleSongs() * IfThen(FirstCover, -1, 1);

          if //animation from central to left or right position using texture scale, height and width
            (not SameValue(Self.Button[B].H, Theme.Song.Cover.H * Scale))
            and (not SameValue(Self.SongTarget, Self.SongCurrent, 0.002)) //avoid initial state or after quit a filter
            and ( //avoid animation whit a few songs (less than VisibleCovers) and reach the end of the list
              ((USongs.CatSongs.GetVisibleSongs() > VisibleCovers) )
              or (not (
                ((Self.SongTarget = USongs.CatSongs.GetVisibleSongs() - 1) and (VisibleIndex = 0))
                or ((Self.SongTarget = 0) and (VisibleIndex = USongs.CatSongs.GetVisibleSongs() - 1))
              ))
            )
          then
          begin
            Self.Button[B].H := Self.Button[B].H - (Theme.Song.Cover.H - Theme.Song.Cover.H * Scale) / Steps;
            Self.Button[B].W := Self.Button[B].W - (Theme.Song.Cover.W - (Theme.Song.Cover.W * Scale) / 2) / Steps;
            if LeftCover then
            begin
              Self.Button[B].X := Self.Button[B].X + Theme.Song.Cover.Padding * PaddingIncrementX;
              Self.Button[B].Texture.RightScale -= (1 - Scale) / Steps;
            end
            else
            begin
              Self.Button[B].X := Self.Button[B].X + (Theme.Song.Cover.W * Scale) * PaddingIncrementX;
              Self.Button[B].Texture.LeftScale -= (1 - Scale) / Steps;
            end
          end
          else //initial position
          begin
            Self.Button[B].H := Theme.Song.Cover.H * Scale;
            Self.Button[B].W := (Theme.Song.Cover.W * Scale) / 2;
            Self.Button[B].X := Self.Button[B].X + Theme.Song.Cover.Padding * PaddingIncrementX;
            if LeftCover then
            begin
              Self.Button[B].Texture.LeftScale := 1;
              Self.Button[B].Texture.RightScale := Scale;
            end
            else
            begin
              Self.Button[B].X := Self.Button[B].X + RightX;
              Self.Button[B].Texture.LeftScale := Scale;
              Self.Button[B].Texture.RightScale := 1;
            end
          end
        end
      end
      else //hide not visible songs
        Self.UnloadCover(B);

      Inc(VisibleIndex);
    end
    else //reset height when a filter is applied to return to song initial position after cancel it
    begin
      Self.UnloadCover(B);
      Self.Button[B].H := Theme.Song.Cover.H * Scale;
    end;
  end;
end;

procedure TScreenSong.SetListScroll;
var
  B, Line, I, Current:  integer;
  Alpha: real;
begin
  Current := USongs.CatSongs.FindVisibleIndex(Self.Interaction);
  //move up at the start of list or in the rest of it
  if (Current < Self.MinLine) and ((Current < Theme.Song.Cover.Rows) or (Current <= Self.LastMinLine)) then
    Self.MinLine := Current
  //move down in the tail of list or in the rest of it
  else if (Current - Theme.Song.Cover.Rows >= Self.MinLine) and ((Current > USongs.CatSongs.GetVisibleSongs() - Theme.Song.Cover.Rows) or (Current > Self.LastMinLine)) then
    Self.MinLine := Current - Theme.Song.Cover.Rows + 1;

  Self.LastMinLine := Self.MinLine;

  // save first category
  if USongs.CatSongs.Song[Interaction].Main then
    Self.MainListFirstVisibleSongIndex := 0;

  for I := 0 to High(Self.StaticsList) do
  begin
    Self.Text[ListTextArtist[I]].Text := '';
    Self.Text[ListTextTitle[I]].Text := '';
    Self.Text[ListTextYear[I]].Text := '';
    Self.Statics[ListVideoIcon[I]].Visible := false;
    Self.Statics[ListMedleyIcon[I]].Visible := false;
    Self.Statics[ListCalcMedleyIcon[I]].Visible := false;
    Self.Statics[ListDuetIcon[I]].Visible := false;
    Self.Statics[ListRapIcon[I]].Visible := false;
    Self.StaticsList[I].Texture.TexNum := Self.StaticsList[I].TextureDeSelect.TexNum;
    Self.StaticsList[I].Texture.W := Theme.Song.ListCover.W;
    Self.StaticsList[I].Texture.H := Theme.Song.ListCover.H;
    Self.StaticsList[I].Texture.X := Theme.Song.ListCover.X;
  end;

  Line := 0;
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := CatSongs.Song[B].Visible;
    if (Self.Button[B].Visible) then
    begin
      if (Line >= Self.MinLine) and (Line - Self.MinLine < Theme.Song.ListCover.Rows) then
      begin
        I := Line - Self.MinLine;
        if I = 0 then
          Self.ListFirstVisibleSongIndex := B;

        Self.LoadCover(B);
        Self.Button[B].H := Theme.Song.Cover.H;
        Self.Button[B].W := Theme.Song.Cover.W;
        Self.Button[B].X := Theme.Song.Cover.X;
        Self.Button[B].Y := Theme.Song.Cover.Y + I * (Theme.Song.Cover.H + Theme.Song.Cover.Padding);
        Self.Button[B].Z := 1;
        if (B = Self.Interaction) then
        begin
          Alpha := 1;
          Self.StaticsList[I].Texture.TexNum := Self.StaticsList[I].TextureSelect.TexNum;
        end
        else
        begin
          Self.Button[B].SetSelect(false);
          Alpha := 0.7;
          Self.StaticsList[I].Texture.TexNum := Self.StaticsList[I].TextureDeSelect.TexNum;
        end;
        Self.Statics[ListVideoIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[ListVideoIcon[I]].Visible := USongs.CatSongs.Song[B].Video.IsSet;
        Self.Statics[ListMedleyIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[ListMedleyIcon[I]].Visible := (USongs.CatSongs.Song[B].Medley.Source = msTag) and not CatSongs.Song[Interaction].isDuet;
        Self.Statics[ListCalcMedleyIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[ListCalcMedleyIcon[I]].Visible := (USongs.CatSongs.Song[B].Medley.Source = msCalculated) and not CatSongs.Song[Interaction].isDuet;
        Self.Statics[ListDuetIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[ListDuetIcon[I]].Visible := USongs.CatSongs.Song[B].isDuet;
        Self.Statics[ListRapIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[ListRapIcon[I]].Visible := USongs.CatSongs.Song[B].hasRap;
        Self.Text[ListTextArtist[I]].Alpha := Alpha;
        Self.Text[ListTextArtist[I]].Text := USongs.CatSongs.Song[B].Artist;
        Self.Text[ListTextTitle[I]].Alpha := Alpha;
        Self.Text[ListTextTitle[I]].Text := USongs.CatSongs.Song[B].Title;
        Self.Text[ListTextYear[I]].Alpha := Alpha;
        Self.Text[ListTextYear[I]].Text := IfThen(((UIni.Ini.Tabs = 0) or (TSortingType(UIni.Ini.Sorting) <> sYear)) and (USongs.CatSongs.Song[B].Year <> 0), IntToStr(USongs.CatSongs.Song[B].Year), '');
      end
      else
        Self.UnloadCover(B);

      Inc(Line);
    end;
  end;
  Self.LoadMainCover();
end;

procedure TScreenSong.OnShow();
var
  I: integer;
  Visible: boolean;
begin
  inherited;
  if not Assigned(UGraphic.ScreenSongMenu) then //load the screens only the first time
  begin
    UGraphic.ScreenSongMenu := TScreenSongMenu.Create();
    UGraphic.ScreenSongJumpto := TScreenSongJumpto.Create();
    UGraphic.ScreenPopupScoreDownload := TScreenPopupScoreDownload.Create();
  end;

  Self.CloseMessage();

  if (TSongMenuMode(Ini.SongMenu) <> smList) then
  begin
    for I := 0 to High(StaticsList) do
    begin
      StaticsList[StaticList[I]].Visible := false;
      Text[ListTextArtist[I]].Visible := false;
      Text[ListTextTitle[I]].Visible  := false;
      Text[ListTextYear[I]].Visible   := false;
      Statics[ListVideoIcon[I]].Visible  := false;
      Statics[ListMedleyIcon[I]].Visible := false;
      Statics[ListCalcMedleyIcon[I]].Visible := false;
      Statics[ListDuetIcon[I]].Visible := false;
      Statics[ListRapIcon[I]].Visible := false;
    end;
    Text[TextArtist].Visible := true;
    Text[TextTitle].Visible  := true;
    Text[TextYear].Visible   := true;
    Statics[VideoIcon].Visible  := true;
    Statics[MedleyIcon].Visible := true;
    Statics[CalcMedleyIcon].Visible := true;
    Statics[DuetIcon].Visible := true;
    Statics[RapIcon].Visible := true;
  end
  else
  begin
    for I := 0 to High(StaticsList) do
    begin
      StaticsList[StaticList[I]].Visible := true;
      Text[ListTextArtist[I]].Visible := true;
      Text[ListTextTitle[I]].Visible  := true;
      Text[ListTextYear[I]].Visible   := true;
      Statics[ListVideoIcon[I]].Visible  := true;
      Statics[ListMedleyIcon[I]].Visible := true;
      Statics[ListCalcMedleyIcon[I]].Visible := true;
      Statics[ListDuetIcon[I]].Visible := true;
      Statics[ListRapIcon[I]].Visible := true;
    end;
    Text[TextArtist].Visible := false;
    Text[TextTitle].Visible  := false;
    Text[TextYear].Visible   := false;
    Statics[VideoIcon].Visible  := false;
    Statics[MedleyIcon].Visible := false;
    Statics[CalcMedleyIcon].Visible := false;
    Statics[DuetIcon].Visible := false;
    Statics[RapIcon].Visible := false;
  end;

  // for duet names
  ScreenSong.ColPlayer[0] := GetPlayerColor(Ini.SingColor[0]);
  ScreenSong.ColPlayer[1] := GetPlayerColor(Ini.SingColor[1]);
  ScreenSong.ColPlayer[2] := GetPlayerColor(Ini.SingColor[2]);
  ScreenSong.ColPlayer[3] := GetPlayerColor(Ini.SingColor[3]);
  ScreenSong.ColPlayer[4] := GetPlayerColor(Ini.SingColor[4]);
  ScreenSong.ColPlayer[5] := GetPlayerColor(Ini.SingColor[5]);

  {**
   * Pause background music
   *}
  SoundLib.PauseBgMusic;

  if SongIndex <> Interaction then
    AudioPlayback.Stop;

  PreviewOpened := -1;

  // reset video playback engine
  fCurrentVideo := nil;

  // reset Medley-Playlist
  SetLength(PlaylistMedley.Song, 0);
  MakeMedley := false;

  if Mode = smMedley then
    Mode := smNormal;

  if Ini.Players <= 3 then PlayersPlay := Ini.Players + 1;
  if Ini.Players  = 4 then PlayersPlay := 6;

  //Cat Mod etc
  if (UIni.Ini.Tabs = 1) and (CatSongs.CatNumShow = -1) then
  begin
    USongs.CatSongs.ShowCategoryList();
    //FIXME small trick to fix scroll in some modes when enter after first time with a category selected in the middle of the list
    Self.SelectNext();
    Self.SelectPrev();
  end
  else //initialize visible songs
    USongs.CatSongs.SetVisibleSongs();

  Self.SetScroll(true);

  //Playlist Mode
  if not(Mode = smPartyClassic) then
  begin
    //If Playlist Shown -> Select Next automatically
    if not(Mode = smPartyFree) and (CatSongs.CatNumShow = -3) then
    begin
      SelectNext;
    end;
  end
  //Party Mode
  else
  begin
    SelectRandomSong;
    //Show Menu directly in PartyMode
    //But only if selected in Options
    if (Ini.PartyPopup = 1) then
    begin
      ScreenSongMenu.MenuShow(SM_Party_Main);
    end;
  end;

  if (ScreenSong.Mode = smJukebox) and (Ini.PartyPopup = 1) then
    ScreenSongMenu.MenuShow(SM_Jukebox);

  Self.IsScrolling := false;
  Self.SetJoker();

  //Set Visibility of Party Statics and Text
  Visible := (Mode = smPartyClassic);
  for I := 0 to High(StaticParty) do
    Statics[StaticParty[I]].Visible := Visible;

  for I := 0 to High(TextParty) do
    Text[TextParty[I]].Visible := Visible;

  //Set Visibility of Non Party Statics and Text
  Visible := not Visible;
  for I := 0 to High(StaticNonParty) do
    Statics[StaticNonParty[I]].Visible := Visible;

  for I := 0 to High(TextNonParty) do
    Text[TextNonParty[I]].Visible := Visible;
end;

procedure TScreenSong.OnShowFinish;
begin
  DuetChange := false;
  Self.IsScrolling := true;
  CoverTime := 10;
  //if (Mode = smPartyTournament) then
  //  PartyTime := SDL_GetTicks();
end;

procedure TScreenSong.OnHide;
begin
  // turn music volume to 100%
  AudioPlayback.SetVolume(1.0);

  // stop preview
  StopMusicPreview();
  StopVideoPreview();
end;

function TScreenSong.Draw: boolean;
var
  dx:         real;
  dt:         real;
  VideoAlpha: real;
  Position:   real;
  I, J:       integer;
begin

  FadeMessage();

  if Self.IsScrolling and not ((TSongMenuMode(Ini.SongMenu) in [smChessboard, smList, smMosaic])) then
  begin
    dx := SongTarget - SongCurrent;
    dt := TimeSkip * 7;

    if dt > 1 then
      dt := 1;

    SongCurrent := SongCurrent + dx*dt;

    if (Self.SongCurrent = Self.SongTarget) then //if occurs an incomplete scroll add one chance to complete well
      SongCurrent := SongTarget - 0.002
    else if
      SameValue(Self.SongCurrent, Self.SongTarget, 0.002)
      and SameValue(Self.Button[Self.Interaction].X, Theme.Song.Cover.X, 1) //to complete animation always in smSlide
      and (USongs.CatSongs.GetVisibleSongs() > 0)
    then
      Self.OnSongSelect();
  end
  else //start to preload covers
    USongs.Songs.PreloadCovers(true);

  Self.SetScroll();

  if (AudioPlayback.Finished) then
    CoverTime := 0;

  //Fading Functions, Only if Covertime is under 5 Seconds
  if (TSongMenuMode(Ini.SongMenu) in [smChessboard, smMosaic, smList]) then
  begin
    if not(Assigned(fCurrentVideo)) then
      Statics[Self.MainCover].Texture.Alpha := 1
    else if (CoverTime < 9) then
    begin
        //Update Fading Time
      CoverTime := CoverTime + TimeSkip;

      //Update Fading Texture
      Statics[Self.MainCover].Texture.Alpha := 1 - (CoverTime - 1) * 1.5;
      if Statics[Self.MainCover].Texture.Alpha < 0 then
        Statics[Self.MainCover].Texture.Alpha := 0;
    end;
  end
  else
  begin
    // cover fade
    if (CoverTime < 9) then
    begin
      {if (CoverTime < 1) and (CoverTime + TimeSkip >= 1) then
      begin
        // load new texture
        //Texture.LoadTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN);
        Button[Interaction].Texture.Alpha := 1;
        Button[Interaction].Texture2 := Texture.LoadTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN);
        Button[Interaction].Texture2.Alpha := 1;
      end;}

      //Update Fading Time
      CoverTime := CoverTime + TimeSkip;

      {//Update Fading Texture
      Button[Interaction].Texture2.Alpha := (CoverTime - 1) * 1.5;
      if Button[Interaction].Texture2.Alpha > 1 then
        Button[Interaction].Texture2.Alpha := 1;
    }end;
  end;

  //inherited Draw;
  //heres a little Hack, that causes the Statics
  //are Drawn after the Buttons because of some Blending Problems.
  //This should cause no Problems because all Buttons on this screen
  //Has Z Position.
  //Draw BG
  DrawBG;

  // StaticsList
  for I := 0 to Length(StaticsList) - 1 do
  begin
    StaticsList[I].Draw;
  end;

  // Jukebox Playlist
  if (Mode = smJukebox) then
  begin
    if Length(ScreenJukebox.JukeboxSongsList) > Theme.Song.TextMedleyMax then
      J := Length(ScreenJukebox.JukeboxSongsList) - Theme.Song.TextMedleyMax
    else
      J := 0;

    for I := 0 to Theme.Song.TextMedleyMax - 1 do
    begin
      if (Length(ScreenJukebox.JukeboxSongsList) > I + J) then
      begin
        Text[TextMedleyArtist[I]].Visible := true;
        Text[TextMedleyTitle[I]].Visible  := true;
        Text[TextMedleyNumber[I]].Visible := true;
        Statics[StaticMedley[I]].Visible  := true;

        Text[TextMedleyNumber[I]].Text := IntToStr(I + 1 + J);
        Text[TextMedleyArtist[I]].Text := CatSongs.Song[ScreenJukebox.JukeboxSongsList[I + J]].Artist;
        Text[TextMedleyTitle[I]].Text  := CatSongs.Song[ScreenJukebox.JukeboxSongsList[I + J]].Title;
      end
      else
      begin
        Text[TextMedleyArtist[I]].Visible := false;
        Text[TextMedleyTitle[I]].Visible  := false;
        Text[TextMedleyNumber[I]].Visible := false;
        Statics[StaticMedley[I]].Visible  := false;
      end;
    end;
  end
  else
  begin

    //Medley Playlist
    if Length(PlaylistMedley.Song) > Theme.Song.TextMedleyMax then
      J := Length(PlaylistMedley.Song) - Theme.Song.TextMedleyMax
    else
      J := 0;

    for I := 0 to Theme.Song.TextMedleyMax - 1 do
    begin
      if (Length(PlaylistMedley.Song) > I + J) and (MakeMedley) then
      begin
        Text[TextMedleyArtist[I]].Visible := true;
        Text[TextMedleyTitle[I]].Visible  := true;
        Text[TextMedleyNumber[I]].Visible := true;
        Statics[StaticMedley[I]].Visible  := true;

        Text[TextMedleyNumber[I]].Text := IntToStr(I + 1 + J);
        Text[TextMedleyArtist[I]].Text := CatSongs.Song[PlaylistMedley.Song[I + J]].Artist;
        Text[TextMedleyTitle[I]].Text  := CatSongs.Song[PlaylistMedley.Song[I + J]].Title;
      end
      else
      begin
        Text[TextMedleyArtist[I]].Visible := false;
        Text[TextMedleyTitle[I]].Visible  := false;
        Text[TextMedleyNumber[I]].Visible := false;
        Statics[StaticMedley[I]].Visible  := false;
      end;
    end;
  end;

  if (TSongMenuMode(Ini.SongMenu) in [smRoulette, smCarousel, smSlotMachine, smSlide])  then
    VideoAlpha := Button[interaction].Texture.Alpha * (CoverTime-1)
  else
    VideoAlpha := 1;

  //Instead of Draw FG Procedure:
  //We draw Buttons for our own
  for I := 0 to Length(Button) - 1 do
  begin
    if (TSongMenuMode(Ini.SongMenu) in [smChessboard, smMosaic, smList]) or (((I<>Interaction) or not Assigned(fCurrentVideo) or (VideoAlpha<1) or AudioPlayback.Finished)) then
        Button[I].Draw;
  end;

  //  StopVideoPreview;

  Position := AudioPlayback.Position;

  if Assigned(fCurrentVideo) then
  begin
    // Just call this once
    // when Screens = 2
    if (ScreenAct = 1) then
      fCurrentVideo.GetFrame(CatSongs.Song[Interaction].VideoGAP + Position);

    fCurrentVideo.SetScreen(ScreenAct);
    fCurrentVideo.Alpha := VideoAlpha;

    //set up window
    if (TSongMenuMode(Ini.SongMenu) in [smChessboard, smMosaic, smList]) then
    begin
        fCurrentVideo.SetScreenPosition(Theme.Song.Cover.SelectX, Theme.Song.Cover.SelectY, 1);
        fCurrentVideo.Width := Theme.Song.Cover.SelectW;
        fCurrentVideo.Height := Theme.Song.Cover.SelectH;

        fCurrentVideo.ReflectionSpacing := Theme.Song.Cover.SelectReflectionSpacing;
    end
    else
    begin
      with Button[interaction] do
      begin
        fCurrentVideo.SetScreenPosition(X, Y, Z);
        fCurrentVideo.Width := W;
        fCurrentVideo.Height := H;
        fCurrentVideo.ReflectionSpacing := Reflectionspacing;
      end;
    end;

    fCurrentVideo.AspectCorrection := acoCrop;

    fCurrentVideo.Draw;

    if Button[interaction].Reflection or (Theme.Song.Cover.SelectReflection) then
      fCurrentVideo.DrawReflection;
  end;

  // duet names
  if (CatSongs.Song[Interaction].isDuet) then
    ColorDuetNameSingers();

  // Statics
  for I := 0 to Length(Statics) - 1 do
    Statics[I].Draw;

  // and texts
  for I := 0 to Length(Text) - 1 do
    Text[I].Draw;

  Equalizer.Draw;

  //Draw Song Menu
  if ScreenSongMenu.Visible then
    ScreenSongMenu.Draw
  else if ScreenSongJumpto.Visible then
    ScreenSongJumpto.Draw;

  //if (Mode = smPartyTournament) then
  //  PartyTimeLimit();

  Result := true;
end;

procedure TScreenSong.SelectNext();
begin
  if USongs.CatSongs.GetVisibleSongs() > 0 then
  begin
    if not Self.IsScrolling then
      Self.OnSongDeselect();

    //try to keep all at the beginning when a filter is applied
    if Self.SongTarget + 1 = USongs.CatSongs.GetVisibleSongs() then //go to initial song if reach the end of subselection list with fast movements
    begin
      Self.SongTarget := 0;
      Self.SongCurrent := -1;
    end
    else if (USongs.CatSongs.GetVisibleSongs() - 1 < High(USongs.CatSongs.Song)) and (Round(Self.SongTarget) = Self.Interaction) then
    begin
      Self.SongTarget := Round(Self.SongCurrent + 1); //translate SongTarget from regular to new position after apply a filter
      if Self.SongTarget = USongs.CatSongs.GetVisibleSongs() then //go to initial song if reach the end of subselection list with slow movements
      begin
        Self.SongTarget := 0;
        Self.SongCurrent := -1;
      end
    end
    else
      Self.SongTarget := Self.SongTarget + 1;

    Self.Interaction := USongs.CatSongs.FindNextVisible(Self.Interaction);
  end;
end;

procedure TScreenSong.SelectPrev;
begin
  if (USongs.CatSongs.GetVisibleSongs() > 0) then
  begin
    if not Self.IsScrolling then
      Self.OnSongDeselect();

    //try to keep all at the beginning when a filter is applied
    if Self.SongTarget - 1 < 0 then //go to final song if reach the start of subselection list with fast movements
    begin
      Self.SongTarget := USongs.CatSongs.GetVisibleSongs() - 1;
      Self.SongCurrent := USongs.CatSongs.GetVisibleSongs();
    end
    else if (USongs.CatSongs.GetVisibleSongs() - 1 < High(USongs.CatSongs.Song)) and (Round(Self.SongTarget) = Self.Interaction) then
    begin
      Self.SongTarget := Round(Self.SongCurrent - 1); //translate SongTarget from regular to new position after apply a filter
      if Self.SongTarget < 0 then //go to final song if reach the start of subselection list with slow movements
      begin
        Self.SongTarget := USongs.CatSongs.GetVisibleSongs() - 1;
        Self.SongCurrent := USongs.CatSongs.GetVisibleSongs();
      end;
    end
    else
      Self.SongTarget := Self.SongTarget - 1;

    Self.Interaction := USongs.CatSongs.FindPreviousVisible(Self.Interaction);
  end;
end;

procedure TScreenSong.SelectNextRow;
var
  Skip, SongIndexRow: integer;
begin
  if USongs.CatSongs.GetVisibleSongs() > 0 then
  begin
    if not Self.IsScrolling then
      Self.OnSongDeselect();

    Skip := 0;
    SongIndexRow := Interaction;

    while ((Skip <= Theme.Song.Cover.Cols) and (SongIndexRow < Length(CatSongs.Song))) do
    begin
      if (CatSongs.Song[SongIndexRow].Visible) then
      begin
        Inc(Skip);
      end;

      Inc(SongIndexRow);
    end;

    Self.SongTarget += 1;
    if (USongs.CatSongs.Song[SongIndexRow - 1].Visible) then
      Self.Interaction := SongIndexRow - 1;
  end;
end;

procedure TScreenSong.SelectPrevRow;
var
  Skip, SongIndexRow: integer;
begin
  if (USongs.CatSongs.GetVisibleSongs() > 0) then
  begin
    if not Self.IsScrolling then
      Self.OnSongDeselect();

    Skip := 0;
    SongIndexRow := Interaction;

    while ((Skip <= Theme.Song.Cover.Cols) and (SongIndexRow > -1)) do
    begin
      if (CatSongs.Song[SongIndexRow].Visible) then
      begin
        Inc(Skip);
      end;

      Dec(SongIndexRow);
    end;

    SongTarget -= 1;
    if (USongs.CatSongs.Song[SongIndexRow + 1].Visible) then
      Self.Interaction := SongIndexRow + 1;
  end;
end;

procedure TScreenSong.StartMusicPreview();
var
  Song: TSong;
  PreviewPos: real;
begin
  if SongIndex <> -1 then
  begin
    PreviewOpened := SongIndex;
    Exit;
  end;

  AudioPlayback.Close();

  if USongs.CatSongs.GetVisibleSongs() = 0 then
    Exit;

  Song := CatSongs.Song[Interaction];
  if not assigned(Song) then
    Exit;

  //fix: if main cat than there is nothing to play
  if Song.main then
    Exit;

  PlayMidi := false;
  if AudioPlayback.Open(Song.Path.Append(Song.Mp3)) then
  begin
    PreviewOpened := Interaction;

    // preview start is either calculated (by finding the chorus) or pre-set, use it
    if (Song.PreviewStart > 0.0) and InRange(Song.PreviewStart, 0.0, AudioPlayback.Length) then
      PreviewPos := Song.PreviewStart
    else
    begin // otherwise, fallback to simple preview calculation
      PreviewPos := AudioPlayback.Length / 4;
      // fix for invalid music file lengths
      if (PreviewPos > 120.0) then PreviewPos := 60.0;
    end;

    AudioPlayback.Position := PreviewPos;

    // set preview volume
    if Ini.PreviewFading = 0 then
    begin
      // music fade disabled: start with full volume
      AudioPlayback.SetVolume(IPreviewVolumeVals[Ini.PreviewVolume]);
      AudioPlayback.Play()
    end
    else
    begin
      // music fade enabled: start muted and fade-in
      AudioPlayback.SetVolume(0);
      AudioPlayback.FadeIn(Ini.PreviewFading, IPreviewVolumeVals[Ini.PreviewVolume]);
    end;
  end;
end;

procedure TScreenSong.StopMusicPreview();
begin
  // Stop preview of previous song
  AudioPlayback.Stop;
end;

procedure TScreenSong.StartVideoPreview();
var
  VideoFile:  IPath;
  Song:       TSong;

begin
  if (Ini.VideoPreview=0)  then
    Exit;

  Self.StopVideoPreview();

  //if no audio open => exit
  if (PreviewOpened = -1) then
    Exit;

  if USongs.CatSongs.GetVisibleSongs() = 0 then
    Exit;

  Song := CatSongs.Song[Interaction];
  if not assigned(Song) then
    Exit;

  //fix: if main cat than there is nothing to play
  if Song.main then
    Exit;

  VideoFile := Song.Path.Append(Song.Video);
  if (Song.Video.IsSet) and VideoFile.IsFile then
  begin
    fCurrentVideo := VideoPlayback.Open(VideoFile);
    if (fCurrentVideo <> nil) then
    begin
      fCurrentVideo.Position := Song.VideoGAP + AudioPlayback.Position;
      fCurrentVideo.Play;
    end;
  end;
end;

procedure TScreenSong.StopVideoPreview();
begin
  // Stop video preview of previous song
  if Assigned(fCurrentVideo) then
  begin
    fCurrentVideo.Stop();
    fCurrentVideo := nil;
  end;
end;

// Changes previewed song
procedure TScreenSong.ChangeMusic;
begin
  StopMusicPreview();
  StopVideoPreview();
  PreviewOpened := -1;
  StartMusicPreview();
  StartVideoPreview();
end;

{* Move directly to a position of the song list *}
procedure TScreenSong.SkipTo(Target: cardinal; Force: boolean = false);
begin
  Self.Interaction := IfThen(USongs.CatSongs.IsFilterApplied(), USongs.CatSongs.FindGlobalIndex(Target), Target);
  Self.SongTarget := Target;
  if Force then //sometimes if needed to force scroll (tabs on, playlist modes, etc.)
    Self.SongCurrent := Target;

  Self.OnSongDeSelect();
end;

procedure TScreenSong.SelectRandomSong;
  procedure SkipToNoDuet();
  var
    Count, RealTarget, Target: Integer;
  begin
    if (Mode = smPartyClassic) then
    begin
      repeat
        Target := Random(USongs.CatSongs.GetVisibleSongs());
        RealTarget := -1;
        Count := -1;
        repeat
          Inc(RealTarget);
          if (CatSongs.Song[RealTarget].Visible) then
            Inc(Count);
        until (Count = Target);
      until not(CatSongs.Song[RealTarget].isDuet);
    end
    else
      Target := Random(USongs.CatSongs.GetVisibleSongs());

    Self.SkipTo(Target);
  end;
var
  I, I2: integer;
begin
  case PlayListMan.Mode of
      smAll:  // all songs just select random song
        begin
          // when tabs are activated then use tab method
          if (UIni.Ini.Tabs = 1) then
          begin
            repeat
              I2 := Low(CatSongs.Song) + Random(High(CatSongs.Song) + 1 - Low(CatSongs.Song));
            until CatSongs.Song[I2].Main = false;

            // search cat
            for I := I2 downto Low(CatSongs.Song) do
            begin
              if CatSongs.Song[I].Main and (PermitCategory(I)) then
                break;
            end;
            // I is the cat number, I2 is the no of the song within this cat

            // choose cat
            CatSongs.ShowCategoryList;

            // show cat in top left mod
            ShowCatTL(I);

            CatSongs.ClickCategoryButton(I);
            SelectNext;
          end;
          SkipToNoDuet();
        end;
      smCategory:  // one category select category and select random song
        begin
          CatSongs.ShowCategoryList;
          CatSongs.ClickCategoryButton(PlaylistMan.CurPlayList);
          ShowCatTL(PlaylistMan.CurPlayList);
          SkipToNoDuet();
        end;
      smPlaylist:  // playlist: select playlist and select random song
        begin
          PlaylistMan.SetPlayList(PlaylistMan.CurPlayList);
          SkipToNoDuet();
        end;
  end;
  SetScroll;
end;

function TScreenSong.PermitCategory(ID: integer): boolean;
var
  I, NextCat, Count: integer;
begin
  NextCat := -1;

  if Mode = smPartyClassic then
  begin
    for I := ID + 1 to High(CatSongs.Song) do
    begin
      if (CatSongs.Song[I].Main) then
      begin
        NextCat := I;
        Break;
      end;
    end;

    if (NextCat = -1) then
      NextCat := High(CatSongs.Song) + 1;

    Count := 0;
    for I := ID + 1 to NextCat - 1 do
    begin
      if not(CatSongs.Song[I].isDuet) then
      begin
        Inc(Count);
        Break;
      end;
    end;

    if (Count > 0) then
      Result := true
    else
      Result := false;
  end
  else
    Result := true;
end;

procedure TScreenSong.SetJoker;
begin
  // If Party Mode
  if Mode = smPartyClassic then //Show Joker that are available
  begin
    if (Length(Party.Teams) >= 1) then
    begin
      Statics[StaticTeam1Joker1].Visible := (Party.Teams[0].JokersLeft >= 1);
      Statics[StaticTeam1Joker2].Visible := (Party.Teams[0].JokersLeft >= 2);
      Statics[StaticTeam1Joker3].Visible := (Party.Teams[0].JokersLeft >= 3);
      Statics[StaticTeam1Joker4].Visible := (Party.Teams[0].JokersLeft >= 4);
      Statics[StaticTeam1Joker5].Visible := (Party.Teams[0].JokersLeft >= 5);
    end
    else
    begin
      Statics[StaticTeam1Joker1].Visible := false;
      Statics[StaticTeam1Joker2].Visible := false;
      Statics[StaticTeam1Joker3].Visible := false;
      Statics[StaticTeam1Joker4].Visible := false;
      Statics[StaticTeam1Joker5].Visible := false;
    end;

    if (Length(Party.Teams) >= 2) then
    begin
      Statics[StaticTeam2Joker1].Visible := (Party.Teams[1].JokersLeft >= 1);
      Statics[StaticTeam2Joker2].Visible := (Party.Teams[1].JokersLeft >= 2);
      Statics[StaticTeam2Joker3].Visible := (Party.Teams[1].JokersLeft >= 3);
      Statics[StaticTeam2Joker4].Visible := (Party.Teams[1].JokersLeft >= 4);
      Statics[StaticTeam2Joker5].Visible := (Party.Teams[1].JokersLeft >= 5);
    end
    else
    begin
      Statics[StaticTeam2Joker1].Visible := false;
      Statics[StaticTeam2Joker2].Visible := false;
      Statics[StaticTeam2Joker3].Visible := false;
      Statics[StaticTeam2Joker4].Visible := false;
      Statics[StaticTeam2Joker5].Visible := false;
    end;

    if (Length(Party.Teams) >= 3) then
    begin
      Statics[StaticTeam3Joker1].Visible := (Party.Teams[2].JokersLeft >= 1);
      Statics[StaticTeam3Joker2].Visible := (Party.Teams[2].JokersLeft >= 2);
      Statics[StaticTeam3Joker3].Visible := (Party.Teams[2].JokersLeft >= 3);
      Statics[StaticTeam3Joker4].Visible := (Party.Teams[2].JokersLeft >= 4);
      Statics[StaticTeam3Joker5].Visible := (Party.Teams[2].JokersLeft >= 5);
    end
    else
    begin
      Statics[StaticTeam3Joker1].Visible := false;
      Statics[StaticTeam3Joker2].Visible := false;
      Statics[StaticTeam3Joker3].Visible := false;
      Statics[StaticTeam3Joker4].Visible := false;
      Statics[StaticTeam3Joker5].Visible := false;
    end;
  end
  else
  begin //Hide all
    Statics[StaticTeam1Joker1].Visible := false;
    Statics[StaticTeam1Joker2].Visible := false;
    Statics[StaticTeam1Joker3].Visible := false;
    Statics[StaticTeam1Joker4].Visible := false;
    Statics[StaticTeam1Joker5].Visible := false;

    Statics[StaticTeam2Joker1].Visible := false;
    Statics[StaticTeam2Joker2].Visible := false;
    Statics[StaticTeam2Joker3].Visible := false;
    Statics[StaticTeam2Joker4].Visible := false;
    Statics[StaticTeam2Joker5].Visible := false;

    Statics[StaticTeam3Joker1].Visible := false;
    Statics[StaticTeam3Joker2].Visible := false;
    Statics[StaticTeam3Joker3].Visible := false;
    Statics[StaticTeam3Joker4].Visible := false;
    Statics[StaticTeam3Joker5].Visible := false;
  end;
end;

//Procedures for Menu
procedure TScreenSong.StartSong;
begin
  CatSongs.Selected := Interaction;

  if (Mode = smPartyFree) then
    Party.SaveSungPartySong(Interaction);

  StopMusicPreview();

  FadeTo(@ScreenSing);
end;

procedure TScreenSong.SelectPlayers;
begin
  CatSongs.Selected := Interaction;
  StopMusicPreview();

  ScreenName.Goto_SingScreen := true;
  FadeTo(@ScreenName);
end;

//Team No of Team (0-5)
procedure TScreenSong.DoJoker (Team: integer);
begin
  if (Mode = smPartyClassic) and
     (High(Party.Teams) >= Team) and
     (Party.Teams[Team].JokersLeft > 0) then
  begin
    //Use Joker
    Dec(Party.Teams[Team].JokersLeft);
    SelectRandomSong;
    SetJoker;
  end;
end;

{ Load a cover dynamically in a song button }
procedure TScreenSong.LoadCover(Const I: integer);
begin
  if Self.Button[I].Texture.TexNum = 0 then
  begin
    Self.Button[I].Texture := UTexture.Texture.LoadTexture(USongs.CatSongs.Song[I].Path.Append(USongs.CatSongs.Song[I].Cover));
    if Self.Button[I].Texture.TexNum = 0 then
      Self.Button[I].Texture := Self.DefaultCover;
  end;
end;

{ Unload a cover and hide his button }
procedure TScreenSong.UnloadCover(Const I: integer);
begin
  Self.Button[I].Visible := false;
  if (Self.Button[I].Texture.TexNum <> 0) and (Self.Button[I].Texture.TexNum <> Self.DefaultCover.TexNum) then
    UTexture.Texture.UnLoadTexture(Self.Button[I].Texture);
end;

{ Load main cover in some game modes }
procedure TScreenSong.LoadMainCover();
begin
  Statics[Self.MainCover].Texture := Button[Self.Interaction].Texture;
  Statics[Self.MainCover].Texture.X := Theme.Song.Cover.SelectX;
  Statics[Self.MainCover].Texture.Y := Theme.Song.Cover.SelectY;
  Statics[Self.MainCover].Texture.W := Theme.Song.Cover.SelectW;
  Statics[Self.MainCover].Texture.H := Theme.Song.Cover.SelectH;
  Statics[Self.MainCover].Texture.Z := 1;
  Statics[Self.MainCover].Texture.Alpha := 1;
end;

procedure TScreenSong.Refresh;
begin

end;

//start Medley round
procedure TScreenSong.StartMedley(NumSongs: integer; MinSource: TMedleySource);
  procedure AddSong(SongNr: integer);
  begin
    SetLength(PlaylistMedley.Song, Length(PlaylistMedley.Song)+1);
    PlaylistMedley.Song[Length(PlaylistMedley.Song)-1] := SongNr;
  end;

  function SongAdded(SongNr: integer): boolean;
  var
    i: integer;
    skipped :boolean;
  begin
    skipped := false;
    for i := 0 to Length(PlaylistMedley.Song) - 1 do
    begin
      if (SongNr=PlaylistMedley.Song[i]) then
      begin
        skipped:=true;
        break;
      end;
    end;
    Result:=skipped;
  end;

  function NumSongsAdded(): Integer;
  begin
    Result := Length(PlaylistMedley.Song);
  end;

  function GetNextSongNr(MinS: TMedleySource): integer;
  var
    I, num: integer;
    unused_arr: array of integer;
    visible_arr: TVisArr;
  begin
    SetLength(unused_arr, 0);
    visible_arr := getVisibleMedleyArr(MinS);
    for I := 0 to Length(visible_arr) - 1 do
    begin
      if (not SongAdded(visible_arr[I])) then
      begin
        SetLength(unused_arr, Length(unused_arr)+1);
        unused_arr[Length(unused_arr)-1] := visible_arr[I];
      end;
    end;

    num := Random(Length(unused_arr));
    Result := unused_arr[num];
end;

var
  I: integer;
  VS: integer;
begin
  //Sel3 := 0;
  if (NumSongs > 0) and not MakeMedley then
  begin
    VS := Length(getVisibleMedleyArr(MinSource));
    if VS < NumSongs then
      PlaylistMedley.NumMedleySongs := VS
    else
      PlaylistMedley.NumMedleySongs := NumSongs;

    //set up Playlist Medley
    SetLength(PlaylistMedley.Song, 0);
    for I := 0 to PlaylistMedley.NumMedleySongs - 1 do
    begin
      AddSong(GetNextSongNr(MinSource));
    end;
  end else if not MakeMedley then //start this song
  begin
    SetLength(PlaylistMedley.Song, 1);
    PlaylistMedley.Song[0] := Interaction;
    PlaylistMedley.NumMedleySongs := 1;
  end
  else if MakeMedley then
  begin
    if (CatSongs.Song[Interaction].Medley.Source >= MinSource) then
    begin
      AddSong(Interaction);
      PlaylistMedley.NumMedleySongs := Length(PlaylistMedley.Song);
    end;
  end;

  if (Mode = smNormal) and not MakeMedley then
  begin
    Mode := smMedley;

    StopMusicPreview();

    //TODO: how about case 2? menu for medley mode?
    case Ini.OnSongClick of
      0: FadeTo(@ScreenSing);
      1: SelectPlayers;
      2: FadeTo(@ScreenSing);
      {2: begin
         if (CatSongs.CatNumShow = -3) then
           ScreenSongMenu.MenuShow(SM_Playlist)
         else
           ScreenSongMenu.MenuShow(SM_Main);
       end;}
    end;
  end
  else if MakeMedley then
  begin
    if PlaylistMedley.NumMedleySongs = NumSongs then
    begin
      Mode := smMedley;
      StopMusicPreview();

      //TODO: how about case 2? menu for medley mode?
      case Ini.OnSongClick of
        0: FadeTo(@ScreenSing);
        1: SelectPlayers;
        2: FadeTo(@ScreenSing);
        {2: begin
          if (CatSongs.CatNumShow = -3) then
            ScreenSongMenu.MenuShow(SM_Playlist)
          else
            ScreenSongMenu.MenuShow(SM_Main);
        end;}
      end;
    end;
  end;
end;

function TScreenSong.getVisibleMedleyArr(MinSource: TMedleySource): TVisArr;
var
  I:      integer;

begin
  SetLength(Result, 0);
  if CatSongs.Song[Interaction].Main then
  begin
    for I := 0 to Length(CatSongs.Song) - 1 do
    begin
      if not CatSongs.Song[I].Main and (CatSongs.Song[I].Medley.Source >= MinSource) then
      begin
        SetLength(Result, Length(Result)+1);
        Result[Length(Result)-1] := I;
      end;
    end;
  end else
  begin
    for I := 0 to Length(CatSongs.Song) - 1 do
    begin
      if CatSongs.Song[I].Visible and (CatSongs.Song[I].Medley.Source >= MinSource) then
      begin
        SetLength(Result, Length(Result)+1);
        Result[Length(Result)-1] := I;
      end;
    end;
  end;
end;

procedure TScreenSong.SongScore;
begin

  if (CatSongs.Song[Interaction].isDuet) or ((Mode <> smNormal) or (Ini.ShowScores = 0) or (CatSongs.Song[Interaction].Edition = '') or ((Ini.ShowScores = 1) and ((Text[TextMaxScore2].Text = '0') and (Text[TextMaxScoreLocal].Text = '0')))) then
  begin
    Text[TextScore].Visible           := false;
    Text[TextMaxScore].Visible        := false;
    Text[TextMediaScore].Visible      := false;
    Text[TextMaxScore2].Visible       := false;
    Text[TextMediaScore2].Visible     := false;
    Text[TextMaxScoreLocal].Visible   := false;
    Text[TextMediaScoreLocal].Visible := false;
    Text[TextScoreUserLocal].Visible  := false;
    Text[TextScoreUser].Visible       := false;
  end
  else
  begin
    if (Ini.ShowScores = 1) and (Text[TextMaxScoreLocal].Text = '0') and (High(DLLMan.Websites) < 0) then
    begin
      Text[TextScore].Visible           := false;
      Text[TextMaxScore].Visible        := false;
      Text[TextMediaScore].Visible      := false;
    end
    else
    begin
      Text[TextScore].Visible           := true;
      Text[TextMaxScore].Visible        := true;
      Text[TextMediaScore].Visible      := true;
    end;

    if (Ini.ShowScores = 1) and (Text[TextMaxScore2].Text = '0') then
    begin
      Text[TextMaxScore2].Visible       := false;
      Text[TextMediaScore2].Visible     := false;
      Text[TextScoreUser].Visible       := false;
    end
    else
    begin
      Text[TextMaxScore2].Visible       := true;
      Text[TextMediaScore2].Visible     := true;
      Text[TextScoreUser].Visible       := true;
    end;

    if (Ini.ShowScores = 1) and (Text[TextMaxScoreLocal].Text = '0') then
    begin
      Text[TextMaxScoreLocal].Visible   := false;
      Text[TextMediaScoreLocal].Visible := false;
      Text[TextScoreUserLocal].Visible  := false;
    end
    else
    begin
      Text[TextMaxScoreLocal].Visible   := true;
      Text[TextMediaScoreLocal].Visible := true;
      Text[TextScoreUserLocal].Visible  := true;
    end;

  end;

  //Set score
  if (High(DLLMan.Websites) >= 0) then
  begin
    Text[TextScore].Text       := UTF8Encode(DLLMan.Websites[Ini.ShowWebScore].Name);
    Text[TextMaxScore2].Text   := IntToStr(DataBase.ReadMax_Score(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, DllMan.Websites[Ini.ShowWebScore].ID, Ini.PlayerLevel[0]));
    Text[TextMediaScore2].Text := IntToStr(DataBase.ReadMedia_Score(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, DllMan.Websites[Ini.ShowWebScore].ID, Ini.PlayerLevel[0]));
    Text[TextScoreUser].Text   := DataBase.ReadUser_Score(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, DllMan.Websites[Ini.ShowWebScore].ID, Ini.PlayerLevel[0]);
  end;

  Text[TextMaxScoreLocal].Text   := IntToStr(DataBase.ReadMax_ScoreLocal(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, Ini.PlayerLevel[0]));
  Text[TextMediaScoreLocal].Text := IntToStr(DataBase.ReadMedia_ScoreLocal(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, Ini.PlayerLevel[0]));
  Text[TextScoreUserLocal].Text  := DataBase.ReadUser_ScoreLocal(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, Ini.PlayerLevel[0]);

end;

procedure TScreenSong.FadeMessage();
var
  factor: real;
begin
  if ((SDL_GetTicks - MessageTime)/1000 > MAX_MESSAGE) then
  begin
    if (MessageTimeFade = 0) then
      MessageTimeFade := SDL_GetTicks();

    factor := (SDL_GetTicks - MessageTimeFade)/1000/2;
    Statics[InfoMessageBG].Texture.Alpha := 1 - factor;
    Text[InfoMessageText].Alpha := 1 - factor;
  end
  else
    MessageTimeFade := 0;

  Statics[InfoMessageBG].Draw;
  Text[InfoMessageText].Draw;
end;

procedure TScreenSong.CloseMessage();
begin
  Statics[InfoMessageBG].Visible := false;
  Text[InfoMessageText].Visible := false;
end;

procedure TScreenSong.ChangeSorting(Tabs: integer; Duet: boolean; Sorting: integer);
var
  I, Count:      integer;
begin
  Ini.Sorting := Sorting;
  UIni.Ini.Tabs := Tabs;

  //ClearButtons();
  CatSongs.Refresh;
  Self.SkipTo(0);
  HideCatTL;
  ChangeMusic;

  Count := 0;
  for I := 0 to High(Button) do
  begin
    //while (CatSongs.Song[Count].Main) do
    //  Count := Count + 1;

    // if (CatSongs.Song[I].CoverTex.TexNum > 0) then
    //   Button[I].Texture := CatSongs.Song[I].CoverTex;
    //else
    //Count := Count + 1;
  end;

end;

end.
