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
  UCommon,
  UIni,
  UMenu,
  UMenuEqualizer,
  UMusic,
  UParty,
  USong,
  USongs,
  UTexture;

type
  TVisArr = array of integer;

  TScreenSong = class(TMenu)
    private
      DefaultCover: TTexture;
      Equalizer: Tms_Equalizer;
      PreviewOpened: Integer; //interaction of the song that is loaded for preview music -1 if nothing is opened
      IsScrolling: boolean; //true if song flow is about to move
      fCurrentVideo: IVideo;
      MinLine: integer; //current chessboard line
      LastMinLine: integer; //used on list mode
      ListFirstVisibleSongIndex: integer;
      MainListFirstVisibleSongIndex: integer;
      TextArtist: integer;
      TextNoSongs: integer;
      TextNumber: integer;
      TextTitle: integer;
      TextYear: integer;
      procedure ColorDuetNameSingers;
      procedure LoadCover(Const I: integer);
      procedure LoadMainCover();
      procedure SetJoker();
      procedure SetScroll(Force: boolean = false);
      procedure SetRouletteScroll();
      procedure SetChessboardScroll();
      procedure SetCarouselScroll();
      procedure SetSlotMachineScroll();
      procedure SetSlideScroll();
      procedure SetListScroll();
      procedure StartMusicPreview();
      procedure StartVideoPreview();
      procedure UnloadCover(Const I: integer);
    public
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

      SongCurrent:  real;
      SongTarget:   real;

      HighSpeed:    boolean;
      CoverFull:    boolean;
      CoverTime:    real;

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

      StaticTeamJoker: array [0..UParty.PartyTeamsMax - 1, 0..UParty.PartyJokers - 1] of integer;
      StaticParty:    array of cardinal;
      TextParty:      array of cardinal;
      StaticNonParty: array of cardinal;
      TextNonParty:   array of cardinal;

      // for chessboard songmenu
      MainCover: integer;

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
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      function ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean; override;
      function Draw: boolean; override;
      procedure FadeMessage();
      procedure CloseMessage();
      procedure OnShow; override;
      procedure OnShowFinish; override;
      procedure OnHide; override;
      procedure SetSubselection(Id: integer; Filter: TSongFilter); overload;
      procedure SetSubselection(Id: UTF8String = ''; Filter: TSongFilter = sfAll); overload;
      procedure SkipTo(Target: cardinal; Force: boolean = false);
      procedure Refresh(Sort: integer; Categories: boolean; Duets: boolean);
      function FreeListMode: boolean;
      procedure SelectRandomSong(RandomCategory: boolean = false);
      procedure ColorizeJokers;
      //procedure PartyTimeLimit;

      //procedures for Menu
      procedure StartSong;
      procedure SelectPlayers;

      procedure OnSongSelect;   // called when song flows movement stops at a song
      procedure OnSongDeSelect; // called before current song is deselected

      //Medley
      procedure StartMedley(NumSongs: integer; MinSource: TMedleySource);
      function  getVisibleMedleyArr(MinSource: TMedleySource): TVisArr;

      procedure StopMusicPreview();
      procedure StopVideoPreview();
  end;

implementation

uses
  Math,
  sdl2,
  SysUtils,
  StrUtils,
  UAudioPlaybackBase,
  UDataBase,
  UDllManager,
  UGraphic,
  ULanguage,
  ULog,
  UMain,
  UMenuButton,
  UNote,
  UPath,
  UPlaylist,
  UScreenPlayerSelection,
  UScreenPopup,
  UScreenSongMenu,
  UScreenSongJumpto,
  USkins,
  UThemes,
  UTime,
  UUnicodeUtils;

const
  MAX_TIME = 30;
  MAX_MESSAGE = 3;
  MAX_TIME_MOUSE_SELECT = 800;

// ***** Public methods ****** //
function TScreenSong.FreeListMode: boolean;
begin
  Result := (Mode in [smNormal, smPartyTournament, smPartyFree, smJukebox]);
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
      Ord('J'):
        if (USongs.CatSongs.GetVisibleSongs() > 0) and Self.FreeListMode() then
          UGraphic.ScreenSongJumpto.Visible := true;
      Ord('M'): //Show SongMenu
        if USongs.CatSongs.GetVisibleSongs() > 0 then
        begin
          if Self.MakeMedley then
            UGraphic.ScreenSongMenu.MenuShow(SM_Medley)
          else if Self.Mode = smJukebox then
            UGraphic.ScreenSongMenu.MenuShow(SM_Jukebox)
          else if Self.Mode = smNormal then
            if USongs.CatSongs.Song[Interaction].Main then
              UGraphic.ScreenSongMenu.MenuShow(SM_Sorting)
            else if USongs.CatSongs.CatNumShow = -3 then
              UGraphic.ScreenSongMenu.MenuShow(SM_Playlist)
            else
              UGraphic.ScreenSongMenu.MenuShow(SM_Main)
          else
            UGraphic.ScreenSongMenu.MenuShow(IfThen(Self.Mode = smPartyClassic, SM_Party_Main, SM_Party_Free_Main));
        end;
      Ord('O'):
        if (USongs.CatSongs.GetVisibleSongs() > 0) and Self.FreeListMode() then
          UGraphic.ScreenSongMenu.MenuShow(SM_Sorting);
      Ord('P'):
        if (USongs.CatSongs.GetVisibleSongs() > 0) and Self.FreeListMode() then
          UGraphic.ScreenSongMenu.MenuShow(SM_Playlist_Load);
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
        if Self.FreeListMode() then
          Self.SelectRandomSong(SDL_ModState = KMOD_LSHIFT);

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
      SDLK_ESCAPE, SDLK_BACKSPACE:
      begin
        Self.CloseMessage();
        case Mode of
          smJukebox:
            Self.FadeTo(@ScreenJukeboxPlaylist);
          smPartyClassic:
            Self.CheckFadeTo(@ScreenMain,'MSG_END_PARTY');
          smPartyFree:
            Self.FadeTo(@ScreenPartyNewRound);
          smPartyTournament:
            Self.FadeTo(@ScreenPartyTournamentRounds);
          else
            if USongs.CatSongs.CatNumShow <> -1 then
              Self.SetSubselection()
            else
              Self.FadeTo(@ScreenMain);
        end
      end;
      SDLK_RETURN:
        begin
          CloseMessage();
          if (Songs.SongList.Count > 0) then
          begin
            if USongs.CatSongs.Song[Self.Interaction].Main then
              Self.SetSubselection(USongs.CatSongs.Song[Self.Interaction].OrderNum, sfCategory)
            else
            begin // clicked on song
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
      SDLK_DOWN, SDLK_PAGEDOWN, SDLK_RIGHT, SDLK_UP, SDLK_PAGEUP, SDLK_LEFT:
        begin
          Self.CloseMessage();
          if (USongs.CatSongs.GetVisibleSongs() > 0) and Self.FreeListMode() then
            if //rotate by categories
              (UIni.Ini.Tabs = 1)
              and (USongs.CatSongs.CatNumShow > -2)
              and (
                (((PressedKey = SDLK_DOWN) or (PressedKey = SDLK_UP)) and (UThemes.Theme.Song.Cover.Rows = 1))
                or (((PressedKey = SDLK_LEFT) or (PressedKey = SDLK_RIGHT)) and (UThemes.Theme.Song.Cover.Cols = 1))
              )
            then
            begin
              if USongs.CatSongs.Song[Self.Interaction].Main then //enter into selected category
                Self.SetSubselection(USongs.CatSongs.Song[Self.Interaction].OrderNum, sfCategory)
              else if (PressedKey = SDLK_DOWN) or (PressedKey = SDLK_RIGHT) then //go to first category if end is reached
                Self.SetSubselection(
                  IfThen(USongs.CatSongs.Song[Self.Interaction].OrderNum = USongs.CatSongs.CatCount, 1, USongs.CatSongs.Song[Self.Interaction].OrderNum + 1),
                  sfCategory
                )
              else  //go to last category if start is reached
                Self.SetSubselection(
                  IfThen(USongs.CatSongs.Song[Self.Interaction].OrderNum = 1, USongs.CatSongs.CatCount, USongs.CatSongs.Song[Self.Interaction].OrderNum - 1),
                  sfCategory
                );
            end
            else
            begin
              case PressedKey of //calculate steps to advance or back
                SDLK_PAGEDOWN, SDLK_PAGEUP: //entire page
                  I := (UThemes.Theme.Song.Cover.Cols * UThemes.Theme.Song.Cover.Rows);
                SDLK_DOWN, SDLK_UP: //vertical
                  I := IfThen((UThemes.Theme.Song.Cover.Cols > 1) and (UThemes.Theme.Song.Cover.Rows > 1), UThemes.Theme.Song.Cover.Cols, 1);
                else //horizontal
                  I := 1;
              end;
              case PressedKey of
                SDLK_PAGEDOWN: //advance to end
                  Self.SkipTo(Min(USongs.CatSongs.GetVisibleSongs() - 1, Round(Self.SongTarget) + I));
                SDLK_PAGEUP: //back to start
                  Self.SkipTo(Max(0, Round(Self.SongTarget) - I));
                SDLK_DOWN, SDLK_RIGHT: //go to initial song if reach the end of subselection list or the next song
                  Self.SkipTo(IfThen(Self.SongTarget + I >= USongs.CatSongs.GetVisibleSongs(), 0, Round(Self.SongTarget) + I));
                SDLK_UP, SDLK_LEFT: //go to final song if reach the start of subselection list or the previous song
                  Self.SkipTo(IfThen(Self.SongTarget - I < 0, USongs.CatSongs.GetVisibleSongs() - 1, Round(Self.SongTarget) - I));
              end;
            end;
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
      SDLK_1..SDLK_3: //use teams jokers
        begin
          if
            (Self.Mode = smPartyClassic)
            and (High(UParty.Party.Teams) >= PressedKey - SDLK_1)
            and (UParty.Party.Teams[PressedKey - SDLK_1].JokersLeft > 0) then
          begin
            Dec(UParty.Party.Teams[PressedKey - SDLK_1].JokersLeft);
            Self.SelectRandomSong();
            Self.SetJoker();
          end;
        end;
    end;
  end;
end;

function TScreenSong.ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean;
var
  B: integer;
begin
  Result := true;
  if UGraphic.ScreenSongMenu.Visible then
    Result := UGraphic.ScreenSongMenu.ParseMouse(MouseButton, BtnDown, X, Y)
  else if UGraphic.ScreenSongJumpTo.Visible then
    Result := UGraphic.ScreenSongJumpTo.ParseMouse(MouseButton, BtnDown, X, Y)
  else
  begin
    Self.TransferMouseCords(X, Y);
    if BtnDown then
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
              if Self.InRegion(X, Y, Self.Statics[0].GetMouseOverArea()) then //arrow to page up
                Self.ParseInput(SDLK_PAGEUP, 0, true)
              else if Self.InRegion(X, Y, Self.Statics[1].GetMouseOverArea()) then //arrow to page down
                Self.ParseInput(SDLK_PAGEDOWN, 0, true);
          end;
        SDL_BUTTON_RIGHT: //go back
          if Self.RightMbESC then
            Result := Self.ParseInput(SDLK_ESCAPE, 0, true);
        SDL_BUTTON_MIDDLE: //open song menu
          Self.ParseInput(0, Ord('M'), true);
        SDL_BUTTON_WHEELDOWN: //next song
          Self.ParseInput(IfThen(UThemes.Theme.Song.Cover.Rows = 1, SDLK_RIGHT, SDLK_DOWN), 0, true);
        SDL_BUTTON_WHEELUP: //previous song
          Self.ParseInput(IfThen(UThemes.Theme.Song.Cover.Rows = 1, SDLK_LEFT, SDLK_UP), 0, true);
      end;
    end
    else if UIni.TSongMenuMode(UIni.Ini.SongMenu) = smChessboard then //hover cover
      for B := 0 to High(Self.Button) do
        if Self.Button[B].Visible and Self.InRegion(X, Y, Self.Button[B].GetMouseOverArea()) and (Self.Interaction <> B) then
        begin
          Self.Interaction := B;
          Self.SongTarget := B;
          Self.OnSongDeSelect();
        end;
  end;
end;

constructor TScreenSong.Create;
var
  I, J, Num, Padding: integer;
  TextArtistY, TextTitleY, TextYearY, StaticMedCY,
  StaticMedMY, StaticVideoY, StaticDuetY, StaticRapY: integer;
  StaticY: real;
begin
  inherited Create;

  Self.DefaultCover := UTexture.Texture.LoadTexture(USkins.Skin.GetTextureFileName('SongCover'));

  LoadFromTheme(Theme.Song);

  Self.TextArtist := Self.AddText(UThemes.Theme.Song.TextArtist);
  Self.TextCat := Self.AddText(UThemes.Theme.Song.TextCat);
  Self.TextNoSongs := Self.AddText(UThemes.Theme.Song.TextNoSongs);
  Self.TextNumber := Self.AddText(UThemes.Theme.Song.TextNumber);
  Self.TextTitle := Self.AddText(UThemes.Theme.Song.TextTitle);
  Self.TextYear := Self.AddText(UThemes.Theme.Song.TextYear);
  Self.CalcMedleyIcon := Self.AddStatic(UThemes.Theme.Song.CalculatedMedleyIcon);
  Self.DuetIcon := Self.AddStatic(UThemes.Theme.Song.DuetIcon);
  Self.MedleyIcon := Self.AddStatic(UThemes.Theme.Song.MedleyIcon);
  Self.RapIcon := Self.AddStatic(UThemes.Theme.Song.RapIcon);
  Self.VideoIcon := Self.AddStatic(UThemes.Theme.Song.VideoIcon);

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
  for I := 0 to UParty.PartyTeamsMax - 1 do
    for J := 0 to UParty.PartyJokers - 1 do
    begin
      Self.StaticTeamJoker[I][J] := Self.AddStatic(UThemes.Theme.Song.StaticTeamJoker);
      Self.Statics[Self.StaticTeamJoker[I][J]].Texture.X += (Self.Statics[Self.StaticTeamJoker[I][J]].Texture.W + Self.Statics[Self.StaticTeamJoker[I][J]].Texture.PaddingX) * J;
      Self.Statics[Self.StaticTeamJoker[I][J]].Texture.Y += (Self.Statics[Self.StaticTeamJoker[I][J]].Texture.H + Self.Statics[Self.StaticTeamJoker[I][J]].Texture.PaddingY) * I;
    end;

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

  Equalizer := Tms_Equalizer.Create(AudioPlayback, Theme.Song.Equalizer);

  PreviewOpened := -1;
  Self.IsScrolling := false;

  fCurrentVideo := nil;

  // Info Message
  InfoMessageBG := AddStatic(Theme.Song.InfoMessageBG);
  InfoMessageText := AddText(Theme.Song.InfoMessageText);

  // Duet Names Singers
  Self.Static6PlayersDuetSingerP6 := Self.AddStatic(UThemes.Theme.Song.Static6PlayersDuetSingerP6); //it's very important the order to overlap 6 and 4 with 3 and 2 statics
  Self.Static6PlayersDuetSingerP5 := Self.AddStatic(UThemes.Theme.Song.Static6PlayersDuetSingerP5);
  Self.Static6PlayersDuetSingerP4 := Self.AddStatic(UThemes.Theme.Song.Static6PlayersDuetSingerP4);
  Self.Static3PlayersDuetSingerP3 := Self.AddStatic(UThemes.Theme.Song.Static3PlayersDuetSingerP3);
  Self.Static3PlayersDuetSingerP2 := Self.AddStatic(UThemes.Theme.Song.Static3PlayersDuetSingerP2);
  Self.Static3PlayersDuetSingerP1 := Self.AddStatic(UThemes.Theme.Song.Static3PlayersDuetSingerP1);
  Self.Static4PlayersDuetSingerP4 := Self.AddStatic(UThemes.Theme.Song.Static4PlayersDuetSingerP4);
  Self.Static4PlayersDuetSingerP3 := Self.AddStatic(UThemes.Theme.Song.Static4PlayersDuetSingerP3);
  Self.Static2PlayersDuetSingerP2 := Self.AddStatic(UThemes.Theme.Song.Static2PlayersDuetSingerP2);
  Self.Static2PlayersDuetSingerP1 := Self.AddStatic(UThemes.Theme.Song.Static2PlayersDuetSingerP1);
  Self.Text2PlayersDuetSingerP1 := Self.AddText(UThemes.Theme.Song.Text2PlayersDuetSingerP1);
  Self.Text2PlayersDuetSingerP2 := Self.AddText(UThemes.Theme.Song.Text2PlayersDuetSingerP2);
  Self.Text3PlayersDuetSingerP1 := Self.AddText(UThemes.Theme.Song.Text3PlayersDuetSingerP1);
  Self.Text3PlayersDuetSingerP2 := Self.AddText(UThemes.Theme.Song.Text3PlayersDuetSingerP2);
  Self.Text3PlayersDuetSingerP3 := Self.AddText(UThemes.Theme.Song.Text3PlayersDuetSingerP3);

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

  Num := IfThen(UIni.TSongMenuMode(UIni.Ini.SongMenu) = smList, UThemes.Theme.Song.Cover.Rows, 0);

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
        B.SetSelect(true);
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
        B.SetSelect(true);
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
  B, VisibleIndex, VisibleCovers: integer;
  X, XCorrection: real;
begin
  VisibleCovers := 4; //4 for fast scroll at the start/end of list, but only 2 is needed for slow scroll
  VisibleIndex := 0;
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
    if Self.Button[B].Visible then
    begin
      XCorrection := 0;
      if not ((VisibleIndex >= Self.SongTarget - VisibleCovers) and (VisibleIndex <= Self.SongTarget + VisibleCovers)) then //not visible songs
        if VisibleIndex < VisibleCovers then //last cover of list
          XCorrection := 1
        else if VisibleIndex >= USongs.CatSongs.GetVisibleSongs() - VisibleCovers then //first covers of list
          XCorrection := -1;

      X := Theme.Song.Cover.X + (Theme.Song.Cover.Padding + Theme.Song.Cover.W) * ((VisibleIndex - Self.SongCurrent) + USongs.CatSongs.GetVisibleSongs() * XCorrection);
      Inc(VisibleIndex);
      if not ((X < -Theme.Song.Cover.W) or (X > 800)) then //visible zone
      begin
        Self.LoadCover(B);
        Self.Button[B].SetSelect(true);
        Self.Button[B].H := Theme.Song.Cover.H;
        Self.Button[B].W := Theme.Song.Cover.W;
        Self.Button[B].X := X; //after load cover to avoid cover flash on change
        Self.Button[B].Y := Theme.Song.Cover.Y;
        Self.Button[B].Z := 0.95; //more than 0.9 to be clicked with mouse and less than 1 to hide reflection
      end
      else //hide not visible songs
        Self.UnloadCover(B);
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
        Self.Button[B].SetSelect(true);
      end
      else
        Self.UnloadCover(B);
    end;
  end;
end;

{* Coverflow effect *}
procedure TScreenSong.SetSlideScroll;
var
  B, VisibleIndex, VisibleCovers: integer;
  PaddingIncrementX, RightX, Scale, Steps: real;
  FirstCover, LastCover, LeftCover, VisibleCover: boolean;
begin
  VisibleIndex := 0; //counter of visible covers
  VisibleCovers := IfThen(USongs.CatSongs.GetVisibleSongs() <= 11, 5, 8); //5 visible covers in each side plus 3 in background to improve the scroll effect
  Scale := 0.95; //scale to reduce size or inclination of side covers
  Steps := Floor(UIni.Ini.MaxFramerate * 15 / 60); //number of steps for animations
  RightX := (Theme.Song.Cover.W + (Theme.Song.Cover.W - Theme.Song.Cover.W * Scale)) / 2; //correction on X for right covers
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
    if Self.Button[B].Visible then
    begin
      VisibleCover := (VisibleIndex >= Self.SongTarget - VisibleCovers) and (VisibleIndex <= Self.SongTarget + VisibleCovers); //visible songs
      LastCover := (not VisibleCover) and (USongs.CatSongs.GetVisibleSongs() - VisibleIndex <= VisibleCovers - Self.SongTarget); //last cover of list
      FirstCover := (not VisibleCover) and (not LastCover) and (USongs.CatSongs.GetVisibleSongs() - Self.SongTarget <= VisibleCovers - VisibleIndex); //first covers of list
      if VisibleCover or LastCover or FirstCover then
      begin
        Self.LoadCover(B);
        Self.Button[B].SetSelect(true);
        Self.Button[B].Y := Theme.Song.Cover.Y;
        Self.Button[B].Z := Self.Statics[2].Texture.Z - 0.01;
        if (B = Self.Interaction) and SameValue(Self.SongTarget, Self.SongCurrent, 1.002) then //main cover
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
          LeftCover := ((VisibleIndex < Self.SongCurrent) or LastCover) and (not FirstCover);
          Self.Button[B].Reflection := true;
          Self.Button[B].X := Theme.Song.Cover.X;
          Self.Button[B].Z := Self.Button[B].Z - IfThen(
            LeftCover,
            (Self.SongCurrent - VisibleIndex + IfThen(LastCover, USongs.CatSongs.GetVisibleSongs(), 0)) * 0.01, //put first covers under following
            (VisibleIndex - Self.SongCurrent + IfThen(FirstCover, USongs.CatSongs.GetVisibleSongs(), 0)) * 0.01 //put last covers under previous
          );

          PaddingIncrementX := VisibleIndex - Self.SongCurrent;
          if not VisibleCover then
            PaddingIncrementX += USongs.CatSongs.GetVisibleSongs() * IfThen(LastCover, -1, 1);

          if //animation from central to left or right position using texture scale, height and width
            (not SameValue(Self.Button[B].H, Theme.Song.Cover.H * Scale))
            and (not SameValue(Self.SongTarget, Self.SongCurrent, 0.0021)) //avoid initial state or after quit a filter or searching before move from first cover
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

  Line := 0;
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := CatSongs.Song[B].Visible;
    if (Self.Button[B].Visible) then
    begin
      if (Line >= Self.MinLine) and (Line - Self.MinLine < UThemes.Theme.Song.Cover.Rows) then
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
        Self.StaticsList[I].Visible := true;
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
        Self.Text[ListTextYear[I]].Text := IfThen(USongs.CatSongs.Song[B].Year <> 0, IntToStr(USongs.CatSongs.Song[B].Year), '');
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

  if Self.Mode = smPartyClassic then
  begin
    Self.SelectRandomSong();
    if UIni.Ini.PartyPopup = 1 then
      UGraphic.ScreenSongMenu.MenuShow(SM_Party_Main);
  end
  else
  begin
    Self.Refresh(UIni.Ini.Sorting, UIni.Ini.Tabs = 1, UIni.Ini.ShowDuets = 1);
    if (UIni.Ini.Tabs = 1) and (CatSongs.CatNumShow = -1) then //fix scroll on show and when enter after on first time with a category selected in the middle of the list
      Self.SetSubselection();
  end;

  Self.SetScroll(true);

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

{* Move directly to a position of the song list *}
procedure TScreenSong.SkipTo(Target: cardinal; Force: boolean = false);
begin
  if (Target = 0) and (Self.SongTarget = USongs.CatSongs.GetVisibleSongs() - 1) then //go to initial song if reach the end of subselection list
    Self.SongCurrent := -1
  else if (Target = USongs.CatSongs.GetVisibleSongs() - 1) and (Self.SongTarget = 0) then //go to final song if reach the start of subselection list
    Self.SongCurrent := USongs.CatSongs.GetVisibleSongs()
  else if Force then //sometimes if needed to force scroll (tabs on, playlist modes, etc.)
    Self.SongCurrent := Target;

  Self.Interaction := IfThen(USongs.CatSongs.IsFilterApplied(), USongs.CatSongs.FindGlobalIndex(Target), Target);
  Self.SongTarget := Target;
  Self.OnSongDeSelect();
end;

procedure TScreenSong.SelectRandomSong(RandomCategory: boolean = false);
var
  Category, PrevSong, Song: integer;
begin
  Randomize();
  if Self.FreeListMode() and (UIni.Ini.Tabs = 1) and RandomCategory then //choose random category
  begin
    repeat
      Category := Random(USongs.CatSongs.CatCount) + 1
    until (USongs.CatSongs.CatCount < 2) or (Category <> USongs.CatSongs.CatNumShow); //avoid to change to same category
    Self.SetSubselection(Category, sfCategory);
  end;

  PrevSong := USongs.CatSongs.FindVisibleIndex(Self.Interaction);
  repeat
    Song := Random(USongs.CatSongs.GetVisibleSongs());
  until (USongs.CatSongs.GetVisibleSongs() < 2) or (Song <> PrevSong); //avoid to change to same song

  Self.SkipTo(Song, Song = PrevSong); //force in some cases after change to other category
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
  if not Assigned(UGraphic.ScreenPlayerSelector) then
    UGraphic.ScreenPlayerSelector := TScreenPlayerSelector.Create();

  UGraphic.ScreenPlayerSelector.Goto_SingScreen := true;
  FadeTo(@UGraphic.ScreenPlayerSelector);
end;

{ Set teams jokers colors }
procedure TScreenSong.ColorizeJokers();
var
  I, J: integer;
  Col: TRGB;
begin
  for I := 0 to UParty.PartyTeamsMax - 1 do
  begin
    Col := UThemes.GetPlayerColor(UIni.Ini.SingColor[I]);
    for J := 0 to UParty.PartyJokers - 1 do
    begin
      Self.Statics[Self.StaticTeamJoker[I][J]].Texture.ColR := Col.R;
      Self.Statics[Self.StaticTeamJoker[I][J]].Texture.ColG := Col.G;
      Self.Statics[Self.StaticTeamJoker[I][J]].Texture.ColB := Col.B;
    end;
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

procedure TScreenSong.Refresh(Sort: integer; Categories: boolean; Duets: boolean);
var
  I, B: integer;
begin
  if USongs.CatSongs.Refresh(Sort, Categories, Duets) or (Length(Self.Button) = 0) then
  begin
    Self.ClearButtons();
    for I := 0 to High(USongs.CatSongs.Song) do
    begin
      B := Self.AddButton(UThemes.Theme.Song.Cover.X, UThemes.Theme.Song.Cover.Y, UThemes.Theme.Song.Cover.W, UThemes.Theme.Song.Cover.H, PATH_NONE);
      Self.Button[B].Reflection := UThemes.Theme.Song.Cover.Reflections;
      Self.Button[B].ReflectionSpacing := UThemes.Theme.Song.Cover.ReflectionSpacing;
    end;
    Self.SkipTo(0);
  end;
end;

{ Set joker visibility }
procedure TScreenSong.SetJoker();
var
  I, JokersLeft: integer;
begin
  for I := 0 to UParty.PartyTeamsMax - 1 do
  begin
    JokersLeft := 0;
    if I <= High(UParty.Party.Teams) then
    begin
      JokersLeft := UParty.Party.Teams[I].JokersLeft;
      Self.SetRangeVisibilityStatic(true, [Self.StaticTeamJoker[I][0], Self.StaticTeamJoker[I][JokersLeft - 1]]);
    end;
    Self.SetRangeVisibilityStatic(false, [Self.StaticTeamJoker[I][JokersLeft], Self.StaticTeamJoker[I][UParty.PartyJokers - 1]]);
  end;
end;

{ Set info of selected song and the position and visibility of all songs }
procedure TScreenSong.SetScroll(Force: boolean = false);
var
  DuetPlayer1: UTF8String = '';
  DuetPlayer2: UTF8String = '';
  Song: USong.TSong;
  Visibility, VisibilityNoList: boolean;
  I: integer;
begin
  if not (Force or Self.IsScrolling) then //to avoid unnecessary modifications if nothing changes
    Exit();

  Visibility := USongs.CatSongs.GetVisibleSongs() <> 0;
  VisibilityNoList := Visibility and (UIni.TSongMenuMode(UIni.Ini.SongMenu) <> smList);

  Self.SetRangeVisibilityStatic(VisibilityNoList, [0, 2]); //0 arrow, 1 song info panel and 2 only for smChessboard down arrow
  Self.SetRangeVisibilityStatic(VisibilityNoList, [Self.CalcMedleyIcon, Self.VideoIcon]); //icons
  Self.Statics[Self.MainCover].Visible := Visibility;
  Self.Text[Self.TextArtist].Visible := VisibilityNoList;
  Self.Text[Self.TextNoSongs].Visible := not Visibility;
  Self.Text[Self.TextNumber].Visible := Visibility;
  Self.Text[Self.TextTitle].Visible := VisibilityNoList;
  Self.Text[Self.TextYear].Visible := VisibilityNoList;
  Self.SetRangeVisibility(Visibility and Self.FreeListMode(), [Self.StaticNonParty[0], Self.StaticNonParty[4]], [Self.TextNonParty[0], Self.TextNonParty[4]]); //set legend visibility
  Self.SetRangeVisibility(false, [Self.Static6PlayersDuetSingerP6, Self.Static2PlayersDuetSingerP1], [Self.Text2PlayersDuetSingerP1, Self.Text3PlayersDuetSingerP3]); //hide duets
  for I := 0 to High(Self.StaticsList) do //hide items in smList, too after change from other mode
  begin
    Self.StaticsList[I].Visible := false;
    Self.Text[Self.ListTextArtist[I]].Text := '';
    Self.Text[Self.ListTextTitle[I]].Text := '';
    Self.Text[Self.ListTextYear[I]].Text := '';
    Self.Statics[Self.ListCalcMedleyIcon[I]].Visible := false;
    Self.Statics[Self.ListDuetIcon[I]].Visible := false;
    Self.Statics[Self.ListMedleyIcon[I]].Visible := false;
    Self.Statics[Self.ListRapIcon[I]].Visible := false;
    Self.Statics[Self.ListVideoIcon[I]].Visible := false;
  end;
  if Visibility then
  begin
    Song := USongs.CatSongs.Song[Self.Interaction];
    if UIni.TSongMenuMode(UIni.Ini.SongMenu) <> smList then
    begin
      Self.Statics[Self.CalcMedleyIcon].Visible := (Song.Medley.Source = msCalculated) and not Song.isDuet;
      Self.Statics[Self.DuetIcon].Visible := Song.isDuet;
      Self.Statics[Self.MedleyIcon].Visible := (Song.Medley.Source = msTag) and not Song.isDuet;
      Self.Statics[Self.RapIcon].Visible := Song.hasRap;
      Self.Statics[Self.VideoIcon].Visible := Song.Video.IsSet;
      Self.Text[Self.TextArtist].Text := Song.Artist; //not visible on smList
      Self.Text[Self.TextYear].Text := IfThen(Song.Year <> 0, IntToStr(Song.Year), '');
    end;
    if (USongs.CatSongs.CatNumShow = -1) and (UIni.Ini.Tabs = 1) and Self.FreeListMode() then //list of categories
    begin
      Self.Text[Self.TextNumber].Text := IntToStr(Song.OrderNum);
      Self.Text[Self.TextTitle].Text := IntToStr(Song.CatNumber)+' '+ULanguage.Language.Translate(IfThen(Song.CatNumber = 1, 'SING_SONG_IN_CAT', 'SING_SONGS_IN_CAT'));
    end
    else
    begin
      Self.Text[Self.TextTitle].Text := Song.Title;
      if USongs.CatSongs.CatNumShow < -1 then //in a search (-2) or in a playlist (-3)
        Self.Text[Self.TextNumber].Text := FloatToStr(Self.SongTarget + 1)
      else if USongs.CatSongs.CatNumShow > -1 then //into a category
        Self.Text[Self.TextNumber].Text := IntToStr(Song.CatNumber)
      else
        Self.Text[Self.TextNumber].Text := IntToStr(Self.Interaction + 1);
    end;
    Self.Text[Self.TextNumber].Text := Self.Text[Self.TextNumber].Text+'/'+IntToStr(USongs.CatSongs.GetVisibleSongs());

    if Song.isDuet then //show duets selectors
    begin
      if Self.DuetChange then
      begin
        DuetPlayer1 := Song.DuetNames[1];
        DuetPlayer2 := Song.DuetNames[0];
      end
      else
      begin
        DuetPlayer1 := Song.DuetNames[0];
        DuetPlayer2 := Song.DuetNames[1];
      end;
      if (UNote.PlayersPlay = 3) or (UNote.PlayersPlay = 6) then
      begin
        if (UGraphic.ScreenAct = 2) and (UNote.PlayersPlay = 6) then
        begin
          Self.Text[Self.Text3PlayersDuetSingerP1].Text := DuetPlayer2;
          Self.Text[Self.Text3PlayersDuetSingerP2].Text := DuetPlayer1;
          Self.Text[Self.Text3PlayersDuetSingerP3].Text := DuetPlayer2;
        end
        else
        begin
          Self.Text[Self.Text3PlayersDuetSingerP1].Text := DuetPlayer1;
          Self.Text[Self.Text3PlayersDuetSingerP2].Text := DuetPlayer2;
          Self.Text[Self.Text3PlayersDuetSingerP3].Text := DuetPlayer1;
        end;
        Self.SetRangeVisibility(
          true,
          [IfThen(UNote.PlayersPlay = 3, Self.Static3PlayersDuetSingerP3, Self.Static6PlayersDuetSingerP6), Self.Static3PlayersDuetSingerP1],
          [Self.Text3PlayersDuetSingerP1, Self.Text3PlayersDuetSingerP3]
        );
      end
      else
      begin
        Self.Text[Self.Text2PlayersDuetSingerP1].Text := DuetPlayer1;
        Self.Text[Self.Text2PlayersDuetSingerP2].Text := DuetPlayer2;
        Self.SetRangeVisibility(
          true,
          [IfThen(UNote.PlayersPlay <= 2, Self.Static2PlayersDuetSingerP2, Self.Static4PlayersDuetSingerP4), Self.Static2PlayersDuetSingerP1],
          [Self.Text2PlayersDuetSingerP1, Self.Text2PlayersDuetSingerP2]
        );
      end;
    end;

    if (UIni.Ini.ShowScores > 0) and (Self.Mode = smNormal) and (not Song.isDuet) then //show scores
    begin
      Self.Text[Self.TextMaxScoreLocal].Text := IntToStr(UDataBase.DataBase.ReadMaxScoreLocal(Song.Artist, Song.Title, UIni.Ini.PlayerLevel[0]));
      Self.Text[Self.TextMediaScoreLocal].Text := IntToStr(UDataBase.DataBase.ReadAverageScoreLocal(Song.Artist, Song.Title, UIni.Ini.PlayerLevel[0]));
      Self.Text[Self.TextScoreUserLocal].Text := UDataBase.DataBase.ReadUserScoreLocal(Song.Artist, Song.Title, UIni.Ini.PlayerLevel[0]);
      if (High(UDllManager.DLLMan.Websites) >= 0) then
      begin
        Self.Text[Self.TextMaxScore2].Text := IntToStr(UDataBase.DataBase.ReadMaxScore(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, UIni.Ini.PlayerLevel[0]));
        Self.Text[Self.TextMediaScore2].Text := IntToStr(UDataBase.DataBase.ReadAverageScore(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, UIni.Ini.PlayerLevel[0]));
        Self.Text[Self.TextScore].Text := UTF8Encode(UDllManager.DLLMan.Websites[UIni.Ini.ShowWebScore].Name);
        Self.Text[Self.TextScoreUser].Text := UDataBase.DataBase.ReadUser_Score(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, UIni.Ini.PlayerLevel[0]);
      end;
      //show local score, web score and captions
      Self.SetRangeVisibilityText((UIni.Ini.ShowScores = 2) or (Self.Text[Self.TextMaxScoreLocal].Text <> '0'), [Self.TextMaxScoreLocal, Self.TextScoreUserLocal]);
      Self.SetRangeVisibilityText((UIni.Ini.ShowScores = 2) or (Self.Text[Self.TextMaxScore2].Text <> '0'), [Self.TextMaxScore2, Self.TextScoreUser]);
      Self.SetRangeVisibilityText(Self.Text[Self.TextMaxScoreLocal].Visible or Self.Text[Self.TextMaxScore2].Visible, [Self.TextScore, Self.TextMediaScore]);
    end
    else
      Self.SetRangeVisibilityText(false, [Self.TextMaxScore, Self.TextScoreUserLocal]);
  end;
  case UIni.TSongMenuMode(UIni.Ini.SongMenu) of
    smRoulette: Self.SetRouletteScroll();
    smChessboard, smMosaic: Self.SetChessboardScroll();
    smCarousel: Self.SetCarouselScroll();
    smSlotMachine: Self.SetSlotMachineScroll();
    smSlide: Self.SetSlideScroll();
    smList: Self.SetListScroll();
  end;
end;

{ SetSubselection adapted to accept ids as integers to show categories and playlist }
procedure TScreenSong.SetSubselection(Id: integer; Filter: TSongFilter);
begin
  Self.SetSubselection(IntToStr(Id), Filter);
end;

{ Show a songs subselection depends on Id and Filter selected. It used to show categories, playlist, searches o full list }
procedure TScreenSong.SetSubselection(Id: UTF8String = ''; Filter: TSongFilter = sfAll);
var
  Caption: UTF8String;
  Position: integer;
begin
  Position := 0;
  case Filter of
    sfCategory:
      Caption := USongs.CatSongs.Song[USongs.CatSongs.ShowCategory(StrToInt(Id))].Artist;
    sfPlaylist:
      begin
        USongs.CatSongs.ShowPlaylist(StrToInt(Id));
        Caption := Format(ULanguage.Language.Translate('PLAYLIST_CATTEXT'), [UPlaylist.PlayListMan.SetPlayList(StrToInt(Id)).Name]);
      end;
    else //search using Id as string to found or show all songs if is empty
      Caption := IfThen(Id = '', '', ULanguage.Language.Translate('SONG_JUMPTO_TYPE_DESC')+' '+Id);
      if (UIni.Ini.Tabs = 1) and (USongs.CatSongs.CatNumShow > -2) then //move to correct category after leave it or after OnShow if the category is in the middle of the list
        Position := IfThen(USongs.CatSongs.CatNumShow > -1, USongs.CatSongs.CatNumShow - 1, Round(Self.SongTarget));

      USongs.CatSongs.SetFilter(Id, sfAll);
    end;
  Self.Text[Self.TextCat].Text := Caption;
  Self.SkipTo(Position, true);
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

end.
