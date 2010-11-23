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
    Timer1: TTimer; //таймер для балуна
    Timer2: TTimer; //таймер для хинта
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure ShowMyBalloonHint (str0, str1:string; n:integer; X, Y:Longint; AFont:integer);
    procedure ShowMyHint (str0:string; n:integer; X, Y:Longint; AFont:integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
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
   Form2.Tag:=1;
   Form2.ShowInTaskBar:=stNever;
   If Form2.Tag=2 then Form2.Hide;//приоритет балуна над хинтом
   Form2.BorderStyle:=bsNone;
   Timer1.Enabled:=true;
   Form2.Font.Size:=AFont;
   Form2.Font.Color:=clBlack;
   Form2.Color:=$0092FFF8;
   Form2.Width:=AFont*32;
   Form2.Height:=AFont*12;
   Panel1.Width:=Form2.Width;
   Panel1.Height:=Form2.Height;
   Form2.Constraints.MaxHeight:=Form2.Height;
   Form2.Constraints.MinHeight:=Form2.Height;
   Form2.Constraints.MaxWidth:=Form2.Width;
   Form2.Constraints.MinWidth:=Form2.Width;
   Label1.BorderSpacing.Around:=5;
   Label2.BorderSpacing.Around:=5;
   if Y-Form2.Height>=0 then Form2.Top:=Y-Form2.Height;
   if Y-Form2.Height<0 then Form2.Top:=Y+22;//22 пикселя - размер иконки в трее
   if X-Form2.Width>=0 then Form2.Left:=X-Form2.Width;
   if X-Form2.Width<0 then Form2.Left:=X+22;
   Label1.Caption:=chr(13)+str0;
   Label2.Caption:=str1;
   Label2.Font.Bold:=true;
   Timer1.Interval:=n;
   Form2.Repaint;
   Form2.Show;
end;

procedure TForm2.ShowMyHint (str0:string; n:integer; X, Y:Longint; AFont:integer);
begin
   If Form2.Tag=1 then exit;//запрет на показ хинта если показывается балун
   Form2.Tag:=2;
   Form2.ShowInTaskBar:=stNever;
   Form2.BorderStyle:=bsNone;
   Form2.Constraints.MaxHeight:=0;
   Form2.Constraints.MinHeight:=0;
   Form2.Constraints.MaxWidth:=0;
   Form2.Constraints.MinWidth:=0;
   Timer2.Enabled:=true;
   Form2.Font.Size:=AFont;
   Form2.Font.Color:=clBlack;
   Form2.Color:=$0092FFF8;
   Form2.Width:=AFont*24;
   Form2.Height:=AFont*12;
   Panel1.Width:=Form2.Width;
   Panel1.Height:=Form2.Height;
   Label1.BorderSpacing.Around:=3;
   Label2.BorderSpacing.Around:=3;
   if Y-Form2.Height>=0 then Form2.Top:=Y-Form2.Height;//22 пикселя - размер иконки в трее, 11- это пополам
   if Y-Form2.Height<0 then Form2.Top:=Y+22;
   Form2.Left:=11+X-Form2.Width div 2;
   Label1.Caption:=str0;
   Label2.Caption:='';
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
   Form2.Hide;
   Timer2.Enabled:=false;
   Form2.Tag:=0;
end;

procedure TForm2.Label1Click(Sender: TObject);
begin
   Form2.Hide;
   If Form2.Tag=1 then Timer1.Enabled:=false;
   If Form2.Tag=2 then Timer2.Enabled:=false;
   Form2.Tag:=0;
end;

procedure TForm2.Label2Click(Sender: TObject);
begin
   Form2.Hide;
   If Form2.Tag=1 then Timer1.Enabled:=false;
   If Form2.Tag=2 then Timer2.Enabled:=false;
   Form2.Tag:=0;
end;

procedure TForm2.Panel1Click(Sender: TObject);
begin
   Form2.Hide;
   If Form2.Tag=1 then Timer1.Enabled:=false;
   If Form2.Tag=2 then Timer2.Enabled:=false;
   Form2.Tag:=0;
end;


initialization
  {$I unit2.lrs}

end.

