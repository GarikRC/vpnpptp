{ Control pptp vpn connection

  Copyright (C) 2009 Edumandriva Alexander Kazancev kazancas@gmail.com

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}


unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Menus, StdCtrls, Unix;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Timer2: TTimer;
    tmpnostart: TMemo;
    Memo_gate1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure tmpnostartChange(Sender: TObject);
    procedure TrayIcon1MouseMove(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{ TForm1 }

procedure TForm1.MenuItem1Click(Sender: TObject);
var
    j:integer;
    Code_up_ppp:boolean;
    link:1..3;//1-link ok, 2-no link, 3-none
begin
  //Проверяем поднялось ли соединение
  Shell('rm -f /tmp/status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > /tmp/status.ppp');
  Code_up_ppp:=False;
  If FileExists('/tmp/status.ppp') then Memo2.Lines.LoadFromFile('/tmp/status.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       Code_up_ppp:=True;
      end;
   end;
  //проверка состояния сетевого интерфейса
   Shell('rm -f /tmp/gate1');
   Shell('/sbin/mii-tool '+Memo1.Lines[3]+' >> /tmp/gate1');
   Shell('printf "none" >> /tmp/gate1');
   Form1.Memo_gate1.Clear;
   If FileExists('/tmp/gate1') then Memo_gate1.Lines.LoadFromFile('/tmp/gate1');
   If RightStr(Memo_gate1.Lines[0],7)='link ok' then link:=1;
   If RightStr(Memo_gate1.Lines[0],7)='no link' then link:=2;
   If LeftStr(Memo_gate1.Lines[0],4)='none' then link:=3;
   //If link=1 then
   //              begin
   //               Application.MessageBox('Link ok. Cетевой интерфейс для VPN PPTP доступен.','Внимание!', 0);
   //               Timer1.Enabled:=False;
   //              end;
   If not Code_up_ppp then If link=1 then
                           begin
                              Form1.MenuItem2Click(Self);//эмулируем на всякий случай отключение вдруг созданного ppp
                              //Form1.TrayIcon1.BalloonHint:='Попытка соединиться...';
                              //Form1.TrayIcon1.ShowBalloonHint;
                              //Application.MessageBox('Попытка соединиться...','Внимание!', 0);
                              Shell('/usr/sbin/pppd call '+Memo1.Lines[0]);
                           end;
 //If link=1 then Timer1.Interval:=5000 else Timer1.Interval:=1000;
 If Code_up_ppp then Timer1.Interval:=1000 else Timer1.Interval:=20000;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  link:1..3;//1-link ok, 2-no link, 3-none
  k:boolean; //запуск под root, под live
  m:boolean; //двойной запуск,
begin
  TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
  Form1.Left:=-1000; //спрятать запущенную форму за пределы экрана
  Memo1.Clear;
   k:=false;
   m:=false;
//проверка ponoff процессах root, live, исключение двойного запуска программы, исключение запуска под иными пользователями
   Shell('ps -u root | grep ponoff | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart1');
   Shell('printf "none" >> /tmp/tmpnostart1');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart1') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart1');
   If LeftStr(tmpnostart.Lines[0],6)='ponoff' then k:=true;
   If LeftStr(tmpnostart.Lines[0],6)='ponoff' then if LeftStr(tmpnostart.Lines[1],6)='ponoff' then m:=true;
   Shell('ps -u live | grep vpnpptp | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart1');
   Shell('printf "none" >> /tmp/tmpnostart1');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart1') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart1');
   If LeftStr(tmpnostart.Lines[0],6)='ponoff' then k:=true;
   If LeftStr(tmpnostart.Lines[0],6)='ponoff' then if LeftStr(tmpnostart.Lines[1],6)='ponoff' then m:=true;
   If not k then
             begin
               Timer1.Enabled:=False;
               Timer2.Enabled:=False;
               Application.MessageBox('Запуск этой программы возможен только под администратором и live-пользователем. Нажмите <OK> для отказа от запуска.','Внимание!', 0);
               Shell('rm -f /tmp/tmpnostart1');
               halt;
              end;
   If m then
             begin
               Timer1.Enabled:=False;
               Timer2.Enabled:=False;
               Application.MessageBox('Другая такая же программа уже работает с VPN PPTP. Нажмите <OK> для отказа от двойного запуска.','Внимание!', 0);
               Shell('rm -f /tmp/tmpnostart1');
               halt;
             end;
  Shell('rm -f /tmp/tmpnostart1');
  If FileExists('/opt/vpnpptp/config') then Memo1.Lines.LoadFromFile('/opt/vpnpptp/config')
  else
   begin
    Timer1.Enabled:=False;
    Application.MessageBox('Соединение не сконфигурировано. Сначала сконфигурируйте соединение через Меню, Утилиты, Системные, vpnpptp (Настройка соединения VPN PPTP).',
    'Внимание!',0);
    //MenuItem2Click(Self);//эмулируем на всякий случай отключение вдруг созданного ppp
    Timer1.Enabled:=False;
    Timer2.Enabled:=False;
    halt;
   end;
   //проверка состояния сетевого интерфейса
   Shell('rm -f /tmp/gate2');
   Shell('/sbin/mii-tool '+Memo1.Lines[3]+' >> /tmp/gate2');
   Shell('printf "none" >> /tmp/gate2');
   Form1.Memo_gate1.Clear;
   If FileExists('/tmp/gate2') then Memo_gate1.Lines.LoadFromFile('/tmp/gate2');
   If RightStr(Memo_gate1.Lines[0],7)='link ok' then link:=1;
   If RightStr(Memo_gate1.Lines[0],7)='no link' then link:=2;
   If LeftStr(Memo_gate1.Lines[0],4)='none' then link:=3;
   If link=3 then
                begin
                 Application.MessageBox('No ethernet. Cетевой интерфейс для VPN PPTP недоступен.','Внимание!', 0);
                 Timer1.Enabled:=False;
                 halt;
                end;
   if link=2 then
                begin
                 Application.MessageBox('No link. Сетевой кабель для VPN PPTP не подключен.','Внимание!', 0);
                 Timer1.Enabled:=False;
                 halt;
                end;
  //Timer1.Interval:=5000;
  MenuItem2Click(Self);//эмулируем на всякий случай отключение вдруг созданного ppp
  MenuItem1Click(Self); //автозапуск vpn + еще немного погодя оно запустится по таймеру если что само
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
 Shell('/etc/ppp/ip-down.d/ip-down');
 Shell('killall pppd');
 Shell('rm -f /tmp/status.ppp');
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
 MenuItem2Click(Self);
 Timer1.Enabled:=False;
 Shell('rm -f /tmp/tmp');
 Shell('rm -f /tmp/gate');
 Shell('rm -f /tmp/gate1');
 Shell('rm -f /tmp/gate2');
 Shell('rm -f /tmp/users');
 //Shell('/etc/ppp/ip-down.d/ip-down');
 halt;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  MenuItem1Click(Self);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
//индикация иконки в трее
var
  j:integer;
  Code_up_ppp_timer:boolean;
begin
  Shell('rm -f /tmp/status1.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > /tmp/status1.ppp');
  Application.ProcessMessages;
  Code_up_ppp_timer:=False;
  If FileExists('/tmp/status1.ppp') then Memo2.Lines.LoadFromFile('/tmp/status1.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       Code_up_ppp_timer:=True;
      end;
   end;
  If Code_up_ppp_timer then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/on.ico')
                    else TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
end;

procedure TForm1.tmpnostartChange(Sender: TObject);
begin

end;

procedure TForm1.TrayIcon1MouseMove(Sender: TObject);
// Вывод информации о соединении
var
  j:integer;
  Code_up_ppp:boolean;
begin
  Shell('rm -f /tmp/status3.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > /tmp/status3.ppp');
  Application.ProcessMessages;
  Code_up_ppp:=False;
  If FileExists('/tmp/status3.ppp') then Memo2.Lines.LoadFromFile('/tmp/status3.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       Code_up_ppp:=True;
      end;
   end;
  If Code_up_ppp then TrayIcon1.Hint:='Соединение '+Memo1.Lines[0]+'установлено'
                    else TrayIcon1.Hint:='Соединение '+Memo1.Lines[0]+'отсутствует';
end;


initialization
  {$I unit1.lrs}

end.

