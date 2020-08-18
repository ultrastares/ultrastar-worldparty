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

unit UAudioConverter;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMusic,
  ULog,
  ctypes,
  UMediaCore_SDL,
  sdl2,
  SysUtils,
  Math;

type
  {*
   * Notes:
   *  - 44.1kHz to 48kHz conversion or vice versa is not supported
   *    by SDL 1.2 (will be introduced in 1.3).
   *    No conversion takes place in this cases.
   *    This is because SDL just converts differences in powers of 2.
   *    So the result might not be that accurate.
   *    This IS audible (voice to high/low) and it needs good synchronization
   *    with the video or the lyrics timer.
   *  - float<->int16 conversion is not supported (will be part of 1.3) and
   *    SDL (<1.3) is not capable of handling floats at all.
   *  -> Using FFmpeg or libsamplerate for resampling is preferred.
   *     Use SDL for channel and format conversion only.
   *}
  TAudioConverter_SDL = class(TAudioConverter)
    private
      cvt: TSDL_AudioCVT;
    public
      function Init(SrcFormatInfo: TAudioFormatInfo; DstFormatInfo: TAudioFormatInfo): boolean; override;
      destructor Destroy(); override;

      function Convert(InputBuffer: PByteArray; OutputBuffer: PByteArray; var InputSize: integer): integer; override;
      function GetOutputBufferSize(InputSize: integer): integer; override;
      function GetRatio(): double; override;
  end;


implementation

uses
  UConfig;

function TAudioConverter_SDL.Init(srcFormatInfo: TAudioFormatInfo; dstFormatInfo: TAudioFormatInfo): boolean;
var
  srcFormat: UInt16;
  dstFormat: UInt16;
begin
  inherited Init(SrcFormatInfo, DstFormatInfo);

  Result := false;

  if not ConvertAudioFormatToSDL(srcFormatInfo.Format, srcFormat) or
     not ConvertAudioFormatToSDL(dstFormatInfo.Format, dstFormat) then
  begin
    Log.LogError('Audio-format not supported by SDL', 'TSoftMixerPlaybackStream.InitFormatConversion');
    Exit;
  end;

  if SDL_BuildAudioCVT(@cvt,
    srcFormat, srcFormatInfo.Channels, Round(srcFormatInfo.SampleRate),
    dstFormat, dstFormatInfo.Channels, Round(dstFormatInfo.SampleRate)) = -1 then
  begin
    Log.LogError(SDL_GetError(), 'TSoftMixerPlaybackStream.InitFormatConversion');
    Exit;
  end;

  Result := true;
end;

destructor TAudioConverter_SDL.Destroy();
begin
  // nothing to be done here
  inherited;
end;

(*
 * Returns the size of the output buffer. This might be bigger than the actual
 * size of resampled audio data.
 *)
function TAudioConverter_SDL.GetOutputBufferSize(InputSize: integer): integer;
begin
  // Note: len_ratio must not be used here. Even if the len_ratio is 1.0, len_mult might be 2.
  // Example: 44.1kHz/mono to 22.05kHz/stereo -> len_ratio=1, len_mult=2
  Result := InputSize * cvt.len_mult;
end;

function TAudioConverter_SDL.GetRatio(): double;
begin
  Result := cvt.len_ratio;
end;

function TAudioConverter_SDL.Convert(InputBuffer: PByteArray; OutputBuffer: PByteArray;
                                     var InputSize: integer): integer;
begin
  Result := -1;

  if InputSize <= 0 then
  begin
    // avoid div-by-zero problems
    if InputSize = 0 then
      Result := 0;
    Exit;
  end;

  // OutputBuffer is always bigger than or equal to InputBuffer
  Move(InputBuffer[0], OutputBuffer[0], InputSize);
  cvt.buf := PUint8(OutputBuffer);
  cvt.len := InputSize;
  if SDL_ConvertAudio(@cvt) = -1 then
    Exit;

  Result := cvt.len_cvt;
end;



end.
