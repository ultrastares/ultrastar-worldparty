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

unit UMenuStatic;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UTexture,
  UMenuInteract,
  dglOpenGL;

type
  TStatic = class
    public
      Texture:           TTexture; // Button Screen position and size
      Visible:           boolean;

      // for list item
      TextureSelect:     TTexture;
      TextureDeselect:   TTexture; // Button Screen position and size

      //Reflection Mod
      Reflection:        boolean;
      Reflectionspacing: real;

      procedure Draw;
      constructor Create(Textura: TTexture); overload;
      function GetMouseOverArea: TMouseOverRect;
  end;

implementation
uses
  UDrawTexture,
  UDisplay;

procedure TStatic.Draw;
begin
  if Visible then
  begin
    DrawTexture(Texture);

  //Reflection Mod
    if (Reflection) then // Draw Reflections
    begin
      with Texture do
      begin
        //Bind Tex and GL Attributes
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);

        glDepthRange(0, 10);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_DEPTH_TEST);

        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glBindTexture(GL_TEXTURE_2D, TexNum);

        //Draw
        glBegin(GL_QUADS);//Top Left
          glColor4f(ColR * Int, ColG * Int, ColB * Int, Alpha-0.3);
          glTexCoord2f(TexX1*TexW, TexY2*TexH);
          glVertex3f(x, y+h*scaleH+ Reflectionspacing, z);

          //Bottom Left
          glColor4f(ColR * Int, ColG * Int, ColB * Int, 0);
          glTexCoord2f(TexX1*TexW, 0.5*TexH+TexY1);
          glVertex3f(x, y+h*scaleH + h*scaleH/2 + Reflectionspacing, z);


          //Bottom Right
          glColor4f(ColR * Int, ColG * Int, ColB * Int, 0);
          glTexCoord2f(TexX2*TexW, 0.5*TexH+TexY1);
          glVertex3f(x+w*scaleW, y+h*scaleH + h*scaleH/2 + Reflectionspacing, z);

          //Top Right
          glColor4f(ColR * Int, ColG * Int, ColB * Int, Alpha-0.3);
          glTexCoord2f(TexX2*TexW, TexY2*TexH);
          glVertex3f(x+w*scaleW, y+h*scaleH + Reflectionspacing, z);
        glEnd;

        glDisable(GL_TEXTURE_2D);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);
      end;
    end;
  end;
end;

constructor TStatic.Create(Textura: TTexture);
begin
  inherited Create;
  Texture := Textura;
end;

function TStatic.GetMouseOverArea: TMouseOverRect;
begin
  Result.X := Self.Texture.X;
  Result.Y := Self.Texture.Y;
  Result.W := Self.Texture.W;
  Result.H := Self.Texture.H;
end;

end.
