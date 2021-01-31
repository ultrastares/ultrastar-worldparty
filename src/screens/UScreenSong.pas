{*
    UltraStar WorldParty - Karaoke Game

    UltraStar WorldParty is the legal property of its developers,
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
  UAvatars,
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
      CurrentVideo: IVideo;
      MinLine: integer; //current chessboard line
      LastMinLine: integer; //used on list mode
      ListFirstVisibleSongIndex: integer;
      MainListFirstVisibleSongIndex: integer;
      TextArtist: integer;
      TextNoSongs: integer;
      TextNumber: integer;
      TextTitle: integer;
      TextYear: integer;
      TextCreator: integer;
      TextFixer: integer;
      procedure ColorDuetNameSingers;
      procedure EnableSearch(const Enable: boolean);
      procedure LoadCover(const I: integer);
      procedure LoadMainCover();
      procedure OnSongSelect(Preview: boolean = true);
      procedure SetJoker();
      procedure SetScroll(Force: boolean = false);
      procedure SetRouletteScroll();
      procedure SetChessboardScroll();
      procedure SetCarouselScroll();
      procedure SetSlotMachineScroll();
      procedure SetSlideScroll();
      procedure SetListScroll();
      procedure StartPreview();
      procedure StopPreview();
      procedure UnloadCover(const I: integer);
    public
      //Video Icon Mod
      VideoIcon: cardinal;

      //Medley Icons
      MedleyIcon:     cardinal;
      CalcMedleyIcon: cardinal;
      DuetIcon: integer;
      DuetChange: boolean;
      RapIcon: integer;
      CreatorIcon: integer;
      FixerIcon: integer;
      UnvalidatedIcon: integer;
      SearchIcon: integer;
      SearchTextPlaceholder: integer;
      SearchText: integer;
      TextCat: integer;

      SongCurrent:  real;
      SongTarget:   real;

      HighSpeed:    boolean;
      CoverFull:    boolean;
      CoverTime:    real;

      //Scores
      TextMyScores: integer;
      TextWebsite: integer;
      TextUserLocalScore1: integer;
      TextUserLocalScore2: integer;
      TextUserLocalScore3: integer;
      TextLocalScore1: integer;
      TextLocalScore2: integer;
      TextLocalScore3: integer;
      TextUserOnlineScore1: integer;
      TextUserOnlineScore2: integer;
      TextUserOnlineScore3: integer;
      TextOnlineScore1: integer;
      TextOnlineScore2: integer;
      TextOnlineScore3: integer;

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

      ListTextArtist: array of integer;
      ListTextTitle: array of integer;
      ListTextYear: array of integer;
      ListTextCreator: array of integer;
      ListTextFixer: array of integer;
      ListVideoIcon: array of integer;
      ListMedleyIcon: array of integer;
      ListCalcMedleyIcon: array of integer;
      ListDuetIcon: array of integer;
      ListRapIcon: array of integer;
      ListCreatorIcon: array of integer;
      ListFixerIcon: array of integer;
      ListUnvalidatedIcon: array of integer;

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
      //Medley
      procedure StartMedley(NumSongs: integer; MinSource: TMedleySource);
      function  getVisibleMedleyArr(MinSource: TMedleySource): TVisArr;
  end;

implementation

uses
  Math,
  md5,
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
  UScreenPlayerSelector,
  UScreenPopup,
  UScreenScore,
  UScreenSingController,
  UScreenSongMenu,
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
  Result := (Mode in [smNormal, smPartyTournament, smPartyFree]);
end;

// Method for input parsing. If false is returned, GetNextWindow
// should be checked to know the next window to load;
function TScreenSong.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
  { Check if scroll needs to be slowed in chessboard mode after pressing repeatedly one key }
  function SlowChessboardScroll(): boolean;
  var
    SlowAction: boolean;
  begin
    Result := false;
    if UIni.TSongMenuMode(UIni.Ini.SongMenu) = smChessboard then
    begin
      SlowAction := (CharCode = Ord('r')) or (PressedKey = SDLK_PAGEDOWN) or (PressedKey = SDLK_PAGEUP);
      Result := Self.CoverTime < IfThen(
        USongs.Songs.GetLoadProgress().CoversPreload,
        IfThen(SlowAction, 1, UTime.TimeSkip * 10), //during cover preload it will be really slow
        IfThen(SlowAction, UTime.TimeSkip * 10, 0)
      );
    end;
  end;
var
  I: integer;
  I2: integer;
  SDL_ModState: word;
  PressedKeyEncoded: UTF8String;
  Song: USong.TSong;
begin
  Result := true;

  //Song Screen Extensions (Jumpto + Menu)
  if (ScreenSongMenu.Visible) then
  begin
    Result := ScreenSongMenu.ParseInput(PressedKey, CharCode, PressedDown);
    Exit;
  end;

  if (PressedDown) then
  begin // Key Down
    if
      Self.FreeListMode()
      and (not Self.Text[Self.SearchTextPlaceholder].Visible)
      and UUnicodeUtils.IsPrintableChar(CharCode)
    then
    begin
      if Length(Self.Text[Self.SearchText].Text) < 25 then
      begin
        Self.Text[Self.SearchText].Text := Self.Text[Self.SearchText].Text+UUnicodeUtils.UCS4ToUTF8String(CharCode);
        Self.SetSubselection(Self.Text[Self.SearchText].Text);
      end;
      Exit;
    end;

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
    end;

    // check special keys
    case PressedKey of
      SDLK_BACKSPACE:
        begin
          if not Self.Text[Self.SearchTextPlaceholder].Visible then
          begin
            Self.Text[Self.SearchText].DeleteLastLetter();
            Self.SetSubselection(Self.Text[Self.SearchText].Text);
            Exit;
          end;
          Self.ParseInput(SDLK_ESCAPE, 0, true);
        end;
      SDLK_ESCAPE:
        if Self.FreeListMode() and (not Self.Text[Self.SearchTextPlaceholder].Visible) then
          Self.ParseInput(SDLK_F3, 0, true)
        else
        begin
          Self.CloseMessage();
          case Mode of
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
          end;
        end;
      SDLK_RETURN:
        begin
          Self.CloseMessage();
          if USongs.CatSongs.GetVisibleSongs() > 0 then
          begin
            if USongs.CatSongs.Song[Self.Interaction].Main then
              Self.SetSubselection(USongs.CatSongs.Song[Self.Interaction].OrderNum, sfCategory)
            else
            begin // clicked on song
              Self.StopPreview();

              if (Mode = smNormal) then //Normal Mode -> Start Song
              begin
                if (SDL_ModState and KMOD_CTRL) <> 0 then
                  Self.StartMedley(0, USongs.CatSongs.Song[Self.Interaction].Medley.Source)
                else if (SDL_ModState and KMOD_SHIFT) <> 0 then
                begin
                  if Length(getVisibleMedleyArr(msTag)) > 0 then
                    Self.StartMedley(5, msTag)
                  else if Length(getVisibleMedleyArr(msCalculated)) > 0 then
                    Self.StartMedley(5, msCalculated)
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
            else if not SlowChessboardScroll() then
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
      SDLK_1..SDLK_3: //use teams jokers
        if
          (Self.Mode = smPartyClassic)
          and (High(UParty.Party.Teams) >= PressedKey - SDLK_1)
          and (UParty.Party.Teams[PressedKey - SDLK_1].JokersLeft > 0) then
        begin
          Dec(UParty.Party.Teams[PressedKey - SDLK_1].JokersLeft);
          Self.SelectRandomSong();
          Self.SetJoker();
        end;
      SDLK_F2: //toggle duet names
        if (Self.Mode = smNormal) and (USongs.CatSongs.Song[Self.Interaction].isDuet) then
        begin
          Self.DuetChange := not Self.DuetChange;
          Self.SetScroll(true);
        end;
      SDLK_F3: //show search
        begin
          Self.Text[Self.SearchText].Text := ''; //needed on hide
          Self.EnableSearch(Self.Text[Self.SearchTextPlaceholder].Visible);
        end;
      SDLK_F4: //random song
        if Self.FreeListMode() and (not SlowChessboardScroll()) then
          Self.SelectRandomSong(SDL_ModState = KMOD_LSHIFT);
      SDLK_F5: //reload songs
        if Self.FreeListMode() then
        begin
          if not Self.Text[Self.SearchTextPlaceholder].Visible then
            Self.ParseInput(SDLK_ESCAPE, 0, true);

          Self.FadeTo(@UGraphic.ScreenMain);
          UGraphic.ScreenMain.ReloadSongs();
        end;
      SDLK_F6: //online update songs
        if (not Usongs.CatSongs.Song[Self.Interaction].Main) and Self.FreeListMode() then
          UGraphic.ScreenPopupScoreDownload.ShowPopup(0, IfThen(SDL_GetModState and KMOD_CTRL <> 0, 1, 0), 0);
      SDLK_F7: //voice removal
        begin
          UAudioPlaybackBase.ToggleVoiceRemoval();
          Self.StartPreview();
        end;
      SDLK_F10: //show menu
        begin
          I := -1;
          case Self.Mode of
            smPartyClassic:
              I := SM_Party_Main;
            smPartyTournament,
            smPartyFree:
              I := SM_Party_Free_Main;
            else
              if USongs.CatSongs.GetVisibleSongs() > 0 then
                if USongs.CatSongs.Song[Self.Interaction].Main then
                  I := SM_Sorting
                else if USongs.CatSongs.CatNumShow = -2 then
                  I := SM_Song
                else if USongs.CatSongs.CatNumShow = -3 then
                  I := SM_Playlist
                else if SDL_GetModState and KMOD_ALT <> 0 then
                  I := SM_Sorting
                else if SDL_GetModState and KMOD_CTRL <> 0 then
                  I := SM_Playlist_Load
                else
                  I := SM_Main
          end;
          if I <> -1 then
            UGraphic.ScreenSongMenu.MenuShow(I);
        end;
    end;
  end;
end;

function TScreenSong.ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean;
var
  B, I, J, CoverX, CoverY: integer;
begin
  Result := true;
  if UGraphic.ScreenSongMenu.Visible then
    Result := UGraphic.ScreenSongMenu.ParseMouse(MouseButton, BtnDown, X, Y)
  else if BtnDown then
  begin
    Self.TransferMouseCords(X, Y);
    case MouseButton of
      SDL_BUTTON_LEFT: //sing or move to the selected song/page
        begin
          if
            Self.InRegion(X, Y, Self.Button[Self.Interaction].GetMouseOverArea()) //button
            or (Self.Statics[Self.MainCover].Visible and Self.InRegion(X, Y, Self.Statics[Self.MainCover].GetMouseOverArea())) //main cover
          then
            Self.ParseInput(SDLK_RETURN, 0, true)
          else if Self.InRegion(X, Y, Self.Statics[Self.SearchIcon].GetMouseOverArea()) then
            Self.EnableSearch(true)
          else
          begin
            if Self.Mode = smPartyClassic then
              for I := 0 to UParty.PartyTeamsMax - 1 do
                for J := 0 to UParty.PartyJokers - 1 do
                  if
                    Self.InRegion(X, Y, Self.Statics[Self.StaticTeamJoker[I][J]].GetMouseOverArea())
                    and Self.Statics[Self.StaticTeamJoker[I][J]].Visible
                  then
                    Self.ParseInput(IfThen(I = 0, SDLK_1, IfThen(I = 1, SDLK_2, SDLK_3)), 0, true);

            if (not Self.Text[Self.SearchTextPlaceholder].Visible) and (Self.Text[Self.SearchText].Text = '') then
              Self.EnableSearch(false);

            case UIni.TSongMenuMode(UIni.Ini.SongMenu) of
              smList: //current song in list mode
                if
                  (X > UThemes.Theme.Song.ListCover.X)
                  and (X < UThemes.Theme.Song.ListCover.X + UThemes.Theme.Song.ListCover.W)
                  and (Y > UThemes.Theme.Song.ListCover.Y)
                  and (Y < UThemes.Theme.Song.ListCover.Y + (UThemes.Theme.Song.ListCover.H + UThemes.Theme.Song.ListCover.Padding) * UThemes.Theme.Song.Cover.Rows)
                then
                  Self.ParseInput(SDLK_RETURN, 0, true);
              smChessboard: //left arrows to move a entire page
                if Self.FreeListMode() then
                begin
                  if Self.InRegion(X, Y, Self.Statics[1].GetMouseOverArea()) then //arrow to page up
                    Self.ParseInput(SDLK_PAGEUP, 0, true)
                  else if Self.InRegion(X, Y, Self.Statics[2].GetMouseOverArea()) then //arrow to page down
                    Self.ParseInput(SDLK_PAGEDOWN, 0, true);
                end;
              else
                if Self.FreeListMode() then
                  for B := 0 to High(Self.Button) do
                    if Self.Button[B].Visible and Self.InRegion(X, Y, Self.Button[B].GetMouseOverArea()) then
                    begin
                      Self.SkipTo(B);
                      Exit();
                    end;
            end;
          end;
        end;
      SDL_BUTTON_RIGHT: //go back
        if //open song menu
          Self.InRegion(X, Y, Self.Button[Self.Interaction].GetMouseOverArea()) //button
          or (Self.Statics[Self.MainCover].Visible and Self.InRegion(X, Y, Self.Statics[Self.MainCover].GetMouseOverArea())) //main cover
        then
          Self.ParseInput(SDLK_F10, 0, true)
        else if Self.RightMbESC then
          Result := Self.ParseInput(SDLK_ESCAPE, 0, true);
      SDL_BUTTON_MIDDLE: //open song menu
        Self.ParseInput(SDLK_F10, 0, true);
      SDL_BUTTON_WHEELDOWN: //next song
        Self.ParseInput(IfThen(UThemes.Theme.Song.Cover.Rows = 1, SDLK_RIGHT, SDLK_DOWN), 0, true);
      SDL_BUTTON_WHEELUP: //previous song
        Self.ParseInput(IfThen(UThemes.Theme.Song.Cover.Rows = 1, SDLK_LEFT, SDLK_UP), 0, true);
    end
  end
  else if Self.FreeListMode() and (not UGraphic.ScreenSongMenu.Visible) then //hover cover
  begin
    Self.TransferMouseCords(X, Y);
    Self.Statics[Self.SearchIcon].Texture.Alpha := IfThen(
      (not Self.Text[Self.SearchTextPlaceholder].Visible) or Self.InRegion(X, Y, Self.Statics[Self.SearchIcon].GetMouseOverArea()),
      1,
      UThemes.Theme.Song.SearchIcon.Alpha
    );
    B := Round(Self.SongTarget);
    case UIni.TSongMenuMode(UIni.Ini.SongMenu) of
      smList:
        if
          (X >= UThemes.Theme.Song.ListCover.X)
          and (X < UThemes.Theme.Song.ListCover.X + UThemes.Theme.Song.ListCover.W)
          and (Y >= UThemes.Theme.Song.ListCover.Y)
          and (Y < UThemes.Theme.Song.ListCover.Y + (UThemes.Theme.Song.ListCover.H + UThemes.Theme.Song.ListCover.Padding) * UThemes.Theme.Song.Cover.Rows)
        then
          B := Self.MinLine + (Y - UThemes.Theme.Song.ListCover.Y) div (UThemes.Theme.Song.ListCover.H + UThemes.Theme.Song.ListCover.Padding);
      smChessboard, smMosaic:
        begin
          Self.Statics[1].Texture.Alpha := IfThen(Self.InRegion(X, Y, Self.Statics[1].GetMouseOverArea()), 1, UThemes.Theme.Song.Statics[1].Alpha);
          Self.Statics[2].Texture.Alpha := IfThen(Self.InRegion(X, Y, Self.Statics[2].GetMouseOverArea()), 1, UThemes.Theme.Song.Statics[2].Alpha);
          if (X >= UThemes.Theme.Song.Cover.X) and (Y >= UThemes.Theme.Song.Cover.Y) then
          begin
            CoverX := (X - UThemes.Theme.Song.Cover.X) div (UThemes.Theme.Song.Cover.W + UThemes.Theme.Song.Cover.Padding);
            CoverY := (Y - UThemes.Theme.Song.Cover.Y) div (UThemes.Theme.Song.Cover.H + UThemes.Theme.Song.Cover.Padding);
            if (CoverX < UThemes.Theme.Song.Cover.Cols) and (CoverY < UThemes.Theme.Song.Cover.Rows) then
              B := (Self.MinLine + CoverY) * UThemes.Theme.Song.Cover.Cols + CoverX;
          end;
        end;
    end;
    if (B < USongs.CatSongs.GetVisibleSongs()) and (CompareValue(Self.SongTarget, B) <> 0) then
    begin
      Self.SkipTo(B);
    end;
  end;
end;

constructor TScreenSong.Create();
var
  I, J, Num, Padding: integer;
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
  Self.TextCreator := Self.AddText(UThemes.Theme.Song.TextCreator);
  Self.TextFixer := Self.AddText(UThemes.Theme.Song.TextFixer);
  Self.CalcMedleyIcon := Self.AddStatic(UThemes.Theme.Song.CalculatedMedleyIcon);
  Self.DuetIcon := Self.AddStatic(UThemes.Theme.Song.DuetIcon);
  Self.MedleyIcon := Self.AddStatic(UThemes.Theme.Song.MedleyIcon);
  Self.RapIcon := Self.AddStatic(UThemes.Theme.Song.RapIcon);
  Self.VideoIcon := Self.AddStatic(UThemes.Theme.Song.VideoIcon);
  Self.CreatorIcon := Self.AddStatic(UThemes.Theme.Song.CreatorIcon);
  Self.FixerIcon := Self.AddStatic(UThemes.Theme.Song.FixerIcon);
  Self.UnvalidatedIcon := Self.AddStatic(UThemes.Theme.Song.UnvalidatedIcon);
  Self.SearchIcon := Self.AddStatic(UThemes.Theme.Song.SearchIcon);
  Self.SearchTextPlaceholder := Self.AddText(UThemes.Theme.Song.SearchTextPlaceholder);
  Self.SearchText := Self.AddText(UThemes.Theme.Song.SearchText);

  //Show Scores
  Self.TextMyScores := Self.AddText(UThemes.Theme.Song.TextMyScores);
  Self.TextWebsite := Self.AddText(UThemes.Theme.Song.TextWebsite);
  Self.TextUserLocalScore1 := Self.AddText(UThemes.Theme.Song.TextUserLocalScore1);
  Self.TextUserLocalScore2 := Self.AddText(UThemes.Theme.Song.TextUserLocalScore2);
  Self.TextUserLocalScore3 := Self.AddText(UThemes.Theme.Song.TextUserLocalScore3);
  Self.TextLocalScore1 := Self.AddText(UThemes.Theme.Song.TextLocalScore1);
  Self.TextLocalScore2 := Self.AddText(UThemes.Theme.Song.TextLocalScore2);
  Self.TextLocalScore3 := Self.AddText(UThemes.Theme.Song.TextLocalScore3);
  Self.TextUserOnlineScore1 := Self.AddText(UThemes.Theme.Song.TextUserOnlineScore1);
  Self.TextUserOnlineScore2 := Self.AddText(UThemes.Theme.Song.TextUserOnlineScore2);
  Self.TextUserOnlineScore3 := Self.AddText(UThemes.Theme.Song.TextUserOnlineScore3);
  Self.TextOnlineScore1 := Self.AddText(UThemes.Theme.Song.TextOnlineScore1);
  Self.TextOnlineScore2 := Self.AddText(UThemes.Theme.Song.TextOnlineScore2);
  Self.TextOnlineScore3 := Self.AddText(UThemes.Theme.Song.TextOnlineScore3);

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

  CurrentVideo := nil;

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

  Self.MainCover := Self.AddStatic(UThemes.Theme.Song.MainCover);

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
  SetLength(ListTextCreator, Num);
  SetLength(ListTextFixer, Num);
  SetLength(ListVideoIcon, Num);
  SetLength(ListMedleyIcon, Num);
  SetLength(ListCalcMedleyIcon, Num);
  SetLength(ListDuetIcon, Num);
  SetLength(ListRapIcon, Num);
  SetLength(ListCreatorIcon, Num);
  SetLength(ListFixerIcon, Num);
  SetLength(Self.ListUnvalidatedIcon, Num);

  for I := 0 to Num - 1 do
  begin
    Self.ListTextArtist[I] := Self.AddText(UThemes.Theme.Song.TextArtist);
    Self.ListTextTitle[I] := Self.AddText(UThemes.Theme.Song.TextTitle);
    Self.ListTextYear[I] := Self.AddText(UThemes.Theme.Song.TextYear);
    Self.ListTextCreator[I] := Self.AddText(UThemes.Theme.Song.TextCreator);
    Self.ListTextFixer[I] := Self.AddText(UThemes.Theme.Song.TextFixer);
    Self.ListVideoIcon[I] := Self.AddStatic(UThemes.Theme.Song.VideoIcon);
    Self.ListMedleyIcon[I] := Self.AddStatic(UThemes.Theme.Song.MedleyIcon);
    Self.ListCalcMedleyIcon[I] := Self.AddStatic(UThemes.Theme.Song.CalculatedMedleyIcon);
    Self.ListDuetIcon[I] := Self.AddStatic(UThemes.Theme.Song.DuetIcon);
    Self.ListRapIcon[I] := Self.AddStatic(UThemes.Theme.Song.RapIcon);
    Self.ListCreatorIcon[I] := Self.AddStatic(UThemes.Theme.Song.CreatorIcon);
    Self.ListFixerIcon[I] := Self.AddStatic(UThemes.Theme.Song.FixerIcon);
    Self.ListUnvalidatedIcon[I] := Self.AddStatic(UThemes.Theme.Song.UnvalidatedIcon);
    Padding := I * (UThemes.Theme.Song.ListCover.H + UThemes.Theme.Song.ListCover.Padding);
    Self.Text[Self.ListTextArtist[I]].Y := Self.Text[Self.ListTextArtist[I]].Y + Padding;
    Self.Text[Self.ListTextTitle[I]].Y := Self.Text[Self.ListTextTitle[I]].Y + Padding;
    Self.Text[Self.ListTextYear[I]].Y := Self.Text[Self.ListTextYear[I]].Y + Padding;
    Self.Text[Self.ListTextCreator[I]].Y := Self.Text[Self.ListTextCreator[I]].Y + Padding;
    Self.Text[Self.ListTextFixer[I]].Y := Self.Text[Self.ListTextFixer[I]].Y + Padding;
    Self.Statics[Self.ListVideoIcon[I]].Texture.Y := Self.Statics[Self.ListVideoIcon[I]].Texture.Y + Padding;
    Self.Statics[Self.ListMedleyIcon[I]].Texture.Y := Self.Statics[Self.ListMedleyIcon[I]].Texture.Y + Padding;
    Self.Statics[Self.ListCalcMedleyIcon[I]].Texture.Y := Self.Statics[Self.ListCalcMedleyIcon[I]].Texture.Y + Padding;
    Self.Statics[Self.ListDuetIcon[I]].Texture.Y := Self.Statics[Self.ListDuetIcon[I]].Texture.Y + Padding;
    Self.Statics[Self.ListRapIcon[I]].Texture.Y := Self.Statics[Self.ListRapIcon[I]].Texture.Y + Padding;
    Self.Statics[Self.ListCreatorIcon[I]].Texture.Y := Self.Statics[Self.ListCreatorIcon[I]].Texture.Y + Padding;
    Self.Statics[Self.ListFixerIcon[I]].Texture.Y := Self.Statics[Self.ListFixerIcon[I]].Texture.Y + Padding;
    Self.Statics[Self.ListUnvalidatedIcon[I]].Texture.Y := Self.Statics[Self.ListUnvalidatedIcon[I]].Texture.Y + Padding;
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

{ Called when song flows movement stops at a song }
procedure TScreenSong.OnSongSelect(Preview: boolean = true);
begin
  Self.IsScrolling := false;
  Self.CoverTime := 0;
  Self.SongIndex := -1;
  if Preview and (UIni.Ini.PreviewVolume <> 0) then
    Self.StartPreview();
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

      if (Abs(Pos) < 3.5) then //7 covers
      begin
        Self.LoadCover(I);
        Angle := Pi * (Pos / Min(VS, 7)); // Range: (-1/4*Pi .. +1/4*Pi)
        B.H := Abs(UThemes.Theme.Song.Cover.H * AutoWidthCorrection * Cos(Angle * 0.8));
        B.W := Abs(UThemes.Theme.Song.Cover.W * Cos(Angle * 0.8));
        B.X := UThemes.Theme.Song.Cover.X + UThemes.Theme.Song.Cover.W * Sin(Angle * 1.25) * 2.4 - (B.W - UThemes.Theme.Song.Cover.W) / 2;
        B.Y := ((UThemes.Theme.Song.Cover.Y) + ((UThemes.Theme.Song.Cover.H) - Abs(UThemes.Theme.Song.Cover.H * Cos(Angle))) * 0.5) - (B.H - (B.H / AutoWidthCorrection));
        B.Z := 0.95 - Abs(Pos) * 0.01;
        B.SetSelect(true);
        B.Reflection := true;
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

        Angle := Pi * Pos;
        B.H := UThemes.Theme.Song.Cover.H - Abs(UThemes.Theme.Song.Cover.H * Cos(Angle) * 0.6);
        B.W := UThemes.Theme.Song.Cover.W - Abs(UThemes.Theme.Song.Cover.W * Cos(Angle) * 0.6);
        B.X := UThemes.Theme.Song.Cover.X + (UThemes.Theme.Song.Cover.W * Sin(Angle) * 2.4) - (B.W - UThemes.Theme.Song.Cover.W) / 2;
        B.Y := UThemes.Theme.Song.Cover.Y - (B.H - Theme.Song.Cover.H) * 0.5;
        B.Z := 0.4;
        B.SetSelect(false);
        B.Reflection := false;
      end
      else
        Self.UnloadCover(I);
    end;
    Inc(I);
  end;
end;

procedure TScreenSong.SetChessboardScroll();
var
  B, Line, Index, Count: integer;
begin
  Self.OnSongSelect(false);
  with UThemes.Theme.Song.Cover do
  begin
    Line := 0;
    Index := 0;
    Count := 0;
    for B := 0 to High(Self.Button) do
    begin
      Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
      Line := Count div Cols;
      if Self.Button[B].Visible and (Line < (Rows + Self.MinLine)) then //only change position for visible buttons
      begin
        if Line >= Self.MinLine then
        begin
          Self.LoadCover(B);
          Self.Button[B].H := H;
          Self.Button[B].W := W;
          Self.Button[B].X := X + (W + Padding) * (Count mod Cols);
          Self.Button[B].Y := Y + (H + Padding) * (Line - Self.MinLine);
          if Index = Self.Interaction then
          begin
            Self.Button[B].Z := 1;
            Self.LoadMainCover();
          end
          else
          begin
            Self.Button[B].Z := 0.9;
            Self.Button[B].SetSelect(false);
          end;
        end
        else //hide not visible songs upper than MinLine + Rows
        begin
          Self.UnloadCover(B);
          Self.Button[B].H := H; //set H and W is needed with tabs on
          Self.Button[B].W := W;
          Self.Button[B].Z := 0;
        end;
        Inc(Count);
      end
      else //hide not visible songs lower than MinLine
      begin
        Self.UnloadCover(B);
        Self.Button[B].H := H; //set H and W is needed with tabs on
        Self.Button[B].W := W;
        Self.Button[B].Z := 0;
      end;
      Inc(Index);
    end;
    if USongs.CatSongs.GetVisibleSongs() = 0 then
      Self.SkipTo(0)
    else if not Self.Button[Self.Interaction].Visible then
    begin
      Self.MinLine := Ceil((USongs.CatSongs.FindVisibleIndex(Self.Interaction) + 1 - Cols * Rows) / Cols);
      if (Line - Self.MinLine) > Rows then //to decrease line when push up (or pag up) key
        Self.MinLine += Rows - 1;

      if Self.MinLine < 0 then //to mantain songs on top when use random song in category
        Self.MinLine := 0;

      Self.SetChessboardScroll(); //to set new positions because Self.IsScrolling is set to false
    end;
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
        Self.Button[B].H := Theme.Song.Cover.H;
        Self.Button[B].W := Theme.Song.Cover.W;
        Self.Button[B].X := X; //after load cover to avoid cover flash on change
        Self.Button[B].Y := Theme.Song.Cover.Y;
        Self.Button[B].Z := 0.95; //more than 0.9 to be clicked with mouse and less than 1 to hide reflection
        Self.Button[B].SetSelect(true);
        Self.Button[B].Texture.Alpha := 1;
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
        Self.Button[B].H := Abs(Theme.Song.Cover.H * cos(Angle * 1.2));
        Self.Button[B].W := Self.Button[B].H;
        Self.Button[B].X := (Theme.Song.Cover.X  + (Theme.Song.Cover.H - Abs(Theme.Song.Cover.H * cos(Angle))) * 0.8);
        Self.Button[B].Y := Theme.Song.Cover.Y + Theme.Song.Cover.W * (Sin(Angle * 1.3) * 0.8) - ((Self.Button[B].H - Theme.Song.Cover.H) / 2);
        Self.Button[B].Z := 1;
        Self.Button[B].DeSelectReflectionspacing := 15 * Self.Button[B].H / Theme.Song.Cover.H;
        Self.Button[B].SetSelect(true);
        Self.Button[B].Texture.Alpha := 1 - Abs(Pos / 1.5);
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
        Self.Button[B].Texture.Alpha := 1;
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
  Self.OnSongSelect(false);
  Current := USongs.CatSongs.FindVisibleIndex(Self.Interaction);
  //move up at the start of list or in the rest of it
  if (Current < Self.MinLine) and ((Current < UThemes.Theme.Song.Cover.Rows) or (Current <= Self.LastMinLine)) then
    Self.MinLine := Current
  //move down in the tail of list or in the rest of it
  else if (Current - UThemes.Theme.Song.Cover.Rows >= Self.MinLine) and ((Current > USongs.CatSongs.GetVisibleSongs() - UThemes.Theme.Song.Cover.Rows) or (Current > Self.LastMinLine)) then
    Self.MinLine := Current - UThemes.Theme.Song.Cover.Rows + 1;

  Self.LastMinLine := Self.MinLine;

  // save first category
  if USongs.CatSongs.Song[Interaction].Main then
    Self.MainListFirstVisibleSongIndex := 0;

  Line := 0;
  for B := 0 to High(Self.Button) do
  begin
    Self.Button[B].Visible := USongs.CatSongs.Song[B].Visible;
    if (Self.Button[B].Visible) then
    begin
      if (Line >= Self.MinLine) and (Line - Self.MinLine < UThemes.Theme.Song.Cover.Rows) then
      begin
        I := Line - Self.MinLine;
        if I = 0 then
          Self.ListFirstVisibleSongIndex := B;

        Self.LoadCover(B);
        Self.Button[B].H := UThemes.Theme.Song.Cover.H;
        Self.Button[B].W := UThemes.Theme.Song.Cover.W;
        Self.Button[B].X := UThemes.Theme.Song.Cover.X;
        Self.Button[B].Y := UThemes.Theme.Song.Cover.Y + I * (UThemes.Theme.Song.Cover.H + UThemes.Theme.Song.Cover.Padding);
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
        Self.Statics[ListCreatorIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[ListCreatorIcon[I]].Visible := USongs.CatSongs.Song[B].Creator <> '';
        Self.Statics[ListFixerIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[ListFixerIcon[I]].Visible := USongs.CatSongs.Song[B].Fixer <> '';
        Self.Statics[Self.ListUnvalidatedIcon[I]].Texture.Alpha := Alpha;
        Self.Statics[Self.ListUnvalidatedIcon[I]].Visible := USongs.CatSongs.Song[B].Validated;
        Self.Text[ListTextArtist[I]].Alpha := Alpha;
        Self.Text[ListTextArtist[I]].Text := USongs.CatSongs.Song[B].Artist;
        Self.Text[ListTextTitle[I]].Alpha := Alpha;
        Self.Text[ListTextTitle[I]].Text := USongs.CatSongs.Song[B].Title;
        Self.Text[ListTextYear[I]].Alpha := Alpha;
        Self.Text[ListTextYear[I]].Text := IfThen(USongs.CatSongs.Song[B].Year <> 0, IntToStr(USongs.CatSongs.Song[B].Year), '');
        Self.Text[ListTextCreator[I]].Alpha := Alpha;
        Self.Text[ListTextCreator[I]].Text := USongs.CatSongs.Song[B].Creator;
        Self.Text[ListTextFixer[I]].Alpha := Alpha;
        Self.Text[ListTextFixer[I]].Text := USongs.CatSongs.Song[B].Fixer;
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
  Avatar: TAvatar;
  Col: TRGB;
  I, J: integer;
  Visible: boolean;
begin
  inherited;
  if not Assigned(UGraphic.ScreenSongMenu) then //load the screens only the first time
  begin
    //TODO move avatar load to UAvatar
    UIni.Ini.SingColor := UIni.Ini.PlayerColor; //FIXME remove this variable in all files
    UNote.PlayersPlay:= UIni.IPlayersVals[UIni.Ini.Players]; //FIXME set this variable is needed to see avatars in scores screen!
    J := 1;
    for I := 1 to High(AvatarsList) do
      if GetArrayIndex(UIni.Ini.PlayerAvatar, UpperCase(MD5Print(MD5File(AvatarsList[I].ToNative())))) <> -1 then
      begin
        Avatar := Avatars.FindAvatar(AvatarsList[I]);
        if (Avatar <> nil) then
          UAvatars.AvatarPlayerTextures[J] := Avatar.GetTexture()
        else
        begin
          UAvatars.AvatarPlayerTextures[J] := UTexture.Texture.LoadTexture(Skin.GetTextureFileName('NoAvatar_P'+IntToStr(J)), TEXTURE_TYPE_TRANSPARENT, $FFFFFF);
          Col := UThemes.GetPlayerColor(UIni.Ini.PlayerColor[J]);
          UAvatars.AvatarPlayerTextures[J].ColR := Col.R;
          UAvatars.AvatarPlayerTextures[J].ColG := Col.G;
          UAvatars.AvatarPlayerTextures[J].ColB := Col.B;
        end;
        FreeAndNil(Avatar);
        Inc(J);
      end;

    for I := J to UIni.IPlayersVals[UIni.Ini.Players] do
    begin
        UAvatars.AvatarPlayerTextures[I] := UTexture.Texture.LoadTexture(Skin.GetTextureFileName('NoAvatar_P'+IntToStr(J)), TEXTURE_TYPE_TRANSPARENT, $FFFFFF);
        Col := UThemes.GetPlayerColor(UIni.Ini.PlayerColor[I - 1]);
        UAvatars.AvatarPlayerTextures[I].ColR := Col.R;
        UAvatars.AvatarPlayerTextures[I].ColG := Col.G;
        UAvatars.AvatarPlayerTextures[I].ColB := Col.B;
    end;
    UThemes.LoadPlayersColors();
    UThemes.Theme.ThemeScoreLoad();
    UGraphic.ScreenScore := UScreenScore.TScreenScore.Create();
    UGraphic.ScreenSing := UScreenSingController.TScreenSingController.Create();
    UGraphic.ScreenSongMenu := UScreenSongMenu.TScreenSongMenu.Create();
    UGraphic.ScreenPopupScoreDownload := UScreenPopup.TScreenPopupScoreDownload.Create();
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
  CurrentVideo := nil;

  SetLength(PlaylistMedley.Song, 0);

  if Mode = smMedley then
    Mode := smNormal;

  UNote.PlayersPlay := IfThen(UIni.Ini.Players = 4, 6, UIni.Ini.Players + 1);

  Visible := not (Self.Mode = smPartyClassic);
  Self.Statics[Self.SearchIcon].Visible := Visible;
  Self.Text[Self.SearchTextPlaceholder].Visible := Visible;
  Self.Text[Self.SearchText].Visible := Visible;
  if Visible then
  begin
    Self.Refresh(UIni.Ini.Sorting, UIni.Ini.Tabs = 1, UIni.Ini.ShowDuets = 1);
    if (UIni.Ini.Tabs = 1) and (CatSongs.CatNumShow = -1) then //fix scroll on show and when enter after on first time with a category selected in the middle of the list
      Self.SetSubselection();

    if Self.Text[Self.SearchText].Text <> '' then
      Self.EnableSearch(true);
  end
  else
  begin
    Self.SelectRandomSong();
    if UIni.Ini.PartyPopup = 1 then
      UGraphic.ScreenSongMenu.MenuShow(SM_Party_Main);
  end;

  Self.SetScroll(true);
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

procedure TScreenSong.OnHide;
begin
  // turn music volume to 100%
  AudioPlayback.SetVolume(1.0);
  Self.StopPreview();
end;

function TScreenSong.Draw: boolean;
var
  dx:         real;
  dt:         real;
  I:       integer;
  Increment: real;
begin
  Result := true;
  if Self.Text[Self.SearchTextPlaceholder].Visible or UGraphic.ScreenSongMenu.Visible then
  begin
    Self.Text[Self.SearchText].Selected := false;
    if (USongs.CatSongs.GetVisibleSongs() = 0) then //needed on song refresh
      Exit()
  end
  else if not Self.Text[Self.SearchText].Selected then
    Self.Text[Self.SearchText].Selected := true;

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
    begin
      Self.OnSongSelect();
      Self.Statics[Self.MainCover].Texture.Alpha := Self.Button[Self.Interaction].Texture.Alpha;
    end;
  end
  else //start to preload covers
    USongs.Songs.PreloadCovers(true);

  Self.SetScroll();

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

  //Instead of Draw FG Procedure:
  //We draw Buttons for our own
  for I := 0 to Length(Button) - 1 do
    if Self.Button[I].Visible then
      Self.Button[I].Draw;

  //cover animation effects distinct of scroll using CoverTime from 0 to 1
  if Self.CoverTime > 1 then //last step
    Self.CoverTime := 1
  else if Self.CoverTime < 1 then
  begin
    Self.CoverTime += UTime.TimeSkip;

    if Assigned(CurrentVideo) then //video fade in on main cover
    begin
      Self.Statics[Self.MainCover].Texture.Alpha := IfThen(Self.CoverTime > 0.2, 1 - Self.CoverTime, 1);
      CurrentVideo.Alpha := 1 - Self.Statics[Self.MainCover].Texture.Alpha;
    end;

    case UIni.TSongMenuMode(UIni.Ini.SongMenu) of
      smChessboard: //cover zoom effect
        if Self.Button[Self.Interaction].H < UThemes.Theme.Song.Cover.ZoomThumbH then
        begin
          Increment := Self.CoverTime * (UThemes.Theme.Song.Cover.ZoomThumbH - UThemes.Theme.Song.Cover.H);
          if Self.Button[Self.Interaction].H + Increment > UThemes.Theme.Song.Cover.ZoomThumbH then //last position
          begin
            Increment := UThemes.Theme.Song.Cover.ZoomThumbH - Self.Button[Self.Interaction].H;
            Self.StartPreview();
          end;
          with Self.Button[Self.Interaction] do
          begin
            H := H + Increment;
            W := W + Increment;
            Y := Y - Increment / 2;
            X := X - Increment / 2;
          end;
        end;
      smList, smMosaic: //wait a bit to start song preview like scroll modes
        if (Self.PreviewOpened = -1) and (Self.CoverTime > 0.2) then
          Self.StartPreview();
    end;
  end;

  if Assigned(CurrentVideo) then
  begin
    if UGraphic.ScreenAct = 1 then
      CurrentVideo.GetFrame(USongs.CatSongs.Song[Self.Interaction].VideoGAP + UMusic.AudioPlayback.Position);

    if UThemes.Theme.Song.MainCover.Reflection then
      CurrentVideo.DrawReflection();

    CurrentVideo.Draw();
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

  if UGraphic.ScreenSongMenu.Visible then
    UGraphic.ScreenSongMenu.Draw();

  //if (Mode = smPartyTournament) then
  //  PartyTimeLimit();
end;

procedure TScreenSong.StartPreview();
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

  Song := CatSongs.Song[Interaction];

  PlayMidi := false;
  if Song.Mp3.IsSet() and AudioPlayback.Open(Song.Path.Append(Song.Mp3)) then
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

    if (UIni.Ini.VideoPreview = 1) and Song.Video.IsSet() then
    begin
      CurrentVideo := UMusic.VideoPlayback.Open(Song.Path.Append(Song.Video));
      if (CurrentVideo <> nil) then
        with UThemes.Theme.Song.MainCover do
        begin
          CurrentVideo.Height := H;
          CurrentVideo.Width := W;
          CurrentVideo.ReflectionSpacing := ReflectionSpacing;
          CurrentVideo.SetScreenPosition(X, Y, Self.Button[Self.Interaction].Texture.Z);
          CurrentVideo.SetScreen(UGraphic.ScreenAct);
          CurrentVideo.AspectCorrection := UMusic.acoCrop;
          CurrentVideo.Position := Song.VideoGAP + UMusic.AudioPlayback.Position;
          CurrentVideo.Play();
        end;
    end;
  end;
end;

procedure TScreenSong.StopPreview();
begin
  Self.PreviewOpened := -1;
  UMusic.AudioPlayback.Stop();
  if Assigned(CurrentVideo) then
  begin
    CurrentVideo.Stop();
    CurrentVideo := nil;
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
  //deselect song actions
  Self.IsScrolling := true;
  Self.DuetChange := false;
  Self.StopPreview();
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

  Self.StopPreview();

  FadeTo(@ScreenSing);
end;

procedure TScreenSong.SelectPlayers;
begin
  USongs.CatSongs.Selected := Self.Interaction;
  Self.StopPreview();
  if not Assigned(UGraphic.ScreenPlayerSelector) then
    UGraphic.ScreenPlayerSelector := TScreenPlayerSelector.Create();

  UGraphic.ScreenPlayerSelector.OpenedInOptions := false;
  Self.FadeTo(@UGraphic.ScreenPlayerSelector);
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

{ Enable or disable search box }
procedure TScreenSong.EnableSearch(const Enable: boolean);
begin
  if not Self.FreeListMode() then
    Exit;

  if Enable and (USongs.CatSongs.GetVisibleSongs() <> 0) then
  begin
    Self.Text[Self.SearchTextPlaceholder].Visible := false;
    Self.Statics[Self.SearchIcon].Texture.Alpha := 1;
  end
  else
  begin
    Self.Text[Self.SearchTextPlaceholder].Visible := true;
    Self.Statics[Self.SearchIcon].Texture.Alpha := UThemes.Theme.Song.SearchIcon.Alpha;
    Self.SetSubselection();
  end
end;

{ Load a cover dynamically in a song button }
procedure TScreenSong.LoadCover(const I: integer);
begin
  if Self.Button[I].Texture.TexNum = 0 then
  begin
    Self.Button[I].Texture := UTexture.Texture.LoadTexture(USongs.CatSongs.Song[I].Path.Append(USongs.CatSongs.Song[I].Cover));
    if Self.Button[I].Texture.TexNum = 0 then
      Self.Button[I].Texture := Self.DefaultCover;
  end;
end;

{ Unload a cover and hide his button }
procedure TScreenSong.UnloadCover(const I: integer);
begin
  Self.Button[I].Visible := false;
  if (Self.Button[I].Texture.TexNum <> 0) and (Self.Button[I].Texture.TexNum <> Self.DefaultCover.TexNum) then
    UTexture.Texture.UnLoadTexture(Self.Button[I].Texture);
end;

{ Load main cover in some game modes }
procedure TScreenSong.LoadMainCover();
begin
  with Self.Statics[Self.MainCover], UThemes.Theme.Song.MainCover do
  begin
    Texture := Self.Button[Self.Interaction].Texture;
    Texture.X := X;
    Texture.Y := Y;
    Texture.W := W;
    Texture.H := H;
  end;
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
      Self.SetRangeVisibilityStatic(Self.Mode = smPartyClassic, [Self.StaticTeamJoker[I][0], Self.StaticTeamJoker[I][JokersLeft - 1]]);
    end;
    if JokersLeft <= UParty.PartyJokers - 1 then
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

  USongs.Songs.PreloadCovers(false);

  Visibility := USongs.CatSongs.GetVisibleSongs() <> 0;
  VisibilityNoList := Visibility and (UIni.TSongMenuMode(UIni.Ini.SongMenu) <> smList);

  Self.SetRangeVisibilityStatic(VisibilityNoList, [0, 2]); //0 arrow, 1 song info panel and 2 only for smChessboard down arrow
  Self.SetRangeVisibilityStatic(VisibilityNoList, [Self.CalcMedleyIcon, Self.UnvalidatedIcon]); //icons
  Self.Statics[Self.MainCover].Visible := Visibility and (UIni.TSongMenuMode(UIni.Ini.SongMenu) in [smChessboard, smList, smMosaic]);
  Self.Text[Self.TextArtist].Visible := VisibilityNoList;
  Self.Text[Self.TextNoSongs].Visible := not Visibility;
  Self.Text[Self.TextNumber].Visible := Visibility;
  Self.SetRangeVisibilityText(VisibilityNoList, [Self.TextTitle, Self.TextFixer]);
  Self.SetRangeVisibility(Visibility and Self.FreeListMode(), [Self.StaticNonParty[0], High(Self.StaticNonParty)], [Self.TextNonParty[0], High(Self.TextNonParty)]); //set legend visibility
  Self.SetRangeVisibility(false, [Self.Static6PlayersDuetSingerP6, Self.Static2PlayersDuetSingerP1], [Self.Text2PlayersDuetSingerP1, Self.Text3PlayersDuetSingerP3]); //hide duets
  for I := 0 to High(Self.StaticsList) do //hide items in smList, too after change from other mode
  begin
    Self.StaticsList[I].Visible := false;
    Self.Text[Self.ListTextArtist[I]].Text := '';
    Self.Text[Self.ListTextTitle[I]].Text := '';
    Self.Text[Self.ListTextYear[I]].Text := '';
    Self.Text[Self.ListTextCreator[I]].Text := '';
    Self.Text[Self.ListTextFixer[I]].Text := '';
    Self.Statics[Self.ListCalcMedleyIcon[I]].Visible := false;
    Self.Statics[Self.ListDuetIcon[I]].Visible := false;
    Self.Statics[Self.ListMedleyIcon[I]].Visible := false;
    Self.Statics[Self.ListRapIcon[I]].Visible := false;
    Self.Statics[Self.ListVideoIcon[I]].Visible := false;
    Self.Statics[Self.ListCreatorIcon[I]].Visible := false;
    Self.Statics[Self.ListUnvalidatedIcon[I]].Visible := false;
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
      Self.Statics[Self.CreatorIcon].Visible := Song.Creator <> '';
      Self.Statics[Self.FixerIcon].Visible := Song.Fixer <> '';
      Self.Statics[Self.UnvalidatedIcon].Visible := false; //not Song.Validated;
      Self.Text[Self.TextArtist].Text := Song.Artist; //not visible on smList
      Self.Text[Self.TextYear].Text := IfThen(Song.Year <> 0, IntToStr(Song.Year), '');
      Self.Text[Self.TextCreator].Text := Song.Creator;
      Self.Text[Self.TextFixer].Text := Song.Fixer;
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

    Self.Text[Self.TextWebsite].text := UTF8Decode('UltraStar España'); //FIXME use the constant
    if (UIni.Ini.ShowScores > 0) and (Self.Mode = smNormal) and (not Song.isDuet) then //show scores
    begin
      Self.Text[Self.TextLocalScore1].Text := IntToStr(UDataBase.DataBase.ReadMaxScoreLocal(Song.Artist, Song.Title, 0));
      Self.Text[Self.TextLocalScore2].Text := IntToStr(UDataBase.DataBase.ReadMaxScoreLocal(Song.Artist, Song.Title, 1));
      Self.Text[Self.TextLocalScore3].Text := IntToStr(UDataBase.DataBase.ReadMaxScoreLocal(Song.Artist, Song.Title, 2));
      Self.Text[Self.TextUserLocalScore1].Text := UDataBase.DataBase.ReadUserScoreLocal(Song.Artist, Song.Title, 0);
      Self.Text[Self.TextUserLocalScore2].Text := UDataBase.DataBase.ReadUserScoreLocal(Song.Artist, Song.Title, 1);
      Self.Text[Self.TextUserLocalScore3].Text := UDataBase.DataBase.ReadUserScoreLocal(Song.Artist, Song.Title, 2);

      if (High(UDllManager.DLLMan.Websites) >= 0) then
      begin
        Self.Text[Self.TextOnlineScore1].Text := IntToStr(UDataBase.DataBase.ReadMaxScore(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, 0));
        Self.Text[Self.TextOnlineScore2].Text := IntToStr(UDataBase.DataBase.ReadMaxScore(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, 1));
        Self.Text[Self.TextOnlineScore3].Text := IntToStr(UDataBase.DataBase.ReadMaxScore(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, 2));
        Self.Text[Self.TextUserOnlineScore1].Text := UDataBase.DataBase.ReadUser_Score(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, 0);
        Self.Text[Self.TextUserOnlineScore2].Text := UDataBase.DataBase.ReadUser_Score(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, 1);
        Self.Text[Self.TextUserOnlineScore3].Text := UDataBase.DataBase.ReadUser_Score(Song.Artist, Song.Title, DllMan.Websites[UIni.Ini.ShowWebScore].ID, 2);
      end;
      //show local score, web score and captions
      Self.SetRangeVisibilityText(
        (UIni.Ini.ShowScores = 2) or (Self.Text[Self.TextLocalScore1].Text <> '0'),
        [Self.TextUserLocalScore1, Self.TextLocalScore3]
      );
      Self.Text[Self.TextMyScores].Visible := Self.Text[Self.TextUserLocalScore1].Visible;
      Self.SetRangeVisibilityText(
        (UIni.Ini.ShowScores = 2) or ((Self.Text[Self.TextOnlineScore1].Text <> '0') and (Self.Text[Self.TextUserOnlineScore1].Text <> '')),
        [Self.TextUserOnlineScore1, Self.TextOnlineScore3]
      );
      Self.Text[Self.TextWebsite].Visible := Self.Text[Self.TextUserOnlineScore1].Visible;
    end
    else
      Self.SetRangeVisibilityText(false, [Self.TextMyScores, Self.TextOnlineScore3]);
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
  if (NumSongs > 0) then
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
  end
  else if USongs.CatSongs.Song[Self.Interaction].Medley.Source = msNone then
    Exit
  else //start this song
  begin
    SetLength(PlaylistMedley.Song, 1);
    PlaylistMedley.Song[0] := Interaction;
    PlaylistMedley.NumMedleySongs := 1;
  end;

  if Self.Mode = smNormal then
  begin
    Mode := smMedley;

    Self.StopPreview();

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
