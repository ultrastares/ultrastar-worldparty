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

unit TextGL;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  dglOpenGL,
  sdl2,
  Classes,
  UCommon,
  UFont,
  ULog,
  UPath,
  UTexture;

type
  PGLFont = ^TGLFont;
  TGLFont = record
    Font:     TScalableFont;
    Outlined: boolean;
    X, Y, Z:  real;
  end;

const
  ftNormal = 0;
  ftOutline1 = 1;
  ftOutline2 = 2;
  ftBold = 3;
  ftBoldHighRes = 4;

var
  Fonts:   array of TGLFont;
  ActFont: integer;
  OutlineColor: TRGB;

procedure BuildFonts;                         // builds all fonts
procedure KillFonts;                          // deletes all font
function  glTextWidth(const text: UTF8String): real; // returns text width
procedure glPrint(const text: UTF8String);    // custom GL "Print" routine
procedure ResetFont();                        // reset font settings of active font
procedure SetFontPos(X, Y: real; NewLine: integer = 0); // sets X and Y
procedure SetFontZ(Z: real);                  // sets Z
procedure SetFontSize(Size: real);
procedure SetFontStyle(Style: integer);       // sets active font style (normal, bold, etc)
procedure SetFontItalic(Enable: boolean);     // sets italic type letter (works for all fonts)
procedure SetFontReflection(Enable:boolean;Spacing: real); // enables/disables text reflection
procedure SetOutlineColor(R, G, B, A: GLFloat); // set outline color
procedure SetOutlineAlpha(A: GLFloat); //only update outline alpha

implementation

uses
  UTextEncoding,
  SysUtils,
  IniFiles,
  UMain,
  UPathUtils;

{**
 * Returns either Filename if it is absolute or a path relative to FontPath.
 *}
function FindFontFile(const Filename: string): IPath;
begin
  Result := FontPath.Append(Filename);
  // if path does not exist, try as an absolute path
  if (not Result.IsFile) then
    Result := Path(Filename);
end;

procedure AddFontFallbacks(FontIni: TMemIniFile; Font: TFont);
var
  FallbackFont: IPath;
  IdentName: string;
  I: Integer;
begin
  // evaluate the ini-file's 'Fallbacks' section
  for I := 1 to 10 do
  begin
    IdentName := 'File' + IntToStr(I);
    FallbackFont := FindFontFile(FontIni.ReadString('Fallbacks', IdentName, ''));
    if (FallbackFont.Equals(PATH_NONE)) then
      Continue;
    try
      Font.AddFallback(FallbackFont);
    except
      on E: EFontError do
        Log.LogError('Setting font fallback ''' + FallbackFont.ToNative() + ''' failed: ' + E.Message);
    end;
  end;
end;

const
  FONT_NAMES: array [0..4] of string = (
    'Normal', 'Bold', 'Outline1', 'Outline2', 'BoldHighRes'
  );

procedure BuildFonts;
var
  I: integer;
  FontIni: TMemIniFile;
  FontFile: IPath;
  FontMaxResolution: Integer;
  FontPreCache: Integer;
  Outline: single;
  Embolden: single;
  OutlineFont: TFTScalableOutlineFont;
  SectionName: string;
begin
  ActFont := 0;

  SetLength(Fonts, Length(FONT_NAMES));

  FontIni := TMemIniFile.Create(FontPath.Append('fonts.ini').ToNative);

  try
    for I := 0 to High(FONT_NAMES) do
    begin
      SectionName := 'Font_'+FONT_NAMES[I];

      FontFile := FindFontFile(FontIni.ReadString(SectionName , 'File', ''));

      FontMaxResolution := FontIni.ReadInteger(SectionName, 'MaxResolution', 64);
      FontPreCache := FontIni.ReadInteger(SectionName, 'PreCache', 1);

      // create either outlined or normal font
      Outline := FontIni.ReadFloat(SectionName, 'Outline', 0.0);
      if (Outline > 0.0) then
      begin
        // outlined font
        OutlineFont := TFTScalableOutlineFont.Create(
          FontFile,
          FontMaxResolution,
          Outline,
          true,
          (FontPreCache<>0)
        );
        OutlineColor.R := FontIni.ReadFloat(SectionName, 'OutlineColorR',  0.0);
        OutlineColor.G := FontIni.ReadFloat(SectionName, 'OutlineColorG',  0.0);
        OutlineColor.B := FontIni.ReadFloat(SectionName, 'OutlineColorB',  0.0);
        OutlineFont.SetOutlineColor(
          OutlineColor.R,
          OutlineColor.G,
          OutlineColor.B,
          FontIni.ReadFloat(SectionName, 'OutlineColorA', -1.0)
        );
        Fonts[I].Font := OutlineFont;
        Fonts[I].Outlined := true;
      end
      else
      begin
        // normal font
        Embolden := FontIni.ReadFloat(SectionName, 'Embolden', 0.0);
        Fonts[I].Font := TFTScalableFont.Create(
          FontFile,
          FontMaxResolution,
          Embolden,
          true,
          (FontPreCache<>0)
        );
        Fonts[I].Outlined := false;
      end;

      Fonts[I].Font.GlyphSpacing := FontIni.ReadFloat(SectionName, 'GlyphSpacing', 0.0);
      Fonts[I].Font.LineSpacing := FontIni.ReadFloat(SectionName, 'LineSpacing', 1.0);
      Fonts[I].Font.Stretch := FontIni.ReadFloat(SectionName, 'Stretch', 1.0);

      AddFontFallbacks(FontIni, Fonts[I].Font);
    end;
  except
    on E: EFontError do
      Log.LogCritical(E.Message, 'BuildFont');
  end;

  // close ini-file
  FontIni.Free;
end;


// Deletes the font
procedure KillFonts;
var
  I: integer;
begin
  for I := 0 to High(Fonts) do
    Fonts[I].Font.Free;
end;

function glTextWidth(const text: UTF8String): real;
var
  Bounds: TBoundsDbl;
begin
  Bounds := Fonts[ActFont].Font.BBox(Text, true);
  Result := Bounds.Right;
end;

// Custom GL "Print" Routine
procedure glPrint(const Text: UTF8String);
var
  GLFont: PGLFont;
begin
  // if there is no text do nothing
  if (Text = '') then
    Exit;

  GLFont := @Fonts[ActFont];

  glPushMatrix();
    // set font position
    glTranslatef(GLFont.X, GLFont.Y + GLFont.Font.Ascender, GLFont.Z);
    // draw string
    GLFont.Font.Print(Text);
  glPopMatrix();
end;

procedure ResetFont();
begin
  SetFontPos(0, 0);
  SetFontZ(0);
  SetFontItalic(False);
  SetFontReflection(False, 0);
  SetOutlineColor(0,0,0,1);
end;

procedure SetFontPos(X, Y: real; NewLine: integer = 0);
begin
  Fonts[ActFont].X := X;
  Fonts[ActFont].Y := Y;
  if NewLine > 0 then
    Fonts[ActFont].Y += NewLine * (Fonts[ActFont].Font.Height * 3) * Fonts[ActFont].Font.LineSpacing;
end;

procedure SetFontZ(Z: real);
begin
  Fonts[ActFont].Z := Z;
end;

procedure SetFontSize(Size: real);
begin
  Fonts[ActFont].Font.Height := Size;
end;

procedure SetFontStyle(Style: integer);
begin
  ActFont := Style;
end;

procedure SetFontItalic(Enable: boolean);
begin
  if (Enable) then
    Fonts[ActFont].Font.Style := Fonts[ActFont].Font.Style + [Italic]
  else
    Fonts[ActFont].Font.Style := Fonts[ActFont].Font.Style - [Italic]
end;

procedure SetFontReflection(Enable: boolean; Spacing: real);
begin
  if (Enable) then
    Fonts[ActFont].Font.Style := Fonts[ActFont].Font.Style + [Reflect]
  else
    Fonts[ActFont].Font.Style := Fonts[ActFont].Font.Style - [Reflect];
  Fonts[ActFont].Font.ReflectionSpacing := Spacing - Fonts[ActFont].Font.Descender;
end;

procedure SetOutlineColor(R, G, B, A: GLFloat);
begin
  if (ActFont > 1) then
    TFTScalableOutlineFont(Fonts[ActFont].Font).SetOutlineColor(R, G, B, A);
end;

procedure SetOutlineAlpha(A: GLFloat);
begin
  TFTScalableOutlineFont(Fonts[ActFont].Font).SetOutlineColor(OutlineColor.R, OutlineColor.G, OutlineColor.B, A);
end;

end.
