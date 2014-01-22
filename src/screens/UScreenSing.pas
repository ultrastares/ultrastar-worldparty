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
 * $URL: https://ultrastardx.svn.sourceforge.net/svnroot/ultrastardx/trunk/src/screens/UScreenSing.pas $
 * $Id: UScreenSing.pas 2779 2010-12-28 10:38:21Z tobigun $
 *}

unit UScreenSing;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  SysUtils,
  SDL,
  TextGL,
  gl,
  bass,
  bassmidi,
  UFiles,
  UGraphicClasses,
  UIni,
  ULog,
  ULyrics,
  UMenu,
  UMusic,
  USingScores,
  USongs,
  UTexture,
  UThemes,
  UPath,
  UTime,
  USkins,
  UHookableEvent;

type
  TPos = record // Lines[part].Line[line].Note[note]
    part: integer;
    line: integer;
    note: integer;
    CP: integer;
  end;

  TLyricsSyncSource = class(TSyncSource)
    function GetClock(): real; override;
  end;

  TMusicSyncSource = class(TSyncSource)
    function GetClock(): real; override;
  end;

  TTimebarMode = (
    tbmCurrent,   // current song position
    tbmRemaining, // remaining time
    tbmTotal      // total time
  );

type
  TScreenSing = class(TMenu)
  private
    // views
    fShowVisualization: boolean;
    fShowWebcam: boolean;
    fShowBackground: boolean;

    fCurrentVideo: IVideo;
    fVideoClip:    IVideo;
    fLyricsSync: TLyricsSyncSource;
    fMusicSync: TMusicSyncSource;
    fTimebarMode: TTimebarMode;

    PlayMidi: boolean;

    StartNote, EndNote:     TPos;

    procedure LoadNextSong();
    procedure UpdateMedleyStats(medley_end: boolean);
    procedure DrawMedleyCountdown();
    procedure SongError();
  protected
    eSongLoaded: THookableEvent; //< event is called after lyrics of a song are loaded on OnShow
    Paused:     boolean; //pause Mod
    NumEmptySentences: array [0..1] of integer;
  public
    Act_Level: integer;
    Act_MD5Song: string;

    StaticDuet: array of cardinal;
    ColPlayer:  array[0..3] of TRGB;

    // timebar fields
    StaticTimeProgress: integer;
    TextTimeText: integer;

    StaticP1: array [0..1] of integer;
    TextP1:   integer;

    // shown when game is in 2/4 player modus
    StaticP1TwoP: array [0..1] of integer;
    TextP1TwoP:   integer;

    // shown when game is in 3/6 player modus
    StaticP1ThreeP: array [0..1] of integer;
    TextP1ThreeP:   integer;

    StaticP2R: array [0..1] of integer;

    MedleyStart, MedleyEnd: real;

    TextP2R:   integer;

    StaticP2M: array [0..1] of integer;
    TextP2M:   integer;

    StaticP3R: array [0..1] of integer;
    TextP3R:   integer;

    StaticPausePopup: integer;

    SongNameStatic:   integer;
    SongNameText:     integer;

    Tex_Background: TTexture;
    FadeOut: boolean;

    Lyrics: TLyricEngine;
    LyricsDuet: TLyricEngine;

    // score manager:
    Scores: TSingScores;

    //the song was sung to the end
    SungToEnd: boolean;

    //use pause
    SungPaused: boolean;

    // some settings to be set by plugins
    Settings: record
      Finish: Boolean; //< if true, screen will finish on next draw

      LyricsVisible: Boolean; //< shows or hides lyrics
      NotesVisible: Integer; //< if bit[playernum] is set the notes for the specified player are visible. By default all players notes are visible

      PlayerEnabled: Integer; //< defines whether a player can score atm
    end;

    // MIDI
    fStream     : HSTREAM;
    ChannelOff  : integer;

    MidiFadeIn: boolean;
    MidiFadeOut: boolean;
    FadeTime: cardinal;

    InfoMessageBG: cardinal;
    InfoMessageText: cardinal;

    MessageTime: cardinal;
    MessageTimeFade: cardinal;

    TextMedleyFadeOut: boolean;
    TextMedleyFadeTime: cardinal;

    procedure ClearSettings;
    procedure ApplySettings; //< applies changes of settings record
    procedure EndSong;

    constructor Create; override;
    procedure OnShow; override;
    procedure OnShowFinish; override;
    procedure OnHide; override;

    function ParseInput(PressedKey: cardinal; CharCode: UCS4Char;
      PressedDown: boolean): boolean; override;
    function Draw: boolean; override;

    function FinishedMusic: boolean;

    procedure ResetMidiChannelVolume();
    procedure OffMidiChannel(channel: integer);

    procedure AutoSendScore;
    procedure AutoSaveScore;

    procedure Finish; virtual;
    procedure Pause; // toggle pause

    procedure OnSentenceEnd(CP: integer; SentenceIndex: cardinal);     // for linebonus + singbar
    procedure OnSentenceChange(CP: integer; SentenceIndex: cardinal);  // for golden notes

    procedure SwapToScreen(Screen: integer);

    procedure WriteMessage(msg: UTF8String);
    procedure FadeMessage();
    procedure CloseMessage();

    procedure MedleyMidiFadeIn();
    procedure MedleyMidiFadeOut();

    procedure MedleyTitleFadeOut();

    function GetLyricColor(Color: integer): TRGB;
  end;

implementation

uses
  Classes,
  Math,
  UCommon,
  UDatabase,
  UDllManager,
  USoundfont,
  UDraw,
  UGraphic,
  ULanguage,
  UNote,
  URecord,
  USong,
  UDisplay,
  UParty,
  UPathUtils,
  UUnicodeUtils,
  UWebcam,
  UWebSDK;

const
  MAX_MESSAGE = 3;

// method for input parsing. if false is returned, getnextwindow
// should be checked to know the next window to load;

function TScreenSing.ParseInput(PressedKey: Cardinal; CharCode: UCS4Char;
  PressedDown: boolean): boolean;
var
  SDL_ModState:  word;
begin
  Result := true;
  if (PressedDown) then
  begin // key down

    SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT
    + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT);


    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
      begin
        // when not ask before exit then finish now
        if (Ini.AskbeforeDel <> 1) then
          Finish
        // else just pause and let the popup make the work
        else if not Paused then
          Pause;

        Result := false;
        Exit;
      end;

      // change soundfont
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

      // show visualization
      Ord('V'):
      begin
        fShowVisualization := not fShowVisualization;

        fShowWebCam := false;
        fShowBackground := false;

        if fShowVisualization then
        begin
          fCurrentVideo := Visualization.Open(PATH_NONE);

          fCurrentVideo.play;
        end
        else
        begin
          fCurrentVideo := fVideoClip;
        end;
        Exit;
      end;

      // show Webcam
      Ord('W'):
      begin
        if (fShowWebCam = false) and (Webcam.Capture <> nil) then
        begin
          fCurrentVideo := nil;
          fShowVisualization := false;
          fShowBackground := false;
          fShowWebCam := true;
        //  ChangeEffectLastTick := SDL_GetTicks;
        //  SelectsS[WebcamParamsSlide].Visible := true;
        //  LastTickFrame := SDL_GetTicks;
        end;
        Exit;
      end;

      // show Background
      Ord('B'):
      begin
        fCurrentVideo := nil;
        fShowVisualization := false;
        fShowWebCam := false;
        fShowBackground := true;
        Exit;
      end;

      // pause
      Ord('P'):
      begin
        Pause;
        Exit;
      end;

      // toggle time display
      Ord('T'):
      begin
        if (fTimebarMode = High(TTimebarMode)) then
          fTimebarMode := Low(TTimebarMode)
        else
          Inc(fTimebarMode);
        Exit;
      end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE:
      begin
        // record sound hack:
        //Sound[0].BufferLong
        if (ScreenSong.Mode = smMedley) then
          PlaylistMedley.NumMedleySongs := PlaylistMedley.CurrentMedleySong;

        Finish;
        FadeOut := true;
        AudioPlayback.PlaySound(SoundLib.Back);
      end;

      SDLK_SPACE:
      begin
        Pause;
      end;

      SDLK_TAB: // change visualization preset
      begin
        if fShowVisualization then
          fCurrentVideo.Position := now; // move to a random position
      end;

      SDLK_RETURN:
      begin
      end;

      // up and down could be done at the same time,
      // but i don't want to declare variables inside
      // functions like this one, called so many times
      SDLK_DOWN:
      begin
      end;
      SDLK_UP:
      begin
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
            end;
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
            end;
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
  end;
end;

procedure TScreenSing.ResetMidiChannelVolume();
var
  I: integer;
begin
  if (PlayMidi) then
  begin
    for I := 0 to 15 do
      BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, 127);

    ChannelOff := -1;

    WriteMessage(Language.Translate('INFO_MIDI_CHANNEL_RESET'));
  end;
end;

procedure TScreenSing.OffMidiChannel(channel: integer);
begin
  if (PlayMidi) then
  begin
    ResetMidiChannelVolume();
    BASS_MIDI_StreamEvent(fstream, channel, MIDI_EVENT_MIXLEVEL, 0);

    ChannelOff := channel;

    WriteMessage(Format(Language.Translate('INFO_MIDI_CHANNEL_OFF'), [IntToStr(channel + 1)]));
  end;
end;

// pause mod
procedure TScreenSing.Pause;
begin
  if (not Paused) then  // enable pause
  begin
    // pause time
    Paused := true;
    SungPaused := true;

    LyricsState.Pause();

    // pause music
    if (PlayMidi) then
      BASS_ChannelPause(fStream)
    else
      AudioPlayback.Pause;

    // pause video
    if (fCurrentVideo <> nil) then
      fCurrentVideo.Pause;

  end
  else              // disable pause
  begin
    LyricsState.Start();

    // play music
    if (PlayMidi) then
      BASS_ChannelPlay(fStream, false)
    else
      AudioPlayback.Play;

    // video
    if (fCurrentVideo <> nil) then
      fCurrentVideo.Pause;

    Paused := false;
  end;
end;
// pause mod end

// Dirty HacK
procedure TScreenSing.SwapToScreen(Screen: integer);
var
  P, I: integer;
begin
  { if screens = 2 and playerplay <= 3 the 2nd screen shows the
    textures of screen 1 }
  if (PlayersPlay <= 3) and (Screen = 2) then
    Screen := 1;

  Statics[StaticP1[0]].Visible := false;
  Statics[StaticP1TwoP[0]].Visible := false;
  Statics[StaticP2R[0]].Visible := false;
  Statics[StaticP1ThreeP[0]].Visible := false;
  Statics[StaticP2M[0]].Visible := false;
  Statics[StaticP3R[0]].Visible := false;
  Statics[StaticP1[1]].Visible := false;
  Statics[StaticP1TwoP[1]].Visible := false;
  Statics[StaticP2R[1]].Visible := false;
  Statics[StaticP1ThreeP[1]].Visible := false;
  Statics[StaticP2M[1]].Visible := false;
  Statics[StaticP3R[1]].Visible := false;

  if (PlayersPlay = 1) then
  begin
    if (Screen = 2) then
      Statics[StaticP1[0]].Visible := true;

    if (Screen = 1) then
      Statics[StaticP1[0]].Visible := true;
  end;

  if (PlayersPlay = 2) or (PlayersPlay = 4) then
  begin
    if (Screen = 2) then
    begin
      Statics[StaticP1TwoP[1]].Visible := true;
      Statics[StaticP2R[1]].Visible := true;
    end;

    if (Screen = 1) then
    begin
      Statics[StaticP1TwoP[0]].Visible := true;
      Statics[StaticP2R[0]].Visible := true;
    end;
  end;

  if (PlayersPlay = 3) or (PlayersPlay = 6) then
  begin
    if (Screen = 2) then
    begin
      Statics[StaticP1ThreeP[1]].Visible := true;
      Statics[StaticP2M[1]].Visible := true;
      Statics[StaticP3R[1]].Visible := true;
    end;

    if (Screen = 1) then
    begin
      Statics[StaticP1ThreeP[0]].Visible := true;
      Statics[StaticP2M[0]].Visible := true;
      Statics[StaticP3R[0]].Visible := true;
    end;
  end;

end;

constructor TScreenSing.Create;
var
  Col: array [1..6] of TRGB;
  I: integer;
  Color: cardinal;
begin
  inherited Create;

  //too dangerous, a mouse button is quickly pressed by accident
  RightMbESC := false;

  fShowVisualization := false;

  fCurrentVideo := nil;

  // create score class
  Scores := TSingScores.Create;
  Scores.LoadfromTheme;

  LoadFromTheme(Theme.Sing);

  SetLength(StaticDuet, Length(Theme.Sing.StaticDuet));
  for i := 0 to High(StaticDuet) do
    StaticDuet[i] := AddStatic(Theme.Sing.StaticDuet[i]);

  // timebar
  StaticTimeProgress := AddStatic(Theme.Sing.StaticTimeProgress);
  TextTimeText := AddText(Theme.Sing.TextTimeText);

  for I := 1 to 6 do
    Col[I] := GetPlayerColor(Ini.SingColor[I - 1]);

  // SCREEN 1
  // 1 player       | P1
  Theme.Sing.StaticP1.ColR := Col[1].R;
  Theme.Sing.StaticP1.ColG := Col[1].G;
  Theme.Sing.StaticP1.ColB := Col[1].B;

  // 2 or 4 players | P1
  Theme.Sing.StaticP1TwoP.ColR := Col[1].R;
  Theme.Sing.StaticP1TwoP.ColG := Col[1].G;
  Theme.Sing.StaticP1TwoP.ColB := Col[1].B;

  //                | P2
  Theme.Sing.StaticP2R.ColR := Col[2].R;
  Theme.Sing.StaticP2R.ColG := Col[2].G;
  Theme.Sing.StaticP2R.ColB := Col[2].B;

  // 3 or 6 players | P1
  Theme.Sing.StaticP1ThreeP.ColR := Col[1].R;
  Theme.Sing.StaticP1ThreeP.ColG := Col[1].G;
  Theme.Sing.StaticP1ThreeP.ColB := Col[1].B;

  //                | P2
  Theme.Sing.StaticP2M.ColR := Col[2].R;
  Theme.Sing.StaticP2M.ColG := Col[2].G;
  Theme.Sing.StaticP2M.ColB := Col[2].B;

  //                | P3

  Theme.Sing.StaticP3R.ColR := Col[3].R;
  Theme.Sing.StaticP3R.ColG := Col[3].G;
  Theme.Sing.StaticP3R.ColB := Col[3].B;

  StaticP1[0]       := AddStatic(Theme.Sing.StaticP1);
  StaticP1TwoP[0]   := AddStatic(Theme.Sing.StaticP1TwoP);
  StaticP2R[0]      := AddStatic(Theme.Sing.StaticP2R);
  StaticP1ThreeP[0] := AddStatic(Theme.Sing.StaticP1ThreeP);
  StaticP2M[0]      := AddStatic(Theme.Sing.StaticP2M);
  StaticP3R[0]      := AddStatic(Theme.Sing.StaticP3R);

  // SCREEN 2
  // 1 player       | P1
  Theme.Sing.StaticP1.ColR := Col[1].R;
  Theme.Sing.StaticP1.ColG := Col[1].G;
  Theme.Sing.StaticP1.ColB := Col[1].B;

  // 2 or 4 players | P1
  Theme.Sing.StaticP1TwoP.ColR := Col[3].R;
  Theme.Sing.StaticP1TwoP.ColG := Col[3].G;
  Theme.Sing.StaticP1TwoP.ColB := Col[3].B;

  //                | P2
  Theme.Sing.StaticP2R.ColR := Col[4].R;
  Theme.Sing.StaticP2R.ColG := Col[4].G;
  Theme.Sing.StaticP2R.ColB := Col[4].B;

  // 3 or 6 players | P1
  Theme.Sing.StaticP1ThreeP.ColR := Col[4].R;
  Theme.Sing.StaticP1ThreeP.ColG := Col[4].G;
  Theme.Sing.StaticP1ThreeP.ColB := Col[4].B;

  //                | P2
  Theme.Sing.StaticP2M.ColR := Col[5].R;
  Theme.Sing.StaticP2M.ColG := Col[5].G;
  Theme.Sing.StaticP2M.ColB := Col[5].B;

  //                | P3
  Theme.Sing.StaticP3R.ColR := Col[6].R;
  Theme.Sing.StaticP3R.ColG := Col[6].G;
  Theme.Sing.StaticP3R.ColB := Col[6].B;

  StaticP1[1]       := AddStatic(Theme.Sing.StaticP1);
  StaticP1TwoP[1]   := AddStatic(Theme.Sing.StaticP1TwoP);
  StaticP2R[1]      := AddStatic(Theme.Sing.StaticP2R);
  StaticP1ThreeP[1] := AddStatic(Theme.Sing.StaticP1ThreeP);
  StaticP2M[1]      := AddStatic(Theme.Sing.StaticP2M);
  StaticP3R[1]      := AddStatic(Theme.Sing.StaticP3R);

  TextP1   := AddText(Theme.Sing.TextP1);
  TextP1TwoP   := AddText(Theme.Sing.TextP1TwoP);
  TextP2R   := AddText(Theme.Sing.TextP2R);
  TextP1ThreeP   := AddText(Theme.Sing.TextP1ThreeP);
  TextP2M   := AddText(Theme.Sing.TextP2M);
  TextP3R   := AddText(Theme.Sing.TextP3R);

  // Sing Bars
  // P1-6
  for I := 1 to 6 do
  begin
    Color := RGBFloatToInt(Col[I].R, Col[I].G, Col[I].B);

	// Color := $002222; //light blue
  // Color := $10000 * Round(0.22*255) + $100 * Round(0.39*255) + Round(0.64*255); //dark blue

    Tex_Left[I]         := Texture.LoadTexture(Skin.GetTextureFileName('GrayLeft'),  TEXTURE_TYPE_COLORIZED, Color);
    Tex_Mid[I]          := Texture.LoadTexture(Skin.GetTextureFileName('GrayMid'),   TEXTURE_TYPE_COLORIZED, Color);
    Tex_Right[I]        := Texture.LoadTexture(Skin.GetTextureFileName('GrayRight'), TEXTURE_TYPE_COLORIZED, Color);

    Tex_plain_Left[I]   := Texture.LoadTexture(Skin.GetTextureFileName('NotePlainLeft'),  TEXTURE_TYPE_COLORIZED, Color);
    Tex_plain_Mid[I]    := Texture.LoadTexture(Skin.GetTextureFileName('NotePlainMid'),   TEXTURE_TYPE_COLORIZED, Color);
    Tex_plain_Right[I]  := Texture.LoadTexture(Skin.GetTextureFileName('NotePlainRight'), TEXTURE_TYPE_COLORIZED, Color);

    Tex_BG_Left[I]      := Texture.LoadTexture(Skin.GetTextureFileName('NoteBGLeft'),  TEXTURE_TYPE_COLORIZED, Color);
    Tex_BG_Mid[I]       := Texture.LoadTexture(Skin.GetTextureFileName('NoteBGMid'),   TEXTURE_TYPE_COLORIZED, Color);
    Tex_BG_Right[I]     := Texture.LoadTexture(Skin.GetTextureFileName('NoteBGRight'), TEXTURE_TYPE_COLORIZED, Color);

    //## backgrounds for the scores ##
    Tex_ScoreBG[I - 1] := Texture.LoadTexture(Skin.GetTextureFileName('ScoreBG'), TEXTURE_TYPE_COLORIZED, Color);
  end;

  StaticPausePopup := AddStatic(Theme.Sing.PausePopUp);

  // <note> pausepopup is not visible at the beginning </note>
  Statics[StaticPausePopup].Visible := false;

  Lyrics := TLyricEngine.Create(
      Theme.LyricBar.UpperX, Theme.LyricBar.UpperY, Theme.LyricBar.UpperW, Theme.LyricBar.UpperH,
      Theme.LyricBar.LowerX, Theme.LyricBar.LowerY, Theme.LyricBar.LowerW, Theme.LyricBar.LowerH);

  LyricsDuet := TLyricEngine.Create(
      Theme.LyricBarDuet.UpperX, Theme.LyricBarDuet.UpperY, Theme.LyricBarDuet.UpperW, Theme.LyricBarDuet.UpperH,
      Theme.LyricBarDuet.LowerX, Theme.LyricBarDuet.LowerY, Theme.LyricBarDuet.LowerW, Theme.LyricBarDuet.LowerH);

  fLyricsSync := TLyricsSyncSource.Create();
  fMusicSync := TMusicSyncSource.Create();

  SongNameStatic := AddStatic(Theme.Sing.StaticSongName);;
  SongNameText := AddText(Theme.Sing.TextSongName);
  
  eSongLoaded := THookableEvent.Create('ScreenSing.SongLoaded');

  // Info Message
  InfoMessageBG := AddStatic(Theme.Sing.InfoMessageBG);
  InfoMessageText := AddText(Theme.Sing.InfoMessageText);

  ClearSettings;
end;

procedure TScreenSing.OnShow;
var
  V1:     boolean;
  V1TwoP: boolean;   // position of score box in two player mode
  V1ThreeP: boolean; // position of score box in three player mode
  V2R:    boolean;
  V2M:    boolean;
  V3R:    boolean;
  BadPlayer: integer;
  Col: TRGB;
  I: integer;
begin
  inherited;

  Log.LogStatus('Begin', 'OnShow');

  FadeOut := false;

  CloseMessage;

  //the song was sung to the end
  SungToEnd := false;
  SungPaused := false;

  ClearSettings;
  Party.CallBeforeSing;

  // prepare players
  SetLength(Player, PlayersPlay);

  //Reset Player Medley stats
  if (ScreenSong.Mode = smMedley) then
  begin
    PlaylistMedley.CurrentMedleySong:=1;

    PlaylistMedley.NumPlayer := PlayersPlay;
    SetLength(PlaylistMedley.Stats, 0);

    fTimebarMode := tbmRemaining;
  end else
    fTimebarMode := tbmCurrent;

  if (ScreenSong.Mode = smMedley) then
    CatSongs.Selected := PlaylistMedley.Song[PlaylistMedley.CurrentMedleySong-1];

  CurrentSong := CatSongs.Song[CatSongs.Selected];

  for I := 0 to High(StaticDuet) do
    Statics[StaticDuet[I]].Visible := CurrentSong.isDuet;

  Statics[SongNameStatic].Visible := false;
  Text[SongNameText].Visible := false;

  case PlayersPlay of
    1:
    begin
      V1     := true;
      V1TwoP := false;
      V1ThreeP := false;
      V2R    := false;
      V2M    := false;
      V3R    := false;
    end;
    2:
    begin
      V1     := false;
      V1TwoP := true;
      V1ThreeP := false;
      V2R    := true;
      V2M    := false;
      V3R    := false;
    end;
    3:
    begin
      V1     := false;
      V1TwoP := false;
      V1ThreeP := true;
      V2R    := false;
      V2M    := true;
      V3R    := true;
    end;
    4:
    begin // double screen
      V1     := false;
      V1TwoP := true;
      V1ThreeP := false;
      V2R    := true;
      V2M    := false;
      V3R    := false;
    end;
    6:
    begin // double screen
      V1     := false;
      V1TwoP := false;
      V1ThreeP := true;
      V2R    := false;
      V2M    := true;
      V3R    := true;
    end;
  end;

  Text[TextP1].Visible       := V1;
  Text[TextP1TwoP].Visible   := V1TwoP;
  Text[TextP2R].Visible      := V2R;
  Text[TextP1ThreeP].Visible := V1ThreeP;
  Text[TextP2M].Visible      := V2M;
  Text[TextP3R].Visible      := V3R;

  BadPlayer := AudioInputProcessor.CheckPlayersConfig(PlayersPlay);
  if (BadPlayer <> 0) then
  begin
    ScreenPopupError.ShowPopup(
        Format(Language.Translate('ERROR_PLAYER_NO_DEVICE_ASSIGNMENT'),
        [BadPlayer]));
  end;

  if (CurrentSong.isDuet) then
  begin
    Col := GetLyricColor(Ini.SingColor[0]);
    if (PlayersPlay = 4) then
    begin
      ColPlayer[0] := GetLyricColor(Ini.SingColor[0]);
      ColPlayer[1] := GetLyricColor(Ini.SingColor[1]);
      ColPlayer[2] := GetLyricColor(Ini.SingColor[2]);
      ColPlayer[3] := GetLyricColor(Ini.SingColor[3]);
    end
  end
  else
    Col := GetLyricColor(1);;

  // set custom options
  case Ini.LyricsFont of
    0: // normal fonts
    begin
      Lyrics.FontStyle := ftNormal;

      Lyrics.LineColor_en.R := Skin_FontR;
      Lyrics.LineColor_en.G := Skin_FontG;
      Lyrics.LineColor_en.B := Skin_FontB;
      Lyrics.LineColor_en.A := 1;

      Lyrics.LineColor_dis.R := 0.4;
      Lyrics.LineColor_dis.G := 0.4;
      Lyrics.LineColor_dis.B := 0.4;
      Lyrics.LineColor_dis.A := 1;

      Lyrics.LineColor_act.R := Col.R; //0.02;
      Lyrics.LineColor_act.G := Col.G; //0.6;
      Lyrics.LineColor_act.B := Col.B; //0.8;
      Lyrics.LineColor_act.A := 1;
    end;
    1, 2: // outline fonts
    begin
      if (Ini.LyricsFont = 1) then
        Lyrics.FontStyle := ftOutline1
      else
        Lyrics.FontStyle := ftOutline2;

      if (CurrentSong.isDuet) then
      begin
        Lyrics.LineColor_en.R := 0.7;
        Lyrics.LineColor_en.G := 0.7;
        Lyrics.LineColor_en.B := 0.7;
        Lyrics.LineColor_en.A := 1;
      end
      else
      begin
        Lyrics.LineColor_en.R := 0.75;
        Lyrics.LineColor_en.G := 0.75;
        Lyrics.LineColor_en.B := 1;
        Lyrics.LineColor_en.A := 1;
      end;

      Lyrics.LineColor_dis.R := 0.8;
      Lyrics.LineColor_dis.G := 0.8;
      Lyrics.LineColor_dis.B := 0.8;
      Lyrics.LineColor_dis.A := 1;

      Lyrics.LineColor_act.R := Col.R; //0.5;
      Lyrics.LineColor_act.G := Col.G; //0.5;
      Lyrics.LineColor_act.B := Col.B; //1;
      Lyrics.LineColor_act.A := 1;
    end;
  end; // case

  if (CurrentSong.isDuet) and (PlayersPlay <> 1) then
  begin
    Col := GetLyricColor(Ini.SingColor[1]);

    // Change Lyric position
    Lyrics.UpperLineX := Theme.LyricBarDuet.UpperX;
    Lyrics.UpperLineY := Theme.LyricBarDuet.UpperY;
    Lyrics.LowerLineX := Theme.LyricBarDuet.LowerX;
    Lyrics.LowerLineY := Theme.LyricBarDuet.LowerY;

    LyricsDuet.UpperLineX := Theme.LyricBar.UpperX;
    LyricsDuet.UpperLineY := Theme.LyricBar.UpperY;
    LyricsDuet.LowerLineX := Theme.LyricBar.LowerX;
    LyricsDuet.LowerLineY := Theme.LyricBar.LowerY;

    // set custom options
    case Ini.LyricsFont of
      0: // normal fonts
      begin
        LyricsDuet.FontStyle := ftNormal;

        LyricsDuet.LineColor_en.R := Skin_FontR;
        LyricsDuet.LineColor_en.G := Skin_FontG;
        LyricsDuet.LineColor_en.B := Skin_FontB;
        LyricsDuet.LineColor_en.A := 1;

        LyricsDuet.LineColor_dis.R := 0.4;
        LyricsDuet.LineColor_dis.G := 0.4;
        LyricsDuet.LineColor_dis.B := 0.4;
        LyricsDuet.LineColor_dis.A := 1;

        LyricsDuet.LineColor_act.R := Col.R; //0.02;
        LyricsDuet.LineColor_act.G := Col.G; //0.6;
        LyricsDuet.LineColor_act.B := Col.B; //0.8;
        LyricsDuet.LineColor_act.A := 1;
      end;
      1, 2: // outline fonts
      begin
        if (Ini.LyricsFont = 1) then
          LyricsDuet.FontStyle := ftOutline1
        else
          LyricsDuet.FontStyle := ftOutline2;

        LyricsDuet.LineColor_en.R := 0.7;
        LyricsDuet.LineColor_en.G := 0.7;
        LyricsDuet.LineColor_en.B := 0.7;
        LyricsDuet.LineColor_en.A := 1;

        LyricsDuet.LineColor_dis.R := 0.8;
        LyricsDuet.LineColor_dis.G := 0.8;
        LyricsDuet.LineColor_dis.B := 0.8;
        LyricsDuet.LineColor_dis.A := 1;

        LyricsDuet.LineColor_act.R := Col.R; //0.5;
        LyricsDuet.LineColor_act.G := Col.G; //0.5;
        LyricsDuet.LineColor_act.B := Col.B; //1;
        LyricsDuet.LineColor_act.A := 1;
      end;
    end; // case

  end
  else
  begin
    Lyrics.UpperLineX := Theme.LyricBar.UpperX;
    Lyrics.UpperLineY := Theme.LyricBar.UpperY;
    Lyrics.LowerLineX := Theme.LyricBar.LowerX;
    Lyrics.LowerLineY := Theme.LyricBar.LowerY;
  end;

  // deactivate pause
  Paused := false;

  LoadNextSong();

  Log.LogStatus('End', 'OnShow');
end;

procedure TScreenSing.onShowFinish;
var
  I, Index: integer;
begin
  // hide cursor on singscreen show
  Display.SetCursor;

  // clear the scores of all players
  for Index := 0 to High(Player) do
    with Player[Index] do
    begin
      Score          := 0;
      ScoreLine      := 0;
      ScoreGolden    := 0;

      ScoreInt       := 0;
      ScoreLineInt   := 0;
      ScoreGoldenInt := 0;
      ScoreTotalInt  := 0;

      ScoreLast      := 0;

      LastSentencePerfect := false;
    end;

  // prepare music
  // Important: AudioPlayback must not be initialized in onShow() as TScreenSong
  // uses stops AudioPlayback in onHide() which interferes with TScreenSings onShow.
  if (StringInArray(CurrentSong.Mp3.GetExtension.ToNative, ['.mid', '.midi', '.rmi', '.kar'])) then
  begin
    //MIDI
    PlayMidi := true;

    BASS_StreamFree(fStream); // free old stream
 	  fStream := BASS_MIDI_StreamCreateFile(false, PChar(CurrentSong.Path.Append(CurrentSong.Mp3).ToNative), 0, 0, BASS_SAMPLE_OVER_POS, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});

    if (ScreenSong.Mode = smMedley) then
    begin
      for I := 0 to 15 do
        BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, 0);
    end
    else
    begin
      for I := 0 to 15 do
        BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, 127);
    end;

    BASS_MIDI_StreamEvent(fStream, ChannelOff, MIDI_EVENT_MIXLEVEL, 0);

    //BASS_ChannelSetPosition(fStream, BASS_ChannelSeconds2Bytes(fStream, CurrentSong.Start), BASS_POS_BYTE);
    BASS_ChannelSetPosition(fStream, BASS_ChannelSeconds2Bytes(fStream, LyricsState.GetCurrentTime()), BASS_POS_BYTE);
  end
  else
  begin
    PlayMidi := false;
    MidiFadeIn := false;

    AudioPlayback.Open(CurrentSong.Path.Append(CurrentSong.Mp3));
    if (ScreenSong.Mode = smMedley) then
      AudioPlayback.SetVolume(0.1)
    else
      AudioPlayback.SetVolume(1.0);
    //AudioPlayback.Position := CurrentSong.Start;
    AudioPlayback.Position := LyricsState.GetCurrentTime();
  end;

  // set time
  if (CurrentSong.Finish > 0) then
    LyricsState.TotalTime := CurrentSong.Finish / 1000
  else
  begin
    if (PlayMidi) then
      LyricsState.TotalTime := BASS_ChannelBytes2Seconds(fStream, BASS_ChannelGetLength(fStream, BASS_POS_BYTE))
    else
      LyricsState.TotalTime := AudioPlayback.Length;
  end;

  LyricsState.UpdateBeats();

  // synchronize music
  if not PlayMidi then
  begin
    if (Ini.SyncTo = Ord(stLyrics)) then
      AudioPlayback.SetSyncSource(fLyricsSync)
    else
      AudioPlayback.SetSyncSource(nil);

    // synchronize lyrics (do not set this before AudioPlayback is initialized)
    if (Ini.SyncTo = Ord(stMusic)) then
      LyricsState.SetSyncSource(fMusicSync)
    else
      LyricsState.SetSyncSource(nil);
  end;

  // start lyrics
  LyricsState.Start(true);

  // start music
  if (PlayMidi) then
  begin
    if (ScreenSong.Mode = smMedley) then
    begin
      FadeTime := SDL_GetTicks();
      MidiFadeIn := true;
    end;

    BASS_ChannelPlay(fStream, false);
  end
  else
  begin
    if (ScreenSong.Mode = smMedley) then
      AudioPlayback.FadeIn(CurrentSong.Medley.FadeIn_time, 1.0)
    else
      AudioPlayback.Play();
  end;

  // Send Score
  Act_MD5Song := CurrentSong.MD5;
  Act_Level := Ini.Difficulty;

  // start timer
  CountSkipTimeSet;
end;

procedure TScreenSing.SongError();
var
  I, len:  integer;

begin
  if (ScreenSong.Mode <> smMedley) then
  begin
    // error loading song -> go back to previous screen and show some error message
    Display.AbortScreenChange;

    // select new song in party mode
    if ScreenSong.Mode = smPartyClassic then
      ScreenSong.SelectRandomSong();

    if (Length(CurrentSong.LastError) > 0) then
      ScreenPopupError.ShowPopup(Format(Language.Translate(CurrentSong.LastError), [CurrentSong.ErrorLineNo]))
    else
      ScreenPopupError.ShowPopup(Language.Translate('ERROR_CORRUPT_SONG'));
    // FIXME: do we need this?
    CurrentSong.Path := CatSongs.Song[CatSongs.Selected].Path;
    Exit;
  end
  else
  begin
    if (PlaylistMedley.CurrentMedleySong<PlaylistMedley.NumMedleySongs) then
    begin
      //Error Loading Song in Medley Mode -> skip actual Medley Song an go on if possible
      len := Length(PlaylistMedley.Song);
      for I := PlaylistMedley.CurrentMedleySong-1 to len - 1 do
        PlaylistMedley.Song[I] := PlaylistMedley.Song[I+1];

      SetLength(PlaylistMedley.Song, Len-1);
      Dec(PlaylistMedley.NumMedleySongs);
      LoadNextSong;
      Exit;
    end
    else
    begin
      if (PlaylistMedley.NumMedleySongs=1) then
      begin
        //Error Loading Song in Medley Mode -> Go back to Song Screen and Show some Error Message
        Display.AbortScreenChange;

        // select new song in party mode
        if ScreenSong.Mode = smPartyClassic then
          ScreenSong.SelectRandomSong();

        if (Length(CurrentSong.LastError) > 0) then
          ScreenPopupError.ShowPopup(Format(Language.Translate(CurrentSong.LastError), [CurrentSong.ErrorLineNo]))
        else
          ScreenPopupError.ShowPopup(Language.Translate('ERROR_CORRUPT_SONG'));

        // FIXME: do we need this?
        CurrentSong.Path := CatSongs.Song[CatSongs.Selected].Path;
        Exit;
      end else
      begin
        //Error Loading Song in Medley Mode -> Finish actual round
        len := Length(PlaylistMedley.Song);
        SetLength(PlaylistMedley.Song, len-1);
        Dec(PlaylistMedley.NumMedleySongs);
        Finish;
        Exit;
      end;
    end;
  end;
end;

procedure TScreenSing.LoadNextSong();
var
  Color:      TRGB;
  Index:      integer;
  VideoFile:  IPath;
  BgFile:     IPath;
  success:    boolean;

  function FindNote(beat: integer): TPos;
  var
    line:   integer;
    note:   integer;
    found:  boolean;
    min:    integer;
    diff:   integer;

  begin
    found := false;

    for line := 0 to length(Lines[0].Line) - 1 do
    begin
      for note := 0 to length(Lines[0].Line[line].Note) - 1 do
      begin
        if (beat>=Lines[0].Line[line].Note[line].Start) and
          (beat<=Lines[0].Line[line].Note[line].Start + Lines[0].Line[line].Note[note].Length) then
        begin
          Result.part := 0;
          Result.line := line;
          Result.note := note;
          Result.CP := 0;
          found:=true;
          break;
        end;
      end;
    end;

    if found then //found exactly
      exit;

    if CurrentSong.isDuet and (PlayersPlay <> 1) then
    begin
      for Line := 0 to length(Lines[1].Line) - 1 do
      begin
        for Note := 0 to length(Lines[1].Line[Line].Note) - 1 do
        begin
          if (beat>=Lines[1].Line[Line].Note[Note].Start) and
            (beat<=Lines[1].Line[Line].Note[Note].Start + Lines[1].Line[Line].Note[Note].Length) then
          begin
            Result.CP := 1;
            Result.line := Line;
            Result.note := Note;
            found:=true;
            break;
          end;
        end;
      end;
    end;

    if found then //found exactly
      exit;

    min := high(integer);
    //second try (approximating)
    for line := 0 to length(Lines[0].Line) - 1 do
    begin
      for note := 0 to length(Lines[0].Line[line].Note) - 1 do
      begin
        diff := abs(Lines[0].Line[line].Note[note].Start - beat);
        if diff<min then
        begin
          Result.part := 0;
          Result.line := line;
          Result.note := note;
          Result.CP := 0;
          min := diff;
        end;
      end;
    end;

    if CurrentSong.isDuet and (PlayersPlay <> 1) then
    begin
      for Line := 0 to length(Lines[1].Line) - 1 do
      begin
        for Note := 0 to length(Lines[1].Line[Line].Note) - 1 do
        begin
          diff := abs(Lines[1].Line[Line].Note[Note].Start - beat);
          if diff<min then
          begin
            Result.CP := 1;
            Result.line := Line;
            Result.note := Note;
            min := diff;
          end;
        end;
      end;
    end;

  end;

begin
  // reset video playback engine
  fCurrentVideo := nil;

  // setup score manager
  Scores.ClearPlayers; // clear old player values
  Color.R := 0;
  Color.G := 0;
  Color.B := 0; // dummy atm  <- \(O.o)/? B like bummy?

  // add new players
  for Index := 0 to PlayersPlay - 1 do
  begin
    Scores.AddPlayer(Tex_ScoreBG[Index], Color);
  end;

  Scores.Init; // get positions for players

  // FIXME: sets path and filename to ''
  ResetSingTemp;

  PlaylistMedley.ApplausePlayed := false;

  if (ScreenSong.Mode = smMedley) then
  begin
    if (length(PlaylistMedley.Song)>=PlaylistMedley.CurrentMedleySong) then
    begin
      CatSongs.Selected := PlaylistMedley.Song[PlaylistMedley.CurrentMedleySong-1];
      //Music.Open(CatSongs.Song[CatSongs.Selected].Path + CatSongs.Song[CatSongs.Selected].Mp3);
    end else
    begin
      SongError;
      Exit;
    end;
  end;

  CurrentSong := CatSongs.Song[CatSongs.Selected];

  // FIXME: bad style, put the try-except into loadsong() and not here
  try
    // check if file is xml
    if CurrentSong.FileName.GetExtension.ToUTF8 = '.xml' then
      success := CurrentSong.AnalyseXML and CurrentSong.LoadXMLSong()
    else
      success := CurrentSong.Analyse(false, ScreenSong.DuetChange); // and CurrentSong.LoadSong();
  except
    success := false;
  end;

  if (not success) then
  begin
    SongError();
    Exit;
  end;

  // Set up Medley timings
  if (ScreenSong.Mode = smMedley) then
  begin
    CurrentSong.SetMedleyMode();

    if (PlaylistMedley.NumMedleySongs > 1) then
      Text[SongNameText].Text := IntToStr(PlaylistMedley.CurrentMedleySong) +
        '/' + IntToStr(PlaylistMedley.NumMedleySongs) + ': ' +
        CurrentSong.Artist + ' - ' + CurrentSong.Title
    else
      Text[SongNameText].Text := CurrentSong.Artist + ' - ' + CurrentSong.Title;

    //medley start and end timestamps
    StartNote := FindNote(CurrentSong.Medley.StartBeat - round(CurrentSong.BPM[0].BPM*CurrentSong.Medley.FadeIn_time/60));
    MedleyStart := GetTimeFromBeat(Lines[0].Line[StartNote.line].Note[0].Start);

    //check Medley-Start
    if (MedleyStart+CurrentSong.Medley.FadeIn_time*0.5>GetTimeFromBeat(CurrentSong.Medley.StartBeat)) then
      MedleyStart := GetTimeFromBeat(CurrentSong.Medley.StartBeat) - CurrentSong.Medley.FadeIn_time;
    if MedleyStart<0 then
      MedleyStart := 0;

    MedleyEnd := GetTimeFromBeat(CurrentSong.Medley.EndBeat) + CurrentSong.Medley.FadeOut_time;
  end;

  {*
   * == Background ==
   * We have four types of backgrounds:
   *   + Blank        : Nothing has been set, this is our fallback
   *   + Picture      : Picture has been set, and exists - otherwise we fallback
   *   + Video        : Video has been set, and exists - otherwise we fallback
   *   + Visualization: + Off        : No visualization
   *                    + WhenNoVideo: Overwrites blank and picture
   *                    + On         : Overwrites blank, picture and video
   *}

  {*
   * set background to: video
   *}
  fShowVisualization := false;
  VideoFile := CurrentSong.Path.Append(CurrentSong.Video);

  if (not fShowWebcam) and (Ini.VideoEnabled = 1) and CurrentSong.Video.IsSet() and VideoFile.IsFile then
  begin
    fVideoClip := VideoPlayback.Open(VideoFile);
    fCurrentVideo := fVideoClip;
    if (fVideoClip <> nil) then
    begin
      fShowVisualization := false;
      if (ScreenSong.Mode = smMedley) then
        fCurrentVideo.Position := CurrentSong.VideoGAP + MedleyStart
      else
        fCurrentVideo.Position := CurrentSong.VideoGAP + CurrentSong.Start;
      fCurrentVideo.Play;
    end;
  end;

  {*
   * set background to: picture
   *}
  //if (CurrentSong.Background.IsSet) and (fVideoClip = nil)
  //  and (TVisualizerOption(Ini.VisualizerOption) = voOff)  then
  if (not fShowWebcam) and (CurrentSong.Background.IsSet) and (fVideoClip = nil)
    and (TVisualizerOption(Ini.VisualizerOption) = voOff)  then
  begin
    BgFile := CurrentSong.Path.Append(CurrentSong.Background);
    try
      Tex_Background := Texture.LoadTexture(BgFile);
    except
      Log.LogError('Background could not be loaded: ' + BgFile.ToNative);
      Tex_Background.TexNum := 0;
    end
  end
  else
  begin
    Tex_Background.TexNum := 0;
  end;

  {*
   * set background to: visualization (Overwrites all)
   *}
  //if (TVisualizerOption(Ini.VisualizerOption) in [voOn]) then
  if (not fShowWebcam) and (TVisualizerOption(Ini.VisualizerOption) in [voOn]) then
  begin
    fShowVisualization := true;
    fCurrentVideo := Visualization.Open(PATH_NONE);
    if (fCurrentVideo <> nil) then
      fCurrentVideo.Play;
  end;

  {*
   * set background to: visualization (Videos are still shown)
   *}
  //if ((TVisualizerOption(Ini.VisualizerOption) in [voWhenNoVideo]) and
  //   (fVideoClip = nil)) then
  if (not fShowWebcam) and ((TVisualizerOption(Ini.VisualizerOption) in [voWhenNoVideo]) and
      (fVideoClip = nil)) then
  begin
    fShowVisualization := true;
    fCurrentVideo := Visualization.Open(PATH_NONE);
    if (fCurrentVideo <> nil) then
      fCurrentVideo.Play;
  end;


  // prepare lyrics timer
  LyricsState.Reset();

  if (ScreenSong.Mode = smMedley) then
  begin
    LyricsState.SetCurrentTime(MedleyStart);
    LyricsState.StartTime := CurrentSong.Gap;
    LyricsState.TotalTime := MedleyEnd;
  end else
  begin
    LyricsState.SetCurrentTime(CurrentSong.Start);
    LyricsState.StartTime := CurrentSong.Gap;
    if (CurrentSong.Finish > 0) then
      LyricsState.TotalTime := CurrentSong.Finish / 1000
    else
      LyricsState.TotalTime := AudioPlayback.Length;
  end;

  LyricsState.UpdateBeats();

  // prepare and start voice-capture
  AudioInput.CaptureStart;

  // main text
  Lyrics.Clear(CurrentSong.BPM[0].BPM, CurrentSong.Resolution);
  LyricsDuet.Clear(CurrentSong.BPM[0].BPM, CurrentSong.Resolution);

  if (CurrentSong.isDuet) and (PlayersPlay <> 1) then
  begin
    // initialize lyrics by filling its queue
    while (not Lyrics.IsQueueFull) and
          (Lyrics.LineCounter <= High(Lines[0].Line)) do
    begin
      Lyrics.AddLine(@Lines[0].Line[Lyrics.LineCounter]);
    end;

    // initialize lyrics by filling its queue
    while (not LyricsDuet.IsQueueFull) and
          (LyricsDuet.LineCounter <= High(Lines[1].Line)) do
    begin
      LyricsDuet.AddLine(@Lines[1].Line[LyricsDuet.LineCounter]);
    end;
  end
  else
  begin
    // initialize lyrics by filling its queue
    while (not Lyrics.IsQueueFull) and
          (Lyrics.LineCounter <= High(Lines[0].Line)) do
    begin
      Lyrics.AddLine(@Lines[0].Line[Lyrics.LineCounter]);
    end;
  end;

  // kill all stars not killed yet (goldenstarstwinkle mod)
  GoldenRec.SentenceChange(0);
  if (CurrentSong.isDuet) and (PlayersPlay <> 1) then
    GoldenRec.SentenceChange(1);

  // set position of line bonus - line bonus end
  // set number of empty sentences for line bonus
  NumEmptySentences[0] := 0;
  NumEmptySentences[1] := 0;

  if (CurrentSong.isDuet) and (PlayersPlay <> 1) then
  begin
    for Index := Low(Lines[1].Line) to High(Lines[1].Line) do
    if Lines[1].Line[Index].TotalNotes = 0 then
      Inc(NumEmptySentences[1]);

    for Index := Low(Lines[0].Line) to High(Lines[0].Line) do
    if Lines[0].Line[Index].TotalNotes = 0 then
      Inc(NumEmptySentences[0]);
  end
  else
  begin
    for Index := Low(Lines[0].Line) to High(Lines[0].Line) do
      if Lines[0].Line[Index].TotalNotes = 0 then
        Inc(NumEmptySentences[0]);
  end;

  eSongLoaded.CallHookChain(False);

  if (ScreenSong.Mode = smMedley) and (PlaylistMedley.CurrentMedleySong>1) then
    onShowFinish;
end;

procedure TScreenSing.ClearSettings;
begin
  Settings.Finish := False;
  Settings.LyricsVisible := True;
  Settings.NotesVisible := high(Integer);
  Settings.PlayerEnabled := high(Integer);
end;

{ applies changes of settings record }
procedure TScreenSing.ApplySettings;
begin
  //
end;

procedure TScreenSing.EndSong;
begin
  Settings.Finish := True;
end;

procedure TScreenSing.OnHide;
begin
  // background texture
  if (Tex_Background.TexNum > 0) then
  begin
    glDeleteTextures(1, PGLuint(@Tex_Background.TexNum));
    Tex_Background.TexNum := 0;
  end;

  Background.OnFinish;
  Display.SetCursor;
end;

function TScreenSing.FinishedMusic: boolean;
begin

  if (PlayMidi) then
  begin
    if (LyricsState.TotalTime > BASS_ChannelBytes2Seconds(fStream, BASS_ChannelGetPosition(fStream, BASS_POS_BYTE))) then
      Result := false
    else
      Result := true;
  end
  else
    Result := AudioPlayback.Finished;

end;

function TScreenSing.Draw: boolean;
var
  DisplayTime:            real;
  DisplayPrefix:          string;
  DisplayMin:             integer;
  DisplaySec:             integer;
  T:                      integer;
  CurLyricsTime:          real;
  TotalTime:              real;
  VideoFrameTime:         Extended;
  Line:                   TLyricLine;
  LastWord:               TLyricWord;
  LineDuet:                   TLyricLine;
  LastWordDuet:               TLyricWord;
  medley_end:             boolean;
  medley_start_applause:  boolean;

begin
  Background.Draw;

  // swap static textures to current screen ones
  SwapToScreen(ScreenAct);

  // draw background picture (if any, and if no visualizations)
  // when we don't check for visualizations the visualizations would
  // be overdrawn by the picture when {UNDEFINED UseTexture} in UVisualizer
  //if (not fShowVisualization) then
  if ((not fShowVisualization) or (fShowBackground)) and (not fShowWebCam) then
    SingDrawBackground;

  if (fShowWebCam) and (Webcam.Capture <> nil) then
    SingDrawWebCamFrame;

  // set player names (for 2 screens and only singstar skin)
  if ScreenAct = 1 then
  begin
    Text[TextP1].Text     := 'P1';
    Text[TextP1TwoP].Text := 'P1';
    Text[TextP1ThreeP].Text := 'P1';
    Text[TextP2R].Text    := 'P2';
    Text[TextP2M].Text    := 'P2';
    Text[TextP3R].Text    := 'P3';

    if (CurrentSong.isDuet) and (PlayersPlay = 4) then
    begin
      Lyrics.LineColor_act.R := ColPlayer[0].R;
      Lyrics.LineColor_act.G := ColPlayer[0].G;
      Lyrics.LineColor_act.B := ColPlayer[0].B;

      LyricsDuet.LineColor_act.R := ColPlayer[1].R;
      LyricsDuet.LineColor_act.G := ColPlayer[1].G;
      LyricsDuet.LineColor_act.B := ColPlayer[1].B;
    end;
  end;

  if ScreenAct = 2 then
  begin
    case PlayersPlay of
      4:
      begin
        Text[TextP1TwoP].Text := 'P3';
        Text[TextP2R].Text    := 'P4';

        if (CurrentSong.isDuet) and (PlayersPlay = 4) then
        begin
          Lyrics.LineColor_act.R := ColPlayer[2].R;
          Lyrics.LineColor_act.G := ColPlayer[2].G;
          Lyrics.LineColor_act.B := ColPlayer[2].B;

          LyricsDuet.LineColor_act.R := ColPlayer[3].R;
          LyricsDuet.LineColor_act.G := ColPlayer[3].G;
          LyricsDuet.LineColor_act.B := ColPlayer[3].B;
        end;

      end;
      6:
      begin
        Text[TextP1ThreeP].Text := 'P4';
        Text[TextP2M].Text      := 'P5';
        Text[TextP3R].Text      := 'P6';
      end;
    end; // case
  end; // if

  // retrieve current lyrics time, we have to store the value to avoid
  // that min- and sec-values do not match
  if (ScreenSong.Mode = smMedley) then
  begin
    CurLyricsTime := LyricsState.GetCurrentTime() - MedleyStart;
    TotalTime := MedleyEnd - MedleyStart;
  end else
  begin
    CurLyricsTime := LyricsState.GetCurrentTime();
    TotalTime :=  LyricsState.TotalTime;
  end;

  // retrieve time for timebar text
  case (fTimebarMode) of
    tbmRemaining: begin
      DisplayTime := TotalTime - CurLyricsTime;
      DisplayPrefix := '-';
    end;
    tbmTotal: begin
      DisplayTime := TotalTime;
      DisplayPrefix := '#';
    end;
    else begin       // current time
      DisplayTime := CurLyricsTime;
      DisplayPrefix := '';
    end;
  end;
  DisplayMin := Round(DisplayTime) div 60;
  DisplaySec := Round(DisplayTime) mod 60;

  // update static menu with time ...
  Text[TextTimeText].Text := Format('%s%.2d:%.2d',
      [DisplayPrefix, DisplayMin, DisplaySec]);

  //the song was sung to the end?
  if not(CurrentSong.isDuet) then
  begin
    Line := Lyrics.GetUpperLine();
    if Line.LastLine then
    begin
      LastWord := Line.Words[Length(Line.Words)-1];
      if CurLyricsTime >= GetTimeFromBeat(LastWord.Start + LastWord.Length) then
        SungToEnd := true;
    end;
  end
  else
  begin
  {  Line := Lyrics.GetUpperLine();
    LineDuet := LyricsDuet.GetUpperLine();
    if Line.LastLine and (LineDuet.LastLine) then
    begin
      LastWord := Line.Words[Length(Line.Words)-1];
      LastWordDuet := LineDuet.Words[Length(Line.Words)-1];
      if (CurLyricsTime >= GetTimeFromBeat(LastWord.Start+LastWord.Length)) and (CurLyricsTime >= GetTimeFromBeat(LastWordDuet.Start+LastWordDuet.Length)) then
        // TODO SAVE DUET SCORES
        SungToEnd := false;
        //SungToEnd := true;
    end;
    }
  end;

  // for medley-mode:
  CurLyricsTime := LyricsState.GetCurrentTime();
  if (ScreenSong.Mode = smMedley) and (CurLyricsTime > MedleyEnd) then
    medley_end := true
  else
    medley_end := false;

  if (ScreenSong.Mode = smMedley) and (CurLyricsTime >
    GetTimeFromBeat(CurrentSong.Medley.EndBeat)) then
    medley_start_applause := true
  else
    medley_start_applause := false;

  // update and draw movie
  if Assigned(fCurrentVideo) then
  begin
    // Just call this once
    // when Screens = 2
    if (ScreenAct = 1) then
    begin
      if (ShowFinish) then
      begin
        // everything is setup, determine the current position
        VideoFrameTime := CurrentSong.VideoGAP + LyricsState.GetCurrentTime();
      end
      else
      begin
        // Important: do not yet start the triggered timer by a call to
        // LyricsState.GetCurrentTime()
        VideoFrameTime := CurrentSong.VideoGAP;
      end;
      fCurrentVideo.GetFrame(VideoFrameTime);
    end;

    fCurrentVideo.SetScreen(ScreenAct);
    fCurrentVideo.Draw;
  end;

  // draw static menu (FG)
  DrawFG;

  //Medley Countdown
  if (ScreenSong.Mode = smMedley) then
    DrawMedleyCountdown;

  // check for music finish
  //Log.LogError('Check for music finish: ' + BoolToStr(Music.Finished) + ' ' + FloatToStr(LyricsState.CurrentTime*1000) + ' ' + IntToStr(CurrentSong.Finish));
  if ShowFinish then
  begin
    if (not FinishedMusic) and (not medley_end or (ScreenSong.Mode <> smMedley)) and
       ((CurrentSong.Finish = 0) or
        (LyricsState.GetCurrentTime() * 1000 <= CurrentSong.Finish)) and
       (not Settings.Finish) then
    begin
      // analyze song if not paused
      if (not Paused) then
      begin
        Sing(Self);

        //Update Medley Stats
        if (ScreenSong.Mode = smMedley) and not FadeOut then
          UpdateMedleyStats(medley_start_applause);

        Party.CallOnSing;
      end;
    end
    else
    begin
      if (not FadeOut) and (Screens=1) or (ScreenAct=2) then
      begin
        Finish;
      end;
    end;
  end;

  // always draw custom items
  SingDraw;

  // goldennotestarstwinkle
  GoldenRec.SpawnRec;

  // draw scores
  Scores.Draw;

  // draw pausepopup
  // FIXME: this is a workaround that the static is drawn over the lyrics, lines, scores and effects
  // maybe someone could find a better solution
  if Paused then
  begin
    Statics[StaticPausePopup].Visible := true;
    Statics[StaticPausePopup].Draw;
    Statics[StaticPausePopup].Visible := false;
  end;

  FadeMessage();

  if (MidiFadeIn) then
    MedleyMidiFadeIn;

  if (MidiFadeOut) then
    MedleyMidiFadeOut;

  Result := true;
end;

procedure TScreenSing.Finish;
var
  I, J:     integer;
  len, num: integer;

begin
  AudioInput.CaptureStop;
  if (PlayMidi) then
  begin
    BASS_ChannelStop(fStream);
    BASS_StreamFree(fStream);
  end
  else
  begin
    AudioPlayback.Stop;
    AudioPlayback.SetSyncSource(nil);
  end;

  if (ScreenSong.Mode = smNormal) and (SungPaused = false) and (SungToEnd) and (Length(DllMan.Websites) > 0) then
  begin
    AutoSendScore;
    AutoSaveScore;
  end;

  LyricsState.Stop();
  LyricsState.SetSyncSource(nil);

  // close video files
  fVideoClip := nil;
  fCurrentVideo := nil;

  // kill all stars and effects
  GoldenRec.KillAll;

  if (Ini.SavePlayback = 1) then
  begin
    Log.BenchmarkStart(0);
    Log.LogVoice(0);
    if (PlayersPlay > 1) then
      Log.LogVoice(1);
    if (PlayersPlay > 2) then
      Log.LogVoice(2);
    Log.BenchmarkEnd(0);
    Log.LogBenchmark('Creating files', 0);
  end;

  SetFontItalic(false);

  if (ScreenSong.Mode = smMedley) then
  begin
    if not FadeOut then
    begin
      for I := 0 to PlayersPlay - 1 do
        PlaylistMedley.Stats[Length(PlaylistMedley.Stats)-1].Player[I] := Player[I];

      Inc(PlaylistMedley.CurrentMedleySong);
      if PlaylistMedley.CurrentMedleySong<=PlaylistMedley.NumMedleySongs then
      begin
        LoadNextSong;
      end else
      begin
        //build sums
        len := Length(PlaylistMedley.Stats);
        num := PlaylistMedley.NumPlayer;

        SetLength(PlaylistMedley.Stats, len+1);
        SetLength(PlaylistMedley.Stats[len].Player, num);

        for J := 0 to len - 1 do
        begin
          for I := 0 to num - 1 do
          begin
            PlaylistMedley.Stats[len].Player[I].Score :=
              PlaylistMedley.Stats[len].Player[I].Score +
              PlaylistMedley.Stats[J].Player[I].Score;

            PlaylistMedley.Stats[len].Player[I].ScoreLine :=
              PlaylistMedley.Stats[len].Player[I].ScoreLine +
              PlaylistMedley.Stats[J].Player[I].ScoreLine;

            PlaylistMedley.Stats[len].Player[I].ScoreGolden :=
              PlaylistMedley.Stats[len].Player[I].ScoreGolden +
              PlaylistMedley.Stats[J].Player[I].ScoreGolden;

            PlaylistMedley.Stats[len].Player[I].ScoreInt :=
              PlaylistMedley.Stats[len].Player[I].ScoreInt +
              PlaylistMedley.Stats[J].Player[I].ScoreInt;

            PlaylistMedley.Stats[len].Player[I].ScoreLineInt :=
              PlaylistMedley.Stats[len].Player[I].ScoreLineInt +
              PlaylistMedley.Stats[J].Player[I].ScoreLineInt;

            PlaylistMedley.Stats[len].Player[I].ScoreGoldenInt :=
              PlaylistMedley.Stats[len].Player[I].ScoreGoldenInt +
              PlaylistMedley.Stats[J].Player[I].ScoreGoldenInt;

            PlaylistMedley.Stats[len].Player[I].ScoreTotalInt :=
              PlaylistMedley.Stats[len].Player[I].ScoreTotalInt +
              PlaylistMedley.Stats[J].Player[I].ScoreTotalInt;
          end; //of for I
        end; //of for J

        //build mean on sum
        for I := 0 to num - 1 do
        begin
          PlaylistMedley.Stats[len].Player[I].Score := round(
            PlaylistMedley.Stats[len].Player[I].Score / len);

          PlaylistMedley.Stats[len].Player[I].ScoreLine := round(
            PlaylistMedley.Stats[len].Player[I].ScoreLine / len);

          PlaylistMedley.Stats[len].Player[I].ScoreGolden := round(
            PlaylistMedley.Stats[len].Player[I].ScoreGolden / len);

          PlaylistMedley.Stats[len].Player[I].ScoreInt := round(
            PlaylistMedley.Stats[len].Player[I].ScoreInt / len);

          PlaylistMedley.Stats[len].Player[I].ScoreLineInt := round(
            PlaylistMedley.Stats[len].Player[I].ScoreLineInt / len);

          PlaylistMedley.Stats[len].Player[I].ScoreGoldenInt := round(
            PlaylistMedley.Stats[len].Player[I].ScoreGoldenInt / len);

          PlaylistMedley.Stats[len].Player[I].ScoreTotalInt := round(
            PlaylistMedley.Stats[len].Player[I].ScoreTotalInt / len);
        end;

        Party.CallAfterSing;
        FadeOut:=true;
      end;
    end;
  end else
  begin
    SetLength(PlaylistMedley.Stats, 1);
    SetLength(PlaylistMedley.Stats[0].Player, PlayersPlay);
    for I := 0 to PlayersPlay - 1 do
      PlaylistMedley.Stats[0].Player[I] := Player[I];

    PlaylistMedley.Stats[0].SongArtist := CurrentSong.Artist;
    PlaylistMedley.Stats[0].SongTitle := CurrentSong.Title;

    if not FadeOut then
      Party.CallAfterSing;

    FadeOut := true;
  end;

end;

procedure TScreenSing.OnSentenceEnd(CP: integer; SentenceIndex: cardinal);
var
  PlayerIndex: byte;
  CurrentPlayer: PPLayer;
  CurrentScore: real;
  Line:      PLine;
  LinePerfection: real;  // perfection of singing performance on the current line
  Rating:    integer;
  LineScore: real;
  LineBonus: real;
  MaxSongScore: integer; // max. points for the song (without line bonus)
  MaxLineScore: real;    // max. points for the current line
  Index: integer;
const
  // TODO: move this to a better place
  MAX_LINE_RATING = 8;        // max. rating for singing performance
begin
  Line := @Lines[CP].Line[SentenceIndex];

  // check for empty sentence
  if (Line.TotalNotes <= 0) then
    Exit;

  // set max song score
  if (Ini.LineBonus = 0) then
    MaxSongScore := MAX_SONG_SCORE
  else
    MaxSongScore := MAX_SONG_SCORE - MAX_SONG_LINE_BONUS;

  // Note: ScoreValue is the sum of all note values of the song
  MaxLineScore := MaxSongScore * (Line.TotalNotes / Lines[CP].ScoreValue);

  for PlayerIndex := 0 to High(Player) do
  begin
    //PlayerIndex := Index;

    if (not CurrentSong.isDuet) or (PlayerIndex mod 2 = CP) or (PlayersPlay = 1)then
    begin
      CurrentPlayer := @Player[PlayerIndex];
      CurrentScore  := CurrentPlayer.Score + CurrentPlayer.ScoreGolden;

      // line bonus

      // points for this line
      LineScore := CurrentScore - CurrentPlayer.ScoreLast;

      // check for lines with low points
      if (MaxLineScore <= 2) then
        LinePerfection := 1
      else
        // determine LinePerfection
        // Note: the "+2" extra points are a little bonus so the player does not
        // have to be that perfect to reach the bonus steps.
        LinePerfection := LineScore / (MaxLineScore - 2);

      // clamp LinePerfection to range [0..1]
      if (LinePerfection < 0) then
        LinePerfection := 0
      else if (LinePerfection > 1) then
        LinePerfection := 1;

      // add line-bonus if enabled
      if (Ini.LineBonus > 0) then
      begin
        // line-bonus points (same for each line, no matter how long the line is)
        LineBonus := MAX_SONG_LINE_BONUS / (Length(Lines[CP].Line) -
          NumEmptySentences[CP]);
        // apply line-bonus
        CurrentPlayer.ScoreLine :=
          CurrentPlayer.ScoreLine + LineBonus * LinePerfection;
        CurrentPlayer.ScoreLineInt := Floor(CurrentPlayer.ScoreLine / 10) * 10;
        // update total score
        CurrentPlayer.ScoreTotalInt :=
          CurrentPlayer.ScoreInt +
          CurrentPlayer.ScoreGoldenInt
          + CurrentPlayer.ScoreLineInt;

        // spawn rating pop-up
        Rating := Round(LinePerfection * MAX_LINE_RATING);
        Scores.SpawnPopUp(PlayerIndex, Rating, CurrentPlayer.ScoreTotalInt);
      end
      else
        Scores.RaiseScore(PlayerIndex, CurrentPlayer.ScoreTotalInt);

      // PerfectLineTwinkle (effect), part 1
      if (Ini.EffectSing = 1) then
        CurrentPlayer.LastSentencePerfect := (LinePerfection >= 1);

      // refresh last score
      CurrentPlayer.ScoreLast := CurrentScore;
    end;
  end;

  // PerfectLineTwinkle (effect), part 2
  if (Ini.EffectSing = 1) then
  begin
    GoldenRec.SpawnPerfectLineTwinkle;

    for PlayerIndex := 0 to High(Player) do
    begin
      CurrentPlayer := @Player[PlayerIndex];
      CurrentPlayer.LastSentencePerfect := false;
    end;
  end;

end;

 // Called on sentence change
 // SentenceIndex: index of the new active sentence
procedure TScreenSing.OnSentenceChange(CP: integer; SentenceIndex: cardinal);
var
  tmp_Lyric: TLyricEngine;
begin
  // goldenstarstwinkle
  GoldenRec.SentenceChange(CP);

  if (CurrentSong.isDuet) and (PlayersPlay <> 1) then
  begin
    if (CP = 1) then
      tmp_Lyric := LyricsDuet
    else
      tmp_Lyric := Lyrics;
  end
  else
    tmp_Lyric := Lyrics;

  // fill lyrics queue and set upper line to the current sentence
  while (tmp_Lyric.GetUpperLineIndex() < SentenceIndex) or
    (not tmp_Lyric.IsQueueFull) do
  begin
    // add the next line to the queue or a dummy if no more lines are available
    if (tmp_Lyric.LineCounter <= High(Lines[CP].Line)) then
    begin
      tmp_Lyric.AddLine(@Lines[CP].Line[tmp_Lyric.LineCounter]);
    end
    else
      tmp_Lyric.AddLine(nil);
  end;

end;

function TLyricsSyncSource.GetClock(): real;
begin
  Result := LyricsState.GetCurrentTime();
end;

function TMusicSyncSource.GetClock(): real;
begin
  if (ScreenSing.PlayMidi) then
    Result := BASS_ChannelBytes2Seconds(ScreenSing.fStream, BASS_ChannelGetPosition(ScreenSing.fStream, BASS_POS_BYTE))
  else
    Result := AudioPlayback.Position;
end;

procedure TScreenSing.UpdateMedleyStats(medley_end: boolean);
var
  len, num, I : integer;

begin
  len := Length(PlaylistMedley.Stats);
  num := PlaylistMedley.NumPlayer;

  if (PlaylistMedley.CurrentMedleySong>len) and
    (PlaylistMedley.CurrentMedleySong<=PlaylistMedley.NumMedleySongs) then
  begin
    inc(len);
    SetLength(PlaylistMedley.Stats, len);
    SetLength(PlaylistMedley.Stats[len-1].Player, num);
    PlaylistMedley.Stats[len-1].SongArtist := CurrentSong.Artist;
    PlaylistMedley.Stats[len-1].SongTitle := CurrentSong.Title;
  end;

  if (PlaylistMedley.CurrentMedleySong<=PlaylistMedley.NumMedleySongs) then
    for I := 0 to num - 1 do
      PlaylistMedley.Stats[len-1].Player[I] := Player[I];

  if medley_end and not PlaylistMedley.ApplausePlayed and
    (PlaylistMedley.CurrentMedleySong<=PlaylistMedley.NumMedleySongs) then
  begin
    PlaylistMedley.ApplausePlayed:=true;

    if (PlayMidi) then
    begin
      MidiFadeOut := true;
      FadeTime := SDL_GetTicks();
      MedleyMidiFadeOut;
    end
    else
      AudioPlayback.Fade(CurrentSong.Medley.FadeOut_time, 0.1);
    AudioPlayback.PlaySound(SoundLib.Applause);
  end;
end;

procedure TScreenSing.DrawMedleyCountdown();
var
  w, h:           real;
  timeDiff:       real;
  t:              real;
  CountDownText:  UTF8String;
  Position:       real;
begin

  if (PlayMidi) then
    Position := BASS_ChannelBytes2Seconds(fStream, BASS_ChannelGetPosition(fStream, BASS_POS_BYTE))
  else
    Position := AudioPlayback.Position;

  if (Position < GetTimeFromBeat(CurrentSong.Medley.StartBeat)) then
  begin
    TextMedleyFadeOut := false;

    Statics[SongNameStatic].Texture.Alpha := 1;
    Text[SongNameText].Alpha := 1;

    Statics[SongNameStatic].Visible := true;
    Text[SongNameText].Visible := true;

    timeDiff := GetTimeFromBeat(CurrentSong.Medley.StartBeat) - Position + 1;
    t := frac(timeDiff);

    glColor4f(0.15, 0.30, 0.6, t);

    h := 300*t*ScreenH/RenderH;
    SetFontStyle(ftBoldHighRes);
    SetFontItalic(false);
    SetFontSize(h);
    CountDownText := IntToStr(round(timeDiff-t));
    w := glTextWidth(PChar(CountDownText));

    SetFontPos (RenderW/2-w/2, RenderH/2-h/2);
    glPrint(PChar(CountDownText));
  end else
  begin
    if (TextMedleyFadeOut = false) then
    begin
      TextMedleyFadeOut := true;
      TextMedleyFadeTime := SDL_GetTicks();
    end;

    MedleyTitleFadeOut;
  end;
end;

procedure TScreenSing.AutoSendScore;
var
  SendInfo: TSendInfo;
  SendStatus: byte;
  Send: boolean;
  TotalScore: integer;
  PlayerIndex, IndexWeb, IndexUser: integer;
begin
  for PlayerIndex := 1 to PlayersPlay do
  begin
    for IndexWeb := 0 to High(DataBase.NetworkUser) do
    begin
      for IndexUser := 0 to High(DataBase.NetworkUser[IndexWeb].Userlist) do
      begin
        Send := false;
        TotalScore := player[PlayerIndex - 1].ScoreInt + player[PlayerIndex - 1].ScoreLineInt + player[PlayerIndex - 1].ScoreGoldenInt;

        case (Act_Level) of
          0: if (TotalScore >= DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoScoreEasy)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoMode = 1)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoPlayer = PlayerIndex - 1) then
                Send := true;

          1: if (TotalScore >= DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoScoreMedium)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoMode = 1)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoPlayer = PlayerIndex - 1) then
                Send := true;

          2: if (TotalScore >= DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoScoreHard)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoMode = 1)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoPlayer = PlayerIndex - 1) then
                Send := true;
        end;

        if (Send) then
        begin

          DllMan.LoadWebsite(IndexWeb);

          SendInfo.Username := DataBase.NetworkUser[IndexWeb].UserList[IndexUser].Username;
          SendInfo.Password := DataBase.NetworkUser[IndexWeb].UserList[IndexUser].Password;

          if (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].SendSavePlayer = 1) then
            SendInfo.Name := Ini.Name[PlayerIndex - 1]
          else
            SendInfo.Name := '';

          SendInfo.ScoreInt := player[PlayerIndex - 1].ScoreInt;
          SendInfo.ScoreLineInt := player[PlayerIndex - 1].ScoreLineInt;
          SendInfo.ScoreGoldenInt := player[PlayerIndex - 1].ScoreGoldenInt;
          SendInfo.MD5Song := Act_MD5Song;
          SendInfo.Level := Act_Level;

          SendStatus := DllMan.WebsiteSendScore(SendInfo);

          case SendStatus of
            0: ScreenPopupError.ShowPopup(Language.Translate('WEBSITE_NO_CONNECTION'));
            2: ScreenPopupError.ShowPopup(Language.Translate('WEBSITE_LOGIN_ERROR'));
            3: ScreenPopupInfo.ShowPopup(Language.Translate('WEBSITE_OK_SEND'));
            4: ScreenPopupError.ShowPopup(Language.Translate('WEBSITE_ERROR_SCORE'));
            5: ScreenPopupError.ShowPopup(Language.Translate('WEBSITE_ERROR_SCORE_DUPLICATED'));
            7: ScreenPopupError.ShowPopup(Language.Translate('WEBSITE_ERROR_SONG'));
          end;

       end;
      end;
    end;
  end;
end;

procedure TScreenSing.AutoSaveScore;
var
  SendInfo: TSendInfo;
  ScoreFile: TextFile;
  EncryptText: string;
  WebName: UTF8String;
  Save: boolean;
  TotalScore: integer;
  PlayerIndex, IndexWeb, IndexUser: integer;
begin
  for PlayerIndex := 1 to PlayersPlay do
  begin
    for IndexWeb := 0 to High(DataBase.NetworkUser) do
    begin
      for IndexUser := 0 to High(DataBase.NetworkUser[IndexWeb].Userlist) do
      begin
        Save := false;
        TotalScore := player[PlayerIndex - 1].ScoreInt + player[PlayerIndex - 1].ScoreLineInt + player[PlayerIndex - 1].ScoreGoldenInt;

        case (Act_Level) of
          0: if (TotalScore >= DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoScoreEasy)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoMode = 2)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoPlayer = PlayerIndex - 1) then
                Save := true;

          1: if (TotalScore >= DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoScoreMedium)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoMode = 2)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoPlayer = PlayerIndex - 1) then
                Save := true;

          2: if (TotalScore >= DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoScoreHard)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoMode = 2)
              and (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].AutoPlayer = PlayerIndex - 1) then
                Save := true;
        end;

        if (Save) then
        begin

          DllMan.LoadWebsite(IndexWeb);

          SendInfo.Username := DataBase.NetworkUser[IndexWeb].UserList[IndexUser].Username;
          SendInfo.Password := DataBase.NetworkUser[IndexWeb].UserList[IndexUser].Password;

          if (DataBase.NetworkUser[IndexWeb].UserList[IndexUser].SendSavePlayer = 1) then
            SendInfo.Name := Ini.Name[PlayerIndex - 1]
          else
            SendInfo.Name := '';

          SendInfo.ScoreInt := player[PlayerIndex - 1].ScoreInt;
          SendInfo.ScoreLineInt := player[PlayerIndex - 1].ScoreLineInt;
          SendInfo.ScoreGoldenInt := player[PlayerIndex - 1].ScoreGoldenInt;
          SendInfo.MD5Song := Act_MD5Song;
          SendInfo.Level := Act_Level;

          WebName := DataBase.NetworkUser[IndexWeb].Website;
          EncryptText := DllMan.WebsiteEncryptScore(SendInfo);

          AssignFile(ScoreFile, WebScoresPath.Append(WebName + '.usc').ToNative);

          if FileExists(WebScoresPath.Append(WebName + '.usc').ToNative) then
            Append(ScoreFile)
          else
            Rewrite(ScoreFile);

          WriteLn(ScoreFile, DatetoStr(Now) + '|' + TimetoStr(Now) + '|' + EncryptText);

          Flush(ScoreFile);
          Close(ScoreFile);

          ScreenPopupInfo.ShowPopup(Language.Translate('WEBSITE_SAVE_SCORE'));

       end;
      end;
    end;
  end;
end;

procedure TScreenSing.WriteMessage(msg: UTF8String);
begin
  MessageTime := SDL_GetTicks();

  Statics[InfoMessageBG].Texture.Alpha := 1;
  Text[InfoMessageText].Alpha := 1;

  Statics[InfoMessageBG].Visible := true;
  Text[InfoMessageText].Visible := true;
  Text[InfoMessageText].Text := msg;
end;

procedure TScreenSing.FadeMessage();
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

procedure TScreenSing.CloseMessage();
begin
  Statics[InfoMessageBG].Visible := false;
  Text[InfoMessageText].Visible := false;
end;

procedure TScreenSing.MedleyMidiFadeIn();
var
  I: integer;
  Vol: cardinal;
  DiffTime: cardinal;
begin
  DiffTime := SDL_GetTicks() - FadeTime;
  Vol := Round((DiffTime * 127)/Trunc(8 * 1000));

  for I := 0 to 15 do
    BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, Vol);

  if (Vol >= 127) then
    MidiFadeIn := false;
end;

procedure TScreenSing.MedleyMidiFadeOut();
var
  I: integer;
  Vol: cardinal;
  DiffTime: cardinal;
begin
  DiffTime := SDL_GetTicks() - FadeTime;
  Vol := 127 - Round((DiffTime * 127)/Trunc(2 * 1000));

  for I := 0 to 15 do
    BASS_MIDI_StreamEvent(fstream, I, MIDI_EVENT_MIXLEVEL, Vol);

  if (Vol <= 0) then
    MidiFadeIn := false;
end;

procedure TScreenSing.MedleyTitleFadeOut();
var
  I: integer;
  Alpha: real;
  CTime: cardinal;
begin

  CTime := SDL_GetTicks() - TextMedleyFadeTime;
  Alpha := CTime/3000;

  if (Alpha >= 1) then
  begin
    Statics[SongNameStatic].Visible := false;
    Text[SongNameText].Visible := false;
  end
  else
  begin
    Text[SongNameText].Alpha := 1 - Alpha;
    Statics[SongNameStatic].Texture.Alpha := 1 - Alpha;
  end;
end;

function TScreenSing.GetLyricColor(Color: integer): TRGB;
begin
  case (Color) of
    1://blue
    begin
      Result.R := 5/255;
      Result.G := 153/255;
      Result.B := 204/255;
    end;
    2: //red
    begin
      Result.R := 230/255;
      Result.G := 0;
      Result.B := 0;
    end;
    3: //green
    begin
      Result.R := 0;
      Result.G := 170/255;
      Result.B := 0;
    end;
    4: //yellow
    begin
      Result.R := 255/255;
      Result.G := 225/255;
      Result.B := 0;
    end;
    5: //orange
    begin
      Result.R := 227/255;
      Result.G := 127/255;
      Result.B := 0;
    end;
    6: //pink
    begin
      Result.R := 255/255;
      Result.G := 0/255;
      Result.B := 130/255;
    end;
    7: //purple
    begin
      Result.R := 180/255;
      Result.G := 0;
      Result.B := 220/255;
    end;
    8: //gold
    begin
      Result.R := 255/255;
      Result.G := 190/255;
      Result.B := 35/255;
    end;
    9: //gray
    begin
      Result.R := 80/255;
      Result.G := 80/255;
      Result.B := 80/255;
    end;
  end;
end;

end.

