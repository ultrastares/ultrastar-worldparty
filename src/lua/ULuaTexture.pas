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

unit ULuaTexture;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  SysUtils,
  ULua,
  UTexture;

function luaopen_Texture (L: Plua_State): Integer; cdecl;

function ULuaTexture_Dummy(L: Plua_State): Integer; cdecl;

implementation

function ULuaTexture_Dummy(L: Plua_State): Integer; cdecl;
begin
  result:=0; // number of results
end;

const
  ULuaTexture_Lib_f: array [0..1] of lual_reg = (
   (name:'Add';func:ULuaTexture_Dummy),
   (name:nil;func:nil)
   );

function luaopen_Texture (L: Plua_State): Integer; cdecl;
begin
    luaL_register(L,'Texture',@ULuaTexture_Lib_f[0]);
    result:=1;
end;
end.
