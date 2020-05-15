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

// prevent pasdoc from parsing this file
{$IFNDEF PASDOC}

//FPC compiler config
{$H+} // use AnsiString instead of ShortString as String-type (default in Delphi)

// if -dDEBUG is specified on the command-line, FPC uses some default
// compiler-flags specified in fpc.cfg -> use -dDEBUG_MODE instead
{$IFDEF DEBUG_MODE}
  {$DEFINE DEBUG}
{$ENDIF}

{$DEFINE HasInline}

// platform dependent config
{$IF Defined(MSWINDOWS)}
  // include defines but no constants
  {$I config-win.inc}
  {$DEFINE HaveBASS}
{$ELSEIF Defined(DARWIN)}
  // include defines but no constants
  {$I config-darwin.inc}

  // enable debug-mode. For development only!
  {.$DEFINE DEBUG}
  {.$DEFINE HaveBASS}
  {$DEFINE UTF8_FILENAMES}
{$ELSEIF Defined(UNIX)}
  // include defines but no constants
  {$IF Defined(FREEBSD)}
    {$I config-freebsd.inc}
  {$ELSEIF Defined(Linux)}
    {$I config-linux.inc}
  {$IFEND}

  // use "configure --enable-debug", "make debug" or
  // the command-line parameter "-debug" instead of defining DEBUG directly
  {.$DEFINE DEBUG}
{$IFEND}

// audio config
{$IF Defined(HaveBASS)}
  {$DEFINE UseBASSPlayback}
  {$DEFINE UseBASSDecoder}
  {$DEFINE UseBASSInput}
{$ELSEIF Defined(HavePortaudio)}
  {$DEFINE UseSDLPlayback}
  {.$DEFINE UsePortaudioPlayback}
  {$DEFINE UsePortaudioInput}
  {$IFDEF HavePortmixer}
    {$DEFINE UsePortmixer}
  {$ENDIF}
{$IFEND}

// ffmpeg config
{$IFDEF HaveFFmpeg}
  {$DEFINE UseFFmpegDecoder}
  {$DEFINE UseFFmpegVideo}
  {$IFDEF HaveSWResample}
    {$DEFINE UseSWResample}
  {$ENDIF}
  {$IFDEF HaveSWScale}
    {$DEFINE UseSWScale}
  {$ENDIF}
{$ENDIF}

{$IFDEF HaveLibsamplerate}
  {$DEFINE UseSRCResample}
{$ENDIF}

// projectM config
{$IF Defined(HaveProjectM)}
  {$DEFINE UseProjectM}
{$IFEND}

// specify some useful defines

{$IF Defined(UseFFmpegVideo) or Defined(UseFFmpegDecoder)}
  {$DEFINE UseFFmpeg}
{$IFEND}

{$IF Defined(UseBASSInput) or Defined(UseBASSPlayback) or Defined(UseBASSDecoder)}
  {$DEFINE UseBASS}
{$IFEND}

{$IF Defined(UsePortaudioInput) or Defined(UsePortaudioPlayback)}
  {$DEFINE UsePortaudio}
{$IFEND}

{$ENDIF PASDOC}
