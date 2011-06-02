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
    Label4: TLabel;
    Panel1: TPanel;
    Timer1: TTimer; //таймер для балуна
    Timer2: TTimer; //таймер для хинта
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ShowMyBalloonHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
    procedure ShowMyHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
   Form2: TForm2;
   Xg,Yg: Longint;

implementation

{ TForm2 }

procedure TForm2.FormClick(Sender: TObject);
begin
   Form2.Hide;
   If Form2.Tag=1 then Timer1.Enabled:=false;
   If Form2.Tag=2 then Timer2.Enabled:=false;
   Form2.Tag:=0;
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   If Form2.Tag=1 then Timer1.Enabled:=false;
   If Form2.Tag=2 then Timer2.Enabled:=false;
   Form2.Tag:=0;
end;

procedure TForm2.ShowMyBalloonHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
begin
   If Form2.Tag=2 then exit; //приоритет хинта над балуном
   if (str0='') or (str1='') then Form2.Hide;
   Xg:=X;
   Yg:=Y;
   Form2.Tag:=1;
   Form2.ShowInTaskBar:=stNever;
   Form2.BorderStyle:=bsNone;
   Timer1.Enabled:=true;
   Form2.Font.Size:=AFont;
   Form2.Font.Color:=clBlack;
   Form2.Color:=$0092FFF8;
   Form2.Width:=AFont*32;
   Form2.Height:=AFont*12;
   Panel1.Width:=Form2.Width;
   Panel1.Height:=Form2.Height;
   Label1.BorderSpacing.Around:=5;
   Label2.BorderSpacing.Around:=5;
   if Y-Form2.Height>=0 then Form2.Top:=Y-Form2.Height;
   if Y-Form2.Height<0 then Form2.Top:=Y+22;//22 пикселя - размер иконки в трее
   if X-Form2.Width>=0 then Form2.Left:=X-Form2.Width;
   if X-Form2.Width<0 then Form2.Left:=X+22;
   Label1.Caption:=chr(13)+str0;
   Label2.Caption:=str1;
   Label3.Caption:='';
   Label4.Caption:='';
   Label2.Font.Bold:=true;
   Timer1.Interval:=n;
   Form2.Repaint;
   Form2.Show;
end;

procedure TForm2.ShowMyHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
begin
   if (str0='') or (str1='') then Form2.Hide;
   Xg:=X;
   Yg:=Y;
   Form2.Tag:=2;
   Form2.ShowInTaskBar:=stNever;
   Form2.BorderStyle:=bsNone;
   Timer2.Enabled:=true;
   Form2.Font.Size:=AFont;
   Form2.Font.Color:=clBlack;
   Form2.Color:=$0092FFF8;
   Form2.Width:=AFont*40;
   Form2.Height:=AFont*12;
   Panel1.Width:=Form2.Width;
   Panel1.Height:=Form2.Height;
   Label1.BorderSpacing.Around:=5;
   Label2.BorderSpacing.Around:=5;
   if Y-Form2.Height>=0 then Form2.Top:=Y-Form2.Height;//22 пикселя - размер иконки в трее, 11- это пополам
   if Y-Form2.Height<0 then Form2.Top:=Y+22;
   Form2.Left:=11+X-Form2.Width div 2;
   Label1.Caption:='';
   Label2.Caption:='';
   Label3.Caption:=str0;
   Label4.Caption:=str1;
   Timer2.Interval:=n;
   Form2.Repaint;
   Form2.Show;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
   Form2.Hide;
   Timer1.Enabled:=false;
   Form2.Tag:=0;
end;

procedure TForm2.Timer2Timer(Sender: TObject);
begin
  //If Mouse.CursorPos.X>=Xg then If Mouse.CursorPos.X<=Xg+22 then
  //                          If Mouse.CursorPos.Y>=Yg then If Mouse.CursorPos.Y<=Yg+22 then exit;
   Form2.Hide;
   Timer2.Enabled:=false;
   Form2.Tag:=0;
end;

initialization
  {$I unit2.lrs}

end.

