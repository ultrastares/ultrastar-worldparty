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

unit UTexture;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  dglOpenGL,
  Classes,
  SysUtils,
  UCommon,
  UPath,
  sdl2,
  SDL2_image;

type
  PTexture = ^TTexture;
  TTexture = record
    TexNum:   GLuint;
    X:        real;
    Y:        real;
    Z:        real;
    W:        real;
    H:        real;
    PaddingX: integer;
    PaddingY: integer;
    ScaleW:   real; // for dynamic scalling while leaving width constant
    ScaleH:   real; // for dynamic scalling while leaving height constant
    Rot:      real; // 0 - 2*pi
    RightScale: real; //
    LeftScale:  real; //
    Int:      real; // intensity
    ColR:     real;
    ColG:     real;
    ColB:     real;
    TexW:     real; // percentage of width to use [0..1]
    TexH:     real; // percentage of height to use [0..1]
    TexX1:    real;
    TexY1:    real;
    TexX2:    real;
    TexY2:    real;
    Alpha:    real;
    Name:     IPath; // experimental for handling cache images. maybe it's useful for dynamic skins
  end;

type
  TTextureType = (
    TEXTURE_TYPE_PLAIN,        // Plain (alpha = 1)
    TEXTURE_TYPE_TRANSPARENT,  // Alpha is used
    TEXTURE_TYPE_COLORIZED     // Alpha is used; Hue of the HSV color-model will be replaced by a new value
  );

const
  TextureTypeStr: array[TTextureType] of string = (
    'Plain',
    'Transparent',
    'Colorized'
  );

function TextureTypeToStr(TexType: TTextureType): string;
function ParseTextureType(const TypeStr: string; Default: TTextureType): TTextureType;

procedure AdjustPixelFormat(var TexSurface: PSDL_Surface; Typ: TTextureType);

type
  PTextureEntry = ^TTextureEntry;
  TTextureEntry = record
    Name:         IPath;
    Typ:          TTextureType;
    Color:        cardinal;

    // we use normal TTexture, it's easier to implement and if needed - we copy ready data
    Texture:      TTexture; // Full-size texture
  end;

  TTextureUnit = class
    public
      Limit: integer;

      function LoadTexture(const Identifier: UTF8String; Typ: TTextureType = TEXTURE_TYPE_PLAIN; Col: LongWord = 0): TTexture; overload;
      function LoadTexture(const Identifier: IPath; Typ: TTextureType = TEXTURE_TYPE_PLAIN; Col: LongWord = 0): TTexture; overload;
      procedure UnLoadTexture(var Texture: TTexture);
      function CreateTexture(Data: PChar; const Name: IPath; Width, Height: word; BitsPerPixel: byte): TTexture;
      constructor Create;
  end;

var
  Texture: TTextureUnit;
  SupportsNPOT: Boolean;
implementation

uses
  DateUtils,
  Math,
  StrUtils,
  UImage,
  ULog,
  USkins,
  UThemes;

procedure AdjustPixelFormat(var TexSurface: PSDL_Surface; Typ: TTextureType);
var
  NeededPixFmt: UInt32;
begin
  NeededPixFmt := IfThen(Typ = TEXTURE_TYPE_PLAIN, SDL_PIXELFORMAT_RGB24, SDL_PIXELFORMAT_ABGR8888);
  if TexSurface^.format.format <> NeededPixFmt then
    TexSurface := SDL_ConvertSurfaceFormat(TexSurface, NeededPixFmt, 0);
end;

{ TTextureUnit }

constructor TTextureUnit.Create;
begin
  inherited Create;
  Log.LogInfo('OpenGL vendor ' + glGetString(GL_VENDOR), 'TTextureUnit.Create');
  Log.LogInfo('OpenGL renderer ' + glGetString(GL_RENDERER), 'TTextureUnit.Create');
  Log.LogInfo('OpenGL version ' + glGetString(GL_VERSION), 'TTextureUnit.Create');
  SupportsNPOT := (AnsiContainsStr(glGetString(GL_EXTENSIONS),'texture_non_power_of_two')) and not (AnsiContainsStr(glGetString(GL_EXTENSIONS), 'Radeon X16'));
  Log.LogInfo('OpenGL TextureNPOT-support: ' + BoolToStr(SupportsNPOT), 'TTextureUnit.Create');
end;

function TTextureUnit.LoadTexture(const Identifier: UTF8String; Typ: TTextureType; Col: LongWord): TTexture;
begin
  Result := Self.LoadTexture(USkins.Skin.GetTextureFileName(Identifier), Typ, Col);
end;

function TTextureUnit.LoadTexture(const Identifier: IPath; Typ: TTextureType; Col: LongWord): TTexture;
var
  TexSurface: PSDL_Surface;
  newWidth, newHeight: integer;
  oldWidth, oldHeight: integer;
  ActTex: GLuint;
begin
  // zero texture data
  FillChar(Result, SizeOf(Result), 0);

  if (Identifier = nil) or (Identifier.IsUnset()) then
    Exit;

  // load texture data into memory
  TexSurface := LoadImage(Identifier);
  if not Assigned(TexSurface) then
  begin
    SDL_FreeSurface(TexSurface);
    Log.LogError('Could not load texture: "' + Identifier.ToNative() +'" with type "'+ TextureTypeToStr(Typ) +'"', 'TTextureUnit.LoadTexture');
    Exit;
  end;

  // convert pixel format as needed
  AdjustPixelFormat(TexSurface, Typ);

  // adjust texture size (scale down, if necessary)
  newWidth   := TexSurface.W;                            //basisbit ToDo make images scale in size and keep ratio?
  newHeight  := TexSurface.H;

  if (newWidth > Limit) then
    newWidth := Limit;

  if (newHeight > Limit) then
    newHeight := Limit;

  if (TexSurface.W > newWidth) or (TexSurface.H > newHeight) then
    ScaleImage(TexSurface, newWidth, newHeight);

  // now we might colorize the whole thing
  if (Typ = TEXTURE_TYPE_COLORIZED) then
    ColorizeImage(TexSurface, Col);

  // save actual dimensions of our texture
  oldWidth  := newWidth;
  oldHeight := newHeight;

  {if (SupportsNPOT = false) then
  begin}
  // make texture dimensions be powers of 2
  newWidth  := Round(Power(2, Ceil(Log2(newWidth))));
  newHeight := Round(Power(2, Ceil(Log2(newHeight))));
  if (newHeight <> oldHeight) or (newWidth <> oldWidth) then
    FitImage(TexSurface, newWidth, newHeight);
  {end;}

  // at this point we have the image in memory...
  // scaled so that dimensions are powers of 2
  // and converted to either RGB or RGBA

  // if we got a Texture of Type Plain, Transparent or Colorized,
  // then we're done manipulating it
  // and could now create our openGL texture from it

  // prepare OpenGL texture
  glGenTextures(1, @ActTex);
  glBindTexture(GL_TEXTURE_2D, ActTex);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexImage2D( //load data into gl texture
    GL_TEXTURE_2D,
    0,
    IfThen((Typ = TEXTURE_TYPE_TRANSPARENT) or (Typ = TEXTURE_TYPE_COLORIZED), GL_RGBA, 3), //idk why 3, maybe is a constant...
    newWidth,
    newHeight,
    0,
    IfThen((Typ = TEXTURE_TYPE_TRANSPARENT) or (Typ = TEXTURE_TYPE_COLORIZED), GL_RGBA, GL_RGB),
    GL_UNSIGNED_BYTE,
    TexSurface.pixels
  );

  // setup texture struct
  with Result do
  begin
    X := 0;
    Y := 0;
    Z := 0;
    W := oldWidth;
    H := oldHeight;
    ScaleW := 1;
    ScaleH := 1;
    Rot := 0;
    TexNum := ActTex;
    TexW := oldWidth / newWidth;
    TexH := oldHeight / newHeight;

    Int   := 1;
    ColR  := 1;
    ColG  := 1;
    ColB  := 1;
    Alpha := 1;

    // new test - default use whole texure, taking TexW and TexH as const and changing these
    TexX1 := 0;
    TexY1 := 0;
    TexX2 := 1;
    TexY2 := 1;

    RightScale := 1;
    LeftScale := 1;

    Name := Identifier;
  end;

  SDL_FreeSurface(TexSurface);
end;

procedure TTextureUnit.UnLoadTexture(var Texture: TTexture);
begin
  glDeleteTextures(1, PGLuint(@Texture.TexNum));
  Texture.TexNum := 0;
end;

function TTextureUnit.CreateTexture(Data: PChar; const Name: IPath; Width, Height: word; BitsPerPixel: byte): TTexture;
var
  //Error:     integer;
  ActTex:    GLuint;
begin
  glGenTextures(1, @ActTex); // ActText = new texture number
  glBindTexture(GL_TEXTURE_2D, ActTex);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexImage2D(GL_TEXTURE_2D, 0, 3, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, Data);

{
  if Mipmapping then
  begin
    Error := gluBuild2DMipmaps(GL_TEXTURE_2D, 3, W, H, GL_RGB, GL_UNSIGNED_BYTE, @Data[0]);
// FPC_BIG_ENDIAN   Error := gluBuild2DMipmaps(GL_TEXTURE_2D, 3, W, H, GL_BGR, GL_UNSIGNED_BYTE, @Data[0]);
    if Error > 0 then
      Log.LogError('gluBuild2DMipmaps() failed', 'TTextureUnit.CreateTexture');
  end;
}

  Result.X := 0;
  Result.Y := 0;
  Result.Z := 0;
  Result.W := 0;
  Result.H := 0;
  Result.ScaleW := 1;
  Result.ScaleH := 1;
  Result.Rot := 0;
  Result.TexNum := ActTex;
  Result.TexW := 1;
  Result.TexH := 1;

  Result.Int := 1;
  Result.ColR := 1;
  Result.ColG := 1;
  Result.ColB := 1;
  Result.Alpha := 1;

  // new test - default use whole texure, taking TexW and TexH as const and changing these
  Result.TexX1 := 0;
  Result.TexY1 := 0;
  Result.TexX2 := 1;
  Result.TexY2 := 1;

  Result.RightScale := 1;
  Result.LeftScale := 1;

  Result.Name := Name;
end;

function TextureTypeToStr(TexType: TTextureType): string;
begin
  Result := TextureTypeStr[TexType];
end;

function ParseTextureType(const TypeStr: string; Default: TTextureType): TTextureType;
var
  TextureType:   TTextureType;
  UpCaseStr: string;
begin
  UpCaseStr := UpperCase(TypeStr);
  for TextureType := Low(TextureTypeStr) to High(TextureTypeStr) do
  begin
    if (UpCaseStr = UpperCase(TextureTypeStr[TextureType])) then
    begin
      Result := TextureType;
      Exit;
    end;
  end;
  //Log.LogInfo('Unknown texture type: "' + TypeStr + '". Using default texture type "'
  //    + TextureTypeToStr(Default) + '"', 'UTexture.ParseTextureType');
  Result := Default;
end;

end.
