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

unit ULyrics;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  dglOpenGL,
  UCommon,
  UIni,
  UTexture,
  UThemes,
  UMusic;

type
  TLyricsEffect = (lfxSimple, lfxZoom, lfxSlide, lfxBall, lfxShift);

  PLyricWord = ^TLyricWord;
  TLyricWord = record
    X:          real;     // left corner
    Width:      real;     // width
    Start:      Longint; // start of the word in quarters (beats)
    Length:     Longint; // length of the word in quarters
    Text:       UTF8String; // text
    Freestyle:  boolean;  // is freestyle?
  end;
  TLyricWordArray = array of TLyricWord;

  TLyricLine = class
    public
      Text:           UTF8String;   // text
      Width:          real;         // width
      Height:         real;         // height
      Words:          TLyricWordArray;   // words in this line
      CurWord:        integer;      // current active word idx (only valid if line is active)
      Start:          integer;      // start of this line in quarters (Note: negative start values are possible due to gap)
      StartNote:      integer;      // start of the first note of this line in quarters
      Length:         integer;      // length in quarters (from start of first to the end of the last note)
      Players:        byte;         // players that should sing that line (bitset, Player1: 1, Player2: 2, Player3: 4)
      LastLine:       boolean;      // is this the last line of the song?

      constructor Create();
      destructor Destroy(); override;
      procedure Reset();
  end;

  TLyricEngine = class
    private
      LastDrawBeat:   real;
      UpperLine:      TLyricLine;    // first line displayed (top)
      LowerLine:      TLyricLine;    // second lind displayed (bottom)
      QueueLine:      TLyricLine;    // third line (will be displayed when lower line is finished)

      IndicatorTex:   TTexture;      // texture for lyric indikator
      BallTex:        TTexture;      // texture of the ball for the lyric effect

      QueueFull:      boolean;       // set to true if the queue is full and a line will be replaced with the next AddLine
      LCounter:       integer;       // line counter
      LyricsFont: byte; //font for the lyric text
      LyricBar: TThemeLyricBar; //line position
      Player: integer;
      IsJukebox: boolean;
      // Some helper procedures for lyric drawing
      procedure UpdateLineMetrics(LyricLine: TLyricLine);
      procedure DrawLyricsWords(LyricLine: TLyricLine; X, Y: real; StartWord, EndWord: integer);
      procedure DrawLyricsLine(IsUpperLine: boolean; Beat: real);
      procedure DrawBall(XBall, YBall, Alpha: real);

    public
      // display propertys
      LyricsEffect: TLyricsEffect;
      Alpha: real;    // alphalevel to fade out at end
      LineColor_en:   TRGB;      // Color of words in an enabled line
      LineColor_dis:  TRGB;      // Color of words in a disabled line
      LineColor_act:  TRGB;      // Color of the active word
      OutlineColor_act: TRGB;                  // outline color actual line
      OutlineColor_dis: TRGB;                  // outline color next line
      OutlineColor_en:  TRGB;                  // outline color sing line

      {
      LineOColor_en:   TRGBA;      // Color of outline words in an enabled line
      LineOColor_dis:  TRGBA;      // Color of outline words in a disabled line
      LineOColor_act:  TRGBA;      // Color of outline the active word
      }

      { // currently not used
       FadeInEffect:   byte;       // Effect for line fading in: 0: No Effect; 1: Fade Effect; 2: Move Upwards from Bottom to Pos
       FadeOutEffect:  byte;       // Effect for line fading out: 0: No Effect; 1: Fade Effect; 2: Move Upwards
      }

      // song specific settings
      BPM:            real;

      // properties to easily read options of this class
      property IsQueueFull: boolean read QueueFull;  // line in queue?
      property LineCounter: integer read LCounter;   // lines that were progressed so far (after last clear)

      procedure AddLine(Line: PLine);              // adds a line to the queue, if there is space
      procedure Draw (Beat: real);                 // draw the current (active at beat) lyrics

      // clears all cached song specific information
      procedure Clear(cBPM: real = 0);

      function GetUpperLine(): TLyricLine;
      function GetLowerLine(): TLyricLine;
      function GetOffset(): integer; //Get lyric offset in jukebox mode
      function GetUpperLineIndex(): integer;
      procedure SetProperties(IsJukeboxLyric: boolean); //Set lyric properties for classic or jukebox mode
      constructor Create(ThemeLyricBar: TThemeLyricBar; PlayerNumber: integer = 0; IsJukeboxLyric: boolean = false);
      procedure   LoadTextures;
      destructor  Destroy; override;
  end;

implementation

uses
  SysUtils,
  USkins,
  TextGL,
  UGraphic,
  UDisplay,
  ULog,
  math;

{ TLyricLine }

constructor TLyricLine.Create();
begin
  inherited;
  Reset();
end;

destructor TLyricLine.Destroy();
begin
  SetLength(Words, 0);
  inherited;
end;

procedure TLyricLine.Reset();
begin
  Start     := 0;
  StartNote := 0;
  Length    := 0;
  LastLine  := False;

  Text      := '';
  Width     := 0;

  // duet mode: players of that line (default: all)
  Players   := $FF;

  SetLength(Words, 0);
  CurWord   := -1;
end;


{ TLyricEngine }

{
  Initializes the engine.
  Player -1 = ScreenOptionsLyrics
  Player 0 = Single player
  Player > 0 = Multiplayer
}
constructor TLyricEngine.Create(ThemeLyricBar: TThemeLyricBar; PlayerNumber: integer = 0; IsJukeboxLyric: boolean = false);
begin
  inherited Create();

  BPM := 0;
  LCounter := 0;
  QueueFull := False;

  UpperLine := TLyricLine.Create;
  LowerLine := TLyricLine.Create;
  QueueLine := TLyricLine.Create;

  LastDrawBeat := 0;
  Self.LyricBar := ThemeLyricBar;
  LoadTextures;
  Self.Player := PlayerNumber;
  Self.IsJukebox := IsJukeboxLyric;
end;

{**
 * Frees memory.
 *}
destructor TLyricEngine.Destroy;
begin
  UpperLine.Free;
  LowerLine.Free;
  QueueLine.Free;
  inherited;
end;

{**
 * Clears all cached Song specific Information.
 *}
procedure TLyricEngine.Clear(cBPM: real);
begin
  BPM := cBPM;
  LCounter := 0;
  QueueFull := False;

  LastDrawBeat:=0;
  Self.SetProperties(Self.IsJukebox);
end;


{**
 * Loads textures needed for the drawing the lyrics,
 * player icons, a ball for the ball effect and the lyric indicator.
 *}
procedure TLyricEngine.LoadTextures;
begin
  // lyric indicator (bar that indicates when the line start)
  IndicatorTex := Texture.LoadTexture(Skin.GetTextureFileName('LyricHelpBar'), TEXTURE_TYPE_TRANSPARENT, $FF00FF);

  // ball for current word hover in ball effect
  BallTex := Texture.LoadTexture(Skin.GetTextureFileName('Ball'), TEXTURE_TYPE_TRANSPARENT, 0);
end;

{**
 * Adds LyricLine to queue.
 * The LyricEngine stores three lines in its queue:
 *   UpperLine: the upper line displayed in the lyrics
 *   LowerLine: the lower line displayed in the lyrics
 *   QueueLine: an offscreen line that precedes LowerLine
 * If the queue is full the next call to AddLine will replace UpperLine with
 * LowerLine, LowerLine with QueueLine and QueueLine with the Line parameter.
 *}
procedure TLyricEngine.AddLine(Line: PLine);
var
  LyricLine: TLyricLine;
  I: integer;
begin
  // only add lines, if there is space
  if not IsQueueFull then
  begin
    // set LyricLine to line to write to
    if (LineCounter = 0) then
      LyricLine := UpperLine
    else if (LineCounter = 1) then
      LyricLine := LowerLine
    else
    begin
      // now the queue is full
      LyricLine := QueueLine;
      QueueFull := True;
    end;
  end
  else
  begin // rotate lines (round-robin-like)
    LyricLine := UpperLine;
    UpperLine := LowerLine;
    LowerLine := QueueLine;
    QueueLine := LyricLine;
  end;

  // reset line state
  LyricLine.Reset();

  // check if sentence has notes
  if (Line <> nil) and (Length(Line^.Note) > 0) then
  begin

    // copy values from SongLine to LyricLine
    LyricLine.Start     := Line^.Start;
    LyricLine.StartNote := Line^.Note[0].Start;
    LyricLine.Length    := Line^.Note[High(Line^.Note)].Start +
                           Line^.Note[High(Line^.Note)].Length -
                           Line^.Note[0].Start;
    LyricLine.LastLine  := Line^.LastLine;

    // copy words
    SetLength(LyricLine.Words, Length(Line^.Note));
    for I := 0 to High(Line^.Note) do
    begin
      LyricLine.Words[I].Start     := Line^.Note[I].Start;
      LyricLine.Words[I].Length    := Line^.Note[I].Length;
      LyricLine.Words[I].Text      := Line^.Note[I].Text;
      LyricLine.Words[I].Freestyle := Line^.Note[I].NoteType = ntFreestyle;

      LyricLine.Text := LyricLine.Text + LyricLine.Words[I].Text;
    end;

    UpdateLineMetrics(LyricLine);
  end;

  // increase the counter
  Inc(LCounter);
end;

{**
 * Draws Lyrics.
 * @param Beat: current Beat in Quarters
 *}
procedure TLyricEngine.Draw(Beat: real);
begin
  Self.DrawLyricsLine(true, Beat);
  Self.DrawLyricsLine(false, Beat);
  LastDrawBeat := Beat;
end;

{**
 * Draws the Ball over the LyricLine if needed.
 *}
procedure TLyricEngine.DrawBall(XBall, YBall, Alpha: real);
begin
  glEnable(GL_TEXTURE_2D);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glBindTexture(GL_TEXTURE_2D, BallTex.TexNum);

  glColor4f(1, 1, 1, Alpha);
  glBegin(GL_QUADS);
    glTexCoord2f(0, 0); glVertex2f(XBall - 10, YBall);
    glTexCoord2f(0, 1); glVertex2f(XBall - 10, YBall + 20);
    glTexCoord2f(1, 1); glVertex2f(XBall + 10, YBall + 20);
    glTexCoord2f(1, 0); glVertex2f(XBall + 10, YBall);
  glEnd;

  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
end;

procedure TLyricEngine.DrawLyricsWords(LyricLine: TLyricLine;
    X, Y: real; StartWord, EndWord: integer);
var
  I: integer;
  PosX: real;
  CurWord: PLyricWord;
begin
  PosX := X;

  // set word positions and line size and draw the line
  for I := StartWord to EndWord do
  begin
    CurWord := @LyricLine.Words[I];
    SetFontItalic(CurWord^.Freestyle);
    SetFontPos(PosX, Y);
    glPrint(CurWord^.Text);
    PosX := PosX + CurWord^.Width;
  end;
end;

procedure TLyricEngine.UpdateLineMetrics(LyricLine: TLyricLine);
var
  I: integer;
  PosX: real;
  CurWord: PLyricWord;
  RequestWidth, RequestHeight: real;
begin
  PosX := 0;

  // setup font
  TextGL.SetFontStyle(Self.LyricsFont);
  ResetFont();

  // check if line is lower or upper line and set sizes accordingly
  // Note: at the moment upper and lower lines have same width/height
  // and this function is just called by AddLine() but this may change
  // so that it is called by DrawLyricsLine().
  //if (LyricLine = LowerLine) then
  //begin
  //  RequestWidth  := Self.LyricBar.LowerW;
  //  RequestHeight := Self.LyricBar.LowerH;
  //end
  //else
  //begin
    RequestWidth := Self.LyricBar.Upper.W;
    RequestHeight := Self.LyricBar.Upper.H;
  //end;

  // set font size to a reasonable value
  LyricLine.Height := RequestHeight * 0.9;
  SetFontSize(LyricLine.Height);
  LyricLine.Width := glTextWidth(LyricLine.Text);

  // change font-size to fit into the lyric bar
  if (LyricLine.Width > RequestWidth) then
  begin
    LyricLine.Height := Trunc(LyricLine.Height * (RequestWidth / LyricLine.Width));
    // the line is very loooong, set font to at least 1px
    if (LyricLine.Height < 1) then
      LyricLine.Height := 1;

    SetFontSize(LyricLine.Height);
    LyricLine.Width := glTextWidth(LyricLine.Text);
  end;

  // calc word positions and widths
  for I := 0 to High(LyricLine.Words) do
  begin
    CurWord := @LyricLine.Words[I];

    // - if current word is italic but not the next word get the width of the
    // italic font to avoid overlapping.
    // - if two italic words follow each other use the normal style's
    // width otherwise the spacing between the words will be too big.
    // - if it is the line's last word use normal width
    if CurWord^.Freestyle and
       (I+1 < Length(LyricLine.Words)) and
       (not LyricLine.Words[I+1].Freestyle) then
    begin
      SetFontItalic(true);
    end;

    CurWord^.X := PosX;
    CurWord^.Width := glTextWidth(CurWord^.Text);
    PosX := PosX + CurWord^.Width;
    SetFontItalic(false);
  end;
end;


{**
 * Draws one LyricLine
 *}
procedure TLyricEngine.DrawLyricsLine(IsUpperLine: boolean; Beat: real);
var
  Position: TThemePosition;
  Line: TLyricLine;
  CurWord:        PLyricWord;     // current word
  LastWord:       PLyricWord;     // last word in line
  NextWord:       PLyricWord;     // word following current word
  Progress:       real;           // progress of singing the current word
  LyricX, LyricY: real;           // left/top lyric position
  WordY: real;                    // word y-position
  ClipPlaneEq: array[0..3] of GLdouble; // clipping plane for slide effect
  {// duet mode
  IconSize: real;                 // size of player icons
  IconAlpha: real;                // alpha level of player icons
  }
begin
  if IsUpperLine then
  begin
    Position := Self.LyricBar.Upper;
    Line := Self.UpperLine;
  end
  else
  begin
    Position := Self.LyricBar.Lower;
    Line := Self.LowerLine;
  end;

  // do not draw empty lines
  if (Length(Line.Words) = 0) then
    Exit;

  // set font size and style
  TextGL.SetFontStyle(Self.LyricsFont);
  TextGL.SetFontSize(Line.Height);
  TextGL.ResetFont();

  // center lyrics
  LyricX := Position.X + (Position.W - Line.Width) / 2;
  LyricY := Position.Y + Self.LyricBar.YOffset + (Position.H - Line.Height) / 2;

  // check if this line is active (at least its first note must be active)
  if (Beat >= Line.StartNote) then
  begin

    // if this line just got active, CurWord is -1,
    // this means we should try to make the first word active
    if (Line.CurWord = -1) then
      Line.CurWord := 0;

    // check if the current active word is still active.
    // Otherwise proceed to the next word if there is one in this line.
    // Note: the max. value of Line.CurWord is High(Line.Words)
    if (Line.CurWord < High(Line.Words)) and
       (Beat >= Line.Words[Line.CurWord + 1].Start) then
    begin
      Inc(Line.CurWord);
    end;

    // determine current and last word in this line.
    // If the end of the line is reached use the last word as current word.
    LastWord := @Line.Words[High(Line.Words)];
    CurWord := @Line.Words[Line.CurWord];
    if (Line.CurWord+1 < Length(Line.Words)) then
      NextWord := @Line.Words[Line.CurWord+1]
    else
      NextWord := nil;

    // calc the progress of the lyrics effect
    Progress := (Beat - CurWord^.Start) / CurWord^.Length;
    if (Progress >= 1) then
      Progress := 1;
    if (Progress <= 0) then
      Progress := 0;

    // last word of this line finished, but this line did not hide -> fade out
    if Line.LastLine and
     (Beat > LastWord^.Start + LastWord^.Length) then
    begin
      Alpha := 1 - (Beat - (LastWord^.Start + LastWord^.Length)) / 15;
      if (Alpha < 0) then
        Alpha := 0;
    end;

    // outline color
    SetOutlineColor(OutlineColor_act.R, OutlineColor_act.G, OutlineColor_act.B, Alpha);

    // draw sentence before current word
    if (LyricsEffect in [lfxSimple, lfxBall, lfxShift]) then
      // only highlight current word and not that ones before in this line
      glColor4f(LineColor_en.R, LineColor_en.G ,LineColor_en.B, Alpha)
    else
      glColor4f(LineColor_act.R, LineColor_act.G ,LineColor_act.B, Alpha);

    DrawLyricsWords(Line, LyricX, LyricY, 0, Line.CurWord-1);

    // draw rest of sentence (without current word)
    glColor4f(LineColor_en.R, LineColor_en.G ,LineColor_en.B, Alpha);

    if (NextWord <> nil) then
    begin

      // outline color
      SetOutlineColor(OutlineColor_en.R, OutlineColor_en.G, OutlineColor_en.B, Alpha);

      DrawLyricsWords(Line, LyricX + NextWord^.X, LyricY,
                      Line.CurWord+1, High(Line.Words));
    end;

    // outline color
    SetOutlineColor(OutlineColor_act.R, OutlineColor_act.G, OutlineColor_act.B, Alpha);

    // draw current word
    if LyricsEffect in [lfxSimple, lfxBall, lfxShift] then
    begin
      if (LyricsEffect = lfxShift) then
        WordY := LyricY - 8 * (1-Progress)
      else
        WordY := LyricY;
      // change the color of the current word
      glColor4f(LineColor_act.R, LineColor_act.G ,LineColor_act.B, Alpha);

      DrawLyricsWords(Line, LyricX + CurWord^.X, WordY, Line.CurWord, Line.CurWord);
    end
    // change color and zoom current word
    else if (LyricsEffect = lfxZoom) then
    begin
      glPushMatrix;

      // zoom at word center
      glTranslatef(LyricX + CurWord^.X + CurWord^.Width/2,
                   LyricY + Line.Height/2, 0);
      glScalef(1.0 + (1-Progress) * 0.5, 1.0 + (1-Progress) * 0.5, 1);

      glColor4f(LineColor_act.R, LineColor_act.G ,LineColor_act.B, Alpha);

      DrawLyricsWords(Line, -CurWord^.Width/2, -Line.Height/2, Line.CurWord, Line.CurWord);

      glPopMatrix;
    end
    // split current word into active and non-active part
    else if (LyricsEffect = lfxSlide) then
    begin
      // enable clipping and set clip equation coefficients to zeros
      glEnable(GL_CLIP_PLANE0);
      FillChar(ClipPlaneEq[0], SizeOf(ClipPlaneEq), 0);

      glPushMatrix;
      glTranslatef(LyricX + CurWord^.X, LyricY, 0);

      // clip non-active right part of the current word
      ClipPlaneEq[0] := -1;
      ClipPlaneEq[3] := CurWord^.Width * Progress;
      if CurWord^.Freestyle then //add a extra width to fill in full freestyle italic notes
        ClipPlaneEq[3] += 5;

      glClipPlane(GL_CLIP_PLANE0, @ClipPlaneEq);
      // and draw active left part
      glColor4f(LineColor_act.R, LineColor_act.G ,LineColor_act.B, Alpha);

      DrawLyricsWords(Line, 0, 0, Line.CurWord, Line.CurWord);

      // clip active left part of the current word
      ClipPlaneEq[0] := -ClipPlaneEq[0];
      ClipPlaneEq[3] := -ClipPlaneEq[3];
      glClipPlane(GL_CLIP_PLANE0, @ClipPlaneEq);
      // and draw non-active right part
      glColor4f(LineColor_en.R, LineColor_en.G ,LineColor_en.B, Alpha);

      DrawLyricsWords(Line, 0, 0, Line.CurWord, Line.CurWord);

      glPopMatrix;

      glDisable(GL_CLIP_PLANE0);
    end;

    // draw the ball onto the current word
    if (LyricsEffect = lfxBall) then
    begin
      DrawBall(LyricX + CurWord^.X + CurWord^.Width * Progress,
               LyricY - 15 - 15*sin(Progress * Pi), Alpha);
    end;

  end
  else
  begin
    // this section is called if the whole line can be drawn at once and no
    // word is highlighted.

    // enable the upper, disable the lower line
    if (Line = UpperLine) then
    begin
      // outline color
      SetOutlineColor(OutlineColor_en.R, OutlineColor_en.G, OutlineColor_en.B, Alpha);

      glColor4f(LineColor_en.R, LineColor_en.G ,LineColor_en.B, Alpha);
    end
    else
    begin
      // outline color
      SetOutlineColor(OutlineColor_dis.R, OutlineColor_dis.G, OutlineColor_dis.B, Alpha);

      glColor4f(LineColor_dis.R, LineColor_dis.G ,LineColor_dis.B, Alpha);
    end;

    DrawLyricsWords(Line, LyricX, LyricY, 0, High(Line.Words));

  end;

  // reset
  SetOutlineColor(0,0,0,1);

end;

{**
 * @returns a reference to the upper line
 *}
function TLyricEngine.GetUpperLine(): TLyricLine;
begin
  Result := UpperLine;
end;

{**
 * @returns a reference to the lower line
 *}
function TLyricEngine.GetLowerLine(): TLyricLine;
begin
  Result := LowerLine;
end;

{ Get lyric offset in jukebox mode }
function TLyricEngine.GetOffset(): integer;
begin
  Result := Self.LyricBar.YOffset;
end;

{**
 * @returns the index of the upper line
 *}
function TLyricEngine.GetUpperLineIndex(): integer;
const
  QUEUE_SIZE = 3;
begin
  // no line in queue
  if (LineCounter <= 0) then
    Result := -1
  // no line has been removed from queue yet
  else if (LineCounter <= QUEUE_SIZE) then
    Result := 0
  // lines have been removed from queue already
  else
    Result := LineCounter - QUEUE_SIZE;
end;

{ Set lyric properties for classic or jukebox mode }
procedure TLyricEngine.SetProperties(IsJukeboxLyric: boolean);
begin
  if IsJukeboxLyric then
  begin
    Self.Alpha := StrToFloat(UIni.ILyricsAlpha[UIni.Ini.JukeboxTransparency]);
    Self.LyricBar.YOffset := IfThen(Self.Player = -1, 0, (100 - UIni.Ini.JukeboxOffset) * -5);
    Self.LyricsEffect := TLyricsEffect(UIni.Ini.JukeboxEffect);
    Self.LyricsFont := UIni.Ini.JukeboxFont;
    Self.LineColor_act := HexToRGB(UIni.Ini.JukeboxSingColor);
    Self.LineColor_en := HexToRGB(UIni.Ini.JukeboxCurrentColor);
    Self.LineColor_dis := HexToRGB(UIni.Ini.JukeboxNextColor);
    Self.OutlineColor_act := HexToRGB(UIni.Ini.JukeboxSingOutlineColor);
    Self.OutlineColor_en := HexToRGB(UIni.Ini.JukeboxCurrentOutlineColor);
    Self.OutlineColor_dis := HexToRGB(UIni.Ini.JukeboxNextOutlineColor);
  end
  else
  begin
    Self.Alpha := StrToFloat(UIni.ILyricsAlpha[UIni.Ini.LyricsTransparency]);
    Self.LyricBar.YOffset := 0;
    Self.LyricsEffect := TLyricsEffect(UIni.Ini.LyricsEffect);
    Self.LyricsFont := UIni.Ini.LyricsFont;
    if Self.Player < 1 then
      Self.LineColor_act := HexToRGB(UIni.Ini.LyricsSingColor)
    else
      Self.LineColor_act := UThemes.GetPlayerColor(UIni.Ini.PlayerColor[Player - 1]);

    Self.LineColor_en := HexToRGB(UIni.Ini.LyricsCurrentColor);
    Self.LineColor_dis := HexToRGB(UIni.Ini.LyricsNextColor);
    Self.OutlineColor_act := HexToRGB(UIni.Ini.LyricsSingOutlineColor);
    Self.OutlineColor_en := HexToRGB(UIni.Ini.LyricsCurrentOutlineColor);
    Self.OutlineColor_dis := HexToRGB(UIni.Ini.LyricsNextOutlineColor);
  end;
  Self.UpdateLineMetrics(Self.UpperLine);
  Self.UpdateLineMetrics(Self.LowerLine);
end;

end.
