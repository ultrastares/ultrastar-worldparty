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

{$MODE OBJFPC}

{$I switches.inc}

uses
  sdl2,
  UMenu;

type
  TScreenSongJumpto = class(TMenu)
    private
      //For ChangeMusic
      fVisible: boolean;
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
  UMusic,
  USongs,
  UThemes,
  UUnicodeUtils;

function TScreenSongJumpto.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if PressedDown then
  begin
    if UUnicodeUtils.IsPrintableChar(CharCode) and (Self.Interaction = 0) and (Length(Self.Text[1].Text) < 25) then
    begin
      Self.Text[0].Visible := false;
      Self.Text[1].Text := Self.Text[1].Text+UUnicodeUtils.UCS4ToUTF8String(CharCode);
      Self.SetTextFound();
    end
    else
      case PressedKey of
        SDLK_BACKSPACE:
          begin
            Self.Text[1].DeleteLastLetter();
            Self.SetTextFound();
          end;
        SDLK_RETURN,
        SDLK_ESCAPE:
          begin
            Self.Visible := false;
            UMusic.AudioPlayback.PlaySound(UMusic.SoundLib.Back);
            if (USongs.CatSongs.GetVisibleSongs() = 0) and (Self.Text[1].Text <> '') then
            begin
              Self.Text[1].Text := '';
              Self.SetTextFound();
            end;
          end;
      end;
  end;
end;

constructor TScreenSongJumpto.Create;
begin
  inherited Create;
  Self.LoadFromTheme(UThemes.Theme.SongJumpto);
  Self.Text[1].Writable := true;
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
  if (USongs.CatSongs.CatNumShow <> -2) then
    Self.Text[1].Text := '';
end;

function TScreenSongJumpto.Draw: boolean;
begin
  Self.Text[0].Visible := Self.Text[1].Text = '';
  Result := inherited Draw;
end;

procedure TScreenSongJumpto.SetTextFound();
begin
  UGraphic.ScreenSong.SetSubselection(Self.Text[1].Text)
end;

end.
