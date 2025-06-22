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

unit UScreenOptionsAdvanced;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  UCommon,
  sdl2,
  UMenu,
  UDisplay,
  UMusic,
  UFiles,
  UIni,
  UThemes,
  ULanguage,
  Upath,
  UDatabase;

type
  TScreenOptionsAdvanced = class(TMenu)
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
    private
      procedure RestoreDefaultConfig;
      procedure RestoreScores;
      class procedure HandleRestoreConfirmation(Value: boolean; Data: Pointer); static;
      class procedure HandleRestoreScoresConfirmation(Value: boolean; Data: Pointer); static;
  end;

implementation

uses
  UGraphic,
  UUnicodeUtils,
  SysUtils,
  UPathUtils,
  ULog,
  UPlatform,
  Classes;

function TScreenOptionsAdvanced.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          UIni.Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptions);
        end;
      SDLK_RETURN:
        begin
          if Self.SelInteraction = 7 then
          begin
            RestoreDefaultConfig;
          end
          else if Self.SelInteraction = 8 then
          begin
            RestoreScores;
          end
          else if Self.SelInteraction = 9 then
          begin
            UIni.Ini.Save;
            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenOptions);
          end;
        end;
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 6) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 6) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
        end;
    end;
  end;
end;

constructor TScreenOptionsAdvanced.Create;
begin
  inherited Create;

  LoadFromTheme(Theme.OptionsAdvanced);
  AddSelectSlide(Theme.OptionsAdvanced.SelectDebug, UIni.Ini.Debug, UIni.IDebug, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsAdvanced.SelectOscilloscope, UIni.Ini.Oscilloscope, UIni.IOscilloscope, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsAdvanced.SelectOnSongClick, UIni.Ini.OnSongClick, UIni.IOnSongClick, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsAdvanced.SelectAskBeforeExit, UIni.Ini.AskBeforeExit, UIni.IAskBeforeExit, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsAdvanced.SelectPartyPopup, UIni.Ini.PartyPopup, UIni.IPartyPopup, 'OPTION_VALUE_');
  AddSelectSlide(Theme.OptionsAdvanced.SelectTopScores, UIni.Ini.TopScores, UIni.ITopScores, 'OPTION_VALUE_');
  Self.AddSelectSlide(Theme.OptionsAdvanced.SelectSingTimebarMode, UIni.Ini.SingTimebarMode, UIni.ISingTimebarMode, 'OPTION_VALUE_');
  AddButton(Theme.OptionsAdvanced.ButtonRestoreConfig);
  AddButton(Theme.OptionsAdvanced.ButtonRestoreScores);
  AddButton(Theme.OptionsAdvanced.ButtonExit);
  Self.AddText(UThemes.Theme.OptionsAdvanced.DebugDesc);
  Self.AddText(UThemes.Theme.OptionsAdvanced.OscilloscopeDesc);
  Self.AddText(UThemes.Theme.OptionsAdvanced.OnSongClickDesc);
  Self.AddText(UThemes.Theme.OptionsAdvanced.AskBeforeExitDesc);
  Self.AddText(UThemes.Theme.OptionsAdvanced.PartyPopupDesc);
  Self.AddText(UThemes.Theme.OptionsAdvanced.TopScoresDesc);
  Self.AddText(UThemes.Theme.OptionsAdvanced.SingTimebarModeDesc);

  Interaction := 0;
end;

procedure TScreenOptionsAdvanced.OnShow;
begin
  inherited;

  Interaction := 0;
end;

class procedure TScreenOptionsAdvanced.HandleRestoreConfirmation(Value: boolean; Data: Pointer);
var
  ConfigPath: IPath;
begin
  if Value then // User confirmed
  begin
    ConfigPath := GetConfigFileName();
    
    try
      // Delete the configuration file
      if ConfigPath.IsFile() then
      begin
        if not DeleteFile(ConfigPath.ToNative()) then
        begin
          ScreenPopupError.ShowPopup(Language.Translate('SING_OPTIONS_ADVANCED_ERROR_DELETING_CONFIG'));
          Log.LogError('Could not delete config file: ' + ConfigPath.ToNative());
          Exit;
        end;
      end;
      
      // Reset configuration
      Ini.Free;
      Ini := TIni.Create();

      // Restart the application
      try
        Platform.RestartApplication;
      except
        on E: Exception do
        begin
          Log.LogError('Failed to restart application: ' + E.Message);
          Halt; // Fallback if RestartApplication fails
        end;
      end;
    except
      on E: Exception do
      begin
        ScreenPopupError.ShowPopup(Language.Translate('SING_OPTIONS_ADVANCED_ERROR_RESTORING_CONFIG'));
        Log.LogError('Error restoring config: ' + E.Message);
      end;
    end;
  end;
end;

class procedure TScreenOptionsAdvanced.HandleRestoreScoresConfirmation(Value: boolean; Data: Pointer);
var
  ScoresPath: IPath;
  RetryCount: Integer;
  Deleted: Boolean;
begin
  if Value then // User confirmed
  begin
    ScoresPath := GetDatabaseFileName();
    
    try
      if ScoresPath.IsFile() then
      begin
        // Close the database if it is open
        if Assigned(UDatabase.DataBase) then
         begin
          UDatabase.DataBase.Free;
          UDatabase.DataBase := nil;
         end;
          
        // Attempt to delete with multiple retries
        RetryCount := 0;
        Deleted := False;
        while (RetryCount < 5) and not Deleted do
        begin
          if DeleteFile(ScoresPath.ToNative()) then
            Deleted := True
          else
          begin
            Inc(RetryCount);
            Sleep(200); // Short pause between attempts
          end;
        end;
        
        if not Deleted then
        begin
          ScreenPopupError.ShowPopup(Language.Translate('SING_OPTIONS_ADVANCED_ERROR_DELETING_SCORES'));
          Log.LogError('Could not delete scores file after multiple attempts: ' + ScoresPath.ToNative());
          Exit;
        end;
      end;

      // Restart the application
      try
        Platform.RestartApplication;
      except
        on E: Exception do
        begin
          Log.LogError('Failed to restart application: ' + E.Message);
          Halt;
        end;
      end;
    except
      on E: Exception do
      begin
        ScreenPopupError.ShowPopup(Language.Translate('SING_OPTIONS_ADVANCED_ERROR_RESTORING_SCORES'));
        Log.LogError('Error restoring scores: ' + E.Message);
      end;
    end;
  end;
end;

procedure TScreenOptionsAdvanced.RestoreDefaultConfig;
begin
  // Show confirmation popup first
  ScreenPopupCheck.ShowPopup(
    Language.Translate('SING_OPTIONS_ADVANCED_RESTORE_CONFIG_CONFIRMATION'),
    @HandleRestoreConfirmation,
    nil,
    false
  );
end;

procedure TScreenOptionsAdvanced.RestoreScores;
begin
  // Show confirmation popup first
  ScreenPopupCheck.ShowPopup(
    Language.Translate('SING_OPTIONS_ADVANCED_RESTORE_SCORES_CONFIRMATION'),
    @HandleRestoreScoresConfirmation,
    nil,
    false
  );
end;

end.