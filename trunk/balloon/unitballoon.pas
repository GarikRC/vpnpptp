unit unitballoon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,Unix,BaseUnix,Gettext,Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    h:THintWindow;
    Timer1: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShowMyBalloonHint (str0, str1, n, X, Y, AFont,PID_before:string);
    procedure Timer1Timer(Sender: TObject);
    procedure ShowMyHint(var hnt:THintWindow; x0,y0,w0,h0:integer; title: string;font0:integer);
    Procedure HideMyHint(var hnt:THintWindow);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
   Form1: TForm1;
   f0:text;

implementation

{ TForm1 }

procedure TForm1.FormClick(Sender: TObject);
begin
   halt;
end;

procedure TForm1.ShowMyHint(var hnt:THintWindow; x0,y0,w0,h0:integer; title: string;font0:integer);
begin
  if hnt<>nil then hnt.ReleaseHandle;
  hnt:=THintWindow.Create(Form1);
  hnt.Color:=$0092FFF8;
  hnt.Font.Size:=font0;
  hnt.Font.Color:=clBlack;
  hnt.Alignment:=taLeftJustify;
  hnt.OnClick:=Form1.OnClick;
  hnt.ActivateHint(rect(x0,y0,x0+w0,y0+h0),title);
end;

Procedure TForm1.HideMyHint(var hnt:THintWindow);
begin
  if hnt<>nil then hnt.ReleaseHandle;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   Form1.Height:=1;
   Form1.Width:=1;
   Form1.Left:=0;
   Form1.Top:=0;
   Form1.Hide;
   Timer1.Enabled:=false;
   application.ProcessMessages;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   Form1.Hide;
   application.ProcessMessages;
    If ParamCount<7 then
                        begin
                             Application.MessageBox('ParamCount must be 7','Error',0);
                             halt;
                        end;
    ShowMyBalloonHint (ParamStr(1),ParamStr(2),ParamStr(3),ParamStr(4),ParamStr(5),ParamStr(6),ParamStr(7));
end;


procedure TForm1.ShowMyBalloonHint (str0, str1, n, X, Y, AFont,PID_before:string);
{- выводимое сообщение,
- заголовок сообщения,
- время, в течение которого сообщение отображается на экране,
- координата X окна сообщения,
- координата Y окна сообщения,
- размер шрифта сообщения,
- PID предыдущего сообщения или 0 (если 0, то balloon не будет дожидаться окончания вывода предыдущего сообщения, или если 0, то это выводится только первое сообщение).}
var
   str:string;
   pid:Tpid;
   yes_balloon:boolean;
   A,B:integer;
begin
    application.ProcessMessages;
    pid:=FpGetpid;
    If PID_before<>'0' then
    repeat
         yes_balloon:=false;
          popen(f0,'ps -e | grep balloon|awk '+chr(39)+'{print $1$5}'+chr(39),'R');
          while not eof(f0) do
                           begin
                             readln(f0,str);
                             if str<>'' then if str<>IntToStr(pid) then if str=PID_before then yes_balloon:=true;
                           end;
          pclose(f0);
          application.ProcessMessages;
          sleep(50);
          application.ProcessMessages;
   until not yes_balloon;
   Timer1.Interval:=StrToInt(n);
   Timer1.Enabled:=true;
   application.ProcessMessages;
   If StrToInt(Y)>(Screen.Height div 2) then B:=StrToInt(Y)-12*StrToInt(AFont);
   If StrToInt(Y)<=(Screen.Height div 2) then B:=StrToInt(Y)+22;
   If StrToInt(X)>(Screen.Width div 2) then A:=StrToInt(X)-30*StrToInt(AFont);
   If StrToInt(X)<=(Screen.Width div 2) then A:=StrToInt(X)+22;
   ShowMyHint(h,A,B,30*StrToInt(AFont),12*StrToInt(AFont),str1+chr(13)+str0,StrToInt(AFont));
   application.ProcessMessages;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
                         begin
                              HideMyHint(h);
                              application.ProcessMessages;
                              halt;
                         end;
end;


initialization

{$R *.lfm}

end.

