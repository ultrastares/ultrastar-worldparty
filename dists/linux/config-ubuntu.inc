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

{*****************************************************************
 * Configuration file for WorldParty snap version
 *****************************************************************}

{* Libraries *}

{$IF Defined(IncludeConstants)}
  lua_lib_name = 'lua5.3';
  LUA_VERSION_INT     = 5003003;
  LUA_VERSION_RELEASE = '3';
  LUA_VERSION_MINOR   = '3';
  LUA_VERSION_MAJOR   = '5';
  LUA_VERSION         = '5.3.3';
  LUA_INTEGER_BITS    = 64;
{$IFEND}

{$MACRO ON}
{$IFNDEF FFMPEG_DIR}
  {$DEFINE FFMPEG_DIR := 'ffmpeg-4.0'}
{$ENDIF}
{$IF Defined(IncludeConstants)}
  FFMPEG_VERSION_INT = 4000000;

av__codec = 'libavcodec';
LIBAVCODEC_VERSION_MAJOR = 58;
LIBAVCODEC_VERSION_MINOR = 91;
LIBAVCODEC_VERSION_RELEASE = 100;

av__format = 'libavformat';
LIBAVFORMAT_VERSION_MAJOR = 58;
LIBAVFORMAT_VERSION_MINOR = 45;
LIBAVFORMAT_VERSION_RELEASE = 100;

av__util = 'libavutil';
LIBAVUTIL_VERSION_MAJOR = 56;
LIBAVUTIL_VERSION_MINOR = 51;
LIBAVUTIL_VERSION_RELEASE = 100;
{$IFEND}

{$IF Defined(IncludeConstants)}
  sw__scale = 'libswscale';
  LIBSWSCALE_VERSION_MAJOR   = 5;
  LIBSWSCALE_VERSION_MINOR   = 7;
  LIBSWSCALE_VERSION_RELEASE = 100;
{$IFEND}

{$IF Defined(IncludeConstants)}
  sw__resample = 'libswresample';
  LIBSWRESAMPLE_VERSION_MAJOR   = 3;
  LIBSWRESAMPLE_VERSION_MINOR   = 7;
  LIBSWRESAMPLE_VERSION_RELEASE = 100;
{$IFEND}

{$UNDEF HaveProjectM}
{$IF Defined(HaveProjectM) and Defined(IncludeConstants)}
  ProjectM_DataDir = '';
  PROJECTM_VERSION_MAJOR   = 0;
  PROJECTM_VERSION_MINOR   = 0;
  PROJECTM_VERSION_RELEASE = 0;
{$IFEND}
