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

unit UMediaCore_SDL;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMusic,
  SDL2;

function ConvertAudioFormatToSDL(Format: TAudioSampleFormat; out SDLFormat: UInt16): boolean;

implementation

function ConvertAudioFormatToSDL(Format: TAudioSampleFormat; out SDLFormat: UInt16): boolean;
begin
  case Format of
    asfU8:     SDLFormat := AUDIO_U8;
    asfS8:     SDLFormat := AUDIO_S8;
    asfU16LSB: SDLFormat := AUDIO_U16LSB;
    asfS16LSB: SDLFormat := AUDIO_S16LSB;
    asfU16MSB: SDLFormat := AUDIO_U16MSB;
    asfS16MSB: SDLFormat := AUDIO_S16MSB;
    asfU16:    SDLFormat := AUDIO_U16;
    asfS16:    SDLFormat := AUDIO_S16;
    else begin
      Result := false;
      Exit;
    end;
  end;
  Result := true;
end;

end.
