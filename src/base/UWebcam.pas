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

unit UWebcam;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  opencv_highgui,
  opencv_types,
  sdl2,
  UTexture;

type

  TWebcam = class
    private
      Enabled: boolean;
      CurrentFrame: PIplImage;
      LastFrame: PIplImage;
      Mutex: PSDL_Mutex;
      Thread: PSDL_Thread;
      function CaptureLoop: integer;
      class function CaptureThread(Data: Pointer): integer; cdecl; static;
    public
      Capture: PCvCapture;
      TextureCam: TTexture;
      constructor Create;
      destructor Destroy(); override;
      procedure Release;
      procedure Restart;
      procedure GetWebcamFrame();
      function FrameEffect(Nr_Effect: integer; Frame: PIplImage): PIplImage;
      function FrameAdjust(Frame: PIplImage): PIplImage;
   end;

var
  Webcam:    TWebcam;

implementation

uses
  opencv_core,
  opencv_imgproc,
  UCommon,
  UIni;

constructor TWebcam.Create;
begin
  inherited;
  Self.Enabled := false;
  Self.Mutex := SDL_CreateMutex();
end;

destructor TWebcam.Destroy();
begin
  Self.Release();
  SDL_DestroyMutex(Self.Mutex);
  inherited;
end;

procedure TWebcam.Release;
begin
  if Self.Enabled then
  begin
    Self.Enabled := false;
    SDL_WaitThread(Self.Thread, nil);
    cvReleaseCapture(@Self.Capture);
  end;
end;

procedure TWebcam.Restart;
var
  X, Y: integer;
begin
  Self.Release();
  if UIni.Ini.WebCamID <> 0 then
    try
      Self.Capture := cvCreateCameraCapture(UIni.Ini.WebCamID - 1);
      if Self.Capture <> nil then
      begin
        UCommon.ParseResolutionString(UIni.IWebcamResolution[UIni.Ini.WebcamResolution], X, Y);
        cvSetCaptureProperty(Self.Capture, CV_CAP_PROP_FRAME_WIDTH, X);
        cvSetCaptureProperty(Self.Capture, CV_CAP_PROP_FRAME_HEIGHT, Y);
        Self.Thread := SDL_CreateThread(@TWebcam.CaptureThread, nil, Self);
        Self.Enabled := true;
      end;
    except
      Self.Enabled := false;
    end;
end;

class function TWebcam.CaptureThread(Data: Pointer): integer; cdecl; static;
begin
  Result := TWebcam(Data).CaptureLoop;
end;

function TWebcam.CaptureLoop: integer;
var
  WebcamFrame: PIplImage;
begin
  SDL_LockMutex(Self.Mutex);
  while Self.Enabled do
  begin
    SDL_UnlockMutex(Self.Mutex);
    WebcamFrame := cvCloneImage(cvQueryFrame(Self.Capture));
    SDL_LockMutex(Self.Mutex);
    if WebcamFrame <> nil then
    begin
      cvReleaseImage(@Self.CurrentFrame);
      Self.CurrentFrame := WebcamFrame;
    end;
  end;
  SDL_UnlockMutex(Self.Mutex);
  Result := 0;
end;

procedure TWebcam.GetWebcamFrame();
var
  WebcamFrame: PIplImage;
begin
  if Self.Enabled then
  begin
    SDL_LockMutex(Self.Mutex);
    WebcamFrame := Self.CurrentFrame;
    Self.CurrentFrame := nil;
    SDL_UnlockMutex(Self.Mutex);
    if WebcamFrame <> nil then
    begin
      if Self.TextureCam.TexNum > 0 then
        UTexture.Texture.UnLoadTexture(Self.TextureCam);

      if UIni.Ini.WebCamFlip = 0 then
        cvFlip(WebcamFrame, nil, 1);

      WebcamFrame := Self.FrameEffect(UIni.Ini.WebCamEffect, Self.FrameAdjust(WebcamFrame));
      Self.TextureCam := UTexture.Texture.CreateTexture(WebcamFrame.imageData, nil, WebcamFrame.Width, WebcamFrame.Height, WebcamFrame.depth);
      cvReleaseImage(@WebcamFrame);
    end;
  end;
end;

// 0  -> NORMAL
// 1  -> GRAYSCALE
// 2  -> BLACK & WHITE
// 3  -> NEGATIVE
// 4  -> BINARY IMAGE
// 5  -> DILATE
// 6  -> THRESHOLD
// 7  -> EDGES
// 8  -> GAUSSIAN BLUR
// 9  -> EQUALIZED
// 10 -> ERODE
function TWebcam.FrameEffect(Nr_Effect: integer; Frame: PIplImage): PIplImage;
var
  Size: CvSize;
  DiffFrame, EffectFrame, ImageFrame, RGBFrame: PIplImage;
begin
  Size  := cvSizeV(Frame.width, Frame.height);
  ImageFrame := cvCreateImage(Size, Frame.depth, 1);
  EffectFrame := cvCreateImage(Size, Frame.depth, 1);
  DiffFrame := cvCreateImage (Size, Frame.depth, 1);
  RGBFrame := cvCreateImage(Size, Frame.depth, 3);
  case Nr_Effect of
    1: //grayscale
      begin
        cvCvtColor(Frame, EffectFrame, CV_BGR2GRAY);
        cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
      end;
    2: //black & white
      begin
        cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY );
        cvThreshold(ImageFrame, EffectFrame, 128, 255, CV_THRESH_OTSU);
        cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
      end;
    3: //negative
      begin
        cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
        cvNot(RGBFrame, RGBFrame);
      end;
    4: //binary image
      begin
        //Convert frame to gray and store in image
        cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
        cvEqualizeHist(ImageFrame, ImageFrame);
        //Copy Image
        if(LastFrame = nil) then
          LastFrame := cvCloneImage(ImageFrame);
        //Differences with actual and last image
        cvAbsDiff(ImageFrame, LastFrame, DiffFrame);
        //threshold image
        cvThreshold(DiffFrame, EffectFrame, 20, 255, 0);
        cvReleaseImage(@LastFrame);
        //Change datas;
        LastFrame := cvCloneImage(ImageFrame);
        cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
      end;
    5: //dilate
      begin
        cvDilate(Frame, Frame, nil, 2);
        cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
      end;
    6: //threshold
      begin
        cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
        cvThreshold(ImageFrame, EffectFrame, 60, 100, 3);
        cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
      end;
    7: //edges
      begin
        cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
        cvCanny(ImageFrame, EffectFrame, 70, 70, 3);
        cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
      end;
    8: //gaussian blur
      begin
        cvSmooth(Frame, Frame, CV_BLUR, 11, 11);
        cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
      end;
    9: //equalized
      begin
        cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
        cvEqualizeHist(ImageFrame, EffectFrame);
        cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
      end;
    10: //erode
      begin
        cvErode(Frame, Frame, nil, 2);
        cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
      end;
    else
      cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
  end;
  cvReleaseImage(@DiffFrame);
  cvReleaseImage(@EffectFrame);
  cvReleaseImage(@Frame);
  cvReleaseImage(@ImageFrame);
  Result := RGBFrame;
end;

function TWebcam.FrameAdjust(Frame: PIplImage): PIplImage;
var
  Size: CvSize;
  BrightValue, SaturationValue, HueValue: integer;
  BrightValueConvt: real;
  ImageFrame, TmpFrame, ValueFrame: PIplImage;
begin
  Size  := cvSizeV(Frame.width, Frame.height);

  ImageFrame := cvCreateImage(Size, Frame.depth, 1);
  TmpFrame := cvCreateImage(Size, Frame.depth, 3);
  ValueFrame := cvCreateImage(Size, Frame.depth, 1);

  BrightValue := Ini.WebcamBrightness;

  if (BrightValue <> 100) then
  begin
    if (BrightValue > 100) then
      BrightValueConvt := (BrightValue - 100) * 255/100
    else
      BrightValueConvt := -((BrightValue - 100) * -255/100);

    cvAddS(Frame, CV_RGB(BrightValueConvt, BrightValueConvt, BrightValueConvt), Frame);
  end;
  cvReleaseImage(@ImageFrame);
  cvReleaseImage(@TmpFrame);
  cvReleaseImage(@ValueFrame);
  Result := Frame;
end;

end.
