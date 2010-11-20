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
    Panel1: TPanel;
    Timer1: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure ShowMyBalloonHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form2: TForm2;
  str0g, str1g: string;
  ng:integer;
  Xg, Yg:Longint;

implementation

{ TForm2 }

procedure TForm2.FormClick(Sender: TObject);
begin
   Form2.Hide;
end;

procedure TForm2.ShowMyBalloonHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
begin
  Form2.Hide;
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
  str0g:=str0;
  str1g:=str1;
  ng:=n;
  Xg:=X;
  Yg:=Y;
  Form2.Show;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Form2.Hide;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  Form2.Left:=Xg-Form2.Width;
  Form2.Top:=Yg-Form2.Height;
  Label1.Caption:=str0g;
  Label1.Font.Bold:=true;
  Label2.Caption:=str1g;
  Timer1.Interval:=ng;
end;

procedure TForm2.Image1Click(Sender: TObject);
begin
   Form2.Hide;
end;

procedure TForm2.Label1Click(Sender: TObject);
begin
   Form2.Hide;
end;

procedure TForm2.Label2Click(Sender: TObject);
begin
  Form2.Hide;
end;


initialization
  {$I unit2.lrs}

end.

