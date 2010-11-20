unit Unit2; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure FormClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure ShowMyBalloonHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
    procedure ShowMyHint (str0:string; n:integer; X, Y:Longint; AFont:integer);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
   Form2: TForm2;

implementation

{ TForm2 }

procedure TForm2.FormClick(Sender: TObject);
begin
   Form2.Hide;
   Timer1.Enabled:=false;
end;

procedure TForm2.ShowMyBalloonHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
begin
   Form2.Hide;
   Timer1.Enabled:=true;
   Form2.Font.Size:=AFont;
   Form2.Font.Color:=clBlack;
   Form2.Color:=$0092FFF8;
   Form2.Width:=AFont*30;
   Form2.Height:=AFont*13;
   Label1.BorderSpacing.Top:=AFont;
   Label1.BorderSpacing.Left:=AFont;
   Label2.BorderSpacing.Top:=AFont;
   Label2.BorderSpacing.Right:=AFont;
   Label2.BorderSpacing.Bottom:=AFont;
   if Y-Form2.Height>=0 then Form2.Top:=Y-Form2.Height;
   if Y-Form2.Height<0 then Form2.Top:=Y+22;//22 пикселя - размер иконки в трее
   if X-Form2.Width>=0 then Form2.Left:=X-Form2.Width;
   if X-Form2.Width<0 then Form2.Left:=X+22;
   Label1.Caption:=str0;
   Label1.Font.Bold:=true;
   Label2.Caption:=str1;
   Label3.Caption:='';
   Timer1.Interval:=n;
   Form2.Show;
end;

procedure TForm2.ShowMyHint (str0:string; n:integer; X, Y:Longint; AFont:integer);
begin
   Form2.Repaint;
   Timer1.Enabled:=true;
   Form2.Font.Size:=AFont;
   Form2.Font.Color:=clBlack;
   Form2.Color:=$0092FFF8;
   Form2.Width:=AFont*24;
   Form2.Height:=AFont*12;
   if Y-Form2.Height div 2>=0 then Form2.Top:=11+Y-Form2.Height div 2;
   if Y-Form2.Height div 2<0 then Form2.Top:=Y+11;//22 пикселя - размер иконки в трее
   if X-Form2.Width div 2>=0 then Form2.Left:=11+X-Form2.Width div 2;
   if X-Form2.Width div 2<0 then Form2.Left:=X+11;
   Label3.Caption:=str0;
   Label1.Caption:='';
   Label2.Caption:='';
   Timer1.Interval:=n;
   Form2.Show;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
   Form2.Hide;
   Timer1.Enabled:=false;
end;

procedure TForm2.Label1Click(Sender: TObject);
begin
   Form2.Hide;
   Timer1.Enabled:=false;
end;

procedure TForm2.Label2Click(Sender: TObject);
begin
   Form2.Hide;
   Timer1.Enabled:=false;
end;


initialization
  {$I unit2.lrs}

end.

