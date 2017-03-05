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

unit UUnicodeStringHelper;

{$mode objfpc}

interface

uses
  UUnicodeUtils;

{**
 * Checks if the given string is a valid UTF-8 string.
 * If an ANSI encoded string (with char codes >= 128) is passed, the
 * function will most probably return false, as most ANSI strings sequences
 * are illegal in UTF-8.
 *}
function IsUTF8StringH(const str: RawByteString): boolean;

{**
 * Returns true if the system uses UTF-8 as default string type
 * (filesystem or API calls).
 * This is always true on Mac OS X and always false on Win32. On Unix it depends
 * on the LC_CTYPE setting.
 * Do not use AnsiToUTF8() or UTF8ToAnsi() if this function returns true.
 *}
function IsNativeUTF8H(): boolean;

implementation

function IsUTF8StringH(const str: RawByteString): boolean;
begin
  Result := IsUTF8String(str);
end;

function IsNativeUTF8H(): boolean;
begin
  Result := IsNativeUTF8();
end;

end.

