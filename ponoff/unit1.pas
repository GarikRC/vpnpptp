{ Control pptp/l2tp vpn connection

  Copyright (C) 2009 Alex Loginov (loginov_alex@inbox.ru, loginov.alex.valer@gmail.com)

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
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs, Process,
  ExtCtrls, Menus, StdCtrls, Unix, Gettext, Translations,UnitMyMessageBox, BaseUnix;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Memo_etc_ppp_ip_up: TMemo;
    Memo_networktest: TMemo;
    Memo_bindutilshost0: TMemo;
    Memo_gate: TMemo;
    Memo_gatevpn: TMemo;
    Memo_testonstart: TMemo;
    MenuItem5: TMenuItem;
    Panel1: TPanel;
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
    procedure MenuItem5Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrayIcon1MouseMove(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  Lang,FallbackLang:string; // язык системы
  Translate:boolean; // переведено или еще не переведено
  POFileName : String; //файл перевода
  BindUtils:boolean; //установлен ли пакет bind-utils
  StartMessage:boolean; //запускать ли сообщения
  NewIPS:boolean; //найден новый, неизвестный ранее ip-адрес vpn-сервера
  NoPingIPS, NoDNS, NoPingGW, NoPingDNS1, NoPingDNS2, NoPingDNS3, NoPingDNS4:boolean;//события
  NoInternet:boolean;//есть ли интернет
  Filenetworktest, FileRemoteIPaddress, FileEtc_hosts, FileDoubleRun, FileDateStart, FileResolv_conf:textfile;//текстовые файлы
  DhclientStart:boolean; //стартанул ли dhclient
  RemoteIPaddress:string;
  Scripts:boolean;//отслеживает невыполнение скриптов поднятия и опускания
  Welcome:boolean;//необходимость в параметре welcome для pppd
  f: text;//текстовый поток
  RX,TX:string;//объем загруженного/отданного
  RXbyte,TXbyte:string;//объем загруженного/отданного в байтах
  DateStart,DateStop:int64;//время запуска/время текущее
  RXSpeed,TXSpeed:string;//скорсть загрузки/отдачи
  Count:byte;//счетчик времени
  ObnullRX,ObnullTX:boolean; //отслеживает обнуление счетчика RX/TX
  AFont:integer; //шрифт приложения
  AProcess: TProcess; //для запуска внешних приложений
  ubuntu:boolean; // используется ли дистрибутив ubuntu
  debian:boolean; // используется ли дистрибутив debian
  fedora:boolean; // используется ли дистрибутив fedora
  suse:boolean; // используется ли дистрибутив suse
  mandriva:boolean; // используется ли дистрибутив mandriva
  CountInterface:integer; //считает сколько в системе поддерживаемых программой интерфейсов
  CountKillallpppd:integer; //счетчик сколько раз убивался pppd
  DoubleRunPonoff:boolean; //многократный запуск ponoff

const
  Config_n=46;//определяет сколько строк (кол-во) в файле config программы максимально уже существует, считая от 1, а не от 0

resourcestring
  message0='Внимание!';
  message1='Запуск этой программы возможен только под администратором или с разрешения администратора. Нажмите <ОК> для отказа от запуска.';
  //message2='Другая такая же программа уже работает с VPN PPTP/L2TP. Нажмите <ОК> для отказа от двойного запуска.';
  message3='Сначала сконфигурируйте соединение: Меню->Утилиты->Системные(или Меню->Интернет)->vpnpptp(Настройка соединения VPN PPTP/L2TP).';
  message4='No ethernet. Cетевой интерфейс для VPN PPTP/L2TP недоступен. Если же он доступен, то установите "Не контролировать state сетевого кабеля" в Конфигураторе.';
  message5='No link. Сетевой кабель для VPN PPTP/L2TP неподключен.';
  message6='Соединение';
  message7='установлено';
  message8='отсутствует';
  message9='No link. Сетевой кабель для VPN PPTP/L2TP неподключен. А реконнект не включен.';
  message10='Выход без аварии';
  message11='Выход при аварии';
  message12='Устанавливается соединение ';
  message13='Получены маршруты через DHCP. ';
  message14='Обнаружен новый IP-адрес VPN-сервера. Соединение перенастраивается... ';
  message15='VPN-сервер не пингуется. ';
  message16='Доступ в интернет отсутствует...';
  message17='DNS-сервер до поднятия VPN не отвечает или некорректный адрес VPN-сервера. ';
  message18='Шлюз локальной сети не пингуется. ';
  message19='Проверено! Интернет работает!';
  message20='Обнаружено совпадение remote ip address с IP-адресом самого VPN-сервера. Соединение было перенастроено.';
  message21='Ошибка получения маршрутов через DHCP. ';
  message22='Статус:';
  message23='DNS1-сервер до поднятия VPN не пингуется. ';
  message24='DNS2-сервер до поднятия VPN не пингуется. ';
  message25='Вы можете в конфигураторе VPN PPTP/L2TP выбрать опцию разрешения пользователям управлять подключением.';
  message26='Вы также можете сконфигурировать соединение из Центра Управления->Сеть и интернет->Настройка VPN-соединений->VPN PPTP/L2TP.';
  message27='Загружено:';
  message28='Отдано:';
  message29='Время в сети:';
  message30='ч.';
  message31='м.';
  message32='с.';
  message33='ОК';
  message34='Да';
  message35='Нет';
  message36='Отмена';
  message37='Минуточку...';
  message38='Запускается приложение ponoff...';
  message39='Наблюдать';
  message40='DNS2-сервер при поднятом VPN не пингуется. ';
  message41='Обнаружено активное соединение dsl. Отключите его командой ifdown dsl0. Нажмите <ОК> для отказа от запуска.';
  message42='DNS1-сервер при поднятом VPN не пингуется. ';

implementation

{ TForm1 }

Function DeleteSym(d, s: string): string;
//Удаление любого символа из строки s, где d - символ для удаления
Begin
While pos(d, s) <> 0 do
Delete(s, (pos(d, s)), 1); result := s;
End;

function CompareFiles(const FirstFile, SecondFile: string): Boolean;
//сравнение файлов
var
  f1, f2: TMemoryStream;
begin
  Result := false;
  f1 := TMemoryStream.Create;
  f2 := TMemoryStream.Create;
  try
    f1.LoadFromFile(FirstFile);
    f2.LoadFromFile(SecondFile);
    if f1.Size = f2.Size then
           Result := CompareMem(f1.Memory, f2.memory, f1.Size);
  finally
    f2.Free;
    f1.Free;
  end
end;
procedure ClearEtc_hosts;
//очистка /etc/hosts от старых мешающих записей
var
   Str_Etc_hosts:string;
begin
If FileExists ('/etc/hosts') then
    begin
        If not FileExists ('/etc/hosts.old') then Shell ('cp -f /etc/hosts /etc/hosts.old');
        AssignFile (FileEtc_hosts,'/etc/hosts');
        reset (FileEtc_hosts);
        While not eof(FileEtc_hosts) do
               begin
                   readln(FileEtc_hosts, Str_Etc_hosts);
                   If not (RightStr(Str_Etc_hosts,Length(Form1.Memo_Config.Lines[1]))=Form1.Memo_Config.Lines[1]) then
                                  Shell('printf "'+Str_Etc_hosts+'\n" >> /tmp/hosts.tmp');
               end;
        closefile (FileEtc_hosts);
        Shell('cp -f /tmp/hosts.tmp /etc/hosts');
        Shell('rm -f /tmp/hosts.tmp');
        Shell('chmod 0644 /etc/hosts');
    end;
end;

Procedure DoCountInterface;
//считает максимальное кол-во default
var
   str:string;
   i:integer;
   FileInterface:textfile;
begin
   i:=0;
   Shell ('rm -f /tmp/CountInterface');
   Shell ('ifconfig |grep eth >>/tmp/CountInterface & ifconfig |grep wlan >>/tmp/CountInterface');
   AssignFile (FileInterface,'/tmp/CountInterface');
   reset (FileInterface);
   While not eof (FileInterface) do
   begin
        readln(FileInterface, str);
        i:=i+1;
   end;
   closefile(FileInterface);
   Shell ('rm -f /tmp/CountInterface');
   if i=0 then i:=1;
   CountInterface:=i;
end;

procedure BalloonMessage (i:integer;str1:string);
begin
Form1.TrayIcon1.BalloonHint:='';
Form1.TrayIcon1.BalloonTimeout:=i;
Form1.TrayIcon1.BalloonHint:=str1;
Application.ProcessMessages;
If Form1.Memo_Config.Lines[23]<>'networktest-yes' then Sleep(1000);
If Form1.Memo_Config.Lines[24]='balloon-no' then If str1<>'' then Form1.TrayIcon1.ShowBalloonHint;
Application.ProcessMessages;
end;

procedure MakeDefaultGW;
//определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сетевой интерфейс, на котором настроено VPN PPTP
begin
       Shell ('rm -f /tmp/gate');
       Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
       Shell('printf "none" >> /tmp/gate');
       Form1.Memo_gate.Clear;
       If FileExists('/tmp/gate') then Form1.Memo_gate.Lines.LoadFromFile('/tmp/gate');
       If Form1.Memo_gate.Lines[0]='none' then
                                          begin
       //исправление default и повторная проверка
                                               Shell ('route add default gw '+Form1.Memo_Config.Lines[2]+' dev '+Form1.Memo_Config.Lines[3]);
                                               Shell ('rm -f /tmp/gate');
                                               Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
                                               Shell('printf "none" >> /tmp/gate');
                                               Form1.Memo_gate.Clear;
                                               If FileExists('/tmp/gate') then Form1.Memo_gate.Lines.LoadFromFile('/tmp/gate');
                                          end;
       If Form1.Memo_gate.Lines[0]='none' then if not FileExists ('/etc/init.d/network-manager') then if not FileExists ('/etc/init.d/NetworkManager') then
                               begin
                                 If FileExists ('/sbin/ifdown') then Shell ('ifdown '+Form1.Memo_Config.Lines[3]);
                                 If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig '+Form1.Memo_Config.Lines[3]+' down');
                                 If FileExists ('/sbin/ifup') then Shell ('ifup '+Form1.Memo_Config.Lines[3]);
                                 If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig '+Form1.Memo_Config.Lines[3]+' up');
                                 If FileExists ('/sbin/ifup') then Shell ('ifup lo');
                                 If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig lo up');
                               end;
       If Form1.Memo_gate.Lines[0]='none' then if FileExists ('/etc/init.d/network-manager') or FileExists ('/etc/init.d/NetworkManager') then
                               begin
                                 If not FileExists ('/etc/init.d/network') or fedora then
                                                                           begin
                                                                                Shell ('service network-manager restart');
                                                                                Shell ('service NetworkManager restart');
                                                                           end;
                                 If debian then if FileExists ('/etc/init.d/networking') then Shell ('/etc/init.d/networking restart');
                                 If FileExists ('/sbin/ifdown') then Shell ('ifdown '+Form1.Memo_Config.Lines[3]);
                                 If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig '+Form1.Memo_Config.Lines[3]+' down');
                                 sleep (3000);
                                 If FileExists ('/sbin/ifup') then Shell ('ifup '+Form1.Memo_Config.Lines[3]);
                                 If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig '+Form1.Memo_Config.Lines[3]+' up');
                                 If FileExists ('/sbin/ifup') then Shell ('ifup lo');
                                 If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig lo up');
                                 sleep (3000);
                               end;
       Shell ('rm -f /tmp/gate');
       Form1.Memo_gate.Lines.Clear;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
    i,j,h:integer;
    Code_up_ppp:boolean;
    link:byte;//1-link ok, 2-no link, 3-none, 4-еще не определено
    str:string;
    Str_networktest, Str_RemoteIPaddress:string;
    FindRemoteIPaddress:boolean;
begin
  NewIPS:=true;
  NoPingIPS:=false;
  NoDNS:=false;
  NoPingGW:=false;
  NoPingDNS1:=false;
  NoPingDNS2:=false;
  NoPingDNS3:=false;
  NoPingDNS4:=false;
  DoCountInterface;
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
//проверяем поднялось ли соединение на pppN и если нет, то поднимаем на pppN; переводим pppN в фон
If Memo_Config.Lines[29]='pppnotdefault-yes' then NoInternet:=true;
If Code_up_ppp then
 begin
  Shell ('rm -f /tmp/gate');
  Shell('/sbin/ip r|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('/sbin/ip r|grep default|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39)+' >> /tmp/gate');
  Shell('printf "none\n" >> /tmp/gate');
  Shell('printf "none\n" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then If Memo_gate.Lines[0]<>Memo_gate.Lines[1] then
                               begin
                                  If Memo_Config.Lines[29]<>'pppnotdefault-yes' then
                                       begin
                                            For h:=1 to CountInterface do
                                                Shell ('/sbin/route del default');
                                            Shell ('/sbin/route add default dev '+Memo_gate.Lines[0]);
                                       end;
                               end;
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then If Memo_gate.Lines[0]<>'none' then
                               begin
                                  If Memo_Config.Lines[29]='pppnotdefault-yes' then
                                           begin
                                             For h:=1 to CountInterface do
                                                 Shell ('/sbin/route del default dev '+Memo_gate.Lines[0]);
                                             Shell ('/sbin/route add default gw '+Memo_config.Lines[2]+' dev '+Memo_config.Lines[3]);
                                             NoInternet:=false;//считаем, что типа при этом есть интернет
                                             //Shell ('/etc/ppp/ip-up.d/ip.up'); //повторно указываем где искать vpn-сервер
                                           end;
                               end;
  Shell ('rm -f /tmp/gate');
  Memo_gate.Lines.Clear;
 end;
If Code_up_ppp then If not FileExists ('/etc/resolv.conf.lock') then Scripts:=false;//скрипты опускания и поднятия не были выполнены
If not Scripts then If ubuntu or debian then Scripts:=true;
If not Scripts then If not Welcome then
                 begin
                    Shell ('killall pppd');
                    Shell ('route add default dev '+Memo_Config.Lines[3]);
                    If FileExists('/tmp/ip-down') then  //возврат к изначальной настройке скрипта ip-down
                            begin
                                Memo_ip_down.Clear;
                                Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                Memo_ip_down.Lines.LoadFromFile('/tmp/ip-down');
                                Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                            end;
                     Shell ('printf "welcome /etc/ppp/ip-up.d/ip-up\n" >> /etc/ppp/peers/'+Memo_Config.Lines[0]);
                     Welcome:=true;
                end;
Shell('rm -f /tmp/hosts.tmp');
If not Code_up_ppp then If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
//обработка случая когда RemoteIPaddress совпадается с ip-адресом самого vpn-сервера
If Code_up_ppp then
               If FileExists('/opt/vpnpptp/hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                      begin
                                         Shell('rm -f /tmp/RemoteIPaddress');
                                         Shell ('ifconfig|grep P-t-P|awk '+chr(39)+'{print $3}'+chr(39)+' >> /tmp/RemoteIPaddress');
                                         If FileSize('/tmp/RemoteIPaddress')<>0 then
                                                                                 begin
                                                                                    AssignFile (FileRemoteIPaddress,'/tmp/RemoteIPaddress');
                                                                                    reset (FileRemoteIPaddress);
                                                                                    readln(FileRemoteIPaddress, Str_RemoteIPaddress);
                                                                                    RemoteIPaddress:=RightStr(Str_RemoteIPaddress,Length(Str_RemoteIPaddress)-6);
                                                                                    closefile (FileRemoteIPaddress);
                                                                                    Shell('rm -f /tmp/RemoteIPaddress');
                                                                                    Memo_bindutilshost0.Lines.LoadFromFile('/opt/vpnpptp/hosts');
                                                                                    FindRemoteIPaddress:=false;
                                                                                    For i:=0 to Memo_bindutilshost0.Lines.Count-1 do
                                                                                    If RemoteIPaddress=Memo_bindutilshost0.Lines[i] then FindRemoteIPaddress:=true;
                                                                                    If FindRemoteIPaddress then
                                                                                                          begin
                                                                                                            //обнаружено совпадение RemoteIPaddress с ip-адресом самого vpn-сервера
                                                                                                            Application.ProcessMessages;
                                                                                                            str:=message20;
                                                                                                            BalloonMessage (8000,str);
                                                                                                            Application.ProcessMessages;
                                                                                                            If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
                                                                                                            //изменение скрипта ip-up
                                                                                                            If FileExists('/etc/ppp/ip-up.d/ip-up') then
                                                                                                                                                    begin
                                                                                                                                                         If not suse then if not fedora then Shell ('printf "'+'/sbin/route add -host \$PPP_REMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-up.d/ip-up');
                                                                                                                                                         If suse or fedora then Shell ('printf "'+'/sbin/route add -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-up.d/ip-up');
                                                                                                                                                    end;
                                                                                                            //изменение скрипта ip-down
                                                                                                            If Memo_Config.Lines[7]='reconnect-pptp' then if FileExists('/etc/ppp/ip-down.d/ip-down') then
                                                                                                                                                     begin
                                                                                                                                                          If not suse then if not fedora then Shell ('printf "'+'/sbin/route del -host \$PPP_REMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-down.d/ip-down');
                                                                                                                                                          If suse or fedora then Shell ('printf "'+'/sbin/route del -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-down.d/ip-down');
                                                                                                                                                     end;
                                                                                                            If Memo_Config.Lines[7]='noreconnect-pptp' then if FileExists('/tmp/ip-down') then
                                                                                                                                                     begin
                                                                                                                                                          If not suse then if not fedora then Shell ('printf "'+'/sbin/route del -host \$PPP_REMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /tmp/ip-down');
                                                                                                                                                          If suse or fedora then Shell ('printf "'+'/sbin/route del -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /tmp/ip-down');
                                                                                                                                                      end;
                                                                                                            Shell('rm -f /opt/vpnpptp/hosts');
                                                                                                          end;
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
If link=1 then If NoInternet then MakeDefaultGW;
If not Code_up_ppp then
       If FileExists('/opt/vpnpptp/resolv.conf') then
                                 Shell ('cp -f /opt/vpnpptp/resolv.conf /etc/resolv.conf');
//проверка технической возможности поднятия соединения
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[30]<>'none' then
                            begin //тест dns1-сервера
                                 Shell('rm -f /tmp/networktest');
                                 Str:='ping -c1 '+Memo_config.Lines[30]+'|grep '+chr(39)+'1 received'+chr(39)+' > /tmp/networktest';
                                 Application.ProcessMessages;
                                 Shell(str);
                                 Application.ProcessMessages;
                                 If FileSize('/tmp/networktest')=0 then
                                                                   begin
                                                                        NoPingDNS1:=true;
                                                                        BalloonMessage (8000,message23);
                                                                        sleep(1000);
                                                                   end;
                                 Shell('rm -f /tmp/networktest');
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[31]<>'none' then
                            begin //тест dns2-сервера
                                 Shell('rm -f /tmp/networktest');
                                 Str:='ping -c1 '+Memo_config.Lines[31]+'|grep '+chr(39)+'1 received'+chr(39)+' > /tmp/networktest';
                                 Application.ProcessMessages;
                                 Shell(str);
                                 Application.ProcessMessages;
                                 If FileSize('/tmp/networktest')=0 then
                                                                   begin
                                                                        NoPingDNS2:=true;
                                                                        BalloonMessage (8000,message24);
                                                                        sleep(1000);
                                                                   end;
                                 Shell('rm -f /tmp/networktest');
                            end;
If not Code_up_ppp then If ((Memo_Config.Lines[23]='networktest-yes') and (BindUtils)) or ((Memo_Config.Lines[23]='networktest-yes') and (Memo_config.Lines[22]='routevpnauto-no')) then
                            begin //тест vpn-сервера
                                 Shell('rm -f /tmp/networktest');
                                 Str:='ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39)+' > /tmp/networktest';
                                 Application.ProcessMessages;
                                 Shell(str);
                                 Application.ProcessMessages;
                                 Shell('printf "none\n" >> /tmp/networktest');
                                 Memo_networktest.Lines.LoadFromFile('/tmp/networktest');
                                 If Memo_networktest.Lines[0]='none' then NoPingIPS:=true;
                                 Shell('rm -f /tmp/networktest');
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then
                            begin //тест шлюза локальной сети
                                 Shell('rm -f /tmp/networktest');
                                 Str:='ping -c1 '+Memo_config.Lines[2]+'|grep '+chr(39)+'1 received'+chr(39)+' > /tmp/networktest';
                                 Application.ProcessMessages;
                                 Shell(str);
                                 Application.ProcessMessages;
                                 Shell('printf "none\n" >> /tmp/networktest');
                                 Memo_networktest.Lines.LoadFromFile('/tmp/networktest');
                                 If Memo_networktest.Lines[0]='none' then NoPingGW:=true;
                                 Shell('rm -f /tmp/networktest');
                            end;
If not Code_up_ppp then DhclientStart:=false;
If not Code_up_ppp then If link=1 then //старт dhclient
                           begin
                              Application.ProcessMessages;
                              If not NoPingIPS then If not NoDNS then If not NoPingGW then If Memo_Config.Lines[9]='dhcp-route-yes' then
                              begin
                                //if not FileExists ('/etc/init.d/network-manager') then if not FileExists ('/etc/init.d/NetworkManager') then
                                                                                  begin
                                                                                  For h:=1 to CountInterface do
                                                                                       Shell ('route del default');
                                                                                  end;
                                If FileExists ('/sbin/ifup') then Shell ('ifup '+Memo_Config.Lines[3]);
                                If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig '+Memo_Config.Lines[3]+' up');
                                If not DhclientStart then begin Shell ('dhclient '+Memo_Config.Lines[3]);Application.ProcessMessages;end;
                                DhclientStart:=true;
                              //If FileExists ('/sbin/ifdown') then Shell ('ifdown '+Memo_Config.Lines[3]);//для проверки бага
                              end;
                              If link=1 then If NoInternet then If Memo_Config.Lines[9]='dhcp-route-yes' then //проверка поднялся ли интерфейс после dhclient
                              begin
                                 Shell ('rm -f /tmp/gate');
                                 Shell('/sbin/ip r|grep '+Memo_Config.Lines[3]+' > /tmp/gate');
                                 Shell('printf "none" >> /tmp/gate');
                                 Memo_gate.Clear;
                                 If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
                                 If Memo_gate.Lines[0]='none' then
                                    begin
                                         sleep (2000);
                                         Shell ('rm -f /tmp/gate');
                                         Shell('/sbin/ip r|grep '+Memo_Config.Lines[3]+' > /tmp/gate');
                                         Shell('printf "none" >> /tmp/gate');
                                         Memo_gate.Clear;
                                         If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
                                         If Memo_gate.Lines[0]='none' then
                                         begin
                                              If FileExists ('/sbin/ifup') then Shell ('ifup '+Memo_Config.Lines[3]);
                                              If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig '+Memo_Config.Lines[3]+' up');
                                              DhclientStart:=false;
                                         end;
                                    end;
                                 Shell ('rm -f /tmp/gate');
                                 Memo_gate.Lines.Clear;
                              end;
                           end;
  //определение и сохранение всех актуальных в данный момент ip-адресов vpn-сервера с занесением маршрутов везде
  If not FileExists('/opt/vpnpptp/hosts') then NewIPS:=false;
  if BindUtils then Str:='host '+Memo_config.Lines[1]+'|grep address|grep '+Memo_config.Lines[1]+'|awk '+ chr(39)+'{print $4}'+chr(39);
  if not BindUtils then Str:='ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39);
  If not Code_up_ppp then If link=1 then
               If FileExists('/opt/vpnpptp/hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                              begin
                                                  Shell('rm -f /tmp/hosts');
                                                  Application.ProcessMessages;
                                                  Shell (Str+' >> /tmp/hosts');
                                                  Application.ProcessMessages;
                                                  If FileSize('/tmp/hosts')=0 then If not BindUtils then
                                                                                             NoPingIPS:=true;
                                                  If FileSize('/tmp/hosts')=0 then If BindUtils then
                                                                                             NoDNS:=true;
                                                  Memo_bindutilshost0.Lines.LoadFromFile('/opt/vpnpptp/hosts');
                                                  AssignFile (Filenetworktest,'/tmp/hosts');
                                                  reset (Filenetworktest);
                                              While not eof(Filenetworktest) do
                                              begin
                                                  readln(Filenetworktest, Str_networktest);
                                                  NewIPS:=true;
                                                  For i:=0 to Memo_bindutilshost0.Lines.Count-1 do
                                                  begin
                                                      Str_networktest:=DeleteSym('(',Str_networktest);
                                                      Str_networktest:=DeleteSym(')',Str_networktest);
                                                      If Str_networktest <>'' then
                                                                      If Str_networktest=Memo_bindutilshost0.Lines[i] then
                                                                                                                      NewIPS:=false;
                                                  end;
                                              If Memo_Config.Lines[41]='etc-hosts-yes' then Shell ('printf "'+Str_networktest+' '+Memo_config.Lines[1]+'\n" >> /etc/hosts');
                                              If NewIPS then
                                                  begin //определился новый, неизвестный ранее ip-адрес vpn-сервера
                                                        Shell('printf "'+Str_networktest+'\n'+'" >> /opt/vpnpptp/hosts');
                                                        //проверка на наличие добавляемого маршрута в таблице маршрутизации и его добавление если нету
                                                        Shell('/sbin/route -n|grep '+Str_networktest+'|grep '+Memo_config.Lines[2]+'|grep '+Memo_config.Lines[3]+'|awk '+ chr(39)+'{print $0}'+chr(39)+' > /tmp/gatevpn');
                                                        Shell('printf "none" >> /tmp/gatevpn');
                                                        Memo_gatevpn.Clear;
                                                        If FileExists('/tmp/gatevpn') then Memo_gatevpn.Lines.LoadFromFile('/tmp/gatevpn');
                                                        //немедленно добавить маршрут в таблицу маршрутизации
                                                        If Memo_gatevpn.Lines[0]='none' then
                                                                                        Shell ('/sbin/route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]);
                                                        Shell('rm -f /tmp/gatevpn');
                                                        //изменение скрипта ip-up
                                                        If FileExists('/etc/ppp/ip-up.d/ip-up') then
                                                                                        Shell ('printf "'+'/sbin/route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-up.d/ip-up');
                                                        //изменение скрипта ip-down
                                                        If Memo_Config.Lines[7]='reconnect-pptp' then if FileExists('/etc/ppp/ip-down.d/ip-down') then
                                                                                        Shell ('printf "'+'/sbin/route del -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-down.d/ip-down');
                                                        If Memo_Config.Lines[7]='noreconnect-pptp' then if FileExists('/tmp/ip-down') then
                                                                                        Shell ('printf "'+'/sbin/route del -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /tmp/ip-down');
                                                  end;
                                              end;
                                           closefile (Filenetworktest);
                                           end;
                                           Shell('rm -f /tmp/hosts');
If Code_up_ppp then If link<>1 then //когда связи по факту нет, но в NetApplet и в ifconfig ppp0 числится, а pppd продолжает сидеть в процессах
                               begin
                                 MenuItem2Click(Self);
                                 If FileExists ('/opt/vpnpptp/off.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                                 exit;
                               end;

If Code_up_ppp then Timer1.Interval:=StrToInt64(Memo_Config.Lines[4]) else Timer1.Interval:=StrToInt64(Memo_Config.Lines[5]);
If Code_up_ppp then If Timer1.Interval=0 then Timer1.Interval:=1000;

If not Code_up_ppp then If link=3 then
                                  begin
                                   MenuItem2Click(Self);
                                   If FileExists ('/opt/vpnpptp/off.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                TrayIcon1.Hide;
                                                                Form3.MyMessageBox(message0,message9,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon);
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
                                   If FileExists ('/opt/vpnpptp/off.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                TrayIcon1.Hide;
                                                                Form3.MyMessageBox(message0,message9,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon);
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
If not Code_up_ppp then If ((link=2) or (link=3)) then
                           begin
                                  Application.ProcessMessages;
                                  If NoPingDNS1 then BalloonMessage (8000,message23);
                                  If NoPingDNS2 then BalloonMessage (8000,message24);
                                  str:='';
                                  If Memo_config.Lines[22]='routevpnauto-yes' then If NewIPS then str:=message14+str;
                                  If Memo_Config.Lines[9]='dhcp-route-yes' then if DhclientStart then str:=message13+str;
                                  If Memo_Config.Lines[9]='dhcp-route-yes' then if not DhclientStart then str:=message21+str;
                                  If NoPingIPS then str:=message15;
                                  If NoPingGW then str:=message18;
                                  If NoDNS then str:=message17;
                                  If (NoPingIPS and NoDNS) then str:=message15+message17;
                                  If (NoPingGW and NoDNS) then str:=message18+message17;
                                  If (NoPingGW and NoPingIPS) then str:=message18+message15;
                                  If (NoPingGW and NoPingIPS and NoDNS) then str:=message18+message15+message17;
                                  If (NoPingIPS) or (NoPingGW) or (NoDNS) then BalloonMessage (8000,str);
                           end;
If not Code_up_ppp then If link=1 then
                           begin
                                  Form1.MenuItem2Click(Self);//на всякий случай отключаем вдруг созданное ppp
                                  Application.ProcessMessages;
                                  If NoPingDNS1 then BalloonMessage (8000,message23);
                                  If NoPingDNS2 then BalloonMessage (8000,message24);
                                  str:='';
                                  str:=message12+Memo_Config.Lines[0]+'...';
                                  If Memo_config.Lines[22]='routevpnauto-yes' then If NewIPS then str:=message14+str;
                                  If Memo_Config.Lines[9]='dhcp-route-yes' then if DhclientStart then str:=message13+str;
                                  If Memo_Config.Lines[9]='dhcp-route-yes' then if not DhclientStart then str:=message21+str;
                                  If NoPingIPS then str:=message15;
                                  If NoDNS then str:=message17;
                                  If NoPingGW then str:=message18;
                                  If (NoPingGW and NoPingIPS) then str:=message18+message15;
                                  If (NoPingIPS and NoDNS) then str:=message15+message17;
                                  If (NoPingGW and NoDNS) then str:=message18+message17;
                                  If (NoPingIPS and NoPingGW and NoDNS) then str:=message18+message15+message17;
                                  BalloonMessage (8000,str);
                                  Application.ProcessMessages;
                                  If NoPingIPS or NoDNS then
                                                   begin
                                                      //if not FileExists ('/etc/init.d/network-manager') then
                                                                                                            begin
                                                                                                            For h:=1 to CountInterface do
                                                                                                                Shell ('route del default');
                                                                                                            end;
                                                      If FileExists ('/sbin/ifdown') then Shell ('ifdown '+Memo_Config.Lines[3]);
                                                      If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig '+Memo_Config.Lines[3]+' down');
                                                      If FileExists ('/sbin/ifup') then Shell ('ifup '+Memo_Config.Lines[3]);
                                                      If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig '+Memo_Config.Lines[3]+' up');
                                                   end;
                                  If not NoPingIPS then If not NoDNS then If not NoPingGW then
                                                   begin
                                                      If not FileExists('/tmp/ObnullRX') then ObnullRX:=false else ObnullRX:=true;
                                                      If not FileExists('/tmp/ObnullTX') then ObnullTX:=false else ObnullTX:=true;
                                                      If not FileExists ('/tmp/DateStart') then DateStart:=0;
                                                      If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then If FileExists ('/sbin/ifup') then Shell ('ifup lo');
                                                      If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig lo up');
                                                      For h:=1 to CountInterface do
                                                                          Shell ('route del default');
                                                      Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
                                                      DoubleRunPonoff:=false;
                                                      If Memo_Config.Lines[39]<>'l2tp' then
                                                                                    Shell ('/usr/sbin/pppd call '+Memo_Config.Lines[0]) else
                                                                                                              begin
                                                                                                                  Shell ('service xl2tpd stop');
                                                                                                                  Shell ('service xl2tpd start');
                                                                                                                  Shell ('echo "c '+Memo_Config.Lines[0]+'" > /var/run/xl2tpd/l2tp-control');
                                                                                                              end;
                                                   end;
                           end;
Application.ProcessMessages;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  link:byte; //1-link ok, 2-no link, 3-none
  i,j,h:integer;
  FilePeers:textfile;
  str:string;
  Apid:tpid;
  Code_up_ppp:boolean;
begin
  DoubleRunPonoff:=false;
  ubuntu:=false;
  debian:=false;
  fedora:=false;
  suse:=false;
  mandriva:=false;
  Application.CreateForm(TForm3, Form3);
  Application.ShowMainForm:=false;
  Application.Minimize;
  If FileExists ('/opt/vpnpptp/ponoff.png') then Image1.Picture.LoadFromFile('/opt/vpnpptp/ponoff.png');
  Panel1.Caption:=message37+' '+message38;
  Form1.Height:=152;
  Form1.Width:=670;
  Form1.Font.Size:=AFont;
  RXbyte:='0';
  TXbyte:='0';
  RXSpeed:='0b/s';
  TXSpeed:='0b/s';
  Count:=0;
  CountInterface:=1;
  CountKillallpppd:=0;
  Form1.Visible:=false;
  Form1.WindowState:=wsMinimized;
  Form1.Hide;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  Scripts:=true;
  NoInternet:=true;
  DhclientStart:=false;
  RemoteIPaddress:='none';
  If FileExists ('/usr/bin/host') then BindUtils:=true else BindUtils:=false;
  MenuItem3.Caption:=message10;
  MenuItem4.Caption:=message11;
  MenuItem5.Caption:=message39;
  TrayIcon1.BalloonTitle:=message0;
  If Screen.Height<440 then AFont:=6;
  If Screen.Height<=480 then AFont:=6;
  If Screen.Height<550 then If not (Screen.Height<=480) then AFont:=6;
  If Screen.Height>550 then AFont:=8;
  If Screen.Height>1000 then AFont:=10;
//проверка ponoff в процессах root, исключение запуска под иными пользователями
   Shell('ps -u root | grep ponoff | awk '+chr(39)+'{print $4}'+chr(39)+' > /tmp/tmpnostart1');
   Shell('printf "none" >> /tmp/tmpnostart1');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart1') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart1');
   If not (LeftStr(tmpnostart.Lines[0],6)='ponoff') then
                                                        begin
                                                             //запуск не под root
                                                             Timer1.Enabled:=False;
                                                             Timer2.Enabled:=False;
                                                             Form1.Hide;
                                                             TrayIcon1.Hide;
                                                             Form3.MyMessageBox(message0,message1+' '+message25,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon);
                                                             Shell('rm -f /tmp/tmpnostart1');
                                                             halt;
                                                         end;
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
  If FileExists('/opt/vpnpptp/config') then begin Memo_Config.Lines.LoadFromFile('/opt/vpnpptp/config');end
  else
   begin
    Timer1.Enabled:=False;
    Timer2.Enabled:=False;
    Form1.Hide;
    TrayIcon1.Hide;
    If mandriva then Form3.MyMessageBox(message0,message3+' '+message26,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon)
                          else Form3.MyMessageBox(message0,message3,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon);
    halt;
   end;
  If Memo_Config.Lines[42]<>'none' then AFont:=StrToInt(Memo_Config.Lines[42]);
  If Memo_Config.Lines[43]='ubuntu' then ubuntu:=true;
  If Memo_Config.Lines[43]='debian' then debian:=true;
  If Memo_Config.Lines[43]='fedora' then fedora:=true;
  If Memo_Config.Lines[43]='suse' then suse:=true;
  If Memo_Config.Lines[43]='mandriva' then mandriva:=true;
  Form1.Font.Size:=AFont;
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
If Code_up_ppp then If FileExists ('/opt/vpnpptp/on.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/on.ico');
If not Code_up_ppp then If FileExists ('/opt/vpnpptp/off.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
TrayIcon1.Show;
Application.ProcessMessages;
//проверка ponoff в процессах root, обработка двойного запуска программы
  If LeftStr(tmpnostart.Lines[0],6)='ponoff' then if LeftStr(tmpnostart.Lines[1],6)='ponoff' then
                                             begin
                                                  DoubleRunPonoff:=true;
                                                  Apid:=FpGetpid;
                                                  Shell('ps -e|grep ponoff|awk '+chr(39)+'{print$1}'+chr(39)+' >/tmp/doublerun');
                                                  AssignFile (FileDoubleRun,'/tmp/doublerun');
                                                  reset (FileDoubleRun);
                                                  While not eof(FileDoubleRun) do
                                                        begin
                                                             Readln (FileDoubleRun,str);
                                                             If str<>IntToStr(Apid) then
                                                             FpKill(StrToInt(str),9);
                                                        end;
                                                  closefile (FileDoubleRun);
                                                  Shell('rm -f /tmp/doublerun')
                                             end;
If not FileExists ('/tmp/DateStart') then DateStart:=0 else
                                       begin
                                            AssignFile (FileDateStart,'/tmp/DateStart');
                                            reset (FileDateStart);
                                            While not eof(FileDateStart) do
                                            begin
                                                 readln(FileDateStart, str);
                                            end;
                                            closefile (FileDateStart);
                                            DateStart:=StrToInt(str);
                                       end;
//учитывание особенностей openSUSE
If suse then
        begin
             Shell('/sbin/ip r|grep dsl > /tmp/gate');
             If FileExists ('/tmp/gate') then if FileSize('/tmp/gate')<>0 then
                                         begin
                                           Timer1.Enabled:=False;
                                           Timer2.Enabled:=False;
                                           Form1.Hide;
                                           TrayIcon1.Hide;
                                           Form3.MyMessageBox(message0,message41,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon);
                                           Shell('rm -f /tmp/gate');
                                           halt;
                                         end;
        end;
   Shell('rm -f /tmp/tmpnostart1');
   If Memo_Config.Lines[23]='networktest-no' then NoInternet:=false;
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
   If link=3 then //попытка поднять требуемый интерфейс
                begin
                   If FileExists ('/etc/init.d/network') then Shell ('service network restart');
                   If debian then if FileExists ('/etc/init.d/networking') then Shell ('/etc/init.d/networking restart');
                   If not FileExists ('/etc/init.d/network') or fedora then
                                                             begin
                                                                  Shell ('service network-manager restart');
                                                                  Shell ('service NetworkManager restart');
                                                             end;
                   //if not FileExists ('/etc/init.d/network-manager') then
                                                                         begin
                                                                         For h:=1 to CountInterface do
                                                                             Shell ('route del default');
                                                                         end;
                   If FileExists ('/sbin/ifdown') then Shell ('ifdown '+Memo_Config.Lines[3]);
                   If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig '+Memo_Config.Lines[3]+' down');
                   If FileExists ('/sbin/ifup') then Shell ('ifup '+Memo_Config.Lines[3]);
                   If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig '+Memo_Config.Lines[3]+' up');
                   //повторная проверка состояния сетевого интерфейса
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
                end;
   If link=3 then
                begin
                 MenuItem3.Visible:=false;
                 MenuItem4.Visible:=false;
                 Timer1.Enabled:=False;
                 Timer2.Enabled:=False;
                 TrayIcon1.Hide;
                 Form3.MyMessageBox(message0,message4,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon);
                 halt;
                end;
   if link=2 then
                begin
                 Form3.MyMessageBox(message0,message5,'','',message33,'/opt/vpnpptp/ponoff.png',false,false,true,AFont,Form1.Icon);
                 Timer1.Enabled:=False;
                 Timer2.Enabled:=False;
                 TrayIcon1.Hide;
                 halt;
                end;
  Timer1.Interval:=StrToInt64(Memo_Config.Lines[5]);
  MenuItem2Click(Self);//на всякий случай отключаем вдруг созданное ppp
  If Memo_Config.Lines[7]='reconnect-pptp' then
                                             begin
                                             Timer1.Enabled:=False;
                                             MenuItem1Click(Self);
                                             end
                                                else
                                                   Timer1.Interval:=100;
Welcome:=false;
AssignFile (FilePeers,'/etc/ppp/peers/'+Memo_Config.Lines[0]);
reset (FilePeers);
While not eof(FilePeers) do
      begin
         readln(FilePeers, Str);
         If Str='welcome /etc/ppp/ip-up.d/ip-up' then Welcome:=true;
       end;
closefile (FilePeers);
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
 //просто убивает pppd, xl2tpd и других демонов и удаляет временные файлы
var i:integer;
begin
 If DoubleRunPonoff then exit;
//проверка наличия в процессах демона pppd
 Shell('ps -u root | grep pppd | awk '+chr(39)+'{print $4}'+chr(39)+' > /tmp/tmp_pppd');
 Form1.tmp_pppd.Clear;
 If FileExists('/tmp/tmp_pppd') then tmp_pppd.Lines.LoadFromFile('/tmp/tmp_pppd');
 Application.ProcessMessages;
 For i:=0 to tmp_pppd.Lines.Count-1 do
 If (LeftStr(tmp_pppd.Lines[i],4)='pppd') then
                                        begin
                                             Shell('killall pppd');
                                             CountKillallpppd:=CountKillallpppd+1;
                                             If not FileExists ('/etc/init.d/network') or fedora then
                                                                                       begin
                                                                                            Shell ('service network-manager restart');
                                                                                            Shell ('service NetworkManager restart');
                                                                                            sleep (3000);
                                                                                       end;
                                        end;
 Shell ('service xl2tpd stop');
 Shell ('killall xl2tpd');
 Shell ('killall openl2tpd');
 Shell ('killall l2tpd');
 Application.ProcessMessages;
 Shell('rm -f /tmp/status.ppp');
 Shell('rm -f /tmp/tmp');
 Shell('rm -f /tmp/gate');
 Shell('rm -f /tmp/gate1');
 Shell('rm -f /tmp/gate2');
 Shell('rm -f /tmp/users');
 Shell('rm -f /tmp/tmpnostart1');
 Shell('rm -f /tmp/status3.ppp');
 Shell('rm -f /tmp/status.ppp');
 Shell('rm -f /tmp/tmp_pppd');
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
//выход без аварии
var h:integer;
begin
 DoubleRunPonoff:=false;
 Timer1.Enabled:=False;
 Timer2.Enabled:=False;
 Shell ('killall net_monitor');
 If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
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
  If FileExists ('/opt/vpnpptp/off.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
  Application.ProcessMessages;
  Shell ('rm -f /tmp/gate');
  If (not Scripts) or (Welcome) then Shell ('etc/ppp/ip-down.d/ip-down');
  Shell('rm -f /etc/resolv.conf.lock');
  For h:=1 to CountInterface do
              Shell ('route del default');
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then If FileExists ('/sbin/ifup') then Shell ('ifup lo');
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig lo up');
  Shell('rm -f /tmp/xl2tpd.conf');
  If CountKillallpppd=2 then If not FileExists ('/etc/init.d/network') or fedora then
                                                                       begin
                                                                            Shell ('service network-manager restart');
                                                                            Shell ('service NetworkManager restart');
                                                                       end;
  If FileExists('/opt/vpnpptp/resolv.conf') then Shell ('cp -f /opt/vpnpptp/resolv.conf /etc/resolv.conf');
  Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
  Shell ('rm -f /tmp/DateStart');
  Shell ('rm -f /tmp/ObnullRX');
  Shell ('rm -f /tmp/ObnullTX');
  MakeDefaultGW;
  halt;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
//выход при аварии
var
 i:integer;
begin
  DoubleRunPonoff:=false;
  Timer1.Enabled:=False;
  Timer2.Enabled:=False;
  Shell ('killall net_monitor');
  If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  If FileExists('/opt/vpnpptp/resolv.conf') then Shell ('cp -f /opt/vpnpptp/resolv.conf /etc/resolv.conf');
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
  MenuItem2Click(Self);
  If FileExists ('/opt/vpnpptp/off.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
  Application.ProcessMessages;
  For i:=0 to 9 do
      begin
        If FileExists ('/sbin/ifdown') then Shell ('ifdown eth'+IntToStr(i));
        If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig eth'+IntToStr(i)+' down');
        If FileExists ('/sbin/ifdown') then Shell ('ifdown wlan'+IntToStr(i));
        If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig wlan'+IntToStr(i)+' down');
      end;
  If FileExists ('/etc/init.d/network') then Shell ('service network restart'); // организация конкурса интерфейсов
  If debian then if FileExists ('/etc/init.d/networking') then Shell ('/etc/init.d/networking restart');
  If not FileExists ('/etc/init.d/network') or fedora then
                                            begin
                                                 Shell ('service network-manager restart');
                                                 Shell ('service NetworkManager restart');
                                            end;
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then If FileExists ('/sbin/ifup') then Shell ('ifup lo');
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig lo up');
  If suse then Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
 //определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сеть своим алгоритмом
  Shell ('rm -f /tmp/gate');
  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('printf "none" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  If Memo_gate.Lines[0]='none' then
     begin
         For i:=0 to 9 do
             begin
              If FileExists ('/sbin/ifdown') then Shell ('ifdown eth'+IntToStr(i));
              If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig eth'+IntToStr(i)+' down');
              If FileExists ('/sbin/ifdown') then Shell ('ifdown wlan'+IntToStr(i));
              If (not FileExists ('/sbin/ifdown')) or ubuntu then Shell ('ifconfig wlan'+IntToStr(i)+' down');
             end;
            If FileExists ('/etc/init.d/network') then Shell ('service network stop');
            If FileExists ('/etc/init.d/network') then Shell ('service network start');
            If debian then if FileExists ('/etc/init.d/networking') then Shell ('/etc/init.d/networking restart');
            If not FileExists ('/etc/init.d/network') or fedora then
                                                      begin
                                                           Shell ('service network-manager restart');
                                                           Shell ('service NetworkManager restart');
                                                      end;
            For i:=0 to 9 do
                 begin
                    If FileExists ('/sbin/ifup') then Shell ('ifup eth'+IntToStr(i));
                    If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig eth'+IntToStr(i)+' up');
                    If FileExists ('/sbin/ifup') then Shell ('ifup wlan'+IntToStr(i));
                    If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig wlan'+IntToStr(i)+' up');
                 end;
           If FileExists ('/sbin/ifup') then Shell ('ifup lo');
           If (not FileExists ('/sbin/ifup')) or ubuntu then Shell ('ifconfig lo up');
     end;
  If (not Scripts) or (Welcome) then Shell ('etc/ppp/ip-down.d/ip-down');
  Shell('rm -f /etc/resolv.conf.lock');
  Shell ('rm -f /tmp/gate');
  Memo_gate.Lines.Clear;
  Shell ('rm -f /tmp/DateStart');
  Shell ('rm -f /tmp/ObnullRX');
  Shell ('rm -f /tmp/ObnullTX');
  halt;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var
  j:integer;
  Code_up_ppp:boolean;
  pppiface:string;
begin
  //Проверяем поднялось ли соединение
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
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
       pppiface:=LeftStr(Memo2.Lines[j],4);
       Code_up_ppp:=True;
      end;
   end;
  If Code_up_ppp then
             begin
                AProcess := TProcess.Create(nil);
                AProcess.CommandLine := '/usr/bin/net_monitor -i '+pppiface;
                AProcess.Execute;
                AProcess.Free;
             end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  MenuItem1Click(Self);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
//индикация иконки в трее, балуны и тест интернета
var
  j:integer;
  Code_up_ppp:boolean;
  pppiface,Str:string;
  RXbyte1,TXbyte1:string;
  TV : timeval;
  DNS3,DNS4:string;
begin
  Count:=Count+1;
  If Count=3 then Count:=1;
  //Проверяем поднялось ли соединение
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
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
       pppiface:=LeftStr(Memo2.Lines[j],4);
       Code_up_ppp:=True;
      end;
   end;
  //определяем скорость, время
  popen (f,'ifconfig '+pppiface+'|grep RX|grep bytes|awk '+chr(39)+'{print $2}'+chr(39),'R');
  If eof(f) then RXbyte1:='0';
  While not eof(f) do
     begin
       Readln (f,RXbyte1);
     end;
  PClose(f);
  popen (f,'ifconfig '+pppiface+'|grep TX|grep bytes|awk '+chr(39)+'{print $6}'+chr(39),'R');
  If eof(f) then TXbyte1:='0';
  While not eof(f) do
     begin
       Readln (f,TXbyte1);
     end;
  PClose(f);
  Delete(RXbyte1,1,6);
  Delete(TXbyte1,1,6);
  If StrToInt64(RXbyte1)>=4242538496 then begin ObnullRX:=true; Shell ('touch /tmp/ObnullRX'); end;//реакция программы за 3сек до факта обнуления значений
  If StrToInt64(TXbyte1)>=4242538496 then begin ObnullTX:=true; Shell ('touch /tmp/ObnullTX'); end;//2^32-4сек*100MБит/сек=4294967296-4сек*13107200Б/сек
  If Count=2 then
  begin
     RXSpeed:=IntToStr((abs(StrToInt64(RXbyte1)-StrToInt64(RXbyte)) div (Timer2.Interval div 1000)) div Count);
     TXSpeed:=IntToStr((abs(StrToInt64(TXbyte1)-StrToInt64(TXbyte)) div (Timer2.Interval div 1000)) div Count);
     RXbyte:=RXbyte1;
     TXbyte:=TXbyte1;
     If StrToInt64(RXSpeed)>1048576 then RXSpeed:=IntToStr(StrToInt64(RXSpeed) div 1048576)+'MiB/s'
           else If StrToInt64(RXSpeed)>1024 then RXSpeed:=IntToStr(StrToInt64(RXSpeed) div 1024)+'KiB/s'
                                                                             else RXSpeed:=RXSpeed+'b/s';
     If StrToInt64(TXSpeed)>1048576 then TXSpeed:=IntToStr(StrToInt64(TXSpeed) div 1048576)+'MiB/s'
           else If StrToInt64(TXSpeed)>1024 then TXSpeed:=IntToStr(StrToInt64(TXSpeed) div 1024)+'KiB/s'
                                                                             else TXSpeed:=TXSpeed+'b/s';
  end;
  If Code_up_ppp then If DateStart=0 then
                      begin
                           fpGettimeofday(@TV,nil);
                           DateStart:=TV.tv_sec;
                           If not FileExists ('/tmp/DateStart') then Shell ('printf "'+IntToStr(DateStart)+'\n" > /tmp/DateStart');
                      end;
  If Code_up_ppp then
                     begin
                             Application.ProcessMessages;
                             If FileExists ('/opt/vpnpptp/on.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/on.ico');
                             If StartMessage then BalloonMessage (8000,message6+' '+Memo_Config.Lines[0]+' '+message7+'...');
                             If Memo_Config.Lines[23]='networktest-no' then NoInternet:=false;
                             If Memo_Config.Lines[29]='pppnotdefault-yes' then NoInternet:=false;
                             If FileExists ('/usr/bin/vnstat') then Shell ('vnstat -u -i '+pppiface);
                             If StartMessage then If Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If NoInternet then
                             begin
                                 sleep (1000);
                                //определение dns, на которых поднято vpn
                                 DNS3:='none';
                                 DNS4:='none';
                                 If FileExists('/etc/resolv.conf') then
                                    begin
                                      AssignFile (FileResolv_conf,'/etc/resolv.conf');
                                      reset (FileResolv_conf);
                                      While not eof (FileResolv_conf) do
                                          begin
                                           readln(FileResolv_conf, str);
                                           If leftstr(str,11)='nameserver ' then If DNS3='none' then DNS3:=RightStr(str,Length(str)-11);
                                           If leftstr(str,11)='nameserver ' then If DNS4='none' then if DNS3<>'none' then if RightStr(str,Length(str)-11)<>DNS3 then DNS4:=RightStr(str,Length(str)-11);
                                         end;
                                      closefile(FileResolv_conf);
                                    end;
                                 //тест dns3-сервера
                                 If DNS3<>'none' then
                                    begin
                                         Shell('rm -f /tmp/networktest');
                                         Str:='ping -c1 '+DNS3+'|grep '+chr(39)+'1 received'+chr(39)+' > /tmp/networktest';
                                         Application.ProcessMessages;
                                         Shell(str);
                                         Application.ProcessMessages;
                                         If FileSize('/tmp/networktest')=0 then
                                                                   begin
                                                                        NoPingDNS3:=true;
                                                                        BalloonMessage (8000,message42);
                                                                        sleep(1000);
                                                                   end;
                                         Shell('rm -f /tmp/networktest');
                                    end;
                                 //тест dns4-сервера
                                 If DNS4<>'none' then
                                    begin
                                         Shell('rm -f /tmp/networktest');
                                         Str:='ping -c1 '+DNS4+'|grep '+chr(39)+'1 received'+chr(39)+' > /tmp/networktest';
                                         Application.ProcessMessages;
                                         Shell(str);
                                         Application.ProcessMessages;
                                         If FileSize('/tmp/networktest')=0 then
                                                                   begin
                                                                        NoPingDNS4:=true;
                                                                        BalloonMessage (8000,message40);
                                                                        sleep(1000);
                                                                   end;
                                         Shell('rm -f /tmp/networktest');
                                    end;
                                 //тест интернета
                                 Shell('rm -f /tmp/networktest');
                                 Str:='ping -c1 '+Memo_Config.Lines[44]+'|grep '+Memo_Config.Lines[44]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39)+' > /tmp/networktest';
                                 Application.ProcessMessages;
                                 Shell(str);
                                 Application.ProcessMessages;
                                 Shell('printf "none\n" >> /tmp/networktest');
                                 Memo_networktest.Lines.LoadFromFile('/tmp/networktest');
                                 If Memo_networktest.Lines[0]='none' then NoInternet:=true else NoInternet:=false;
                                 Shell('rm -f /tmp/networktest');
                                 Application.ProcessMessages;
                                 If NoInternet then BalloonMessage (16000,message6+' '+Memo_Config.Lines[0]+' '+message7+'... '+message16)
                                                    else
                                                          BalloonMessage (8000,message6+' '+Memo_Config.Lines[0]+' '+message7+'... '+message19);
                                 Application.ProcessMessages;
                             end;
                             StartMessage:=false;
                     end;
  If not Code_up_ppp then
                           begin
                             Application.ProcessMessages;
                             If not StartMessage then
                                    begin
                                         BalloonMessage (8000,message6+' '+Memo_Config.Lines[0]+' '+message8+'...');
                                         NoInternet:=true;
                                    end;
                             If FileExists ('/opt/vpnpptp/off.ico') then TrayIcon1.Icon.LoadFromFile('/opt/vpnpptp/off.ico');
                             StartMessage:=true;
                           end;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
end;

procedure TForm1.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  j:integer;
  Code_up_ppp,find_net_monitor:boolean;
begin
  If Button=MBLEFT then exit;
  If not FileExists ('/usr/bin/net_monitor') then begin MenuItem5.Visible:=false; exit;end;
  If not FileExists ('/usr/bin/vnstat') then begin MenuItem5.Visible:=false; exit;end;
  //Проверяем поднялось ли соединение
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
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
  find_net_monitor:=false;
  If Code_up_ppp then If FileExists ('/usr/bin/net_monitor') then if FileExists ('/usr/bin/vnstat') then
                    begin
                         //проверка net_monitor в процессах root, игнорируя зомби
                         Shell('ps -u root | grep net_monitor | awk '+chr(39)+'{print $4$5}'+chr(39)+' > /tmp/tmpnostart1');
                         Shell('printf "none" >> /tmp/tmpnostart1');
                         Form1.tmpnostart.Clear;
                         If FileExists('/tmp/tmpnostart1') then
                              begin
                                   tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart1');
                                   For j:=0 to tmpnostart.Lines.Count-1 do
                                            If tmpnostart.Lines[j]='net_monitor' then find_net_monitor:=true;
                              end;
                    end;
  If not find_net_monitor then MenuItem5.Enabled:=true else MenuItem5.Enabled:=false;
  If not Code_up_ppp then MenuItem5.Enabled:=false;
end;

procedure TForm1.TrayIcon1MouseMove(Sender: TObject);
// Вывод информации о соединении
var
  j:integer;
  Code_up_ppp:boolean;
  str:string;
  pppiface:string;
  SecondsPastRun:int64;
  hour,min,sec:int64;
  Time:string;
  TV : timeval;
begin
  SecondsPastRun:=0;
  fpGettimeofday(@TV,nil);
  DateStop:=TV.tv_sec;
  If DateStart<>0 then
     begin
          SecondsPastRun:=DateStop-DateStart;
          hour:=SecondsPastRun div 3600;
          min:=(SecondsPastRun mod 3600) div 60;
          sec:=(SecondsPastRun mod 3600) mod 60;
     end else
             begin
                  hour:=0;
                  min:=0;
                  sec:=0;
             end;
  Time:=IntToStr(hour)+message30+IntToStr(min)+message31+IntToStr(sec)+message32;
  pppiface:='';
  Application.ProcessMessages;
  Shell('rm -f /tmp/status3.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > /tmp/status3.ppp');
  Code_up_ppp:=False;
  If FileExists('/tmp/status3.ppp') then Memo2.Lines.LoadFromFile('/tmp/status3.ppp');
  Memo2.Lines.Add(' ');
  Application.ProcessMessages;
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       pppiface:=LeftStr(Memo2.Lines[j],4);
       Code_up_ppp:=True;
      end;
   end;
  popen (f,'ifconfig '+pppiface+'|grep RX|grep bytes|awk '+chr(39)+'{print $3$4}'+chr(39),'R');
  If eof(f) then RX:='0';
  While not eof(f) do
     begin
       Readln (f,RX);
     end;
  PClose(f);
  popen (f,'ifconfig '+pppiface+'|grep TX|grep bytes|awk '+chr(39)+'{print $7$8}'+chr(39),'R');
  If eof(f) then TX:='0';
  While not eof(f) do
     begin
       Readln (f,TX);
     end;
  PClose(f);
  TX:=DeleteSym ('(',TX);
  TX:=DeleteSym (')',TX);
  RX:=DeleteSym ('(',RX);
  RX:=DeleteSym (')',RX);
  If ObnullRX or FileExists('/tmp/ObnullRX')then RX:='>4GiB';
  If ObnullTX or FileExists('/tmp/ObnullTX')then TX:='>4GiB';
  str:='';
  If Memo_Config.Lines[39]<>'l2tp' then
                                   begin
  If Code_up_ppp then str:=message6+': '+Memo_Config.Lines[0]+' (VPN PPTP)'+chr(13)+message22+' '+message7+chr(13)+message29+' '+Time+chr(13)+message27+' '+RX+' ('+RXSpeed+')'+chr(13)+message28+' '+TX+' ('+TXSpeed+')'
                    else str:=message6+': '+Memo_Config.Lines[0]+' (VPN PPTP)'+chr(13)+message22+' '+message8+chr(13)+message29+' '+Time+chr(13)+message27+' '+RX+' ('+RXSpeed+')'+chr(13)+message28+' '+TX+' ('+TXSpeed+')';
                                   end;
  If Memo_Config.Lines[39]='l2tp' then
                                   begin
  If Code_up_ppp then str:=message6+': '+Memo_Config.Lines[0]+' (VPN L2TP)'+chr(13)+message22+' '+message7+chr(13)+message29+' '+Time+chr(13)+message27+' '+RX+' ('+RXSpeed+')'+chr(13)+message28+' '+TX+' ('+TXSpeed+')'
                    else str:=message6+': '+Memo_Config.Lines[0]+' (VPN L2TP)'+chr(13)+message22+' '+message8+chr(13)+message29+' '+Time+chr(13)+message27+' '+RX+' ('+RXSpeed+')'+chr(13)+message28+' '+TX+' ('+TXSpeed+')';
                                   end;
  TrayIcon1.Hint:=str;
  Application.ProcessMessages;
end;

initialization
  {$I unit1.lrs}
  Gettext.GetLanguageIDs(Lang,FallbackLang);
  Translate:=false;
  //FallbackLang:='uk'; //просто для проверки при отладке
  If FallbackLang='ru' then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/ponoff.ru.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If FallbackLang='uk' then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/ponoff.uk.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If not Translate then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/ponoff.en.po';
                               If FileExists (POFileName) then
                                             Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                            end;
end.
