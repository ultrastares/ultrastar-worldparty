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

unit UPlatformLinux;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  Classes,
  UPlatform,
  UConfig,
  UPath;

type
  TPlatformLinux = class(TPlatform)
    private
      UseLocalDirs: boolean;

      procedure DetectLocalExecution();
      function GetHomeDir(): IPath;
    public
      procedure Init; override;

      function GetLogPath        : IPath; override;
      function GetGameSharedPath : IPath; override;
      function GetGameUserPath   : IPath; override;
  end;

implementation

uses
  UCommandLine,
  BaseUnix,
  pwd,
  SysUtils,
  ULog;

const
  {$I paths.inc}

procedure TPlatformLinux.Init;
begin
  inherited Init();
  DetectLocalExecution();
end;

{**
 * Detects whether the game was executed locally or globally.
 * - It is local if it was not installed and directly executed from
 *   within the game folder. In this case resources (themes, language-files)
 *   reside in the directory of the executable.
 * - It is global if the game was installed (e.g. to /usr/games) and
 *   the resources are in a separate folder (e.g. /usr/share/ultrastar-worldparty)
 *   which name is stored in the INSTALL_DATADIR constant in paths.inc.
 *
 * Sets UseLocalDirs to true if the game is executed locally, false otherwise.
 *}
procedure TPlatformLinux.DetectLocalExecution();
var
  LocalDir, LanguageDir: IPath;
begin
  // we just check if the 'languages' folder exists in the
  // directory of the executable. If so -> local execution.
  LocalDir := GetExecutionDir();
  LanguageDir := LocalDir.Append('languages');
  UseLocalDirs := LanguageDir.IsDirectory;
end;

function TPlatformLinux.GetLogPath: IPath;
begin
  if UseLocalDirs then
    Result := GetExecutionDir()
  else
    Result := GetGameUserPath().Append('logs', pdAppend);

  // create non-existing directories
  Result.CreateDirectory(true);
end;

function TPlatformLinux.GetGameSharedPath: IPath;
begin
  if UseLocalDirs then
    Result := GetExecutionDir()
  else
    Result := Path(INSTALL_DATADIR, pdAppend);
end;

function TPlatformLinux.GetGameUserPath: IPath;
begin
  if UseLocalDirs then
    Result := GetExecutionDir()
  else
    Result := GetHomeDir().Append('.ultrastar-worldparty', pdAppend);
end;

{**
 * Returns the user's home directory terminated by a path delimiter
 *}
function TPlatformLinux.GetHomeDir(): IPath;
begin
  Result := Path(GetUserDir()).AppendPathDelim();
end;

end.
