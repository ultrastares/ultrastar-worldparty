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


unit UScreenOptionsLyrics;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  ULyrics,
  UMenu;

type
  TScreenOptionsLyrics = class(TMenu)
    protected
      Lyrics: TLyricEngine;
      SelectModeProperty: integer;
      SelectFont: integer;
      SelectEffect: integer;
      SelectTransparency: integer;
      SelectLines: integer;
      SelectProperty: integer;
      SelectColor: integer;
      SelectMode: integer;
      TexColor: integer;
      Red: integer;
      Green: integer;
      Blue: integer;
      PointerStart: integer;
      SingColor: string;
      SingOutlineColor: string;
      CurrentColor: string;
      CurrentOutlineColor: string;
      NextColor: string;
      NextOutlineColor: string;
      function GetColorPosition(Colors: array of UTF8String; HexColor: string): integer; //Get color position from ini array or set the last for personalized color
      procedure SetColor(); //Change range colors and selected color for each line type and property
      procedure SetModeValues(); //Set ini values into selects for each mode
      procedure SetValues(); //Set lyric sample and slides properties
    public
      constructor Create(); override;
      function Draw(): boolean; override;
      procedure OnShow(); override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
  end;

implementation

uses
  Math,
  UCommon,
  UGraphic,
  UIni,
  ULanguage,
  UMusic,
  UThemes,
  UUnicodeUtils;

constructor TScreenOptionsLyrics.Create();
var
  Line: TLine;
begin
  inherited Create();

  Self.LoadFromTheme(UThemes.Theme.OptionsLyrics);
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectModeProperty, Self.SelectModeProperty, UIni.Switch, 'PARTY_MODE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectFont, Self.SelectFont, UIni.ILyricsFont, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectEffect, Self.SelectEffect, UIni.ILyricsEffect, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectTransparency, Self.SelectTransparency, UIni.ILyricsAlpha);
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectLines, Self.SelectLines, UIni.ILine, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectProperty, Self.SelectProperty, UIni.IProperty, 'OPTION_VALUE_');
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectColor, Self.SelectColor, UIni.LineColor, 'C_COLOR_');
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectR, Self.Red, IRed);
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectG, Self.Green, IGreen);
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectB, Self.Blue, IBlue);
  Self.AddSelectSlide(UThemes.Theme.OptionsLyrics.SelectMode, Self.SelectMode, ['CLASSIC', 'JUKEBOX'], 'PARTY_MODE_');
  Self.PointerStart := Self.AddStatic(UThemes.Theme.OptionsLyrics.PointerR);
  Self.AddStatic(UThemes.Theme.OptionsLyrics.PointerG);
  Self.AddStatic(UThemes.Theme.OptionsLyrics.PointerB);
  Self.TexColor := Self.AddStatic(UThemes.Theme.OptionsLyrics.TexColor);
  Self.AddButton(UThemes.Theme.OptionsLyrics.ButtonExit);
  Self.SetModeValues();

  //add lyric lines
  Self.Lyrics := TLyricEngine.Create(UThemes.Theme.OptionsLyrics.LyricBar, -1);
  SetLength(Line.Note, 3);
  Line.Note[0].Text := 'Lor';
  Line.Note[1].Text := 'em';
  Line.Note[2].Text := ' ipsum dolor sit amet';
  Line.Note[0].Start := 0;
  Line.Note[1].Start := 10;
  Line.Note[2].Start := 20;
  Line.Note[0].Length := 10;
  Line.Note[1].Length := 10;
  Line.Note[2].Length := 40;
  Self.Lyrics.AddLine(@Line);
  SetLength(Line.Note, 1);
  Line.Note[0].Text := 'consectetur adipiscing elit';
  Line.Note[0].Start := 60;
  Self.Lyrics.AddLine(@Line);
  Self.SetValues();
end;

function TScreenOptionsLyrics.Draw(): boolean;
begin
  Result := inherited Draw();
  Self.Lyrics.Draw(11); //to see effects in the second note in slide mode too
end;

procedure TScreenOptionsLyrics.OnShow();
begin
  inherited;
  Self.Interaction := 0;
  Self.SetModeValues();
end;

function TScreenOptionsLyrics.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var
  SDL_ModState:  word;
  LeftPressedKey: boolean;
  HexColor: UTF8String;
  ColorValue: integer;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    SDL_ModState := SDL_GetModState and (KMOD_LSHIFT + KMOD_RSHIFT + KMOD_LCTRL + KMOD_RCTRL + KMOD_LALT  + KMOD_RALT);

    // check special keys
    case PressedKey of
      SDLK_BACKSPACE, SDLK_ESCAPE:
        begin
          UIni.Ini.Save();
          Self.FadeTo(@UGraphic.ScreenOptions, UMusic.SoundLib.Back);
        end;
      SDLK_RETURN:
        if Self.SelInteraction = 11 then
          Self.ParseInput(SDLK_ESCAPE, 0, true);
      SDLK_DOWN:
        Self.InteractNext();
      SDLK_UP :
        Self.InteractPrev();
      SDLK_LEFT, SDLK_RIGHT:
        begin
          if Self.SelInteraction = 11 then
            Exit();

          UMusic.AudioPlayback.PlaySound(UMusic.SoundLib.Option);
          LeftPressedKey := PressedKey = SDLK_LEFT;
          if LeftPressedKey then
            Self.InteractDec()
          else
            Self.InteractInc();

          case Self.Interaction of
            10: //change mode
              Self.SetModeValues();
            4, 5: //set line type color
              Self.SetColor();
            6: //change color
              if Self.SelectProperty = 0 then //fill
                case Self.SelectLines of
                  0:
                    if Self.SelectColor < High(UIni.IHexSingColor) then
                      Self.SingColor := UIni.IHexSingColor[Self.SelectColor];
                  1:
                    if Self.SelectColor < High(UIni.IHexGrayColor) then
                      Self.CurrentColor := UIni.IHexGrayColor[Self.SelectColor];
                  2:
                    if Self.SelectColor < High(UIni.IHexGrayColor) then
                      Self.NextColor := UIni.IHexGrayColor[Self.SelectColor];
                end
              else if Self.SelectColor < High(UIni.IHexOColor) then //outline
                case Self.SelectLines of
                  0: Self.SingOutlineColor := UIni.IHexOColor[Self.SelectColor];
                  1: Self.CurrentOutlineColor := UIni.IHexOColor[Self.SelectColor];
                  2: Self.NextOutlineColor := UIni.IHexOColor[Self.SelectColor];
                end;
            7..9: //change personalized color
              begin
                ColorValue := Self.SelectsS[Self.SelInteraction].SelectedOption + IfThen(LeftPressedKey, -1, 1) * IfThen(SDL_ModState and (KMOD_LSHIFT or KMOD_RSHIFT) <> 0, 9, 1);
                if (ColorValue >= 0) and (ColorValue <= 255) then
                  Self.SelectsS[Self.SelInteraction].SelectedOption := ColorValue;

                HexColor := RGBToHex(Self.Red, Self.Green, Self.Blue);
                //set color and change to known color position if possible
                if Self.SelectProperty = 0 then //fill
                  case Self.SelectLines of
                    0:
                      begin
                        Self.SingColor := HexColor;
                        Self.SelectsS[6].SelectedOption := Self.GetColorPosition(UIni.IHexSingColor, HexColor);
                      end;
                    1:
                      begin
                        Self.CurrentColor := HexColor;
                        Self.SelectsS[6].SelectedOption := Self.GetColorPosition(UIni.IHexGrayColor, HexColor)
                      end;
                    2:
                      begin
                        Self.NextColor := HexColor;
                        Self.SelectsS[6].SelectedOption := Self.GetColorPosition(UIni.IHexGrayColor, HexColor)
                      end;
                  end
                else //outline
                begin
                  case Self.SelectLines of
                    0: Self.SingOutlineColor := HexColor;
                    1: Self.CurrentOutlineColor := HexColor;
                    2: Self.NextOutlineColor := HexColor;
                  end;
                  Self.SelectsS[6].SelectedOption := Self.GetColorPosition(UIni.IHexOColor, HexColor);
                end;
              end;
          end;
        end;
    end;
    if Self.SelectMode = 0 then
    begin
      UIni.Ini.NoteLines := Self.SelectModeProperty;
      UIni.Ini.LyricsFont := Self.SelectFont;
      UIni.Ini.LyricsEffect := Self.SelectEffect;
      UIni.Ini.LyricsTransparency := Self.SelectTransparency;
      UIni.Ini.LyricsSingColor := Self.SingColor;
      UIni.Ini.LyricsSingOutlineColor := Self.SingOutlineColor;
      UIni.Ini.LyricsCurrentColor := Self.CurrentColor;
      UIni.Ini.LyricsCurrentOutlineColor := Self.CurrentOutlineColor;
      UIni.Ini.LyricsNextColor := Self.NextColor;
      UIni.Ini.LyricsNextOutlineColor := Self.NextOutlineColor;
    end
    else
    begin
      UIni.Ini.JukeboxOffset := Self.SelectModeProperty;
      UIni.Ini.JukeboxFont := Self.SelectFont;
      UIni.Ini.JukeboxEffect := Self.SelectEffect;
      UIni.Ini.JukeboxTransparency := Self.SelectTransparency;
      UIni.Ini.JukeboxSingColor := Self.SingColor;
      UIni.Ini.JukeboxSingOutlineColor := Self.SingOutlineColor;
      UIni.Ini.JukeboxCurrentColor := Self.CurrentColor;
      UIni.Ini.JukeboxCurrentOutlineColor := Self.CurrentOutlineColor;
      UIni.Ini.JukeboxNextColor := Self.NextColor;
      UIni.Ini.JukeboxNextOutlineColor := Self.NextOutlineColor;
    end;
    Self.SetValues();
  end;
end;

{ Get color position from ini array or set the last for personalized color }
function TScreenOptionsLyrics.GetColorPosition(Colors: array of UTF8String; HexColor: string): integer;
begin
  Result := UCommon.GetArrayIndex(Colors, HexColor);
  if Result = -1 then
    Result := High(Colors);
end;

{ Change range colors and selected color for each line type and property }
procedure TScreenOptionsLyrics.SetColor();
begin
  if Self.SelectProperty = 0 then //fill
    case Self.SelectLines of
      0: //sing
        begin
          Self.SelectColor := Self.GetColorPosition(UIni.IHexSingColor, Self.SingColor);
          Self.UpdateSelectSlideOptions(UThemes.Theme.OptionsLyrics.SelectColor, 6, UIni.LineColor, Self.SelectColor, 'C_COLOR_');
        end;
      1: //upper
        begin
          Self.SelectColor := Self.GetColorPosition(UIni.IHexGrayColor, Self.CurrentColor);
          Self.UpdateSelectSlideOptions(UThemes.Theme.OptionsLyrics.SelectColor, 6, UIni.GreyScaleColor, Self.SelectColor);
        end;
      2: //lower
        begin
          Self.SelectColor := Self.GetColorPosition(UIni.IHexGrayColor, Self.NextColor);
          Self.UpdateSelectSlideOptions(UThemes.Theme.OptionsLyrics.SelectColor, 6, UIni.GreyScaleColor, Self.SelectColor);
        end;
    end
  else //outline
  begin
    case Self.SelectLines of
      0: Self.SelectColor := Self.GetColorPosition(UIni.IHexOColor, Self.SingOutlineColor);
      1: Self.SelectColor := Self.GetColorPosition(UIni.IHexOColor, Self.CurrentOutlineColor);
      2: Self.SelectColor := Self.GetColorPosition(UIni.IHexOColor, Self.NextOutlineColor);
    end;
    Self.UpdateSelectSlideOptions(UThemes.Theme.OptionsLyrics.SelectColor, 6, UIni.OutlineColor, Self.SelectColor, 'C_COLOR_');
  end;
end;

{ Set ini values into selects for each mode }
procedure TScreenOptionsLyrics.SetModeValues();
begin
  if Self.SelectMode = 0 then
  begin
    Self.SelectModeProperty := UIni.Ini.NoteLines;
    Self.UpdateSelectSlideOptions(UThemes.Theme.OptionsLyrics.SelectModeProperty, 0, UIni.Switch, Self.SelectModeProperty, 'OPTION_VALUE_');
    Self.SelectsS[0].Text.Text := ULanguage.Language.Translate('SING_OPTIONS_LYRICS_NOTELINES');
    Self.SelectsS[1].SelectedOption := UIni.Ini.LyricsFont;
    Self.SelectsS[2].SelectedOption := UIni.Ini.LyricsEffect;
    Self.SelectsS[3].SelectedOption := UIni.Ini.LyricsTransparency;
    Self.SingColor := UIni.Ini.LyricsSingColor;
    Self.SingOutlineColor := UIni.Ini.LyricsSingOutlineColor;
    Self.CurrentColor := UIni.Ini.LyricsCurrentColor;
    Self.CurrentOutlineColor := UIni.Ini.LyricsCurrentOutlineColor;
    Self.NextColor := UIni.Ini.LyricsNextColor;
    Self.NextOutlineColor := UIni.Ini.LyricsNextOutlineColor;
  end
  else
  begin
    Self.SelectModeProperty := UIni.Ini.JukeboxOffset;
    Self.UpdateSelectSlideOptions(UThemes.Theme.OptionsLyrics.SelectModeProperty, 0, UIni.JukeboxOffsetLyric, Self.SelectModeProperty);
    Self.SelectsS[0].Text.Text := ULanguage.Language.Translate('JUKEBOX_SONGOPTIONS_LYRIC_POSITION');
    Self.SelectsS[1].SelectedOption := UIni.Ini.JukeboxFont;
    Self.SelectsS[2].SelectedOption := UIni.Ini.JukeboxEffect;
    Self.SelectsS[3].SelectedOption := UIni.Ini.JukeboxTransparency;
    Self.SingColor := UIni.Ini.JukeboxSingColor;
    Self.SingOutlineColor := UIni.Ini.JukeboxSingOutlineColor;
    Self.CurrentColor := UIni.Ini.JukeboxCurrentColor;
    Self.CurrentOutlineColor := UIni.Ini.JukeboxCurrentOutlineColor;
    Self.NextColor := UIni.Ini.JukeboxNextColor;
    Self.NextOutlineColor := UIni.Ini.JukeboxNextOutlineColor;
  end;
  Self.SetColor();
end;

{ Set lyric sample and slides properties }
procedure TScreenOptionsLyrics.SetValues();
var
  HexColor: string;
  RGBColor: TRGB;
begin
  Self.Lyrics.SetProperties(Self.SelectMode = 1);
  Self.SelectsS[5].Visible := Self.SelectFont <> 0;
  HexColor := '';
  if Self.SelectProperty = 0 then //fill
    case Self.SelectLines of
      0: HexColor := Self.SingColor;
      1: HexColor := Self.CurrentColor;
      2: HexColor := Self.NextColor;
    end
  else //outline
    case Self.SelectLines of
      0: HexColor := Self.SingOutlineColor;
      1: HexColor := Self.CurrentOutlineColor;
      2: HexColor := Self.NextOutlineColor;
    end;

  RGBColor := UCommon.HexToRGB(HexColor, false);
  Self.SelectsS[7].SelectedOption := Round(RGBColor.R);
  Self.SelectsS[8].SelectedOption := Round(RGBColor.G);
  Self.SelectsS[9].SelectedOption := Round(RGBColor.B);
  Self.Statics[Self.PointerStart].Texture.X := Self.SelectsS[7].TextureSBG.X + ((Self.SelectsS[7].TextureSBG.W - Self.Statics[Self.PointerStart].Texture.W) / 255) * RGBColor.R;
  Self.Statics[Self.PointerStart + 1].Texture.X := Self.SelectsS[7].TextureSBG.X + ((Self.SelectsS[7].TextureSBG.W - Self.Statics[Self.PointerStart].Texture.W) / 255) * RGBColor.G;
  Self.Statics[Self.PointerStart + 2].Texture.X := Self.SelectsS[7].TextureSBG.X + ((Self.SelectsS[7].TextureSBG.W - Self.Statics[Self.PointerStart].Texture.W) / 255) * RGBColor.B;
  if Self.TexColor <> 0 then //only in option lyrics
  begin
    Self.Statics[Self.TexColor].Texture.ColR := RGBColor.R / 255;
    Self.Statics[Self.TexColor].Texture.ColG := RGBColor.G / 255;
    Self.Statics[Self.TexColor].Texture.ColB := RGBColor.B / 255;
  end;
end;

end.
