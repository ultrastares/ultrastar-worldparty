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
unit UWebSDK;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

type
  // Website
  TWebsiteInfo = record
    Name:  array [0..30] of char;
    ID: integer;
  end;

  TSendInfo = record
      Username:   UTF8String;   // Username & name of the player
      Password:   UTF8String;   // Password
      ScoreInt:       integer;  // Player's Score Int
      ScoreLineInt:   integer;  // Player's Score Line
      ScoreGoldenInt: integer;  // Player's Score Golden
      MD5Song:        string;   // Song Hash
      Level:      byte;         // Level (0- Easy, 1- Medium, 2- Hard)
      Name: string; //player name
  end;

  TLoginInfo = record
      Username:   UTF8String;   // Username
      Password:   UTF8String;   // Password
  end;

  pModi_WebsiteInfo = procedure (var Info: TWebsiteInfo);
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  fModi_SendScore = function (SendInfo: TSendInfo): integer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  fModi_EncryptScore = function (SendInfo: TSendInfo): widestring;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  fModi_Login = function (LoginInfo: TLoginInfo): byte;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  fModi_EncryptPassword = function (LoginInfo: TLoginInfo): widestring;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  fModi_DownloadScore = function (ListMD5Song: widestring; Level: byte): widestring;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  fModi_VerifySong = function (MD5Song: widestring): widestring;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

implementation

end.
