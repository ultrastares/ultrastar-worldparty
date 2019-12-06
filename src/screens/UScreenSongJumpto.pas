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


unit UScreenSongJumpto;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  sdl2,
  SysUtils,
  UMenu,
  UDisplay,
  UMusic,
  UFiles,
  USongs,
  UThemes;

type
  TScreenSongJumpto = class(TMenu)
    private
      //For ChangeMusic
      fVisible: boolean;
      fSelectType: TSongFilter;
      procedure SetTextFound();

      //Visible //Whether the Menu should be Drawn
      //Whether the Menu should be Drawn
      procedure SetVisible(Value: boolean);
    public
      constructor Create; override;

      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      function Draw: boolean; override;

      property Visible: boolean read fVisible write SetVisible;
  end;

implementation

uses
  UGraphic,
  UMain,
  UIni,
  UTexture,
  ULanguage,
  UParty,
  UScreenSong,
  ULog,
  UUnicodeUtils;

function TScreenSongJumpto.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    if (IsAlphaNumericChar(CharCode) or
        IsPunctuationChar(CharCode)) then
    begin
      if (Interaction = 0) then
      begin
        Button[0].Text[0].ColR := Theme.SongJumpto.ButtonSearchText.ColR;
        Button[0].Text[0].ColG := Theme.SongJumpto.ButtonSearchText.ColG;
        Button[0].Text[0].ColB := Theme.SongJumpto.ButtonSearchText.ColB;
        Button[0].Text[0].Text := Button[0].Text[0].Text + UCS4ToUTF8String(CharCode);
        Self.SetTextFound();
      end;
    end;

    // check special keys
    case PressedKey of
      SDLK_BACKSPACE:
        begin
          if (Interaction = 0) and (Length(Button[0].Text[0].Text) > 0) then
          begin
            Button[0].Text[0].DeleteLastLetter();
            Self.SetTextFound();
          end;
        end;

      SDLK_RETURN,
      SDLK_ESCAPE:
        begin
          Visible := false;
          AudioPlayback.PlaySound(SoundLib.Back);
          if (USongs.CatSongs.GetVisibleSongs() = 0) and (Length(Self.Button[0].Text[0].Text) > 0) then
          begin
            Self.Button[0].Text[0].Text := '';
            Self.SetTextFound();
          end;
        end;

      SDLK_DOWN:
        begin
          {SelectNext;
          Button[0].Text[0].Selected := (Interaction = 0);}
        end;

      SDLK_UP:
        begin
          {SelectPrev;
          Button[0].Text[0].Selected := (Interaction = 0); }
        end;

      SDLK_RIGHT:
        begin
          Interaction := 1;
          InteractInc;
          if (Length(Button[0].Text[0].Text) > 0) then
            Self.SetTextFound();
          Interaction := 0;
        end;
      SDLK_LEFT:
        begin
          Interaction := 1;
          InteractDec;
          if (Length(Button[0].Text[0].Text) > 0) then
            Self.SetTextFound();
          Interaction := 0;
        end;
    end;
  end;
end;

constructor TScreenSongJumpto.Create;
var
  ButtonID: integer;
begin
  inherited Create;

  LoadFromTheme(Theme.SongJumpto);

  ButtonID := AddButton(Theme.SongJumpto.ButtonSearchText);

  if (Length(Button[0].Text) = 0) then
    AddButtonText(14, 20, '');

  Button[ButtonID].Text[0].Writable := true;

  fSelectType := sfAll;
  AddSelectSlide(Theme.SongJumpto.SelectSlideType, PInteger(@fSelectType)^, []);

  Interaction := 0;
end;

procedure TScreenSongJumpto.SetVisible(Value: boolean);
begin
//If change from invisible to Visible then OnShow
  if (fVisible = false) and (Value = true) then
    OnShow;

  fVisible := Value;
end;

procedure TScreenSongJumpto.OnShow;
begin
  inherited;

  //Reset Screen if no Old Search is Displayed
  if (CatSongs.CatNumShow <> -2) then
  begin
    SelectsS[0].SetSelectOpt(0);

    Button[0].Text[0].Text := '';
  end;

  //Select Input
  Interaction := 0;
  Button[0].Text[0].Selected := true;
end;

function TScreenSongJumpto.Draw: boolean;
begin
  Result := inherited Draw;
end;

procedure TScreenSongJumpto.SetTextFound();
begin
  UGraphic.ScreenSong.SetSubselection(Self.Button[0].Text[0].Text, fSelectType);
end;

end.
