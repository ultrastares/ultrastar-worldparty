{* UltraStar Deluxe - Karaoke Game
 *
 * UltraStar Deluxe is the legal property of its developers, whose names
 * are too numerous to list here. Please refer to the COPYRIGHT
 * file distributed with this source distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 * $URL: https://ultrastardx.svn.sourceforge.net/svnroot/ultrastardx/trunk/src/screens/UScreenSong.pas $
 * $Id: UScreenSong.pas 2665 2010-10-14 08:00:23Z k-m_schindler $
 *}

unit UScreenSong;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  SysUtils,
  SDL,
  bass,
  bassmidi,
  UCatCovers,
  UCommon,
  UDataBase,
  UDisplay,
  UDllManager,
  UPath,
  UFiles,
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
      Equalizer: Tms_Equalizer;

      PreviewOpened: Integer; // interaction of the Song that is loaded for preview music
                              // -1 if nothing is opened

      isScrolling: boolean;   // true if song flow is about to move

      fCurrentVideo: IVideo;

      fStream     : HSTREAM;

      procedure StartMusicPreview();
      procedure StopMusicPreview();
      procedure StartVideoPreview();
      procedure StopVideoPreview();
      procedure MidiFadeInPreview();
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
      TextMedleyArtist:   array[1..4] of integer;
      TextMedleyTitle:    array[1..4] of integer;
      TextMedleyNumber:   array[1..4] of integer;
      StaticMedley:   array[1..4] of integer;

      //Duet Icon
      DuetIcon:     cardinal;
      DuetChange:   boolean;

      TextCat:   integer;
      StaticCat: integer;

      SongCurrent:  real;
      SongTarget:   real;

      HighSpeed:    boolean;
      CoverFull:    boolean;
      CoverTime:    real;

      CoverX:       integer;
      CoverY:       integer;
      CoverW:       integer;
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

      PlayMidi: boolean;
      MidiFadeIn: boolean;
      FadeTime: cardinal;

      InfoMessageBG: cardinal;
      InfoMessageText: cardinal;

      StaticDuetSingerP1: cardinal;
      StaticDuetSingerP2: cardinal;
      TextDuetSingerP1: cardinal;
      TextDuetSingerP2: cardinal;
      ColPlayer:  array[0..3] of TRGB;

      //CurrentPartyTime: cardinal;
      //PartyTime: cardinal;
      //TextPartyTime: cardinal;

      MessageTime: cardinal;
      MessageTimeFade: cardinal;

      constructor Create; override;
      procedure SetScroll;
      //procedure SetScroll1;
      //procedure SetScroll2;
      procedure SetScroll3;
      procedure SetScroll4;
      procedure SetScroll5;
      procedure SetScroll6;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      function ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean; override;
      function Draw: boolean; override;
      function FinishedMusic: boolean;

      procedure ResetMidiChannelVolume();
      procedure OffMidiChannel(channel: integer);

      procedure WriteMessage(msg: UTF8String);
      procedure FadeMessage();
      procedure CloseMessage();

      procedure GenerateThumbnails();
      procedure OnShow; override;
      procedure OnShowFinish; override;
      procedure OnHide; override;
      procedure SelectNext;
      procedure SelectPrev;
      procedure SkipTo(Target: cardinal);
      procedure FixSelected; //Show Wrong Song when Tabs on Fix
      procedure FixSelected2; //Show Wrong Song when Tabs on Fix
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
      procedure SetStatics;
      procedure ColorizeJokers;
      //procedure PartyTimeLimit;
      function PermitCategory(ID: integer): boolean;

      //procedures for Menu
      procedure StartSong;
      procedure OpenEditor;
      procedure DoJoker(Team: integer);
      procedure SelectPlayers;

      procedure OnSongSelect;   // called when song flows movement stops at a song
      procedure OnSongDeSelect; // called before current song is deselected

      procedure UnloadDetailedCover;

      procedure SongScore;

      //Extensions
      procedure DrawExtensions;

      //Medley
      procedure StartMedley(NumSongs: integer; MinSource: TMedleySource);
      function  getVisibleMedleyArr(MinSource: TMedleySource): TVisArr;

      procedure ColorDuetNameSingers;
  end;

implementation

uses
  Math,
  gl,
  UCovers,
  UGraphic,
  UMain,
  UMenuButton,
  UNote,
  UParty,
  UPlaylist,
  USoundfont,
  UScreenSongMenu,
  USkins,
  UUnicodeUtils;

const
  MAX_TIME = 30;
  MAX_MESSAGE = 3;

// ***** Public methods ****** //
function TScreenSong.FreeListMode: boolean;
begin
  if ((Mode = smNormal) or (Mode = smPartyTournament) or (Mode = smPartyFree) or (Mode = smPartyJukebox)) then
    Result := true
  else
    Result := false;
end;

//Show Wrong Song when Tabs on Fix
procedure TScreenSong.FixSelected;
var
  I, I2: integer;
begin
  if CatSongs.VisibleSongs > 0 then
  begin
    I2:= 0;
    for I := Low(CatSongs.Song) to High(Catsongs.Song) do
    begin
      if CatSongs.Song[I].Visible then
        inc(I2);

      if I = Interaction - 1 then
        break;
    end;

    SongCurrent := I2;
    SongTarget  := I2;
  end;
end;

procedure TScreenSong.FixSelected2;
var
  I, I2: integer;
begin
  if CatSongs.VisibleSongs > 0 then
  begin
    I2:= 0;
    for I := Low(CatSongs.Song) to High(Catsongs.Song) do
    begin
      if CatSongs.Song[I].Visible then
        inc(I2);

      if I = Interaction - 1 then
        break;
    end;

    SongTarget  := I2;
  end;
end;
//Show Wrong Song when Tabs on Fix End

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
  //Statics[StaticCat].Texture := Texture.GetTexture(Button[Cat].Texture.Name, TEXTURE_TYPE_PLAIN, true);

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

// Method for input parsing. If false is returned, GetNextWindow
// should be checked to know the next window to load;
function TScreenSong.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var
  I:      integer;
  I2:     integer;
  SDL_ModState:  word;
  UpperLetter: UCS4Char;
  TempStr: UTF8String;
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

    SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT
    + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT);

    //Jump to Artist/Titel
    if ((SDL_ModState and KMOD_LALT <> 0) and (FreeListMode)) then
    begin
      UpperLetter := UCS4UpperCase(CharCode);

      if (UpperLetter in ([Ord('A')..Ord('Z'), Ord('0') .. Ord('9')]) ) then
      begin
        I2 := Length(CatSongs.Song);

        //Jump To Titel
        if (SDL_ModState = (KMOD_LALT or KMOD_LSHIFT)) then
        begin
          for I := 1 to High(CatSongs.Song) do
          begin
            if (CatSongs.Song[(I + Interaction) mod I2].Visible) then
            begin
              TempStr := CatSongs.Song[(I + Interaction) mod I2].Title;
              if (Length(TempStr) > 0) and
                 (UCS4UpperCase(UTF8ToUCS4String(TempStr)[0]) = UpperLetter) then
              begin
                SkipTo(CatSongs.VisibleIndex((I + Interaction) mod I2));

                AudioPlayback.PlaySound(SoundLib.Change);

                SetScroll4;
                //Break and Exit
                Exit;
              end;
            end;
          end;
        end
        //Jump to Artist
        else if (SDL_ModState = KMOD_LALT) then
        begin
          for I := 1 to High(CatSongs.Song) do
          begin
            if (CatSongs.Song[(I + Interaction) mod I2].Visible) then
            begin
              TempStr := CatSongs.Song[(I + Interaction) mod I2].Artist;
              if (Length(TempStr) > 0) and
                 (UCS4UpperCase(UTF8ToUCS4String(TempStr)[0]) = UpperLetter) then
              begin
                SkipTo(CatSongs.VisibleIndex((I + Interaction) mod I2));

                AudioPlayback.PlaySound(SoundLib.Change);

                SetScroll4;

                //Break and Exit
                Exit;
              end;
            end;
          end;
        end;
      end;

      Exit;
    end;

    // **********************
    // * workaround for LCTRL+R: it should be changed when we have a solution for the
    // * CTRL+'A'..'Z' problem
    if (SDL_ModState = KMOD_LCTRL) and (PressedKey = SDLK_R) then
      CharCode := UCS4Char('R');
    // **********************

    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;

      Ord('F'):
        begin
          if (PlayMidi) then
          begin
            if (SoundfontMan.CurSoundfont < High(SoundFontMan.Soundfonts)) then
              SoundfontMan.CurSoundfont := SoundfontMan.CurSoundfont + 1
            else
              SoundfontMan.CurSoundfont := 0;

            SoundfontMan.SetSoundfont(SoundfontMan.CurSoundfont, fStream);
            WriteMessage(UTF8Encode(SoundfontMan.Soundfonts[SoundfontMan.CurSoundfont].Name));
            Ini.SaveSoundFont(UTF8Encode(SoundfontMan.Soundfonts[SoundfontMan.CurSoundfont].Name));
          end;
        end;

      Ord('M'): //Show SongMenu
        begin
          if (Songs.SongList.Count > 0) then
          begin
            if (FreeListMode) and (Mode <> smPartyFree) and (Mode <> smPartyTournament) then
            begin
              if (not CatSongs.Song[Interaction].Main) then // clicked on Song
              begin
                if CatSongs.CatNumShow = -3 then
                begin
                  ScreenSongMenu.OnShow;
                  ScreenSongMenu.MenuShow(SM_Playlist);
                end
                else
                begin
                  ScreenSongMenu.OnShow;
                  ScreenSongMenu.MenuShow(SM_Main);
                end;
              end
              else
              begin
                ScreenSongMenu.OnShow;
                ScreenSongMenu.MenuShow(SM_Playlist_Load);
              end;
            end //Party Mode -> Show Party Menu
            else
            begin
              ScreenSongMenu.OnShow;
              if (Mode <> smPartyFree) and (Mode <> smPartyTournament) then
                ScreenSongMenu.MenuShow(SM_Party_Main)
              else
                ScreenSongMenu.MenuShow(SM_Party_Free_Main);
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

      Ord('E'):
        begin
          OpenEditor;
          Exit;
        end;

      Ord('S'):
        begin
          if (SDL_ModState = KMOD_LSHIFT) and not MakeMedley and
            (CatSongs.Song[Interaction].Medley.Source>=msCalculated) and
            (Mode = smNormal)then
            StartMedley(0, msCalculated)
          else if (CatSongs.Song[Interaction].Medley.Source>=msTag) and not MakeMedley and
            (Mode = smNormal) then
            StartMedley(0, msTag);
        end;

      Ord('D'):
        begin
          if (Mode = smNormal) and (SDL_ModState = KMOD_LSHIFT) and not MakeMedley and
            (length(getVisibleMedleyArr(msCalculated))>0) then
            StartMedley(5, msCalculated)
          else if (Mode = smNormal) and (Length(getVisibleMedleyArr(msTag)) > 0)
            and not MakeMedley then
            StartMedley(5, msTag);
        end;

      Ord('R'):
        begin
          if (Songs.SongList.Count > 0) and
             (FreeListMode) then
          begin
            if (SDL_ModState = KMOD_LSHIFT) and (Ini.TabsAtStartup = 1) then // random category
            begin
              I2 := 0; // count cats
              for I := 0 to High(CatSongs.Song) do
              begin
                if CatSongs.Song[I].Main then
                  Inc(I2);
              end;

              I2 := Random(I2 + 1); // random and include I2

              // find cat:
              for I := 0 to High(CatSongs.Song) do
                begin
                if CatSongs.Song[I].Main then
                  Dec(I2);
                if (I2 <= 0) then
                begin
                  // show cat in top left mod
                  ShowCatTL (I);

                  Interaction := I;

                  CatSongs.ShowCategoryList;
                  CatSongs.ClickCategoryButton(I);
                  SelectNext;
                  FixSelected;
                  break;
                end;
              end;
            end
            else if (SDL_ModState = KMOD_LCTRL) and (Ini.TabsAtStartup = 1) then // random in all categories
            begin
              repeat
                I2 := Random(High(CatSongs.Song) + 1);
              until (not CatSongs.Song[I2].Main);

              // search cat
              for I := I2 downto 0 do
              begin
              if CatSongs.Song[I].Main then
                break;
              end;

              // in I is now the categorie in I2 the song

              // choose cat
              CatSongs.ShowCategoryList;

              // show cat in top left mod
              ShowCatTL (I);

              CatSongs.ClickCategoryButton(I);
              SelectNext;

              // Fix: not existing song selected:
              //if (I + 1 = I2) then
                Inc(I2);

              // choose song
              SkipTo(I2 - I);
            end
            else // random in one category
            begin
              SkipTo(Random(CatSongs.VisibleSongs));
            end;
            AudioPlayback.PlaySound(SoundLib.Change);

            SetScroll4;
          end;
          Exit;
        end;
    end; // normal keys

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          CloseMessage();

          if (FreeListMode) then
          begin
            //On Escape goto Cat-List Hack
            if (Ini.TabsAtStartup = 1) and (CatSongs.CatNumShow <> -1) then
              begin
              //Find Category
              I := Interaction;
              while (not CatSongs.Song[I].Main) do
              begin
                Dec(I);
                if (I < 0) then
                  break;
              end;
              if (I <= 1) then
                Interaction := High(CatSongs.Song)
              else
                Interaction := I - 1;

              //Stop Music
              StopMusicPreview();

              CatSongs.ShowCategoryList;

              //Show Cat in Top Left Mod
              HideCatTL;

              //Show Wrong Song when Tabs on Fix
              SelectNext;
              FixSelected;
              //SelectPrev(true);
              //CatSongs.Song[0].Visible := false;
              end
            else
            begin
            //On Escape goto Cat-List Hack End
              //Tabs off and in Search or Playlist -> Go back to Song view
              if (CatSongs.CatNumShow < -1) then
              begin
                //Atm: Set Empty Filter
                CatSongs.SetFilter('', fltAll);

                //Show Cat in Top Left Mod
                HideCatTL;
                Interaction := 0;

                //Show Wrong Song when Tabs on Fix
                SelectNext;
                FixSelected;
              end
              else
              begin
                StopMusicPreview();
                AudioPlayback.PlaySound(SoundLib.Back);

                //CurrentPartyTime := MAX_TIME - StrToInt(Text[TextPartyTime].Text);

                case Mode of
                  smPartyFree: FadeTo(@ScreenPartyNewRound);
                  smPartyJukebox: FadeTo(@ScreenPartyOptions);
                  smPartyTournament: FadeTo(@ScreenPartyTournamentRounds);
                  else FadeTo(@ScreenMain);
                end;

              end;

            end;
          end
          //When in party Mode then Ask before Close
          else if (Mode = smPartyClassic) then
          begin
            AudioPlayback.PlaySound(SoundLib.Back);
            CheckFadeTo(@ScreenMain,'MSG_END_PARTY');
          end;
        end;
      SDLK_RETURN:
        begin
          CloseMessage();

          if (Songs.SongList.Count > 0) then
          begin
            if CatSongs.Song[Interaction].Main then
            begin // clicked on Category Button
              //Show Cat in Top Left Mod
              ShowCatTL (Interaction);

              //I := CatSongs.VisibleIndex(Interaction);
              CatSongs.ClickCategoryButton(Interaction);
              {I2 := CatSongs.VisibleIndex(Interaction);
              SongCurrent := SongCurrent - I + I2;
              SongTarget := SongTarget - I + I2; }

              //  SetScroll4;

              //Show Wrong Song when Tabs on Fix
              SelectNext;
              FixSelected;
            end
            else
            begin // clicked on song
              // Duets Warning
              if (CatSongs.Song[Interaction].isDuet) and (Mode <> smNormal) then
              begin
                ScreenPopupError.ShowPopup(Language.Translate('SING_ERROR_DUET_MODE_PARTY'));
                Exit;
              end;

              {
              if (CatSongs.Song[Interaction].isDuet and ((PlayersPlay=1) or
                (PlayersPlay=3) or (PlayersPlay=6))) then
              begin
                ScreenPopupError.ShowPopup(Language.Translate('SING_ERROR_DUET_NUM_PLAYERS'));
                Exit;
              end;
              }
              
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

                if (Mode = smPartyJukebox) then
                begin
                  //if (Length(JukeboxSongsList) > 0) then
                  //  StartSong
                  //else
                  //  ScreenPopupError.ShowPopup(Language.Translate('PARTY_MODE_JUKEBOX_NO_SONGS'));
                end;
              end;
          end;
        end;

      SDLK_DOWN:
        begin
          CloseMessage();

          if (FreeListMode) then
          begin
            //Only Change Cat when not in Playlist or Search Mode
            if (CatSongs.CatNumShow > -2) then
            begin
              //Cat Change Hack
              if Ini.TabsAtStartup = 1 then
              begin
                I := Interaction;
                if I <= 0 then
                  I := 1;

                while not catsongs.Song[I].Main do
                begin
                  Inc (I);
                  if (I > High(catsongs.Song)) then
                    I := Low(catsongs.Song);
                end;

                Interaction := I;

                //Show Cat in Top Left Mod
                ShowCatTL (Interaction);

                CatSongs.ClickCategoryButton(Interaction);
                SelectNext;
                FixSelected;

                //Play Music:
                AudioPlayback.PlaySound(SoundLib.Change);
              end;

            //
            //Cat Change Hack End}
            end;
          end;
        end;
      SDLK_UP:
        begin
          CloseMessage();

          if (FreeListMode) then
          begin
            //Only Change Cat when not in Playlist or Search Mode
            if (CatSongs.CatNumShow > -2) then
            begin
              //Cat Change Hack
              if Ini.TabsAtStartup = 1 then
              begin
                I := Interaction;
                I2 := 0;
                if I <= 0 then
                  I := 1;

                while not catsongs.Song[I].Main or (I2 = 0) do
                begin
                  if catsongs.Song[I].Main then
                    Inc(I2);
                  Dec (I);
                  if (I < Low(catsongs.Song)) then
                    I := High(catsongs.Song);
                end;

                Interaction := I;

                //Show Cat in Top Left Mod
                ShowCatTL (I);

                CatSongs.ClickCategoryButton(I);
                SelectNext;
                FixSelected;

                //Play Music:
                AudioPlayback.PlaySound(SoundLib.Change);
              end;
            end;
            //Cat Change Hack End}
          end;
        end;

      SDLK_RIGHT:
        begin
          CloseMessage();

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
              AudioPlayback.PlaySound(SoundLib.Change);
              SelectNext;
              SetScroll4;
            end;
          end;
        end;

      SDLK_LEFT:
        begin
          CloseMessage();

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
              AudioPlayback.PlaySound(SoundLib.Change);
              SelectPrev;
              SetScroll4;
            end;
          end;
        end;
      SDLK_SPACE:
        begin
          if (CatSongs.Song[Interaction].isDuet) then
            DuetChange := not DuetChange;
        end;
      SDLK_1:
        begin //Joker
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(0);
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
              OffMidiChannel(10);
            end
            else
              DoJoker(0);
            end;
        end;

      SDLK_2:
        begin //Joker
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(1);
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
              OffMidiChannel(11);
            end
            else
              DoJoker(1);
          end;

        end;

      SDLK_3:
        begin //Joker
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(2);
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
              OffMidiChannel(12);
            end
            else
              DoJoker(2);
          end;
        end;

      SDLK_4:
        begin
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(3);
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
              OffMidiChannel(13);
            end;
          end;
        end;

      SDLK_5:
        begin
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(4);
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
              OffMidiChannel(14);
            end;
          end;
        end;

      SDLK_6:
        begin
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(5);
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
              OffMidiChannel(15);
            end;
          end;
        end;

      SDLK_7:
        begin
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(6);
          end;
        end;

      SDLK_8:
        begin
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(7);
          end;
        end;

      SDLK_9:
        begin
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(8);
          end;
        end;

      SDLK_0:
        begin
          if (SDL_ModState = KMOD_LSHIFT) then
          begin
            OffMidiChannel(9);
          end
          else
          begin
            if (SDL_ModState = KMOD_LCTRL) then
            begin
              ResetMidiChannelVolume();
            end;
          end
        end;
    end;
  end; // if (PressedDown)
end;

procedure TScreenSong.ResetMidiChannelVolume();
var
  I: integer;
begin
  if (PlayMidi) then
  begin
    for I := 0 to 15 do
      BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, 127);

    ScreenSing.ChannelOff := -1;

    WriteMessage(Language.Translate('INFO_MIDI_CHANNEL_RESET'));
  end;
end;

procedure TScreenSong.OffMidiChannel(channel: integer);
begin
  if (PlayMidi) then
  begin
    ResetMidiChannelVolume();
    BASS_MIDI_StreamEvent(fstream, channel, MIDI_EVENT_MIXLEVEL, 0);

    ScreenSing.ChannelOff := channel;

    WriteMessage(Format(Language.Translate('INFO_MIDI_CHANNEL_OFF'), [IntToStr(channel + 1)]));
  end;
end;

function TScreenSong.ParseMouse(MouseButton: integer; BtnDown: boolean; X, Y: integer): boolean;
  var
    I, J: Integer;
    Btn: Integer;
begin
  Result := true;

  if (ScreenSongMenu.Visible) then
  begin
    Result := ScreenSongMenu.ParseMouse(MouseButton, BtnDown, X, Y);
    exit;
  end
  else if (ScreenSongJumpTo.Visible) then
  begin
    Result := ScreenSongJumpTo.ParseMouse(MouseButton, BtnDown, X, Y);
    exit;
  end
  else // no extension visible
  begin
    if (BtnDown) then
    begin
      //if RightMbESC is set, send ESC keypress
      if RightMbESC and (MouseButton = SDL_BUTTON_RIGHT) then
        Result:=ParseInput(SDLK_ESCAPE, 0, true)

     //song scrolling with mousewheel
      else if (MouseButton = SDL_BUTTON_WHEELDOWN) then
        ParseInput(SDLK_RIGHT, 0, true)

      else if (MouseButton = SDL_BUTTON_WHEELUP) then
        ParseInput(SDLK_LEFT, 0, true)

      //LMB anywhere starts
      else if (MouseButton = SDL_BUTTON_LEFT) then
      begin
        if (CatSongs.VisibleSongs > 4) then
        begin
          // select the second visible button left from selected
          I := 0;
          Btn := Interaction;
          while (I < 2) do
          begin
            Dec(Btn);
            if (Btn < 0) then
              Btn := High(CatSongs.Song);

            if (CatSongs.Song[Btn].Visible) then
              Inc(I);
          end;

          // test the 5 front buttons for click
          for I := 0 to 4 do
          begin

            if InRegion(X, Y, Button[Btn].GetMouseOverArea) then
            begin
              // song cover clicked
              if (I = 2) then
              begin // Selected Song clicked -> start singing
                ParseInput(SDLK_RETURN, 0, true);
              end
              else
              begin // one of the other 4 covers in the front clicked -> select it
                J := I - 2;
                while (J < 0) do
                begin
                  ParseInput(SDLK_LEFT, 0, true);
                  Inc(J);
                end;

                while (J > 0) do
                begin
                  ParseInput(SDLK_RIGHT, 0, true);
                  Dec(J);
                end;
              end;
              Break;
            end;

            Btn := CatSongs.FindNextVisible(Btn);
            if (Btn = -1) then
              Break;
          end;
        end
        else
          ParseInput(SDLK_RETURN, 0, true);
      end;
    end;
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
  i: integer;
begin
  inherited Create;

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

  //TextPartyTime := AddText(Theme.Song.TextPartyTime);

  SetLength(StaticNonParty, Length(Theme.Song.StaticNonParty));
  for i := 0 to High(Theme.Song.StaticNonParty) do
    StaticNonParty[i] := AddStatic(Theme.Song.StaticNonParty[i]);

  SetLength(TextNonParty, Length(Theme.Song.TextNonParty));
  for i := 0 to High(Theme.Song.TextNonParty) do
    TextNonParty[i] := AddText(Theme.Song.TextNonParty[i]);

  // Song List
  //Songs.LoadSongList; // moved to the UltraStar unit
  CatSongs.Refresh;

  GenerateThumbnails();

  // Randomize Patch
  Randomize;

  Equalizer := Tms_Equalizer.Create(AudioPlayback, Theme.Song.Equalizer);

  PreviewOpened := -1;
  isScrolling := false;

  fCurrentVideo := nil;

  // Info Message
  InfoMessageBG := AddStatic(Theme.Song.InfoMessageBG);
  InfoMessageText := AddText(Theme.Song.InfoMessageText);

  // Duet Names Singers
  TextDuetSingerP1 := AddText(Theme.Song.TextDuetSingerP1);
  TextDuetSingerP2 := AddText(Theme.Song.TextDuetSingerP2);
  StaticDuetSingerP1 := AddStatic(Theme.Song.StaticDuetSingerP1);
  StaticDuetSingerP2 := AddStatic(Theme.Song.StaticDuetSingerP2);

  // Medley Playlist
  for I := 1 to 4 do
  begin
    TextMedleyArtist[I] := AddText(Theme.Song.TextArtistMedley[I]);
    TextMedleyTitle[I] := AddText(Theme.Song.TextTitleMedley[I]);
    TextMedleyNumber[I] := AddText(Theme.Song.TextNumberMedley[I]);
    StaticMedley[I] := AddStatic(Theme.Song.StaticMedley[I]);
  end;

end;

procedure TScreenSong.ColorDuetNameSingers();
var
  Col: TRGB;
begin
  if (PlayersPlay = 2) then
  begin
    Statics[StaticDuetSingerP1].Texture.ColR := ColPlayer[0].R;
    Statics[StaticDuetSingerP1].Texture.ColG := ColPlayer[0].G;
    Statics[StaticDuetSingerP1].Texture.ColB := ColPlayer[0].B;

    Statics[StaticDuetSingerP2].Texture.ColR := ColPlayer[1].R;
    Statics[StaticDuetSingerP2].Texture.ColG := ColPlayer[1].G;
    Statics[StaticDuetSingerP2].Texture.ColB := ColPlayer[1].B;
  end;

  if (PlayersPlay = 4) then
  begin
    if (ScreenAct = 1) then
    begin
      Statics[StaticDuetSingerP1].Texture.ColR := ColPlayer[0].R;
      Statics[StaticDuetSingerP1].Texture.ColG := ColPlayer[0].G;
      Statics[StaticDuetSingerP1].Texture.ColB := ColPlayer[0].B;

      Statics[StaticDuetSingerP2].Texture.ColR := ColPlayer[1].R;
      Statics[StaticDuetSingerP2].Texture.ColG := ColPlayer[1].G;
      Statics[StaticDuetSingerP2].Texture.ColB := ColPlayer[1].B;
    end;

    if (ScreenAct = 2) then
    begin
      Statics[StaticDuetSingerP1].Texture.ColR := ColPlayer[2].R;
      Statics[StaticDuetSingerP1].Texture.ColG := ColPlayer[2].G;
      Statics[StaticDuetSingerP1].Texture.ColB := ColPlayer[2].B;

      Statics[StaticDuetSingerP2].Texture.ColR := ColPlayer[3].R;
      Statics[StaticDuetSingerP2].Texture.ColG := ColPlayer[3].G;
      Statics[StaticDuetSingerP2].Texture.ColB := ColPlayer[3].B;
    end;
  end;

end;

procedure TScreenSong.GenerateThumbnails();
var
  I: integer;
  CoverButtonIndex: integer;
  CoverButton: TButton;
  CoverTexture: TTexture;
  Cover: TCover;
  CoverFile: IPath;
  Song: TSong;
begin
  if (Length(CatSongs.Song) <= 0) then
    Exit;

  // set length of button array once instead for every song
  SetButtonLength(Length(CatSongs.Song));

  // create all buttons
  for I := 0 to High(CatSongs.Song) do
  begin
    CoverButton := nil;

    // create a clickable cover
    CoverButtonIndex := AddButton(300 + I*250, 140, 200, 200, PATH_NONE, TEXTURE_TYPE_PLAIN, Theme.Song.Cover.Reflections);
    if (CoverButtonIndex > -1) then
      CoverButton := Button[CoverButtonIndex];
    if (CoverButton = nil) then
      Continue;

    Song := CatSongs.Song[I];

    CoverFile := Song.Path.Append(Song.Cover);
    if (not CoverFile.IsFile()) then
      Song.Cover := PATH_NONE;

    if (Song.Cover.IsUnset) then
      CoverFile := Skin.GetTextureFileName('SongCover');

    // load cover and cache its texture
    Cover := Covers.FindCover(CoverFile);
    if (Cover = nil) then
      Cover := Covers.AddCover(CoverFile);

    // use the cached texture
    // TODO: this is a workaround until the new song-loading works.
    // The TCover object should be added to the song-object. The thumbnails
    // should be loaded each time the song-screen is shown (it is real fast).
    // This way, we will not waste that much memory and have a link between
    // song and cover.

    if (Cover <> nil) then
    begin
      CoverTexture := Cover.GetPreviewTexture();
      //Texture.AddTexture(CoverTexture, TEXTURE_TYPE_PLAIN, false);
      CoverButton.Texture := CoverTexture;

      Song.CoverTex := CoverTexture;

      // set selected to false -> the right texture will be displayed
      CoverButton.Selected := False;
    end;

    Cover.Free;
  end;

  // reset selection
  if (Length(CatSongs.Song) > 0) then
    Interaction := 0;
end;

{ called when song flows movement stops at a song }
procedure TScreenSong.OnSongSelect;
begin
  if (Ini.PreviewVolume <> 0) then
  begin
    StartMusicPreview;
    StartVideoPreview;
  end;

  // fade in detailed cover
  CoverTime := 0;
end;

{ called before current song is deselected }
procedure TScreenSong.OnSongDeSelect;
begin
  DuetChange := false;

  CoverTime := 10;
  //UnLoadDetailedCover;

  StopMusicPreview();
  StopVideoPreview();
  PreviewOpened := -1;
end;

procedure TScreenSong.SetScroll;
var
  VS, B, I: integer;
begin
  VS := CatSongs.VisibleSongs;
  if VS > 0 then
  begin

    // Set Positions
    case Theme.Song.Cover.Style of
      3: SetScroll3;
      5: SetScroll5;
      6: SetScroll6;
      else SetScroll4;
    end;

    // Set visibility of video icon
    Statics[VideoIcon].Visible := CatSongs.Song[Interaction].Video.IsSet;

    // Set visibility of medley icons
    Statics[MedleyIcon].Visible := (CatSongs.Song[Interaction].Medley.Source = msTag);
    Statics[CalcMedleyIcon].Visible := (CatSongs.Song[Interaction].Medley.Source = msCalculated);

    //Set Visibility of Duet Icon
    Statics[DuetIcon].Visible := CatSongs.Song[Interaction].isDuet;

    // Set texts
    Text[TextArtist].Text := CatSongs.Song[Interaction].Artist;
    Text[TextTitle].Text  :=  CatSongs.Song[Interaction].Title;

    if ((Ini.Tabs = 0) or (TSortingType(Ini.Sorting) <> sYear))
      and ((CatSongs.Song[Interaction].Year <> 'Unknown') and (CatSongs.Song[Interaction].Year <> '')) then
        Text[TextYear].Text  :=  '(' + CatSongs.Song[Interaction].Year + ')'
    else
      Text[TextYear].Text  :=  '';

    // Duet Singers
    if (CatSongs.Song[Interaction].isDuet) then
    begin
      Text[TextDuetSingerP1].Visible := true;
      Text[TextDuetSingerP2].Visible := true;

      Statics[StaticDuetSingerP1].Visible := true;
      Statics[StaticDuetSingerP2].Visible := true;

      // Set duet texts
      if (DuetChange) then
      begin
        Text[TextDuetSingerP1].Text := CatSongs.Song[Interaction].DuetNames[1];
        Text[TextDuetSingerP2].Text := CatSongs.Song[Interaction].DuetNames[0];
      end
      else
      begin
        Text[TextDuetSingerP1].Text := CatSongs.Song[Interaction].DuetNames[0];
        Text[TextDuetSingerP2].Text := CatSongs.Song[Interaction].DuetNames[1];
      end;
    end
    else
    begin
      Text[TextDuetSingerP1].Visible := false;
      Text[TextDuetSingerP2].Visible := false;

      Statics[StaticDuetSingerP1].Visible := false;
      Statics[StaticDuetSingerP2].Visible := false;
    end;

    //Set Song Score
    SongScore;

    if (Ini.TabsAtStartup = 1) and (CatSongs.CatNumShow = -1) then
    begin
      Text[TextNumber].Text := IntToStr(CatSongs.Song[Interaction].OrderNum) + '/' + IntToStr(CatSongs.CatCount);
      Text[TextTitle].Text  := '(' + IntToStr(CatSongs.Song[Interaction].CatNumber) + ' ' + Language.Translate('SING_SONGS_IN_CAT') + ')';
    end
    else if (CatSongs.CatNumShow = -2) then
      Text[TextNumber].Text := IntToStr(CatSongs.VisibleIndex(Interaction)+1) + '/' + IntToStr(VS)
    else if (CatSongs.CatNumShow = -3) then
      Text[TextNumber].Text := IntToStr(CatSongs.VisibleIndex(Interaction)+1) + '/' + IntToStr(VS)
    else if (Ini.TabsAtStartup = 1) then
      Text[TextNumber].Text := IntToStr(CatSongs.Song[Interaction].CatNumber) + '/' + IntToStr(CatSongs.Song[Interaction - CatSongs.Song[Interaction].CatNumber].CatNumber)
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

(*
procedure TScreenSong.SetScroll1;
var
  B:      integer;    // button
  Src:    integer;
  //Dst:    integer;
  Count:  integer;    // Dst is not used. Count is used.
  Ready:  boolean;

  VisCount: integer;  // count of visible (or selectable) buttons
  VisInt:   integer;  // visible position of interacted button
  Typ:      integer;  // 0 when all songs fits the screen
  Placed:   integer;  // number of placed visible buttons
begin
  //Src := 0;
  //Dst := -1;
  Count := 1;
  Typ := 0;
  Ready := false;
  Placed := 0;

  VisCount := 0;
  for B := 0 to High(Button) do
    if CatSongs.Song[B].Visible then
      Inc(VisCount);

  VisInt := 0;
  for B := 0 to Interaction-1 do
    if CatSongs.Song[B].Visible then
      Inc(VisInt);

  if VisCount <= 6 then
  begin
    Typ := 0;
  end
  else
  begin
    if VisInt <= 3 then
    begin
      Typ := 1;
      Count := 7;
      Ready := true;
    end;

    if (VisCount - VisInt) <= 3 then
    begin
      Typ := 2;
      Count := 7;
      Ready := true;
    end;

    if not Ready then
    begin
      Typ := 3;
      Src := Interaction;
    end;
  end;


  // hide all buttons
  for B := 0 to High(Button) do
  begin
    Button[B].Visible := false;
    Button[B].Selectable := CatSongs.Song[B].Visible;
  end;

  {
  for B := Src to Dst do
  begin
    //Button[B].Visible := true;
    Button[B].Visible := CatSongs.Song[B].Visible;
    Button[B].Selectable := Button[B].Visible;
    Button[B].Y := 140 + (B-Src) * 60;
  end;
  }

  if Typ = 0 then
  begin
    for B := 0 to High(Button) do
    begin
      if CatSongs.Song[B].Visible then
      begin
        Button[B].Visible := true;
        Button[B].Y := 140 + (Placed) * 60;
        Inc(Placed);
      end;
    end;
  end;

  if Typ = 1 then
  begin
    B := 0;
    while (Count > 0) do
    begin
      if CatSongs.Song[B].Visible then
      begin
        Button[B].Visible := true;
        Button[B].Y := 140 + (Placed) * 60;
        Inc(Placed);
        Dec(Count);
      end;
      Inc(B);
    end;
  end;

  if Typ = 2 then
  begin
    B := High(Button);
    while (Count > 0) do
    begin
      if CatSongs.Song[B].Visible then
      begin
        Button[B].Visible := true;
        Button[B].Y := 140 + (6-Placed) * 60;
        Inc(Placed);
        Dec(Count);
      end;
      Dec(B);
    end;
  end;

  if Typ = 3 then
  begin
    B := Src;
    Count := 4;
    while (Count > 0) do
    begin
      if CatSongs.Song[B].Visible then
      begin
        Button[B].Visible := true;
        Button[B].Y := 140 + (3+Placed) * 60;
        Inc(Placed);
        Dec(Count);
      end;
      Inc(B);
    end;

    B := Src-1;
    Placed := 0;
    Count := 3;
    while (Count > 0) do
    begin
      if CatSongs.Song[B].Visible then
      begin
        Button[B].Visible := true;
        Button[B].Y := 140 + (2-Placed) * 60;
        Inc(Placed);
        Dec(Count);
      end;
      Dec(B);
    end;

  end;

  if Length(Button) > 0 then
    Statics[1].Texture.Y := Button[Interaction].Y - 5; // selection texture
end;

procedure TScreenSong.SetScroll2;
var
  B:      integer;
  //Factor:    integer; // factor of position relative to center of screen
  //Factor2:   real;
begin
  // line
  for B := 0 to High(Button) do
    Button[B].X := 300 + (B - Interaction) * 260;

  if Length(Button) >= 3 then
  begin
    if Interaction = 0 then
      Button[High(Button)].X := 300 - 260;

    if Interaction = High(Button) then
      Button[0].X := 300 + 260;
  end;

  // circle
  {
  for B := 0 to High(Button) do
  begin
    Factor := (B - Interaction); // 0 to center, -1: to left, +1 to right
    Factor2 := Factor / Length(Button);
    Button[B].X := 300 + 10000 * sin(2*pi*Factor2);
    //Button[B].Y := 140 + 50 * ;
  end;
  }
end;
*)

procedure TScreenSong.SetScroll3; // with slide
var
  B:      integer;
  //Factor:    integer; // factor of position relative to center of screen
  //Factor2:   real;
begin
  SongTarget := Interaction;

  // line
  for B := 0 to High(Button) do
  begin
    Button[B].X := 300 + (B - SongCurrent) * 260;
    if (Button[B].X < -Button[B].W) or (Button[B].X > 800) then
      Button[B].Visible := false
    else
      Button[B].Visible := true;
  end;

  {
  if Length(Button) >= 3 then
  begin
    if Interaction = 0 then
      Button[High(Button)].X := 300 - 260;

    if Interaction = High(Button) then
      Button[0].X := 300 + 260;
  end;
  }

  // circle
  {
  for B := 0 to High(Button) do
  begin
    Factor := (B - Interaction); // 0 to center, -1: to left, +1 to right
    Factor2 := Factor / Length(Button);
    Button[B].X := 300 + 10000 * sin(2*pi*Factor2);
    //Button[B].Y := 140 + 50 * ;
  end;
  }
end;

(**
 * Rotation
 *)
procedure TScreenSong.SetScroll4;
var
  B:      integer;
  Angle:  real;
  Z, Z2:  real;
  VS:     integer;
begin
  VS := CatSongs.VisibleSongs();

  for B := 0 to High(Button) do
  begin
    Button[B].Visible := CatSongs.Song[B].Visible;
    if Button[B].Visible then
    begin
      // angle between the cover and selected song-cover in radians
      Angle := 2*Pi * (CatSongs.VisibleIndex(B) - SongCurrent) /  VS;

      // calc z-position from angle
      Z := (1 + cos(Angle)) / 2;  // scaled to range [0..1]
      Z2 := (1 + 2*Z) / 3;        // scaled to range [1/3..1]

      // adjust cover's width and height according its z-position
      // Note: Theme.Song.Cover.W is not used as width and height are equal
      //   and Theme.Song.Cover.W is used as circle radius in Scroll5.
      Button[B].W := Theme.Song.Cover.H * Z2;
      Button[B].H := Button[B].W;

      // set cover position
      Button[B].X := Theme.Song.Cover.X +
                     (0.185 * Theme.Song.Cover.H * VS * sin(Angle)) * Z2 -
                     ((Button[B].H - Theme.Song.Cover.H)/2);
      Button[B].Y := Theme.Song.Cover.Y  +
                     (Theme.Song.Cover.H - Abs(Button[B].H)) * 0.7;
      Button[B].Z := Z / 2 + 0.3;
    end;
  end;
end;

(**
 * rotate
 *)
procedure TScreenSong.SetScroll5;
var
  B:      integer;
  Angle:    real;
  Pos:    real;
  VS:     integer;
  Padding:     real;
  X:        real;
  {
  Theme.Song.CoverW: circle radius
  Theme.Song.CoverX: x-pos. of the left edge of the selected cover
  Theme.Song.CoverY: y-pos. of the upper edge of the selected cover
  Theme.Song.CoverH: cover height
  }
begin
  VS := CatSongs.VisibleSongs();

  // Update positions of all buttons
  for B := 0 to High(Button) do
  begin
    Button[B].Visible := CatSongs.Song[B].Visible; // adjust visibility
    if Button[B].Visible then // Only change pos for visible buttons
    begin
      // Pos is the distance to the centered cover in the range [-VS/2..+VS/2]
      Pos := (CatSongs.VisibleIndex(B) - SongCurrent);
      if (Pos < -VS/2) then
        Pos := Pos + VS
      else if (Pos > VS/2) then
        Pos := Pos - VS;

      // Avoid overlapping of the front covers.
      // Use an alternate position for the five front covers.
      if (Abs(Pos) < 2.5) then
      begin
        Angle := Pi * (Pos / Min(VS, 5)); // Range: (-1/4*Pi .. +1/4*Pi)

        Button[B].H := Abs(Theme.Song.Cover.H * cos(Angle*0.8));
        Button[B].W := Button[B].H;

        //Button[B].Reflectionspacing := 15 * Button[B].H/Theme.Song.Cover.H;
        Button[B].DeSelectReflectionspacing := 15 * Button[B].H/Theme.Song.Cover.H;

        Padding := (Button[B].H - Theme.Song.Cover.H)/2;
        X := Sin(Angle*1.3) * 0.9;

        Button[B].X := Theme.Song.Cover.X + Theme.Song.Cover.W * X - Padding;
        Button[B].Y := (Theme.Song.Cover.Y  + (Theme.Song.Cover.H - Abs(Theme.Song.Cover.H * cos(Angle))) * 0.5);
        Button[B].Z := 0.95 - Abs(Pos) * 0.01;

        if VS < 5 then
          Button[B].Texture.Alpha := 1 - Abs(Pos) / VS  * 2
        else
          Button[B].Texture.Alpha := 1;
      end
      { only draw 3 visible covers in the background
        (the 3 that are on the opposite of the front covers}
      else if (VS > 7) and (Abs(Pos) > floor(VS/2) - 1.5) then
      begin
        // Transform Pos to range [-1..-3/4, +3/4..+1]
        { the 3 covers at the back will show up in the gap between the
          front cover and its neighbors
          one cover will be hiddenbehind the front cover,
          but this will not be a lack of performance ;) }
        if Pos < 0 then
          Pos := (Pos - 2 + ceil(VS/2))/8 - 0.75
        else
          Pos := (Pos + 2 - floor(VS/2))/8 + 0.75;

        // angle in radians [-2Pi..-Pi, +Pi..+2Pi]
        Angle := 2*Pi * Pos;

        Button[B].H := 0.6*(Theme.Song.Cover.H-Abs(Theme.Song.Cover.H * cos(Angle/2)*0.8));
        Button[B].W := Button[B].H;

        Padding := (Button[B].H - Theme.Song.Cover.H)/2;

        Button[B].X :=  Theme.Song.Cover.X+Theme.Song.Cover.H/2-Button[b].H/2+Theme.Song.Cover.W/320*((Theme.Song.Cover.H)*sin(Angle/2)*1.52);
        Button[B].Y := Theme.Song.Cover.Y  - (Button[B].H - Theme.Song.Cover.H)*0.75;
        Button[B].Z := (0.4 - Abs(Pos/4)) -0.00001; //z < 0.49999 is behind the cover 1 is in front of the covers

        Button[B].Texture.Alpha := 1;

        //Button[B].Reflectionspacing := 15 * Button[B].H/Theme.Song.Cover.H;
        Button[B].DeSelectReflectionspacing := 15 * Button[B].H/Theme.Song.Cover.H;
      end
      { all other covers are not visible }
      else
        Button[B].Visible := false;
    end;
  end;
end;

procedure TScreenSong.SetScroll6; // rotate (slotmachine style)
var
  B:      integer;
  Angle:  real;
  Pos:    real;
  VS:     integer;
  diff:   real;
  X:      real;
  Factor: real;
  Z, Z2:  real;
begin
  VS := CatSongs.VisibleSongs;

  if VS <= 5 then
  begin
    // circle
    for B := 0 to High(Button) do
    begin
      Button[B].Visible := CatSongs.Song[B].Visible;
      if Button[B].Visible then // optimization for 1000 songs - updates only visible songs, hiding in tabs becomes useful for maintaing good speed
      begin

        Factor := 2 * pi * (CatSongs.VisibleIndex(B) - SongCurrent) /  VS {CatSongs.VisibleSongs};// 0.5.0 (II): takes another 16ms

        Z := (1 + cos(Factor)) / 2;
        Z2 := (1 + 2*Z) / 3;

        Button[B].Y := Theme.Song.Cover.Y + (0.185 * Theme.Song.Cover.H * VS * sin(Factor)) * Z2 - ((Button[B].H - Theme.Song.Cover.H)/2); // 0.5.0 (I): 2 times faster by not calling CatSongs.VisibleSongs
        Button[B].Z := Z / 2 + 0.3;

        Button[B].W := Theme.Song.Cover.H * Z2;

        //Button[B].Y := {50 +} 140 + 50 - 50 * Z2;
        Button[B].X := Theme.Song.Cover.X  + (Theme.Song.Cover.H - Abs(Button[B].H)) * 0.7 ;
        Button[B].H := Button[B].W;
      end;
    end;
  end
  else
  begin
    //Change Pos of all Buttons
    for B := Low(Button) to High(Button) do
    begin
      Button[B].Visible := CatSongs.Song[B].Visible; //Adjust Visibility
      if Button[B].Visible then //Only Change Pos for Visible Buttons
      begin
        Pos := (CatSongs.VisibleIndex(B) - SongCurrent);
        if (Pos < -VS/2) then
          Pos := Pos + VS
        else if (Pos > VS/2) then
          Pos := Pos - VS;

        if (Abs(Pos) < 2.5) then {fixed Positions}
        begin
          Angle := Pi * (Pos / 5);
          //Button[B].Visible := false;

          Button[B].H := Abs(Theme.Song.Cover.H * cos(Angle*0.8));//Power(Z2, 3);

          Button[B].DeSelectReflectionspacing := 15 * Button[B].H/Theme.Song.Cover.H;

          Button[B].Z := 0.95 - Abs(Pos) * 0.01;

          Button[B].X := (Theme.Song.Cover.X  + (Theme.Song.Cover.H - Abs(Theme.Song.Cover.H * cos(Angle))) * 0.5);

          Button[B].W := Button[B].H;

          Diff := (Button[B].H - Theme.Song.Cover.H)/2;

          X := Sin(Angle*1.3)*0.9;

          Button[B].Y := Theme.Song.Cover.Y + Theme.Song.Cover.W * X - Diff;
        end
        else
        begin {Behind the Front Covers}

          // limit-bg-covers hack
          if (abs(VS/2-abs(Pos))>10) then
            Button[B].Visible := false;
          if VS > 25 then
            VS:=25;
          // end of limit-bg-covers hack

          if Pos < 0 then
            Pos := (Pos - VS/2)/VS
          else
            Pos := (Pos + VS/2)/VS;

          Angle := Pi * Pos*2;

          Button[B].Z := (0.4 - Abs(Pos/4)) -0.00001; //z < 0.49999 is behind the cover 1 is in front of the covers

          Button[B].H :=0.6*(Theme.Song.Cover.H-Abs(Theme.Song.Cover.H * cos(Angle/2)*0.8));//Power(Z2, 3);

          Button[B].W := Button[B].H;

          Button[B].X := Theme.Song.Cover.X  - (Button[B].H - Theme.Song.Cover.H)*0.5;

          Button[B].DeSelectReflectionspacing := 15 * Button[B].H/Theme.Song.Cover.H;

          Button[B].Y := Theme.Song.Cover.Y+Theme.Song.Cover.H/2-Button[b].H/2+Theme.Song.Cover.W/320*(Theme.Song.Cover.H*sin(Angle/2)*1.52);
        end;
      end;
    end;
  end;
end;

procedure TScreenSong.OnShow;
var
  I: integer;
begin
  inherited;

  CloseMessage();

  // for duet names
  ScreenSong.ColPlayer[0] := GetPlayerColor(Ini.SingColor[0]);
  ScreenSong.ColPlayer[1] := GetPlayerColor(Ini.SingColor[1]);
  ScreenSong.ColPlayer[2] := GetPlayerColor(Ini.SingColor[2]);
  ScreenSong.ColPlayer[3] := GetPlayerColor(Ini.SingColor[3]);

  //Text[TextPartyTime].Text := IntToStr(MAX_TIME);

  {**
 * Pause background music, so we can play it again on scorescreen
 *}
  SoundLib.PauseBgMusic;

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
  if (Ini.TabsAtStartup = 1) and (CatSongs.CatNumShow = -1) then
  begin
    CatSongs.ShowCategoryList;
    FixSelected;
    //Show Cat in Top Left Mod
    HideCatTL;
  end;

  if Length(CatSongs.Song) > 0 then
  begin
    SetScroll;
  end;

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

  isScrolling := false;
  SetJoker;
  SetStatics;
  {
  if (Mode = smPartyFree) then
    Text[TextPartyTime].Visible := true
  else
    Text[TextPartyTime].Visible := false;
  }
end;

procedure TScreenSong.OnShowFinish;
begin
  DuetChange := false;

  isScrolling := true;
  CoverTime := 10;

  //if (Mode = smPartyFree) then
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

procedure TScreenSong.DrawExtensions;
begin
  //Draw Song Menu
  if (ScreenSongMenu.Visible) then
  begin
    ScreenSongMenu.Draw;
  end
  else if (ScreenSongJumpto.Visible) then
  begin
    ScreenSongJumpto.Draw;
  end
end;

function TScreenSong.FinishedMusic: boolean;
begin

  if (PlayMidi) then
  begin
    if (LyricsState.TotalTime > BASS_ChannelBytes2Seconds(ScreenSing.fStream, BASS_ChannelGetPosition(ScreenSing.fStream, BASS_POS_BYTE))) then
      Result := false
    else
      Result := true;
  end
  else
    Result := AudioPlayback.Finished;

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

  if isScrolling then
  begin
    dx := SongTarget-SongCurrent;
    dt := TimeSkip * 7;

    if dt > 1 then
      dt := 1;

    SongCurrent := SongCurrent + dx*dt;

    if SameValue(SongCurrent, SongTarget, 0.002) and (CatSongs.VisibleSongs > 0) then
    begin
      isScrolling := false;
      SongCurrent := SongTarget;
      OnSongSelect;
    end;
  end;

  if (MidiFadeIn) then
    MidiFadeInPreview;

  {
  if SongCurrent > Catsongs.VisibleSongs then
  begin
    SongCurrent := SongCurrent - Catsongs.VisibleSongs;
    SongTarget := SongTarget - Catsongs.VisibleSongs;
  end;
  }

  //Log.BenchmarkStart(5);

  SetScroll;

  //Log.BenchmarkEnd(5);
  //Log.LogBenchmark('SetScroll4', 5);

  //Fading Functions, Only if Covertime is under 5 Seconds
  if (CoverTime < 9) then
  begin
    // cover fade
    if (CoverTime < 1) and (CoverTime + TimeSkip >= 1) then
    begin
      // load new texture
      Texture.GetTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN, false);
      Button[Interaction].Texture.Alpha := 1;
      Button[Interaction].Texture2 := Texture.GetTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN, false);
      Button[Interaction].Texture2.Alpha := 1;
    end;

    //Update Fading Time
    CoverTime := CoverTime + TimeSkip;

    //Update Fading Texture
    Button[Interaction].Texture2.Alpha := (CoverTime - 1) * 1.5;
    if Button[Interaction].Texture2.Alpha > 1 then
      Button[Interaction].Texture2.Alpha := 1;

  end;

  //inherited Draw;
  //heres a little Hack, that causes the Statics
  //are Drawn after the Buttons because of some Blending Problems.
  //This should cause no Problems because all Buttons on this screen
  //Has Z Position.
  //Draw BG
  DrawBG;

  //Medley Playlist
  if Length(PlaylistMedley.Song)>4 then
    J := Length(PlaylistMedley.Song)-4
  else
    J := 0;

  for I := 1 to 4 do
  begin
    if (Length(PlaylistMedley.Song)>= I + J) and (MakeMedley) then
    begin
      Text[TextMedleyArtist[I]].Visible := true;
      Text[TextMedleyTitle[I]].Visible  := true;
      Text[TextMedleyNumber[I]].Visible := true;
      Statics[StaticMedley[I]].Visible  := true;

      Text[TextMedleyNumber[I]].Text := IntToStr(I+J);
      Text[TextMedleyArtist[I]].Text := CatSongs.Song[PlaylistMedley.Song[I-1+J]].Artist;
      Text[TextMedleyTitle[I]].Text  := CatSongs.Song[PlaylistMedley.Song[I-1+J]].Title;
    end
    else
    begin
      Text[TextMedleyArtist[I]].Visible := false;
      Text[TextMedleyTitle[I]].Visible  := false;
      Text[TextMedleyNumber[I]].Visible := false;
      Statics[StaticMedley[I]].Visible  := false;
    end;
  end;

  VideoAlpha := Button[interaction].Texture.Alpha*(CoverTime-1);
  //Instead of Draw FG Procedure:
  //We draw Buttons for our own
  for I := 0 to Length(Button) - 1 do
  begin
    if (I<>Interaction) or not Assigned(fCurrentVideo) or (VideoAlpha<1) or FinishedMusic then
      Button[I].Draw;
  end;

  //  StopVideoPreview;

  if (PlayMidi) then
    Position := BASS_ChannelBytes2Seconds(fStream, BASS_ChannelGetPosition(fStream, BASS_POS_BYTE))
  else
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
    with Button[interaction] do
    begin
      fCurrentVideo.SetScreenPosition(X, Y, Z);
      fCurrentVideo.Width := W;
      fCurrentVideo.Height := H;
      fCurrentVideo.ReflectionSpacing := Reflectionspacing;
    end;
    fCurrentVideo.AspectCorrection := acoCrop;

    fCurrentVideo.Draw;

    if Button[interaction].Reflection then
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

  DrawExtensions;

  //if (Mode = smPartyFree) then
  //  PartyTimeLimit();

  Result := true;
end;

{
procedure TScreenSong.PartyTimeLimit();
var
  CurrentTick: cardinal;
  I, I2:       integer;
  TimeS: string;
  N_DuetSongs: integer;
begin
  CurrentTick := SDL_GetTicks();

  TimeS := IntToStr(Round(MAX_TIME - (CurrentTick - PartyTime)/ 1000) - CurrentPartyTime);

  if (StrToInt(TimeS) > 0) then
  begin
    Text[TextPartyTime].Text := TimeS;

    if (StrToInt(Text[TextPartyTime].Text) <= 5) then
    begin
      Text[TextPartyTime].ColR := Theme.Song.TextPartyTime.DColR;
      Text[TextPartyTime].ColG := Theme.Song.TextPartyTime.DColG;
      Text[TextPartyTime].ColB := Theme.Song.TextPartyTime.DColB;
    end
    else
    begin
      Text[TextPartyTime].ColR := Theme.Song.TextPartyTime.ColR;
      Text[TextPartyTime].ColG := Theme.Song.TextPartyTime.ColG;
      Text[TextPartyTime].ColB := Theme.Song.TextPartyTime.ColB;
    end;

  end
  else
  begin
    // number of duet songs
    N_DuetSongs := 0;
    for I := 0 to High(CatSongs.Song) do
    begin
      if (CatSongs.Song[I].isDuet) then
        Inc(N_DuetSongs);
    end;

    // random
    repeat
      if (Ini.TabsAtStartup = 1) then // random with category
      begin
        I := Random(High(CatSongs.Song) + 1);

        while CatSongs.Song[I].Main do
          Inc(I);

        I2 := I - 1;

        while not(CatSongs.Song[I2].Main) do
          Dec(I2);

        // show cat in top left mod
        ShowCatTL (I2);

        Interaction := I;

        CatSongs.ShowCategoryList;
        CatSongs.ClickCategoryButton(I2);
        SelectNext;
        FixSelected;
      end
      else // random in one category
      begin
        SkipTo(Random(CatSongs.VisibleSongs));
      end;
    until (Party.SongNotSungAndNotDuet(Interaction, N_DuetSongs));

    ParseInput(SDLK_RETURN, 0, true);
  end;

end;
}

procedure TScreenSong.SelectNext;
var
  Skip: integer;
  VS:   integer;
begin
  VS := CatSongs.VisibleSongs;

  if VS > 0 then
  begin

    if (not isScrolling) and (VS > 0) then
    begin
      isScrolling := true;
      OnSongDeselect;
    end;

    Skip := 1;

    // this 1 could be changed by CatSongs.FindNextVisible
    while (not CatSongs.Song[(Interaction + Skip) mod Length(Interactions)].Visible) do
      Inc(Skip);

    SongTarget := SongTarget + 1;//Skip;

    Interaction := (Interaction + Skip) mod Length(Interactions);

    // try to keep all at the beginning
    if SongTarget > VS-1 then
    begin
      SongTarget := SongTarget - VS;
      SongCurrent := SongCurrent - VS;
    end;
  end;

  // Interaction -> Button, load cover
  // show uncached texture
  //Button[Interaction].Texture := Texture.GetTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN, false);
end;

procedure TScreenSong.SelectPrev;
var
  Skip: integer;
  VS:   integer;
begin
  VS := CatSongs.VisibleSongs;

  if VS > 0 then
  begin
    if (not isScrolling) and (VS > 0) then
    begin
      isScrolling := true;
      OnSongDeselect;
    end;

    Skip := 1;

    while (not CatSongs.Song[(Interaction - Skip + Length(Interactions)) mod Length(Interactions)].Visible) do
      Inc(Skip);
    SongTarget := SongTarget - 1;//Skip;

    Interaction := (Interaction - Skip + Length(Interactions)) mod Length(Interactions);

    // try to keep all at the beginning
    if SongTarget < 0 then
    begin
      SongTarget := SongTarget + CatSongs.VisibleSongs;
      SongCurrent := SongCurrent + CatSongs.VisibleSongs;
    end;

    // show uncached texture
    //Button[Interaction].Texture := Texture.GetTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN, false);
  end;
end;

procedure TScreenSong.StartMusicPreview();
var
  Song: TSong;
  PreviewPos: real;
  I: integer;
  Vol: cardinal;
begin
  AudioPlayback.Close();

  if CatSongs.VisibleSongs = 0 then
    Exit;

  Song := CatSongs.Song[Interaction];
  if not assigned(Song) then
    Exit;

  //fix: if main cat than there is nothing to play
  if Song.main then
    Exit;

  if (StringInArray(Song.Path.Append(Song.Mp3).GetExtension.ToNative, ['.mid', '.midi', '.rmi', '.kar'])) then
  begin
    PlayMidi := true;
    MidiFadeIn := false;

    ScreenSing.ChannelOff := -1;

    PreviewOpened := Interaction;
    if (Song.PreviewStart>0) then
      PreviewPos := Song.PreviewStart
    else
      PreviewPos := AudioPlayback.Length / 4;

    BASS_StreamFree(fStream); // free old stream
 	  fStream := BASS_MIDI_StreamCreateFile(false, PChar(Song.Path.Append(Song.Mp3).ToNative), 0, 0, BASS_SAMPLE_OVER_POS, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});

    BASS_ChannelSetPosition(fStream, BASS_ChannelSeconds2Bytes(fStream, Song.Start), BASS_POS_BYTE);

    PreviewPos := BASS_ChannelBytes2Seconds(fStream, BASS_ChannelGetLength(fStream, BASS_POS_BYTE)) / 4;
    // fix for invalid music file lengths
    if (PreviewPos > 60.0) and (Song.PreviewStart=0) then
      PreviewPos := 60.0;

    BASS_ChannelSetPosition(fStream, BASS_ChannelSeconds2Bytes(fStream, PreviewPos), BASS_POS_BYTE);

    // set preview volume
    if (Ini.PreviewFading = 0) then
    begin
      // music fade disabled: start with full volume
      Vol := Round(127 * IPreviewVolumeVals[Ini.PreviewVolume]);
      for I := 0 to 15 do
        BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, Vol);

      BASS_ChannelPlay(fStream, false)
    end
    else
    begin
      // music fade enabled: start muted and fade-in
      MidiFadeIn := true;
      FadeTime := SDL_GetTicks();

      Vol := 0;
      for I := 0 to 15 do
        BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, Vol);

      BASS_ChannelPlay(fStream, false)
    end;

  end
  else
  begin
    PlayMidi := false;
    if AudioPlayback.Open(Song.Path.Append(Song.Mp3)) then
    begin
      PreviewOpened := Interaction;

      PreviewPos := AudioPlayback.Length / 4;
      // fix for invalid music file lengths
      if (PreviewPos > 60.0) then
        PreviewPos := 60.0;
      AudioPlayback.Position := PreviewPos;

      // set preview volume
      if (Ini.PreviewFading = 0) then
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
end;

procedure TScreenSong.MidiFadeInPreview();
var
  I: integer;
  Vol: cardinal;
  DiffTime: cardinal;
begin
  DiffTime := SDL_GetTicks() - FadeTime;
  Vol := Round((DiffTime * 127 * IPreviewVolumeVals[Ini.PreviewVolume])/Trunc(Ini.PreviewFading * 1000));

  for I := 0 to 15 do
    BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, Vol);

  if (Vol >= 127) then
    MidiFadeIn := false;
end;

procedure TScreenSong.StopMusicPreview();
begin
  // Stop preview of previous song
  if (PlayMidi) then
    BASS_ChannelStop(fStream)
  else
    AudioPlayback.Stop;
end;

procedure TScreenSong.StartVideoPreview();
var
  VideoFile:  IPath;
  Song:       TSong;
  Position:   real;
begin
  if (Ini.VideoPreview=0)  then
    Exit;

  if Assigned(fCurrentVideo) then
  begin
    fCurrentVideo.Stop();
    fCurrentVideo := nil;
  end;

  //if no audio open => exit
  if (PreviewOpened = -1) then
    Exit;

  if CatSongs.VisibleSongs = 0 then
    Exit;

  Song := CatSongs.Song[Interaction];
  if not assigned(Song) then
    Exit;

  //fix: if main cat than there is nothing to play
  if Song.main then
    Exit;

  if (PlayMidi) then
    Position := BASS_ChannelBytes2Seconds(fStream, BASS_ChannelGetPosition(fStream, BASS_POS_BYTE))
  else
    Position := AudioPlayback.Position;

  VideoFile := Song.Path.Append(Song.Video);
  if (Song.Video.IsSet) and VideoFile.IsFile then
  begin
    fCurrentVideo := VideoPlayback.Open(VideoFile);
    if (fCurrentVideo <> nil) then
    begin
      fCurrentVideo.Position := Song.VideoGAP + Position;
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

  BASS_StreamFree(fStream); // free old stream

  StartMusicPreview();
  StartVideoPreview();
end;

procedure TScreenSong.SkipTo(Target: cardinal);
var
  i: integer;
begin
  Interaction := High(CatSongs.Song);
  SongTarget  := 0;

  for i := 1 to Target+1 do
    SelectNext;

  FixSelected2;
end;

procedure TScreenSong.SelectRandomSong;
var
  I, I2, Count, RealTarget: integer;
  Target: cardinal;
begin
  case PlayListMan.Mode of
      smAll:  // all songs just select random song
        begin
          // when tabs are activated then use tab method
          if (Ini.TabsAtStartup = 1) then
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

            // choose song
            // duets not playble
            if (ScreenSong.Mode = smPartyClassic) then
            begin
              repeat
                Target := Random(CatSongs.VisibleSongs);

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
              Target := Random(CatSongs.VisibleSongs);

            SkipTo(Target);
            //SkipTo(I2 - I);
          end
          // when tabs are deactivated use easy method
          else
          begin
            // duets not playble
            if (ScreenSong.Mode = smPartyClassic) then
            begin
              repeat
                Target := Random(CatSongs.VisibleSongs);

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
              Target := Random(CatSongs.VisibleSongs);

            SkipTo(Target);
          end;
        end;
      smCategory:  // one category select category and select random song
        begin

          CatSongs.ShowCategoryList;
          CatSongs.ClickCategoryButton(PlaylistMan.CurPlayList);
          ShowCatTL(PlaylistMan.CurPlayList);

          SelectNext;
          FixSelected2;

          // duets not playble
          if (ScreenSong.Mode = smPartyClassic) then
          begin
            repeat
              Target := Random(CatSongs.VisibleSongs);

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
            Target := Random(CatSongs.VisibleSongs);

          SkipTo(Target);
        end;
      smPlaylist:  // playlist: select playlist and select random song
        begin
          PlaylistMan.SetPlayList(PlaylistMan.CurPlayList);

          // duets not playble
          if (ScreenSong.Mode = smPartyClassic) then
          begin
            repeat
              Target := Random(CatSongs.VisibleSongs);

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
            Target := Random(CatSongs.VisibleSongs);

          SkipTo(Target);
          FixSelected2;
        end;
  end;

  AudioPlayback.PlaySound(SoundLib.Change);
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

procedure TScreenSong.SetStatics;
var
  I:       integer;
  Visible: boolean;
begin
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

procedure TScreenSong.OpenEditor;
begin
  if (Songs.SongList.Count > 0) and
     (not CatSongs.Song[Interaction].Main) and
     (Mode = smNormal) then
  begin
    StopMusicPreview();
    AudioPlayback.PlaySound(SoundLib.Start);
    CurrentSong := CatSongs.Song[Interaction];
    FadeTo(@ScreenEditSub);
  end;
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

//Detailed Cover Unloading. Unloads the Detailed, uncached Cover of the cur. Song
procedure TScreenSong.UnloadDetailedCover;
begin
  // show cached texture
  Button[Interaction].Texture := Texture.GetTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN, true);
  Button[Interaction].Texture2.Alpha := 0;

  if Button[Interaction].Texture.Name <> Skin.GetTextureFileName('SongCover') then
    Texture.UnloadTexture(Button[Interaction].Texture.Name, TEXTURE_TYPE_PLAIN, false);
end;

procedure TScreenSong.Refresh;
begin

end;

{
procedure TScreenSong.Refresh(GiveStats: boolean);
var
  Pet:    integer;
  I:      integer;
  Name:   IPath;
Label CreateSongButtons;

begin
  Log.BenchmarkStart(2);
  ClearButtons();
  Log.BenchmarkEnd(2);
  Log.LogBenchmark('--> Refresh Clear Buttons', 2);

  Log.BenchmarkStart(2);
  CatSongs.Refresh;
  Log.BenchmarkEnd(2);
  Log.LogBenchmark('--> Refresh CatSongs', 2);

  Log.BenchmarkStart(2);
  if (length(CatSongs.Song) > 0) then
  begin
    //Set Length of Button Array one Time Instead of one time for every Song
    SetButtonLength(Length(CatSongs.Song));

    I := 0;
    Pet := 0;
    CreateSongButtons:

    try
      for Pet := I to High(CatSongs.Song) do
      begin // creating all buttons
        if (CatSongs.Song[Pet].CoverTex.TexNum = -1) then
        begin
          Texture.Limit := 512;
          if CatSongs.Song[Pet].Cover = PATH_NONE then
            AddButton(300 + Pet*250, 140, 200, 200, Skin.GetTextureFileName('SongCover'), TEXTURE_TYPE_PLAIN, Theme.Song.Cover.Reflections)
          else
          begin
            Name := CatSongs.Song[Pet].Path + CatSongs.Song[Pet].Cover;
            // cache texture if there is a need to this
            if not Covers.CoverExists(Name) then
            begin
              Texture.CreateCacheMipmap := true;
              Texture.GetTexture(Name, 'Plain', true); // preloads textures and creates cache mipmap
              Texture.CreateCacheMipmap := false;

              // puts this texture to the cache file
              Covers.AddCover(Name);

              // unload full size texture
              Texture.UnloadTexture(Name, false);

              // we should also add mipmap texture by calling createtexture and use mipmap cache as data source
            end;

            // and now load it from cache file (small place for the optimization by eliminating reading it from file, but not here)
            AddButton(300 + Pet*250, 140, 200, 200, Name, 'JPG', 'Plain', Theme.Song.Cover.Reflections, true);
          end;
          Texture.Limit := 1024*1024;
        end else
          AddButton(300 + Pet*250, 140, 200, 200, Theme.Song.Cover.Reflections, CatSongs.Song[Pet].CoverTex);

        I := -1;
      end;
    except
      //When Error is reported the First time for this Song
      if (I <> Pet) then
      begin
        //Some Error reporting:
        Log.LogError('Could not load Cover (maybe damaged?): ' + CatSongs.Song[Pet].Path + CatSongs.Song[Pet].Cover);

        //Change Cover to NoCover and Continue Loading
        CatSongs.Song[Pet].Cover := '';
        I := Pet;
      end
      else //when Error occurs Multiple Times(NoSong Cover is damaged), then start loading next Song
      begin
        Log.LogError('NoCover Cover is damaged!');
        try
          AddButton(300 + Pet*250, 140, 200, 200, '', 'JPG', 'Plain', Theme.Song.Cover.Reflections, true);
        except
          Messagebox(0, PChar('No Cover Image is damage. Could not Workaround Song Loading, Ultrastar will exit now.'), PChar(Language.Translate('US_VERSION')), MB_ICONERROR or MB_OK);
          Halt;
        end;
        I := Pet + 1;
      end;
    end;

    if (I <> -1) then
      GoTo CreateSongButtons;

  end;
  Log.BenchmarkEnd(2);
  Log.LogBenchmark('--> Refresh Create Buttons', 2);

  FixSelected;
end;
}

  {
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
  if (NumSongs>0) then
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
  end else //start this song
  begin
    SetLength(PlaylistMedley.Song, 1);
    PlaylistMedley.Song[0] := Interaction;
    PlaylistMedley.NumMedleySongs := 1;
  end;

  if (Mode = smNormal) then
  begin

    Mode := smMedley;
    StopMusicPreview();

    //TODO: how about case 2? menu for medley mode?
    case Ini.OnSongClick of
      0: FadeTo(@ScreenSing);
      1: SelectPlayers;
      2: FadeTo(@ScreenSing);
      //2: begin
      //   if (CatSongs.CatNumShow = -3) then
      //     ScreenSongMenu.MenuShow(SM_Playlist)
      //   else
      //     ScreenSongMenu.MenuShow(SM_Main);
      // end;
    end;
  end;
end;
}
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

  if (Mode=smNormal) and not MakeMedley then
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
    Text[TextMaxScore2].Text   := IntToStr(DataBase.ReadMax_Score(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, DllMan.Websites[Ini.ShowWebScore].ID, Ini.Difficulty));
    Text[TextMediaScore2].Text := IntToStr(DataBase.ReadMedia_Score(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, DllMan.Websites[Ini.ShowWebScore].ID, Ini.Difficulty));
    Text[TextScoreUser].Text   := DataBase.ReadUser_Score(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, DllMan.Websites[Ini.ShowWebScore].ID, Ini.Difficulty);
  end;

  Text[TextMaxScoreLocal].Text   := IntToStr(DataBase.ReadMax_ScoreLocal(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, Ini.Difficulty));
  Text[TextMediaScoreLocal].Text := IntToStr(DataBase.ReadMedia_ScoreLocal(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, Ini.Difficulty));
  Text[TextScoreUserLocal].Text  := DataBase.ReadUser_ScoreLocal(CatSongs.Song[Interaction].Artist, CatSongs.Song[Interaction].Title, Ini.Difficulty);

end;


procedure TScreenSong.WriteMessage(msg: UTF8String);
begin

  MessageTime := SDL_GetTicks();

  Statics[InfoMessageBG].Texture.Alpha := 1;
  Text[InfoMessageText].Alpha := 1;

  Statics[InfoMessageBG].Visible := true;
  Text[InfoMessageText].Visible := true;
  Text[InfoMessageText].Text := msg;

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
  Ini.TabsAtStartup := Tabs;

  //ClearButtons();
  CatSongs.Refresh;
  Interaction := 0;
  HideCatTL;
  FixSelected2;
  ChangeMusic;

  Count := 0;
  for I := 0 to High(Button) do
  begin
    //while (CatSongs.Song[Count].Main) do
    //  Count := Count + 1;

    if (CatSongs.Song[I].CoverTex.TexNum > 0) then
      Button[I].Texture := CatSongs.Song[I].CoverTex;
    //else
    //Count := Count + 1;
  end;

  //for I := 0 to High(CatSongs.Song) do
  //if CatSongs.Song[Pet].Cover = PATH_NONE then
  //  AddButton(300 + I*250, 140, 200, 200, Skin.GetTextureFileName('SongCover'), TEXTURE_TYPE_PLAIN, Theme.Song.Cover.Reflections)

  //SetLength(Button, Length(CatSongs.Song));

  //

  //UnLoadDetailedCover;

//  SetScroll;


{
  if (length(CatSongs.Song) > 0) then
  begin
    //Set Length of Button Array one Time Instead of one time for every Song
    SetButtonLength(Length(CatSongs.Song));

    I := 0;
    Pet := 0;
    CreateSongButtons:

    try
      for Pet := I to High(CatSongs.Song) do
      begin // creating all buttons
        if (CatSongs.Song[Pet].CoverTex.TexNum = -1) then
        begin
          Texture.Limit := 512;
          if CatSongs.Song[Pet].Cover = PATH_NONE then
            AddButton(300 + Pet*250, 140, 200, 200, Skin.GetTextureFileName('SongCover'), TEXTURE_TYPE_PLAIN, Theme.Song.Cover.Reflections)
          else
          begin

            Name := CatSongs.Song[Pet].FileName;

            //Name := CatSongs.Song[Pet].Path + CatSongs.Song[Pet].Cover;
            // cache texture if there is a need to this
            if not Covers.CoverExists(Name) then
            begin
              //Texture.CreateCacheMipmap := true;
              //Texture.GetTexture(Name, 'Plain', true); // preloads textures and creates cache mipmap
              //Texture.CreateCacheMipmap := false;

              // puts this texture to the cache file
              Covers.AddCover(Name);

              // unload full size texture
              Texture.UnloadTexture(Name, TEXTURE_TYPE_PLAIN, false);

              // we should also add mipmap texture by calling createtexture and use mipmap cache as data source
            end;

            // and now load it from cache file (small place for the optimization by eliminating reading it from file, but not here)
            AddButton(300 + Pet*250, 140, 200, 200, Name, TEXTURE_TYPE_PLAIN, Theme.Song.Cover.Reflections);
          end;
          Texture.Limit := 1024*1024;
        end;// else
         // AddButton(300 + Pet*250, 140, 200, 200, Theme.Song.Cover.Reflections, CatSongs.Song[Pet].CoverTex);

        I := -1;
      end;
    except
      //When Error is reported the First time for this Song
      if (I <> Pet) then
      begin
        //Change Cover to NoCover and Continue Loading
        CatSongs.Song[Pet].Cover := PATH_NONE;
        I := Pet;
      end
      else //when Error occurs Multiple Times(NoSong Cover is damaged), then start loading next Song
      begin
        Log.LogError('NoCover Cover is damaged!');
        try
          AddButton(300 + Pet*250, 140, 200, 200, PATH_NONE, TEXTURE_TYPE_PLAIN, Theme.Song.Cover.Reflections);
        except
          Halt;
        end;
        I := Pet + 1;
      end;
    end;

    if (I <> -1) then
      GoTo CreateSongButtons;

  end;
  Log.BenchmarkEnd(2);
  Log.LogBenchmark('--> Refresh Create Buttons', 2);

  //FixSelected;

  // set length of button array once instead for every song
  //SetButtonLength(Length(CatSongs.Song));
  //SetLength(Button, Length(CatSongs.Song));

  // create all buttons
  //for I := 0 to High(CatSongs.Song) do
  //begin

    //if not (CatSongs.Song[I].Main) then
    //  Button[I].Texture.TexNum := Button[I].Texture.TexNum;//CatSongs.Song[1].CoverTex.TexNum;

    {
    CoverButton := nil;
    // create a clickable cover
    CoverButtonIndex := AddButton(300 + I*250, 140, 200, 200, PATH_NONE, TEXTURE_TYPE_PLAIN, Theme.Song.Cover.Reflections);
    if (CoverButtonIndex > -1) then
      CoverButton := Button[CoverButtonIndex];

    {
    if (CoverButton = nil) then
      Continue;

    Song := CatSongs.Song[I];

    CoverFile := Song.Path.Append(Song.Cover);
    if (not CoverFile.IsFile()) then
      Song.Cover := PATH_NONE;

    if (Song.Cover.IsUnset) then
      CoverFile := Skin.GetTextureFileName('SongCover');
    {
    // load cover and cache its texture
    Cover := Covers.FindCover(CoverFile);
    if (Cover = nil) then
      Cover := Covers.AddCover(CoverFile);

    // use the cached texture
    // TODO: this is a workaround until the new song-loading works.
    // The TCover object should be added to the song-object. The thumbnails
    // should be loaded each time the song-screen is shown (it is real fast).
    // This way, we will not waste that much memory and have a link between
    // song and cover.
    if (Cover <> nil) then
    begin
      CoverTexture := Cover.GetPreviewTexture();
      Texture.AddTexture(CoverTexture, TEXTURE_TYPE_PLAIN, true);
      CoverButton.Texture := CoverTexture;

      // set selected to false -> the right texture will be displayed
      CoverButton.Selected := False;
    end;

    Cover.Free;
     }
  //end;

  // reset selection
  //if (Length(CatSongs.Song) > 0) then
  //  Interaction := 0;
//end;


  //Count := 0;
  //for I := 0 to High(Button) do
  //begin
  //  while (CatSongs.Song[Count].Main) do
  //    Count := Count + df1;
  //
  //  Button[I].Texture := CatSongs.Song[Count].CoverTex;
  //end;

  {changed := false;

  if (tabs and (Ini.Tabs = 0)) or (not tabs and (Ini.Tabs=1)) then
    changed := true;

  if (sorting <> Ini.Sorting) then
    changed := true;

  if not changed then
    Exit;
  }


  {if not CatSongs.Song[Interaction].Main then
  begin
    Artist := CatSongs.Song[Interaction].Artist;
    Title := CatSongs.Song[Interaction].Title;
    jump := true;
  end else
    jump := false;
  }

  //Refresh;
  //PlaylistMan.LoadPlayLists;

  {
  //if jump then
  //  I2 := PlaylistMan.FindSong(Artist, Title)
  //else
  //begin
    //Find Category
    I := Interaction;
    while not CatSongs.Song[I].Main  do
    begin
      Dec (I);
      if (I < low(CatSongs.Song)) then
        break;
    end;
    if (I<= 1) then
      Interaction := high(catsongs.Song)
    else
      Interaction := I - 1;

    HideCatTL;

    //Show Wrong Song when Tabs on Fix
    SelectNext;
    FixSelected;
    ChangeMusic;
  //end;

  if (Ini.Tabs=1) and not (CatSongs.CatNumShow = -3) and jump then
  begin
    //Search Cat
    for I := I2 downto low(CatSongs.Song) do
    begin
      if CatSongs.Song[I].Main then
        break;
    end;

    //Choose Cat
    CatSongs.ShowCategoryList;
    ShowCatTL(I);
    CatSongs.ClickCategoryButton(I);
  end;

  //Choose Song
  if jump then
  begin
    SkipTo(I2);
    SongCurrent := SongTarget;
    ChangeMusic;
  end;

  if (Ini.Tabs=0) then
    HideCatTL;

  Ini.Save;
  }

end;

end.
