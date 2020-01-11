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
      ButtonGameIID,
      ButtonGraphicsIID,
      ButtonSoundIID,
      ButtonInputIID,
      ButtonLyricsIID,
      ButtonThemesIID,
      ButtonMicrophonesIID,
      ButtonAdvancedIID,
      ButtonNetworkIID,
      ButtonWebcamIID,
      ButtonProfilesIID,
      ButtonExitIID: cardinal;

      MapIIDtoDescID: array of integer;

      procedure UpdateTextDescriptionFor(IID: integer); virtual;

    public
      TextDescription:    integer;
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
  UScreenOptionsProfiles,
  UWebcam,
  UUnicodeUtils;

function TScreenOptions.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE:
      begin
        Ini.Save;
        AudioPlayback.PlaySound(SoundLib.Back);
        FadeTo(@ScreenMain);
      end;
      SDLK_RETURN:
      begin
        if Interaction = ButtonGameIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsGame) then
            UGraphic.ScreenOptionsGame := TScreenOptionsGame.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsGame);
        end
        else if Interaction = ButtonGraphicsIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsGraphics) then
            UGraphic.ScreenOptionsGraphics := TScreenOptionsGraphics.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsGraphics);
        end
        else if Interaction = ButtonSoundIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsSound) then
            UGraphic.ScreenOptionsSound := TScreenOptionsSound.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsSound);
        end
        else if Interaction = ButtonLyricsIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsLyrics) then
            UGraphic.ScreenOptionsLyrics := TScreenOptionsLyrics.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsLyrics);
        end
        else if Interaction = ButtonThemesIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsThemes) then
            UGraphic.ScreenOptionsThemes := TScreenOptionsThemes.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsThemes);
        end
        else if Interaction = ButtonMicrophonesIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsMicrophones) then
            UGraphic.ScreenOptionsMicrophones := TScreenOptionsMicrophones.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsMicrophones);
        end
        else if Interaction = ButtonAdvancedIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsAdvanced) then
            UGraphic.ScreenOptionsAdvanced := TScreenOptionsAdvanced.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsAdvanced);
        end
        else if Interaction = ButtonNetworkIID then
          if High(DataBase.NetworkUser) = -1 then
            UGraphic.ScreenPopupError.ShowPopup(ULanguage.Language.Translate('SING_OPTIONS_NETWORK_NO_DLL'))
          else
          begin
            if not Assigned(UGraphic.ScreenOptionsNetwork) then
              UGraphic.ScreenOptionsNetwork := TScreenOptionsNetwork.Create();

            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenOptionsNetwork);
          end
        else if Interaction = ButtonWebcamIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsWebcam) then
            UGraphic.ScreenOptionsWebcam := TScreenOptionsWebcam.Create();

          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptionsWebcam);
        end
        else if Interaction = ButtonProfilesIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsProfiles) then
            UGraphic.ScreenOptionsProfiles := TScreenOptionsProfiles.Create();

          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptionsProfiles);
        end
        else if Interaction = ButtonExitIID then
        begin
          Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenMain);
        end;
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

  Self.ButtonGameIID := Self.AddButton(Theme.Options.ButtonGame);
  Self.ButtonGraphicsIID := Self.AddButton(Theme.Options.ButtonGraphics);
  Self.ButtonSoundIID := Self.AddButton(Theme.Options.ButtonSound);
  Self.ButtonLyricsIID := Self.AddButton(Theme.Options.ButtonLyrics);
  Self.ButtonThemesIID := Self.AddButton(Theme.Options.ButtonThemes);
  Self.ButtonMicrophonesIID := Self.AddButton(Theme.Options.ButtonMicrophones);
  Self.ButtonAdvancedIID := Self.AddButton(Theme.Options.ButtonAdvanced);
  Self.ButtonNetworkIID := Self.AddButton(Theme.Options.ButtonNetwork);
  Self.ButtonWebcamIID := Self.AddButton(Theme.Options.ButtonWebcam);
  Self.ButtonProfilesIID := Self.AddButton(Theme.Options.ButtonProfiles);
  Self.ButtonExitIID := Self.AddButton(Theme.Options.ButtonExit);
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
var
  index: integer;
begin
  // Sanity check
  if (IID < 0) or (IID >= Length(MapIIDtoDescID)) then
    Exit;

  Text[TextDescription].Text := Theme.Options.Description[MapIIDtoDescID[IID]];
end;

end.
