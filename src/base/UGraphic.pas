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

unit UGraphic;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  dglOpenGL,
  SysUtils,
  sdl2,
  TextGL,
  UDisplay,
  UCommandLine,
  UCommon,
  UImage,
  UIni,
  ULog,
  UPathUtils,
  UScreenLoading,
  UScreenMain,
  UScreenPlayerSelector,
  UScreenOptions,
  UScreenOptionsGame,
  UScreenOptionsGraphics,
  UScreenOptionsSound,
  UScreenOptionsLyrics,
  UScreenOptionsThemes,
  UScreenOptionsMicrophones,
  UScreenOptionsAdvanced,
  UScreenOptionsNetwork,
  UScreenOptionsWebcam,
  UScreenOptionsProfiles,
  UScreenSong,
  UScreenSingController,
  UScreenJukebox,
  UScreenJukeboxOptions,
  UScreenJukeboxPlaylist,
  UScreenScore,
  UScreenTop5,
  UScreenOpen,
  UScreenAbout,
  UScreenDevelopers,
  USkins,
  UScreenSongMenu,
  {Party Screens}
  UScreenPartyNewRound,
  UScreenPartyScore,
  UScreenPartyOptions,
  UScreenPartyWin,
  UScreenPartyPlayer,
  UScreenPartyRounds,
  UScreenPartyTournamentRounds,
  UScreenPartyTournamentPlayer,
  UScreenPartyTournamentOptions,
  UScreenPartyTournamentWin,
  {Stats Screens}
  UScreenStatMain,
  UScreenStatDetail,
  {Popup for errors, etc.}
  UScreenPopup,
  UTexture;

type
  TRecR = record
    Top:    real;
    Left:   real;
    Right:  real;
    Bottom: real;
  end;

const
  Mode_Windowed = 0;
  Mode_Borderless = 1;
  Mode_Fullscreen = 2;

type
  FullscreenModes = integer;


var
  Screen:         PSDL_Window;
  glcontext:      TSDL_GLContext;
  LoadingThread:  PSDL_Thread;
  Mutex:          PSDL_Mutex;

  CurrentWindowMode:      FullscreenModes;
  WindowModeDirty:        boolean;

  RenderW:    integer;
  RenderH:    integer;
  ScreenW:    integer;
  ScreenH:    integer;
  Screens:    integer;
  ScreenAct:  integer;
  ScreenX:    integer;
  LastX, LastY:    integer;
  LastW, LastH:    integer;
  HasValidPosition:     boolean;
  HasValidSize:         boolean;

  ScreenLoading:      TScreenLoading;
  ScreenMain:         TScreenMain;
  ScreenPlayerSelector: TScreenPlayerSelector;
  ScreenSong:         TScreenSong;
  ScreenSing:         TScreenSingController;

  ScreenJukebox:         TScreenJukebox;
  ScreenJukeboxOptions:  TScreenJukeboxOptions;
  ScreenJukeboxPlaylist: TScreenJukeboxPlaylist;

  ScreenScore:        TScreenScore;
  ScreenTop5:         TScreenTop5;
  ScreenOptions:          TScreenOptions;
  ScreenOptionsGame:      TScreenOptionsGame;
  ScreenOptionsGraphics:  TScreenOptionsGraphics;
  ScreenOptionsSound:     TScreenOptionsSound;
  ScreenOptionsLyrics:    TScreenOptionsLyrics;
  ScreenOptionsThemes:    TScreenOptionsThemes;
  ScreenOptionsMicrophones:    TScreenOptionsMicrophones;
  ScreenOptionsAdvanced:  TScreenOptionsAdvanced;
  ScreenOptionsNetwork:   TScreenOptionsNetwork;
  ScreenOptionsWebcam:    TScreenOptionsWebcam;
  ScreenOptionsProfiles:  TScreenOptionsProfiles;
  ScreenOpen:         TScreenOpen;
  ScreenAbout:        TScreenAbout;
  ScreenDevelopers:   TScreenDevelopers;

  ScreenSongMenu:     TScreenSongMenu;

  //Party Screens
  //ScreenSingModi:         TScreenSingModi;
  ScreenPartyNewRound:    TScreenPartyNewRound;
  ScreenPartyScore:       TScreenPartyScore;
  ScreenPartyWin:         TScreenPartyWin;
  ScreenPartyOptions:     TScreenPartyOptions;
  ScreenPartyPlayer:      TScreenPartyPlayer;
  ScreenPartyRounds:      TScreenPartyRounds;

  // Tournament
  ScreenPartyTournamentRounds:   TScreenPartyTournamentRounds;
  ScreenPartyTournamentPlayer:   TScreenPartyTournamentPlayer;
  ScreenPartyTournamentOptions:  TScreenPartyTournamentOptions;
  ScreenPartyTournamentWin:      TScreenPartyTournamentWin;

  //StatsScreens
  ScreenStatMain:         TScreenStatMain;
  ScreenStatDetail:       TScreenStatDetail;

  //popup mod
  ScreenPopupCheck: TScreenPopupCheck;
  ScreenPopupError: TScreenPopupError;
  ScreenPopupInfo:  TScreenPopupInfo;
  ScreenPopupInsertUser: TScreenPopupInsertUser;
  ScreenPopupSendScore:  TScreenPopupSendScore;
  ScreenPopupScoreDownload: TScreenPopupScoreDownload;

  //Notes
  Tex_Left:        array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_note_left
  Tex_Mid:         array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_note_mid
  Tex_Right:       array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_note_right

  Tex_plain_Left:  array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_notebg_left
  Tex_plain_Mid:   array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_notebg_mid
  Tex_plain_Right: array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_notebg_right

  Tex_BG_Left:     array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_noteglow_left
  Tex_BG_Mid:      array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_noteglow_mid
  Tex_BG_Right:    array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_noteglow_right


  Tex_Left_Rap:        array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_note_left
  Tex_Mid_Rap:         array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_note_mid
  Tex_Right_Rap:       array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_note_right

  Tex_plain_Left_Rap:  array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_notebg_left
  Tex_plain_Mid_Rap:   array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_notebg_mid
  Tex_plain_Right_Rap: array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_notebg_right

  Tex_BG_Left_Rap:     array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_noteglow_left
  Tex_BG_Mid_Rap:      array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_noteglow_mid
  Tex_BG_Right_Rap:    array[1..UIni.IMaxPlayerCount] of TTexture;   //rename to tex_noteglow_right

  Tex_Lyric_Help_Bar: TTexture;
  FullScreen:     boolean;

  Tex_TimeProgress: TTexture;
  Tex_JukeboxTimeProgress: TTexture;

  //ScoreBG Texs
  Tex_ScoreBG: array [0..UIni.IMaxPlayerCount-1] of TTexture;

  //Score Screen Textures
    Tex_Score_NoteBarLevel_Dark     : array [1..UIni.IMaxPlayerCount] of TTexture;
    Tex_Score_NoteBarRound_Dark     : array [1..UIni.IMaxPlayerCount] of TTexture;

    Tex_Score_NoteBarLevel_Light    : array [1..UIni.IMaxPlayerCount] of TTexture;
    Tex_Score_NoteBarRound_Light    : array [1..UIni.IMaxPlayerCount] of TTexture;

    Tex_Score_NoteBarLevel_Lightest : array [1..UIni.IMaxPlayerCount] of TTexture;
    Tex_Score_NoteBarRound_Lightest : array [1..UIni.IMaxPlayerCount] of TTexture;

    Tex_Score_Ratings               : array [0..7] of TTexture;  //stores all possible rating result images

  PboSupported: boolean;

const
  Skin_BGColorR = 1;
  Skin_BGColorG = 1;
  Skin_BGColorB = 1;

  Skin_SpectrumR = 0;
  Skin_SpectrumG = 0;
  Skin_SpectrumB = 0;

  Skin_Spectograph1R = 0.6;
  Skin_Spectograph1G = 0.8;
  Skin_Spectograph1B = 1;

  Skin_Spectograph2R = 0;
  Skin_Spectograph2G = 0;
  Skin_Spectograph2B = 0.2;

  Skin_FontR = 0;
  Skin_FontG = 0;
  Skin_FontB = 0;

  Skin_FontHighlightR = 0.3; // 0.3
  Skin_FontHighlightG = 0.3; // 0.3
  Skin_FontHighlightB = 1;   // 1

  Skin_TimeR = 0.25; //0,0,0
  Skin_TimeG = 0.25;
  Skin_TimeB = 0.25;

  Skin_OscR = 0;
  Skin_OscG = 0;
  Skin_OscB = 0;

  Skin_SpectrumT = 470;
  Skin_SpectrumBot = 570;
  Skin_SpectrumH = 100;

  Skin_P1_LinesR = 0.5;  // 0.6 0.6 1
  Skin_P1_LinesG = 0.5;
  Skin_P1_LinesB = 0.5;

  Skin_P2_LinesR = 0.5; // 1 0.6 0.6
  Skin_P2_LinesG = 0.5;
  Skin_P2_LinesB = 0.5;

  Skin_P1_NotesB = 250;
  Skin_P2_NotesB = 430; // 430 / 300

  Skin_P1_ScoreT = 50;
  Skin_P1_ScoreL = 20;

  Skin_P2_ScoreT = 50;
  Skin_P2_ScoreL = 640;

procedure Initialize3D (Title: string);
procedure Finalize3D;
procedure SwapBuffers;

procedure LoadTextures;
procedure InitializeScreen(Title: string);
procedure LoadScreens;
procedure UnloadScreens;

procedure UpdateResolution;
procedure UpdateVideoMode;

procedure SetVideoMode(Mode: FullscreenModes);
function SwitchVideoMode(Mode: FullscreenModes): FullscreenModes;
function HasWindowState(Flag: integer): boolean;

// events
procedure OnWindowMoved(x,y: integer);
procedure OnWindowResized(w,h: integer);

implementation

procedure UnloadFontTextures;
begin
  Log.LogStatus('Kill Fonts', 'UnloadFontTextures');
  KillFonts;
end;

procedure LoadTextures;
begin
  TextGL.BuildFonts; //font textures
  Texture := TTextureUnit.Create;
  Texture.Limit := 1920; //currently, Full HD is all we want. switch to 64bit target before going further up
  //TODO this textures must be loaded in file that use it, but need more OOP to do this...
  Tex_Lyric_Help_Bar := Texture.LoadTexture('LyricHelpBar', TEXTURE_TYPE_TRANSPARENT);
  Tex_TimeProgress := Texture.LoadTexture('TimeBar');
  Tex_JukeboxTimeProgress := Texture.LoadTexture('JukeboxTimeBar');
end;

const
  WINDOW_ICON = 'icons/WorldParty.png';

procedure Initialize3D(Title: string);
begin
  InitializeScreen(Title);
  LoadTextures();

  //screen loading
  ScreenLoading := TScreenLoading.Create;
  Display := TDisplay.Create;
  Display.CurrentScreen := @ScreenLoading;
  SwapBuffers;
  ScreenLoading.Draw;
  SwapBuffers;

  // this would be run in the loadingthread
  LoadScreens();

  Display.CurrentScreen^.FadeTo(@ScreenMain);
end;

procedure SwapBuffers;
begin
  SDL_GL_SwapWindow(Screen);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0, RenderW, RenderH, 0, -1, 100);
  glMatrixMode(GL_MODELVIEW);
end;

procedure Finalize3D;
begin
  UnloadFontTextures;
  SDL_QuitSubSystem(SDL_INIT_VIDEO);
end;

procedure InitializeScreen(Title: string);
var
  S:      string;
  W, H:   integer;
  X, Y:   integer; // offset for re-positioning
  Borderless, Fullscreen: boolean;
  Split: boolean;
  Disp: TSDL_DisplayMode;

label
  NoDoubledResolution;

begin
  if (Params.Screens <> -1) then
    Screens := Params.Screens + 1
  else
    Screens := Ini.Screens + 1;
  case Params.Split of
    spmSplit:
      Split := True;
    spmNoSplit:
      Split := False;
    else
      Split := Ini.Split = 1;
  end; // case

  // check whether to start in fullscreen, windowed mode or borderless mode (windowed fullscreen).
  // The command-line parameters take precedence over the ini settings.
  Borderless := (Ini.FullScreen = 2) and (Params.ScreenMode <> scmFullscreen);
  Fullscreen := ((Ini.FullScreen = 1) or (Params.ScreenMode = scmFullscreen)) and
                not (Params.ScreenMode = scmWindowed);

  // If there is a resolution in Parameters, use it, else use the Ini value
  // check for a custom resolution (in the format of WIDTHxHEIGHT) or try validating ID from TIni
  if ParseResolutionString(Params.CustomResolution, W, H) then
    Log.LogStatus(Format('Use custom resolution from Command line: %d x %d', [W, H]), 'SDL_SetVideoMode')
  else if Ini.GetResolution(Params.Resolution, S) and ParseResolutionString(S, W, H) then
    Log.LogStatus(Format('Use resolution by index from command line: %d x %d [%d]', [W, H, Params.Resolution]), 'SDL_SetVideoMode')
  else if Fullscreen then
  begin
    Log.LogStatus('Use config fullscreen resolution', 'SDL_SetVideoMode');
    S := Ini.GetResolutionFullscreen(W, H);

    // fullscreen resolution shouldn't be doubled as it would not allow running real fullscreen
    // in a specific resolution if desired and required for some TVs/monitors/display devices
    Goto NoDoubledResolution;
  end
  else
  begin
    Log.LogStatus('Use config resolution', 'SDL_SetVideoMode');
    S := Ini.GetResolution(W, H);

    // hackfix to prevent a doubled resolution twice as GetResolution(int,int) is already doubling the resolution
    Goto NoDoubledResolution;
  end;

  // hacky fix to support multiplied resolution (in width) in multiple screen setup (Screens=2 and more)
  // TODO: RattleSN4K3: Improve the way multiplied screen resolution is applied and stored (see UGraphics::InitializeScreen; W := W * Screens)
  if ((Screens > 1) and not Split) then
  	W := W * Screens;

NoDoubledResolution:

  Log.LogStatus('Creating window', 'SDL_SetVideoMode');

  // TODO: use SDL renderer (for proper scale in "real fullscreen"). Able to choose rendering mode (OpenGL, OpenGL ES, Direct3D)
  if Borderless then
  begin
    Log.LogStatus('Set Video Mode...   Borderless fullscreen', 'SDL_SetVideoMode');
    CurrentWindowMode := Mode_Borderless;
    screen := SDL_CreateWindow('Loading...',
              SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, W, H, SDL_WINDOW_OPENGL or SDL_WINDOW_FULLSCREEN_DESKTOP or SDL_WINDOW_RESIZABLE);
  end
  else if Fullscreen then
  begin
    Log.LogStatus('Set Video Mode...   Fullscreen', 'SDL_SetVideoMode');
    CurrentWindowMode := Mode_Fullscreen;
    screen := SDL_CreateWindow('UltraStar Deluxe loading...',
              SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, W, H, SDL_WINDOW_OPENGL or SDL_WINDOW_FULLSCREEN or SDL_WINDOW_RESIZABLE);
  end
  else
  begin
    Log.LogStatus('Set Video Mode...   Windowed', 'SDL_SetVideoMode');
    CurrentWindowMode := Mode_Windowed;
    screen := SDL_CreateWindow('UltraStar Deluxe loading...',
              SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, W, H, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE);
  end;

  //SDL_ShowCursor(0);    just to be able to debug while having mosue cursor

  if (screen = nil) then
  begin
    Log.LogCritical('Creating window failed', 'SDL_SetVideoMode');
  end
  else
  begin
    X:=0; Y:=0;

    // check if created window has the desired size, otherwise override the config resolution value
    if SDL_GetWindowDisplayMode(screen, @Disp) = 0 then
    begin
      if (Disp.w < W) or (Disp.h < H) then
      begin
        Log.LogStatus(Format('Video resolution (%s) exceeded possible size (%s). Override stored config resolution!', [BuildResolutionString(W,H), BuildResolutionString(Disp.w, Disp.h)]), 'SDL_SetVideoMode');
        Ini.SetResolution(Disp.w, Disp.h, true);
      end
      else if Fullscreen and ((Disp.w > W) or (Disp.h > H)) then
      begin
        Log.LogStatus(Format('Video resolution not used. Using native fullscreen resolution (%s)', [BuildResolutionString(Disp.w, Disp.h)]), 'SDL_SetVideoMode');
        Ini.SetResolution(Disp.w, Disp.h, false, true);
      end;

      X := Disp.w - Screen.w;
      Y := Disp.h - Screen.h;
    end;

    // if screen is out of the visisble desktop area, move it back
    // this likely happens when creating a Window bigger than the possible desktop size
    if (SDL_GetWindowFlags(screen) and SDL_WINDOW_FULLSCREEN = 0) and ((screen.x < 0) or (screen.Y < 0)) then
    begin
      // TODO: update SDL2
      //SDL_GetWindowBordersSize(screen, w, h, nil, nil);
      Log.LogStatus('Bad position for window. Re-position to (0,0)', 'SDL_SetVideoMode');
      SDL_SetWindowPosition(screen, x, y+x);
    end;
  end;

  //LoadOpenGL();
  glcontext := SDL_GL_CreateContext(Screen);
  InitOpenGL();

  //   ActivateRenderingContext(
  ReadExtensions;
  ReadImplementationProperties;
  Log.LogInfo('OpenGL vendor ' + glGetString(GL_VENDOR), 'UGraphic.InitializeScreen');
  if not (glGetError = GL_NO_ERROR) then
  begin
    Log.LogInfo('an OpenGL Error happened.', 'UGraphic.InitializeScreen');
  end;
  Log.LogInfo('OpenGL renderer ' + glGetString(GL_RENDERER), 'UGraphic.InitializeScreen');
  Log.LogInfo('OpenGL version ' + glGetString(GL_VERSION), 'UGraphic.InitializeScreen');


  // define virtual (Render) and real (Screen) screen size
  RenderW := 800;
  RenderH := 600;
  ScreenW := Screen.w;
  ScreenH := Screen.h;
  // Activate Vertical synchronization (Limits FPS to 60, saving power in GPU)
  SDL_GL_SetSwapInterval(1); // VSYNC (currently Windows only)

  {// clear screen once window is being shown
  // Note: SwapBuffers uses RenderW/H, so they must be defined before
  glClearColor(1, 1, 1, 1);
  glClear(GL_COLOR_BUFFER_BIT);
  SwapBuffers;}

  SDL_SetWindowTitle(Screen, PChar(Title));
  SDL_SetWindowIcon(Screen, UImage.LoadImage(UPathUtils.ResourcesPath.Append(WINDOW_ICON))); //load icon image (must be 32x32 for win32)
end;

function HasWindowState(Flag: integer): boolean;
begin
  Result := SDL_GetWindowFlags(screen) and Flag <> 0;
end;

procedure UpdateResolution();
  var
    Disp: TSDL_DisplayMode;
    Event: TSDL_event;
begin
  if CurrentWindowMode = Mode_Borderless then Exit;
  case CurrentWindowMode of
    Mode_Fullscreen:
    begin
      SDL_GetWindowDisplayMode(screen, @Disp); // TODO: verify if not failed
      Ini.GetResolutionFullscreen(Disp.W, Disp.H); // we use the fullscreen resolution without being doubled, true fullscreen uses non-multiplied one
      SDL_SetWindowDisplayMode(screen, @Disp);
      SDL_SetWindowSize(screen, Disp.W, Disp.H);
    end;
    Mode_Windowed:
    begin
      Ini.GetResolution(Disp.W, Disp.H);
      SDL_SetWindowSize(screen, Disp.W, Disp.H);

      // re-center window if it wasn't moved already, keeps it centered
      if not HasValidPosition then
      begin
        SDL_SetWindowPosition(screen, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
      end;

      // simulate window re-drawing, otherwise the context will be different sized
      Event.user.type_ := SDL_WINDOWEVENT;
      Event.window.event := SDL_WINDOWEVENT_RESIZED;
      Event.window.data1 := Disp.W;
      Event.window.data2 := Disp.H;
      SDL_PushEvent(@Event);
    end;
  end;
end;

procedure UpdateVideoMode();
  var
    Mode: FullscreenModes;
begin
  if Ini.Fullscreen = 1 then Mode := Mode_Fullscreen
  else if Ini.FullScreen = 2 then Mode := Mode_Borderless
  else Mode := Mode_Windowed;

  SetVideoMode(Mode);
end;

procedure SetVideoMode(Mode: FullscreenModes);
  var
    Disp: TSDL_DisplayMode;
begin
  if Mode = CurrentWindowMode then Exit;
  if Mode >= Mode_Fullscreen then
  begin
    Mode := Mode and not Mode_Borderless;
    SDL_GetWindowDisplayMode(screen, @Disp);
    SDL_SetWindowFullscreen(screen, SDL_WINDOW_FULLSCREEN);

    Ini.GetResolutionFullscreen(Disp.W, Disp.H);
    SDL_SetWindowDisplayMode(screen, @Disp);
    SDL_SetWindowSize(screen, Disp.W, Disp.H);
  end
  else if Mode = Mode_Borderless then
  begin
    // calls window-resize event which updates screen sizes
    SDL_SetWindowFullscreen(screen, SDL_WINDOW_FULLSCREEN_DESKTOP);
  end
  else if Mode = Mode_Windowed then
  begin
    WindowModeDirty := true; // set window size dirty to restore old size after switching from fullscreen
    SDL_SetWindowFullscreen(screen, SDL_WINDOW_RESIZABLE); // calls window-resize event which updates screen sizes

    ScreenW := LastW; ScreenH := LastH;
    if not HasValidSize then Ini.GetResolution(ScreenW, ScreenH);
    SDL_SetWindowSize(screen, ScreenW, ScreenH);
  end;

  CurrentWindowMode := Mode;
end;

function SwitchVideoMode(Mode: FullscreenModes): FullscreenModes;
begin
  if Mode = Mode_Windowed then Mode := CurrentWindowMode;
  SetVideoMode(CurrentWindowMode xor Mode);
  Result := CurrentWindowMode;
end;

procedure OnWindowMoved(x,y: integer);
begin
  if CurrentWindowMode <> Mode_Windowed then Exit;
  if (SDL_GetWindowFlags(screen) and (SDL_WINDOW_MINIMIZED or SDL_WINDOW_MAXIMIZED) <> 0) then Exit;

  if not WindowModeDirty then
  begin
    HasValidPosition := true;
    LastX := x;
    LastY := y;
  end;
end;

procedure OnWindowResized(w,h: integer);
begin
  if WindowModeDirty and not HasWindowState(SDL_WINDOW_FULLSCREEN) then
  begin
    if not HasValidSize then
    begin
      LastH := ScreenH;
      LastW := ScreenW;
    end;

    // restoring from maximized state will additionally call a SDL_WINDOWEVENT_RESIZED event
    // we keep the dirty flag to still revert to the last none-maximized stored position and size
    if HasWindowState(SDL_WINDOW_MINIMIZED or SDL_WINDOW_MAXIMIZED) then
    begin
      SDL_RestoreWindow(screen);
    end
    else
    begin
      WindowModeDirty := false;
    end;

    // override render size
    ScreenW := LastW;
    ScreenH := LastH;
    SDL_SetWindowPosition(screen, LastX, LastY);

    // if there wasn't a windowed mode before, center window
    if not HasValidPosition then
    begin
      SDL_SetWindowPosition(screen, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
    end;
  end
  else
  begin
    // override render size
    ScreenW := w; ScreenH := h;

    if not HasWindowState(SDL_WINDOW_MAXIMIZED or SDL_WINDOW_FULLSCREEN) then
    begin
      HasValidSize := true;
      LastW := w;
      LastH := h;
    end;
  end;

  if CurrentWindowMode = Mode_Fullscreen then
  begin
    Screen.W := ScreenW;
    Screen.H := ScreenH;
  end
  else
  begin
    SDL_SetWindowSize(screen, ScreenW, ScreenH);
  end;

  if assigned(Display) then
  begin
    Display.OnWindowResized(); // notify display window has changed
  end;
end;

{ Load common screens }
procedure LoadScreens;
begin
  ScreenOpen := TScreenOpen.Create();
  ScreenPopupCheck := TScreenPopupCheck.Create();
  ScreenPopupError := TScreenPopupError.Create();
  ScreenPopupInfo := TScreenPopupInfo.Create();
  ScreenMain := TScreenMain.Create;
end;

procedure ShowStatus(Status: string);
begin
  ScreenMain.Text[3].Text := Status;
end;

{ Free screen variables in all cases, with an instance or not }
procedure UnloadScreens;
begin
  FreeAndNil(ScreenMain);
  FreeAndNil(ScreenPlayerSelector);
  FreeAndNil(ScreenSong);
  FreeAndNil(ScreenScore);
  FreeAndNil(ScreenOptions);
  FreeAndNil(ScreenOptionsGame);
  FreeAndNil(ScreenOptionsGraphics);
  FreeAndNil(ScreenOptionsSound);
  FreeAndNil(ScreenOptionsLyrics);
  FreeAndNil(ScreenOptionsThemes);
  FreeAndNil(ScreenOptionsMicrophones);
  FreeAndNil(ScreenOptionsAdvanced);
  FreeAndNil(ScreenOptionsNetwork);
  FreeAndNil(ScreenOptionsWebcam);
  FreeAndNil(ScreenOptionsProfiles);
  FreeAndNil(ScreenJukebox);
  FreeAndNil(ScreenJukeboxOptions);
  FreeAndNil(ScreenJukeboxPlaylist);
  FreeAndNil(ScreenTop5);
  FreeAndNil(ScreenOpen);
  FreeAndNil(ScreenAbout);
  FreeAndNil(ScreenDevelopers);
  FreeAndNil(ScreenSongMenu);
  FreeAndNil(ScreenPopupCheck);
  FreeAndNil(ScreenPopupError);
  FreeAndNil(ScreenPopupInfo);
  FreeAndNil(ScreenPopupInsertUser);
  FreeAndNil(ScreenPopupSendScore);
  FreeAndNil(ScreenPopupScoreDownload);
  FreeAndNil(ScreenPartyNewRound);
  FreeAndNil(ScreenPartyScore);
  FreeAndNil(ScreenPartyWin);
  FreeAndNil(ScreenPartyOptions);
  FreeAndNil(ScreenPartyPlayer);
  FreeAndNil(ScreenPartyRounds);
  FreeAndNil(ScreenPartyTournamentRounds);
  FreeAndNil(ScreenPartyTournamentPlayer);
  FreeAndNil(ScreenPartyTournamentOptions);
  FreeAndNil(ScreenPartyTournamentWin);
  FreeAndNil(ScreenStatMain);
  FreeAndNil(ScreenStatDetail);
end;

end.
