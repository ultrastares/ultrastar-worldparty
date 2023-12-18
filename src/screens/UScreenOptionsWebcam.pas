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


unit UScreenOptionsWebcam;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  UMenu,
  UDisplay,
  UDraw,
  UMusic,
  UFiles,
  UIni,
  UThemes;

type
  TScreenOptionsWebcam = class(TMenu)
    private
      Preview: boolean;
      ID, Resolution, Flip, Brightness, Effect: integer;
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      function Draw: boolean; override;
  end;

implementation

uses
  dglOpenGL,
  UGraphic,
  ULanguage,
  UUnicodeUtils,
  UWebcam,
  SysUtils;

function TScreenOptionsWebcam.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin
    case PressedKey of
      SDLK_ESCAPE,SDLK_BACKSPACE:
        begin
          UWebcam.Webcam.Release();
          UIni.Ini.SaveWebcamSettings();
          Self.FadeTo(@UGraphic.ScreenOptions, UMusic.SoundLib.Back);
        end;
      SDLK_RETURN:
        if Self.Interaction = 5 then
          Self.ParseInput(SDLK_ESCAPE, 0, true);
      SDLK_DOWN:
        Self.InteractNext();
      SDLK_UP :
        Self.InteractPrev();
      SDLK_LEFT, SDLK_RIGHT:
        if Self.Interaction <= 4 then
        begin
          UMusic.AudioPlayback.PlaySound(UMusic.SoundLib.Option);
          if PressedKey = SDLK_RIGHT then
            Self.InteractInc()
          else
            Self.InteractDec();

          if Self.Interaction < 2 then
          begin
            UWebcam.Webcam.Restart();
            Self.Preview := UWebcam.Webcam.Capture <> nil;
          end;
        end;
    end;
  end;
end;

constructor TScreenOptionsWebcam.Create;
var
  WebcamsIDs: array[0..2] of UTF8String;
  IWebcamEffectTranslated: array [0..10] of UTF8String = ('NORMAL', 'GRAYSCALE', 'BLACK_WHITE', 'NEGATIVE', 'BINARY_IMAGE', 'DILATE', 'THRESHOLD', 'EDGES', 'GAUSSIAN_BLUR', 'EQUALIZED', 'ERODE');
begin
  inherited Create;
  LoadFromTheme(Theme.OptionsWebcam);
  WebcamsIDs[0] := Language.Translate('OPTION_VALUE_OFF');
  WebcamsIDs[1] := '0';
  WebcamsIDs[2] := '1';
  ID          := AddSelectSlide(Theme.OptionsWebcam.SelectWebcam, UIni.Ini.WebCamID, WebcamsIDs);
  Resolution  := AddSelectSlide(Theme.OptionsWebcam.SelectResolution, UIni.Ini.WebcamResolution, IWebcamResolution);
  Flip        := AddSelectSlide(Theme.OptionsWebcam.SelectFlip, UIni.Ini.WebCamFlip, IWebcamFlip, 'OPTION_VALUE_');
  Brightness  := AddSelectSlide(Theme.OptionsWebcam.SelectBrightness, UIni.Ini.WebCamBrightness, IWebcamBrightness);
  Effect      := AddSelectSlide(Theme.OptionsWebcam.SelectEffect, UIni.Ini.WebCamEffect, IWebcamEffectTranslated, 'SING_OPTIONS_WEBCAM_EFFECT_');
  AddButton(Theme.OptionsWebcam.ButtonExit);
  Self.AddText(UThemes.Theme.OptionsWebcam.IDDesc);
  Self.AddText(UThemes.Theme.OptionsWebcam.ResolutionDesc);
  Self.AddText(UThemes.Theme.OptionsWebcam.FlipDesc);
  Self.AddText(UThemes.Theme.OptionsWebcam.BrightnessDesc);
  Self.AddText(UThemes.Theme.OptionsWebcam.EffectDesc);
  Interaction := 0;
end;

procedure TScreenOptionsWebcam.OnShow;
begin
  inherited;
  if UIni.Ini.WebCamID > 0 then
  begin
    UWebcam.Webcam.Restart();
    Self.Preview := UWebcam.Webcam.Capture <> nil;
  end
  else
    Self.Preview := false;
end;

function TScreenOptionsWebcam.Draw: boolean;
begin
  Self.DrawBG;
  if Self.Preview then
    UDraw.SingDrawWebCamFrame(UThemes.Theme.OptionsWebcam.Preview, true);

  Result := Self.DrawFG;
end;

end.
