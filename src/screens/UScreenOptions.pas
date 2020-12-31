{*
    UltraStar WorldParty - Karaoke Game

  UltraStar WorldParty is the legal property of its developers,
  whose names  are too numerous to list here. Please refer to the
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


unit UScreenOptions;

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
  UIni,
  UThemes;

type
  TScreenOptions = class(TMenu)
    private
      MapIIDtoDescID: array of integer;
      procedure UpdateTextDescriptionFor(IID: integer); virtual;
    public
      TextDescription: integer;
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure SetInteraction(Num: integer); override;
      procedure SetAnimationProgress(Progress: real); override;
  end;

implementation

uses
  UGraphic,
  UDatabase,
  ULanguage,
  UScreenOptionsGame,
  UScreenOptionsGraphics,
  UScreenOptionsSound,
  UScreenOptionsLyrics,
  UScreenOptionsThemes,
  UScreenOptionsMicrophones,
  UScreenOptionsAdvanced,
  UScreenOptionsNetwork,
  UScreenOptionsWebcam,
  UScreenPlayerSelector,
  UWebcam,
  UUnicodeUtils;

function TScreenOptions.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var
  Screen: PMenu;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE:
        Self.FadeTo(@UGraphic.ScreenMain, UMusic.SoundLib.Back);
      SDLK_RETURN:
        begin
          Screen := nil;
          case Self.Interaction of
            0:
              Self.FadeTo(@UGraphic.ScreenMain, UMusic.SoundLib.Back);
            1:
              begin
                if not Assigned(UGraphic.ScreenOptionsGame) then
                  UGraphic.ScreenOptionsGame := TScreenOptionsGame.Create();

                Screen := @UGraphic.ScreenOptionsGame;
              end;
            2:
              begin
                if not Assigned(UGraphic.ScreenOptionsGraphics) then
                  UGraphic.ScreenOptionsGraphics := TScreenOptionsGraphics.Create();

                Screen := @UGraphic.ScreenOptionsGraphics;
              end;
            3:
              begin
                if not Assigned(UGraphic.ScreenOptionsSound) then
                  UGraphic.ScreenOptionsSound := TScreenOptionsSound.Create();

                Screen := @UGraphic.ScreenOptionsSound;
              end;
            4:
              begin
                if not Assigned(UGraphic.ScreenOptionsLyrics) then
                  UGraphic.ScreenOptionsLyrics := TScreenOptionsLyrics.Create();

                Screen := @UGraphic.ScreenOptionsLyrics;
              end;
            5:
              begin
                if not Assigned(UGraphic.ScreenOptionsThemes) then
                  UGraphic.ScreenOptionsThemes := TScreenOptionsThemes.Create();

                Screen := @UGraphic.ScreenOptionsThemes;
              end;
            6:
              begin
                if not Assigned(UGraphic.ScreenOptionsMicrophones) then
                  UGraphic.ScreenOptionsMicrophones := TScreenOptionsMicrophones.Create();

                Screen := @UGraphic.ScreenOptionsMicrophones;
              end;
            7:
              begin
                if not Assigned(UGraphic.ScreenOptionsAdvanced) then
                  UGraphic.ScreenOptionsAdvanced := TScreenOptionsAdvanced.Create();

                Screen := @UGraphic.ScreenOptionsAdvanced;
              end;
            8:
              if High(DataBase.NetworkUser) = -1 then
                UGraphic.ScreenPopupError.ShowPopup(ULanguage.Language.Translate('SING_OPTIONS_NETWORK_NO_DLL'))
              else
              begin
                if not Assigned(UGraphic.ScreenOptionsNetwork) then
                  UGraphic.ScreenOptionsNetwork := TScreenOptionsNetwork.Create();

                Screen := @UGraphic.ScreenOptionsNetwork;
              end;
            9:
              begin
                if not Assigned(UGraphic.ScreenOptionsWebcam) then
                  UGraphic.ScreenOptionsWebcam := TScreenOptionsWebcam.Create();

                Screen := @UGraphic.ScreenOptionsWebcam;
              end;
            10:
              begin
                if not Assigned(UGraphic.ScreenPlayerSelector) then
                  UGraphic.ScreenPlayerSelector := TScreenPlayerSelector.Create();

                UGraphic.ScreenPlayerSelector.OpenedInOptions := true;
                Screen := @UGraphic.ScreenPlayerSelector;
              end;
          end;
          if Assigned(Screen) then
            Self.FadeTo(Screen, UMusic.SoundLib.Start);
      end;
      SDLK_DOWN: InteractNextRow;
      SDLK_UP: InteractPrevRow;
      SDLK_RIGHT: InteractNext;
      SDLK_LEFT: InteractPrev;
    end;
  end;
end;

constructor TScreenOptions.Create;

begin
  inherited Create;

  TextDescription := AddText(Theme.Options.TextDescription);

  LoadFromTheme(Theme.Options);

  Self.AddButton(UThemes.Theme.Options.ButtonExit);
  Self.AddButton(UThemes.Theme.Options.ButtonGame);
  Self.AddButton(UThemes.Theme.Options.ButtonGraphics);
  Self.AddButton(UThemes.Theme.Options.ButtonSound);
  Self.AddButton(UThemes.Theme.Options.ButtonLyrics);
  Self.AddButton(UThemes.Theme.Options.ButtonThemes);
  Self.AddButton(UThemes.Theme.Options.ButtonMicrophones);
  Self.AddButton(UThemes.Theme.Options.ButtonAdvanced);
  Self.AddButton(UThemes.Theme.Options.ButtonNetwork);
  Self.AddButton(UThemes.Theme.Options.ButtonWebcam);
  Self.AddButton(UThemes.Theme.Options.ButtonProfiles);
  Self.Interaction := 0;
end;

procedure TScreenOptions.OnShow;
begin
  inherited;
  // continue possibly stopped bg-music (stopped in Microphones options)
  SoundLib.StartBgMusic;
end;

procedure TScreenOptions.SetInteraction(Num: integer);
begin
  inherited SetInteraction(Num);
  UpdateTextDescriptionFor(Interaction);
end;

procedure TScreenOptions.SetAnimationProgress(Progress: real);
var
  i: integer;
begin
  // update all buttons
  for i := 0 to High(Button) do
    Button[i].Texture.ScaleW := Progress;
end;

procedure TScreenOptions.UpdateTextDescriptionFor(IID: integer);
begin
  // Sanity check
  if (IID < 0) or (IID >= Length(MapIIDtoDescID)) then
    Exit;

  Text[TextDescription].Text := Theme.Options.Description[MapIIDtoDescID[IID]];
end;

end.
