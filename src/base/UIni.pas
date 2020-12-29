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

//TODO: lots of parts in this code should be rewritten in a more object oriented way.

unit UIni;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  Classes,
  IniFiles,
  SysUtils,
  UCommon,
  ULog,
  UTextEncoding,
  UFilesystem,
  UPath;

type
  {**
   * TInputDeviceConfig stores the configuration for an input device.
   * Configurations will be stored in the InputDeviceConfig array.
   * Note that not all devices listed in InputDeviceConfig are active devices.
   * Some might be unplugged and hence unavailable.
   * Available devices are held in TAudioInputProcessor.DeviceList. Each
   * TAudioInputDevice listed there has a CfgIndex field which is the index to
   * its configuration in the InputDeviceConfig array.
   *}
  PInputDeviceConfig = ^TInputDeviceConfig;
  TInputDeviceConfig = record
    Name:               string;  //**< Name of the input device
    Input:              integer; //**< Index of the input source to use for recording
    Latency:            integer; //**< Latency in ms, or LATENCY_AUTODETECT for default

    {**
     * Mapping of recording channels to players, e.g. ChannelToPlayerMap[0] = 2
     * maps the channel 0 (left) to player 2.
     * A player index of 0 (CHANNEL_OFF) means that the channel is not assigned
     * to any player (the channel is off).
     *}
    ChannelToPlayerMap: array of integer;
  end;

{* Constants for TInputDeviceConfig *}
const
  CHANNEL_OFF = 0;         // for field ChannelToPlayerMap
  LATENCY_AUTODETECT = -1; // for field Latency
  DEFAULT_RESOLUTION = '800x600';
  IMaxPlayerCount = 6;
  IPlayers: array[0..4] of UTF8String = ('1', '2', '3', '4', '6');
  IPlayersVals: array[0..4] of integer = (1, 2, 3, 4, 6);

type

//Options

  TVisualizerOption      = (voOff, voWhenNoVideo, voWhenNoVideoAndImage, voOn);
  TBackgroundMusicOption = (bmoOff, bmoOn);
  TSongMenuMode = ( smRoulette, smChessboard, smCarousel, smSlotMachine, smSlide, smList, smMosaic);

  TIni = class
    private
      function ExtractKeyIndex(const Key, Prefix, Suffix: string): integer;
      function GetMaxKeyIndex(Keys: TStringList; const Prefix, Suffix: string): integer;
      function ReadArrayIndex(const SearchArray: array of UTF8String; IniFile: TCustomIniFile;
          IniSection: string; IniProperty: string; Default: integer; CaseInsensitive: boolean = false): integer; overload;
      function ReadArrayIndex(const SearchArray: array of UTF8String; IniFile: TCustomIniFile;
          IniSection: string; IniProperty: string; Default: integer; DefaultValue: UTF8String; CaseInsensitive: boolean = false): integer; overload;

      procedure TranslateOptionValues;
      procedure LoadInputDeviceCfg(IniFile: TMemIniFile);
      procedure SaveInputDeviceCfg(IniFile: TIniFile);
      procedure LoadThemes(IniFile: TCustomIniFile);
      procedure LoadPaths(IniFile: TCustomIniFile);
      procedure LoadScreenModes(IniFile: TCustomIniFile);
      procedure LoadWebcamSettings(IniFile: TCustomIniFile);
    public
      // Players or Teams colors
      SingColor:      array[0..(IMaxPlayerCount-1)] of integer;

      Name: array[0..(IMaxPlayerCount-1)] of UTF8String;
      PlayerColor:    array[0..(IMaxPlayerCount-1)] of integer;
      TeamColor:      array[0..2] of integer;

      PlayerAvatar:   array[0..(IMaxPlayerCount-1)] of UTF8String;
      PlayerLevel:    array[0..(IMaxPlayerCount-1)] of integer;

      // Templates for Names Mod
      NameTeam:       array[0..2] of UTF8String;
      NameTemplate:   array[0..(IMaxPlayerCount-1)] of UTF8String;

      //Filename of the opened iniFile
      Filename:       IPath;

      // Game
      Players:        integer;
      Difficulty:     integer;
      Language:       integer;
      SongMenu:       integer;
      ShowDuets: integer;
      Tabs:           integer;
      Sorting:        integer;
      ShowScores:     integer;
      ShowWebScore:   integer;


      // Graphics
      MaxFramerate: integer;
      Screens:        integer;
      Split:          integer;
      Resolution:     integer;             // Resolution for windowed mode
      ResolutionFullscreen:     integer;   // Resolution for real fullscreen (changing Video mode)
      EffectSing:     integer;
      ScreenFade:     integer;
      VisualizerOption: integer;
      FullScreen:     integer;
      TextureSize:    integer;
      SingWindow:     integer;
      // not used
      //Spectrum:       integer;
      //Spectrograph:   integer;
      MovieSize:      integer;
      VideoPreview:   integer;
      VideoEnabled:   integer;

      // Sound
      MicBoost:       integer;
      ClickAssist:    integer;
      BeatClick:      integer;
      SavePlayback:   integer;
      ThresholdIndex: integer;
      AudioOutputBufferSizeIndex: integer;
      VoicePassthrough: integer;
      MusicAutoGain:  integer;
      SoundFont:      string;

      SyncTo: integer;

      //Song Preview
      PreviewVolume:  integer;
      PreviewFading:  integer;

      //lyrics
      NoteLines: integer;
      LyricsFont: integer;
      LyricsEffect: integer;
      LyricsTransparency: integer;
      LyricsSingColor: string;
      LyricsSingOutlineColor: string;
      LyricsCurrentColor: string;
      LyricsCurrentOutlineColor: string;
      LyricsNextColor: string;
      LyricsNextOutlineColor: string;

      // Jukebox
      JukeboxOffset: integer;
      JukeboxSongMenu: integer;
      JukeboxFont: integer;
      JukeboxEffect: integer;
      JukeboxTransparency: integer;
      JukeboxSingColor: string;
      JukeboxSingOutlineColor: string;
      JukeboxCurrentColor: string;
      JukeboxCurrentOutlineColor: string;
      JukeboxNextColor: string;
      JukeboxNextOutlineColor: string;

      // Themes
      Theme:          integer;
      Skin:         integer;
      Color:          integer;
      BackgroundMusicOption: integer;

      // Record
      InputDeviceConfig: array of TInputDeviceConfig;

      // Advanced

	  Debug:          integer;
      Oscilloscope:   integer;
      AskBeforeDel:   integer;
      OnSongClick:    integer;
      LineBonus:      integer;
      PartyPopup:     integer;
      SingScores:     integer;
      TopScores:      integer;
      SingTimebarMode:       integer;
      JukeboxTimebarMode:    integer;
      FindUnsetMedley: integer;

      // WebCam
      WebCamID:         integer;
      WebcamResolution: integer;
      WebCamFPS:        integer;
      WebCamFlip:       integer;
      WebCamBrightness: integer;
      WebCamSaturation: integer;
      WebCamHue:        integer;
      WebCamEffect:     integer;

      // default encoding for texts (lyrics, song-name, ...)
      DefaultEncoding: TEncoding;

      procedure Load();
      procedure Save();
      procedure SaveNames();
      procedure SaveLevel();
      procedure SavePlayerColors();
      procedure SavePlayerAvatars();
      procedure SavePlayerLevels();
      procedure SaveTeamColors();
      procedure SaveShowWebScore();
      procedure SaveJukeboxSongMenu();
      procedure SaveSoundFont(Name: string);
      procedure SaveWebcamSettings();
      procedure SaveNumberOfPlayers();
      procedure SaveSingTimebarMode();
      procedure SaveJukeboxTimebarMode();

      { Sets resolution.
        @return (@true when resolution was added, @false otherwise) }
      function SetResolution(ResolutionString: string; RemoveCurrent: boolean = false; NoSave: boolean = false): boolean; overload;
      { Sets resolution.
        @return (@true when resolution was added, @false otherwise) }
      function SetResolution(w,h: integer; RemoveCurrent: boolean = false; NoSave: boolean = false): boolean; overload;
      { Sets resolution given by the index pointing to a resolution in IResolution.
        @return (@true when resolution ID was found, @false otherwise) }
      function SetResolution(index: integer): boolean; overload;
      function GetResolution(): string; overload;
      function GetResolution(out w,h: integer): string; overload;
      function GetResolution(index: integer; out ResolutionString: string): boolean; overload;

      function GetResolutionFullscreen(): string; overload;
      function GetResolutionFullscreen(out w,h: integer): string; overload;
      function GetResolutionFullscreen(index: integer; out ResolutionString: string): boolean; overload;

      procedure ClearCustomResolutions();

  end;
var
  Ini:         TIni;
  IResolution: TUTF8StringDynArray;
  IResolutionFullScreen: TUTF8StringDynArray;
  IResolutionCustom: TUTF8StringDynArray;
  ILanguage:   TUTF8StringDynArray;
  LanguageIso: array of UTF8String;
  ITheme:      TUTF8StringDynArray;

{*
 * Options
 *}

const
  IDifficulty:  array[0..2] of UTF8String = ('Easy', 'Medium', 'Hard');
  Switch: array[0..1] of UTF8String = ('Off', 'On');
  ISorting:      array[0..8] of UTF8String = ('Edition', 'Genre', 'Language', 'Folder', 'Title', 'Artist', 'Artist2', 'Year', 'Decade');
  ISongMenuMode: array[0..6] of UTF8String = ('Roulette', 'Chessboard', 'Carousel', 'Slot Machine', 'Slide', 'List', 'Mosaic');

type
  TSortingType = (sEdition, sGenre, sLanguage, sFolder, sTitle, sArtist, sArtist2, sYear, sDecade);

const
  IShowScores:       array[0..2] of UTF8String  = ('Off', 'When exists', 'On');

  IDebug:            array[0..1] of UTF8String  = ('Off', 'On');

  IScreens:          array[0..1] of UTF8String  = ('1', '2');
  ISplit:            array[0..1] of UTF8String  = ('Off', 'On');
  IFullScreen:       array[0..2] of UTF8String  = ('Off', 'On', 'Borderless');
  IVisualizer:       array[0..3] of UTF8String  = ('Off', 'WhenNoVideo', 'WhenNoVideoAndImage', 'On');

  IBackgroundMusic:  array[0..1] of UTF8String  = ('Off', 'On');

  ITextureSize:      array[0..3] of UTF8String  = ('64', '128', '256', '512');
  ITextureSizeVals:  array[0..3] of integer     = ( 64,   128,   256,   512);

  ISingWindow:       array[0..1] of UTF8String  = ('Small', 'Big');

  //SingBar Mod
  IOscilloscope:     array[0..1] of UTF8String  = ('Off', 'On');

  ISpectrum:         array[0..1] of UTF8String  = ('Off', 'On');
  ISpectrograph:     array[0..1] of UTF8String  = ('Off', 'On');
  IMovieSize:        array[0..2] of UTF8String  = ('Half', 'Full [Vid]', 'Full [BG+Vid]');
  IVideoPreview:     array[0..1] of UTF8String  = ('Off', 'On');
  IVideoEnabled:     array[0..1] of UTF8String  = ('Off', 'On');

  IClickAssist:      array[0..1] of UTF8String  = ('Off', 'On');
  IBeatClick:        array[0..1] of UTF8String  = ('Off', 'On');
  ISavePlayback:     array[0..1] of UTF8String  = ('Off', 'On');

  IThreshold:        array[0..3] of UTF8String  = ('5%', '10%', '15%', '20%');
  IThresholdVals:    array[0..3] of single  = (0.05, 0.10,  0.15,  0.20);

  IVoicePassthrough: array[0..1] of UTF8String  = ('Off', 'On');

  IMusicAutoGain:        array[0..3] of UTF8String  = ('Off', 'Soft', 'Medium', 'Hard');
  IMusicAutoGainVals:    array[0..3] of integer  = (-1, 0, 1, 2);


const
  ISyncTo: array[0..2] of UTF8String  = ('Music', 'Lyrics', 'Off');
type
  TSyncToType = (stMusic, stLyrics, stOff);

const
  IAudioOutputBufferSize:     array[0..9] of UTF8String  = ('Auto', '256', '512', '1024', '2048', '4096', '8192', '16384', '32768', '65536');
  IAudioOutputBufferSizeVals: array[0..9] of integer     = ( 0,      256,   512 ,  1024 ,  2048 ,  4096 ,  8192 ,  16384 ,  32768 ,  65536 );

  IAudioInputBufferSize:      array[0..9] of UTF8String  = ('Auto', '256', '512', '1024', '2048', '4096', '8192', '16384', '32768', '65536');
  IAudioInputBufferSizeVals:  array[0..9] of integer     = ( 0,      256,   512 ,  1024 ,  2048 ,  4096 ,  8192 ,  16384 ,  32768 ,  65536 );

  //Song Preview
  IPreviewVolume:             array[0..10] of UTF8String = ('Off', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%');
  IPreviewVolumeVals:         array[0..10] of single     = ( 0,   0.10,  0.20,  0.30,  0.40,  0.50,  0.60,  0.70,  0.80,  0.90,   1.00  );

  IPreviewFading:             array[0..5] of UTF8String  = ('Off', '1 Sec', '2 Secs', '3 Secs', '4 Secs', '5 Secs');
  IPreviewFadingVals:         array[0..5] of integer     = ( 0,     1,       2,        3,        4,        5      );

  ILyricsFont:    array[0..2] of UTF8String = ('Plain', 'OLine1', 'OLine2');
  ILyricsEffect:  array[0..4] of UTF8String = ('Simple', 'Zoom', 'Slide', 'Ball', 'Shift');
  ILyricsAlpha: array[0..19] of UTF8String = ('0.05', '0.10', '0.15', '0.20', '0.25', '0.30', '0.35', '0.40', '0.45', '0.50', '0.55', '0.60', '0.65', '0.70', '0.75', '0.80', '0.85', '0.90', '0.95', '1.00');

  //for lyric colors
  ILine:             array[0..2] of UTF8String = ('Sing', 'Top', 'Bottom');
  IProperty: array[0..1] of UTF8String = ('Fill', 'Outline');
  LineColor: array[0..21] of UTF8String = ('Blue', 'Green', 'Pink', 'Red', 'Violet', 'Orange', 'Yellow', 'Magenta', 'Brown', 'Black', 'Turquoise', 'Salmon', 'GreenYellow', 'Lavender', 'Beige', 'Teal', 'Orchid', 'SteelBlue', 'Plum', 'Chocolate', 'Gold', 'Other');
  LineInactiveColor: array[0..9] of UTF8String = ('Black', 'Gray +3', 'Gray +2', 'Gray +1', 'Gray', 'Gray -1', 'Gray -2', 'Gray -3', 'White', 'Other');
  OutlineColor: array[0..2] of UTF8String = ('Black', 'White', 'Other');

  IHexSingColor: array[0..21] of UTF8String = ('0096FF', '3FBF3F', 'FF3FC0', 'DC0000', 'B43FE6', 'FF9000', 'FFFF00', 'D7006F', 'C07F1F', '000000', '00FFE6', 'FF7F66', '99FF66', 'CCCCFF', 'FFE6CC', '339999', '9900CC', '336699', 'FF99FF', '8A5C2E', 'FFCC33', '');
  IHexGrayColor: array[0..9] of UTF8String = ('000000', '202020', '404040', '606060', '808080', 'A0A0A0', 'C0C0C0', 'D6D6D6', 'FFFFFF', '');
  IHexOColor:    array[0..2] of UTF8String = ('000000', 'FFFFFF', '');

  IJukeboxSongMenu: array[0..1] of UTF8String = ('Off', 'On');
  JukeboxOffsetLyric: array [0..100] of UTF8String = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
                                                        '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100');
  IColor:         array[0..9] of UTF8String = ('Blue', 'Green', 'Pink', 'Red', 'Violet', 'Orange', 'Yellow', 'Magenta', 'Brown', 'Black');

  // Advanced
  IEffectSing:    array[0..1] of UTF8String = ('Off', 'On');
  IScreenFade:    array[0..1] of UTF8String = ('Off', 'On');
  IAskbeforeDel:  array[0..1] of UTF8String = ('Off', 'On');
  ISingScores:    array[0..1] of UTF8String = ('Off', 'On');
  ITopScores:    array[0..1] of UTF8String = ('All', 'Player');
  IOnSongClick:   array[0..2] of UTF8String = ('Sing', 'Select Players', 'Open Menu');
  sStartSing = 0;
  sSelectPlayer = 1;
  sOpenMenu = 2;

  ILineBonus:     array[0..1] of UTF8String = ('Off', 'On');
  IPartyPopup:    array[0..1] of UTF8String = ('Off', 'On');

  ISingTimebarMode:    array[0..2] of UTF8String = ('Current', 'Remaining', 'Total');
  IJukeboxTimebarMode: array[0..2] of UTF8String = ('Current', 'Remaining', 'Total');

  // Recording options
  IChannelPlayer: array[0..6] of UTF8String = ('Off', '1', '2', '3', '4', '5', '6');
  IMicBoost:      array[0..3] of UTF8String = ('Off', '+6dB', '+12dB', '+18dB');

  // Webcam
  IWebcamResolution: array[0..5] of UTF8String = ('160x120', '176x144', '320x240', '352x288', '640x480', '800x600');
  IWebcamFPS:        array[0..8] of UTF8String = ('10', '12', '15', '18', '20', '22', '25', '28', '30');
  IWebcamFlip:       array[0..1] of UTF8String = ('Off', 'On');

{*
 * Translated options
 *}

var
  GreyScaleColor: array[0..9] of UTF8String;
  // Network
  ISendNameTranslated:        array[0..1] of UTF8String = ('Off', 'On');
  IAutoModeTranslated:        array[0..2] of UTF8String = ('Off', 'Send', 'Guardar');
  IAutoPlayerTranslated: array[0..6] of UTF8String = ('Player 1', 'Player 2', 'Player 3', 'Player 4', 'Player 5', 'Player 6', 'All');
  IAutoScoreEasyTranslated:   array of UTF8String;
  IAutoScoreMediumTranslated: array of UTF8String;
  IAutoScoreHardTranslated:   array of UTF8String;

  // Webcam
  IWebcamBrightness: array [0..200] of UTF8String;
  IWebcamSaturation: array [0..200] of UTF8String;
  IWebcamHue:        array [0..360] of UTF8String;

  IRed:       array[0..255] of UTF8String;
  IGreen:     array[0..255] of UTF8String;
  IBlue:      array[0..255] of UTF8String;

implementation

uses
  gettext,
  {$IFDEF MSWINDOWS}
  Windows,
  {$ELSE}
  Unix,
  {$ENDIF}
  math,
  StrUtils,
  sdl2,
  UCommandLine,
  UDataBase,
  UDllManager,
  ULanguage,
  UPlatform,
  UMain,
  URecord,
  USkins,
  UThemes,
  UPathUtils,
  UUnicodeUtils;

const
  IGNORE_INDEX = -1;

(**
 * Translate and set the values of options, which need translation.
 *)
procedure TIni.TranslateOptionValues;
var
  I: integer;
  Zeros: string;
begin
  // Load Languagefile, fallback to config language if param is invalid
  if (Params.Language > -1) and (Params.Language < Length(ILanguage)) then
    ULanguage.Language.ChangeLanguage(ILanguage[Params.Language])
  else
    ULanguage.Language.ChangeLanguage(ILanguage[Language]);

  for I := 0 to 255 do
  begin
    IRed[I]   := IntToStr(I);
    IGreen[I] := IntToStr(I);
    IBlue[I]  := IntToStr(I);
  end;

  GreyScaleColor[0] := ULanguage.Language.Translate('OPTION_VALUE_BLACK');
  GreyScaleColor[1] := ULanguage.Language.Translate('OPTION_VALUE_GRAY') + ' +3';
  GreyScaleColor[2] := ULanguage.Language.Translate('OPTION_VALUE_GRAY') + ' +2';
  GreyScaleColor[3] := ULanguage.Language.Translate('OPTION_VALUE_GRAY') + ' +1';
  GreyScaleColor[4] := ULanguage.Language.Translate('OPTION_VALUE_GRAY');
  GreyScaleColor[5] := ULanguage.Language.Translate('OPTION_VALUE_GRAY') + ' -1';
  GreyScaleColor[6] := ULanguage.Language.Translate('OPTION_VALUE_GRAY') + ' -2';
  GreyScaleColor[7] := ULanguage.Language.Translate('OPTION_VALUE_GRAY') + ' -3';
  GreyScaleColor[8] := ULanguage.Language.Translate('OPTION_VALUE_WHITE');
  GreyScaleColor[9] := ULanguage.Language.Translate('OPTION_VALUE_OTHER');

  // Network
  IAutoModeTranslated[0]         := ULanguage.Language.Translate('OPTION_VALUE_OFF');
  IAutoModeTranslated[1]         := ULanguage.Language.Translate('OPTION_VALUE_SEND');
  IAutoModeTranslated[2]         := ULanguage.Language.Translate('OPTION_VALUE_SAVE');

  for I:=0 to IMaxPlayerCount-1 do
    IAutoPlayerTranslated[I]       :=ULanguage.Language.Translate('OPTION_PLAYER_' + IntToStr(I));

  IAutoPlayerTranslated[6] := ULanguage.Language.Translate('OPTION_ALL_PLAYERS');

  SetLength(IAutoScoreEasyTranslated, 10000);
  SetLength(IAutoScoreMediumTranslated, 10000);
  SetLength(IAutoScoreHardTranslated, 10000);

  for I := 0 to 9999 do
  begin
    case (I) of
      0..9 : Zeros := '000';
      10..99 : Zeros := '00';
      100..999 : Zeros := '0';
      else Zeros := ''; //1000..9999
    end;

    IAutoScoreEasyTranslated[I]   := '+' + Zeros + IntToStr(I);
    IAutoScoreMediumTranslated[I] := '+' + Zeros + IntToStr(I);
    IAutoScoreHardTranslated[I]   := '+' + Zeros + IntToStr(I);
  end;

end;

procedure TIni.LoadWebcamSettings(IniFile: TCustomIniFile);
var
  I: integer;
begin
  for I:= 100 downto 1 do
  begin
    IWebcamBrightness[100 - I]   := '-' + IntToStr(I);
    IWebcamSaturation[100 - I]   := '-' + IntToStr(I);
  end;

  IWebcamBrightness[100]   := '0';
  IWebcamSaturation[100]   := '0';

  for I:= 1 to 100 do
  begin
    IWebcamBrightness[I + 100]   := '+' + IntToStr(I);
    IWebcamSaturation[I + 100]   := '+' + IntToStr(I);
  end;

  for I:= 180 downto 1 do
    IWebcamHue[180 - I]   := '-' + IntToStr(I);

  IWebcamHue[180]   := '0';

  for I:= 1 to 180 do
    IWebcamHue[I + 180]   := '+' + IntToStr(I);

end;

(**
 * Extracts an index of a key that is surrounded by a Prefix/Suffix pair.
 * Example: ExtractKeyIndex('MyKey[1]', '[', ']') will return 1.
 *)
function TIni.ExtractKeyIndex(const Key, Prefix, Suffix: string): integer;
var
  Value: string;
  Start: integer;
  PrefixPos, SuffixPos: integer;
begin
  Result := -1;

  PrefixPos := Pos(Prefix, Key);
  if (PrefixPos <= 0) then
    Exit;
  SuffixPos := Pos(Suffix, Key);
  if (SuffixPos <= 0) then
    Exit;

  Start := PrefixPos + Length(Prefix);

  // copy all between prefix and suffix
  Value  := Copy(Key, Start, SuffixPos - Start);
  Result := StrToIntDef(Value, -1);
end;

(**
 * Finds the maximum key-index in a key-list.
 * The indexes of the list are surrounded by Prefix/Suffix,
 * e.g. MyKey[1] (Prefix='[', Suffix=']')
 *)
function TIni.GetMaxKeyIndex(Keys: TStringList; const Prefix, Suffix: string): integer;
var
  i:        integer;
  KeyIndex: integer;
begin
  Result := -1;

  for i := 0 to Keys.Count-1 do
  begin
    KeyIndex := ExtractKeyIndex(Keys[i], Prefix, Suffix);
    if (KeyIndex > Result) then
      Result := KeyIndex;
  end;
end;

(**
 * Reads the property IniSeaction:IniProperty from IniFile and
 * finds its corresponding index in SearchArray.
 * If SearchArray does not contain the property value, the default value is
 * returned.
 *)
function TIni.ReadArrayIndex(const SearchArray: array of UTF8String; IniFile: TCustomIniFile;
    IniSection: string; IniProperty: string; Default: integer; CaseInsensitive: boolean = false): integer;
begin
  Result := ReadArrayIndex(SearchArray, IniFile, IniSection, IniProperty, Default, '', CaseInsensitive);
end;

function TIni.ReadArrayIndex(const SearchArray: array of UTF8String; IniFile: TCustomIniFile;
          IniSection: string; IniProperty: string; Default: integer; DefaultValue: UTF8String; CaseInsensitive: boolean = false): integer;
var
  StrValue: string;
begin
  StrValue := IniFile.ReadString(IniSection, IniProperty, '');
  Result := GetArrayIndex(SearchArray, StrValue, CaseInsensitive);
  if (Result < 0) then
  begin
    if (Default = IGNORE_INDEX) and (not UCommon.Equals(StrValue, DefaultValue, not CaseInsensitive)) then
    begin
      // priorite default string value
      Result := GetArrayIndex(SearchArray, DefaultValue, CaseInsensitive);
    end;

    if (Result < 0) or (Result > High(SearchArray)) then Result := Default;
  end;
end;

procedure TIni.LoadInputDeviceCfg(IniFile: TMemIniFile);
var
  DeviceCfg:    PInputDeviceConfig;
  DeviceIndex:  integer;
  ChannelCount: integer;
  ChannelIndex: integer;
  RecordKeys:   TStringList;
  i:            integer;
begin
  RecordKeys := TStringList.Create();

  // read all record-keys for filtering
  IniFile.ReadSection('Record', RecordKeys);

  SetLength(InputDeviceConfig, 0);

  for i := 0 to RecordKeys.Count-1 do
  begin
    // find next device-name
    DeviceIndex := ExtractKeyIndex(RecordKeys[i], 'DeviceName[', ']');
    if (DeviceIndex >= 0) then
    begin
      if not IniFile.ValueExists('Record', Format('DeviceName[%d]', [DeviceIndex])) then
        Continue;

      // resize list
      SetLength(InputDeviceConfig, Length(InputDeviceConfig)+1);

      // read an input device's config.
      // Note: All devices are appended to the list whether they exist or not.
      //   Otherwise an external device's config will be lost if it is not
      //   connected (e.g. singstar mics or USB-Audio devices).
      DeviceCfg := @InputDeviceConfig[High(InputDeviceConfig)];
      DeviceCfg.Name := IniFile.ReadString('Record', Format('DeviceName[%d]', [DeviceIndex]), '');
      DeviceCfg.Input := IniFile.ReadInteger('Record', Format('Input[%d]', [DeviceIndex]), 0);
      DeviceCfg.Latency := IniFile.ReadInteger('Record', Format('Latency[%d]', [DeviceIndex]), LATENCY_AUTODETECT);

      // find the largest channel-number of the current device in the ini-file
      ChannelCount := GetMaxKeyIndex(RecordKeys, 'Channel', Format('[%d]', [DeviceIndex]));
      if (ChannelCount < 0) then
        ChannelCount := 0;

      SetLength(DeviceCfg.ChannelToPlayerMap, ChannelCount);

      // read channel-to-player mapping for every channel of the current device
      // or set non-configured channels to no player (=0).
      for ChannelIndex := 0 to High(DeviceCfg.ChannelToPlayerMap) do
      begin
        DeviceCfg.ChannelToPlayerMap[ChannelIndex] :=
          IniFile.ReadInteger('Record', Format('Channel%d[%d]', [ChannelIndex+1, DeviceIndex]), CHANNEL_OFF);
      end;
    end;
  end;

  RecordKeys.Free();

  // MicBoost
  MicBoost := ReadArrayIndex(IMicBoost, IniFile, 'Record', 'MicBoost', IGNORE_INDEX, 'Off');
  // Threshold
  ThresholdIndex := ReadArrayIndex(IThreshold, IniFile, 'Record', 'Threshold', 1);
end;

procedure TIni.SaveInputDeviceCfg(IniFile: TIniFile);
var
  DeviceIndex:  integer;
  ChannelIndex: integer;
begin
  for DeviceIndex := 0 to High(InputDeviceConfig) do
  begin
    // DeviceName and DeviceInput
    IniFile.WriteString('Record', Format('DeviceName[%d]', [DeviceIndex+1]),
                        InputDeviceConfig[DeviceIndex].Name);
    IniFile.WriteInteger('Record', Format('Input[%d]', [DeviceIndex+1]),
                        InputDeviceConfig[DeviceIndex].Input);
    IniFile.WriteInteger('Record', Format('Latency[%d]', [DeviceIndex+1]),
                        InputDeviceConfig[DeviceIndex].Latency);

    // Channel-to-Player Mapping
    for ChannelIndex := 0 to High(InputDeviceConfig[DeviceIndex].ChannelToPlayerMap) do
    begin
      IniFile.WriteInteger('Record',
                          Format('Channel%d[%d]', [ChannelIndex+1, DeviceIndex+1]),
                          InputDeviceConfig[DeviceIndex].ChannelToPlayerMap[ChannelIndex]);
    end;
  end;

  // MicBoost
  IniFile.WriteString('Record', 'MicBoost', IMicBoost[MicBoost]);
  // Threshold
  IniFile.WriteString('Record', 'Threshold', IThreshold[ThresholdIndex]);
end;

procedure TIni.LoadPaths(IniFile: TCustomIniFile);
var
  PathStrings: TStringList;
  I: integer;
begin
  UPathUtils.InitializeSongPaths();
  PathStrings := TStringList.Create();
  IniFile.ReadSection('Directories', PathStrings);
  for I := 0 to PathStrings.Count - 1 do
    if (Pos('SONGDIR', UpperCase(PathStrings[I])) = 1) then
      UPathUtils.AddSongPath(UPath.Path(IniFile.ReadString('Directories', PathStrings[I], '')));

  PathStrings.Free();
end;

procedure TIni.LoadThemes(IniFile: TCustomIniFile);
begin
  Theme := ReadArrayIndex(ITheme, IniFile, 'Themes', 'Theme', IGNORE_INDEX, UThemes.DefaultTheme, true);
  Self.Skin := Self.ReadArrayIndex(UThemes.Theme.Themes[Theme].Skins, IniFile, 'Themes', 'Skin', GetArrayIndex(UThemes.Theme.Themes[Theme].Skins, UThemes.Theme.Themes[Theme].DefaultSkin));
  Self.Color := Self.ReadArrayIndex(IColor, IniFile, 'Themes', 'Color', USkins.Skin.GetDefaultColor());
end;

procedure TIni.LoadScreenModes(IniFile: TCustomIniFile);

  // swap two strings
  procedure swap(var s1, s2: UTF8String);
  var
    s3: string;
  begin
    s3 := s1;
    s1 := s2;
    s2 := s3;
  end;

var
  I, Success, DisplayIndex:     integer;
  CurrentMode, ModeIter, MaxMode: TSDL_DisplayMode;
  CurrentRes, ResString: string;
begin
  MaxFramerate := IniFile.ReadInteger('Graphics', 'MaxFramerate', 60);
  // Screens
  Screens := ReadArrayIndex(IScreens, IniFile, 'Graphics', 'Screens', 0);

  // Split mode
  Split := ReadArrayIndex(ISplit, IniFile, 'Graphics', 'Split', 0);

  FullScreen := ReadArrayIndex(IFullScreen, IniFile, 'Graphics', 'FullScreen', IGNORE_INDEX, 'Borderless');

  // standard fallback resolutions
  SetLength(IResolution, 27);
  IResolution[0] := '640x480'; // VGA
  IResolution[1] := '720x480'; // SDTV 480i, EDTV 480p [TV]
  IResolution[2] := '720x576'; // SDTV 576i, EDTV 576p [TV]
  IResolution[3] := '768x576'; // SDTV 576i, EDTV 576p [TV]
  IResolution[4] := '800x600'; // SVGA
  IResolution[5] := '960x540'; // Quarter FHD
  IResolution[6] := '1024x768'; // XGA
  IResolution[7] := '1152x666';
  IResolution[8] := '1152x864'; // XGA+
  IResolution[9] := '1280x720'; // WXGA-H
  IResolution[10] := '1280x800'; // WXGA
  IResolution[11] := '1280x960'; // WXGA
  IResolution[12] := '1280x1024'; // SXGA
  IResolution[13] := '1366x768'; // HD
  IResolution[14] := '1400x1050'; // SXGA+
  IResolution[15] := '1440x900'; // WXGA+
  IResolution[16] := '1600x900'; // HD+
  IResolution[17] := '1600x1200'; // UXGA
  IResolution[18] := '1680x1050'; // WSXGA+
  IResolution[19] := '1920x1080'; // FHD
  IResolution[20] := '1920x1200'; // WUXGA
  IResolution[21] := '2048x1152'; // QWXGA
  IResolution[22] := '2560x1440'; // WQHD
  IResolution[23] := '2560x1600'; // WQXGA
  IResolution[24] := '3840x2160'; // 4K UHD
  IResolution[25] := '4096x2304'; // 4K
  IResolution[26] := '4096x3072'; // HXGA

  // Check if there are any modes available

  // retrieve currently used Video Display
  DisplayIndex := -1;
  MaxMode.h := 0; MaxMode.w := 0;
  CurrentMode.h := -1; CurrentMode.w := -1;
  CurrentRes := '';
  for I := 0 to SDL_GetNumVideoDisplays() - 1 do
  begin
    Success := SDL_GetCurrentDisplayMode(I,  @CurrentMode);
    if Success = 0 then
    begin
      DisplayIndex := I;
      CurrentRes := BuildResolutionString(CurrentMode.w, CurrentMode.h);
      Break
    end;
  end;

  // retrieve available display modes, store into separate array
  if DisplayIndex >= 0 then
  begin
    for I := 0 to SDL_GetNumDisplayModes(DisplayIndex) - 1 do
    begin
      Success := SDL_GetDisplayMode(DisplayIndex, I, @ModeIter);
      if Success <> 0 then continue;

      ResString := BuildResolutionString(ModeIter.w, ModeIter.h);
      if GetArrayIndex(IResolutionFullScreen, ResString) < 0 then
      begin
        // Log.LogStatus('Found Video Mode: ' + ResString, 'Video');
        SetLength(IResolutionFullScreen, Length(IResolutionFullScreen) + 1);
        IResolutionFullScreen[High(IResolutionFullScreen)] := ResString;

        if (ModeIter.w > MaxMode.w) or (ModeIter.h > ModeIter.h) then
        begin
          MaxMode := ModeIter;
        end;
      end;
    end;
  end;

  // if display modes are found, override fallback ones
  if Length(IResolutionFullScreen) > 0 then
  begin
    Log.LogStatus( 'Found resolutions: ' + IntToStr(Length(IResolutionFullScreen)), 'Video');
    IResolution := IResolutionFullScreen;

    // reverse order
    for I := 0 to (Length(IResolution) div 2) - 1 do swap(IResolution[I], IResolution[High(IResolution)-I]);
  end;

  // read fullscreen resolution and verify if possible
  ResString := IniFile.ReadString('Graphics', 'ResolutionFullscreen', CurrentRes);
  ResolutionFullscreen := GetArrayIndex(IResolutionFullScreen, ResString);

  // Check if there is a resolution configured, try using it
  ResString := IniFile.ReadString('Graphics', 'Resolution', '');
  if ResString = '' then
  begin
    ResString := CurrentRes; // either store desktop resolution or invalid which results into DEFAULT
  end;

  // check if stored resolution is valid
  Resolution := GetArrayIndex(IResolution, ResString);

  // if resolution cannot be found, check if is larger than max resolution
  if (Resolution < 0) and (MaxMode.w > 0) and (MaxMode.h > 0) and
     (ParseResolutionString(ResString, ModeIter.w, ModeIter.h)) and
     ((ModeIter.w > MaxMode.w) or (ModeIter.h > MaxMode.h)) then
  begin
    Log.LogInfo(Format('Exceeding resoluton found (%s). Reverting to standard resolution.', [ResString]), 'Video');
    ResString := CurrentRes;
    Resolution := GetArrayIndex(IResolution, ResString);
  end;

  // append unknown mode to list
  if (Resolution = -1) and (Length(ResString) >= 3) then
  begin
    SetLength(IResolution, Length(IResolution) + 1);
    IResolution[High(IResolution)] := ResString;
    Resolution := High(IResolution);

    // store also as custom resolution to eventually remove it upon window size change
    SetLength(IResolutionCustom, Length(IResolutionCustom) + 1);
    IResolutionCustom[High(IResolutionCustom)] := ResString;
  end;

  if (Length(IResolution) = 0) or (Resolution < 0) then
  begin
    // if no modes were set, then failback to DEFAULT_RESOLUTION (800x600)
    SetLength(IResolution, Length(IResolution) + 1);
    IResolution[High(IResolution)] := DEFAULT_RESOLUTION;
    Resolution := GetArrayIndex(IResolution, DEFAULT_RESOLUTION);
    if Resolution < 0 then Resolution := 0;

    Log.LogStatus( Format('No video mode found! Default to: %s ', [IResolution[Resolution]]), 'Video');
    FullScreen := 0; // default to fullscreen OFF in this case
  end;

end;

procedure TIni.Load();
var
  IniFile: TMemIniFile;
  I: integer;
  IShowWebScore: array of UTF8String;
  LanguageIsoCode: integer;
  Lang, FallbackLang: string;
begin
  GamePath := Platform.GetGameUserPath;

  Log.LogStatus( 'GamePath : ' +GamePath.ToNative , '' );

  if (Params.ConfigFile.IsSet) then
    FileName := Params.ConfigFile
  else
    FileName := GamePath.Append('config.ini');

  Log.LogStatus('Using config : ' + FileName.ToNative, 'Ini');
  IniFile := TMemIniFile.Create(FileName.ToNative);

  for I := 0 to IMaxPlayerCount-1 do
  begin
    // Name
    Name[I] := IniFile.ReadString('Name', 'P'+IntToStr(I+1), 'Player'+IntToStr(I+1));
    // Color Player
    PlayerColor[I] := IniFile.ReadInteger('PlayerColor', 'P'+IntToStr(I+1), I + 1);
    // Avatar Player
    PlayerAvatar[I] := IniFile.ReadString('PlayerAvatar', 'P'+IntToStr(I+1), '');
    // Level Player
    PlayerLevel[I] := IniFile.ReadInteger('PlayerLevel', 'P'+IntToStr(I+1), 0);
  end;

  // Color Team
  for I := 0 to 2 do
    TeamColor[I] := IniFile.ReadInteger('TeamColor', 'T'+IntToStr(I+1), I + 1);

  // Templates for Names Mod
  for I := 0 to 2 do
    NameTeam[I] := IniFile.ReadString('NameTeam', 'T'+IntToStr(I+1), 'Team'+IntToStr(I+1));
  for I := 0 to IMaxPlayerCount - 1 do
    NameTemplate[I] := IniFile.ReadString('NameTemplate', 'Name'+IntToStr(I+1), 'Template'+IntToStr(I+1));

  // Players
  Players := ReadArrayIndex(IPlayers, IniFile, 'Game', 'Players', 0);

  // Difficulty
  Difficulty := ReadArrayIndex(IDifficulty, IniFile, 'Game', 'Difficulty', IGNORE_INDEX, 'Easy');

  //if language is unset try to find system language or load english at default
  GetLanguageIDs(Lang, FallbackLang);
  LanguageIsoCode := GetArrayIndex(LanguageIso, IfThen(Length(Lang) = 2, Lang, Copy(FallbackLang, 1, 2)));
  Language := ReadArrayIndex(ILanguage, IniFile, 'Game', 'Language', IGNORE_INDEX, ILanguage[IfThen(LanguageIsoCode > -1, LanguageIsoCode, GetArrayIndex(LanguageIso, 'en'))]);

  // SongMenu
  SongMenu := ReadArrayIndex(ISongMenuMode, IniFile, 'Game', 'SongMenu', Ord(smChessboard));

  // Tabs
  ShowDuets := Self.ReadArrayIndex(Switch, IniFile, 'Game', 'ShowDuets', 1);
  Self.Tabs := Self.ReadArrayIndex(Switch, IniFile, 'Game', 'Tabs', 0);
  Self.FindUnsetMedley := ReadArrayIndex(Switch, IniFile, 'Game', 'FindUnsetMedley', 0);

  // Song Sorting
  Sorting := ReadArrayIndex(ISorting, IniFile, 'Game', 'Sorting', Ord(sTitle));

  // Show Score
  ShowScores := ReadArrayIndex(IShowScores, IniFile, 'Game', 'ShowScores', IGNORE_INDEX, 'On');

  // Read Users Info (Network)
  DataBase.ReadUsers;

  // Update Webs Scores
  DataBase.AddWebsite;

  // Webs Scores Path
  WebScoresPath := Path(IniFile.ReadString('Directories', 'WebScoresDir', WebsitePath.ToNative));
  if not(DirectoryExists(WebScoresPath.ToNative)) then
    WebScoresPath :=  WebsitePath;

  // ShowWebScore
  if (Length(DllMan.Websites) > 0) then
  begin
    SetLength(IShowWebScore, Length(DLLMan.Websites));
    for I:= 0 to High(DllMan.Websites) do
      IShowWebScore[I] := DllMan.Websites[I].Name;
    ShowWebScore := ReadArrayIndex(IShowWebScore, IniFile, 'Game', 'ShowWebScore', 0);
    if (ShowWebScore = -1) then
      ShowWebScore := 0;
  end;

  LoadScreenModes(IniFile);

  LoadWebcamSettings(IniFile);

  // ScreenFade
  ScreenFade := ReadArrayIndex(IScreenFade, IniFile, 'Graphics', 'ScreenFade', IGNORE_INDEX, 'On');

  // TextureSize (aka CachedCoverSize)
  TextureSize := ReadArrayIndex(ITextureSize, IniFile, 'Graphics', 'TextureSize', IGNORE_INDEX, '256');

  // SingWindow
  SingWindow := ReadArrayIndex(ISingWindow, IniFile, 'Graphics', 'SingWindow', IGNORE_INDEX, 'Big');

  // Spectrum
  //Spectrum := ReadArrayIndex(ISpectrum, IniFile, 'Graphics', 'Spectrum', IGNORE_INDEX, 'Off');

  // Spectrograph
  //Spectrograph := ReadArrayIndex(ISpectrograph, IniFile, 'Graphics', 'Spectrograph', IGNORE_INDEX, 'Off');

  // MovieSize
  MovieSize := ReadArrayIndex(IMovieSize, IniFile, 'Graphics', 'MovieSize', 2);

  // VideoPreview
  VideoPreview := ReadArrayIndex(IVideoPreview, IniFile, 'Graphics', 'VideoPreview', 1);

  // VideoEnabled
  VideoEnabled := ReadArrayIndex(IVideoEnabled, IniFile, 'Graphics', 'VideoEnabled', 1);

  // ClickAssist
  ClickAssist := ReadArrayIndex(IClickAssist, IniFile, 'Sound', 'ClickAssist', IGNORE_INDEX, 'Off');

  // BeatClick
  BeatClick := ReadArrayIndex(IBeatClick, IniFile, 'Sound', 'BeatClick', 0);

  // SavePlayback
  SavePlayback := ReadArrayIndex(ISavePlayback, IniFile, 'Sound', 'SavePlayback', 0);

  // AudioOutputBufferSize
  AudioOutputBufferSizeIndex := ReadArrayIndex(IAudioOutputBufferSize, IniFile, 'Sound', 'AudioOutputBufferSize', 0);

  //Preview Volume
  PreviewVolume := ReadArrayIndex(IPreviewVolume, IniFile, 'Sound', 'PreviewVolume', 6);

  //Preview Fading
  PreviewFading := ReadArrayIndex(IPreviewFading, IniFile, 'Sound', 'PreviewFading', 1);

  //AudioRepeat aka VoicePassthrough
  VoicePassthrough := ReadArrayIndex(IVoicePassthrough, IniFile, 'Sound', 'VoicePassthrough', 0);

  // ReplayGain aka MusicAutoGain
  MusicAutoGain := ReadArrayIndex(IMusicAutoGain, IniFile, 'Sound', 'MusicAutoGain', 0);

  SoundFont := IniFile.ReadString('Sound', 'SoundFont', '');

  //lyrics
  Self.NoteLines := ReadArrayIndex(Switch, IniFile, 'Lyrics', 'NoteLines', 0);
  Self.LyricsFont := ReadArrayIndex(ILyricsFont, IniFile, 'Lyrics', 'Font', 0);
  Self.LyricsEffect := ReadArrayIndex(ILyricsEffect, IniFile, 'Lyrics', 'Effect', 2);
  Self.LyricsTransparency := ReadArrayIndex(ILyricsAlpha, IniFile, 'Lyrics', 'Transparency', 19);
  Self.LyricsSingColor := IniFile.ReadString('Lyrics', 'SingColor', IHexSingColor[7]);
  Self.LyricsSingOutlineColor := IniFile.ReadString('Lyrics', 'SingOutlineColor', IHexOColor[0]);
  Self.LyricsCurrentColor := IniFile.ReadString('Lyrics', 'CurrentColor', IHexGrayColor[6]);
  Self.LyricsCurrentOutlineColor := IniFile.ReadString('Lyrics', 'CurrentOutlineColor', IHexOColor[0]);
  Self.LyricsNextColor := IniFile.ReadString('Lyrics', 'NextColor', IHexGrayColor[5]);
  Self.LyricsNextOutlineColor := IniFile.ReadString('Lyrics', 'NextOutlineColor', IHexOColor[0]);

  // Jukebox
  Self.JukeboxOffset := IniFile.ReadInteger('Jukebox', 'Position', 100);
  Self.JukeboxFont := ReadArrayIndex(ILyricsFont, IniFile, 'Jukebox', 'Font', 2);
  Self.JukeboxEffect := ReadArrayIndex(ILyricsEffect, IniFile, 'Jukebox', 'Effect', 2);
  Self.JukeboxTransparency := ReadArrayIndex(ILyricsAlpha, IniFile, 'Jukebox', 'Transparency', 19);
  Self.JukeboxSingColor := IniFile.ReadString('Jukebox', 'SingColor', IHexSingColor[7]);
  Self.JukeboxSingOutlineColor := IniFile.ReadString('Jukebox', 'SingOutlineColor', IHexOColor[0]);
  Self.JukeboxCurrentColor := IniFile.ReadString('Jukebox', 'CurrentColor', IHexGrayColor[6]);
  Self.JukeboxCurrentOutlineColor := IniFile.ReadString('Jukebox', 'CurrentOutlineColor', IHexOColor[0]);
  Self.JukeboxNextColor := IniFile.ReadString('Jukebox', 'NextColor', IHexGrayColor[5]);
  Self.JukeboxNextOutlineColor := IniFile.ReadString('Jukebox', 'NextOutlineColor', IHexOColor[0]);
  Self.JukeboxSongMenu := ReadArrayIndex(IJukeboxSongMenu, IniFile, 'Jukebox', 'SongMenu', IGNORE_INDEX, 'On');

  // DefaultEncoding
  DefaultEncoding := ParseEncoding(IniFile.ReadString('Lyrics', 'Encoding', ''), encAuto);

  LoadThemes(IniFile);

  LoadInputDeviceCfg(IniFile);

    // Debug
  Debug := ReadArrayIndex(IDebug, IniFile, 'Advanced', 'Debug', 0);

    // Oscilloscope
  Oscilloscope := ReadArrayIndex(IOscilloscope, IniFile, 'Advanced', 'Oscilloscope', 0);


  // Visualizations
  // <mog> this could be of use later..
  //  VisualizerOption :=
  //    TVisualizerOption(GetEnumValue(TypeInfo(TVisualizerOption),
  //            IniFile.ReadString('Graphics', 'Visualization', 'Off')));
  // || VisualizerOption := TVisualizerOption(GetArrayIndex(IVisualizer, IniFile.ReadString('Graphics', 'Visualization', 'Off')));
  VisualizerOption := ReadArrayIndex(IVisualizer, IniFile, 'Graphics', 'Visualization', IGNORE_INDEX, 'Off');

{**
 * Background music
 *}
  BackgroundMusicOption := ReadArrayIndex(IBackgroundMusic, IniFile, 'Sound', 'BackgroundMusic', IGNORE_INDEX, 'On');

  // EffectSing
  EffectSing := ReadArrayIndex(IEffectSing, IniFile, 'Advanced', 'EffectSing', IGNORE_INDEX, 'On');

  // AskbeforeDel
  AskBeforeDel := ReadArrayIndex(IAskbeforeDel, IniFile, 'Advanced', 'AskbeforeDel', IGNORE_INDEX, 'On');

  // OnSongClick
  OnSongClick := ReadArrayIndex(IOnSongClick, IniFile, 'Advanced', 'OnSongClick', IGNORE_INDEX, 'Sing');

  // Linebonus
  LineBonus := ReadArrayIndex(ILineBonus, IniFile, 'Advanced', 'LineBonus', 1);

  // PartyPopup
  PartyPopup := ReadArrayIndex(IPartyPopup, IniFile, 'Advanced', 'PartyPopup', IGNORE_INDEX, 'On');

  // SingScores
  SingScores := ReadArrayIndex(ISingScores, IniFile, 'Advanced', 'SingScores', IGNORE_INDEX, 'Off');

  // TopScores
  TopScores := ReadArrayIndex(ITopScores, IniFile, 'Advanced', 'TopScores', IGNORE_INDEX, 'All');

  // SyncTo
  SyncTo := ReadArrayIndex(ISyncTo, IniFile, 'Advanced', 'SyncTo', Ord(stMusic));

  // SingTimebarMode
  SingTimebarMode := ReadArrayIndex(ISingTimebarMode, IniFile, 'Advanced', 'SingTimebarMode', IGNORE_INDEX, 'Remaining');

  // JukeboxTimebarMode
  JukeboxTimebarMode := ReadArrayIndex(IJukeboxTimebarMode, IniFile, 'Advanced', 'JukeboxTimebarMode', IGNORE_INDEX, 'Current');

  // WebCam
  WebCamID := IniFile.ReadInteger('Webcam', 'ID', 0);
  WebCamResolution := ReadArrayIndex(IWebcamResolution, IniFile, 'Webcam', 'Resolution', IGNORE_INDEX, '320x240');
  if (WebCamResolution = -1) then
    WebcamResolution := 2;
  WebCamFPS := ReadArrayIndex(IWebcamFPS, IniFile, 'Webcam', 'FPS', 4);
  WebCamFlip := ReadArrayIndex(IWebcamFlip, IniFile, 'Webcam', 'Flip', IGNORE_INDEX, 'On');
  WebCamBrightness := ReadArrayIndex(IWebcamBrightness, IniFile, 'Webcam', 'Brightness', IGNORE_INDEX, '0');
  WebCamSaturation := ReadArrayIndex(IWebcamSaturation, IniFile, 'Webcam', 'Saturation', IGNORE_INDEX, '0');
  WebCamHue := ReadArrayIndex(IWebcamHue, IniFile, 'Webcam', 'Hue', IGNORE_INDEX, '0');
  WebCamEffect := IniFile.ReadInteger('Webcam', 'Effect', 0);

  JukeboxSongMenu := ReadArrayIndex(IJukeboxSongMenu, IniFile, 'Jukebox', 'SongMenu', IGNORE_INDEX, 'On');

  LoadPaths(IniFile);

  TranslateOptionValues;

  IniFile.Free;
end;

procedure TIni.Save;
var
  IniFile: TIniFile;
begin
  try
  begin
    if (Filename.IsFile and Filename.IsReadOnly) then
    begin
      Log.LogError('Config-file is read-only', 'TIni.Save');
      Exit;
    end;

  IniFile := TIniFile.Create(Filename.ToNative);

  // Players
  IniFile.WriteString('Game', 'Players', IPlayers[Players]);

  // Difficulty
  IniFile.WriteString('Game', 'Difficulty', IDifficulty[Difficulty]);

  // Language
  IniFile.WriteString('Game', 'Language', ILanguage[Language]);

  IniFile.WriteString('Game', 'ShowDuets', Switch[Self.ShowDuets]);
  // Tabs
  IniFile.WriteString('Game', 'Tabs', Switch[Tabs]);

  // SongMenu
  IniFile.WriteString('Game', 'SongMenu', ISongMenuMode[Ord(SongMenu)]);

  // Sorting
  IniFile.WriteString('Game', 'Sorting', ISorting[Sorting]);

  // Show Scores
  IniFile.WriteString('Game', 'ShowScores', IShowScores[ShowScores]);
  IniFile.WriteString('Game', 'FindUnsetMedley', Switch[Self.FindUnsetMedley]);

  // MaxFramerate
  IniFile.WriteInteger('Graphics', 'MaxFramerate', MaxFramerate);

  // Screens
  IniFile.WriteString('Graphics', 'Screens', IScreens[Screens]);

  // Split
  IniFile.WriteString('Graphics', 'Split', ISplit[Split]);

  // FullScreen
  IniFile.WriteString('Graphics', 'FullScreen', IFullScreen[FullScreen]);

  // Visualization
  IniFile.WriteString('Graphics', 'Visualization', IVisualizer[VisualizerOption]);

  // Resolution
  IniFile.WriteString('Graphics', 'Resolution', GetResolution);
  IniFile.WriteString('Graphics', 'ResolutionFullscreen', GetResolutionFullscreen);

  //EffectSing
  IniFile.WriteString('Graphics', 'EffectSing', IEffectSing[EffectSing]);

  //ScreenFade
  IniFile.WriteString('Graphics', 'ScreenFade', IScreenFade[ScreenFade]);

  // TextureSize
  IniFile.WriteString('Graphics', 'TextureSize', ITextureSize[TextureSize]);

  // Sing Window
  IniFile.WriteString('Graphics', 'SingWindow', ISingWindow[SingWindow]);

  // Spectrum
  //IniFile.WriteString('Graphics', 'Spectrum', ISpectrum[Spectrum]);

  // Spectrograph
  //IniFile.WriteString('Graphics', 'Spectrograph', ISpectrograph[Spectrograph]);

  // Movie Size
  IniFile.WriteString('Graphics', 'MovieSize', IMovieSize[MovieSize]);

  // VideoPreview
  IniFile.WriteString('Graphics', 'VideoPreview', IVideoPreview[VideoPreview]);

  // VideoEnabled
  IniFile.WriteString('Graphics', 'VideoEnabled', IVideoEnabled[VideoEnabled]);

  // ClickAssist
  IniFile.WriteString('Sound', 'ClickAssist', IClickAssist[ClickAssist]);

  // BeatClick
  IniFile.WriteString('Sound', 'BeatClick', IBeatClick[BeatClick]);

  // AudioOutputBufferSize
  IniFile.WriteString('Sound', 'AudioOutputBufferSize', IAudioOutputBufferSize[AudioOutputBufferSizeIndex]);

  // Background music
  IniFile.WriteString('Sound', 'BackgroundMusic', IBackgroundMusic[BackgroundMusicOption]);

  // Song Preview
  IniFile.WriteString('Sound', 'PreviewVolume', IPreviewVolume[PreviewVolume]);

  // PreviewFading
  IniFile.WriteString('Sound', 'PreviewFading', IPreviewFading[PreviewFading]);

  // SavePlayback
  IniFile.WriteString('Sound', 'SavePlayback', ISavePlayback[SavePlayback]);

  // VoicePasstrough
  IniFile.WriteString('Sound', 'VoicePassthrough', IVoicePassthrough[VoicePassthrough]);

  // MusicAutoGain
  IniFile.WriteString('Sound', 'MusicAutoGain', IMusicAutoGain[MusicAutoGain]);

  //lyrics
  IniFile.WriteString('Lyrics', 'NoteLines', Switch[Self.NoteLines]);
  IniFile.WriteString('Lyrics', 'Font', ILyricsFont[Self.LyricsFont]);
  IniFile.WriteString('Lyrics', 'Effect', ILyricsEffect[Self.LyricsEffect]);
  IniFile.WriteString('Lyrics', 'Transparency', ILyricsAlpha[Self.LyricsTransparency]);
  IniFile.WriteString('Lyrics', 'SingColor', Self.LyricsSingColor);
  IniFile.WriteString('Lyrics', 'SingOutlineColor', Self.LyricsSingOutlineColor);
  IniFile.WriteString('Lyrics', 'CurrentColor', Self.LyricsCurrentColor);
  IniFile.WriteString('Lyrics', 'CurrentOutlineColor', Self.LyricsCurrentOutlineColor);
  IniFile.WriteString('Lyrics', 'NextColor', Self.LyricsNextColor);
  IniFile.WriteString('Lyrics', 'NextOutlineColor', Self.LyricsNextOutlineColor);

  // Jukebox
  IniFile.WriteInteger('Jukebox', 'Position', Self.JukeboxOffset);
  IniFile.WriteString('Jukebox', 'Font', ILyricsFont[Self.JukeboxFont]);
  IniFile.WriteString('Jukebox', 'Effect', ILyricsEffect[Self.JukeboxEffect]);
  IniFile.WriteString('Jukebox', 'Transparency', ILyricsAlpha[Self.JukeboxTransparency]);
  IniFile.WriteString('Jukebox', 'SingColor', Self.JukeboxSingColor);
  IniFile.WriteString('Jukebox', 'SingOutlineColor', Self.JukeboxSingOutlineColor);
  IniFile.WriteString('Jukebox', 'CurrentColor', Self.JukeboxCurrentColor);
  IniFile.WriteString('Jukebox', 'CurrentOutlineColor', Self.JukeboxCurrentOutlineColor);
  IniFile.WriteString('Jukebox', 'NextColor', Self.JukeboxNextColor);
  IniFile.WriteString('Jukebox', 'NextOutlineColor', Self.JukeboxNextOutlineColor);

  //Encoding default
  IniFile.WriteString('Lyrics', 'Encoding', EncodingName(DefaultEncoding));

  // Theme
  IniFile.WriteString('Themes', 'Theme', ITheme[Theme]);

  // Skin
  IniFile.WriteString('Themes', 'Skin', UThemes.Theme.Themes[Theme].Skins[Self.Skin]);

  // Color
  IniFile.WriteString('Themes', 'Color', IColor[Color]);

  SaveInputDeviceCfg(IniFile);

  // Debug
  IniFile.WriteString('Advanced', 'Debug', IDebug[Debug]);

  // Oscilloscope
  IniFile.WriteString('Advanced', 'Oscilloscope', IOscilloscope[Oscilloscope]);

  //AskbeforeDel
  IniFile.WriteString('Advanced', 'AskbeforeDel', IAskbeforeDel[AskBeforeDel]);

  //OnSongClick
  IniFile.WriteString('Advanced', 'OnSongClick', IOnSongClick[OnSongClick]);

  //Line Bonus
  IniFile.WriteString('Advanced', 'LineBonus', ILineBonus[LineBonus]);

  //Party Popup
  IniFile.WriteString('Advanced', 'PartyPopup', IPartyPopup[PartyPopup]);

  //SingScores
  IniFile.WriteString('Advanced', 'SingScores', ISingScores[SingScores]);

  //TopScores
  IniFile.WriteString('Advanced', 'TopScores', ITopScores[TopScores]);

  //SyncTo
  IniFile.WriteString('Advanced', 'SyncTo', ISyncTo[SyncTo]);

  // SingTimebarMode
  IniFile.WriteString('Advanced', 'SingTimebarMode', ISingTimebarMode[SingTimebarMode]);

  // JukeboxTimebarMode
  IniFile.WriteString('Advanced', 'JukeboxTimebarMode', IJukeboxTimebarMode[JukeboxTimebarMode]);

  // Directories (add a template if section is missing)
  // Note: Value must be ' ' and not '', otherwise no key is generated on Linux
  if (not IniFile.SectionExists('Directories')) then
    IniFile.WriteString('Directories', 'SongDir1', ' ');

  if (not IniFile.ValueExists('Directories', 'WebScoresDir')) then
    IniFile.WriteString('Directories', 'WebScoresDir', ' ');

  end
  except
    On e :Exception do begin
      Log.LogWarn('Saving InputDeviceConfig failed: ' + e.Message, 'UIni.Save');
    end;
  end;
end;

procedure TIni.SaveNames;
var
  IniFile: TIniFile;
  I:       integer;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    //Name Templates for Names Mod
    for I := 0 to High(Name) do
      IniFile.WriteString('Name', 'P' + IntToStr(I+1), Name[I]);
    for I := 0 to High(NameTeam) do
      IniFile.WriteString('NameTeam', 'T' + IntToStr(I+1), NameTeam[I]);
    for I := 0 to High(NameTemplate) do
      IniFile.WriteString('NameTemplate', 'Name' + IntToStr(I+1), NameTemplate[I]);

    IniFile.Free;
  end;
end;

procedure TIni.SaveLevel;
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    // Difficulty
    IniFile.WriteString('Game', 'Difficulty', IDifficulty[Difficulty]);

    IniFile.Free;
  end;
end;

procedure TIni.SaveJukeboxSongMenu;
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    IniFile.WriteString('Jukebox', 'SongMenu', IJukeboxSongMenu[JukeboxSongMenu]);

    IniFile.Free;
  end;
end;


procedure TIni.SaveShowWebScore;
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    // ShowWebScore
    IniFile.WriteString('Game', 'ShowWebScore', DllMan.Websites[ShowWebScore].Name);

    IniFile.Free;
  end;
end;


procedure TIni.SavePlayerColors;

var
  IniFile: TIniFile;
  I: integer;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    //Colors for Names Mod
    for I := 1 to IMaxPlayerCount do
      IniFile.WriteString('PlayerColor', 'P' + IntToStr(I), IntToStr(PlayerColor[I-1]));

    IniFile.Free;
  end;
end;

procedure TIni.SavePlayerAvatars;
var
  IniFile: TIniFile;
  I: integer;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    //Colors for Names Mod
    for I := 1 to IMaxPlayerCount do
      IniFile.WriteString('PlayerAvatar', 'P' + IntToStr(I), PlayerAvatar[I-1]);

    IniFile.Free;
  end;
end;

procedure TIni.SavePlayerLevels;
var
  IniFile: TIniFile;
  I: integer;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    for I := 1 to IMaxPlayerCount do
      IniFile.WriteInteger('PlayerLevel', 'P' + IntToStr(I), PlayerLevel[I-1]);

    IniFile.Free;
  end;
end;

procedure TIni.SaveTeamColors;
var
  IniFile: TIniFile;
  I: integer;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    //Colors for Names Mod
    for I := 1 to 3 do
      IniFile.WriteString('TeamColor', 'T' + IntToStr(I), IntToStr(TeamColor[I-1]));

    IniFile.Free;
  end;
end;

procedure TIni.SaveSoundFont(Name: string);
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    IniFile.WriteString('Sound', 'SoundFont', Name);

    IniFile.Free;
  end;
end;

procedure TIni.SaveWebcamSettings;
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    // WebCam
    IniFile.WriteInteger('Webcam', 'ID', WebCamID);
    IniFile.WriteString('Webcam', 'Resolution', IWebcamResolution[WebcamResolution]);
    IniFile.WriteInteger('Webcam', 'FPS', StrToInt(IWebcamFPS[WebCamFPS]));

    IniFile.WriteString('Webcam', 'Flip', IWebcamFlip[WebcamFlip]);
    IniFile.WriteString('Webcam', 'Brightness', IWebcamBrightness[WebcamBrightness]);
    IniFile.WriteString('Webcam', 'Saturation', IWebcamSaturation[WebcamSaturation]);
    IniFile.WriteString('Webcam', 'Hue', IWebcamHue[WebcamHue]);
    IniFile.WriteInteger('Webcam', 'Effect', WebcamEffect);

    IniFile.Free;
  end;

end;

procedure TIni.SaveNumberOfPlayers;
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    // Players
    IniFile.WriteString('Game', 'Players', IPlayers[Players]);

    IniFile.Free;
  end;
end;

procedure TIni.SaveSingTimebarMode;
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    // Players
    IniFile.WriteString('Advanced', 'SingTimebarMode', ISingTimebarMode[SingTimebarMode]);

    IniFile.Free;
  end;
end;

procedure TIni.SaveJukeboxTimebarMode;
var
  IniFile: TIniFile;
begin
  if not Filename.IsReadOnly() then
  begin
    IniFile := TIniFile.Create(Filename.ToNative);

    // Players
    IniFile.WriteString('Advanced', 'JukeboxTimebarMode', IJukeboxTimebarMode[JukeboxTimebarMode]);

    IniFile.Free;
  end;
end;


function TIni.SetResolution(ResolutionString: string; RemoveCurrent: boolean; NoSave: boolean): boolean;
  var
    Index: integer;
    Dirty: boolean;
begin
  Result := false;
  Dirty := false;

  // check if current resolution is custom and then remove anyway (no matter what RemoveCurrent is set)
  if (Resolution >= 0) then
  begin
    Index := GetArrayIndex(IResolutionCustom, IResolution[Resolution]);
    if Index >= 0 then
    begin
      StringDeleteFromArray(IResolutionCustom, Index);
      StringDeleteFromArray(IResolution, Resolution);
    end;
  end;

  Index := GetArrayIndex(IResolution, ResolutionString);
  if not NoSave and (Resolution <> Index) then Dirty := true;
  if (Resolution >= 0) and (RemoveCurrent) then StringDeleteFromArray(IResolution, Resolution);
  if Index < 0 then
  begin
    SetLength(IResolution, Length(IResolution) + 1);
    IResolution[High(IResolution)] := ResolutionString;
    index := High(IResolution);
    Result := true;

    if GetArrayIndex(IResolutionCustom, ResolutionString) < 0 then
    begin
      SetLength(IResolutionCustom, Length(IResolutionCustom) + 1);
      IResolutionCustom[High(IResolutionCustom)] := ResolutionString;
    end;
  end;

  if SetResolution(index) and Dirty then
  begin
    Log.LogStatus('Resolution overridden to: ' + ResolutionString, 'Video');
    Save();
  end;
end;

function TIni.SetResolution(w,h: integer; RemoveCurrent: boolean; NoSave: boolean): boolean;
begin

  // hacky fix to support multiplied resolution (in width) in multiple screen setup (Screens=2 and more)
  // TODO: RattleSN4K3: Improve the way multiplied screen resolution is applied and stored (see UGraphics::InitializeScreen; W := W * Screens)
  if (Screens > 0) and not ((Params.Split = spmSplit ) or (Split > 0)) then w := w div (Screens+1) // integral div
  else if (Params.Screens > 0) and not ((Params.Split = spmSplit ) or (Split > 0)) then w := w div (Params.Screens+1);

  Result := SetResolution(BuildResolutionString(w, h), RemoveCurrent, NoSave);
end;

function TIni.SetResolution(index: integer): boolean;
begin
  Result := false;
  if (index >= 0) and (index < Length(IResolution)) then
  begin
      Resolution := index;
      Result := true;
  end;
end;

function TIni.GetResolution(): string;
begin
  if Resolution >= 0 then Result := IResolution[Resolution]
  else if Length(IResolution) = 0 then Result := DEFAULT_RESOLUTION
  else Result := IResolution[0];
end;

function TIni.GetResolution(out w,h: integer): string;
begin
  Result := GetResolution();
  ParseResolutionString(Result, w, h);

  // hacky fix to support multiplied resolution (in width) in multiple screen setup (Screens=2 and more)
  // TODO: RattleSN4K3: Improve the way multiplied screen resolution is applied and stored (see UGraphics::InitializeScreen; W := W * Screens)
  if (Screens > 0) and not ((Params.Split = spmSplit ) or (Split > 0)) then w := w * (Screens+1)
  else if (Params.Screens > 0) and not ((Params.Split = spmSplit ) or (Split > 0)) then w := w * (Params.Screens+1);
end;

function TIni.GetResolution(index: integer; out ResolutionString: string): boolean;
begin
  Result := false;
  if (index >= 0) and (index < Length(IResolution)) then
  begin
      ResolutionString := IResolution[index];
      Result := true;
  end;
end;

function TIni.GetResolutionFullscreen(): string;
begin
  if ResolutionFullscreen >= 0 then Result := IResolutionFullScreen[ResolutionFullscreen]
  else if Length(IResolutionFullScreen) = 0 then Result := DEFAULT_RESOLUTION
  else Result := IResolutionFullScreen[0];
end;

function TIni.GetResolutionFullscreen(out w,h: integer): string;
begin
  Result := GetResolutionFullscreen();
  ParseResolutionString(Result, w, h);
end;

function TIni.GetResolutionFullscreen(index: integer; out ResolutionString: string): boolean;
begin
  Result := false;
  if (index >= 0) and (index < Length(IResolutionFullScreen)) then
  begin
      ResolutionString := IResolutionFullScreen[index];
      Result := true;
  end;
end;

procedure TIni.ClearCustomResolutions();
  var
    Index, i, custom: integer;
    ResString: string;
begin
  if Resolution < 0 then Exit;

  // check if current resolution is a custom one
  ResString := IResolution[Resolution];
  Index := GetArrayIndex(IResolutionCustom, ResString);
  for i := High(IResolutionCustom) downto 0 do
  begin
    custom := GetArrayIndex(IResolution, IResolutionCustom[i]);
    if (custom >= 0) and (Index <> i) then
    begin
      StringDeleteFromArray(IResolution, custom);
      StringDeleteFromArray(IResolutionCustom, i);
    end;
  end;

  // update index
  Resolution := GetArrayIndex(IResolution, ResString);
end;

end.
