{* UltraStar Deluxe - Karaoke Game
 *
 * UltraStar Deluxe is the legal property of its developers, whose names
 * are too numerous to list here. Please refer to the COPYRIGHT
 * file distributed with this source distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 * $URL: https://ultrastardx.svn.sourceforge.net/svnroot/ultrastardx/trunk/src/base/UPlaylist.pas $
 * $Id: $
 *}

unit UWebcam;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  Classes,
  UTexture,
  opencv_core,
  opencv_highgui,
  opencv_imgproc,
  opencv_types;

type

  TWebcam = class
    private
      LastTickFrame: integer;

    public
      Capture: PCvCapture;
      TextureCam: TTexture;

      constructor Create;
      procedure Release;
      procedure GetWebcamFrame;
   end;

var
  Webcam:  TWebcam;


implementation

uses
  gl,
  SysUtils,
  SDL,
  ULog,
  UIni;

//----------
//Create - Construct Class - Dummy for now
//----------
constructor TWebcam.Create;
var
  H, W, I, Count: integer;
  s: string;
begin
  inherited;

  Capture := cvCreateCameraCapture(Ini.WebCamID);

  if (Capture <> nil) then
  begin
    S := IWebcamResolution[Ini.WebcamResolution];

    I := Pos('x', S);
    W := StrToInt(Copy(S, 1, I-1));
    H := StrToInt(Copy(S, I+1, 1000));

    cvSetCaptureProperty(Capture, CV_CAP_PROP_FRAME_WIDTH, W);
    cvSetCaptureProperty(Capture, CV_CAP_PROP_FRAME_HEIGHT, H);
  end;

end;

procedure TWebcam.Release;
begin
  if (Capture <> nil) then
    cvReleaseCapture(@Capture);
end;

procedure TWebcam.GetWebcamFrame;
var
  WebcamFrame: PIplImage;
begin
  if ((SDL_GetTicks() - LastTickFrame) >= 1000/StrToInt(IWebcamFPS[Ini.WebCamFPS])) then
  begin
    if (TextureCam.TexNum > 0) then
    begin
      glDeleteTextures(1, PGLuint(@TextureCam.TexNum));
      TextureCam.TexNum := 0;
    end;

    WebcamFrame := cvQueryFrame(Capture);
    cvCvtColor(WebcamFrame, WebcamFrame, CV_BGR2RGB);

    cvFlip(WebcamFrame, nil, 1);
    TextureCam := Texture.CreateTexture(WebcamFrame.imageData, nil, WebcamFrame.Width, WebcamFrame.Height, WebcamFrame.depth);

    WebcamFrame := nil;
    cvReleaseImage(@WebcamFrame);
    //cvReleaseImage(@ScreenSing.RGBFrame);
    LastTickFrame := SDL_GetTicks();

    // wait for a key
    cvWaitKey(0);
  end;

end;

{
function FrameEffect(Nr_Effect: integer; Frame: PIplImage): PIplImage;
var
  Size: CvSize;
  HalfSize: CvSize;
  Red: integer;
  Green: integer;
  Blue: integer;
begin

  // default params values
  if (ScreenSing.CamEffectParam[Nr_Effect] = -1) then
  begin

    case Nr_Effect of
      2: ScreenSing.CamEffectParam[Nr_Effect] := 20;
      3: ScreenSing.CamEffectParam[Nr_Effect] := 2;
      4: ScreenSing.CamEffectParam[Nr_Effect] := 60;
      5: ScreenSing.CamEffectParam[Nr_Effect] := 70;
      6: ScreenSing.CamEffectParam[Nr_Effect] := 11;
      9: ScreenSing.CamEffectParam[Nr_Effect] := 2;
     10: ScreenSing.CamEffectParam[Nr_Effect] := 50;
     11: ScreenSing.CamEffectParam[Nr_Effect] := 5;
     12: ScreenSing.CamEffectParam[Nr_Effect] := 50;
    else
      ScreenSing.CamEffectParam[Nr_Effect] := 0;
    end;

  end;

  Size  := cvSizeV(Frame.width, Frame.height);
  HalfSize  := cvSizeV(Frame.width/2, Frame.height/2);

  if (ScreenSing.ImageFrame = nil) then
    ScreenSing.ImageFrame := cvCreateImage(Size, Frame.depth, 1);

  if (ScreenSing.EffectFrame = nil) then
    ScreenSing.EffectFrame := cvCreateImage(Size, Frame.depth, 1);

  if(ScreenSing.DiffFrame = nil) then
    ScreenSing.DiffFrame := cvCreateImage (Size, Frame.depth, 1);

  if(ScreenSing.RGBFrame = nil) then
    ScreenSing.RGBFrame := cvCreateImage(Size, Frame.depth, 3);

  case Nr_Effect of
    1: begin // Grayscale
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Grayscale';

         cvCvtColor(Frame, ScreenSing.EffectFrame, CV_BGR2GRAY);
         cvCvtColor(ScreenSing.EffectFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    2: begin // Binary Image Difference
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Binary Difference';

         //Convert frame to gray and store in image
         cvCvtColor(Frame, ScreenSing.ImageFrame, CV_BGR2GRAY);
         cvEqualizeHist(ScreenSing.ImageFrame, ScreenSing.ImageFrame);

         //Copy Image
         if(ScreenSing.LastFrame = nil) then
           ScreenSing.LastFrame := cvCloneImage(ScreenSing.ImageFrame);

         //Differences with actual and last image
         cvAbsDiff(ScreenSing.ImageFrame, ScreenSing.LastFrame, ScreenSing.DiffFrame);

         //threshold image
         cvThreshold(ScreenSing.DiffFrame, ScreenSing.EffectFrame, ScreenSing.CamEffectParam[Nr_Effect], 255, 0);

         cvReleaseImage(@ScreenSing.LastFrame);

         //Change datas;
         ScreenSing.LastFrame := cvCloneImage(ScreenSing.ImageFrame);

         cvCvtColor(ScreenSing.EffectFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    3: begin // Dilate
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Dilate';

         cvDilate(Frame, Frame, nil, ScreenSing.CamEffectParam[Nr_Effect]);
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    4: begin //threshold image
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Threshold';

         cvCvtColor(Frame, ScreenSing.ImageFrame, CV_BGR2GRAY);
         cvThreshold(ScreenSing.ImageFrame, ScreenSing.EffectFrame, ScreenSing.CamEffectParam[Nr_Effect], 100, 3);
         cvCvtColor(ScreenSing.EffectFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    5: begin // Edges
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Edges';

         cvCvtColor(Frame, ScreenSing.ImageFrame, CV_BGR2GRAY);
         cvCanny(ScreenSing.ImageFrame, ScreenSing.EffectFrame, ScreenSing.CamEffectParam[Nr_Effect], ScreenSing.CamEffectParam[Nr_Effect], 3);
         cvCvtColor(ScreenSing.EffectFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    6: begin // Gaussian Blur
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Gaussian Blur';

         if (ScreenSing.CamEffectParam[Nr_Effect] <= 0) then
           ScreenSing.CamEffectParam[Nr_Effect] := 1;

         cvSmooth(Frame, Frame, CV_BLUR, ScreenSing.CamEffectParam[Nr_Effect], ScreenSing.CamEffectParam[Nr_Effect]);
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    7: begin // Equalized
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Equalized';

         cvCvtColor(Frame, ScreenSing.ImageFrame, CV_BGR2GRAY);
         cvEqualizeHist(ScreenSing.ImageFrame, ScreenSing.EffectFrame);
         cvCvtColor(ScreenSing.EffectFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    8: begin // Negative
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Negative';

         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         cvNot(ScreenSing.RGBFrame, ScreenSing.RGBFrame);
         Result := ScreenSing.RGBFrame;
       end;
    9: begin
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Erode';

         cvErode(Frame, Frame, nil, ScreenSing.CamEffectParam[Nr_Effect]);
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    10:begin // Brightness
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Brightness';

         cvAddS(Frame, CV_RGB(ScreenSing.CamEffectParam[Nr_Effect], ScreenSing.CamEffectParam[Nr_Effect], ScreenSing.CamEffectParam[Nr_Effect]), Frame);
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    11:begin // Contrast
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Contrast';

         cvConvertScale(Frame, Frame, ScreenSing.CamEffectParam[Nr_Effect]/10);
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    12:begin // Color
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Color';

         cvAddS(Frame, CV_RGB(255, 0, 0), Frame);
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    13:begin // Hue
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Hue';

         // Convert from Red-Green-Blue to Hue-Saturation-Value
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2HSV );

         // Split hue, saturation and value of hsv on them
         cvSplit(ScreenSing.RGBFrame, ScreenSing.ImageFrame, nil, nil, 0);
         cvCvtColor(ScreenSing.ImageFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    14:begin // Saturation
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Saturation';

         // Convert from Red-Green-Blue to Hue-Saturation-Value
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2HSV );

         // Split hue, saturation and value of hsv on them
         cvSplit(ScreenSing.RGBFrame, nil, ScreenSing.ImageFrame, nil, 0);
         cvCvtColor(ScreenSing.ImageFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    15:begin // Value
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Value';

         // Convert from Red-Green-Blue to Hue-Saturation-Value
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2HSV );

         // Split hue, saturation and value of hsv on them
         cvSplit(ScreenSing.RGBFrame, nil, nil, ScreenSing.ImageFrame, 0);
         cvCvtColor(ScreenSing.ImageFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    16:begin // Black & White
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'Black & White';

         cvCvtColor(Frame, ScreenSing.ImageFrame, CV_BGR2GRAY );
         cvThreshold(ScreenSing.ImageFrame, ScreenSing.EffectFrame, 128, 255, CV_THRESH_OTSU);
         cvCvtColor(ScreenSing.EffectFrame, ScreenSing.RGBFrame, CV_GRAY2RGB);
         Result := ScreenSing.RGBFrame;
       end;
    17:begin //
         ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
         ScreenSing.Text[ScreenSing.WebcamText].Text := 'TESTE';

         //ScreenSing.RGBFrame := Frame;
         //SDL_CreateThread(@FindFaces, nil);
         cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
         Result := ScreenSing.RGBFrame;
       end
    else
    begin
      ScreenSing.Statics[ScreenSing.WebcamStatic].Visible := true;
      ScreenSing.Text[ScreenSing.WebcamText].Visible := true;
      ScreenSing.Text[ScreenSing.WebcamText].Text := 'Normal';

      cvCvtColor(Frame, ScreenSing.RGBFrame, CV_BGR2RGB);
      Result := ScreenSing.RGBFrame;
    end;
  end;


//  cvReleaseImage(@ScreenSing.ImageFrame);
//  cvReleaseImage(@ScreenSing.DiffFrame);
//  cvReleaseImage(@ScreenSing.EffectFrame);

end;
}
//----------

end.
