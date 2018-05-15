{*
    UltraStar Deluxe WorldParty - Karaoke Game

  UltraStar Deluxe WorldParty is the legal property of its developers,
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
      ButtonRecordIID,
      ButtonAdvancedIID,
      ButtonNetworkIID,
      ButtonWebcamIID,
      ButtonJukeboxIID,
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
  UScreenOptionsRecord,
  UScreenOptionsAdvanced,
  UScreenOptionsNetwork,
  UScreenOptionsWebcam,
  UScreenOptionsJukebox,
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
        else if Interaction = ButtonRecordIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsRecord) then
            UGraphic.ScreenOptionsRecord := TScreenOptionsRecord.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsRecord);
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
        else if Interaction = ButtonJukeboxIID then
        begin
          if not Assigned(UGraphic.ScreenOptionsJukebox) then
            UGraphic.ScreenOptionsJukebox := TScreenOptionsJukebox.Create();

          AudioPlayback.PlaySound(SoundLib.Start);
          FadeTo(@ScreenOptionsJukebox);
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

  // TODO: Generalize method and implement it into base code (to be used by every screen/menu)
  function AddButtonChecked(Btn: TThemeButton; DescIndex: byte; out IIDvar: cardinal; AddX: real = 14; AddY: real = 20): cardinal;
  var OldPos: integer;
  begin
    OldPos := Length(Button);
    Result := AddButton(Btn);
    if Length(Button) <> OldPos then // check if button was succesfully added
    begin
      IIDvar := High(Interactions);

      // update mapping, IID to Desc index
      SetLength(MapIIDtoDescID, IIDvar+1);
      MapIIDtoDescID[IIDvar] := DescIndex;

      if (Length(Button[Result].Text) = 0) then // update text if not already set
        AddButtonText(AddX, AddY, Theme.Options.Description[DescIndex]);
    end;

  end;
begin
  inherited Create;

  TextDescription := AddText(Theme.Options.TextDescription);

  LoadFromTheme(Theme.Options);

  // Order is irrelevant to the represenatation, however InteractNext/Prev is not working with a different order
  AddButtonChecked(Theme.Options.ButtonGame, OPTIONS_DESC_INDEX_GAME,  ButtonGameIID);
  AddButtonChecked(Theme.Options.ButtonGraphics, OPTIONS_DESC_INDEX_GRAPHICS,  ButtonGraphicsIID);
  AddButtonChecked(Theme.Options.ButtonSound, OPTIONS_DESC_INDEX_SOUND,  ButtonSoundIID);

  AddButtonChecked(Theme.Options.ButtonLyrics, OPTIONS_DESC_INDEX_LYRICS,  ButtonLyricsIID);
  AddButtonChecked(Theme.Options.ButtonThemes, OPTIONS_DESC_INDEX_THEMES,  ButtonThemesIID);
  AddButtonChecked(Theme.Options.ButtonRecord, OPTIONS_DESC_INDEX_RECORD,  ButtonRecordIID);
  AddButtonChecked(Theme.Options.ButtonAdvanced, OPTIONS_DESC_INDEX_ADVANCED,  ButtonAdvancedIID);
  AddButtonChecked(Theme.Options.ButtonNetwork, OPTIONS_DESC_INDEX_NETWORK,  ButtonNetworkIID);

  AddButtonChecked(Theme.Options.ButtonWebcam, OPTIONS_DESC_INDEX_WEBCAM,  ButtonWebcamIID);
  AddButtonChecked(Theme.Options.ButtonJukebox, OPTIONS_DESC_INDEX_JUKEBOX,  ButtonJukeboxIID);

  AddButtonChecked(Theme.Options.ButtonExit, OPTIONS_DESC_INDEX_BACK,  ButtonExitIID);

  Interaction := 0;
end;

procedure TScreenOptions.OnShow;
begin
  inherited;
  // continue possibly stopped bg-music (stopped in record options)
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
