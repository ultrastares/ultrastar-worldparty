{*
    UltraStar Deluxe WorldParty - Karaoke Game
	
	UltraStar Deluxe WorldParty is the legal property of its developers, 
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

unit PseudoThread;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

interface

type

// Debugging threads with XCode doesn't seem to work.
// We use PseudoThread in Debug mode to get proper debugging.

TPseudoThread = class(TObject)
  private
  protected
    Terminated,
    FreeOnTerminate: boolean;
    procedure Execute; virtual; abstract;
    procedure Resume;
    procedure Suspend;
  public
   constructor Create(const suspended : boolean);
end;

implementation

{ TPseudoThread }

constructor TPseudoThread.Create(const suspended: boolean);
begin
  if not suspended then
  begin
    Execute;
  end;
end;

procedure TPseudoThread.Resume;
begin
  Execute;
end;

procedure TPseudoThread.Suspend;
begin
end;

end.
 
