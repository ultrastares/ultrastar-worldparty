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

{* Libraries *}

{$IF Defined(IncludeConstants)}
  LUA_LIB_NAME        = 'lua';
  LUA_VERSION_INT     = 5001005;
  LUA_VERSION_RELEASE = '5';
  LUA_VERSION_MINOR   = '1';
  LUA_VERSION_MAJOR   = '5';
  LUA_VERSION         = '5.1.5';
  LUA_INTEGER_BITS    = 32;
{$IFEND}

//the required DLLs can be downloaded here: https://ffmpeg.zeranoe.com/builds/win32/shared/
{$MACRO ON}
{$IFNDEF FFMPEG_DIR}
  {$DEFINE FFMPEG_DIR := 'ffmpeg-4.0'}
{$ENDIF}
{$IF Defined(IncludeConstants)}
  FFMPEG_VERSION_INT = 4002002;
  av__codec = 'avcodec-58';
  LIBAVCODEC_VERSION_MAJOR = 58;
  LIBAVCODEC_VERSION_MINOR = 91;
  LIBAVCODEC_VERSION_RELEASE = 100;

  av__format = 'avformat-58';
  LIBAVFORMAT_VERSION_MAJOR = 58;
  LIBAVFORMAT_VERSION_MINOR = 45;
  LIBAVFORMAT_VERSION_RELEASE = 100;

  av__util = 'avutil-56';
  LIBAVUTIL_VERSION_MAJOR = 56;
  LIBAVUTIL_VERSION_MINOR = 51;
  LIBAVUTIL_VERSION_RELEASE = 100;

  sw__resample = 'swresample-3';
  LIBSWRESAMPLE_VERSION_MAJOR   = 3;
  LIBSWRESAMPLE_VERSION_MINOR   = 7;
  LIBSWRESAMPLE_VERSION_RELEASE = 100;

  sw__scale = 'swscale-5';
  LIBSWSCALE_VERSION_MAJOR   = 5;
  LIBSWSCALE_VERSION_MINOR   = 7;
  LIBSWSCALE_VERSION_RELEASE = 100;
{$IFEND}

{$DEFINE UseBASS}

{$DEFINE HaveProjectM}
{$IF Defined(HaveProjectM) and Defined(IncludeConstants)}
  ProjectM_DataDir = 'Visuals\projectM';
  PROJECTM_VERSION_MAJOR   = 1;
  PROJECTM_VERSION_MINOR   = 10;
  PROJECTM_VERSION_RELEASE = 0;
{$IFEND}

{$DEFINE UseMIDIPort}
