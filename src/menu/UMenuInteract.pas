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
 
unit UMenuInteract;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

type
  TInteract = record // for moving thru menu
    Typ: integer;  // 0 - button, 1 - select, 2 - Text, 3 - Select SLide, 5 - ButtonCollection Child
    Num: integer;  // number of this item in proper list like buttons, selects
  end;

  { to handle the area where the mouse is over a control }
  TMouseOverRect = record
    X, Y: Real;
    W, H: Real;
  end;

  { to handle the on click action }
  TMouseClickAction = (maNone, maReturn, maLeft, maRight);

implementation

end.
 