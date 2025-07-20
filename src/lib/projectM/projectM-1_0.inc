// ProjectM Delphi Interface Unit
// Maintains compatibility with all projectM versions from 1.0 onwards

// Note on ProjectM versioning scheme:
// Version  | Version in pkg-config .pc file
// ---------+--------------------------------------------
// 1.00     | 1.00
// 1.01     | 1.00
// 1.1      | 1.10
// 1.2      | 1.2 (= 1.02)
//
// Important: Version 1.1 is numerically greater than 1.2 in this scheme

const
{$IFDEF MSWINDOWS}
  // Windows uses dynamic linking
  libprojectM_cwrapper = 'projectM-cwrapper.dll';
{$ELSE}
  // Unix-like systems use static linking for cwrapper and dynamic for projectM
  libprojectM_cwrapper = '';
  {$L 'cwrapper/libprojectM-cwrapper.a'}
  {$LINKLIB projectM}
{$ENDIF}

{**************** INTERNAL SECTION - C FUNCTION DECLARATIONS ****************}

type
  _PProjectM = Pointer; // Opaque pointer to projectM instance

{ Core projectM functions }
function _projectM_create1(config_file: PChar): _PProjectM; cdecl; external libprojectM_cwrapper name 'projectM_create1';

{$IF (PROJECTM_VERSION < 1000000) or (PROJECTM_VERSION >= 2000000)}
function _projectM_create2(gx: cint; gy: cint; fps: cint;
  texsize: cint; width: cint; height: cint;
  preset_url: PChar; title_fonturl: PChar; title_menuurl: PChar): _PProjectM; 
  cdecl; external libprojectM_cwrapper name 'projectM_create2';
{$IFEND}

procedure _projectM_resetGL(pm: _PProjectM; width: cint; height: cint); cdecl; external libprojectM_cwrapper name 'projectM_resetGL';
procedure _projectM_setTitle(pm: _PProjectM; title: PChar); cdecl; external libprojectM_cwrapper name 'projectM_setTitle';
procedure _projectM_renderFrame(pm: _PProjectM); cdecl; external libprojectM_cwrapper name 'projectM_renderFrame';
function _projectM_initRenderToTexture(pm: _PProjectM): cuint; cdecl; external libprojectM_cwrapper name 'projectM_initRenderToTexture';
procedure _projectM_free(pm: _PProjectM); cdecl; external libprojectM_cwrapper name 'projectM_free';

{ Input handling functions }
procedure _projectM_key_handler(pm: _PProjectM; event: TProjectMEvent;
  keycode: TProjectMKeycode; modifier: TProjectMModifier); cdecl; external libprojectM_cwrapper name 'projectM_key_handler';

{$IF PROJECTM_VERSION > 1000000} // Versions > 1.01
procedure _projectM_settings(pm: _PProjectM; settings: PSettings); cdecl; external libprojectM_cwrapper name 'projectM_settings';
{$IFEND}

{ Audio processing functions }
procedure _PCM_addPCMfloat(pm: _PProjectM; pcm_data: PSingle; samples: cint); cdecl; external libprojectM_cwrapper name 'PCM_addPCMfloat';
procedure _PCM_addPCM16(pm: _PProjectM; pcm_data: PPCM16); cdecl; external libprojectM_cwrapper name 'PCM_addPCM16';
procedure _PCM_addPCM16Data(pm: _PProjectM; pcm_data: PCshort; samples: cshort); cdecl; external libprojectM_cwrapper name 'PCM_addPCM16Data';
procedure _PCM_addPCM8_512(pm: _PProjectM; pcm_data: PPCM8_512); cdecl; external libprojectM_cwrapper name 'PCM_addPCM8_512';
procedure _PCM_addPCM8_1024(pm: _PProjectM; pcm_data: PPCM8_1024); cdecl; external libprojectM_cwrapper name 'PCM_addPCM8';

{**************** EXTERNAL SECTION - CLASS IMPLEMENTATION ****************}

constructor TProjectM.Create(const configFile: string);
begin
  inherited Create();

  // Validate config file before passing to C++ layer
  if not FileExists(configFile) then
    raise Exception.Create('Configuration file not found: ' + configFile);

  data := _projectM_create1(PChar(configFile));
  if data = nil then
    raise Exception.Create('Failed to create projectM instance');
end;

{$IF PROJECTM_VERSION >= 2000000} // Versions > 1.01
constructor TProjectM.Create(gx, gy: integer; fps: integer;
  texsize: integer; width, height: integer;
  const presetsDir, fontsDir: string;
  const titleFont, menuFont: string);
begin
  inherited Create();
  
  // Construct full paths for font files
  data := _projectM_create2(gx, gy, fps, texsize, width, height,
            PChar(presetsDir),
            PChar(IncludeTrailingPathDelimiter(fontsDir) + titleFont,
            PChar(IncludeTrailingPathDelimiter(fontsDir) + menuFont));
            
  if data = nil then
    raise Exception.Create('Failed to create projectM instance with parameters');
end;
{$IFEND}

procedure TProjectM.ResetGL(width, height: Integer);
begin
  _projectM_resetGL(data, width, height);
end;

procedure TProjectM.SetTitle(const title: string);
begin
  _projectM_setTitle(data, PChar(title));
end;

procedure TProjectM.RenderFrame;
begin
  _projectM_renderFrame(data);
end;

{ Audio input methods }
procedure TProjectM.AddPCMfloat(pcmData: PSingle; samples: integer);
begin
  _PCM_addPCMfloat(data, pcmData, samples);
end;

procedure TProjectM.AddPCM16(pcmData: PPCM16);
begin
  _PCM_addPCM16(data, pcmData);
end;

procedure TProjectM.AddPCM16Data(pcmData: PSmallint; samples: Smallint);
begin
  _PCM_addPCM16Data(data, PCshort(pcmData), samples);
end;

procedure TProjectM.AddPCM8_512(pcmData: PPCM8_512);
begin
  _PCM_addPCM8_512(data, pcmData);
end;

procedure TProjectM.AddPCM8_1024(pcmData: PPCM8_1024);
begin
  _PCM_addPCM8_1024(data, pcmData);
end;

function TProjectM.InitRenderToTexture: GLuint;
begin
  Result := _projectM_initRenderToTexture(data);
end;

{ Preset control methods }
procedure TProjectM.KeyHandler(event: TProjectMEvent;
                               keycode: TProjectMKeycode;
                               modifier: TProjectMModifier);
begin
  _projectM_key_handler(data, event, keycode, modifier);
end;

procedure TProjectM.RandomPreset;
begin
  KeyHandler(PROJECTM_KEYDOWN, PROJECTM_K_r_LOWERCASE, PROJECTM_KMOD_LSHIFT);
end;

procedure TProjectM.PreviousPreset;
begin
  KeyHandler(PROJECTM_KEYDOWN, PROJECTM_K_p_LOWERCASE, PROJECTM_KMOD_LSHIFT);
end;

procedure TProjectM.NextPreset;
begin
  KeyHandler(PROJECTM_KEYDOWN, PROJECTM_K_n_LOWERCASE, PROJECTM_KMOD_LSHIFT);
end;

procedure TProjectM.ToggleShowPresetNames;
begin
  KeyHandler(PROJECTM_KEYDOWN, PROJECTM_K_F3, PROJECTM_KMOD_LSHIFT);
end;

{$IF PROJECTM_VERSION > 1000000} // Versions > 1.01
procedure TProjectM.Settings(var settings: TSettings);
begin
  _projectM_settings(data, @settings);
end;
{$IFEND}

destructor TProjectM.Destroy;
begin
  if data <> nil then
    _projectM_free(data);
  inherited Destroy;
end;