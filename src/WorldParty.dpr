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


program WorldParty;

{$IFDEF MSWINDOWS}
  {$R '..\res\link.res' '..\res\link.rc'}
{$ENDIF}

{$MODE OBJFPC}

{$I switches.inc}

uses
  {$IFDEF Unix}
  cthreads,            // THIS MUST be the first used unit in FPC if Threads are used!!
                       // (see http://wiki.lazarus.freepascal.org/Multithreaded_Application_Tutorial)
  cwstring,            // Enable Unicode support
  {$ENDIF}

  {$IFNDEF FPC}
  ctypes                 in 'lib\ctypes\ctypes.pas', // FPC compatibility types for C libs
  {$ENDIF}

  //------------------------------
  //Includes - 3rd Party Libraries
  //------------------------------
  SQLiteTable3  		 in 'lib\SQLite\SQLiteTable3.pas',
  SQLite3       		 in 'lib\SQLite\SQLite3.pas',
  sdl2                   in 'lib\SDL2\sdl2.pas',
  SDL2_image             in 'lib\SDL2\SDL2_image.pas',
  //new work on current OpenGL implementation
  dglOpenGL              in 'lib\dglOpenGL\dglOpenGL.pas',
  UMediaCore_SDL         in 'media\UMediaCore_SDL.pas',

  zlib                   in 'lib\zlib\zlib.pas',
  freetype               in 'lib\freetype\freetype.pas',

  avcodec in 'lib\'+FFMPEG_DIR+'\avcodec.pas',
  avformat in 'lib\'+FFMPEG_DIR+'\avformat.pas',
  avutil in 'lib\'+FFMPEG_DIR+'\avutil.pas',
  rational in 'lib\'+FFMPEG_DIR+'\rational.pas',
  avio in 'lib\'+FFMPEG_DIR+'\avio.pas',
  swresample in 'lib\'+FFMPEG_DIR+'\swresample.pas',
  swscale in 'lib\'+FFMPEG_DIR+'\swscale.pas',
  UMediaCore_FFmpeg in 'media\UMediaCore_FFmpeg.pas',

  {$IFDEF UseProjectM}
  projectM      in 'lib\projectM\projectM.pas',
  {$ENDIF}

  {$IFDEF UseMIDIPort}
  MidiCons      in 'lib\midi\MidiCons.pas',

  CircBuf       in 'lib\midi\CircBuf.pas',
  DelphiMcb     in 'lib\midi\DelphiMcb.pas',
  MidiDefs      in 'lib\midi\MidiDefs.pas',
  MidiFile      in 'lib\midi\MidiFile.pas',
  MidiOut       in 'lib\midi\MidiOut.pas',
  MidiType      in 'lib\midi\MidiType.pas',
  {$ENDIF}

  {$IFDEF FPC}
  FileUtil in 'lib\Lazarus\components\lazutils\fileutil.pas',
  FPCAdds in 'lib\Lazarus\components\lazutils\fpcadds.pas',
  LazUtilsStrConsts in 'lib\Lazarus\components\lazutils\lazutilsstrconsts.pas',
  LazFileUtils in 'lib\Lazarus\components\lazutils\lazfileutils.pas',
  LazUTF8 in 'lib\Lazarus\components\lazutils\lazutf8.pas',
  LazUTF8Classes in 'lib\Lazarus\components\lazutils\lazutf8classes.pas',
  Masks in 'lib\Lazarus\components\lazutils\masks.pas',
  {$ENDIF}
  CpuCount in 'lib\other\cpucount.pas',
  {$IFDEF MSWINDOWS}
  // FPC compatibility file for Allocate/DeallocateHWnd
  WinAllocation in 'lib\other\WinAllocation.pas',
  Windows,
  {$ENDIF}

  //------------------------------
  //Includes - Lua Support
  //------------------------------
  ULua           in 'lib\Lua\ULua.pas',
  ULuaUtils      in 'lua\ULuaUtils.pas',
  ULuaGl         in 'lua\ULuaGl.pas',
  ULuaLog        in 'lua\ULuaLog.pas',
  ULuaTextGL     in 'lua\ULuaTextGL.pas',
  ULuaTexture    in 'lua\ULuaTexture.pas',
  UHookableEvent in 'lua\UHookableEvent.pas',
  ULuaCore       in 'lua\ULuaCore.pas',
  ULuaUsdx       in 'lua\ULuaUsdx.pas',
  ULuaParty      in 'lua\ULuaParty.pas',
  ULuaScreenSing in 'lua\ULuaScreenSing.pas',

  //------------------------------
  //Includes - Menu System
  //------------------------------
  UDisplay               in 'menu\UDisplay.pas',
  UMenu                  in 'menu\UMenu.pas',
  UMenuStatic            in 'menu\UMenuStatic.pas',
  UMenuText              in 'menu\UMenuText.pas',
  UMenuButton            in 'menu\UMenuButton.pas',
  UMenuInteract          in 'menu\UMenuInteract.pas',
  UMenuSelectSlide       in 'menu\UMenuSelectSlide.pas',
  UMenuEqualizer         in 'menu\UMenuEqualizer.pas',
  UDrawTexture           in 'menu\UDrawTexture.pas',
  UMenuButtonCollection  in 'menu\UMenuButtonCollection.pas',

  UMenuBackground        in 'menu\UMenuBackground.pas',
  UMenuBackgroundNone    in 'menu\UMenuBackgroundNone.pas',
  UMenuBackgroundColor   in 'menu\UMenuBackgroundColor.pas',
  UMenuBackgroundTexture in 'menu\UMenuBackgroundTexture.pas',
  UMenuBackgroundVideo   in 'menu\UMenuBackgroundVideo.pas',
  UMenuBackgroundFade    in 'menu\UMenuBackgroundFade.pas',

  //------------------------------
  //Includes - base
  //------------------------------
  UConfig           in 'base\UConfig.pas',

  UCommon           in 'base\UCommon.pas',
  UGraphic          in 'base\UGraphic.pas',
  UTexture          in 'base\UTexture.pas',
  ULanguage         in 'base\ULanguage.pas',
  UMain             in 'base\UMain.pas',
  UDraw             in 'base\UDraw.pas',
  URecord           in 'base\URecord.pas',
  UTime             in 'base\UTime.pas',
  USong             in 'base\USong.pas',
  USongs            in 'base\USongs.pas',
  UIni              in 'base\UIni.pas',
  UImage            in 'base\UImage.pas',
  ULyrics           in 'base\ULyrics.pas',
  USkins            in 'base\USkins.pas',
  UThemes           in 'base\UThemes.pas',
  ULog              in 'base\ULog.pas',
  UJoystick         in 'base\UJoystick.pas',
  UDataBase         in 'base\UDataBase.pas',
  UCatCovers        in 'base\UCatCovers.pas',
  UFiles            in 'base\UFiles.pas',
  UGraphicClasses   in 'base\UGraphicClasses.pas',
  UPlaylist         in 'base\UPlaylist.pas',
  UCommandLine      in 'base\UCommandLine.pas',
  URingBuffer       in 'base\URingBuffer.pas',
  USingScores       in 'base\USingScores.pas',
  UPathUtils        in 'base\UPathUtils.pas',
  UNote             in 'base\UNote.pas',
  UBeatTimer        in 'base\UBeatTimer.pas',

  TextGL            in 'base\TextGL.pas',
  UUnicodeUtils     in 'base\UUnicodeUtils.pas',
  UFont             in 'base\UFont.pas',
  UTextEncoding     in 'base\UTextEncoding.pas',

  UPath             in 'base\UPath.pas',
  UFilesystem       in 'base\UFilesystem.pas',

  //------------------------------
  //Includes - Plugin Support
  //------------------------------
  UParty            in 'base\UParty.pas',            // TODO: rewrite Party Manager as Module, reomplent ability to offer party Mody by Plugin

  //------------------------------
  //Includes - Platform
  //------------------------------

  UPlatform         in 'base\UPlatform.pas',
{$IF Defined(MSWINDOWS)}
  UPlatformWindows  in 'base\UPlatformWindows.pas',
{$ELSEIF Defined(DARWIN)}
  UPlatformMacOSX   in 'base\UPlatformMacOSX.pas',
{$ELSEIF Defined(UNIX)}
  UPlatformLinux    in 'base\UPlatformLinux.pas',
{$IFEND}

  //------------------------------
  //Includes - Media
  //------------------------------

  UMusic in 'base\UMusic.pas',
  UAudioPlaybackBase in 'media\UAudioPlaybackBase.pas',
  UFFT in 'lib\fft\UFFT.pas',
  UAudioPlayback_SoftMixer in 'media\UAudioPlayback_SoftMixer.pas',
  UAudioConverter in 'media\UAudioConverter.pas',

  //******************************
  //Pluggable media modules
  // The modules are prioritized as in the include list below.
  // This means the first entry has highest priority, the last lowest.
  //******************************

UVideo                    in 'media\UVideo.pas',
{$IFDEF UseProjectM}
  // must be after UVideo, so it will not be the default video module
  UVisualizer               in 'media\UVisualizer.pas',
{$ENDIF}
  {$IFDEF UseBASS}
  BASS in 'lib\bass\bass.pas',
  BASS_FX in 'lib\bass_fx\bass_fx.pas',
  UAudioCore_Bass in 'media\UAudioCore_Bass.pas',
  UAudioInput_Bass in 'media\UAudioInput_Bass.pas',
  UAudioPlayback_Bass in 'media\UAudioPlayback_Bass.pas',
  UAudioDecoder_Bass in 'media\UAudioDecoder_Bass.pas',
  {$ELSE}
  UAudioInput_SDL in 'media\UAudioInput_SDL.pas',
  UAudioPlayback_SDL in 'media\UAudioPlayback_SDL.pas',
  UAudioDecoder_FFmpeg in 'media\UAudioDecoder_FFmpeg.pas',
  {$ENDIF}
  //------------------------------
  //Includes - Screens
  //------------------------------
  UScreenLoading          in 'screens\UScreenLoading.pas',
  UScreenMain             in 'screens\UScreenMain.pas',
  UScreenPlayerSelector in 'screens\UScreenPlayerSelector.pas',
  UScreenSong             in 'screens\UScreenSong.pas',
  UScreenSingController   in 'screens\controllers\UScreenSingController.pas',
  UScreenSingView         in 'screens\views\UScreenSingView.pas',
  UScreenScore            in 'screens\UScreenScore.pas',
  UScreenJukebox          in 'screens\UScreenJukebox.pas',
  UScreenOptions          in 'screens\UScreenOptions.pas',
  UScreenOptionsGame      in 'screens\UScreenOptionsGame.pas',
  UScreenOptionsGraphics  in 'screens\UScreenOptionsGraphics.pas',
  UScreenOptionsSound     in 'screens\UScreenOptionsSound.pas',
  UScreenOptionsLyrics    in 'screens\UScreenOptionsLyrics.pas',
  UScreenOptionsThemes    in 'screens\UScreenOptionsThemes.pas',
  UScreenOptionsMicrophones    in 'screens\UScreenOptionsMicrophones.pas',
  UScreenOptionsAdvanced  in 'screens\UScreenOptionsAdvanced.pas',
  UScreenOptionsNetwork in 'screens\UScreenOptionsNetwork.pas',
  UScreenOptionsWebcam  in 'screens\UScreenOptionsWebcam.pas',
  UScreenOptionsProfiles  in 'screens\UScreenOptionsProfiles.pas',

  UScreenOpen             in 'screens\UScreenOpen.pas',
  UScreenTop5             in 'screens\UScreenTop5.pas',
  UScreenSongMenu         in 'screens\UScreenSongMenu.pas',
  UScreenStatMain         in 'screens\UScreenStatMain.pas',
  UScreenStatDetail       in 'screens\UScreenStatDetail.pas',
  UScreenPopup            in 'screens\UScreenPopup.pas',

  //Includes - Screens PartyMode
  UScreenPartyNewRound    in 'screens\UScreenPartyNewRound.pas',
  UScreenPartyScore       in 'screens\UScreenPartyScore.pas',
  UScreenPartyPlayer      in 'screens\UScreenPartyPlayer.pas',
  UScreenPartyOptions     in 'screens\UScreenPartyOptions.pas',
  UScreenPartyRounds      in 'screens\UScreenPartyRounds.pas',
  UScreenPartyWin         in 'screens\UScreenPartyWin.pas',

  UWebSDK                 in 'webSDK\UWebSDK.pas',
  //curlobj                 in 'webSDK\cURL\src\curlobj.pas',

  opencv_highgui          in 'lib\openCV\opencv_highgui.pas',
  opencv_core             in 'lib\openCV\opencv_core.pas',
  opencv_imgproc          in 'lib\openCV\opencv_imgproc.pas',
  opencv_types            in 'lib\openCV\opencv_types.pas',

  UWebcam                 in 'base\UWebcam.pas',

  UDLLManager             in 'base\UDLLManager.pas',

  UPartyTournament              in 'base\UPartyTournament.pas',
  UScreenPartyTournamentRounds  in 'screens\UScreenPartyTournamentRounds.pas',
  UScreenPartyTournamentPlayer  in 'screens\UScreenPartyTournamentPlayer.pas',
  UScreenPartyTournamentOptions in 'screens\UScreenPartyTournamentOptions.pas',
  UScreenPartyTournamentWin     in 'screens\UScreenPartyTournamentWin.pas',
  UScreenJukeboxOptions         in 'screens\UScreenJukeboxOptions.pas',
  UScreenJukeboxPlaylist        in 'screens\UScreenJukeboxPlaylist.pas',


  UAvatars                in 'base\UAvatars.pas',
  UScreenAbout            in 'screens\UScreenAbout.pas',
  UScreenDevelopers       in 'screens\UScreenDevelopers.pas',

  SysUtils;

const
  sLineBreakWin = AnsiString(#13#10);//Windows-Style Linebreak. Older USDX versions don't support other formats.
var
  I: Integer;
  Report: string;

begin
  try
    {$IF DEFINED(MSWINDOWS) AND NOT DEFINED(DEBUG)}
    FreeConsole(); //hacky workaround to get a working GUI-only experience on windows 10 when using fpc 3.0.0 on windows
    {$IFEND}
    UMain.Main();
  except
    on E : Exception do
    begin
      Report := 'Sorry, an error ocurred! Please report this error to the game-developers. Also check the Error.log file in the game folder.' + LineEnding +
        'Stacktrace:' + LineEnding;
      if E <> nil then begin
        Report := Report + 'Exception class: ' + E.ClassName + LineEnding +
        'Message: ' + E.Message + LineEnding;
      end;
      Report := Report + BackTraceStrFunc(ExceptAddr);
      for I := 0 to ExceptFrameCount - 1 do
        Report := Report + LineEnding + BackTraceStrFunc(ExceptFrames[I]);
      ShowMessage(Report);

      Halt;
    end;
  end;
end.
