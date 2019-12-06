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

unit UMenuBackgroundColor;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UCommon,
  UThemes,
  UMenuBackground;

//TMenuBackgroundColor - Background Color
//--------

type
  TMenuBackgroundColor = class (TMenuBackground)
    private
      Color: TRGB;
    public
      constructor Create(const ThemedSettings: TThemeBackground); override;
      procedure   Draw; override;
  end;

implementation
uses
  dglOpenGL,
  UGraphic;

constructor TMenuBackgroundColor.Create(const ThemedSettings: TThemeBackground);
begin
  inherited;
  Color := ThemedSettings.Color;
end;

procedure   TMenuBackgroundColor.Draw;
begin
  if (ScreenAct = 1) then
  begin //just clear once, even when using two screens
   glClearColor(Color.R, Color.G, Color.B, 0);
   glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  end;
end;

end.
