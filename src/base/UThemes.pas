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

unit UThemes;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  IniFiles,
  SysUtils,
  Classes,
  UCommon,
  ULog,
  UIni,
  USkins,
  UTexture,
  UPath;

type
  TBackgroundType =
    (bgtNone, bgtColor, bgtTexture, bgtVideo, bgtFade, bgtAuto);

const
  ThemeMinVersion = 19.12;
  DefaultTheme = 'Argon';
  BGT_Names: array [TBackgroundType] of string =
    ('none', 'color', 'texture', 'video', 'fade', 'auto');

type
  TThemeBackground = record
    BGType: TBackgroundType;
    Color:  TRGB;
    Tex:    string;
    Alpha:  real;
  end;

const
  //Defaul Background for Screens w/o Theme
  DEFAULT_BACKGROUND: TThemeBackground = (
    BGType: bgtColor;
    Color:  (R:1; G:1; B:1);
    Tex:    '';
    Alpha:  1.0
  );

type
  TThemePosition = record
    X: integer;
    Y: integer;
    H: integer;
    W: integer;
  end;

  TThemeStatic = record
    X:      integer;
    Y:      integer;
    Z:      real;
    W:      integer;
    H:      integer;
    PaddingX: integer;
    PaddingY: integer;
    Color:  string;
    ColR:   real;
    ColG:   real;
    ColB:   real;
    Tex:    string;
    Typ:    TTextureType;
    TexX1:  real;
    TexY1:  real;
    TexX2:  real;
    TexY2:  real;
    Alpha:  real;
    //Reflection
    Reflection:           boolean;
    Reflectionspacing:    real;
  end;
  AThemeStatic = array of TThemeStatic;

  TThemeText = record
    X:      integer;
    Y:      integer;
    W:      integer;
    Z:      real;
    Color:   string;
    DColor:  string;
    ColR:   real;
    ColG:   real;
    ColB:   real;
    DColR:   real;
    DColG:   real;
    DColB:   real;
    Font:   integer;
    Size:   integer;
    Align:  integer;
    Text:   UTF8String;
    Writable: boolean; // true -> add a blink char (|) at the end
    //Reflection
    Reflection:           boolean;
    ReflectionSpacing:    real;
  end;
  AThemeText = array of TThemeText;

  TThemeButton = record
    Text:   AThemeText;
    X:      integer;
    Y:      integer;
    Z:      real;
    W:      integer;
    H:      integer;
    Color:  string;
    ColR:   real;
    ColG:   real;
    ColB:   real;
    Int:    real;
    DColor: string;
    DColR:  real;
    DColG:  real;
    DColB:  real;
    DInt:   real;
    Tex:    string;
    Typ:    TTextureType;

    Visible: boolean;

    //Reflection Mod
    Reflection:           boolean;
    Reflectionspacing:    real;
    //Fade Mod
    SelectH:    integer;
    SelectW:    integer;
    Fade:       boolean;
    FadeText:   boolean;
    DeSelectReflectionspacing : real;
    FadeTex:    string;
    FadeTexPos: integer;

    //Button Collection Mod
    Parent: byte; //Number of the Button Collection this Button is assigned to. IF 0: No Assignement
  end;

  //Button Collection Mod
  TThemeButtonCollection = record
    Style: TThemeButton;
    ChildCount: byte; //No of assigned Childs
    FirstChild: byte; //No of Child on whose Interaction Position the Button should be
  end;

  AThemeButtonCollection = array of TThemeButtonCollection;
  PAThemeButtonCollection = ^AThemeButtonCollection;

  TThemeSelectSlide = record
    Tex:    string;
    Typ:    TTextureType;
    TexSBG: string;
    TypSBG: TTextureType;
    X:      integer;
    Y:      integer;
    W:      integer;
    H:      integer;
    Z:      real;
    SBGW:   integer;

    TextSize: integer;

    ShowArrows:boolean;
    OneItemOnly:boolean;

    Text:   UTF8String;
    ColR,  ColG,  ColB,  Int:     real;
    DColR, DColG, DColB, DInt:    real;
    TColR,  TColG,  TColB,  TInt:     real;
    TDColR, TDColG, TDColB, TDInt:    real;
    SBGColR,  SBGColG,  SBGColB,  SBGInt:     real;
    SBGDColR, SBGDColG, SBGDColB, SBGDInt:    real;
    STColR,  STColG,  STColB,  STInt:     real;
    STDColR, STDColG, STDColB, STDInt:    real;
    SkipX:    integer;
  end;

  TThemeEqualizer = record
    Visible: boolean;
    Direction: boolean;
    Alpha: real;
    X: integer;
    Y: integer;
    Z: real;
    W: integer;
    H: integer;
    Space: integer;
    Bands: integer;
    Length: integer;
    ColR, ColG, ColB: real;
    Reflection:           boolean;
    Reflectionspacing:    real;
  end;

  PThemeBasic = ^TThemeBasic;
  TThemeBasic = class
    Background:       TThemeBackground;
    Text:             AThemeText;
    Statics:           AThemeStatic;

    //Button Collection Mod
    ButtonCollection: AThemeButtonCollection;
  end;

  TThemeLoading = class(TThemeBasic)
    StaticAnimation:  TThemeStatic;
    TextLoading:      TThemeText;
  end;

  TThemeMain = class(TThemeBasic)
    ButtonSolo:       TThemeButton;
    ButtonMulti:      TThemeButton;
    ButtonJukebox:    TThemeButton;
    ButtonStat:       TThemeButton;
    ButtonOptions:    TThemeButton;
    ButtonExit:       TThemeButton;
    ButtonAbout:      TThemeButton;
    ProgressSongsText: TThemeText;

    TextDescription:      TThemeText;
    TextDescriptionLong:  TThemeText;
    Description:          array[0..7] of UTF8String;
    DescriptionLong:      array[0..7] of UTF8String;

  end;

  TThemePlayerSelector = class(TThemeBasic)
    PlayerButtonName:          TThemeButton;
    PlayerButtonAvatar:        TThemeButton;

    PlayerScrollAvatar: record
      NumAvatars: integer;
      DistanceAvatars: integer;
    end;

    PlayerAvatar:        TThemeButton;

    PlayerSelect:        array [0..UIni.IMaxPlayerCount-1] of TThemeStatic;
    PlayerSelectText:    array [0..UIni.IMaxPlayerCount-1] of TThemeText;
    PlayerSelectAvatar:  array [0..UIni.IMaxPlayerCount-1] of TThemeStatic;
    PlayerSelectCurrent: TThemeButton;

    SelectPlayersCount:  TThemeSelectSlide;
    SelectPlayerColor:   TThemeSelectSlide;
    SelectPlayerLevel:   TThemeSelectSlide;
    SingButton: TThemeButton;
    ExitButton: TThemeButton;
  end;

  TThemeSong = class(TThemeBasic)
    TextNoSongs: TThemeText;
    TextArtist: TThemeText;
    TextNumber: TThemeText;
    TextTitle: TThemeText;
    TextYear: TThemeText;
    TextCreator: TThemeText;
    TextFixer: TThemeText;
    SearchIcon: TThemeStatic;
    SearchText: TThemeText;
    SearchTextPlaceholder: TThemeText;

    //Song icons
    VideoIcon: TThemeStatic;
    MedleyIcon: TThemeStatic;
    CalculatedMedleyIcon: TThemeStatic;
    DuetIcon: TThemeStatic;
    RapIcon: TThemeStatic;
    CreatorIcon: TThemeStatic;
    FixerIcon: TThemeStatic;
    UnvalidatedIcon: TThemeStatic;

    //Show Cat in TopLeft Mod
    TextCat:          TThemeText;

    SongSelectionUp: TThemeStatic;
    SongSelectionDown: TThemeStatic;
    Equalizer: TThemeEqualizer;

    //Cover Mod
    Cover: record
      X: integer;
      Y: integer;
      Z: integer;
      W: integer;
      H: integer;
      Rows: integer;
      Cols: integer;
      Padding: integer;
      Reflections: boolean;
      ReflectionSpacing: integer;
      ZoomThumbW: integer;
      ZoomThumbH: integer;
    end;

    MainCover: TThemeStatic;

    //List Song Mod
    ListCover: record
      X: integer;
      Y: integer;
      Z: integer;
      W: integer;
      H: integer;
      Padding: integer;
      Reflection: boolean;
      ReflectionSpacing: integer;
      Typ:    TTextureType;
      Tex: string;
      DTex: string;
      Color:  string;
      DColor:  string;
      ColR, ColG, ColB: real;
      DColR, DColG, DColB: real;
    end;

    //Party and Non Party specific Statics and Texts
    StaticParty:    AThemeStatic;
    TextParty:      AThemeText;

    StaticNonParty: AThemeStatic;
    TextNonParty:   AThemeText;

    InfoMessageText: TThemeText;
    InfoMessageBG:   TThemeStatic;

    //Ranking Song Screen
    TextMyScores:         TThemeText;
    TextWebsite:          TThemeText;
    TextUserLocalScore1:  TThemeText;
    TextUserLocalScore2:  TThemeText;
    TextUserLocalScore3:  TThemeText;
    TextLocalScore1:      TThemeText;
    TextLocalScore2:      TThemeText;
    TextLocalScore3:      TThemeText;
    TextUserOnlineScore1: TThemeText;
    TextUserOnlineScore2: TThemeText;
    TextUserOnlineScore3: TThemeText;
    TextOnlineScore1:     TThemeText;
    TextOnlineScore2:     TThemeText;
    TextOnlineScore3:     TThemeText;

    //Party Mode
    StaticTeamJoker: TThemeStatic;

    TextPartyTime    : TThemeText;

    Static2PlayersDuetSingerP1: TThemeStatic;
    Static2PlayersDuetSingerP2: TThemeStatic;

    Static3PlayersDuetSingerP1: TThemeStatic;
    Static3PlayersDuetSingerP2: TThemeStatic;
    Static3PlayersDuetSingerP3: TThemeStatic;

    Static4PlayersDuetSingerP3: TThemeStatic;
    Static4PlayersDuetSingerP4: TThemeStatic;

    Static6PlayersDuetSingerP4: TThemeStatic;
    Static6PlayersDuetSingerP5: TThemeStatic;
    Static6PlayersDuetSingerP6: TThemeStatic;

    Text2PlayersDuetSingerP1:   TThemeText;
    Text2PlayersDuetSingerP2:   TThemeText;

    Text3PlayersDuetSingerP1:   TThemeText;
    Text3PlayersDuetSingerP2:   TThemeText;
    Text3PlayersDuetSingerP3:   TThemeText;
  end;

  TThemeSing = class(TThemeBasic)
    //TimeBar mod
    StaticTimeProgress:   TThemeStatic;
    TextTimeText      :   TThemeText;
    //eoa TimeBar mod

    StaticP1:         TThemeStatic;
    TextP1:           TThemeText;
    StaticP1ScoreBG:  TThemeStatic; //Static for ScoreBG
    TextP1Score:      TThemeText;
    StaticP1Avatar:   TThemeStatic;

    //moveable singbar mod
    StaticP1SingBar:         TThemeStatic;
    StaticP1ThreePSingBar:   TThemeStatic;
    StaticP1TwoPSingBar:     TThemeStatic;
    StaticP2RSingBar:        TThemeStatic;
    StaticP2MSingBar:        TThemeStatic;
    StaticP3SingBar:         TThemeStatic;
    //eoa moveable singbar

    //added for ps3 skin
    //game in 2/4 player modi
    StaticP1TwoP:         TThemeStatic;
    StaticP1TwoPAvatar:   TThemeStatic;
    StaticP1TwoPScoreBG:  TThemeStatic; //Static for ScoreBG
    TextP1TwoP:           TThemeText;
    TextP1TwoPScore:      TThemeText;
    //game in 3/6 player modi
    StaticP1ThreeP:         TThemeStatic;
    StaticP1ThreePAvatar:   TThemeStatic;
    StaticP1ThreePScoreBG:  TThemeStatic; //Static for ScoreBG
    TextP1ThreeP:           TThemeText;
    TextP1ThreePScore:      TThemeText;
    //eoa

    StaticP2R:        TThemeStatic;
    StaticP2RAvatar:  TThemeStatic;
    StaticP2RScoreBG: TThemeStatic; //Static for ScoreBG
    TextP2R:          TThemeText;
    TextP2RScore:     TThemeText;

    StaticP2M:        TThemeStatic;
    StaticP2MAvatar:  TThemeStatic;
    StaticP2MScoreBG: TThemeStatic; //Static for ScoreBG
    TextP2M:          TThemeText;
    TextP2MScore:     TThemeText;

    StaticP3R:        TThemeStatic;
    StaticP3RAvatar:  TThemeStatic;
    StaticP3RScoreBG: TThemeStatic; //Static for ScoreBG
    TextP3R:          TThemeText;
    TextP3RScore:     TThemeText;

    StaticDuetP1ThreeP:        TThemeStatic;
    StaticDuetP1ThreePAvatar:  TThemeStatic;
    TextDuetP1ThreeP:          TThemeText;
    StaticDuetP1ThreePScoreBG: TThemeStatic;
    TextDuetP1ThreePScore:     TThemeText;

    StaticDuetP2M:        TThemeStatic;
    StaticDuetP2MAvatar:  TThemeStatic;
    TextDuetP2M:          TThemeText;
    StaticDuetP2MScoreBG: TThemeStatic;
    TextDuetP2MScore:     TThemeText;

    StaticDuetP3R:        TThemeStatic;
    StaticDuetP3RAvatar:  TThemeStatic;
    TextDuetP3R:          TThemeText;
    StaticDuetP3RScoreBG: TThemeStatic;
    TextDuetP3RScore:     TThemeText;

    StaticDuetP1ThreePSingBar: TThemeStatic;
    StaticDuetP2MSingBar:      TThemeStatic;
    StaticDuetP3RSingBar:       TThemeStatic;

    //game in 4/6 player modi in 1 Screen
    StaticP1FourPSingBar: TThemeStatic;
    StaticP1FourP:        TThemeStatic;
    StaticP1FourPAvatar:  TThemeStatic;
    StaticP1FourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP1FourP:          TThemeText;
    TextP1FourPScore:     TThemeText;

    StaticP2FourPSingBar: TThemeStatic;
    StaticP2FourP:        TThemeStatic;
    StaticP2FourPAvatar:  TThemeStatic;
    StaticP2FourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP2FourP:          TThemeText;
    TextP2FourPScore:     TThemeText;

    StaticP3FourPSingBar: TThemeStatic;
    StaticP3FourP:        TThemeStatic;
    StaticP3FourPAvatar:  TThemeStatic;
    StaticP3FourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP3FourP:          TThemeText;
    TextP3FourPScore:     TThemeText;

    StaticP4FourPSingBar: TThemeStatic;
    StaticP4FourP:        TThemeStatic;
    StaticP4FourPAvatar:  TThemeStatic;
    StaticP4FourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP4FourP:          TThemeText;
    TextP4FourPScore:     TThemeText;

    StaticP1SixPSingBar: TThemeStatic;
    StaticP1SixP:        TThemeStatic;
    StaticP1SixPAvatar:  TThemeStatic;
    StaticP1SixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP1SixP:          TThemeText;
    TextP1SixPScore:     TThemeText;

    StaticP2SixPSingBar: TThemeStatic;
    StaticP2SixP:        TThemeStatic;
    StaticP2SixPAvatar:  TThemeStatic;
    StaticP2SixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP2SixP:          TThemeText;
    TextP2SixPScore:     TThemeText;

    StaticP3SixPSingBar: TThemeStatic;
    StaticP3SixP:        TThemeStatic;
    StaticP3SixPAvatar:  TThemeStatic;
    StaticP3SixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP3SixP:          TThemeText;
    TextP3SixPScore:     TThemeText;

    StaticP4SixPSingBar: TThemeStatic;
    StaticP4SixP:        TThemeStatic;
    StaticP4SixPAvatar:  TThemeStatic;
    StaticP4SixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP4SixP:          TThemeText;
    TextP4SixPScore:     TThemeText;

    StaticP5SixPSingBar: TThemeStatic;
    StaticP5SixP:        TThemeStatic;
    StaticP5SixPAvatar:  TThemeStatic;
    StaticP5SixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP5SixP:          TThemeText;
    TextP5SixPScore:     TThemeText;

    StaticP6SixPSingBar: TThemeStatic;
    StaticP6SixP:        TThemeStatic;
    StaticP6SixPAvatar:  TThemeStatic;
    StaticP6SixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP6SixP:          TThemeText;
    TextP6SixPScore:     TThemeText;

    // duet 4/6 players in one screen
    StaticP1DuetFourPSingBar: TThemeStatic;
    StaticP1DuetFourP:        TThemeStatic;
    StaticP1DuetFourPAvatar:  TThemeStatic;
    StaticP1DuetFourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP1DuetFourP:          TThemeText;
    TextP1DuetFourPScore:     TThemeText;

    StaticP2DuetFourPSingBar: TThemeStatic;
    StaticP2DuetFourP:        TThemeStatic;
    StaticP2DuetFourPAvatar:  TThemeStatic;
    StaticP2DuetFourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP2DuetFourP:          TThemeText;
    TextP2DuetFourPScore:     TThemeText;

    StaticP3DuetFourPSingBar: TThemeStatic;
    StaticP3DuetFourP:        TThemeStatic;
    StaticP3DuetFourPAvatar:  TThemeStatic;
    StaticP3DuetFourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP3DuetFourP:          TThemeText;
    TextP3DuetFourPScore:     TThemeText;

    StaticP4DuetFourPSingBar: TThemeStatic;
    StaticP4DuetFourP:        TThemeStatic;
    StaticP4DuetFourPAvatar:  TThemeStatic;
    StaticP4DuetFourPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP4DuetFourP:          TThemeText;
    TextP4DuetFourPScore:     TThemeText;

    StaticP1DuetSixPSingBar: TThemeStatic;
    StaticP1DuetSixP:        TThemeStatic;
    StaticP1DuetSixPAvatar:  TThemeStatic;
    StaticP1DuetSixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP1DuetSixP:          TThemeText;
    TextP1DuetSixPScore:     TThemeText;

    StaticP2DuetSixPSingBar: TThemeStatic;
    StaticP2DuetSixP:        TThemeStatic;
    StaticP2DuetSixPAvatar:  TThemeStatic;
    StaticP2DuetSixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP2DuetSixP:          TThemeText;
    TextP2DuetSixPScore:     TThemeText;

    StaticP3DuetSixPSingBar: TThemeStatic;
    StaticP3DuetSixP:        TThemeStatic;
    StaticP3DuetSixPAvatar:  TThemeStatic;
    StaticP3DuetSixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP3DuetSixP:          TThemeText;
    TextP3DuetSixPScore:     TThemeText;

    StaticP4DuetSixPSingBar: TThemeStatic;
    StaticP4DuetSixP:        TThemeStatic;
    StaticP4DuetSixPAvatar:  TThemeStatic;
    StaticP4DuetSixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP4DuetSixP:          TThemeText;
    TextP4DuetSixPScore:     TThemeText;

    StaticP5DuetSixPSingBar: TThemeStatic;
    StaticP5DuetSixP:        TThemeStatic;
    StaticP5DuetSixPAvatar:  TThemeStatic;
    StaticP5DuetSixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP5DuetSixP:          TThemeText;
    TextP5DuetSixPScore:     TThemeText;

    StaticP6DuetSixPSingBar: TThemeStatic;
    StaticP6DuetSixP:        TThemeStatic;
    StaticP6DuetSixPAvatar:  TThemeStatic;
    StaticP6DuetSixPScoreBG: TThemeStatic; //Static for ScoreBG
    TextP6DuetSixP:          TThemeText;
    TextP6DuetSixPScore:     TThemeText;

    SingP1Oscilloscope:           TThemePosition;
    SingP1TwoPOscilloscope:       TThemePosition;
    SingP2ROscilloscope:          TThemePosition;
    SingP1ThreePOscilloscope:     TThemePosition;
    SingP2MOscilloscope:          TThemePosition;
    SingP3ROscilloscope:          TThemePosition;
    SingDuetP1ThreePOscilloscope: TThemePosition;
    SingDuetP2MOscilloscope:      TThemePosition;
    SingDuetP3ROscilloscope:      TThemePosition;
    SingP1FourPOscilloscope:      TThemePosition;
    SingP2FourPOscilloscope:      TThemePosition;
    SingP3FourPOscilloscope:      TThemePosition;
    SingP4FourPOscilloscope:      TThemePosition;
    SingP1SixPOscilloscope:       TThemePosition;
    SingP2SixPOscilloscope:       TThemePosition;
    SingP3SixPOscilloscope:       TThemePosition;
    SingP4SixPOscilloscope:       TThemePosition;
    SingP5SixPOscilloscope:       TThemePosition;
    SingP6SixPOscilloscope:       TThemePosition;
    SingP1DuetFourPOscilloscope:  TThemePosition;
    SingP2DuetFourPOscilloscope:  TThemePosition;
    SingP3DuetFourPOscilloscope:  TThemePosition;
    SingP4DuetFourPOscilloscope:  TThemePosition;
    SingP1DuetSixPOscilloscope:   TThemePosition;
    SingP2DuetSixPOscilloscope:   TThemePosition;
    SingP3DuetSixPOscilloscope:   TThemePosition;
    SingP4DuetSixPOscilloscope:   TThemePosition;
    SingP5DuetSixPOscilloscope:   TThemePosition;
    SingP6DuetSixPOscilloscope:   TThemePosition;

    StaticSongName:   TThemeStatic;
    TextSongName:     TThemeText;

    //Linebonus Translations
    LineBonusText:    array [0..8] of UTF8String;

    //Pause Popup
    PausePopUp:      TThemeStatic;

    InfoMessageText: TThemeText;
    InfoMessageBG:   TThemeStatic;

    StaticDuet: AThemeStatic;
  end;

  TThemeJukebox = class(TThemeBasic)
    StaticTimeProgress:   TThemeStatic;
    StaticTimeBackground: TThemeStatic;
    StaticSongBackground: TThemeStatic;
    StaticSongListBackground: TThemeStatic;
    TextTimeText:         TThemeText;
    TextSongText:         TThemeText;
    SongDescription:      TThemeButton;
    FindSong:             TThemeButton;
    RepeatSongList:       TThemeButton;
    SongListOrder:        TThemeButton;
    RandomSongList:       TThemeButton;
    Lyric:                TThemeButton;
    Options:              TThemeButton;
    SongListClose:        TThemeButton;
    SongListFixPin:       TThemeButton;
    TextListText:         TThemeText;
    TextCountText:        TThemeText;
    SongCover:            TThemeStatic;
    SongListPlayPause:    TThemeButton;

    StaticActualSongStatics:    AThemeStatic;
    StaticActualSongCover:      TThemeStatic;
    TextActualSongArtist:       TThemeText;
    TextActualSongTitle:        TThemeText;

    SongListUp:   TThemeButton;
    SongListDown: TThemeButton;

    //Jukebox SongMenu
    StaticSongMenuBackground:     TThemeStatic;
    SongMenuPlayPause:     TThemeButton;
    StaticSongMenuTimeProgress:   TThemeStatic;
    StaticSongMenuTimeBackground: TThemeStatic;
    SongMenuNext:          TThemeButton;
    SongMenuPrevious:      TThemeButton;
    SongMenuPlaylist:      TThemeButton;
    SongMenuTextTime:      TThemeText;
    SongMenuOptions:       TThemeButton;

    //Jukebox SongOptions
    StaticSongOptionsBackground: TThemeStatic;
    SongOptionsClose:            TThemeButton;
    SongOptionsVideoText:        TThemeText;
    SongOptionsLyricText:        TThemeText;
    SongOptionsLyricPositionSlide:   TThemeSelectSlide;
    SongOptionsLyricFontSlide: TThemeSelectSlide;
    SongOptionsLyricEffectSlide: TThemeSelectSlide;
    SongOptionsLyricColorSlide:      TThemeSelectSlide;
    SongOptionsLyricLineSlide:       TThemeSelectSlide;
    SongOptionsLyricPropertySlide:   TThemeSelectSlide;
    SongOptionsLyricAlphaSlide:      TThemeSelectSlide;
    SelectR:            TThemeSelectSlide;
    SelectG:            TThemeSelectSlide;
    SelectB:            TThemeSelectSlide;
    PointerR:           TThemeStatic;
    PointerG:           TThemeStatic;
    PointerB:           TThemeStatic;
  end;

  TThemeJukeboxPlaylist = class(TThemeBasic)
    SelectPlayList: TThemeSelectSlide;
    SelectPlayListItems: TThemeSelectSlide;
  end;

  TThemeLyricBar = record
     YOffset, IndicatorYOffset: integer;
     Upper, Lower: TThemePosition;
  end;

  TThemeScore = class(TThemeBasic)
    TextArtist:       TThemeText;
    TextTitle:        TThemeText;

    TextArtistTitle:  TThemeText;

    PlayerStatic:     array[1..UIni.IMaxPlayerCount] of AThemeStatic;
    PlayerTexts:      array[1..UIni.IMaxPlayerCount] of AThemeText;

    TextName:         array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextScore:        array[1..UIni.IMaxPlayerCount] of TThemeText;

    AvatarStatic:     array[1..UIni.IMaxPlayerCount] of TThemeStatic;

    TextNotes:            array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextNotesScore:       array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextLineBonus:        array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextLineBonusScore:   array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextGoldenNotes:      array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextGoldenNotesScore: array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextTotal:            array[1..UIni.IMaxPlayerCount] of TThemeText;
    TextTotalScore:       array[1..UIni.IMaxPlayerCount] of TThemeText;

    StaticBoxLightest:    array[1..UIni.IMaxPlayerCount] of TThemeStatic;
    StaticBoxLight:       array[1..UIni.IMaxPlayerCount] of TThemeStatic;
    StaticBoxDark:        array[1..UIni.IMaxPlayerCount] of TThemeStatic;

    StaticRatings:        array[1..UIni.IMaxPlayerCount] of TThemeStatic;

    StaticBackLevel:        array[1..UIni.IMaxPlayerCount] of TThemeStatic;
    StaticBackLevelRound:   array[1..UIni.IMaxPlayerCount] of TThemeStatic;
    StaticLevel:            array[1..UIni.IMaxPlayerCount] of TThemeStatic;
    StaticLevelRound:       array[1..UIni.IMaxPlayerCount] of TThemeStatic;

    ButtonSend:  array[1..UIni.IMaxPlayerCount] of TThemeButton;
  end;

  TThemeTop5 = class(TThemeBasic)
    TextLevel:        TThemeText;
    TextArtistTitle:  TThemeText;

    StaticNumber:     AThemeStatic;
    TextNumber:       AThemeText;
    TextName:         AThemeText;
    TextScore:        AThemeText;
    TextDate:         AThemeText;
  end;

  TThemeOptions = class(TThemeBasic)
    ButtonGame:        TThemeButton;
    ButtonGraphics:    TThemeButton;
    ButtonSound:       TThemeButton;
    ButtonLyrics:      TThemeButton;
    ButtonThemes:      TThemeButton;
    ButtonMicrophones: TThemeButton;
    ButtonAdvanced:    TThemeButton;
    ButtonNetwork:     TThemeButton;
    ButtonWebcam:      TThemeButton;
    ButtonProfiles:    TThemeButton;
    ButtonExit:        TThemeButton;

    TextDescription:      TThemeText;
    Description:          array[0..10] of UTF8String;
  end;

  TThemeOptionsGame = class(TThemeBasic)
    SelectLanguage: TThemeSelectSlide;
    SelectSongMenu: TThemeSelectSlide;
    SelectDuets: TThemeSelectSlide;
    SelectTabs: TThemeSelectSlide;
    SelectSorting: TThemeSelectSlide;
    SelectShowScores: TThemeSelectSlide;
    SelectSingScores: TThemeSelectSlide;
    SelectFindUnsetMedley: TThemeSelectSlide;
    ButtonExit:TThemeButton;
  end;

  TThemeOptionsGraphics = class(TThemeBasic)
    SelectFullscreen:       TThemeSelectSlide;
    SelectResolution:       TThemeSelectSlide;
    SelectEffectSing:     	TThemeSelectSlide;
    SelectScreenFade:     	TThemeSelectSlide;
    SelectVisualizer:       TThemeSelectSlide;
    SelectMovieSize:        TThemeSelectSlide;
    ButtonExit:             TThemeButton;
  end;

  TThemeOptionsSound = class(TThemeBasic)
    SelectBackgroundMusic:       TThemeSelectSlide;
    SelectClickAssist:           TThemeSelectSlide;
    SelectBeatClick:             TThemeSelectSlide;
    SelectSlidePreviewVolume:    TThemeSelectSlide;
    SelectSlidePreviewFading:    TThemeSelectSlide;
    SelectSlideVoicePassthrough: TThemeSelectSlide;
    SelectSlideMusicAutoGain:    TThemeSelectSlide;
    ButtonExit:                  TThemeButton;
  end;

  TThemeOptionsLyrics = class(TThemeBasic)
    SelectMode: TThemeSelectSlide;
    SelectModeProperty: TThemeSelectSlide;
    SelectFont: TThemeSelectSlide;
    SelectEffect: TThemeSelectSlide;
    SelectTransparency: TThemeSelectSlide;
    SelectLines: TThemeSelectSlide;
    SelectProperty: TThemeSelectSlide;
    SelectColor: TThemeSelectSlide;
    SelectR: TThemeSelectSlide;
    SelectG: TThemeSelectSlide;
    SelectB: TThemeSelectSlide;
    PointerR: TThemeStatic;
    PointerG: TThemeStatic;
    PointerB: TThemeStatic;
    TexColor: TThemeStatic;
    LyricBar: TThemeLyricBar;
    ButtonExit: TThemeButton;
  end;

  TThemeOptionsThemes = class(TThemeBasic)
    SelectTheme:        TThemeSelectSlide;
    SelectSkin:         TThemeSelectSlide;
    SelectColor:        TThemeSelectSlide;
    ButtonExit:         TThemeButton;
  end;

  TThemeOptionsMicrophones = class(TThemeBasic)
    SelectSlideCard:       TThemeSelectSlide;
    SelectSlideInput:      TThemeSelectSlide;
    SelectSlideChannel:    TThemeSelectSlide;
    SelectThreshold:       TThemeSelectSlide;
    SelectMicBoost:        TThemeSelectSlide;
    ButtonExit:            TThemeButton;
  end;

  TThemeOptionsAdvanced = class(TThemeBasic)
    SelectDebug:          TThemeSelectSlide;
    SelectOscilloscope:   TThemeSelectSlide;
    SelectAskbeforeDel:   TThemeSelectSlide;
    SelectOnSongClick:    TThemeSelectSlide;
    SelectPartyPopup:     TThemeSelectSlide;
    SelectTopScores:      TThemeSelectSlide;
    ButtonExit:           TThemeButton;
  end;

  TThemeOptionsNetwork = class(TThemeBasic)
    SelectWebsite:        TThemeSelectSlide;
    SelectUsername:       TThemeSelectSlide;
    SelectSendName:       TThemeSelectSlide;
    SelectAutoMode:       TThemeSelectSlide;
    SelectAutoPlayer:     TThemeSelectSlide;
    SelectAutoScoreEasy:   TThemeSelectSlide;
    SelectAutoScoreMedium: TThemeSelectSlide;
    SelectAutoScoreHard:   TThemeSelectSlide;
    TextInsertUser:       TThemeText;
    ButtonInsert:         TThemeButton;
    ButtonExit:           TThemeButton;
  end;

  TThemeOptionsWebcam = class(TThemeBasic)
    SelectWebcam:         TThemeSelectSlide;
    SelectResolution:     TThemeSelectSlide;
    SelectFPS:            TThemeSelectSlide;
    SelectFlip:           TThemeSelectSlide;
    SelectBrightness:     TThemeSelectSlide;
    SelectSaturation:     TThemeSelectSlide;
    SelectHue:            TThemeSelectSlide;
    SelectEffect:         TThemeSelectSlide;

    ButtonPreVisualization: TThemeButton;
    ButtonExit:           TThemeButton;
  end;

  TThemeOptionsProfiles = class(TThemeBasic)
    ButtonExit:           TThemeButton;
  end;

  //Error- and Check-Popup
  TThemeError = class(TThemeBasic)
    Button1: TThemeButton;
    TextError: TThemeText;
  end;

  TThemeCheck = class(TThemeBasic)
    Button1: TThemeButton;
    Button2: TThemeButton;
    TextCheck: TThemeText;
  end;

  TThemeInsertUser = class(TThemeBasic)
    TextInsertUser: TThemeText;
    ButtonUsername: TThemeButton;
    ButtonPassword: TThemeButton;
    Button1: TThemeButton;
    Button2: TThemeButton;
  end;

  TThemeSendScore = class(TThemeBasic)
    SelectSlide1: TThemeSelectSlide;
    SelectSlide2: TThemeSelectSlide;
    SelectSlide3: TThemeSelectSlide;
    ButtonUsername: TThemeButton;
    ButtonPassword: TThemeButton;
    Button1:  TThemeButton;
    Button2:  TThemeButton;
  end;

  TThemeScoreDownload = class(TThemeBasic)
    Button1: TThemeButton;
    TextSongScoreDownload: TThemeText;
    TextWebScoreDownload: TThemeText;
    DownloadProgressSong: TThemeStatic;
    DownloadProgressWeb: TThemeStatic;
  end;

  //ScreenSong Menu
  TThemeSongMenu = class(TThemeBasic)
    Button1: TThemeButton;
    Button2: TThemeButton;
    Button3: TThemeButton;
    Button4: TThemeButton;
    Button5: TThemeButton;
    Button6: TThemeButton;
    SelectSlide1: TThemeSelectSlide;
    SelectSlide2: TThemeSelectSlide;
    SelectSlide3: TThemeSelectSlide;
    TextMenu: TThemeText;
  end;

  //Party Screens
  TThemePartyNewRound = class(TThemeBasic)
    TextRound1:        TThemeText;
    TextRound2:        TThemeText;
    TextRound3:        TThemeText;
    TextRound4:        TThemeText;
    TextRound5:        TThemeText;
    TextRound6:        TThemeText;
    TextRound7:        TThemeText;
    TextWinner1:       TThemeText;
    TextWinner2:       TThemeText;
    TextWinner3:       TThemeText;
    TextWinner4:       TThemeText;
    TextWinner5:       TThemeText;
    TextWinner6:       TThemeText;
    TextWinner7:       TThemeText;
    TextNextRound:     TThemeText;
    TextNextRoundNo:   TThemeText;
    TextNextPlayer1:   TThemeText;
    TextNextPlayer2:   TThemeText;
    TextNextPlayer3:   TThemeText;

    StaticRound1:      TThemeStatic;
    StaticRound2:      TThemeStatic;
    StaticRound3:      TThemeStatic;
    StaticRound4:      TThemeStatic;
    StaticRound5:      TThemeStatic;
    StaticRound6:      TThemeStatic;
    StaticRound7:      TThemeStatic;

    TextScoreTeam1:    TThemeText;
    TextScoreTeam2:    TThemeText;
    TextScoreTeam3:    TThemeText;
    TextNameTeam1:     TThemeText;
    TextNameTeam2:     TThemeText;
    TextNameTeam3:     TThemeText;
    TextTeam1Players:  TThemeText;
    TextTeam2Players:  TThemeText;
    TextTeam3Players:  TThemeText;

    StaticTeam1:       TThemeStatic;
    StaticTeam2:       TThemeStatic;
    StaticTeam3:       TThemeStatic;
    StaticNextPlayer1: TThemeStatic;
    StaticNextPlayer2: TThemeStatic;
    StaticNextPlayer3: TThemeStatic;
  end;

  TThemePartyScore = class(TThemeBasic)
    TextScoreTeam1:    TThemeText;
    TextScoreTeam2:    TThemeText;
    TextScoreTeam3:    TThemeText;
    TextNameTeam1:     TThemeText;
    TextNameTeam2:     TThemeText;
    TextNameTeam3:     TThemeText;
    StaticTeam1:       TThemeStatic;
    StaticTeam1BG:     TThemeStatic;
    StaticTeam1Deco:   TThemeStatic;
    StaticTeam2:       TThemeStatic;
    StaticTeam2BG:     TThemeStatic;
    StaticTeam2Deco:   TThemeStatic;
    StaticTeam3:       TThemeStatic;
    StaticTeam3BG:     TThemeStatic;
    StaticTeam3Deco:   TThemeStatic;

    DecoTextures:      record
      ChangeTextures:  boolean;

      FirstTexture:    string;
      FirstTyp:        TTextureType;
      FirstColor:      string;

      SecondTexture:   string;
      SecondTyp:       TTextureType;
      SecondColor:     string;

      ThirdTexture:    string;
      ThirdTyp:        TTextureType;
      ThirdColor:      string;
    end;


    TextWinner:        TThemeText;
  end;

  TThemePartyWin = class(TThemeBasic)
    TextScoreTeam1:    TThemeText;
    TextScoreTeam2:    TThemeText;
    TextScoreTeam3:    TThemeText;
    TextNameTeam1:     TThemeText;
    TextNameTeam2:     TThemeText;
    TextNameTeam3:     TThemeText;
    StaticTeam1:       TThemeStatic;
    StaticTeam1BG:     TThemeStatic;
    StaticTeam1Deco:   TThemeStatic;
    StaticTeam2:       TThemeStatic;
    StaticTeam2BG:     TThemeStatic;
    StaticTeam2Deco:   TThemeStatic;
    StaticTeam3:       TThemeStatic;
    StaticTeam3BG:     TThemeStatic;
    StaticTeam3Deco:   TThemeStatic;

    TextWinner:        TThemeText;
  end;

  TThemePartyOptions = class(TThemeBasic)
    SelectMode:  TThemeSelectSlide;
    SelectLevel: TThemeSelectSlide;
    SelectPlayList: TThemeSelectSlide;
    SelectPlayListItems: TThemeSelectSlide;

    {ButtonNext: TThemeButton;
    ButtonPrev: TThemeButton;}
  end;

  TThemePartyPlayer = class(TThemeBasic)
    SelectTeams: TThemeSelectSlide;
    SelectPlayers1: TThemeSelectSlide;
    SelectPlayers2: TThemeSelectSlide;
    SelectPlayers3: TThemeSelectSlide;

    Team1Name: TThemeButton;
    Player1Name: TThemeButton;
    Player2Name: TThemeButton;
    Player3Name: TThemeButton;
    Player4Name: TThemeButton;

    Team2Name: TThemeButton;
    Player5Name: TThemeButton;
    Player6Name: TThemeButton;
    Player7Name: TThemeButton;
    Player8Name: TThemeButton;

    Team3Name: TThemeButton;
    Player9Name: TThemeButton;
    Player10Name: TThemeButton;
    Player11Name: TThemeButton;
    Player12Name: TThemeButton;

    {ButtonNext: TThemeButton;
    ButtonPrev: TThemeButton;}
  end;

  TThemePartyRounds = class(TThemeBasic)
    SelectRoundCount: TThemeSelectSlide;
    SelectRound: array [0..6] of TThemeSelectSlide;
  end;

  TThemePartyTournamentPlayer = class(TThemeBasic)
    SelectPlayers: TThemeSelectSlide;

    Player1Name: TThemeButton;
    Player2Name: TThemeButton;
    Player3Name: TThemeButton;
    Player4Name: TThemeButton;
    Player5Name: TThemeButton;
    Player6Name: TThemeButton;
    Player7Name: TThemeButton;
    Player8Name: TThemeButton;
    Player9Name: TThemeButton;
    Player10Name: TThemeButton;
    Player11Name: TThemeButton;
    Player12Name: TThemeButton;
    Player13Name: TThemeButton;
    Player14Name: TThemeButton;
    Player15Name: TThemeButton;
    Player16Name: TThemeButton;
  end;

  TThemePartyTournamentOptions = class(TThemeBasic)
    SelectRoundsFinal:  TThemeSelectSlide;
    SelectRounds2Final: TThemeSelectSlide;
    SelectRounds4Final: TThemeSelectSlide;
    SelectRounds8Final: TThemeSelectSlide;
  end;

  TThemePartyTournamentRounds = class(TThemeBasic)
    TextNamePlayer: array[0..1, 0..7] of TThemeButton;
    TextWinner: TThemeText;
    TextResult: TThemeText;
    NextPlayers: TThemeText;
  end;

  TThemePartyTournamentWin = class(TThemeBasic)
    TextScorePlayer1:    TThemeText;
    TextScorePlayer2:    TThemeText;
    TextNamePlayer1:     TThemeText;
    TextNamePlayer2:     TThemeText;
    StaticBGPlayer1:     TThemeStatic;
    StaticBGPlayer2:     TThemeStatic;
  end;

  //About
  TThemeAboutMain = class(TThemeBasic)
  	StaticBghelper:	  TThemeStatic;
    ButtonDevelopers: TThemeButton;
    ButtonExit:       TThemeButton;
    TextOverview:     TThemeText;
  end;

  //Developers
  TThemeDevelopers = class(TThemeBasic)
    ButtonExit:       TThemeButton;

    TextOverview:     TThemeText;
  end;

  //Stats Screens
  TThemeStatMain = class(TThemeBasic)
    ButtonScores:     TThemeButton;
    ButtonSingers:    TThemeButton;
    ButtonSongs:      TThemeButton;
    ButtonBands:      TThemeButton;
    ButtonExit:       TThemeButton;

    TextOverview:     TThemeText;
  end;

  TThemeStatDetail = class(TThemeBasic)
    ButtonNext:       TThemeButton;
    ButtonPrev:       TThemeButton;
    ButtonReverse:    TThemeButton;
    ButtonExit:       TThemeButton;

    TextDescription:  TThemeText;
    TextPage:         TThemeText;
    TextList:         AThemeText;

    Description:      array[0..3] of UTF8String;
    DescriptionR:     array[0..3] of UTF8String;
    FormatStr:        array[0..3] of UTF8String;
    PageStr:          UTF8String;
  end;

  TThemeEntry = record
    Name: string;
    Filename: IPath;
    DefaultSkin: UTF8String;
    Skins: array of UTF8String;
  end;

  TInheritance = record
    Section: string;
    Base: boolean;
  end;

  TTheme = class
  private
    Inheritance: array of TInheritance;
    ThemeBase: TMemIniFile;
    ThemeIni: TMemIniFile;
    LastThemeBasic:   TThemeBasic;
    procedure CreateThemeObjects();
    function SectionExists(const Section: string): boolean;
    procedure SetInheritance(const Section: string);
    procedure ReadProperty(const Section: string; const Identifier: string; const Default: integer; var Field: integer);
    procedure ReadProperty(const Section: string; const Identifier: string; const Default: real; var Field: real);
    procedure ReadProperty(const Section: string; const Identifier: string; const Default: boolean; var Field: boolean);
    procedure ReadProperty(const Section: string; const Identifier: string; const Default: string; var Field: string);
    procedure ReadProperty(const Section: string; const Identifier: string; const Default: UTF8String; var Field: UTF8String; const FieldType: integer = 0);
  public
    Themes:           array of TThemeEntry;
    Loading:          TThemeLoading;
    Main:             TThemeMain;
    PlayerSelector:             TThemePlayerSelector;
    Song:             TThemeSong;
    Sing:             TThemeSing;
    LyricBar:         TThemeLyricBar;
    LyricBarDuetP1:   TThemeLyricBar;
    LyricBarDuetP2:   TThemeLyricBar;
    LyricBarJukebox:  TThemeLyricBar;
    Jukebox:          TThemeJukebox;
    JukeboxPlaylist:  TThemeJukeboxPlaylist;
    Score:            TThemeScore;
    Top5:             TThemeTop5;
    Options:          TThemeOptions;
    OptionsGame:      TThemeOptionsGame;
    OptionsGraphics:  TThemeOptionsGraphics;
    OptionsSound:     TThemeOptionsSound;
    OptionsLyrics:    TThemeOptionsLyrics;
    OptionsThemes:    TThemeOptionsThemes;
    OptionsMicrophones:    TThemeOptionsMicrophones;
    OptionsAdvanced:  TThemeOptionsAdvanced;
    OptionsNetwork:   TThemeOptionsNetwork;
    OptionsWebcam:    TThemeOptionsWebcam;
	OptionsProfiles:  TThemeOptionsProfiles;
    //error and check popup
    ErrorPopup:         TThemeError;
    CheckPopup:         TThemeCheck;
    InsertUserPopup:    TThemeInsertUser;
    SendScorePopup:     TThemeSendScore;
    ScoreDownloadPopup: TThemeScoreDownload;
    //ScreenSong extensions
    SongMenu:         TThemeSongMenu;
    //Party Screens:
    PartyNewRound:    TThemePartyNewRound;
    PartyScore:       TThemePartyScore;
    PartyWin:         TThemePartyWin;
    PartyOptions:     TThemePartyOptions;
    PartyPlayer:      TThemePartyPlayer;
    PartyRounds:      TThemePartyRounds;

    //Tournament
    PartyTournamentPlayer: TThemePartyTournamentPlayer;
    PartyTournamentOptions: TThemePartyTournamentOptions;
    PartyTournamentRounds: TThemePartyTournamentRounds;
    PartyTournamentWin: TThemePartyTournamentWin;

    // About
    AboutMain:        TThemeAboutMain;
	Developers:       TThemeDevelopers;

    //Stats Screens:
    StatMain:         TThemeStatMain;
    StatDetail:       TThemeStatDetail;

    ILevel: array[0..2] of UTF8String;
    IMode:  array[0..2] of UTF8String;

    constructor Create();

    procedure LoadList;

    function LoadTheme(ThemeNum: integer; sColor: integer): boolean; // Load some theme settings from file

    procedure LoadColors;

    procedure ThemeLoadBasic(Theme: TThemeBasic; const Name: string);
    procedure ThemeLoadBackground(var ThemeBackground: TThemeBackground; const Name: string);
    procedure ThemeLoadText(var ThemeText: TThemeText; const Name: string);
    procedure ThemeLoadTexts(var ThemeText: AThemeText; const Name: string);
    procedure ThemeLoadStatic(var ThemeStatic: TThemeStatic; const Name: string);
    procedure ThemeLoadStatics(var ThemeStatic: AThemeStatic; const Name: string);
    procedure ThemeLoadButton(var ThemeButton: TThemeButton; const Name: string; Collections: PAThemeButtonCollection = nil);
    procedure ThemeLoadButtonCollection(var Collection: TThemeButtonCollection; const Name: string);
    procedure ThemeLoadButtonCollections(var Collections: AThemeButtonCollection; const Name: string);
    procedure ThemeLoadSelectSlide(var ThemeSelectS: TThemeSelectSlide; const Name: string);
    procedure ThemeLoadEqualizer(var ThemeEqualizer: TThemeEqualizer; const Name: string);
    procedure ThemeLoadLyricBar(var ThemeLyricBar: TThemeLyricBar; Name: string);
    procedure ThemeLoadPosition(var ThemePosition: TThemePosition; const Name: string);
    procedure ThemeScoreLoad;
    procedure ThemePartyLoad;
    procedure ThemeSongLoad;
  end;

  TColor = record
    Name:   string;
    RGB:    TRGB;
  end;

procedure glColorRGB(Color: TRGB);  overload;
procedure glColorRGB(Color: TRGB; Alpha: real);  overload;
procedure glColorRGB(Color: TRGBA); overload;
procedure glColorRGB(Color: TRGBA; Alpha: real); overload;

function ColorExists(Name: string): integer;
procedure LoadColor(var R, G, B: real; ColorName: string);
function GetSystemColor(Color: integer): TRGB;
function ColorSqrt(RGB: TRGB): TRGB;

function GetLyricColor(Color: integer): TRGB;
function GetLyricBarColor(Color: integer): TRGB;

function GetPlayerColor(Color: integer): TRGB;
function GetPlayerLightColor(Color: integer): TRGB;
procedure LoadPlayersColors;
procedure LoadTeamsColors;

var
  //Skin:         TSkin;
  Theme:        TTheme;
  Color:        array of TColor;
  LastC:        integer;

implementation

uses
  ULanguage,
  UPathUtils,
  UFileSystem,
  TextGL,
  dglOpenGL,
  math,
  StrUtils,
  UUnicodeUtils;

//-----------
//Helper procs to use TRGB in Opengl ...maybe this should be somewhere else
//-----------
procedure glColorRGB(Color: TRGB);  overload;
begin
  glColor3f(Color.R, Color.G, Color.B);
end;

procedure glColorRGB(Color: TRGB; Alpha: real);  overload;
begin
  glColor4f(Color.R, Color.G, Color.B, Alpha);
end;

procedure glColorRGB(Color: TRGBA); overload;
begin
  glColor4f(Color.R, Color.G, Color.B, Color.A);
end;

procedure glColorRGB(Color: TRGBA; Alpha: real); overload;
begin
  glColor4f(Color.R, Color.G, Color.B, Min(Color.A, Alpha));
end;

constructor TTheme.Create();
begin
  inherited Create();
  LoadList;
end;

procedure TTheme.LoadList;
var
  Iter: IFileIterator;
  FileInfo: TFileInfo;
  Entry: TThemeEntry;
  Ini: TMemIniFile;
  DefaultSkin: UTF8String;
  I, Len: integer;
begin
  Log.LogStatus('Searching for ini file themes in '+ThemePath.ToNative(), 'Theme.LoadList');
  Iter := UFileSystem.FileSystem.FileFind(ThemePath.Append('*.ini'), 0);
  while Iter.HasNext() do
  begin
    FileInfo := Iter.Next();
    Entry.Name := FileInfo.Name.SetExtension('').ToNative();
    Entry.Filename := ThemePath.Append(FileInfo.Name);
    Ini := TMemIniFile.Create(Entry.Filename.ToNative());
    DefaultSkin := Ini.ReadString('Theme', 'DefaultSkin', '');
    Entry.DefaultSkin := '';
    Len := 0;
    for I := 0 to High(USkins.Skin.Skin) do
      if CompareText(Entry.Name, USkins.Skin.Skin[I].Theme) = 0 then
      begin
        if DefaultSkin = USkins.Skin.Skin[I].Name then
          Entry.DefaultSkin := DefaultSkin;

        SetLength(Entry.Skins, Len + 1);
        Entry.Skins[Len] := USkins.Skin.Skin[I].Name;
        Inc(Len);
      end;

    if Entry.DefaultSkin = '' then
      Log.CriticalError('Could not find the default skin '+DefaultSkin+' of theme '+Entry.Name)
    else if Ini.ReadFloat('Theme', 'Version', 0) < ThemeMinVersion then
      Log.CriticalError('The theme '+Entry.Name+' must be updated to be compatible with the '+FormatFloat('00.00', ThemeMinVersion)+' version themes style')
    else
    begin
      Log.LogStatus('Found theme '+Entry.Name, 'Theme.LoadList');
      if Entry.Name = DefaultTheme then
        Self.ThemeBase := TMemIniFile.Create(Entry.Filename.ToNative());

      Len := Length(Themes);
      SetLength(Themes, Len + 1);
      SetLength(ITheme, Len + 1);
      Themes[Len] := Entry;
      ITheme[Len] := Entry.Name;
    end;
    Ini.Free();
  end;
  if not Assigned(Self.ThemeBase) then
    Log.CriticalError('Could not find the default theme '+DefaultTheme);
end;

{ Check if a section exist in current theme or in base theme }
function TTheme.SectionExists(const Section: string): boolean;
begin
  Result := Self.ThemeIni.SectionExists(Section) or Self.ThemeBase.SectionExists(Section);
end;

{ Try to search a section inheritance in current theme or, if don't exists, in the base theme }
procedure TTheme.SetInheritance(const Section: string);
var
  I: integer;
  CurrentInheritance: string;
begin
  I := 1;
  SetLength(Self.Inheritance, 1);
  Self.Inheritance[0].Section := Section;
  Self.Inheritance[0].Base := not Self.ThemeIni.SectionExists(Section);
  CurrentInheritance := Section;
  repeat
    CurrentInheritance := IfThen(
      Self.Inheritance[I - 1].Base,
      Self.ThemeBase.ReadString(CurrentInheritance, 'Inheritance', ''),
      Self.ThemeIni.ReadString(CurrentInheritance, 'Inheritance', '')
    );
    if CurrentInheritance <> '' then
    begin
      SetLength(Self.Inheritance, I + 1);
      Self.Inheritance[I].Section := CurrentInheritance;
      Self.Inheritance[I].Base := not Self.ThemeIni.SectionExists(CurrentInheritance);
      Inc(I);
    end;
  until (CurrentInheritance = '') or (I > 50);
  if I > 50 then
    Log.CriticalError('Inheritance loop error in section '+Section+' of current theme');
end;

{ Integer type overload of ReadProperty }
procedure TTheme.ReadProperty(const Section: string; const Identifier: string; const Default: integer; var Field: integer);
var
  TempString: UTF8String;
begin
  Self.ReadProperty(Section, Identifier, UTF8String(IntToStr(Default)), TempString, 1);
  Field := StrToInt(TempString);
end;

{ Real type overload of ReadProperty }
procedure TTheme.ReadProperty(const Section: string; const Identifier: string; const Default: real; var Field: real);
var
  TempString: UTF8String;
begin
  Self.ReadProperty(Section, Identifier, UTF8String(FloatToStr(Default)), TempString, 2);
  Field := StrToFloat(TempString);
end;

{ Boolean type overload of ReadProperty }
procedure TTheme.ReadProperty(const Section: string; const Identifier: string; const Default: boolean; var Field: boolean);
var
  TempString: UTF8String;
begin
  Self.ReadProperty(Section, Identifier, UTF8String(BoolToStr(Default)), TempString, 3);
  Field := StrtoBool(TempString);
end;

{ String overload of ReadProperty }
procedure TTheme.ReadProperty(const Section: string; const Identifier: string; const Default: string; var Field: string);
var
  TempString: UTF8String;
begin
  Self.ReadProperty(Section, Identifier, Default, TempString);
  Field := TempString;
end;

{ Read a property from a section of a ini file using inheritance. It's mandatory call SetInheritance before read anything }
procedure TTheme.ReadProperty(const Section: string; const Identifier: string; const Default: UTF8String; var Field: UTF8String; const FieldType: integer = 0);
var
  ExitValue: UTF8String;
  I, MaxDeep, RealFieldType: integer;
begin
  MaxDeep := High(Self.Inheritance);
  I := 0;
  repeat
    RealFieldType := IfThen(Self.Inheritance[I].Base, FieldType, FieldType + 4);
    ExitValue := '-9999';
    case RealFieldType of
      0: Field := Self.ThemeBase.ReadString(Self.Inheritance[I].Section, Identifier, ExitValue);
      1: Field := IntToStr(Self.ThemeBase.ReadInteger(Self.Inheritance[I].Section, Identifier, StrToInt(ExitValue)));
      2: Field := FloatToStr(Self.ThemeBase.ReadFloat(Self.Inheritance[I].Section, Identifier, StrToFloat(ExitValue)));
      3:
        begin
          Field := BoolToStr(Self.ThemeBase.ReadBool(Self.Inheritance[I].Section, Identifier, StrtoBool(Default)));
          ExitValue := IfThen(Self.ThemeBase.ValueExists(Self.Inheritance[I].Section, Identifier), BoolToStr(not StrtoBool(Field)), Field);
        end;
      4: Field := Self.ThemeIni.ReadString(Self.Inheritance[I].Section, Identifier, ExitValue);
      5: Field := IntToStr(Self.ThemeIni.ReadInteger(Self.Inheritance[I].Section, Identifier, StrToInt(ExitValue)));
      6: Field := FloatToStr(Self.ThemeIni.ReadFloat(Self.Inheritance[I].Section, Identifier, StrToFloat(ExitValue)));
      7:
        begin
          Field := BoolToStr(Self.ThemeIni.ReadBool(Self.Inheritance[I].Section, Identifier, StrtoBool(Default)));
          ExitValue := IfThen(Self.ThemeIni.ValueExists(Self.Inheritance[I].Section, Identifier), BoolToStr(not StrtoBool(Field)), Field);
        end;
    end;
    Inc(I);
  until (Field <> ExitValue) or (I > MaxDeep);
  if Field = ExitValue then //to fix inheritance with value 0 and default 0 in a int or float field type
    Field := IfThen((Default = '') and (RealFieldType in [1, 2, 5, 6]), '0', Default);
end;

function TTheme.LoadTheme(ThemeNum: integer; sColor: integer): boolean;
var
  I, J:    integer;
begin
  Result := false;

  CreateThemeObjects();

  Log.LogStatus('Loading: '+ Themes[ThemeNum].FileName.ToNative, 'TTheme.LoadTheme');

  if not Themes[ThemeNum].FileName.IsFile() then
  begin
    Log.LogError('Theme does not exist ('+ Themes[ThemeNum].FileName.ToNative +')', 'TTheme.LoadTheme');
  end;

  if Themes[ThemeNum].FileName.IsFile() then
  begin
    Result := true;
    Self.ThemeIni := TMemIniFile.Create(Self.Themes[ThemeNum].FileName.ToNative());
    begin //deleted previous if asking for theme name because don't have sense now
      Skin.Color := sColor;
      Skin.LoadSkin();

      LoadColors;


      // Loading
      ThemeLoadBasic(Loading, 'Loading');

      // Main
      ThemeLoadBasic(Main, 'Main');

      ThemeLoadText(Main.TextDescriptionLong, 'MainTextDescriptionLong');
      ThemeLoadText(Main.ProgressSongsText, 'MainProgressSongsText');
      ThemeLoadButton(Main.ButtonSolo, 'MainButtonSolo');
      ThemeLoadButton(Main.ButtonMulti, 'MainButtonMulti');
      ThemeLoadButton(Main.ButtonJukebox, 'MainButtonJukebox');
      ThemeLoadButton(Main.ButtonStat, 'MainButtonStats');
      ThemeLoadButton(Main.ButtonOptions, 'MainButtonOptions');
      ThemeLoadButton(Main.ButtonExit, 'MainButtonExit');
      ThemeLoadButton(Main.ButtonAbout, 'MainButtonAbout');

      //Main Desc Text Translation Start

      Main.Description[0] := Language.Translate('SING_SING');
      Main.DescriptionLong[0] := Language.Translate('SING_SING_DESC');
      Main.Description[1] := Language.Translate('SING_MULTI');
      Main.DescriptionLong[1] := Language.Translate('SING_MULTI_DESC');
      Main.Description[2] := Language.Translate('SING_JUKEBOX');
      Main.DescriptionLong[2] := Language.Translate('SING_JUKEBOX_DESC');
      Main.Description[3] := Language.Translate('SING_STATS');
      Main.DescriptionLong[3] := Language.Translate('SING_STATS_DESC');
      Main.Description[4] := Language.Translate('SING_GAME_OPTIONS');
      Main.DescriptionLong[4] := Language.Translate('SING_GAME_OPTIONS_DESC');
      Main.Description[5] := Language.Translate('SING_EXIT');
      Main.DescriptionLong[5] := Language.Translate('SING_EXIT_DESC');
      Main.Description[6] := Language.Translate('SING_ABOUT');
      Main.DescriptionLong[6] := Language.Translate('SING_ABOUT_DESC');

      //Main Desc Text Translation End

      Main.TextDescription.Text := Main.Description[0];
      Main.TextDescriptionLong.Text := Main.DescriptionLong[0];

      // Name
      ThemeLoadBasic(PlayerSelector, 'Name');

      ThemeLoadButton(PlayerSelector.PlayerButtonName, 'NamePlayerButtonName');
      ThemeLoadButton(PlayerSelector.PlayerButtonAvatar, 'NamePlayerButtonAvatar');

      Self.SetInheritance('NamePlayerScrollAvatar');
      Self.ReadProperty('NamePlayerScrollAvatar', 'Count', 5, PlayerSelector.PlayerScrollAvatar.NumAvatars);
      Self.ReadProperty('NamePlayerScrollAvatar', 'Distance', 40, PlayerSelector.PlayerScrollAvatar.DistanceAvatars);

      ThemeLoadButton(PlayerSelector.PlayerAvatar, 'NamePlayerAvatar');
      Self.ThemeLoadButton(Self.PlayerSelector.SingButton, 'NamePlayerSingButton');
      Self.ThemeLoadButton(Self.PlayerSelector.ExitButton, 'NamePlayerExitButton');

      ThemeLoadSelectSlide(PlayerSelector.SelectPlayersCount, 'NameSelectPlayerCount');
      ThemeLoadSelectSlide(PlayerSelector.SelectPlayerColor, 'NameSelectPlayerColor');
      ThemeLoadSelectSlide(PlayerSelector.SelectPlayerLevel, 'NameSelectPlayerLevel');

      for I := 0 to UIni.IMaxPlayerCount-1 do
      begin
        ThemeLoadStatic(PlayerSelector.PlayerSelect[I], 'NamePlayerSelectStatic' + IntToStr((I + 1)));
        ThemeLoadText(PlayerSelector.PlayerSelectText[I], 'NamePlayerSelectStatic' + IntToStr((I + 1)) + 'Text');
        ThemeLoadStatic(PlayerSelector.PlayerSelectAvatar[I], 'NamePlayerSelectStatic' + IntToStr((I + 1)) + 'Avatar');
      end;

      ThemeLoadButton(PlayerSelector.PlayerSelectCurrent, 'NamePlayerSelectCurrent');

      //Song
      ThemeSongLoad();

      //LyricBar
      Self.ThemeLoadLyricBar(LyricBar, 'SingLyricsUpperBar');
      Self.ThemeLoadLyricBar(LyricBarDuetP1, 'SingLyricsDuetP1UpperBar');
      Self.ThemeLoadLyricBar(LyricBarDuetP2, 'SingLyricsDuetP2UpperBar');
      Self.ThemeLoadLyricBar(LyricBarJukebox, 'JukeboxLyricsUpperBar');

      // Jukebox
      // ThemeLoadStatic(Jukebox.StaticTimeProgress, 'JukeboxTimeProgress');
      // ThemeLoadStatic(Jukebox.StaticTimeBackground, 'JukeboxTimeBackground');
      // ThemeLoadStatic(Jukebox.StaticSongBackground, 'JukeboxSongBackground');
      ThemeLoadStatic(Jukebox.StaticSongListBackground, 'JukeboxSongListBackground');
      //ThemeLoadText(Jukebox.TextTimeText, 'JukeboxTimeText');
      //ThemeLoadText(Jukebox.TextTimeDesc, 'JukeboxTimeDesc');
      //ThemeLoadText(Jukebox.TextSongText, 'JukeboxTextSong');
      ThemeLoadButton(Jukebox.SongDescription, 'JukeboxSongDescription');
      ThemeLoadButton(Jukebox.FindSong, 'JukeboxFind');
      ThemeLoadButton(Jukebox.RepeatSongList, 'JukeboxRepeat');
      ThemeLoadButton(Jukebox.SongListPlayPause, 'JukeboxPlayPause');
      ThemeLoadButton(Jukebox.SongListOrder, 'JukeboxSort');
      ThemeLoadButton(Jukebox.RandomSongList, 'JukeboxRandom');
      ThemeLoadButton(Jukebox.Lyric, 'JukeboxLyric');
      ThemeLoadButton(Jukebox.SongListClose, 'JukeboxSongListClose');
      ThemeLoadButton(Jukebox.Options, 'JukeboxOptions');
      ThemeLoadText(Jukebox.TextListText, 'JukeboxListText');
      ThemeLoadText(Jukebox.TextCountText, 'JukeboxCountText');
      ThemeLoadStatic(Jukebox.SongCover, 'JukeboxSongCover');

      ThemeLoadStatics(Jukebox.StaticActualSongStatics, 'JukeboxStaticActualSong');
      ThemeLoadStatic(Jukebox.StaticActualSongCover, 'JukeboxStaticActualSongCover');
      ThemeLoadText(Jukebox.TextActualSongArtist, 'JukeboxTextActualSongArtist');
      ThemeLoadText(Jukebox.TextActualSongTitle, 'JukeboxTextActualSongTitle');

      ThemeLoadButton(Jukebox.SongListUp, 'JukeboxSongListUp');
      ThemeLoadButton(Jukebox.SongListDown, 'JukeboxSongListDown');

      // Jukebox SongMenu
      ThemeLoadStatic(Jukebox.StaticSongMenuTimeProgress, 'JukeboxSongMenuTimeProgress');
      ThemeLoadStatic(Jukebox.StaticSongMenuTimeBackground, 'JukeboxSongMenuTimeBackground');
      ThemeLoadText(Jukebox.SongMenuTextTime, 'JukeboxSongMenuTextTime');

      ThemeLoadStatic(Jukebox.StaticSongMenuBackground, 'JukeboxSongMenuBackground');
      ThemeLoadButton(Jukebox.SongMenuPlayPause, 'JukeboxSongMenuPlayPause');

      ThemeLoadButton(Jukebox.SongMenuNext, 'JukeboxSongMenuNext');
      ThemeLoadButton(Jukebox.SongMenuPrevious, 'JukeboxSongMenuPrevious');
      ThemeLoadButton(Jukebox.SongMenuPlaylist, 'JukeboxSongMenuPlaylist');
      ThemeLoadButton(Jukebox.SongMenuOptions, 'JukeboxSongMenuOptions');

      // Jukebox SongOptions
      ThemeLoadStatic(Jukebox.StaticSongOptionsBackground, 'JukeboxSongOptionsBackground');
      ThemeLoadButton(Jukebox.SongOptionsClose, 'JukeboxSongOptionsClose');
      ThemeLoadButton(Jukebox.SongListFixPin, 'JukeboxSongListFixPin');
      ThemeLoadText(Jukebox.SongOptionsLyricText, 'JukeboxSongOptionsLyricText');
      ThemeLoadSelectSlide(Jukebox.SongOptionsLyricPositionSlide, 'JukeboxSongOptionsLyricPositionSlide');
      ThemeLoadSelectSlide(Jukebox.SongOptionsLyricFontSlide, 'JukeboxSongOptionsLyricFontSlide');
      ThemeLoadSelectSlide(Jukebox.SongOptionsLyricEffectSlide, 'JukeboxSongOptionsLyricEffectSlide');
      ThemeLoadSelectSlide(Jukebox.SongOptionsLyricAlphaSlide, 'JukeboxSongOptionsLyricAlphaSlide');
      ThemeLoadSelectSlide(Jukebox.SongOptionsLyricColorSlide, 'JukeboxSongOptionsLyricColorSlide');
      ThemeLoadSelectSlide(Jukebox.SongOptionsLyricLineSlide, 'JukeboxSongOptionsLyricLineSlide');
      ThemeLoadSelectSlide(Jukebox.SongOptionsLyricPropertySlide, 'JukeboxSongOptionsLyricPropertySlide');
      ThemeLoadSelectSlide(Jukebox.SelectR,    'JukeboxSongOptionsLyricSelectR');
      ThemeLoadSelectSlide(Jukebox.SelectG,    'JukeboxSongOptionsLyricSelectG');
      ThemeLoadSelectSlide(Jukebox.SelectB,    'JukeboxSongOptionsLyricSelectB');
      ThemeLoadStatic(Jukebox.PointerR,        'JukeboxSongOptionsLyricPointerR');
      ThemeLoadStatic(Jukebox.PointerG,        'JukeboxSongOptionsLyricPointerG');
      ThemeLoadStatic(Jukebox.PointerB,        'JukeboxSongOptionsLyricPointerB');

      // JukeboxPlaylist
      ThemeLoadBasic(JukeboxPlaylist, 'JukeboxPlaylist');
      ThemeLoadSelectSlide(JukeboxPlaylist.SelectPlayList, 'JukeboxPlaylistSelectPlayList');
      ThemeLoadSelectSlide(JukeboxPlaylist.SelectPlayListItems, 'JukeboxPlaylistSelectPlayListItems');

      // Sing
      ThemeLoadBasic(Sing, 'Sing');

      ThemeLoadStatics (Sing.StaticDuet, 'SingStaticDuet');

      //TimeBar mod
       ThemeLoadStatic(Sing.StaticTimeProgress, 'SingTimeProgress');
       ThemeLoadText(Sing.TextTimeText, 'SingTimeText');
      //eoa TimeBar mod

      ThemeLoadText (Sing.InfoMessageText, 'SingInfoMessageText');
      ThemeLoadStatic (Sing.InfoMessageBG, 'SingInfoMessageBG');

    //moveable singbar mod
      ThemeLoadStatic(Sing.StaticP1SingBar, 'SingP1SingBar');
      ThemeLoadStatic(Sing.StaticP1TwoPSingBar, 'SingP1TwoPSingBar');
      ThemeLoadStatic(Sing.StaticP1ThreePSingBar, 'SingP1ThreePSingBar');
      ThemeLoadStatic(Sing.StaticP2RSingBar, 'SingP2RSingBar');
      ThemeLoadStatic(Sing.StaticP2MSingBar, 'SingP2MSingBar');
      ThemeLoadStatic(Sing.StaticP3SingBar, 'SingP3SingBar');
    //eoa moveable singbar

      ThemeLoadStatic(Sing.StaticP1, 'SingP1Static');
      ThemeLoadText(Sing.TextP1, 'SingP1Text');
      ThemeLoadStatic(Sing.StaticP1ScoreBG, 'SingP1Static2');
      ThemeLoadText(Sing.TextP1Score, 'SingP1TextScore');
      ThemeLoadStatic(Sing.StaticP1Avatar, 'SingP1Avatar');

  //This one is shown in 2/4P mode
        ThemeLoadStatic(Sing.StaticP1TwoP, 'SingP1TwoPStatic');
        ThemeLoadStatic(Sing.StaticP1TwoPAvatar, 'SingP1TwoPAvatar');
        ThemeLoadText(Sing.TextP1TwoP, 'SingP1TwoPText');
        ThemeLoadStatic(Sing.StaticP1TwoPScoreBG, 'SingP1TwoPStatic2');
        ThemeLoadText(Sing.TextP1TwoPScore, 'SingP1TwoPTextScore');

  //This one is shown in 3/6P mode
        ThemeLoadStatic(Sing.StaticP1ThreeP, 'SingP1ThreePStatic');
        ThemeLoadStatic(Sing.StaticP1ThreePAvatar, 'SingP1ThreePAvatar');
        ThemeLoadText(Sing.TextP1ThreeP, 'SingP1ThreePText');
        ThemeLoadStatic(Sing.StaticP1ThreePScoreBG, 'SingP1ThreePStatic2');
        ThemeLoadText(Sing.TextP1ThreePScore, 'SingP1ThreePTextScore');

      ThemeLoadStatic(Sing.StaticP2R, 'SingP2RStatic');
      ThemeLoadText(Sing.TextP2R, 'SingP2RText');
      ThemeLoadStatic(Sing.StaticP2RScoreBG, 'SingP2RStatic2');
      ThemeLoadText(Sing.TextP2RScore, 'SingP2RTextScore');
      ThemeLoadStatic(Sing.StaticP2RAvatar, 'SingP2RAvatar');

      ThemeLoadStatic(Sing.StaticP2M, 'SingP2MStatic');
      ThemeLoadText(Sing.TextP2M, 'SingP2MText');
      ThemeLoadStatic(Sing.StaticP2MScoreBG, 'SingP2MStatic2');
      ThemeLoadText(Sing.TextP2MScore, 'SingP2MTextScore');
      ThemeLoadStatic(Sing.StaticP2MAvatar, 'SingP2MAvatar');

      ThemeLoadStatic(Sing.StaticP3R, 'SingP3RStatic');
      ThemeLoadText(Sing.TextP3R, 'SingP3RText');
      ThemeLoadStatic(Sing.StaticP3RScoreBG, 'SingP3RStatic2');
      ThemeLoadText(Sing.TextP3RScore, 'SingP3RTextScore');
      ThemeLoadStatic(Sing.StaticP3RAvatar, 'SingP3RAvatar');

      ThemeLoadStatic(Sing.StaticSongName, 'SingSongNameStatic');
      ThemeLoadText(Sing.TextSongName, 'SingSongNameText');

      // 3/6 players duet
      ThemeLoadStatic(Sing.StaticDuetP1ThreeP, 'SingDuetP1ThreePStatic');
      ThemeLoadText(Sing.TextDuetP1ThreeP, 'SingDuetP1ThreePText');
      ThemeLoadStatic(Sing.StaticDuetP1ThreePScoreBG, 'SingDuetP1ThreePStatic2');
      ThemeLoadText(Sing.TextDuetP1ThreePScore, 'SingDuetP1ThreePTextScore');
      ThemeLoadStatic(Sing.StaticDuetP1ThreePAvatar, 'SingDuetP1ThreePAvatar');

      ThemeLoadStatic(Sing.StaticDuetP2M, 'SingDuetP2MStatic');
      ThemeLoadText(Sing.TextDuetP2M, 'SingDuetP2MText');
      ThemeLoadStatic(Sing.StaticDuetP2MScoreBG, 'SingDuetP2MStatic2');
      ThemeLoadText(Sing.TextDuetP2MScore, 'SingDuetP2MTextScore');
      ThemeLoadStatic(Sing.StaticDuetP2MAvatar, 'SingDuetP2MAvatar');

      ThemeLoadStatic(Sing.StaticDuetP3R, 'SingDuetP3RStatic');
      ThemeLoadText(Sing.TextDuetP3R, 'SingDuetP3RText');
      ThemeLoadStatic(Sing.StaticDuetP3RScoreBG, 'SingDuetP3RStatic2');
      ThemeLoadText(Sing.TextDuetP3RScore, 'SingDuetP3RTextScore');
      ThemeLoadStatic(Sing.StaticDuetP3RAvatar, 'SingDuetP3RAvatar');

      ThemeLoadStatic(Sing.StaticDuetP1ThreePSingBar, 'SingDuetP1ThreePSingBar');
      ThemeLoadStatic(Sing.StaticDuetP2MSingBar, 'SingDuetP2MSingBar');
      ThemeLoadStatic(Sing.StaticDuetP3RSingBar, 'SingDuetP3RSingBar');

      //4P/6P mode in 1 Screen
      ThemeLoadStatic(Sing.StaticP1FourPSingBar, 'SingP1FourPSingBar');
      ThemeLoadStatic(Sing.StaticP1FourP, 'SingP1FourPStatic');
      ThemeLoadText(Sing.TextP1FourP, 'SingP1FourPText');
      ThemeLoadStatic(Sing.StaticP1FourPScoreBG, 'SingP1FourPStatic2');
      ThemeLoadText(Sing.TextP1FourPScore, 'SingP1FourPTextScore');
      ThemeLoadStatic(Sing.StaticP1FourPAvatar, 'SingP1FourPAvatar');

      ThemeLoadStatic(Sing.StaticP2FourPSingBar, 'SingP2FourPSingBar');
      ThemeLoadStatic(Sing.StaticP2FourP, 'SingP2FourPStatic');
      ThemeLoadText(Sing.TextP2FourP, 'SingP2FourPText');
      ThemeLoadStatic(Sing.StaticP2FourPScoreBG, 'SingP2FourPStatic2');
      ThemeLoadText(Sing.TextP2FourPScore, 'SingP2FourPTextScore');
      ThemeLoadStatic(Sing.StaticP2FourPAvatar, 'SingP2FourPAvatar');

      ThemeLoadStatic(Sing.StaticP3FourPSingBar, 'SingP3FourPSingBar');
      ThemeLoadStatic(Sing.StaticP3FourP, 'SingP3FourPStatic');
      ThemeLoadText(Sing.TextP3FourP, 'SingP3FourPText');
      ThemeLoadStatic(Sing.StaticP3FourPScoreBG, 'SingP3FourPStatic2');
      ThemeLoadText(Sing.TextP3FourPScore, 'SingP3FourPTextScore');
      ThemeLoadStatic(Sing.StaticP3FourPAvatar, 'SingP3FourPAvatar');

      ThemeLoadStatic(Sing.StaticP4FourPSingBar, 'SingP4FourPSingBar');
      ThemeLoadStatic(Sing.StaticP4FourP, 'SingP4FourPStatic');
      ThemeLoadText(Sing.TextP4FourP, 'SingP4FourPText');
      ThemeLoadStatic(Sing.StaticP4FourPScoreBG, 'SingP4FourPStatic2');
      ThemeLoadText(Sing.TextP4FourPScore, 'SingP4FourPTextScore');
      ThemeLoadStatic(Sing.StaticP4FourPAvatar, 'SingP4FourPAvatar');

      ThemeLoadStatic(Sing.StaticP1SixPSingBar, 'SingP1SixPSingBar');
      ThemeLoadStatic(Sing.StaticP1SixP, 'SingP1SixPStatic');
      ThemeLoadText(Sing.TextP1SixP, 'SingP1SixPText');
      ThemeLoadStatic(Sing.StaticP1SixPScoreBG, 'SingP1SixPStatic2');
      ThemeLoadText(Sing.TextP1SixPScore, 'SingP1SixPTextScore');
      ThemeLoadStatic(Sing.StaticP1SixPAvatar, 'SingP1SixPAvatar');

      ThemeLoadStatic(Sing.StaticP2SixPSingBar, 'SingP2SixPSingBar');
      ThemeLoadStatic(Sing.StaticP2SixP, 'SingP2SixPStatic');
      ThemeLoadText(Sing.TextP2SixP, 'SingP2SixPText');
      ThemeLoadStatic(Sing.StaticP2SixPScoreBG, 'SingP2SixPStatic2');
      ThemeLoadText(Sing.TextP2SixPScore, 'SingP2SixPTextScore');
      ThemeLoadStatic(Sing.StaticP2SixPAvatar, 'SingP2SixPAvatar');

      ThemeLoadStatic(Sing.StaticP3SixPSingBar, 'SingP3SixPSingBar');
      ThemeLoadStatic(Sing.StaticP3SixP, 'SingP3SixPStatic');
      ThemeLoadText(Sing.TextP3SixP, 'SingP3SixPText');
      ThemeLoadStatic(Sing.StaticP3SixPScoreBG, 'SingP3SixPStatic2');
      ThemeLoadText(Sing.TextP3SixPScore, 'SingP3SixPTextScore');
      ThemeLoadStatic(Sing.StaticP3SixPAvatar, 'SingP3SixPAvatar');

      ThemeLoadStatic(Sing.StaticP4SixPSingBar, 'SingP4SixPSingBar');
      ThemeLoadStatic(Sing.StaticP4SixP, 'SingP4SixPStatic');
      ThemeLoadText(Sing.TextP4SixP, 'SingP4SixPText');
      ThemeLoadStatic(Sing.StaticP4SixPScoreBG, 'SingP4SixPStatic2');
      ThemeLoadText(Sing.TextP4SixPScore, 'SingP4SixPTextScore');
      ThemeLoadStatic(Sing.StaticP4SixPAvatar, 'SingP4SixPAvatar');

      ThemeLoadStatic(Sing.StaticP5SixPSingBar, 'SingP5SixPSingBar');
      ThemeLoadStatic(Sing.StaticP5SixP, 'SingP5SixPStatic');
      ThemeLoadText(Sing.TextP5SixP, 'SingP5SixPText');
      ThemeLoadStatic(Sing.StaticP5SixPScoreBG, 'SingP5SixPStatic2');
      ThemeLoadText(Sing.TextP5SixPScore, 'SingP5SixPTextScore');
      ThemeLoadStatic(Sing.StaticP5SixPAvatar, 'SingP5SixPAvatar');

      ThemeLoadStatic(Sing.StaticP6SixPSingBar, 'SingP6SixPSingBar');
      ThemeLoadStatic(Sing.StaticP6SixP, 'SingP6SixPStatic');
      ThemeLoadText(Sing.TextP6SixP, 'SingP6SixPText');
      ThemeLoadStatic(Sing.StaticP6SixPScoreBG, 'SingP6SixPStatic2');
      ThemeLoadText(Sing.TextP6SixPScore, 'SingP6SixPTextScore');
      ThemeLoadStatic(Sing.StaticP6SixPAvatar, 'SingP6SixPAvatar');

      // duet 4/6 players in one screen
      ThemeLoadStatic(Sing.StaticP1DuetFourPSingBar, 'SingP1DuetFourPSingBar');
      ThemeLoadStatic(Sing.StaticP1DuetFourP, 'SingP1DuetFourPStatic');
      ThemeLoadText(Sing.TextP1DuetFourP, 'SingP1DuetFourPText');
      ThemeLoadStatic(Sing.StaticP1DuetFourPScoreBG, 'SingP1DuetFourPStatic2');
      ThemeLoadText(Sing.TextP1DuetFourPScore, 'SingP1DuetFourPTextScore');
      ThemeLoadStatic(Sing.StaticP1DuetFourPAvatar, 'SingP1DuetFourPAvatar');

      ThemeLoadStatic(Sing.StaticP2DuetFourPSingBar, 'SingP2DuetFourPSingBar');
      ThemeLoadStatic(Sing.StaticP2DuetFourP, 'SingP2DuetFourPStatic');
      ThemeLoadText(Sing.TextP2DuetFourP, 'SingP2DuetFourPText');
      ThemeLoadStatic(Sing.StaticP2DuetFourPScoreBG, 'SingP2DuetFourPStatic2');
      ThemeLoadText(Sing.TextP2DuetFourPScore, 'SingP2DuetFourPTextScore');
      ThemeLoadStatic(Sing.StaticP2DuetFourPAvatar, 'SingP2DuetFourPAvatar');

      ThemeLoadStatic(Sing.StaticP3DuetFourPSingBar, 'SingP3DuetFourPSingBar');
      ThemeLoadStatic(Sing.StaticP3DuetFourP, 'SingP3DuetFourPStatic');
      ThemeLoadText(Sing.TextP3DuetFourP, 'SingP3DuetFourPText');
      ThemeLoadStatic(Sing.StaticP3DuetFourPScoreBG, 'SingP3DuetFourPStatic2');
      ThemeLoadText(Sing.TextP3DuetFourPScore, 'SingP3DuetFourPTextScore');
      ThemeLoadStatic(Sing.StaticP3DuetFourPAvatar, 'SingP3DuetFourPAvatar');

      ThemeLoadStatic(Sing.StaticP4DuetFourPSingBar, 'SingP4DuetFourPSingBar');
      ThemeLoadStatic(Sing.StaticP4DuetFourP, 'SingP4DuetFourPStatic');
      ThemeLoadText(Sing.TextP4DuetFourP, 'SingP4DuetFourPText');
      ThemeLoadStatic(Sing.StaticP4DuetFourPScoreBG, 'SingP4DuetFourPStatic2');
      ThemeLoadText(Sing.TextP4DuetFourPScore, 'SingP4DuetFourPTextScore');
      ThemeLoadStatic(Sing.StaticP4DuetFourPAvatar, 'SingP4DuetFourPAvatar');


      ThemeLoadStatic(Sing.StaticP1DuetSixPSingBar, 'SingP1DuetSixPSingBar');
      ThemeLoadStatic(Sing.StaticP1DuetSixP, 'SingP1DuetSixPStatic');
      ThemeLoadText(Sing.TextP1DuetSixP, 'SingP1DuetSixPText');
      ThemeLoadStatic(Sing.StaticP1DuetSixPScoreBG, 'SingP1DuetSixPStatic2');
      ThemeLoadText(Sing.TextP1DuetSixPScore, 'SingP1DuetSixPTextScore');
      ThemeLoadStatic(Sing.StaticP1DuetSixPAvatar, 'SingP1DuetSixPAvatar');

      ThemeLoadStatic(Sing.StaticP2DuetSixPSingBar, 'SingP2DuetSixPSingBar');
      ThemeLoadStatic(Sing.StaticP2DuetSixP, 'SingP2DuetSixPStatic');
      ThemeLoadText(Sing.TextP2DuetSixP, 'SingP2DuetSixPText');
      ThemeLoadStatic(Sing.StaticP2DuetSixPScoreBG, 'SingP2DuetSixPStatic2');
      ThemeLoadText(Sing.TextP2DuetSixPScore, 'SingP2DuetSixPTextScore');
      ThemeLoadStatic(Sing.StaticP2DuetSixPAvatar, 'SingP2DuetSixPAvatar');

      ThemeLoadStatic(Sing.StaticP3DuetSixPSingBar, 'SingP3DuetSixPSingBar');
      ThemeLoadStatic(Sing.StaticP3DuetSixP, 'SingP3DuetSixPStatic');
      ThemeLoadText(Sing.TextP3DuetSixP, 'SingP3DuetSixPText');
      ThemeLoadStatic(Sing.StaticP3DuetSixPScoreBG, 'SingP3DuetSixPStatic2');
      ThemeLoadText(Sing.TextP3DuetSixPScore, 'SingP3DuetSixPTextScore');
      ThemeLoadStatic(Sing.StaticP3DuetSixPAvatar, 'SingP3DuetSixPAvatar');

      ThemeLoadStatic(Sing.StaticP4DuetSixPSingBar, 'SingP4DuetSixPSingBar');
      ThemeLoadStatic(Sing.StaticP4DuetSixP, 'SingP4DuetSixPStatic');
      ThemeLoadText(Sing.TextP4DuetSixP, 'SingP4DuetSixPText');
      ThemeLoadStatic(Sing.StaticP4DuetSixPScoreBG, 'SingP4DuetSixPStatic2');
      ThemeLoadText(Sing.TextP4DuetSixPScore, 'SingP4DuetSixPTextScore');
      ThemeLoadStatic(Sing.StaticP4DuetSixPAvatar, 'SingP4DuetSixPAvatar');

      ThemeLoadStatic(Sing.StaticP5DuetSixPSingBar, 'SingP5DuetSixPSingBar');
      ThemeLoadStatic(Sing.StaticP5DuetSixP, 'SingP5DuetSixPStatic');
      ThemeLoadText(Sing.TextP5DuetSixP, 'SingP5DuetSixPText');
      ThemeLoadStatic(Sing.StaticP5DuetSixPScoreBG, 'SingP5DuetSixPStatic2');
      ThemeLoadText(Sing.TextP5DuetSixPScore, 'SingP5DuetSixPTextScore');
      ThemeLoadStatic(Sing.StaticP5DuetSixPAvatar, 'SingP5DuetSixPAvatar');

      ThemeLoadStatic(Sing.StaticP6DuetSixPSingBar, 'SingP6DuetSixPSingBar');
      ThemeLoadStatic(Sing.StaticP6DuetSixP, 'SingP6DuetSixPStatic');
      ThemeLoadText(Sing.TextP6DuetSixP, 'SingP6DuetSixPText');
      ThemeLoadStatic(Sing.StaticP6DuetSixPScoreBG, 'SingP6DuetSixPStatic2');
      ThemeLoadText(Sing.TextP6DuetSixPScore, 'SingP6DuetSixPTextScore');
      ThemeLoadStatic(Sing.StaticP6DuetSixPAvatar, 'SingP6DuetSixPAvatar');

      // Oscilloscope Position
      ThemeLoadPosition(Sing.SingP1Oscilloscope, 'SingP1Oscilloscope');
      ThemeLoadPosition(Sing.SingP1TwoPOscilloscope, 'SingP1TwoPOscilloscope');
      ThemeLoadPosition(Sing.SingP2ROscilloscope, 'SingP2ROscilloscope');
      ThemeLoadPosition(Sing.SingP1ThreePOscilloscope, 'SingP1ThreePOscilloscope');
      ThemeLoadPosition(Sing.SingP2MOscilloscope, 'SingP2MOscilloscope');
      ThemeLoadPosition(Sing.SingP3ROscilloscope, 'SingP3ROscilloscope');
      ThemeLoadPosition(Sing.SingDuetP1ThreePOscilloscope, 'SingDuetP1ThreePOscilloscope');
      ThemeLoadPosition(Sing.SingDuetP2MOscilloscope, 'SingDuetP2MOscilloscope');
      ThemeLoadPosition(Sing.SingDuetP3ROscilloscope, 'SingDuetP3ROscilloscope');
      ThemeLoadPosition(Sing.SingP1FourPOscilloscope, 'SingP1FourPOscilloscope');
      ThemeLoadPosition(Sing.SingP2FourPOscilloscope, 'SingP2FourPOscilloscope');
      ThemeLoadPosition(Sing.SingP3FourPOscilloscope, 'SingP3FourPOscilloscope');
      ThemeLoadPosition(Sing.SingP4FourPOscilloscope, 'SingP4FourPOscilloscope');
      ThemeLoadPosition(Sing.SingP1SixPOscilloscope, 'SingP1SixPOscilloscope');
      ThemeLoadPosition(Sing.SingP2SixPOscilloscope, 'SingP2SixPOscilloscope');
      ThemeLoadPosition(Sing.SingP3SixPOscilloscope, 'SingP3SixPOscilloscope');
      ThemeLoadPosition(Sing.SingP4SixPOscilloscope, 'SingP4SixPOscilloscope');
      ThemeLoadPosition(Sing.SingP5SixPOscilloscope, 'SingP5SixPOscilloscope');
      ThemeLoadPosition(Sing.SingP6SixPOscilloscope, 'SingP6SixPOscilloscope');
      ThemeLoadPosition(Sing.SingP1DuetFourPOscilloscope, 'SingP1DuetFourPOscilloscope');
      ThemeLoadPosition(Sing.SingP2DuetFourPOscilloscope, 'SingP2DuetFourPOscilloscope');
      ThemeLoadPosition(Sing.SingP3DuetFourPOscilloscope, 'SingP3DuetFourPOscilloscope');
      ThemeLoadPosition(Sing.SingP4DuetFourPOscilloscope, 'SingP4DuetFourPOscilloscope');
      ThemeLoadPosition(Sing.SingP1DuetSixPOscilloscope, 'SingP1DuetSixPOscilloscope');
      ThemeLoadPosition(Sing.SingP2DuetSixPOscilloscope, 'SingP2DuetSixPOscilloscope');
      ThemeLoadPosition(Sing.SingP3DuetSixPOscilloscope, 'SingP3DuetSixPOscilloscope');
      ThemeLoadPosition(Sing.SingP4DuetSixPOscilloscope, 'SingP4DuetSixPOscilloscope');
      ThemeLoadPosition(Sing.SingP5DuetSixPOscilloscope, 'SingP5DuetSixPOscilloscope');
      ThemeLoadPosition(Sing.SingP6DuetSixPOscilloscope, 'SingP6DuetSixPOscilloscope');

      //Line Bonus Texts
      Sing.LineBonusText[0] := Language.Translate('POPUP_AWFUL');
      Sing.LineBonusText[1] := Sing.LineBonusText[0];
      Sing.LineBonusText[2] := Language.Translate('POPUP_POOR');
      Sing.LineBonusText[3] := Language.Translate('POPUP_BAD');
      Sing.LineBonusText[4] := Language.Translate('POPUP_NOTBAD');
      Sing.LineBonusText[5] := Language.Translate('POPUP_GOOD');
      Sing.LineBonusText[6] := Language.Translate('POPUP_GREAT');
      Sing.LineBonusText[7] := Language.Translate('POPUP_AWESOME');
      Sing.LineBonusText[8] := Language.Translate('POPUP_PERFECT');

      //PausePopup
      ThemeLoadStatic(Sing.PausePopUp, 'PausePopUpStatic');

      // Score
      ThemeLoadBasic(Score, 'Score');

      ThemeLoadText(Score.TextArtist, 'ScoreTextArtist');
      ThemeLoadText(Score.TextTitle, 'ScoreTextTitle');
      ThemeLoadText(Score.TextArtistTitle, 'ScoreTextArtistTitle');

      // Send Button's
      for I := 1 to 3 do
         ThemeLoadButton(Score.ButtonSend[I], 'ScoreButtonSend' + IntToStr(I));

      // Top5
      ThemeLoadBasic(Top5, 'Top5');

      ThemeLoadText(Top5.TextLevel,       'Top5TextLevel');
      ThemeLoadText(Top5.TextArtistTitle, 'Top5TextArtistTitle');
      ThemeLoadStatics(Top5.StaticNumber, 'Top5StaticNumber');
      ThemeLoadTexts(Top5.TextNumber,     'Top5TextNumber');
      ThemeLoadTexts(Top5.TextName,       'Top5TextName');
      ThemeLoadTexts(Top5.TextScore,      'Top5TextScore');
      ThemeLoadTexts(Top5.TextDate,       'Top5TextDate');

      // Options
      ThemeLoadBasic(Options, 'Options');

      ThemeLoadButton(Options.ButtonGame,        'OptionsButtonGame');
      ThemeLoadButton(Options.ButtonGraphics,    'OptionsButtonGraphics');
      ThemeLoadButton(Options.ButtonSound,       'OptionsButtonSound');

      ThemeLoadButton(Options.ButtonLyrics,      'OptionsButtonLyrics');
      ThemeLoadButton(Options.ButtonThemes,      'OptionsButtonThemes');
      ThemeLoadButton(Options.ButtonMicrophones, 'OptionsButtonMicrophones');
      ThemeLoadButton(Options.ButtonAdvanced,    'OptionsButtonAdvanced');
      ThemeLoadButton(Options.ButtonNetwork,     'OptionsButtonNetwork');
      ThemeLoadButton(Options.ButtonWebcam,      'OptionsButtonWebcam');
      ThemeLoadButton(Options.ButtonProfiles,    'OptionsButtonProfiles');
      ThemeLoadButton(Options.ButtonExit,        'OptionsButtonExit');

      ThemeLoadText(Options.TextDescription, 'OptionsTextDescription');
      // Options Game
      ThemeLoadBasic(OptionsGame, 'OptionsGame');

      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectLanguage, 'OptionsGameSelectSlideLanguage');
      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectSongMenu, 'OptionsGameSelectSongMenu');
      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectDuets, 'OptionsGameSelectDuets');
      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectTabs, 'OptionsGameSelectTabs');
      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectSorting, 'OptionsGameSelectSlideSorting');
      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectShowScores, 'OptionsGameSelectShowScores');
      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectSingScores, 'OptionsGameSelectSingScores');
      Self.ThemeLoadSelectSlide(Self.OptionsGame.SelectFindUnsetMedley, 'OptionsGameSelectFindUnsetMedley');
      Self.ThemeLoadButton(Self.OptionsGame.ButtonExit, 'OptionsGameButtonExit');

      // Options Graphics
      ThemeLoadBasic(OptionsGraphics, 'OptionsGraphics');

      ThemeLoadSelectSlide(OptionsGraphics.SelectFullscreen,   'OptionsGraphicsSelectFullscreen');
      ThemeLoadSelectSlide(OptionsGraphics.SelectResolution,   'OptionsGraphicsSelectSlideResolution');
      ThemeLoadSelectSlide(OptionsGraphics.SelectScreenFade,    'OptionsGraphicsSelectScreenFade');
      ThemeLoadSelectSlide(OptionsGraphics.SelectEffectSing,    'OptionsGraphicsSelectEffectSing');
      ThemeLoadSelectSlide(OptionsGraphics.SelectVisualizer,   'OptionsGraphicsSelectVisualizer');
      ThemeLoadSelectSlide(OptionsGraphics.SelectMovieSize,    'OptionsGraphicsSelectMovieSize');
      ThemeLoadButton(OptionsGraphics.ButtonExit,              'OptionsGraphicsButtonExit');

      // Options Sound
      ThemeLoadBasic(OptionsSound, 'OptionsSound');

      ThemeLoadSelectSlide(OptionsSound.SelectBackgroundMusic,       'OptionsSoundSelectBackgroundMusic');
      ThemeLoadSelectSlide(OptionsSound.SelectClickAssist,           'OptionsSoundSelectClickAssist');
      ThemeLoadSelectSlide(OptionsSound.SelectBeatClick,             'OptionsSoundSelectBeatClick');
      //Song Preview
      ThemeLoadSelectSlide(OptionsSound.SelectSlidePreviewVolume,    'OptionsSoundSelectSlidePreviewVolume');
      ThemeLoadSelectSlide(OptionsSound.SelectSlidePreviewFading,    'OptionsSoundSelectSlidePreviewFading');
      ThemeLoadSelectSlide(OptionsSound.SelectSlideVoicePassthrough, 'OptionsSoundSelectVoicePassthrough');
      ThemeLoadSelectSlide(OptionsSound.SelectSlideMusicAutoGain,    'OptionsSoundSelectSlideMusicAutoGain');

      ThemeLoadButton(OptionsSound.ButtonExit, 'OptionsSoundButtonExit');

      // Options Lyrics
      ThemeLoadBasic(OptionsLyrics, 'OptionsLyrics');

      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectMode, 'OptionsLyricsSelectMode');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectModeProperty, 'OptionsLyricsSelectModeProperty');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectFont, 'OptionsLyricsSelectFont');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectEffect, 'OptionsLyricsSelectEffect');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectTransparency, 'OptionsLyricsSelectTransparency');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectLines, 'OptionsLyricsSelectLines');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectProperty, 'OptionsLyricsSelectProperty');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectColor, 'OptionsLyricsSelectColor');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectR, 'OptionsLyricsSelectR');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectG, 'OptionsLyricsSelectG');
      Self.ThemeLoadSelectSlide(Self.OptionsLyrics.SelectB, 'OptionsLyricsSelectB');
      Self.ThemeLoadStatic(Self.OptionsLyrics.PointerR, 'OptionsLyricsPointerR');
      Self.ThemeLoadStatic(Self.OptionsLyrics.PointerG, 'OptionsLyricsPointerG');
      Self.ThemeLoadStatic(Self.OptionsLyrics.PointerB, 'OptionsLyricsPointerB');
      Self.ThemeLoadStatic(Self.OptionsLyrics.TexColor, 'OptionsLyricsColor');
      Self.ThemeLoadLyricBar(Self.OptionsLyrics.LyricBar, 'OptionsLyricsUpperBar');
      Self.ThemeLoadButton(OptionsLyrics.ButtonExit, 'OptionsLyricsButtonExit');

      // Options Themes
      ThemeLoadBasic(OptionsThemes, 'OptionsThemes');

      ThemeLoadSelectSlide(OptionsThemes.SelectTheme, 'OptionsThemesSelectTheme');
      ThemeLoadSelectSlide(OptionsThemes.SelectSkin,  'OptionsThemesSelectSkin');
      ThemeLoadSelectSlide(OptionsThemes.SelectColor, 'OptionsThemesSelectColor');
      ThemeLoadButton(OptionsThemes.ButtonExit,       'OptionsThemesButtonExit');

      // Options Microphones
      ThemeLoadBasic(OptionsMicrophones, 'OptionsMicrophones');

      ThemeLoadSelectSlide(OptionsMicrophones.SelectSlideCard,     'OptionsMicrophonesSelectSlideCard');
      ThemeLoadSelectSlide(OptionsMicrophones.SelectSlideInput,    'OptionsMicrophonesSelectSlideInput');
      ThemeLoadSelectSlide(OptionsMicrophones.SelectSlideChannel,  'OptionsMicrophonesSelectSlideChannel');
      ThemeLoadSelectSlide(OptionsMicrophones.SelectThreshold,     'OptionsMicrophonesSelectThreshold');
      ThemeLoadSelectSlide(OptionsMicrophones.SelectMicBoost,      'OptionsMicrophonesSelectMicBoost');
      ThemeLoadButton(OptionsMicrophones.ButtonExit,               'OptionsMicrophonesButtonExit');

      //Options Advanced
      ThemeLoadBasic(OptionsAdvanced, 'OptionsAdvanced');

      ThemeLoadSelectSlide(OptionsAdvanced.SelectDebug,      	'OptionsAdvancedSelectDebug');
      ThemeLoadSelectSlide(OptionsAdvanced.SelectOscilloscope,  'OptionsAdvancedSelectOscilloscope');
      ThemeLoadSelectSlide(OptionsAdvanced.SelectOnSongClick,   'OptionsAdvancedSelectSlideOnSongClick');
      ThemeLoadSelectSlide(OptionsAdvanced.SelectAskbeforeDel,  'OptionsAdvancedSelectAskbeforeDel');
      ThemeLoadSelectSlide(OptionsAdvanced.SelectPartyPopup,    'OptionsAdvancedSelectPartyPopup');
      ThemeLoadSelectSlide(OptionsAdvanced.SelectTopScores,     'OptionsAdvancedSelectTopScores');
      ThemeLoadButton     (OptionsAdvanced.ButtonExit,          'OptionsAdvancedButtonExit');

      //Options Network
      ThemeLoadBasic(OptionsNetwork, 'OptionsNetwork');

      ThemeLoadSelectSlide(OptionsNetwork.SelectWebsite,       'OptionsNetworkSelectWebsite');
      ThemeLoadSelectSlide(OptionsNetwork.SelectUsername,      'OptionsNetworkSelectUsername');
      ThemeLoadSelectSlide(OptionsNetwork.SelectSendName,      'OptionsNetworkSelectSendSaveName');
      ThemeLoadSelectSlide(OptionsNetwork.SelectAutoMode,      'OptionsNetworkSelectAutoMode');
      ThemeLoadSelectSlide(OptionsNetwork.SelectAutoPlayer,      'OptionsNetworkSelectAutoPlayer');
      ThemeLoadSelectSlide(OptionsNetwork.SelectAutoScoreEasy,   'OptionsNetworkSelectAutoScoreEasy');
      ThemeLoadSelectSlide(OptionsNetwork.SelectAutoScoreMedium, 'OptionsNetworkSelectAutoScoreMedium');
      ThemeLoadSelectSlide(OptionsNetwork.SelectAutoScoreHard,   'OptionsNetworkSelectAutoScoreHard');
      ThemeLoadText(OptionsNetwork.TextInsertUser, 'OptionsNetworkTextInsertUser');

      ThemeLoadButton(OptionsNetwork.ButtonInsert,          'OptionsNetworkButtonInsert');
      ThemeLoadButton(OptionsNetwork.ButtonExit,          'OptionsNetworkButtonExit');

      //Options Webcam
      ThemeLoadBasic(OptionsWebcam, 'OptionsWebcam');

      ThemeLoadSelectSlide(OptionsWebcam.SelectWebcam,     'OptionsWebcamSelectWebcam');
      ThemeLoadSelectSlide(OptionsWebcam.SelectResolution, 'OptionsWebcamSelectResolution');
      ThemeLoadSelectSlide(OptionsWebcam.SelectFPS,        'OptionsWebcamSelectFPS');
      ThemeLoadSelectSlide(OptionsWebcam.SelectFlip,       'OptionsWebcamSelectFlip');
      ThemeLoadSelectSlide(OptionsWebcam.SelectBrightness, 'OptionsWebcamSelectBrightness');
      ThemeLoadSelectSlide(OptionsWebcam.SelectSaturation, 'OptionsWebcamSelectSaturation');
      ThemeLoadSelectSlide(OptionsWebcam.SelectHue,        'OptionsWebcamSelectHue');
      ThemeLoadSelectSlide(OptionsWebcam.SelectEffect,     'OptionsWebcamSelectEffect');

      ThemeLoadButton(OptionsWebcam.ButtonPreVisualization,          'OptionsWebcamButtonPreVisualization');
      ThemeLoadButton(OptionsWebcam.ButtonExit,          'OptionsWebcamButtonExit');

      //Options Profiles
	  ThemeLoadBasic(OptionsProfiles, 'OptionsProfiles');
	  ThemeLoadButton(OptionsProfiles.ButtonExit,          'OptionsProfilesButtonExit');

      //error popup
      ThemeLoadBasic (ErrorPopup, 'ErrorPopup');
      ThemeLoadButton(ErrorPopup.Button1, 'ErrorPopupButton1');
      ThemeLoadText  (ErrorPopup.TextError,'ErrorPopupText');

      //check popup
      ThemeLoadBasic (CheckPopup, 'CheckPopup');
      ThemeLoadButton(CheckPopup.Button1, 'CheckPopupButton1');
      ThemeLoadButton(CheckPopup.Button2, 'CheckPopupButton2');
      ThemeLoadText(CheckPopup.TextCheck , 'CheckPopupText');

      // insert user popup
      ThemeLoadBasic (InsertUserPopup, 'InsertUserPopup');
      ThemeLoadText  (InsertUserPopup.TextInsertUser , 'InsertUserPopupText');
      ThemeLoadButton(InsertUserPopup.ButtonUsername, 'InsertUserPopupButtonUsername');
      ThemeLoadButton(InsertUserPopup.ButtonPassword, 'InsertUserPopupButtonPassword');
      ThemeLoadButton(InsertUserPopup.Button1, 'InsertUserPopupButton1');
      ThemeLoadButton(InsertUserPopup.Button2, 'InsertUserPopupButton2');

      // send score popup
      ThemeLoadBasic (SendScorePopup, 'SendScorePopup');
      ThemeLoadSelectSlide(SendScorePopup.SelectSlide1, 'SendScorePopupSelectSlide1');
      ThemeLoadSelectSlide(SendScorePopup.SelectSlide2, 'SendScorePopupSelectSlide2');
      ThemeLoadSelectSlide(SendScorePopup.SelectSlide3, 'SendScorePopupSelectSlide3');
      ThemeLoadButton(SendScorePopup.ButtonUsername, 'SendScorePopupButtonUsername');
      ThemeLoadButton(SendScorePopup.ButtonPassword, 'SendScorePopupButtonPassword');
      ThemeLoadButton(SendScorePopup.Button1, 'SendScorePopupButton1');
      ThemeLoadButton(SendScorePopup.Button2, 'SendScorePopupButton2');

      // download score popup
      ThemeLoadBasic (ScoreDownloadPopup, 'ScoreDownloadPopup');
      ThemeLoadButton(ScoreDownloadPopup.Button1, 'ScoreDownloadPopupButton1');
      ThemeLoadText(ScoreDownloadPopup.TextSongScoreDownload , 'ScoreDownloadPopupSongText');
      ThemeLoadText(ScoreDownloadPopup.TextWebScoreDownload , 'ScoreDownloadPopupWebText');
      ThemeLoadStatic(ScoreDownloadPopup.DownloadProgressSong, 'ScoreDownloadPopupProgressSong');
      ThemeLoadStatic(ScoreDownloadPopup.DownloadProgressWeb, 'ScoreDownloadPopupProgressWeb');

      //Song Menu
      ThemeLoadBasic (SongMenu, 'SongMenu');
      ThemeLoadButton(SongMenu.Button1, 'SongMenuButton1');
      ThemeLoadButton(SongMenu.Button2, 'SongMenuButton2');
      ThemeLoadButton(SongMenu.Button3, 'SongMenuButton3');
      ThemeLoadButton(SongMenu.Button4, 'SongMenuButton4');
      ThemeLoadButton(SongMenu.Button5, 'SongMenuButton5');
      ThemeLoadButton(SongMenu.Button6, 'SongMenuButton6');
      ThemeLoadSelectSlide(SongMenu.SelectSlide1, 'SongMenuSelectSlide1');
      ThemeLoadSelectSlide(SongMenu.SelectSlide2, 'SongMenuSelectSlide2');
      ThemeLoadSelectSlide(SongMenu.SelectSlide3, 'SongMenuSelectSlide3');

      ThemeLoadText(SongMenu.TextMenu, 'SongMenuTextMenu');

      //Party Options
      ThemeLoadBasic(PartyOptions, 'PartyOptions');
      ThemeLoadSelectSlide(PartyOptions.SelectMode, 'PartyOptionsSelectMode');
      ThemeLoadSelectSlide(PartyOptions.SelectLevel, 'PartyOptionsSelectLevel');
      ThemeLoadSelectSlide(PartyOptions.SelectPlayList, 'PartyOptionsSelectPlayList');
      ThemeLoadSelectSlide(PartyOptions.SelectPlayListItems, 'PartyOptionsSelectPlayListItems');
      {ThemeLoadButton (ButtonNext, 'ButtonNext');
      ThemeLoadButton (ButtonPrev, 'ButtonPrev');}

      //Party Player
      ThemeLoadBasic(PartyPlayer, 'PartyPlayer');

      ThemeLoadSelectSlide(PartyPlayer.SelectTeams, 'PartyPlayerSelectTeams');
      ThemeLoadSelectSlide(PartyPlayer.SelectPlayers1, 'PartyPlayerSelectPlayers1');
      ThemeLoadSelectSlide(PartyPlayer.SelectPlayers2, 'PartyPlayerSelectPlayers2');
      ThemeLoadSelectSlide(PartyPlayer.SelectPlayers3, 'PartyPlayerSelectPlayers3');

      ThemeLoadButton(PartyPlayer.Team1Name, 'PartyPlayerTeam1Name');
      ThemeLoadButton(PartyPlayer.Player1Name, 'PartyPlayerPlayer1Name');
      ThemeLoadButton(PartyPlayer.Player2Name, 'PartyPlayerPlayer2Name');
      ThemeLoadButton(PartyPlayer.Player3Name, 'PartyPlayerPlayer3Name');
      ThemeLoadButton(PartyPlayer.Player4Name, 'PartyPlayerPlayer4Name');

      ThemeLoadButton(PartyPlayer.Team2Name, 'PartyPlayerTeam2Name');
      ThemeLoadButton(PartyPlayer.Player5Name, 'PartyPlayerPlayer5Name');
      ThemeLoadButton(PartyPlayer.Player6Name, 'PartyPlayerPlayer6Name');
      ThemeLoadButton(PartyPlayer.Player7Name, 'PartyPlayerPlayer7Name');
      ThemeLoadButton(PartyPlayer.Player8Name, 'PartyPlayerPlayer8Name');

      ThemeLoadButton(PartyPlayer.Team3Name, 'PartyPlayerTeam3Name');
      ThemeLoadButton(PartyPlayer.Player9Name, 'PartyPlayerPlayer9Name');
      ThemeLoadButton(PartyPlayer.Player10Name, 'PartyPlayerPlayer10Name');
      ThemeLoadButton(PartyPlayer.Player11Name, 'PartyPlayerPlayer11Name');
      ThemeLoadButton(PartyPlayer.Player12Name, 'PartyPlayerPlayer12Name');

      // Party Rounds
      ThemeLoadBasic(PartyRounds, 'PartyRounds');

      ThemeLoadSelectSlide(PartyRounds.SelectRoundCount, 'PartyRoundsSelectRoundCount');
      for I := 0 to High(PartyRounds.SelectRound) do
        ThemeLoadSelectSlide(PartyRounds.SelectRound[I], 'PartyRoundsSelectRound' + IntToStr(I + 1));

      {ThemeLoadButton(ButtonNext, 'PartyPlayerButtonNext');
      ThemeLoadButton(ButtonPrev, 'PartyPlayerButtonPrev');}

      //Party Tournament Player
      ThemeLoadBasic(PartyTournamentPlayer, 'PartyTournamentPlayer');

      ThemeLoadSelectSlide(PartyTournamentPlayer.SelectPlayers, 'PartyTournamentPlayerSelectPlayers');

      ThemeLoadButton(PartyTournamentPlayer.Player1Name, 'PartyTournamentPlayerPlayer1Name');
      ThemeLoadButton(PartyTournamentPlayer.Player2Name, 'PartyTournamentPlayerPlayer2Name');
      ThemeLoadButton(PartyTournamentPlayer.Player3Name, 'PartyTournamentPlayerPlayer3Name');
      ThemeLoadButton(PartyTournamentPlayer.Player4Name, 'PartyTournamentPlayerPlayer4Name');
      ThemeLoadButton(PartyTournamentPlayer.Player5Name, 'PartyTournamentPlayerPlayer5Name');
      ThemeLoadButton(PartyTournamentPlayer.Player6Name, 'PartyTournamentPlayerPlayer6Name');
      ThemeLoadButton(PartyTournamentPlayer.Player7Name, 'PartyTournamentPlayerPlayer7Name');
      ThemeLoadButton(PartyTournamentPlayer.Player8Name, 'PartyTournamentPlayerPlayer8Name');
      ThemeLoadButton(PartyTournamentPlayer.Player9Name, 'PartyTournamentPlayerPlayer9Name');
      ThemeLoadButton(PartyTournamentPlayer.Player10Name, 'PartyTournamentPlayerPlayer10Name');
      ThemeLoadButton(PartyTournamentPlayer.Player11Name, 'PartyTournamentPlayerPlayer11Name');
      ThemeLoadButton(PartyTournamentPlayer.Player12Name, 'PartyTournamentPlayerPlayer12Name');
      ThemeLoadButton(PartyTournamentPlayer.Player13Name, 'PartyTournamentPlayerPlayer13Name');
      ThemeLoadButton(PartyTournamentPlayer.Player14Name, 'PartyTournamentPlayerPlayer14Name');
      ThemeLoadButton(PartyTournamentPlayer.Player15Name, 'PartyTournamentPlayerPlayer15Name');
      ThemeLoadButton(PartyTournamentPlayer.Player16Name, 'PartyTournamentPlayerPlayer16Name');

      //Party Tournament Options
      ThemeLoadBasic(PartyTournamentOptions, 'PartyTournamentOptions');
      ThemeLoadSelectSlide(PartyTournamentOptions.SelectRoundsFinal, 'PartyTournamentOptionsSelectRoundsFinal');
      ThemeLoadSelectSlide(PartyTournamentOptions.SelectRounds2Final, 'PartyTournamentOptionsSelectRounds2Final');
      ThemeLoadSelectSlide(PartyTournamentOptions.SelectRounds4Final, 'PartyTournamentOptionsSelectRounds4Final');
      ThemeLoadSelectSlide(PartyTournamentOptions.SelectRounds8Final, 'PartyTournamentOptionsSelectRounds8Final');

      //Party Tournament Rounds

      ThemeLoadBasic(PartyTournamentRounds, 'PartyTournamentRounds');

      for I := 0 to 1 do
      begin
        for J := 0 to 7 do
        begin
          ThemeLoadButton (PartyTournamentRounds.TextNamePlayer[I, J], 'PartyTournamentRoundsTextNameBlock' + IntToStr(I + 1) + 'Player' + IntToStr(J + 1));
        end;
      end;

      ThemeLoadText(PartyTournamentRounds.TextWinner, 'PartyTournamentRoundsWinner');
      ThemeLoadText(PartyTournamentRounds.TextResult, 'PartyTournamentRoundsResult');

      ThemeLoadText(PartyTournamentRounds.NextPlayers, 'PartyTournamentRoundsNextPlayers');

      //Party Tournament Win
      ThemeLoadBasic(PartyTournamentWin, 'PartyTournamentWin');

      ThemeLoadText (PartyTournamentWin.TextScorePlayer1,    'PartyTournamentWinTextScorePlayer1');
      ThemeLoadText (PartyTournamentWin.TextScorePlayer2,    'PartyTournamentWinTextScorePlayer2');

      ThemeLoadText (PartyTournamentWin.TextNamePlayer1,     'PartyTournamentWinTextNamePlayer1');
      ThemeLoadText (PartyTournamentWin.TextNamePlayer2,     'PartyTournamentWinTextNamePlayer2');

      ThemeLoadStatic (PartyTournamentWin.StaticBGPlayer1,   'PartyTournamentWinStaticBGPlayer1');
      ThemeLoadStatic (PartyTournamentWin.StaticBGPlayer2,   'PartyTournamentWinStaticBGPlayer2');

      // About
      ThemeLoadBasic(AboutMain, 'AboutMain');
      ThemeLoadButton(AboutMain.ButtonDevelopers, 'AboutMainButtonDevelopers');
      ThemeLoadButton(AboutMain.ButtonExit, 'AboutMainButtonExit');
      ThemeLoadText (AboutMain.TextOverview, 'AboutMainTextOverview');
	  ThemeLoadStatic(AboutMain.StaticBghelper, 'AboutMainStatico');

      ThemeLoadBasic(Developers, 'Developers');
      ThemeLoadButton(Developers.ButtonExit, 'DevelopersButtonExit');
      ThemeLoadText (Developers.TextOverview, 'DevelopersTextOverview');

      // Stats
      ThemeLoadBasic(StatMain, 'StatMain');

      ThemeLoadButton(StatMain.ButtonScores, 'StatMainButtonScores');
      ThemeLoadButton(StatMain.ButtonSingers, 'StatMainButtonSingers');
      ThemeLoadButton(StatMain.ButtonSongs, 'StatMainButtonSongs');
      ThemeLoadButton(StatMain.ButtonBands, 'StatMainButtonBands');
      ThemeLoadButton(StatMain.ButtonExit, 'StatMainButtonExit');

      ThemeLoadText (StatMain.TextOverview, 'StatMainTextOverview');


      ThemeLoadBasic(StatDetail, 'StatDetail');

      ThemeLoadButton(StatDetail.ButtonNext, 'StatDetailButtonNext');
      ThemeLoadButton(StatDetail.ButtonPrev, 'StatDetailButtonPrev');
      ThemeLoadButton(StatDetail.ButtonReverse, 'StatDetailButtonReverse');
      ThemeLoadButton(StatDetail.ButtonExit, 'StatDetailButtonExit');

      ThemeLoadText (StatDetail.TextDescription, 'StatDetailTextDescription');
      ThemeLoadText (StatDetail.TextPage, 'StatDetailTextPage');
      ThemeLoadTexts(StatDetail.TextList, 'StatDetailTextList');

      //Translate Texts
      StatDetail.Description[0] := Language.Translate('STAT_DESC_SCORES');
      StatDetail.Description[1] := Language.Translate('STAT_DESC_SINGERS');
      StatDetail.Description[2] := Language.Translate('STAT_DESC_SONGS');
      StatDetail.Description[3] := Language.Translate('STAT_DESC_BANDS');

      StatDetail.DescriptionR[0] := Language.Translate('STAT_DESC_SCORES_REVERSED');
      StatDetail.DescriptionR[1] := Language.Translate('STAT_DESC_SINGERS_REVERSED');
      StatDetail.DescriptionR[2] := Language.Translate('STAT_DESC_SONGS_REVERSED');
      StatDetail.DescriptionR[3] := Language.Translate('STAT_DESC_BANDS_REVERSED');

      StatDetail.FormatStr[0] := Language.Translate('STAT_FORMAT_SCORES');
      StatDetail.FormatStr[1] := Language.Translate('STAT_FORMAT_SINGERS');
      StatDetail.FormatStr[2] := Language.Translate('STAT_FORMAT_SONGS');
      StatDetail.FormatStr[3] := Language.Translate('STAT_FORMAT_BANDS');

      StatDetail.PageStr := Language.Translate('STAT_PAGE');


      //Level Translations
      //Fill ILevel
      ILevel[0] := Language.Translate('OPTION_VALUE_EASY');
      ILevel[1] := Language.Translate('OPTION_VALUE_MEDIUM');
      ILevel[2] := Language.Translate('OPTION_VALUE_HARD');

      //Mode Translations
      //Fill IMode
      IMode[0] := Language.Translate('PARTY_MODE_CLASSIC');
      IMode[1] := Language.Translate('PARTY_MODE_CLASSIC_FREE');
      IMode[2] := Language.Translate('PARTY_MODE_TOURNAMENT');
      //IMode[3] := Language.Translate('PARTY_MODE_CHALLENGE'); //Hidden for the moment. Check in the future
    end;
  end;
end;

procedure TTheme.ThemeLoadBasic(Theme: TThemeBasic; const Name: string);
begin
  ThemeLoadBackground(Theme.Background, Name);
  ThemeLoadTexts(Theme.Text, Name + 'Text');
  ThemeLoadStatics(Theme.Statics, Name + 'Static');
  ThemeLoadButtonCollections(Theme.ButtonCollection, Name + 'ButtonCollection');

  LastThemeBasic := Theme;
end;

procedure TTheme.ThemeLoadBackground(var ThemeBackground: TThemeBackground; const Name: string);
var
  BGType: string;
  I: TBackgroundType;
  TempColor: integer;
begin
  Self.SetInheritance(Name+'Background');
  Self.ReadProperty(Name+'Background', 'Type', 'auto', BGType);
  BGType := LowerCase(BGType);

  ThemeBackground.BGType := bgtAuto;
  for I := Low(BGT_Names) to High(BGT_Names) do
  begin
    if (BGT_Names[I] = BGType) then
    begin
      ThemeBackground.BGType := I;
      Break;
    end;
  end;

  Self.ReadProperty(Name+'Background', 'Tex', '', ThemeBackground.Tex);
  Self.ReadProperty(Name+'Background', 'ColR', 1, TempColor);
  ThemeBackground.Color.R := TempColor;
  Self.ReadProperty(Name+'Background', 'ColG', 1, TempColor);
  ThemeBackground.Color.G := TempColor;
  Self.ReadProperty(Name+'Background', 'ColB', 1, TempColor);
  ThemeBackground.Color.B := TempColor;
  Self.ReadProperty(Name+'Background', 'Alpha', 1, ThemeBackground.Alpha);
end;

procedure TTheme.ThemeLoadText(var ThemeText: TThemeText; const Name: string);
var
  C: integer;
begin
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'X', 0, ThemeText.X);
  Self.ReadProperty(Name, 'Y', 0, ThemeText.Y);
  Self.ReadProperty(Name, 'W', 0, ThemeText.W);
  Self.ReadProperty(Name, 'Z', 0, ThemeText.Z);
  Self.ReadProperty(Name, 'ColR', 0, ThemeText.ColR);
  Self.ReadProperty(Name, 'ColG', 0, ThemeText.ColG);
  Self.ReadProperty(Name, 'ColB', 0, ThemeText.ColB);
  Self.ReadProperty(Name, 'Font', ftNormal, ThemeText.Font);
  Self.ReadProperty(Name, 'Size', 0, ThemeText.Size);
  Self.ReadProperty(Name, 'Align', 0, ThemeText.Align);
  Self.ReadProperty(Name, 'Text', '', ThemeText.Text);
  ThemeText.Text := ULanguage.Language.Translate(ThemeText.Text);

  Self.ReadProperty(Name, 'Color', '', ThemeText.Color);
  C := ColorExists(ThemeText.Color);
  if C >= 0 then
  begin
    ThemeText.ColR := Color[C].RGB.R;
    ThemeText.ColG := Color[C].RGB.G;
    ThemeText.ColB := Color[C].RGB.B;
  end;

  Self.ReadProperty(Name, 'DColor', '', ThemeText.DColor);
  C := ColorExists(ThemeText.DColor);
  if C >= 0 then
  begin
    ThemeText.DColR := Color[C].RGB.R;
    ThemeText.DColG := Color[C].RGB.G;
    ThemeText.DColB := Color[C].RGB.B;
  end;

  Self.ReadProperty(Name, 'Size', 0, ThemeText.Size);
  Self.ReadProperty(Name, 'Writable', false, ThemeText.Writable);
  Self.ReadProperty(Name, 'Reflection', false, ThemeText.Reflection);
  Self.ReadProperty(Name, 'ReflectionSpacing', 15, ThemeText.ReflectionSpacing);
end;

procedure TTheme.ThemeLoadTexts(var ThemeText: AThemeText; const Name: string);
var
  T: integer;
begin
  T := 1;
  while Self.SectionExists(Name + IntToStr(T)) do
  begin
    SetLength(ThemeText, T);
    ThemeLoadText(ThemeText[T-1], Name + IntToStr(T));
    Inc(T);
  end;
end;

procedure TTheme.ThemeLoadStatic(var ThemeStatic: TThemeStatic; const Name: string);
var
  C: integer;
  TextureType: string;
begin
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'Tex', '', ThemeStatic.Tex);
  Self.ReadProperty(Name, 'X', 0, ThemeStatic.X);
  Self.ReadProperty(Name, 'Y', 0, ThemeStatic.Y);
  Self.ReadProperty(Name, 'Z', 0, ThemeStatic.Z);
  Self.ReadProperty(Name, 'W', 0, ThemeStatic.W);
  Self.ReadProperty(Name, 'H', 0, ThemeStatic.H);
  Self.ReadProperty(Name, 'PaddingX', 0, ThemeStatic.PaddingX);
  Self.ReadProperty(Name, 'PaddingY', 0, ThemeStatic.PaddingY);
  Self.ReadProperty(Name, 'Alpha', 1, ThemeStatic.Alpha);
  Self.ReadProperty(Name, 'Type', '', TextureType);
  if TextureType = '' then
    ULog.Log.LogError('no texture type for ' + Name + ' found.', 'TTheme.ThemeLoadStatic');

  ThemeStatic.Typ := UTexture.ParseTextureType(TextureType, TEXTURE_TYPE_PLAIN);
  Self.ReadProperty(Name, 'Color', '', ThemeStatic.Color);
  C := ColorExists(ThemeStatic.Color);
  if C >= 0 then
  begin
    ThemeStatic.ColR := Color[C].RGB.R;
    ThemeStatic.ColG := Color[C].RGB.G;
    ThemeStatic.ColB := Color[C].RGB.B;
  end;
  Self.ReadProperty(Name, 'TexX1', 0, ThemeStatic.TexX1);
  Self.ReadProperty(Name, 'TexY1', 0, ThemeStatic.TexY1);
  Self.ReadProperty(Name, 'TexX2', 1, ThemeStatic.TexX2);
  Self.ReadProperty(Name, 'TexY2', 1, ThemeStatic.TexY2);
  Self.ReadProperty(Name, 'Reflection', false, ThemeStatic.Reflection);
  Self.ReadProperty(Name, 'ReflectionSpacing', 15, ThemeStatic.ReflectionSpacing);
end;

procedure TTheme.ThemeLoadStatics(var ThemeStatic: AThemeStatic; const Name: string);
var
  S: integer;
begin
  S := 1;
  while Self.SectionExists(Name + IntToStr(S)) do
  begin
    SetLength(ThemeStatic, S);
    ThemeLoadStatic(ThemeStatic[S-1], Name + IntToStr(S));
    Inc(S);
  end;
end;

//Button Collection Mod
procedure TTheme.ThemeLoadButtonCollection(var Collection: TThemeButtonCollection; const Name: string);
var T: integer;
begin
  //Load Collection Style
  ThemeLoadButton(Collection.Style, Name);

  //Load Other Attributes
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'FirstChild', 0, T);
  if (T > 0) And (T < 256) then
    Collection.FirstChild := T
  else
    Collection.FirstChild := 0;
end;

procedure TTheme.ThemeLoadButtonCollections(var Collections: AThemeButtonCollection; const Name: string);
var
  I: integer;
begin
  I := 1;
  while Self.SectionExists(Name + IntToStr(I)) do
  begin
    SetLength(Collections, I);
    ThemeLoadButtonCollection(Collections[I-1], Name + IntToStr(I));
    Inc(I);
  end;
end;
//End Button Collection Mod

procedure TTheme.ThemeLoadButton(var ThemeButton: TThemeButton; const Name: string; Collections: PAThemeButtonCollection);
var
  C, T, TLen: integer;
  TempString: string;
  Collections2: PAThemeButtonCollection;
begin
  if not Self.SectionExists(Name) then
  begin
    ThemeButton.Visible := False;
    exit;
  end;
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'Tex', '', ThemeButton.Tex);
  Self.ReadProperty(Name, 'X', 0, ThemeButton.X);
  Self.ReadProperty(Name, 'Y', 0, ThemeButton.Y);
  Self.ReadProperty(Name, 'Z', 0, ThemeButton.Z);
  Self.ReadProperty(Name, 'W', 0, ThemeButton.W);
  Self.ReadProperty(Name, 'H', 0, ThemeButton.H);
  Self.ReadProperty(Name, 'Type', '', TempString);
  if TempString = '' then
    ULog.Log.LogError('no texture type for ' + Name + ' found.', 'TTheme.ThemeLoadButton');

  ThemeButton.Typ := UTexture.ParseTextureType(TempString, TEXTURE_TYPE_PLAIN);
  Self.ReadProperty(Name, 'Reflection', false, ThemeButton.Reflection);
  Self.ReadProperty(Name, 'ReflectionSpacing', 15, ThemeButton.ReflectionSpacing);
  Self.ReadProperty(Name, 'ColR', 1, ThemeButton.ColR);
  Self.ReadProperty(Name, 'ColG', 1, ThemeButton.ColG);
  Self.ReadProperty(Name, 'ColB', 1, ThemeButton.ColB);
  Self.ReadProperty(Name, 'Int', 1, ThemeButton.Int);
  Self.ReadProperty(Name, 'DColR', 1, ThemeButton.DColR);
  Self.ReadProperty(Name, 'DColG', 1, ThemeButton.DColG);
  Self.ReadProperty(Name, 'DColB', 1, ThemeButton.DColB);
  Self.ReadProperty(Name, 'DInt', 1, ThemeButton.DInt);
  Self.ReadProperty(Name, 'Color', '', ThemeButton.Color);
  C := ColorExists(ThemeButton.Color);
  if C >= 0 then
  begin
    ThemeButton.ColR := Color[C].RGB.R;
    ThemeButton.ColG := Color[C].RGB.G;
    ThemeButton.ColB := Color[C].RGB.B;
  end;

  Self.ReadProperty(Name, 'DColor', '', ThemeButton.DColor);
  C := ColorExists(ThemeButton.DColor);
  if C >= 0 then
  begin
    ThemeButton.DColR := Color[C].RGB.R;
    ThemeButton.DColG := Color[C].RGB.G;
    ThemeButton.DColB := Color[C].RGB.B;
  end;
  Self.ReadProperty(Name, 'Visible', true, ThemeButton.Visible);
  Self.ReadProperty(Name, 'SelectH', ThemeButton.H, ThemeButton.SelectH);
  Self.ReadProperty(Name, 'SelectW', ThemeButton.W, ThemeButton.SelectW);
  Self.ReadProperty(Name, 'DeSelectReflectionSpacing', ThemeButton.Reflectionspacing, ThemeButton.DeSelectReflectionspacing);
  Self.ReadProperty(Name, 'Fade', true, ThemeButton.Fade);
  Self.ReadProperty(Name, 'FadeText', true, ThemeButton.FadeText);
  Self.ReadProperty(Name, 'FadeTex', '', ThemeButton.FadeTex);
  Self.ReadProperty(Name, 'FadeTexPos', 0, ThemeButton.FadeTexPos);
  if (ThemeButton.FadeTexPos > 4) or (ThemeButton.FadeTexPos < 0) then
    ThemeButton.FadeTexPos := 0;

  //Button Collection Mod
  Self.ReadProperty(Name, 'Parent', 0, T);

  //Set Collections to Last Basic Collections if no valid Value
  if (Collections = nil) then
    Collections2 := @LastThemeBasic.ButtonCollection
  else
    Collections2 := Collections;
  //Test for valid Value
  if (Collections2 <> nil) AND (T > 0) AND (T <= Length(Collections2^)) then
  begin
    Inc(Collections2^[T-1].ChildCount);
    ThemeButton.Parent := T;
  end
  else
    ThemeButton.Parent := 0;

  //Read ButtonTexts
  Self.ReadProperty(Name, 'Texts', 0, TLen);
  SetLength(ThemeButton.Text, TLen);
  for T := 1 to TLen do
    Self.ThemeLoadText(ThemeButton.Text[T - 1], Name+'Text'+IntToStr(T));
end;

procedure TTheme.ThemeLoadSelectSlide(var ThemeSelectS: TThemeSelectSlide; const Name: string);
var
  TempString: string;
begin
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'Text', '', TempString);
  ThemeSelectS.Text := ULanguage.Language.Translate(TempString);

  Self.ReadProperty(Name, 'Tex', '', ThemeSelectS.Tex);
  Self.ReadProperty(Name, 'Type', '', TempString);
  ThemeSelectS.Typ := UTexture.ParseTextureType(TempString, TEXTURE_TYPE_PLAIN);
  if TempString = '' then
    ULog.Log.LogError('no texture type for ' + Name + ' found.', 'TTheme.ThemeLoadSelectSlide');

  Self.ReadProperty(Name, 'TexSBG', '', ThemeSelectS.TexSBG);
  Self.ReadProperty(Name, 'TypeSBG', '', TempString);
  ThemeSelectS.TypSBG := UTexture.ParseTextureType(TempString, TEXTURE_TYPE_PLAIN);

  Self.ReadProperty(Name, 'X', 0, ThemeSelectS.X);
  Self.ReadProperty(Name, 'Y', 0, ThemeSelectS.Y);
  Self.ReadProperty(Name, 'Z', 0, ThemeSelectS.Z);
  Self.ReadProperty(Name, 'W', 0, ThemeSelectS.W);
  Self.ReadProperty(Name, 'H', 0, ThemeSelectS.H);
  Self.ReadProperty(Name, 'TextSize', 30, ThemeSelectS.TextSize);
  Self.ReadProperty(Name, 'SkipX', 0, ThemeSelectS.SkipX);
  Self.ReadProperty(Name, 'SBGW', 400, ThemeSelectS.SBGW);

  Self.ReadProperty(Name, 'Color', '', TempString);
  LoadColor(ThemeSelectS.ColR, ThemeSelectS.ColG,  ThemeSelectS.ColB, TempString);
  Self.ReadProperty(Name, 'Int', 1, ThemeSelectS.Int);
  Self.ReadProperty(Name, 'DColor', '', TempString);
  LoadColor(ThemeSelectS.DColR, ThemeSelectS.DColG,  ThemeSelectS.DColB, TempString);
  Self.ReadProperty(Name, 'DInt', 1, ThemeSelectS.DInt);

  Self.ReadProperty(Name, 'TColor', '', TempString);
  LoadColor(ThemeSelectS.TColR, ThemeSelectS.TColG,  ThemeSelectS.TColB, TempString);
  Self.ReadProperty(Name, 'TInt', 1, ThemeSelectS.TInt);
  Self.ReadProperty(Name, 'TDColor', '', TempString);
  LoadColor(ThemeSelectS.TDColR, ThemeSelectS.TDColG,  ThemeSelectS.TDColB, TempString);
  Self.ReadProperty(Name, 'TDInt', 1, ThemeSelectS.TDInt);

  Self.ReadProperty(Name, 'SBGColor', '', TempString);
  LoadColor(ThemeSelectS.SBGColR, ThemeSelectS.SBGColG,  ThemeSelectS.SBGColB, TempString);
  Self.ReadProperty(Name, 'SBGInt', 1, ThemeSelectS.SBGInt);
  Self.ReadProperty(Name, 'SBGDColor', '', TempString);
  LoadColor(ThemeSelectS.SBGDColR, ThemeSelectS.SBGDColG,  ThemeSelectS.SBGDColB, TempString);
  Self.ReadProperty(Name, 'SBGDInt', 1, ThemeSelectS.SBGDInt);

  Self.ReadProperty(Name, 'STColor', '', TempString);
  LoadColor(ThemeSelectS.STColR, ThemeSelectS.STColG,  ThemeSelectS.STColB, TempString);
  Self.ReadProperty(Name, 'STInt', 1, ThemeSelectS.STInt);
  Self.ReadProperty(Name, 'STDColor', '', TempString);
  LoadColor(ThemeSelectS.STDColR, ThemeSelectS.STDColG,  ThemeSelectS.STDColB, TempString);
  Self.ReadProperty(Name, 'STDInt', 1, ThemeSelectS.STDInt);


  Self.ReadProperty(Name, 'ShowArrows', true, ThemeSelectS.showArrows);
  Self.ReadProperty(Name, 'OneItemOnly', true, ThemeSelectS.oneItemOnly);
end;

procedure TTheme.ThemeLoadEqualizer(var ThemeEqualizer: TThemeEqualizer; const Name: string);
var
  I: integer;
  TempString: string;
begin
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'Visible', true, ThemeEqualizer.Visible);
  Self.ReadProperty(Name, 'Direction', true, ThemeEqualizer.Direction);
  Self.ReadProperty(Name, 'Alpha', 1, ThemeEqualizer.Alpha);
  Self.ReadProperty(Name, 'Space', 1, ThemeEqualizer.Space);
  Self.ReadProperty(Name, 'X', 0, ThemeEqualizer.X);
  Self.ReadProperty(Name, 'Y', 0, ThemeEqualizer.Y);
  Self.ReadProperty(Name, 'Z', 1, ThemeEqualizer.Z);
  Self.ReadProperty(Name, 'W', 8, ThemeEqualizer.W);
  Self.ReadProperty(Name, 'H', 8, ThemeEqualizer.H);
  Self.ReadProperty(Name, 'Bands', 5, ThemeEqualizer.Bands);
  Self.ReadProperty(Name, 'Length', 12, ThemeEqualizer.Length);
  Self.ReadProperty(Name, 'Reflection', false, ThemeEqualizer.Reflection);
  Self.ReadProperty(Name, 'ReflectionSpacing', 15, ThemeEqualizer.ReflectionSpacing);
  Self.ReadProperty(Name, 'Color', 'Black', TempString);
  I := ColorExists(TempString);
  if I >= 0 then
  begin
    ThemeEqualizer.ColR := Color[I].RGB.R;
    ThemeEqualizer.ColG := Color[I].RGB.G;
    ThemeEqualizer.ColB := Color[I].RGB.B;
  end
  else
  begin
    ThemeEqualizer.ColR := 0;
    ThemeEqualizer.ColG := 0;
    ThemeEqualizer.ColB := 0;
  end;
end;

procedure TTheme.ThemeLoadLyricBar(var ThemeLyricBar: TThemeLyricBar; Name: string);
begin
  Self.ThemeLoadPosition(ThemeLyricBar.Upper, Name);
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'YOffset', 0, ThemeLyricBar.YOffset); //Y jukebox lyric position offset
  Self.ReadProperty(Name, 'IndicatorYOffset', 0, ThemeLyricBar.IndicatorYOffset);
  Name := ReplaceStr(Name, 'Upper', 'Lower');
  Self.ThemeLoadPosition(ThemeLyricBar.Lower, Name);
end;

procedure TTheme.ThemeLoadPosition(var ThemePosition: TThemePosition; const Name: string);
begin
  Self.SetInheritance(Name);
  Self.ReadProperty(Name, 'H', 0, ThemePosition.H);
  Self.ReadProperty(Name, 'W', 0, ThemePosition.W);
  Self.ReadProperty(Name, 'X', 0, ThemePosition.X);
  Self.ReadProperty(Name, 'Y', 0, ThemePosition.Y);
end;

procedure TTheme.LoadColors;
var
  SL:     TStringList;
  C:      integer;
  S:      string;
begin
  SL := TStringList.Create();
  Self.SetInheritance('Colors');
  if Self.Inheritance[0].Base then
    Self.ThemeBase.ReadSection('Colors', SL)
  else
    Self.ThemeIni.ReadSection('Colors', SL);

  // normal colors
  SetLength(Color, SL.Count);
  for C := 0 to SL.Count-1 do
  begin
    Color[C].Name := SL.Strings[C];

    Self.ReadProperty('Colors', SL.Strings[C], '', S);

    Color[C].RGB.R := StrToInt(Copy(S, 1, Pos(' ' , S)-1))/255;
    Delete(S, 1, Pos(' ', S));

    Color[C].RGB.G := StrToInt(Copy(S, 1, Pos(' ' , S)-1))/255;
    Delete(S, 1, Pos(' ', S));

    Color[C].RGB.B := StrToInt(S)/255;
  end;

  // skin color
  SetLength(Color, SL.Count + 3);
  C := SL.Count;
  Color[C].Name := 'ColorDark';
  Color[C].RGB := GetSystemColor(Skin.Color);  //Ini.Color);

  C := C+1;
  Color[C].Name := 'ColorLight';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  C := C+1;
  Color[C].Name := 'ColorLightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  LastC := C;

  // players colors
  SetLength(Color, Length(Color)+18);

  LoadPlayersColors;

  SL.Free;

end;

procedure LoadPlayersColors;
var
  C:      integer;
begin

  C := LastC;

  // P1
  C := C+1;
  Color[C].Name := 'P1Dark';
  Color[C].RGB := GetPlayerColor(Ini.PlayerColor[0]);

  C := C+1;
  Color[C].Name := 'P1Light';
  Color[C].RGB := GetPlayerLightColor(Ini.PlayerColor[0]);

  C := C+1;
  Color[C].Name := 'P1Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  // P2
  C := C+1;
  Color[C].Name := 'P2Dark';
  Color[C].RGB := GetPlayerColor(Ini.PlayerColor[1]);

  C := C+1;
  Color[C].Name := 'P2Light';
  Color[C].RGB := GetPlayerLightColor(Ini.PlayerColor[1]);

  C := C+1;
  Color[C].Name := 'P2Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  // P3
  C := C+1;
  Color[C].Name := 'P3Dark';
  Color[C].RGB := GetPlayerColor(Ini.PlayerColor[2]);

  C := C+1;
  Color[C].Name := 'P3Light';
  Color[C].RGB := GetPlayerLightColor(Ini.PlayerColor[2]);

  C := C+1;
  Color[C].Name := 'P3Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  // P4
  C := C+1;
  Color[C].Name := 'P4Dark';
  Color[C].RGB := GetPlayerColor(Ini.PlayerColor[3]);

  C := C+1;
  Color[C].Name := 'P4Light';
  Color[C].RGB := GetPlayerLightColor(Ini.PlayerColor[3]);

  C := C+1;
  Color[C].Name := 'P4Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  // P5
  C := C+1;
  Color[C].Name := 'P5Dark';
  Color[C].RGB := GetPlayerColor(Ini.PlayerColor[4]);

  C := C+1;
  Color[C].Name := 'P5Light';
  Color[C].RGB := GetPlayerLightColor(Ini.PlayerColor[4]);

  C := C+1;
  Color[C].Name := 'P5Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  // P6
  C := C+1;
  Color[C].Name := 'P6Dark';
  Color[C].RGB := GetPlayerColor(Ini.PlayerColor[5]);

  C := C+1;
  Color[C].Name := 'P6Light';
  Color[C].RGB := GetPlayerLightColor(Ini.PlayerColor[5]);

  C := C+1;
  Color[C].Name := 'P6Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

end;

procedure LoadTeamsColors;
var
  C:      integer;
begin

  C := LastC;

  // P1
  C := C+1;
  Color[C].Name := 'P1Dark';
  Color[C].RGB := GetPlayerColor(Ini.TeamColor[0]);

  C := C+1;
  Color[C].Name := 'P1Light';
  Color[C].RGB := GetPlayerLightColor(Ini.TeamColor[0]);

  C := C+1;
  Color[C].Name := 'P1Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  // P2
  C := C+1;
  Color[C].Name := 'P2Dark';
  Color[C].RGB := GetPlayerColor(Ini.TeamColor[1]);

  C := C+1;
  Color[C].Name := 'P2Light';
  Color[C].RGB := GetPlayerLightColor(Ini.TeamColor[1]);

  C := C+1;
  Color[C].Name := 'P2Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

  // P3
  C := C+1;
  Color[C].Name := 'P3Dark';
  Color[C].RGB := GetPlayerColor(Ini.TeamColor[2]);

  C := C+1;
  Color[C].Name := 'P3Light';
  Color[C].RGB := GetPlayerLightColor(Ini.TeamColor[2]);

  C := C+1;
  Color[C].Name := 'P3Lightest';
  Color[C].RGB := ColorSqrt(Color[C-1].RGB);

end;

function ColorExists(Name: string): integer;
var
  C: integer;
begin
  Result := -1;
  for C := 0 to High(Color) do
    if Color[C].Name = Name then
      Result := C;
end;

procedure LoadColor(var R, G, B: real; ColorName: string);
var
  C: integer;
begin
  C := ColorExists(ColorName);
  if C >= 0 then
  begin
    R := Color[C].RGB.R;
    G := Color[C].RGB.G;
    B := Color[C].RGB.B;
  end;
end;

function GetSystemColor(Color: integer): TRGB;
begin
  case Color of
    0:  begin
          // blue
          Result.R := 71/255;
          Result.G := 175/255;
          Result.B := 247/255;
        end;
    1:  begin
          // green
          Result.R := 63/255;
          Result.G := 191/255;
          Result.B := 63/255;
        end;
    2:  begin
          // pink
          Result.R := 255/255;
{          Result.G := 63/255;
          Result.B := 192/255;}
          Result.G := 175/255;
          Result.B := 247/255;
        end;
    3:  begin
          // red
          Result.R := 247/255;
          Result.G := 71/255;
          Result.B := 71/255;
        end;
        //'Violet', 'Orange', 'Yellow', 'Brown', 'Black'
        //New Theme-Color Patch
    4:  begin
          // violet
          Result.R := 212/255;
          Result.G := 71/255;
          Result.B := 247/255;
        end;
    5:  begin
          // orange
          Result.R := 247/255;
          Result.G := 144/255;
          Result.B := 71/255;
        end;
    6:  begin
          // yellow
          Result.R := 230/255;
          Result.G := 230/255;
          Result.B := 95/255;
        end;
    7:  begin
          // Magenta
          Result.R := 215/255;
          Result.G := 0/255;
          Result.B := 111/255;
        end;
    8:  begin
          // brown
          Result.R := 192/255;
          Result.G := 127/255;
          Result.B := 31/255;
        end;
    9:  begin
          // black
          Result.R := 0;
          Result.G := 0;
          Result.B := 0;
        end;
    else
        begin
          // blue
          Result.R := 71/255;
          Result.G := 175/255;
          Result.B := 247/255;
        end;
    //New Theme-Color Patch End

    end;
end;

function GetPlayerColor(Color: integer): TRGB;
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
      Result.G := 190/255;
      Result.B := 0;
    end;
    4: //yellow
    begin
      Result.R := 255/255;
      Result.G := 255/255;
      Result.B := 0;
    end;
    5: //Magenta
    begin
      Result.R := 215/255;
      Result.G := 0/255;
      Result.B := 111;
    end;
    6: //orange
    begin
      Result.R := 255/255;
      Result.G := 127/255;
      Result.B := 0;
    end;
    7: //pink
    begin
      Result.R := 255/255;
      Result.G := 110/255;
      Result.B := 180/255;
    end;
    8: //purple
    begin
      Result.R := 175/255;
      Result.G := 0;
      Result.B := 210/255;
    end;
    9: //gold
    begin
      Result.R := 218/255;
      Result.G := 165/255;
      Result.B := 32/255;
    end;
    10: //gray
    begin
      Result.R := 150/255;
      Result.G := 150/255;
      Result.B := 150/255;
    end;
    11: //dark blue
    begin
      Result.R := 0;
      Result.G := 0;
      Result.B := 220/255;
    end;
    12: //sky
    begin
      Result.R := 0;
      Result.G := 110/255;
      Result.B := 210/255;
    end;
    13: //cyan
    begin
      Result.R := 0/255;
      Result.G := 215/255;
      Result.B := 215/255;
    end;
    14: //flame
    begin
      Result.R := 210/255;
      Result.G := 70/255;
      Result.B := 0/255;
    end;
    15: //orchid
    begin
      Result.R := 210/255;
      Result.G := 0;
      Result.B := 210/255;
    end;
    16: //harlequin
    begin
      Result.R := 110/255;
      Result.G := 210/255;
      Result.B := 0;
    end;
    17: //lime
    begin
      Result.R := 160/255;
      Result.G := 210/255;
      Result.B := 0;
    end;
    else
    begin
      Result.R := 5/255;
      Result.G := 153/255;
      Result.B := 204/255;
    end;
  end;
end;

function GetPlayerLightColor(Color: integer): TRGB;
begin
  case (Color) of
    1://blue
    begin
      Result.R := 145/255;
      Result.G := 215/255;
      Result.B := 240/255;
    end;
    2: //red
    begin
      Result.R := 245/255;
      Result.G := 162/255;
      Result.B := 162/255;
    end;
    3: //green
    begin
      Result.R := 152/255;
      Result.G := 250/255;
      Result.B := 153/255;
    end;
    4: //yellow
    begin
      Result.R := 255/255;
      Result.G := 246/255;
      Result.B := 143/255;
    end;
    5: //Magenta
    begin
      Result.R := 215/255;
      Result.G := 0/255;
      Result.B := 111/255;
    end;
    6: //orange
    begin
      Result.R := 255/255;
      Result.G := 204/255;
      Result.B := 156/255;
    end;
    7: //pink
    begin
      Result.R := 255/255;
      Result.G := 192/255;
      Result.B := 205/255;
    end;
    8: //violet
    begin
      Result.R := 240/255;
      Result.G := 170/255;
      Result.B := 255/255;
    end;
    9: //gold
    begin
      Result.R := 255/255;
      Result.G := 214/255;
      Result.B := 118/255;
    end;
    10: //gray
    begin
      Result.R := 220/255;
      Result.G := 220/255;
      Result.B := 220/255;
    end;
    11: //dark blue
    begin
      Result.R := 90/255;
      Result.G := 90/255;
      Result.B := 255/255;
    end;
    12: //sky
    begin
      Result.R := 80/255;
      Result.G := 160/255;
      Result.B := 235/255;
    end;
    13: //cyan
    begin
      Result.R := 150/255;
      Result.G := 230/255;
      Result.B := 230/255;
    end;
    14: //flame
    begin
      Result.R := 230/255;
      Result.G := 130/255;
      Result.B := 80/255;
    end;
    15: //orchid
    begin
      Result.R := 230/255;
      Result.G := 100/255;
      Result.B := 230/255;
    end;
    16: //harlequin
    begin
      Result.R := 160/255;
      Result.G := 230/255;
      Result.B := 90/255;
    end;
    17: //lime
    begin
      Result.R := 190/255;
      Result.G := 230/255;
      Result.B := 100/255;
    end;
    else
    begin
      Result.R := 145/255;
      Result.G := 215/255;
      Result.B := 240/255;
    end;
  end;
end;

function ColorSqrt(RGB: TRGB): TRGB;
begin
  Result.R := sqrt(RGB.R);
  Result.G := sqrt(RGB.G);
  Result.B := sqrt(RGB.B);
end;

function GetLyricColor(Color: integer): TRGB;
begin
  case Color of
    0:  begin
          // blue
          Result.R := 0;
          Result.G := 150/255;
          Result.B := 255/255;
        end;
    1:  begin
          // green
          Result.R := 63/255;
          Result.G := 191/255;
          Result.B := 63/255;
        end;
    2:  begin
          // pink
          Result.R := 255/255;
          Result.G := 63/255;
          Result.B := 192/255;{
          Result.G := 175/255;
          Result.B := 247/255; }
        end;
    3:  begin
          // red
          Result.R := 220/255;
          Result.G := 0;
          Result.B := 0;
        end;
        //'Violet', 'Orange', 'Yellow', 'Brown', 'Black'
        //New Theme-Color Patch
    4:  begin
          // violet
          Result.R := 180/255;
          Result.G := 63/255;
          Result.B := 230/255;
        end;
    5:  begin
          // orange
          Result.R := 255/255;
          Result.G := 144/255;
          Result.B := 0;
        end;
    6:  begin
          // yellow
          Result.R := 255/255;
          Result.G := 255/255;
          Result.B := 0;
        end;
    7: //Magenta
    begin
      Result.R := 215/255;
      Result.G := 0/255;
      Result.B := 111/255;
    end;
    8:  begin
          // brown
          Result.R := 192/255;
          Result.G := 127/255;
          Result.B := 31/255;
        end;
    9:  begin
          // black
          Result.R := 0;
          Result.G := 0;
          Result.B := 0;
        end;
        //New Theme-Color Patch End
        // daniel20 colors
    10:  //Turquoise
        begin
          Result.R := 0/255;
          Result.G := 255/255;
          Result.B := 230/255;
        end;
    11: //Salmon
        begin
          Result.R := 255/255;
          Result.G := 127/255;
          Result.B := 102/255;
        end;
    12: //GreenYellow
        begin
          Result.R := 153/255;
          Result.G := 255/255;
          Result.B := 102/255;
        end;
    13: //Lavender
        begin
          Result.R := 204/255;
          Result.G := 204/255;
          Result.B := 255/255;
        end;
    14: //Beige
        begin
          Result.R := 255/255;
          Result.G := 230/255;
          Result.B := 204/255;
        end;
    15: //Teal
        begin
          Result.R := 51/255;
          Result.G := 153/255;
          Result.B := 153/255;
        end;
    16: //Orchid
        begin
          Result.R := 153/255;
          Result.G := 0;
          Result.B := 204/255;
        end;
    17: //SteelBlue
        begin
          Result.R := 51/255;
          Result.G := 102/255;
          Result.B := 153/255;
        end;
    18: //Plum
        begin
          Result.R := 255/255;
          Result.G := 153/255;
          Result.B := 255/255;
        end;
    19: //Chocolate
        begin
          Result.R := 138/255;
          Result.G := 92/255;
          Result.B := 46/255;
        end;
    20: //Gold
        begin
          Result.R := 255/255;
          Result.G := 204/255;
          Result.B := 51/255;
        end;
    else begin
          // blue
          Result.R := 0;
          Result.G := 150/255;
          Result.B := 255/255;
        end;
    end;
end;

function GetLyricBarColor(Color: integer): TRGB;
begin
  Result := GetPlayerColor(Color);
end;

procedure TTheme.ThemePartyLoad;
var
  TempString: string;
begin
  //Party Screens:
  //Party NewRound
  ThemeLoadBasic(PartyNewRound, 'PartyNewRound');

  ThemeLoadText (PartyNewRound.TextRound1, 'PartyNewRoundTextRound1');
  ThemeLoadText (PartyNewRound.TextRound2, 'PartyNewRoundTextRound2');
  ThemeLoadText (PartyNewRound.TextRound3, 'PartyNewRoundTextRound3');
  ThemeLoadText (PartyNewRound.TextRound4, 'PartyNewRoundTextRound4');
  ThemeLoadText (PartyNewRound.TextRound5, 'PartyNewRoundTextRound5');
  ThemeLoadText (PartyNewRound.TextRound6, 'PartyNewRoundTextRound6');
  ThemeLoadText (PartyNewRound.TextRound7, 'PartyNewRoundTextRound7');
  ThemeLoadText (PartyNewRound.TextWinner1, 'PartyNewRoundTextWinner1');
  ThemeLoadText (PartyNewRound.TextWinner2, 'PartyNewRoundTextWinner2');
  ThemeLoadText (PartyNewRound.TextWinner3, 'PartyNewRoundTextWinner3');
  ThemeLoadText (PartyNewRound.TextWinner4, 'PartyNewRoundTextWinner4');
  ThemeLoadText (PartyNewRound.TextWinner5, 'PartyNewRoundTextWinner5');
  ThemeLoadText (PartyNewRound.TextWinner6, 'PartyNewRoundTextWinner6');
  ThemeLoadText (PartyNewRound.TextWinner7, 'PartyNewRoundTextWinner7');
  ThemeLoadText (PartyNewRound.TextNextRound, 'PartyNewRoundTextNextRound');
  ThemeLoadText (PartyNewRound.TextNextRoundNo, 'PartyNewRoundTextNextRoundNo');
  ThemeLoadText (PartyNewRound.TextNextPlayer1, 'PartyNewRoundTextNextPlayer1');
  ThemeLoadText (PartyNewRound.TextNextPlayer2, 'PartyNewRoundTextNextPlayer2');
  ThemeLoadText (PartyNewRound.TextNextPlayer3, 'PartyNewRoundTextNextPlayer3');

  ThemeLoadStatic (PartyNewRound.StaticRound1, 'PartyNewRoundStaticRound1');
  ThemeLoadStatic (PartyNewRound.StaticRound2, 'PartyNewRoundStaticRound2');
  ThemeLoadStatic (PartyNewRound.StaticRound3, 'PartyNewRoundStaticRound3');
  ThemeLoadStatic (PartyNewRound.StaticRound4, 'PartyNewRoundStaticRound4');
  ThemeLoadStatic (PartyNewRound.StaticRound5, 'PartyNewRoundStaticRound5');
  ThemeLoadStatic (PartyNewRound.StaticRound6, 'PartyNewRoundStaticRound6');
  ThemeLoadStatic (PartyNewRound.StaticRound7, 'PartyNewRoundStaticRound7');

  ThemeLoadText (PartyNewRound.TextScoreTeam1, 'PartyNewRoundTextScoreTeam1');
  ThemeLoadText (PartyNewRound.TextScoreTeam2, 'PartyNewRoundTextScoreTeam2');
  ThemeLoadText (PartyNewRound.TextScoreTeam3, 'PartyNewRoundTextScoreTeam3');
  ThemeLoadText (PartyNewRound.TextNameTeam1, 'PartyNewRoundTextNameTeam1');
  ThemeLoadText (PartyNewRound.TextNameTeam2, 'PartyNewRoundTextNameTeam2');
  ThemeLoadText (PartyNewRound.TextNameTeam3, 'PartyNewRoundTextNameTeam3');

  ThemeLoadText (PartyNewRound.TextTeam1Players, 'PartyNewRoundTextTeam1Players');
  ThemeLoadText (PartyNewRound.TextTeam2Players, 'PartyNewRoundTextTeam2Players');
  ThemeLoadText (PartyNewRound.TextTeam3Players, 'PartyNewRoundTextTeam3Players');

  ThemeLoadStatic (PartyNewRound.StaticTeam1, 'PartyNewRoundStaticTeam1');
  ThemeLoadStatic (PartyNewRound.StaticTeam2, 'PartyNewRoundStaticTeam2');
  ThemeLoadStatic (PartyNewRound.StaticTeam3, 'PartyNewRoundStaticTeam3');
  ThemeLoadStatic (PartyNewRound.StaticNextPlayer1, 'PartyNewRoundStaticNextPlayer1');
  ThemeLoadStatic (PartyNewRound.StaticNextPlayer2, 'PartyNewRoundStaticNextPlayer2');
  ThemeLoadStatic (PartyNewRound.StaticNextPlayer3, 'PartyNewRoundStaticNextPlayer3');

  //Party Score
  ThemeLoadBasic(PartyScore, 'PartyScore');

  ThemeLoadText (PartyScore.TextScoreTeam1, 'PartyScoreTextScoreTeam1');
  ThemeLoadText (PartyScore.TextScoreTeam2, 'PartyScoreTextScoreTeam2');
  ThemeLoadText (PartyScore.TextScoreTeam3, 'PartyScoreTextScoreTeam3');
  ThemeLoadText (PartyScore.TextNameTeam1, 'PartyScoreTextNameTeam1');
  ThemeLoadText (PartyScore.TextNameTeam2, 'PartyScoreTextNameTeam2');
  ThemeLoadText (PartyScore.TextNameTeam3, 'PartyScoreTextNameTeam3');

  ThemeLoadStatic (PartyScore.StaticTeam1, 'PartyScoreStaticTeam1');
  ThemeLoadStatic (PartyScore.StaticTeam1BG, 'PartyScoreStaticTeam1BG');
  ThemeLoadStatic (PartyScore.StaticTeam1Deco, 'PartyScoreStaticTeam1Deco');
  ThemeLoadStatic (PartyScore.StaticTeam2, 'PartyScoreStaticTeam2');
  ThemeLoadStatic (PartyScore.StaticTeam2BG, 'PartyScoreStaticTeam2BG');
  ThemeLoadStatic (PartyScore.StaticTeam2Deco, 'PartyScoreStaticTeam2Deco');
  ThemeLoadStatic (PartyScore.StaticTeam3, 'PartyScoreStaticTeam3');
  ThemeLoadStatic (PartyScore.StaticTeam3BG, 'PartyScoreStaticTeam3BG');
  ThemeLoadStatic (PartyScore.StaticTeam3Deco, 'PartyScoreStaticTeam3Deco');

  //Load Party Score DecoTextures Object
  Self.SetInheritance('PartyScoreDecoTextures');
  Self.ReadProperty('PartyScoreDecoTextures', 'ChangeTextures', false, PartyScore.DecoTextures.ChangeTextures);
  Self.ReadProperty('PartyScoreDecoTextures', 'FirstColor', 'Black', PartyScore.DecoTextures.FirstColor);
  Self.ReadProperty('PartyScoreDecoTextures', 'FirstTexture', '', PartyScore.DecoTextures.FirstTexture);
  Self.ReadProperty('PartyScoreDecoTextures', 'FirstTyp', '', TempString);
  PartyScore.DecoTextures.FirstTyp :=  ParseTextureType(TempString, TEXTURE_TYPE_COLORIZED);
  Self.ReadProperty('PartyScoreDecoTextures', 'SecondColor', 'Black', PartyScore.DecoTextures.SecondColor);
  Self.ReadProperty('PartyScoreDecoTextures', 'SecondTexture', '', PartyScore.DecoTextures.SecondTexture);
  Self.ReadProperty('PartyScoreDecoTextures', 'SecondTyp', '', TempString);
  PartyScore.DecoTextures.SecondTyp :=  ParseTextureType(TempString, TEXTURE_TYPE_COLORIZED);
  Self.ReadProperty('PartyScoreDecoTextures', 'ThirdColor', 'Black', PartyScore.DecoTextures.ThirdColor);
  Self.ReadProperty('PartyScoreDecoTextures', 'ThirdTexture', '', PartyScore.DecoTextures.ThirdTexture);
  Self.ReadProperty('PartyScoreDecoTextures', 'ThirdTyp', '', TempString);
  PartyScore.DecoTextures.ThirdTyp :=  ParseTextureType(TempString, TEXTURE_TYPE_COLORIZED);

  ThemeLoadText (PartyScore.TextWinner, 'PartyScoreTextWinner');

  //Party Win
  ThemeLoadBasic(PartyWin, 'PartyWin');

  ThemeLoadText (PartyWin.TextScoreTeam1,    'PartyWinTextScoreTeam1');
  ThemeLoadText (PartyWin.TextScoreTeam2,    'PartyWinTextScoreTeam2');
  ThemeLoadText (PartyWin.TextScoreTeam3,    'PartyWinTextScoreTeam3');
  ThemeLoadText (PartyWin.TextNameTeam1,     'PartyWinTextNameTeam1');
  ThemeLoadText (PartyWin.TextNameTeam2,     'PartyWinTextNameTeam2');
  ThemeLoadText (PartyWin.TextNameTeam3,     'PartyWinTextNameTeam3');

  ThemeLoadStatic (PartyWin.StaticTeam1,     'PartyWinStaticTeam1');
  ThemeLoadStatic (PartyWin.StaticTeam1BG,   'PartyWinStaticTeam1BG');
  ThemeLoadStatic (PartyWin.StaticTeam1Deco, 'PartyWinStaticTeam1Deco');
  ThemeLoadStatic (PartyWin.StaticTeam2,     'PartyWinStaticTeam2');
  ThemeLoadStatic (PartyWin.StaticTeam2BG,   'PartyWinStaticTeam2BG');
  ThemeLoadStatic (PartyWin.StaticTeam2Deco, 'PartyWinStaticTeam2Deco');
  ThemeLoadStatic (PartyWin.StaticTeam3,     'PartyWinStaticTeam3');
  ThemeLoadStatic (PartyWin.StaticTeam3BG,   'PartyWinStaticTeam3BG');
  ThemeLoadStatic (PartyWin.StaticTeam3Deco, 'PartyWinStaticTeam3Deco');

  ThemeLoadText (PartyWin.TextWinner,        'PartyWinTextWinner');
end;

procedure TTheme.ThemeScoreLoad;
var
  I: integer;
  prefix: string;
begin
  // Score
  ThemeLoadBasic(Score, 'Score');

  ThemeLoadText(Score.TextArtist, 'ScoreTextArtist');
  ThemeLoadText(Score.TextTitle, 'ScoreTextTitle');
  ThemeLoadText(Score.TextArtistTitle, 'ScoreTextArtistTitle');

  prefix := '';
  if not((Ini.Players < 3) or (Ini.Screens = 1)) then
  begin
    // 4 players 1 screen
    if (Ini.Players = 3) then
      prefix := 'FourP';

    // 6 players 1 screen
    if (Ini.Players = 4) then
      prefix := 'SixP';
  end;

  for I := 1 to 6 do
  begin
    ThemeLoadStatics(Score.PlayerStatic[I],        'Score' + prefix + 'Player' + IntToStr(I) + 'Static');
    ThemeLoadTexts(Score.PlayerTexts[I],           'Score' + prefix + 'Player' + IntToStr(I) + 'Text');
    ThemeLoadStatic(Score.AvatarStatic[I],         'Score' + prefix + 'Player' + IntToStr(I) + 'Avatar');

    ThemeLoadText(Score.TextName[I],               'Score' + prefix + 'TextName'             + IntToStr(I));
    ThemeLoadText(Score.TextScore[I],              'Score' + prefix + 'TextScore'            + IntToStr(I));
    ThemeLoadText(Score.TextNotes[I],              'Score' + prefix + 'TextNotes'            + IntToStr(I));
    ThemeLoadText(Score.TextNotesScore[I],         'Score' + prefix + 'TextNotesScore'       + IntToStr(I));
    ThemeLoadText(Score.TextLineBonus[I],          'Score' + prefix + 'TextLineBonus'        + IntToStr(I));
    ThemeLoadText(Score.TextLineBonusScore[I],     'Score' + prefix + 'TextLineBonusScore'   + IntToStr(I));
    ThemeLoadText(Score.TextGoldenNotes[I],        'Score' + prefix + 'TextGoldenNotes'      + IntToStr(I));
    ThemeLoadText(Score.TextGoldenNotesScore[I],   'Score' + prefix + 'TextGoldenNotesScore' + IntToStr(I));
    ThemeLoadText(Score.TextTotal[I],              'Score' + prefix + 'TextTotal'            + IntToStr(I));
    ThemeLoadText(Score.TextTotalScore[I],         'Score' + prefix + 'TextTotalScore'       + IntToStr(I));

    ThemeLoadStatic(Score.StaticBoxLightest[I],    'Score' + prefix + 'StaticBoxLightest'    + IntToStr(I));
    ThemeLoadStatic(Score.StaticBoxLight[I],       'Score' + prefix + 'StaticBoxLight'       + IntToStr(I));
    ThemeLoadStatic(Score.StaticBoxDark[I],        'Score' + prefix + 'StaticBoxDark'        + IntToStr(I));

    ThemeLoadStatic(Score.StaticBackLevel[I],      'Score' + prefix + 'StaticBackLevel'      + IntToStr(I));
    ThemeLoadStatic(Score.StaticBackLevelRound[I], 'Score' + prefix + 'StaticBackLevelRound' + IntToStr(I));
    ThemeLoadStatic(Score.StaticLevel[I],          'Score' + prefix + 'StaticLevel'          + IntToStr(I));
    ThemeLoadStatic(Score.StaticLevelRound[I],     'Score' + prefix + 'StaticLevelRound'     + IntToStr(I));
    ThemeLoadStatic(Score.StaticRatings[I],        'Score' + prefix + 'StaticRatingPicture'  + IntToStr(I));
  end;
end;

procedure TTheme.ThemeSongLoad;
var
  C: integer;
  prefix, TempString: string;
begin
  prefix := '';
  case (TSongMenuMode(Ini.SongMenu)) of
    smRoulette: prefix := 'Roulette';
    smChessboard: prefix := 'Chessboard';
    smCarousel: prefix := 'Carousel';
    smSlotMachine: prefix := 'SlotMachine';
    smSlide: prefix := 'Slide';
    smList: prefix := 'List';
    smMosaic: prefix := 'Mosaic';
  end;
  // Song
  ThemeLoadBasic(Song, 'Song' + prefix);

  ThemeLoadText(Song.TextNoSongs, 'SongTextNoSongs');
  ThemeLoadText(Song.TextArtist, 'Song' + prefix + 'TextArtist');
  ThemeLoadText(Song.TextTitle, 'Song' + prefix + 'TextTitle');
  ThemeLoadText(Song.TextNumber, 'Song' + prefix + 'TextNumber');
  ThemeLoadText(Song.TextYear, 'Song' + prefix + 'TextYear');
  ThemeLoadText(Song.TextCreator, 'Song' + prefix + 'TextCreator');
  ThemeLoadText(Song.TextFixer, 'Song' + prefix + 'TextFixer');
  Self.ThemeLoadText(Self.Song.SearchText, 'Song'+prefix+'SearchText');
  Self.ThemeLoadText(Self.Song.SearchTextPlaceholder, 'Song'+prefix+'SearchTextPlaceholder');
  Self.ThemeLoadStatic(Self.Song.SearchIcon, 'Song'+prefix+'SearchIcon');

  //Song icons
  Self.ThemeLoadStatic(Self.Song.VideoIcon, 'Song'+prefix+'VideoIcon');
  Self.ThemeLoadStatic(Self.Song.MedleyIcon, 'Song'+prefix+'MedleyIcon');
  Self.ThemeLoadStatic(Self.Song.CalculatedMedleyIcon, 'Song'+prefix+'CalculatedMedleyIcon');
  Self.ThemeLoadStatic(Self.Song.DuetIcon, 'Song'+prefix+'DuetIcon');
  Self.ThemeLoadStatic(Self.Song.RapIcon, 'Song'+prefix+'RapIcon');
  Self.ThemeLoadStatic(Self.Song.CreatorIcon, 'Song'+prefix+'CreatorIcon');
  Self.ThemeLoadStatic(Self.Song.FixerIcon, 'Song'+prefix+'FixerIcon');
  Self.ThemeLoadStatic(Self.Song.UnvalidatedIcon, 'Song'+prefix+'UnvalidatedIcon');

  //Show Cat in TopLeft Mod
  ThemeLoadText(Song.TextCat, 'Song' + prefix + 'TextCat');

  //Load Cover Pos and Size from Theme Mod
  Self.SetInheritance('Song'+prefix+'Cover');
  Self.ReadProperty('Song'+prefix+'Cover', 'Cols', 4, Self.Song.Cover.Cols);
  Self.ReadProperty('Song'+prefix+'Cover', 'H', 200, Self.Song.Cover.H);
  Self.ReadProperty('Song'+prefix+'Cover', 'W', 300, Self.Song.Cover.W);
  Self.ReadProperty('Song'+prefix+'Cover', 'X', 300, Self.Song.Cover.X);
  Self.ReadProperty('Song'+prefix+'Cover', 'Y', 100, Self.Song.Cover.Y);
  Self.ReadProperty('Song'+prefix+'Cover', 'Padding', 0, Self.Song.Cover.Padding);
  Self.ReadProperty('Song'+prefix+'Cover', 'Reflections', false, Self.Song.Cover.Reflections);
  Self.ReadProperty('Song'+prefix+'Cover', 'ReflectionSpacing', 0, Self.Song.Cover.ReflectionSpacing);
  Self.ReadProperty('Song'+prefix+'Cover', 'Rows', 4, Self.Song.Cover.Rows);
  //zoom for smChessboard and smMosaic
  Self.ReadProperty('Song'+prefix+'Cover', 'ZoomThumbW', 0, Self.Song.Cover.ZoomThumbW);
  Self.ReadProperty('Song'+prefix+'Cover', 'ZoomThumbH', 0, Self.Song.Cover.ZoomThumbH);

  if (TSongMenuMode(Ini.SongMenu) = smList) then
  begin
    Self.SetInheritance('Song'+prefix+'SelectSong');
    Self.ReadProperty('Song'+prefix+'SelectSong', 'X', 300, Self.Song.ListCover.X);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'Y', 100, Self.Song.ListCover.Y);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'W', 300, Self.Song.ListCover.W);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'H', 200, Self.Song.ListCover.H);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'Z', 1, Self.Song.ListCover.Z);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'Reflection', false, Self.Song.ListCover.Reflection);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'ReflectionSpacing', 0, Self.Song.ListCover.ReflectionSpacing);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'Padding', 4, Self.Song.ListCover.Padding);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'Type', '', TempString);
    Song.ListCover.Typ := ParseTextureType(TempString, TEXTURE_TYPE_PLAIN);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'Tex', '', Self.Song.ListCover.Tex);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'DTex', '', Self.Song.ListCover.DTex);
    Self.ReadProperty('Song'+prefix+'SelectSong', 'Color', '', Self.Song.ListCover.Color);
    C := ColorExists(Song.ListCover.Color);
    if C >= 0 then
    begin
      Song.ListCover.ColR := Color[C].RGB.R;
      Song.ListCover.ColG := Color[C].RGB.G;
      Song.ListCover.ColB := Color[C].RGB.B;
    end;
    Self.ReadProperty('Song'+prefix+'SelectSong', 'DColor', '', Self.Song.ListCover.DColor);
    C := ColorExists(Song.ListCover.DColor);
    if C >= 0 then
    begin
      Song.ListCover.DColR := Color[C].RGB.R;
      Song.ListCover.DColG := Color[C].RGB.G;
      Song.ListCover.DColB := Color[C].RGB.B;
    end;
  end;
  Self.ThemeLoadStatic(
    Self.Song.MainCover,
    'Song'+prefix+IfThen(Self.SectionExists('Song'+prefix+'MainCover'), 'MainCover', 'Cover')
  );

  ThemeLoadEqualizer(Song.Equalizer, 'Song' + prefix + 'Equalizer');

  //Ranking Song Screen
  ThemeLoadText(Song.TextMyScores, 'Song' + prefix + 'TextMyScores');
  ThemeLoadText(Song.TextWebsite, 'Song' + prefix + 'TextWebsite');
  ThemeLoadText(Song.TextUserLocalScore1, 'Song' + prefix + 'TextUserLocalScore1');
  ThemeLoadText(Song.TextUserLocalScore2, 'Song' + prefix + 'TextUserLocalScore2');
  ThemeLoadText(Song.TextUserLocalScore3, 'Song' + prefix + 'TextUserLocalScore3');
  ThemeLoadText(Song.TextLocalScore1, 'Song' + prefix + 'TextLocalScore1');
  ThemeLoadText(Song.TextLocalScore2, 'Song' + prefix + 'TextLocalScore2');
  ThemeLoadText(Song.TextLocalScore3, 'Song' + prefix + 'TextLocalScore3');
  ThemeLoadText(Song.TextUserOnlineScore1, 'Song' + prefix + 'TextUserOnlineScore1');
  ThemeLoadText(Song.TextUserOnlineScore2, 'Song' + prefix + 'TextUserOnlineScore2');
  ThemeLoadText(Song.TextUserOnlineScore3, 'Song' + prefix + 'TextUserOnlineScore3');
  ThemeLoadText(Song.TextOnlineScore1, 'Song' + prefix + 'TextOnlineScore1');
  ThemeLoadText(Song.TextOnlineScore2, 'Song' + prefix + 'TextOnlineScore2');
  ThemeLoadText(Song.TextOnlineScore3, 'Song' + prefix + 'TextOnlineScore3');

  //Party and Non Party specific Statics and Texts
  ThemeLoadStatics (Song.StaticParty, 'Song' + prefix + 'StaticParty');
  ThemeLoadTexts (Song.TextParty, 'Song' + prefix + 'TextParty');

  ThemeLoadStatics (Song.StaticNonParty, 'Song' + prefix + 'StaticNonParty');
  ThemeLoadTexts (Song.TextNonParty, 'Song' + prefix + 'TextNonParty');

  // Duet Singers
  ThemeLoadStatic (Song.Static2PlayersDuetSingerP1, 'Song' + prefix + 'Static2PlayersDuetSingerP1');
  ThemeLoadStatic (Song.Static2PlayersDuetSingerP2, 'Song' + prefix + 'Static2PlayersDuetSingerP2');
  ThemeLoadText (Song.Text2PlayersDuetSingerP1, 'Song' + prefix + 'Text2PlayersDuetSingerP1');
  ThemeLoadText (Song.Text2PlayersDuetSingerP2, 'Song' + prefix + 'Text2PlayersDuetSingerP2');

  ThemeLoadStatic (Song.Static3PlayersDuetSingerP1, 'Song' + prefix + 'Static3PlayersDuetSingerP1');
  ThemeLoadStatic (Song.Static3PlayersDuetSingerP2, 'Song' + prefix + 'Static3PlayersDuetSingerP2');
  ThemeLoadStatic (Song.Static3PlayersDuetSingerP3, 'Song' + prefix + 'Static3PlayersDuetSingerP3');
  ThemeLoadText (Song.Text3PlayersDuetSingerP1, 'Song' + prefix + 'Text3PlayersDuetSingerP1');
  ThemeLoadText (Song.Text3PlayersDuetSingerP2, 'Song' + prefix + 'Text3PlayersDuetSingerP2');
  ThemeLoadText (Song.Text3PlayersDuetSingerP3, 'Song' + prefix + 'Text3PlayersDuetSingerP3');

  // 4/6 players 1 screen
  ThemeLoadStatic (Song.Static4PlayersDuetSingerP3, 'Song' + prefix + 'Static4PlayersDuetSingerP3');
  ThemeLoadStatic (Song.Static4PlayersDuetSingerP4, 'Song' + prefix + 'Static4PlayersDuetSingerP4');

  ThemeLoadStatic (Song.Static6PlayersDuetSingerP4, 'Song' + prefix + 'Static6PlayersDuetSingerP4');
  ThemeLoadStatic (Song.Static6PlayersDuetSingerP5, 'Song' + prefix + 'Static6PlayersDuetSingerP5');
  ThemeLoadStatic (Song.Static6PlayersDuetSingerP6, 'Song' + prefix + 'Static6PlayersDuetSingerP6');

  //Party Mode
  Self.ThemeLoadStatic(Song.StaticTeamJoker, 'Song'+prefix+'StaticTeamJoker');

  ThemeLoadText (Song.TextPartyTime, 'Song' + prefix + 'TextPartyTime');

  ThemeLoadText (Song.InfoMessageText, 'Song' + prefix + 'InfoMessageText');
  ThemeLoadStatic (Song.InfoMessageBG, 'Song' + prefix + 'InfoMessageBG');
end;

procedure TTheme.CreateThemeObjects();
begin
  Self.Loading := TThemeLoading.Create();
  Self.Main := TThemeMain.Create();
  Self.PlayerSelector := TThemePlayerSelector.Create();
  Self.Song := TThemeSong.Create();
  Self.Sing := TThemeSing.Create();
  Self.Jukebox := TThemeJukebox.Create();
  Self.JukeboxPlaylist := TThemeJukeboxPlaylist.Create();
  Self.AboutMain := TThemeAboutMain.Create();
  Self.Developers := TThemeDevelopers.Create();
  Self.Score := TThemeScore.Create();
  Self.Top5 := TThemeTop5.Create();
  Self.Options := TThemeOptions.Create();
  Self.OptionsGame := TThemeOptionsGame.Create();
  Self.OptionsGraphics := TThemeOptionsGraphics.Create();
  Self.OptionsSound := TThemeOptionsSound.Create();
  Self.OptionsLyrics := TThemeOptionsLyrics.Create();
  Self.OptionsThemes := TThemeOptionsThemes.Create();
  Self.OptionsMicrophones := TThemeOptionsMicrophones.Create();
  Self.OptionsAdvanced := TThemeOptionsAdvanced.Create();
  Self.OptionsNetwork := TThemeOptionsNetwork.Create();
  Self.OptionsWebcam := TThemeOptionsWebcam.Create();
  Self.OptionsProfiles := TThemeOptionsProfiles.Create();
  Self.ErrorPopup := TThemeError.Create();
  Self.CheckPopup := TThemeCheck.Create();
  Self.InsertUserPopup := TThemeInsertUser.Create();
  Self.SendScorePopup := TThemeSendScore.Create();
  Self.ScoreDownloadPopup := TThemeScoreDownload.Create();
  Self.SongMenu := TThemeSongMenu.Create();
  Self.PartyNewRound := TThemePartyNewRound.Create();
  Self.PartyWin := TThemePartyWin.Create();
  Self.PartyScore := TThemePartyScore.Create();
  Self.PartyOptions := TThemePartyOptions.Create();
  Self.PartyPlayer := TThemePartyPlayer.Create();
  Self.PartyRounds := TThemePartyRounds.Create();
  Self.PartyTournamentPlayer := TThemePartyTournamentPlayer.Create();
  Self.PartyTournamentOptions := TThemePartyTournamentOptions.Create();
  Self.PartyTournamentRounds := TThemePartyTournamentRounds.Create();
  Self.PartyTournamentWin := TThemePartyTournamentWin.Create();
  Self.StatMain := TThemeStatMain.Create();
  Self.StatDetail := TThemeStatDetail.Create();
end;

end.
