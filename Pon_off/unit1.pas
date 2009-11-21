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
  ExtCtrls, Menus, StdCtrls, users, BaseUnix, Unix;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
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
    Data: TPasswordRecord;
    Code_up_ppp:boolean;
begin
  //Проверяем поднялось ли соединение
  GetUserData(FpGetuid, Data);
  Shell('rm -f '+Data.pw_dir+'/.status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+Data.pw_dir+'/.status.ppp');
  Code_up_ppp:=False;
  If FileExists(Data.pw_dir+'/.status.ppp') then Memo2.Lines.LoadFromFile(Data.pw_dir+'/.status.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       Code_up_ppp:=True;
      end;
   end;
  If not Code_up_ppp then
                           begin
                              Form1.MenuItem2Click(Self);//эмулируем на всякий случай отключение вдруг созданного ppp
                              Shell('/usr/sbin/pppd call '+Memo1.Lines[0]);
                              Sleep(5000);
                           end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Left:=-1000; // спрятать запущенную форму за пределы экрана
  Memo1.Clear;
  If FileExists('/opt/vpnpptp/config') then Memo1.Lines.LoadFromFile('/opt/vpnpptp/config')
  else
   begin
    Application.MessageBox('Сперва сконфигурируйте соединение через Меню, Утилиты, Системные, vpnpptp (Настройка соединения VPN PPTP)',
    'Соединение не сконфигурировано',0);
    MenuItem2Click(Self);//эмулируем на всякий случай отключение вдруг созданного ppp
    halt;
   end;
  MenuItem2Click(Self);//эмулируем на всякий случай отключение вдруг созданного ppp
  MenuItem1Click(Self); //автозапуск vpn + еще немного погодя оно запустится по таймеру если что само
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var
  Data: TPasswordRecord;
begin
 GetUserData(FpGetuid, Data);
 Shell('/etc/ppp/ip-down.d/ip-down');
 Shell('killall pppd');
 Shell('rm -f '+Data.pw_dir+'/.status.ppp');
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
var
  Data: TPasswordRecord;
begin
 MenuItem2Click(Self);
 halt;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  MenuItem1Click(Self);
end;

procedure TForm1.TrayIcon1MouseMove(Sender: TObject);
// Вывод информации о соединении
var
  Data: TPasswordRecord;
  j:integer;
  Code_up_ppp:boolean;
begin
  GetUserData(FpGetuid, Data);
  Shell('rm -f '+Data.pw_dir+'/.status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+Data.pw_dir+'/.status.ppp');
  Application.ProcessMessages;
  Code_up_ppp:=False;
  If FileExists(Data.pw_dir+'/.status.ppp') then Memo2.Lines.LoadFromFile(Data.pw_dir+'/.status.ppp');
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

