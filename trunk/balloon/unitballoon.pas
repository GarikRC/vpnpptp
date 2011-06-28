unit unitballoon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Unix, BaseUnix, Gettext, Menus, StdCtrls, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Label0: TLabel;
    Label_text: TLabel;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShowMyBalloonHint(str0, str1, n, X, Y, AFont,PID_before,picture:string);
    procedure ShowMyHint(var hnt:THintWindow; x0,y0,w0,h0:integer; title: string;font0:integer;str,picture:string);
    Procedure HideMyHint(var hnt:THintWindow);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
   Form1:TForm1;
   f0:text;
   h:THintWindow;
   k0,k1:integer; //коэффициенты
   k3:integer; //размер иконки в трее

implementation
{ TForm1 }

procedure TForm1.FormClick(Sender: TObject);
begin
   HideMyHint(h);
   halt;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
     x,code,i:integer;
     s:string;
begin
     //проверка корректности переданных параметров
     If ParamCount<>8 then
             begin
                Application.MessageBox('ParamCount must be 8.','Error!',0);
               halt;
             end;
     for i:=3 to 7 do
               begin
                 Val(ParamStr(i),x,code);
                 if code<>0 then
                              begin
                                 s:='ParamStr('+IntToStr(i)+') must be value.';
                                 Application.MessageBox(PChar(s),'Error!',0);
                                 halt;
                              end;
               end;
end;

procedure TForm1.ShowMyHint(var hnt:THintWindow; x0,y0,w0,h0:integer; title: string;font0:integer;str,picture:string);
var
  i:integer;
begin
     Form1.Font.Size:=font0;
     Form1.Font.Color:=clBlack;
     label0.Caption:=str;
     Label_text.Caption:=title;
     label0.Font.Style:=[fsBold];
     Panel1.BorderSpacing.Around:=1;
     Image1.Height:=font0*5;
     Image1.Width:=font0*5;
     Form1.Align:=alClient;
     hnt.ActivateHint(rect(x0,y0,x0+w0,y0+h0),'');
     for i:=0 to Form1.ComponentCount-2 do
     begin
     if pos(Form1.Components[i].Name,'Timer')<>0 then continue;
     (Form1.Components[i] as TControl).OnClick:=Form1.OnClick;
     end;
   end;

   Procedure TForm1.HideMyHint(var hnt:THintWindow);
   begin
     if hnt<>nil then hnt.ReleaseHandle;
   end;

   procedure TForm1.Timer1Timer(Sender: TObject);
   begin
     HideMyHint(h);
     halt;
   end;

   procedure TForm1.ShowMyBalloonHint (str0, str1, n, X, Y, AFont,PID_before,picture:string);
   {- выводимое сообщение,
   - заголовок сообщения,
   - время, в течение которого сообщение отображается на экране (миллисекунды),
   - координата X окна сообщения,
   - координата Y окна сообщения,
   - размер шрифта сообщения,
   - PID предыдущего сообщения или 0 (если 0, то balloon не будет дожидаться окончания вывода предыдущего сообщения, или если 0, то это выводится только первое сообщение),
   - рисунок с путем к нему.}
   var
      str:string;
      pid:Tpid;
      yes_balloon:boolean;
      A,B:integer;
   begin
       pid:=FpGetpid;
       If PID_before<>'0' then
       repeat
            yes_balloon:=false;
             popen(f0,'ps -p '+PID_before+'|awk '+chr(39)+'{print $1$5}'+chr(39),'R');
             while not eof(f0) do
                              begin
                                readln(f0,str);
                                if str='PID' then continue;
                                if str<>'' then if str<>IntToStr(pid) then if str=PID_before then yes_balloon:=true;
                              end;
             pclose(f0);
             sleep(200);
      until not yes_balloon;
      k0:=35;
      k1:=12;
      k3:=22;
      If picture='' then
                         begin
                              Image1.Visible:=false;
                              k0:=30;
                         end;
      If picture<>'' then If FileExists(picture) then Image1.Picture.LoadFromFile(picture)
                                                                                           else
                                                                                               begin
                                                                                                    Image1.Visible:=false;
                                                                                                    k0:=30;
                                                                                               end;
      If StrToInt(Y)>(Screen.Height div 2) then B:=StrToInt(Y)-k1*StrToInt(AFont);
      If StrToInt(Y)<=(Screen.Height div 2) then B:=StrToInt(Y)+k3;
      If StrToInt(X)>(Screen.Width div 2) then A:=StrToInt(X)-k0*StrToInt(AFont);
      If StrToInt(X)<=(Screen.Width div 2) then A:=StrToInt(X)+k3;
      ShowMyHint(h,A,B,k0*StrToInt(AFont),k1*StrToInt(AFont),str0,StrToInt(AFont),str1,picture);
      Timer1.Interval:=StrToInt(n);
      Timer1.Enabled:=true;
   end;

   initialization

   {$R *.lfm}

   end.
