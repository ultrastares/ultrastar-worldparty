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


unit UScreenOptionsSound;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  UDisplay,
  UFiles,
  UIni,
  ULanguage,
  UMenu,
  UMusic,
  UThemes;

type
  TScreenOptionsSound = class(TMenu)
  public
    constructor Create; override;
    function ParseInput(PressedKey: Cardinal; CharCode: UCS4Char;
      PressedDown: boolean): boolean; override;
    procedure OnShow; override;
  end;

implementation

uses
  UGraphic,
  UUnicodeUtils,
  SysUtils;

function TScreenOptionsSound.ParseInput(PressedKey: cardinal;
  CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE:
      begin
        Ini.Save;
        AudioPlayback.PlaySound(SoundLib.Back);
        FadeTo(@ScreenOptions);
      end;
      SDLK_RETURN:
      begin
        if SelInteraction = 7 then
        begin
          Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptions);
        end;
      end;
      SDLK_DOWN:
        InteractNext;
      SDLK_UP:
        InteractPrev;
      SDLK_RIGHT:
      begin
        if (SelInteraction >= 0) and (SelInteraction < 8) then
        begin
          AudioPlayback.PlaySound(SoundLib.Option);
          InteractInc;
        end;
      end;
      SDLK_LEFT:
      begin
        if (SelInteraction >= 0) and (SelInteraction < 8) then
        begin
          AudioPlayback.PlaySound(SoundLib.Option);
          InteractDec;
        end;
      end;
    end;
  end;

{**
 * Actually this one isn't pretty - but it does the trick of
 * turning the background music on/off in "real time"
 * bgm = background music
 * TODO: - Fetching the SelectInteraction via something more descriptive
 *       - Obtaining the current value of a select is imho ugly
 *}
  if (SelInteraction = 1) then
  begin
    if TBackgroundMusicOption(SelectsS[1].SelectedOption) = bmoOn then
      SoundLib.StartBgMusic
    else
      SoundLib.PauseBgMusic;
  end;

end;

constructor TScreenOptionsSound.Create;
var
  IMusicAutoGainTranslated: array[0..3] of UTF8String;
  IPreviewFadingTranslated: array[0..5] of UTF8String;
  I: integer;
begin
  inherited Create;

  LoadFromTheme(Theme.OptionsSound);
  AddSelectSlide(Theme.OptionsSound.SelectSlideVoicePassthrough, UIni.Ini.VoicePassthrough, UIni.IVoicePassthrough, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsSound.SelectBackgroundMusic, UIni.Ini.BackgroundMusicOption, UIni.IBackgroundMusic, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsSound.SelectClickAssist, UIni.Ini.ClickAssist, UIni.IClickAssist, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsSound.SelectBeatClick, UIni.Ini.BeatClick, UIni.IBeatClick, 'OPTION_VALUE_');
  IMusicAutoGainTranslated := UIni.IMusicAutoGain;
  for I := 1 to High(UIni.IMusicAutoGain) do
    IMusicAutoGainTranslated[I] := 'GAIN_'+IMusicAutoGainTranslated[I];

  AddSelectSlide(Theme.OptionsSound.SelectSlideMusicAutoGain, UIni.Ini.MusicAutoGain, IMusicAutoGainTranslated, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsSound.SelectSlidePreviewVolume, UIni.Ini.PreviewVolume, UIni.IPreviewVolume);
  IPreviewFadingTranslated[0] := ULanguage.Language.Translate('OPTION_VALUE_OFF');
  IPreviewFadingTranslated[1] := '1 '+LowerCase(ULanguage.Language.Translate('OPTION_VALUE_SEC'));
  IPreviewFadingTranslated[2] := '2 '+LowerCase(ULanguage.Language.Translate('OPTION_VALUE_SECS'));
  IPreviewFadingTranslated[3] := '3 '+LowerCase(ULanguage.Language.Translate('OPTION_VALUE_SECS'));
  IPreviewFadingTranslated[4] := '4 '+LowerCase(ULanguage.Language.Translate('OPTION_VALUE_SECS'));
  IPreviewFadingTranslated[5] := '5 '+LowerCase(ULanguage.Language.Translate('OPTION_VALUE_SECS'));
  AddSelectSlide(Theme.OptionsSound.SelectSlidePreviewFading, UIni.Ini.PreviewFading, IPreviewFadingTranslated);

  AddButton(Theme.OptionsSound.ButtonExit);

  Interaction := 0;
end;

procedure TScreenOptionsSound.OnShow;
begin
  inherited;
  Interaction := 0;
end;

end.
