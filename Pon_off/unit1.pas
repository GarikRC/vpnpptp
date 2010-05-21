{ Control pptp vpn connection

  Copyright (C) 2009 Alexander Kazancev kazancas@gmail.com
                     Alex Loginov loginov_alex@inbox.ru, loginov.alex.valer@gmail.com

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
  ExtCtrls, Menus, StdCtrls, Unix, Gettext, Translations;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo_bindutilshost0: TMemo;
    Memo_bindutilshost1: TMemo;
    Memo_gate: TMemo;
    Memo_gatevpn: TMemo;
    tmp_pppd: TMemo;
    Memo_ip_down: TMemo;
    Memo_Config: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    MenuItem4: TMenuItem;
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
    procedure MenuItem4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure tmpnostartChange(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure TrayIcon1MouseMove(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  Lang,FallbackLang:string;
  Translate:boolean; // переведено или еще не переведено
  POFileName : String;
  BindUtils:boolean; //установлен ли пакет bind-utils
  StartMessage:boolean;

const
  Config_n=23;//определяет сколько строк (кол-во) в файле config программы максимально уже существует, считая от 1, а не от 0

resourcestring
  message0='Внимание!';
  message1='Запуск этой программы возможен только под администратором. Нажмите <OK> для отказа от запуска.';
  message2='Другая такая же программа уже работает с VPN PPTP. Нажмите <OK> для отказа от двойного запуска.';
  message3='Сначала сконфигурируйте соединение: Меню, Утилиты, Системные (или Меню, Интернет), Настройка VPN PPTP (Настройка соединения VPN PPTP).';
  message4='No ethernet. Cетевой интерфейс для VPN PPTP недоступен. Если же он доступен, то установите "Не контролировать state сетевого кабеля" в Конфигураторе.';
  message5='No link. Сетевой кабель для VPN PPTP неподключен.';
  message6='Соединение ';
  message7=' установлено';
  message8=' отсутствует';
  message9='No link. Сетевой кабель для VPN PPTP неподключен. А реконнект не включен.';
  message10='Выход без аварии';
  message11='Выход при аварии';
  message12='Устанавливается соединение ';

implementation

{ TForm1 }

Function DeleteSym(d, s: string): string;
//Удаление любого символа из строки s, где d - символ для удаления
Begin
While pos(d, s) <> 0 do
Delete(s, (pos(d, s)), 1); result := s;
End;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
    i,j:integer;
    Code_up_ppp:boolean;
    link:1..4;//1-link ok, 2-no link, 3-none, 4-еще не определено
    pchar_message0,pchar_message1:pchar;
    str:string;
    f,f1:textfile;
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
link:=4;
If Memo_Config.Lines[6]='mii-tool-no' then link:=1; //отказ от контроля link
If Memo_Config.Lines[7]='reconnect-pptp' then link:=1;
If link=4 then
   begin
     Shell('rm -f /tmp/gate1');
     Shell('/sbin/mii-tool '+Memo_Config.Lines[3]+' >> /tmp/gate1');
     Shell('printf "none" >> /tmp/gate1');
     Form1.Memo_gate1.Clear;
     If FileExists('/tmp/gate1') then Memo_gate1.Lines.LoadFromFile('/tmp/gate1');
     If RightStr(Memo_gate1.Lines[0],7)='link ok' then link:=1;
     If RightStr(Memo_gate1.Lines[0],7)='no link' then link:=2;
     If LeftStr(Memo_gate1.Lines[0],4)='none' then link:=3;
   end;
  //определение и сохранение всех актуальных в данный момент ip-адресов vpn-сервера с занесением маршрутов везде
  //BindUtils:=false; //просто для проверки при отладке метода ping
  if BindUtils then Str:='host '+Memo_config.Lines[1]+'|grep address|grep '+Memo_config.Lines[1]+'|awk '+ chr(39)+'{print $4}'+chr(39);
  if not BindUtils then Str:='ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{ print $3 }'+chr(39)+'|grep '+chr(39)+'('+chr(39);
  If not Code_up_ppp then If link=1 then
               If FileExists('/opt/vpnpptp/hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                              begin
                                                  Shell('rm -f /tmp/hosts');
                                                  Shell (Str+' > /tmp/hosts');
                                                  Shell('printf "none\n" >> /tmp/hosts');
                                                  Memo_bindutilshost0.Lines.LoadFromFile('/opt/vpnpptp/hosts');
                                                  Memo_bindutilshost1.Lines.LoadFromFile('/tmp/hosts');
                                                  For i:=0 to Memo_bindutilshost0.Lines.Count-1 do
                                                  For j:=0 to Memo_bindutilshost1.Lines.Count-1 do
                                                  begin
                                                      Memo_bindutilshost1.Lines[j]:=DeleteSym('(',Memo_bindutilshost1.Lines[j]);
                                                      Memo_bindutilshost1.Lines[j]:=DeleteSym(')',Memo_bindutilshost1.Lines[j]);
                                                      If Memo_bindutilshost1.Lines[j] <>'none' then If Memo_bindutilshost1.Lines[j] <>'' then
                                                                                       begin
                                                                                         If Memo_bindutilshost1.Lines[j]=Memo_bindutilshost0.Lines[i] then Memo_bindutilshost1.Lines[j]:= 'none';
                                                                                         Shell('rm -f /opt/vpnpptp/hosts');
                                                                                       end;
                                                  end;
                                                  If not FileExists('/opt/vpnpptp/hosts') then
                                                         begin
                                                            For i:=0 to Memo_bindutilshost0.Lines.Count-1 do
                                                               If Memo_bindutilshost0.Lines[i]<>'none' then Shell('printf "'+Memo_bindutilshost0.Lines[i]+'\n'+'" >> /opt/vpnpptp/hosts');
                                                         end;
                                                  For j:=0 to Memo_bindutilshost1.Lines.Count-1 do
                                                  begin
                                                      If LeftStr(Memo_bindutilshost1.Lines[j],4)<>'none' then
                                                                                                         begin //определился новый, неизвестный ранее ip-адрес vpn-сервера
                                                                                                           Shell('printf "'+Memo_bindutilshost1.Lines[j]+'\n'+'" >> /opt/vpnpptp/hosts');
                                                                                                           begin
                                                                                                              //проверка на наличие добавляемого маршрута в таблице маршрутизации и его добавление если нету
                                                                                                              Shell('/sbin/route -n|grep '+Memo_bindutilshost1.Lines[j]+'|grep '+Memo_config.Lines[2]+'|grep '+Memo_config.Lines[3]+'|awk '+ chr(39)+'{print $0}'+chr(39)+' > /tmp/gatevpn');
                                                                                                              Shell('printf "none" >> /tmp/gatevpn');
                                                                                                              Memo_gatevpn.Clear;
                                                                                                              If FileExists('/tmp/gatevpn') then Memo_gatevpn.Lines.LoadFromFile('/tmp/gatevpn');
                                                                                                              If Memo_gatevpn.Lines[0]='none' then //немедленно добавить маршрут в таблицу маршрутизации
                                                                                                                                              Shell ('/sbin/route add -host ' + Memo_bindutilshost1.Lines[j] + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]);
                                                                                                              Shell('rm -f /tmp/gatevpn');
                                                                                                              //изменение скрипта ip-up
                                                                                                              If FileExists('/etc/ppp/ip-up.d/ip-up') then
                                                                                                                                           Shell ('printf "'+'/sbin/route add -host ' + Memo_bindutilshost1.Lines[j] + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-up.d/ip-up');
                                                                                                              //изменение скрипта ip-down
                                                                                                              If Memo_Config.Lines[7]='reconnect-pptp' then If FileExists('/etc/ppp/ip-down.d/down-up') then
                                                                                                                                        Shell ('printf "'+'/sbin/route del -host ' + Memo_bindutilshost1.Lines[j] + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-down.d/ip-down');
                                                                                                              If Memo_Config.Lines[7]='noreconnect-pptp' then If FileExists('/tmp/ip-down') then
                                                                                                                                        Shell ('printf "'+'/sbin/route del -host ' + Memo_bindutilshost1.Lines[j] + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /tmp/ip-down');
                                                                                                         end;
                                                                                                       end;
                                                  Shell('rm -f /tmp/hosts');
                                              end;
                                            end;
If Code_up_ppp then If link<>1 then //когда связи по факту нет, но в NetApplet и в ifconfig ppp0 числится, а pppd продолжает сидеть в процессах
                               begin
                                 MenuItem2Click(Self);
                                 TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                                 exit;
                               end;

If Code_up_ppp then Timer1.Interval:=StrToInt(Memo_Config.Lines[4]) else Timer1.Interval:=StrToInt(Memo_Config.Lines[5]);
If Code_up_ppp then If Timer1.Interval=0 then Timer1.Interval:=1000;

If not Code_up_ppp then If link=3 then
                                  begin
                                   MenuItem2Click(Self);
                                   TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                pchar_message0:=Pchar(message0);
                                                                pchar_message1:=Pchar(message9);
                                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                MenuItem2Click(Self);
                                                                If Memo_Config.Lines[7]='noreconnect-pptp' then
                                                                   begin
                                                                     Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                                                     Memo_ip_down.Clear;
                                                                     If FileExists('/tmp/ip-down') then
                                                                                                   begin
                                                                                                      Memo_ip_down.Lines.LoadFromFile('/tmp/ip-down');
                                                                                                      Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                                      Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                                      Shell ('rm -f /tmp/ip-down');
                                                                                                    end;
                                                                   end;
                                                                halt;
                                                              end;
                                  end;
If not Code_up_ppp then If link=2 then
                                  begin
                                   MenuItem2Click(Self);
                                   TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                pchar_message0:=Pchar(message0);
                                                                pchar_message1:=Pchar(message9);
                                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                MenuItem2Click(Self);
                                                                If Memo_Config.Lines[7]='noreconnect-pptp' then
                                                                   begin
                                                                     Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                                                     Memo_ip_down.Clear;
                                                                     If FileExists('/tmp/ip-down') then
                                                                                                   begin
                                                                                                       Memo_ip_down.Lines.LoadFromFile('/tmp/ip-down');
                                                                                                       Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                                       Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                                       Shell ('rm -f /tmp/ip-down');
                                                                                                   end;
                                                                   end;
                                                                halt;
                                                              end;
                                  end;

If not Code_up_ppp then If link=1 then
                           begin
                                  Form1.MenuItem2Click(Self);//на всякий случай отключаем вдруг созданное ppp
                                  If Memo_Config.Lines[9]='dhcp-route-yes' then Shell ('dhclient '+Memo_Config.Lines[3]);
                                  TrayIcon1.BalloonTimeout:=5000;
                                  TrayIcon1.BalloonHint:=message12+Memo_Config.Lines[0]+'...';
                                  TrayIcon1.ShowBalloonHint;
                                  Shell('/usr/sbin/pppd call '+Memo_Config.Lines[0]);
                           end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  link:1..3; //1-link ok, 2-no link, 3-none
  pchar_message0,pchar_message1:pchar;
  i:integer;
begin
  If FileExists ('/usr/bin/host') then BindUtils:=true else BindUtils:=false;
  MenuItem3.Caption:=message10;
  MenuItem4.Caption:=message11;
  TrayIcon1.BalloonTitle:=message0;
  TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
  StartMessage:=true;
  Form1.Left:=-1000; //спрятать запущенную форму за пределы экрана
  Memo_Config.Clear;
//проверка ponoff в процессах root, исключение двойного запуска программы, исключение запуска под иными пользователями
   Shell('ps -u root | grep ponoff | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart1');
   Shell('printf "none" >> /tmp/tmpnostart1');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart1') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart1');
   If not (LeftStr(tmpnostart.Lines[0],6)='ponoff') then
                                                        begin
                                                             //запуск не под root
                                                             Timer1.Enabled:=False;
                                                             Timer2.Enabled:=False;
                                                             pchar_message0:=Pchar(message0);
                                                             pchar_message1:=Pchar(message1);
                                                             Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                             Shell('rm -f /tmp/tmpnostart1');
                                                             halt;
                                                         end;
   If LeftStr(tmpnostart.Lines[0],6)='ponoff' then if LeftStr(tmpnostart.Lines[1],6)='ponoff' then
                                                                                                  begin
                                                                                                      //двойной запуск
                                                                                                      Timer1.Enabled:=False;
                                                                                                      Timer2.Enabled:=False;
                                                                                                      pchar_message0:=Pchar(message0);
                                                                                                      pchar_message1:=Pchar(message2);
                                                                                                      Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                                                      Shell('rm -f /tmp/tmpnostart1');
                                                                                                      halt;
                                                                                                  end;
  Shell('rm -f /tmp/tmpnostart1');
//обеспечение совместимости старого config с новым
If FileExists('/opt/vpnpptp/config') then
     begin
        Memo_config.Lines.LoadFromFile('/opt/vpnpptp/config');
        If Memo_config.Lines.Count<Config_n then
                                            begin
                                               for i:=Memo_config.Lines.Count to Config_n do
                                                  Shell('printf "none\n" >> /opt/vpnpptp/config');
                                            end;
     end;
  If FileExists('/opt/vpnpptp/config') then
                                           begin
                                               Memo_Config.Lines.LoadFromFile('/opt/vpnpptp/config');
                                               If Memo_Config.Lines[20]='require-mppe-128-yes' then
                                                                              Shell ('modprobe ppp_mppe');//загрузка модуля ядра для обеспечения шифрования
                                           end
  else
   begin
    Timer1.Enabled:=False;
    pchar_message0:=Pchar(message0);
    pchar_message1:=Pchar(message3);
    Application.MessageBox(pchar_message1,pchar_message0, 0);
    Timer1.Enabled:=False;
    Timer2.Enabled:=False;
    halt;
   end;
                                                If FileExists('/tmp/ip-down') then  //возврат к изначальной настройке скрипта ip-down
                                                                              begin
                                                                                  Memo_ip_down.Clear;
                                                                                  Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                                                                  Memo_ip_down.Lines.LoadFromFile('/tmp/ip-down');
                                                                                  Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                  Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                              end;
        If Memo_Config.Lines[7]='noreconnect-pptp' then
                                             begin
                                                Shell ('rm -f /tmp/ip-down');
                                                Memo_ip_down.Clear;
                                                If FileExists('/etc/ppp/ip-down.d/ip-down') then Memo_ip_down.Lines.LoadFromFile('/etc/ppp/ip-down.d/ip-down');
                                                Memo_ip_down.Lines.SaveToFile('/tmp/ip-down');
                                                Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                                Shell ('printf "#!/bin/sh\n" >> /etc/ppp/ip-down.d/ip-down');
                                                Shell('chmod a+x /tmp/ip-down');
                                                Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                             end;
   //проверка состояния сетевого интерфейса
   Shell('rm -f /tmp/gate2');
   Shell('/sbin/mii-tool '+Memo_Config.Lines[3]+' >> /tmp/gate2');
   Shell('printf "none" >> /tmp/gate2');
   Form1.Memo_gate1.Clear;
   If FileExists('/tmp/gate2') then Memo_gate1.Lines.LoadFromFile('/tmp/gate2');
   If RightStr(Memo_gate1.Lines[0],7)='link ok' then link:=1;
   If RightStr(Memo_gate1.Lines[0],7)='no link' then link:=2;
   If LeftStr(Memo_gate1.Lines[0],4)='none' then link:=3;
   If Memo_Config.Lines[6]='mii-tool-no' then link:=1; //отказ от контроля link
   If Memo_Config.Lines[7]='reconnect-pptp' then link:=1;
   If link=3 then
                begin
                 pchar_message0:=Pchar(message0);
                 pchar_message1:=Pchar(message4);
                 Application.MessageBox(pchar_message1,pchar_message0, 0);
                 Timer1.Enabled:=False;
                 halt;
                end;
   if link=2 then
                begin
                 pchar_message0:=Pchar(message0);
                 pchar_message1:=Pchar(message5);
                 Application.MessageBox(pchar_message1,pchar_message0, 0);
                 Timer1.Enabled:=False;
                 halt;
                end;
  Timer1.Interval:=StrToInt(Memo_Config.Lines[5]);
  MenuItem2Click(Self);//на всякий случай отключаем вдруг созданное ppp
  If Memo_Config.Lines[7]='reconnect-pptp' then
                                             begin
                                             Timer1.Enabled:=False;
                                             MenuItem1Click(Self);
                                             end
                                                else
                                                   Timer1.Interval:=500;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
 //просто убивает pppd и удаляет временные файлы
begin
//проверка наличия в процессах демона pppd
 Shell('ps -u root | grep pppd | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmp_pppd');
 Shell('printf "none" >> /tmp/tmp_pppd');
 Form1.tmp_pppd.Clear;
 If FileExists('/tmp/tmp_pppd') then tmp_pppd.Lines.LoadFromFile('/tmp/tmp_pppd');
 If LeftStr(tmp_pppd.Lines[0],4)='pppd' then
                                        Shell('killall pppd');
 Shell('rm -f /tmp/status.ppp');
 Shell('rm -f /tmp/tmp');
 Shell('rm -f /tmp/gate');
 Shell('rm -f /tmp/gate1');
 Shell('rm -f /tmp/gate2');
 Shell('rm -f /tmp/users');
 Shell('rm -f /tmp/tmpnostart1');
 Shell('rm -f /tmp/status1.ppp');
 Shell('rm -f /tmp/status3.ppp');
 Shell('rm -f /tmp/status.ppp');
 Shell('rm -f /tmp/tmp_pppd');
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
 Timer1.Enabled:=False;
 If Memo_Config.Lines[7]='noreconnect-pptp' then
                                            begin
                                              Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                              Memo_ip_down.Clear;
                                              If FileExists('/tmp/ip-down') then
                                                                            begin
                                                                                 Memo_ip_down.Lines.LoadFromFile('/tmp/ip-down');
                                                                                 Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                 Shell ('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                 Shell ('rm -f /tmp/ip-down');
                                                                            end;
                                            end;
 MenuItem2Click(Self);
 //определяем текущий шлюз, и если он не восстановлен скриптом ip-down, то восстанавливаем его сами
  Shell ('rm -f /tmp/gate');
  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('printf "none" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  If Memo_gate.Lines[0]='none' then Shell ('/etc/ppp/ip-down.d/ip-down');
  Shell ('rm -f /tmp/gate');
  halt;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
 MenuItem2Click(Self);
 Timer1.Enabled:=False;
 If Memo_Config.Lines[7]='noreconnect-pptp' then
                                            begin
                                              Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                              Memo_ip_down.Clear;
                                              If FileExists('/tmp/ip-down') then
                                                                            begin
                                                                                 Memo_ip_down.Lines.LoadFromFile('/tmp/ip-down');
                                                                                 Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                 Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                 Shell ('rm -f /tmp/ip-down');
                                                                             end;
                                              Shell ('/etc/init.d/network restart'); // организация конкурса интерфейсов
                                            end;
 halt;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  MenuItem1Click(Self);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
//индикация иконки в трее и балуны
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
  If Code_up_ppp_timer then
                           begin
                             TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/on.ico');
                             If StartMessage then TrayIcon1.BalloonTimeout:=8000;
                             If StartMessage then TrayIcon1.BalloonHint:=message6+Memo_Config.Lines[0]+message7+'...';
                             If StartMessage then TrayIcon1.ShowBalloonHint;
                             StartMessage:=false;
                           end;
  If not Code_up_ppp_timer then
                           begin
                             If not StartMessage then TrayIcon1.BalloonTimeout:=8000;
                             If not StartMessage then TrayIcon1.BalloonHint:=message6+Memo_Config.Lines[0]+message8+'...';
                             If not StartMessage then TrayIcon1.ShowBalloonHint;
                             TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                             StartMessage:=true;
                           end;
end;

procedure TForm1.tmpnostartChange(Sender: TObject);
begin

end;

procedure TForm1.TrayIcon1Click(Sender: TObject);
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
  If Code_up_ppp then TrayIcon1.Hint:=message6+Memo_Config.Lines[0]+message7
                    else TrayIcon1.Hint:=message6+Memo_Config.Lines[0]+message8;
end;


initialization
  {$I unit1.lrs}
  Gettext.GetLanguageIDs(Lang,FallbackLang);
  Translate:=false;
//FallbackLang:='uk'; //просто для проверки при отладке
  If FallbackLang='ru' then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/ponoff.ru.po';
                               Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                               Translate:=true;
                            end;
  If FallbackLang='uk' then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/ponoff.uk.po';
                               Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                               Translate:=true;
                            end;
  If not Translate then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/ponoff.en.po';
                               Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                            end;
end.
