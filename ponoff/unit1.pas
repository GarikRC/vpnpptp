{ Control VPN PPTP/L2TP/OpenL2TP connection

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
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs, Process, AsyncProcess,
  ExtCtrls, Menus, StdCtrls, Unix, Gettext, Translations,UnitMyMessageBox, BaseUnix, LCLProc;

type

  { TForm1 }
  TForm1 = class(TForm)
    Image1: TImage;
    Memo_General_conf: TMemo;
    Memo_bindutilshost0: TMemo;
    MenuItem5: TMenuItem;
    Memo_Config: TMemo;
    MenuItem4: TMenuItem;
    MenuItem6: TMenuItem;
    Panel1: TPanel;
    Timer2: TTimer;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrayIcon1MouseMove(Sender: TObject);
    procedure BalloonMessage (time_of_show_msec:integer;msg_title,msg_text:string;font_size:integer);
    procedure CheckFiles;
    procedure CheckVPN;
    procedure ClearEtc_hosts;
    procedure MakeDefaultGW;
  private
    { private declarations }
  public
    { public declarations }
  end;

const
  MaxMes=20;//максимальное кол-во выводимых одновременно сообщений (устанавливается с запасом)
  Config_n=47;//определяет сколько строк (кол-во) в файле config программы максимально уже существует, считая от 1, а не от 0
  General_conf_n=5;//определяет сколько строк (кол-во) в файле general.conf программы максимально уже существует, считая от 1, а не от 0
  MyLibDir='/var/lib/vpnpptp/'; //директория для файлов, создаваемых в процессе работы программы
  MyTmpDir='/tmp/vpnpptp/'; //директория для временных файлов
  MyDataDir='/usr/share/vpnpptp/'; //директория для основных неизменных файлов программы
  MyLangDir='/usr/share/vpnpptp/lang/'; //директория для файлов переводов программы
  MyScriptsDir='/usr/share/vpnpptp/scripts/'; //директория для скриптов программы
  MyWikiDir='/usr/share/vpnpptp/wiki/'; //директория для вики программы
  MyPixmapsDir='/usr/share/pixmaps/'; //директория для значков программы
  EtcPppIpUpDDir='/etc/ppp/ip-up.d/';
  EtcPppIpDownDDir='/etc/ppp/ip-down.d/';
  UsrBinDir='/usr/bin/';
  SBinDir='/sbin/';
  EtcDir='/etc/';
  VarLogDir='/var/log/';
  UsrSBinDir='/usr/sbin/';
  VarRunXl2tpdDir='/var/run/xl2tpd/';
  EtcInitDDir='/etc/init.d/';
  EtcPppPeersDir='/etc/ppp/peers/';
  EtcDhcpDir='/etc/dhcp/';
  EtcPppDir='/etc/ppp/';
  EtcShorewallDir='/etc/shorewall/';
  UsrShareApplicationsDir='/usr/share/applications/';
  EtcRcDDir='/etc/rc.d/';
  EtcXl2tpdDir='/etc/xl2tpd/';
  EtcPppIpDownLDir='/etc/ppp/ip-down.l/';
  VarRunVpnpptp='/var/run/vpnpptp/';
  VarRunDir='/var/run/';

var
  Form1: TForm1;
  Lang,FallbackLang:string; // язык системы
  Translate:boolean; // переведено или еще не переведено
  POFileName : string; //файл перевода
  BindUtils:boolean; //установлен ли пакет bind-utils
  StartMessage:boolean; //запускать ли сообщения
  NewIPS:boolean; //найден новый, неизвестный ранее ip-адрес vpn-сервера
  NoPingIPS, NoDNS, NoPingGW, NoPingDNS1, NoPingDNS2, NoPingDNS3, NoPingDNS4:boolean;//события
  NoInternet:boolean;//есть ли интернет
  Filenetworktest, FileRemoteIPaddress, FileEtc_hosts, FileDoubleRun, FileDateStart, FileResolv_conf:textfile;//текстовые файлы
  DhclientStart:boolean; //стартанул ли dhclient
  RemoteIPaddress:string;
  f,f1: text;//текстовый поток
  RX,TX:string;//объем загруженного/отданного для вывода
  RXbyte0,TXbyte0:string;//объем загруженного/отданного в байтах на предыдущем шаге
  RXbyte1,TXbyte1:string;//объем загруженного/отданного в байтах на текущем шаге
  DateStart,DateStop:int64;//время запуска/время текущее
  RXSpeed,TXSpeed:string;//скорость загрузки/отдачи
  ObnullRX,ObnullTX:integer; //отслеживает кол-во обнулений счетчика RX/TX
  AFont:integer; //шрифт приложения
  AProcess,AProcessDhclient,AProcessNet_Monitor: TAsyncProcess; //для запуска внешних приложений
  ubuntu:boolean; // используется ли дистрибутив ubuntu
  debian:boolean; // используется ли дистрибутив debian
  fedora:boolean; // используется ли дистрибутив fedora
  suse:boolean; // используется ли дистрибутив suse
  mandriva:boolean; // используется ли дистрибутив mandriva
  CountInterface:integer; //считает сколько в системе поддерживаемых программой интерфейсов
  DoubleRunPonoff:boolean; //многократный запуск ponoff
  NetServiceStr:string; //какой сервис управляет сетью
  ServiceCommand:string; //команда service или /etc/init.d/, или другая команда
  FlagMtu:boolean; //необходимость проверки mtu
  FlagLengthSyslog:boolean; //проверен ли размер файла-лога /var/log/syslog
  FlagLengthVpnlog:boolean; //проверен ли размер файла-лога /var/log/vpnlog
  Code_up_ppp:boolean; //существует ли интерфейс pppN
  PppIface:string; //точный интерфейс pppN
  Net_MonitorRun:boolean; //запущен ли net_monitor
  ProfileName:string; //определяет какое имя соединения использовать
  ProfileStrDefault:string; //имя соединения, используемое по-умолчанию
  TrafficRX, TrafficTX:int64; //общий трафик RX/TX
  DoSpeedCount:boolean; //выводить ли скорость загрузки/отдачи
  MaxSpeed:int64; //максимальная пропускная способность сети
  LimitRX,LimitTX:byte; //счетчик сколько раз превышалась пропускная способность сети
  NoConnectMessageShow:boolean; //выводить ли сообщение об отсутствии соединения

resourcestring
  message0='Внимание!';
  message1='Запуск этой программы возможен только под администратором или с разрешения администратора. Нажмите <ОК> для отказа от запуска.';
  message2='Не обнаружено ни одного сервиса, способного управлять сетью. Корректная работа программы невозможна!';
  message3='Сначала сконфигурируйте соединение: Меню->Утилиты->Системные(или Меню->Интернет)->vpnpptp(Настройка соединения VPN PPTP/L2TP/OpenL2TP).';
  message4='No ethernet. Cетевой интерфейс для VPN PPTP/L2TP/OpenL2TP недоступен.';
  message5='No link. Сетевой кабель для VPN PPTP/L2TP/OpenL2TP неподключен.';
  message6='Соединение';
  message7='установлено';
  message8='отсутствует';
  message9='No link. Сетевой кабель для VPN PPTP/L2TP/OpenL2TP неподключен. А реконнект не включен.';
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
  message25='Вы можете в конфигураторе VPN PPTP/L2TP/OpenL2TP выбрать опцию разрешения пользователям управлять подключением.';
  message26='Вы также можете сконфигурировать соединение из Центра Управления->Сеть и интернет->Настройка VPN-соединений->VPN PPTP/L2TP/OpenL2TP.';
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
  message43='Рекомендуется вручную уменьшить MTU/MRU, так как используемое значение MTU =';
  message44='байт слишком большое.';
  message45='Размер файла-лога /var/log/syslog больше 1 GiB.';
  message46='Возможны проблемы с установлением соединения...';
  message47='Если же он доступен, то установите "Не контролировать state сетевого кабеля" в Конфигураторе.';
  message48='Отсутствуют некритичные файлы: ';
  message49='Отсутствуют критичные файлы: ';
  message50='Не найдено соединение';
  message51='Обнаружено активное соединение с именем';
  message52='Одновременный запуск нескольких соединений с разными именами недопустим.';
  message53='Отсутствует дефолтное соединение.';
  message54='Выберите одно из доступных соединений, неявляющихся дефолтными, из выпадающего списка. Это соединение станет дефолтным.';
  message55='<ОК> - выбрать. <Отмена> - отказаться и выйти.';
  message56='Соединение с именем';
  message57='не может существовать, так как это имя зарезервировано программой.';
  message58='Шлюз: ';
  message59='IP-адрес: ';
  message60='Интерфейс: ';
  message61='Пожертвования';
  message62='Информация о возможности пожертвований на разработку!';
  message63='Скорость отдачи три раза подряд в течение трех секунд превысила пропускную способность сети. Сеть неработоспособна.';
  message64='Скорость загрузки три раза подряд в течение трех секунд превысила пропускную способность сети.';
  message65='Размер файла-лога /var/log/vpnlog больше 1 GiB.';

implementation

uses balloon_matrix,hint_matrix;

procedure KillZombieNet_Monitor;
//следит за дочерним процессом AProcessNet_Monitor, и если он уже только как зомби, то убирает его
var
   find_net_monitor:boolean;
   str:string;
begin
  find_net_monitor:=false;
  If FileExists (UsrBinDir+'net_monitor') then if FileExists (UsrBinDir+'vnstat') then if Net_MonitorRun then
                    begin
                         //проверка net_monitor в процессах root, игнорируя зомби
                         popen(f,'ps -u root | grep net_monitor | awk '+chr(39)+'{print $4$5}'+chr(39),'R');
                         str:='';
                         While not eof(f) do
                              begin
                                   Readln(f,str);
                                   If str='net_monitor' then find_net_monitor:=true;
                              end;
                         PClose(f);
                         If not find_net_monitor then
                                                 begin
                                                     Net_MonitorRun:=false;
                                                     AProcessNet_Monitor.WaitOnExit;
                                                     AProcessNet_Monitor.Free;
                                                 end;
                    end;
end;

Procedure DoCountInterface;
//считает максимальное кол-во default
var
   str:string;
   i:integer;
begin
  i:=0;
  str:='';
  popen (f,'ifconfig |grep '+chr(39)+'eth'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  str:='';
  popen (f,'ifconfig |grep '+chr(39)+'wlan'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  str:='';
  popen (f,'ifconfig |grep '+chr(39)+'br'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  str:='';
  popen (f,'ifconfig |grep '+chr(39)+'em'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  if i=0 then i:=1;
  CountInterface:=i;
end;

procedure Ifdown (Iface:string;wait:boolean);
//опускает интерфейс
var
   str:string;
begin
         str:='';
         If FileExists (SBinDir+'ifdown') then if not ubuntu then if not fedora then str:='ifdown '+Iface;
         If (not FileExists (SBinDir+'ifdown')) or ubuntu or fedora then str:='ifconfig '+Iface+' down';
         if str<>'' then
                        begin
                             AProcess := TAsyncProcess.Create(nil);
                             if wait then AProcess.Options:=AProcess.Options+[poWaitOnExit];
                             AProcess.CommandLine:=str;
                             AProcess.Execute;
                             AProcess.Free;
                        end;
end;

procedure Ifup (Iface:string;wait:boolean);
//поднимает интерфейс
var
   str:string;
begin
         str:='';
         If FileExists (SBinDir+'ifup') then if not ubuntu then if not fedora then str:='ifup '+Iface;
         If (not FileExists (SBinDir+'ifup')) or ubuntu or fedora then str:='ifconfig '+Iface+' up';
         if str<>'' then
                        begin
                             AProcess := TAsyncProcess.Create(nil);
                             if wait then AProcess.Options:=AProcess.Options+[poWaitOnExit];
                             AProcess.CommandLine:=str;
                             AProcess.Execute;
                             AProcess.Free;
                        end;
end;

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

procedure MySleep (sec:integer);
//пауза
var
  i,j:integer;
begin
   i:=0;
   j:=0;
   repeat
         Sleep(100);
         j:=j+1;
         i:=i+100;
         Application.ProcessMessages;
   until i+100>sec;
end;

{ TForm1 }

procedure TForm1.BalloonMessage (time_of_show_msec:integer;msg_title,msg_text:string;font_size:integer);
begin
         If Form1.Memo_Config.Lines[24]<>'balloon-no' then exit;
         FormBalloonMatrix.BalloonMessage(time_of_show_msec,msg_title,msg_text,font_size);
         Application.ProcessMessages;
end;

procedure TForm1.CheckFiles;
//проверяет наличие необходимых программе файлов
var
    str:string;
begin
    //критичные файлы
    str:=message49;
    If not FileExists(MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.before') then str:=str+MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.before, ';
    If not FileExists(MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.after') then str:=str+MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.after, ';
    If Form1.Memo_Config.Lines[24]='balloon-no' then If not FileExists(UsrBinDir+'balloon') then str:=str+UsrBinDir+'balloon, ';
    If str<>message49 then
                     begin
                          Form1.Timer1.Enabled:=False;
                          Form1.Timer2.Enabled:=False;
                          Form1.Hide;
                          Form1.TrayIcon1.Hide;
                          str:=LeftStr(str,Length(str)-2);
                          Form3.MyMessageBox(message0,str,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          Shell('rm -f '+VarRunVpnpptp+ProfileName);
                          halt;
                     end;
    //некритичные файлы
    str:=message48;
    If not FileExists(MyPixmapsDir+'ponoff.png') then str:=str+MyPixmapsDir+'ponoff.png, ';
    If FallbackLang='ru' then If not FileExists(MyLangDir+'ponoff.ru.po') then str:=str+MyLangDir+'ponoff.ru.po, ';
    If FallbackLang='en' then If not FileExists(MyLangDir+'ponoff.en.po') then str:=str+MyLangDir+'ponoff.en.po, ';
    If FallbackLang='uk' then If not FileExists(MyLangDir+'ponoff.uk.po') then str:=str+MyLangDir+'ponoff.uk.po, ';
    If str<>message48 then
                     begin
                          str:=LeftStr(str,Length(str)-2);
                          Form1.TrayIcon1.Show;
                          MySleep(1000);
                          BalloonMessage (4000,message0,str,AFont);
                          Application.ProcessMessages;
                     end;
end;

procedure TForm1.CheckVPN;
//проверяет поднялось ли соединение и на каком точно интерфейсе поднялось
var
  str:string;
begin
  str:='';
  PppIface:='';
  Code_up_ppp:=false;
  If FileExists(VarRunDir+'ppp-'+Form1.Memo_Config.Lines[0]+'.pid') then
                                                                        begin
                                                                             popen (f,'cat '+VarRunDir+'ppp-'+Form1.Memo_Config.Lines[0]+'.pid|grep ppp','R');
                                                                             While not eof(f) do
                                                                                              begin
                                                                                                   Readln (f,str);
                                                                                                   If str<>'' then PppIface:=str;
                                                                                              end;
                                                                             PClose(f);
                                                                             popen (f,'ifconfig |grep '+PppIface,'R');
                                                                             If not eof(f) then If PppIface<>'' then Code_up_ppp:=true;
                                                                             PClose(f);
                                                                      end;
end;

procedure TForm1.ClearEtc_hosts;
//очистка /etc/hosts от старых мешающих записей
var
   Str_Etc_hosts:string;
begin
If FileExists (EtcDir+'hosts') then
    begin
        If not FileExists (EtcDir+'hosts.old') then Shell ('cp -f '+EtcDir+'hosts '+EtcDir+'hosts.old');
        AssignFile (FileEtc_hosts,EtcDir+'hosts');
        reset (FileEtc_hosts);
        While not eof(FileEtc_hosts) do
               begin
                   readln(FileEtc_hosts, Str_Etc_hosts);
                   If not (RightStr(Str_Etc_hosts,Length(Form1.Memo_Config.Lines[1]))=Form1.Memo_Config.Lines[1]) then
                                  Shell('printf "'+Str_Etc_hosts+'\n" >> '+MyTmpDir+'hosts.tmp');
               end;
        closefile (FileEtc_hosts);
        Shell('cp -f '+MyTmpDir+'hosts.tmp '+EtcDir+'hosts');
        Shell('rm -f '+MyTmpDir+'hosts.tmp');
        Shell('chmod 0644 '+EtcDir+'hosts');
    end;
end;

procedure TForm1.MakeDefaultGW;
//определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сетевой интерфейс, на котором настроено VPN
var
  nodefaultgw:boolean;
begin
  nodefaultgw:=false;
  popen (f,SBinDir+'ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39),'R');
  If eof(f) then nodefaultgw:=true;
  PClose(f);
  If nodefaultgw then //исправление default и повторная проверка
                      begin
                          Shell ('route add default gw '+Form1.Memo_Config.Lines[2]+' dev '+Form1.Memo_Config.Lines[3]);
                          nodefaultgw:=false;
                          popen (f,SBinDir+'ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39),'R');
                          If eof(f) then nodefaultgw:=true;
                          PClose(f);
                     end;
  If nodefaultgw then
                     begin
                         If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networking') or (NetServiceStr='networkmanager') then
                                                                                                begin
                                                                                                    AProcess := TAsyncProcess.Create(nil);
                                                                                                    AProcess.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                                                                                                    AProcess.Execute;
                                                                                                    AProcess.Free;
                                                                                                end;
                          Ifdown(Form1.Memo_Config.Lines[3],false);
                          If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep (3000);
                          Ifup(Form1.Memo_Config.Lines[3],false);
                          Ifup('lo',false);
                          If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep (3000);
                     end;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
    i,h:integer;
    link:byte;//1-link ok, 2-no link, 3-none, 4-еще не определено
    str,MtuUsed:string;
    Str_networktest, Str_RemoteIPaddress:string;
    FindRemoteIPaddress:boolean;
    RealPppIface, RealPppIfaceDefault:string;
    none:boolean;
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
  //Проверяем размер файла-лога /var/log/syslog
  If not FlagLengthSyslog then If FileExists(VarLogDir+'syslog') then If FileSize(VarLogDir+'syslog')>1073741824 then // >1 Гб
           begin
               BalloonMessage (4000,message0,message45+' '+message46,AFont);
               Application.ProcessMessages;
           end;
   FlagLengthSyslog:=true;
   //Проверяем размер файла-лога /var/log/vpnlog
   If not FlagLengthVpnlog then If FileExists(VarLogDir+'vpnlog') then If FileSize(VarLogDir+'vpnlog')>1073741824 then // >1 Гб
            begin
                BalloonMessage (4000,message0,message65+' '+message46,AFont);
                Application.ProcessMessages;
            end;
    FlagLengthVpnlog:=true;
//Проверяем поднялось ли соединение
CheckVPN;
If Code_up_ppp then MenuItem6.Enabled:=true else MenuItem6.Enabled:=false;
//проверяем поднялось ли соединение на pppN и если нет, то поднимаем на pppN; переводим pppN в фон
If Memo_Config.Lines[29]='pppnotdefault-yes' then NoInternet:=true;
If Code_up_ppp then
 begin
 RealPppIface:='';
 popen (f,SBinDir+'ip r|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39),'R');
 While not eof(f) do
    begin
        Readln (f,RealPppIface);
    end;
 PClose(f);
 RealPppIfaceDefault:='';
 popen (f,SBinDir+'ip r|grep default|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39),'R');
 While not eof(f) do
    begin
        Readln (f,RealPppIfaceDefault);
    end;
 PClose(f);
 If RealPppIface<>'' then if LeftStr(RealPppIface,3)='ppp' then If RealPppIface<>RealPppIfaceDefault then
                               begin
                                  If Memo_Config.Lines[29]<>'pppnotdefault-yes' then
                                       begin
                                            For h:=1 to CountInterface do
                                                Shell (SBinDir+'route del default');
                                            Shell (SBinDir+'route add default dev '+RealPppIface);
                                       end;
                               end;
  If RealPppIface<>'' then if LeftStr(RealPppIface,3)='ppp' then
                               begin
                                  If Memo_Config.Lines[29]='pppnotdefault-yes' then
                                           begin
                                             For h:=1 to CountInterface do
                                                 Shell (SBinDir+'route del default dev '+RealPppIface);
                                             Shell (SBinDir+'route add default gw '+Memo_config.Lines[2]+' dev '+Memo_config.Lines[3]);
                                             NoInternet:=false;//считаем, что типа при этом есть интернет
                                           end;
                               end;
end;
If Code_up_ppp then If FileExists (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after') then If FileExists (EtcDir+'resolv.conf') then
                       If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after', EtcDir+'resolv.conf') then
                                            Shell ('cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after '+EtcDir+'resolv.conf');
If not Code_up_ppp then If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
//Проверяем используемое mtu
If not Code_up_ppp then FlagMtu:=false;
MtuUsed:='';
If Code_up_ppp then If not FlagMtu then If not FileExists (MyTmpDir+'mtu.checked') then
   begin
     popen (f,'ifconfig '+PppIface+'|grep MTU |awk '+ chr(39)+'{print $6}'+chr(39),'R');
     While not eof(f) do
        begin
          Readln (f,MtuUsed);
        end;
     PClose(f);
     If MtuUsed<>'' then If Length(MtuUsed)>=4 then MtuUsed:=RightStr(MtuUsed,Length(MtuUsed)-4);
     If MtuUsed<>'' then If StrToInt(MtuUsed)>1460 then
        begin
             BalloonMessage (4000,message0,message43+' '+MtuUsed+' '+message44,AFont);
             Shell('touch '+MyTmpDir+'mtu.checked');
             Application.ProcessMessages;
        end;
        FlagMtu:=true;
   end;
//обработка случая когда RemoteIPaddress совпадается с ip-адресом самого vpn-сервера
If Code_up_ppp then If Memo_Config.Lines[46]<>'route-IP-remote-yes' then
               If FileExists(MyLibDir+Memo_Config.Lines[0]+'/hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                      begin
                                         popen (f,'ifconfig '+PppIface+'|grep P-t-P|awk '+chr(39)+'{print $3}'+chr(39),'R');
                                         if not eof(f) then
                                                                                 begin
                                                                                    While not eof(f) do
                                                                                          readln(f, Str_RemoteIPaddress);
                                                                                    RemoteIPaddress:=RightStr(Str_RemoteIPaddress,Length(Str_RemoteIPaddress)-6);
                                                                                    Memo_bindutilshost0.Lines.LoadFromFile(MyLibDir+Memo_Config.Lines[0]+'/hosts');
                                                                                    FindRemoteIPaddress:=false;
                                                                                    For i:=0 to Memo_bindutilshost0.Lines.Count-1 do
                                                                                    If RemoteIPaddress=Memo_bindutilshost0.Lines[i] then FindRemoteIPaddress:=true;
                                                                                    If FindRemoteIPaddress then
                                                                                                          begin
                                                                                                            //обнаружено совпадение RemoteIPaddress с ip-адресом самого vpn-сервера
                                                                                                            Application.ProcessMessages;
                                                                                                            str:=message20;
                                                                                                            BalloonMessage (4000,message0,str,AFont);
                                                                                                            Application.ProcessMessages;
                                                                                                            If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
                                                                                                            //изменение скрипта имя_соединения-ip-up
                                                                                                            If FileExists(EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up') then
                                                                                                                                               Shell ('printf "'+SBinDir+'route add -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up');
                                                                                                            //изменение скрипта имя_соединения-ip-down
                                                                                                            if FileExists(EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down') then
                                                                                                                                                        Shell ('printf "'+SBinDir+'route del -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down');
                                                                                                            Shell('rm -f '+MyLibDir+Memo_Config.Lines[0]+'/hosts');
                                                                                                          end;
                                                                                 end;
                                          PClose(f);
                                      end;
//проверка состояния сетевого интерфейса
link:=4;
If Memo_Config.Lines[6]='mii-tool-no' then link:=1; //отказ от контроля link
If Memo_Config.Lines[7]='reconnect-pptp' then link:=1;
If link=4 then
   begin
     popen (f,SBinDir+'mii-tool '+Memo_Config.Lines[3],'R');
     str:='';
     while not eof(f) do
        readln(f,str);
     If str<>'' then If RightStr(str,7)='link ok' then link:=1;
     If str<>'' then If RightStr(str,7)='no link' then link:=2;
     If str='' then link:=3;
     PClose(f);
   end;
If link=1 then If NoInternet then MakeDefaultGW;
If not Code_up_ppp then
       If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
             If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                                 Shell ('cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
//проверка технической возможности поднятия соединения
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[30]<>'none' then
                            begin //тест dns1-сервера
                            Application.ProcessMessages;
                            popen (f,'ping -c1 '+Memo_config.Lines[30]+'|grep '+chr(39)+'1 received'+chr(39),'R');
                            Application.ProcessMessages;
                            If eof(f) then
                                                              begin
                                                                   NoPingDNS1:=true;
                                                                   BalloonMessage (4000,message0,message23,AFont);
                                                              end;
                            PClose(f);
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[31]<>'none' then
                            begin //тест dns2-сервера
                                 Application.ProcessMessages;
                                 popen (f,'ping -c1 '+Memo_config.Lines[31]+'|grep '+chr(39)+'1 received'+chr(39),'R');
                                 Application.ProcessMessages;
                                 If eof(f) then
                                                                   begin
                                                                        NoPingDNS2:=true;
                                                                        BalloonMessage (4000,message0,message24,AFont);
                                                                   end;
                                 PClose(f);
                            end;
If not Code_up_ppp then If ((Memo_Config.Lines[23]='networktest-yes') and (BindUtils)) or ((Memo_Config.Lines[23]='networktest-yes') and (Memo_config.Lines[22]='routevpnauto-no')) then
                            begin //тест vpn-сервера
                                 Application.ProcessMessages;
                                 popen (f,'ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39),'R');
                                 Application.ProcessMessages;
                                 If eof(f) then NoPingIPS:=true;
                                 PClose(f);
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then
                            begin //тест шлюза локальной сети
                                 Application.ProcessMessages;
                                 popen (f,'ping -c1 '+Memo_config.Lines[2]+'|grep '+chr(39)+'1 received'+chr(39),'R');
                                 Application.ProcessMessages;
                                 If eof(f) then NoPingGW:=true;
                                 PClose(f);
                            end;
If not Code_up_ppp then DhclientStart:=false;
If not Code_up_ppp then If link=1 then If Memo_Config.Lines[9]='dhcp-route-yes' then //старт dhclient
                           begin
                              AProcessDhclient := TAsyncProcess.Create(nil);
                              AProcessDhclient.CommandLine :='dhclient '+Memo_Config.Lines[3];
                              Application.ProcessMessages;
                              If not NoPingIPS then If not NoDNS then If not NoPingGW then
                              begin
                                For h:=1 to CountInterface do
                                                            Shell ('route del default');
                                Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
                                If not DhclientStart then
                                                      begin
                                                           if fedora then Shell('killall dhclient');
                                                          AProcessDhclient.Execute;
                                                           Mysleep(StrToInt(Memo_Config.Lines[5]) div 3);
                                                           Application.ProcessMessages;
                                                      end;
                                DhclientStart:=true;
                              end;
                              If link=1 then If NoInternet then //проверка поднялся ли интерфейс после dhclient
                              begin
                                   none:=false;
                                   popen (f,SBinDir+'ip r|grep '+Memo_Config.Lines[3],'R');
                                   If eof(f) then none:=true;
                                   PClose(f);
                                   if none then
                                      begin
                                         Mysleep(StrToInt(Memo_Config.Lines[5]) div 3);
                                         none:=false;
                                         popen (f,SBinDir+'ip r|grep '+Memo_Config.Lines[3],'R');
                                         If eof(f) then none:=true;
                                         PClose(f);
                                         if none then
                                                 begin
                                                      Ifup(Form1.Memo_Config.Lines[3],false);
                                                      DhclientStart:=false;
                                                 end;
                                      end;
                              end;
                           end;
  //определение и сохранение всех актуальных в данный момент ip-адресов vpn-сервера с занесением маршрутов везде
  If not FileExists(MyLibDir+Memo_Config.Lines[0]+'/hosts') then NewIPS:=false;
  if BindUtils then Str:='host '+Memo_config.Lines[1]+'|grep address|grep '+Memo_config.Lines[1]+'|awk '+ chr(39)+'{print $4}'+chr(39);
  if not BindUtils then Str:='ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39);
  If not Code_up_ppp then If link=1 then
               If FileExists(MyLibDir+Memo_Config.Lines[0]+'/hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                       if Memo_config.Lines[21]='IPS-no' then
                                     begin
                                             Application.ProcessMessages;
                                             popen (f,Str,'R');
                                             Application.ProcessMessages;
                                             If eof(f) then If not BindUtils then
                                                                                NoPingIPS:=true;
                                             If eof(f) then If BindUtils then
                                                                            NoDNS:=true;
                                              Memo_bindutilshost0.Lines.LoadFromFile(MyLibDir+Memo_Config.Lines[0]+'/hosts');
                                              While not eof(f) do
                                              begin
                                                  readln(f, Str_networktest);
                                                  NewIPS:=true;
                                                  For i:=0 to Memo_bindutilshost0.Lines.Count-1 do
                                                  begin
                                                      Str_networktest:=DeleteSym('(',Str_networktest);
                                                      Str_networktest:=DeleteSym(')',Str_networktest);
                                                      If Str_networktest <>'' then
                                                                      If Str_networktest=Memo_bindutilshost0.Lines[i] then
                                                                                                                      NewIPS:=false;
                                                  end;
                                                  If Memo_Config.Lines[41]='etc-hosts-yes' then Shell ('printf "'+Str_networktest+' '+Memo_config.Lines[1]+'\n" >> '+EtcDir+'hosts');
                                                  If NewIPS then
                                                     begin //определился новый, неизвестный ранее ip-адрес vpn-сервера
                                                        Shell('printf "'+Str_networktest+'\n'+'" >> '+MyLibDir+Memo_Config.Lines[0]+'/hosts');
                                                        Shell (SBinDir+'route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]);
                                                        //изменение скрипта имя_соединения-ip-up
                                                        If FileExists(EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up') then
                                                                                        Shell ('printf "'+SBinDir+'route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up');
                                                        //изменение скрипта имя_соединения-ip-down
                                                        if FileExists(EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down') then
                                                                                        Shell ('printf "'+SBinDir+'route del -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down');
                                                    end;
                                              end;
                                           PClose(f);
                                    end;
If Code_up_ppp then If link<>1 then //когда связи по факту нет, но в NetApplet и в ifconfig ppp0 числится, а pppd продолжает сидеть в процессах
                               begin
                                 MenuItem2Click(Self);
                                 If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
                                 exit;
                               end;

If Code_up_ppp then Timer1.Interval:=StrToInt64(Memo_Config.Lines[4]) else Timer1.Interval:=StrToInt64(Memo_Config.Lines[5]);
If Code_up_ppp then If Timer1.Interval=0 then Timer1.Interval:=1000;

If not Code_up_ppp then If link=3 then
                                  begin
                                   MenuItem2Click(Self);
                                   If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                TrayIcon1.Hide;
                                                                Shell ('killall balloon');
                                                                Form3.MyMessageBox(message0,message9,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                MenuItem2Click(Self);
                                                                Shell('rm -f '+VarRunVpnpptp+ProfileName);
                                                                halt;
                                                              end;
                                  end;
If not Code_up_ppp then If link=2 then
                                  begin
                                   MenuItem2Click(Self);
                                   If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                TrayIcon1.Hide;
                                                                Shell ('killall balloon');
                                                                Form3.MyMessageBox(message0,message9,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                MenuItem2Click(Self);
                                                                Shell('rm -f '+VarRunVpnpptp+ProfileName);
                                                                halt;
                                                              end;
                                  end;
If not Code_up_ppp then If ((link=2) or (link=3)) then
                           begin
                                  Application.ProcessMessages;
                                  If NoPingDNS1 then BalloonMessage (4000,message0,message23,AFont);
                                  If NoPingDNS2 then BalloonMessage (4000,message0,message24,AFont);
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
                                  If (NoPingIPS) or (NoPingGW) or (NoDNS) then BalloonMessage (4000,message0,str,AFont);
                           end;
If not Code_up_ppp then If link=1 then
                           begin
                                  Form1.MenuItem2Click(Self);//на всякий случай отключаем вдруг созданное ppp
                                  Application.ProcessMessages;
                                  If NoPingDNS1 then BalloonMessage (4000,message0,message23,AFont);
                                  If NoPingDNS2 then BalloonMessage (4000,message0,message24,AFont);
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
                                  BalloonMessage (4000,message0,str,AFont);
                                  Application.ProcessMessages;
                                  If NoPingIPS or NoDNS then
                                                   begin
                                                      For h:=1 to CountInterface do
                                                                                Shell ('route del default');
                                                      Ifdown(Memo_Config.Lines[3],false);
                                                      Ifup(Form1.Memo_Config.Lines[3],false);
                                                   end;
                                  If not NoPingIPS then If not NoDNS then If not NoPingGW then
                                                   begin
                                                      If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
                                                           If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                                                               Shell ('cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
                                                      TrafficRX:=0;
                                                      TrafficTX:=0;
                                                      RXbyte0:='0';
                                                      TXbyte0:='0';
                                                      RXbyte1:='0';
                                                      TXbyte1:='0';
                                                      ObnullRX:=0;
                                                      ObnullTX:=0;
                                                      DoSpeedCount:=false;
                                                      Shell ('rm -f '+MyTmpDir+'ObnullRX');
                                                      Shell ('rm -f '+MyTmpDir+'ObnullTX');
                                                      If not FileExists(MyTmpDir+'DateStart') then DateStart:=0;
                                                      If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo',false);
                                                      For h:=1 to CountInterface do
                                                                          Shell ('route del default');
                                                      Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
                                                      DoubleRunPonoff:=false;
                                                      If Memo_Config.Lines[39]='pptp' then
                                                                                    Shell (UsrSBinDir+'pppd call '+Memo_Config.Lines[0]);
                                                      If Memo_Config.Lines[39]='l2tp' then
                                                                                          begin
                                                                                              //проверка xl2tpd в процессах
                                                                                              popen(f,'ps -A | grep xl2tpd','R');
                                                                                              If eof(f) then
                                                                                                            begin
                                                                                                                 Shell (ServiceCommand+'xl2tpd stop');
                                                                                                                 AProcess := TAsyncProcess.Create(nil);
                                                                                                                 AProcess.CommandLine :=ServiceCommand+'xl2tpd start';
                                                                                                                 AProcess.Execute;
                                                                                                                 while AProcess.Running do
                                                                                                                                         MySleep(30);
                                                                                                                 AProcess.Free;
                                                                                                             end;
                                                                                               PClose(f);
                                                                                               Shell ('echo "c '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
                                                                                          end;
                                                       If Memo_Config.Lines[39]='openl2tp' then Shell('sh '+MyLibDir+Memo_Config.Lines[0]+'/openl2tp-start');
                                                   end;
                                  If Memo_Config.Lines[9]='dhcp-route-yes' then
                                                begin
                                                    AProcessDhclient.WaitOnExit;
                                                    AProcessDhclient.Free;
                                                end;
                           end;
Application.ProcessMessages;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  link:byte; //1-link ok, 2-no link, 3-none
  i,j,h,zero:integer;
  str,stri,StrObnull:string;
  Apid:tpid;
  FileObnull:textfile;
begin
  if FileSize(MyLibDir+'profiles')=0 then Shell ('rm -f '+MyLibDir+'profiles');
  if FileSize(MyLibDir+'default/default')=0 then Shell ('rm -f '+MyLibDir+'default/default');
  If FileExists (SBinDir+'service') or FileExists (UsrSBinDir+'service') then ServiceCommand:='service ' else ServiceCommand:=EtcInitDDir;
  DoubleRunPonoff:=false;
  ubuntu:=false;
  debian:=false;
  fedora:=false;
  suse:=false;
  mandriva:=false;
  Application.CreateForm(TForm3, Form3);
  Application.ShowMainForm:=false;
  Application.Minimize;
  If FileExists (MyPixmapsDir+'ponoff.png') then Image1.Picture.LoadFromFile(MyPixmapsDir+'ponoff.png');
  Panel1.Caption:=message37+' '+message38;
  Form1.Height:=152;
  Form1.Width:=670;
  Form1.Font.Size:=AFont;
  RXbyte0:='0';
  TXbyte0:='0';
  RXbyte1:='0';
  TXbyte1:='0';
  TrafficRX:=0;
  TrafficTX:=0;
  StrObnull:='';
  LimitRX:=0;
  LimitTX:=0;
  DoSpeedCount:=false;
  If FileExists(MyTmpDir+'ObnullRX') then
                                     begin
                                          AssignFile (FileObnull,MyTmpDir+'ObnullRX');
                                          reset (FileObnull);
                                          While not eof(FileObnull) do
                                                     readln(FileObnull, StrObnull);
                                          closefile (FileObnull);
                                     end;
  If StrObnull<>'' then ObnullRX:=StrToInt(StrObnull) else ObnullRX:=0;
  StrObnull:='';
  If FileExists(MyTmpDir+'ObnullTX') then
                                     begin
                                          AssignFile (FileObnull,MyTmpDir+'ObnullTX');
                                          reset (FileObnull);
                                          While not eof(FileObnull) do
                                                     readln(FileObnull, StrObnull);
                                          closefile (FileObnull);
                                     end;
  If StrObnull<>'' then ObnullTX:=StrToInt(StrObnull) else ObnullTX:=0;
  RXSpeed:='0b/s';
  TXSpeed:='0b/s';
  Net_MonitorRun:=false;
  CountInterface:=1;
  FlagMtu:=false;
  FlagLengthSyslog:=false;
  FlagLengthVpnlog:=false;
  Form1.Visible:=false;
  Form1.WindowState:=wsMinimized;
  Form1.Hide;
  NoInternet:=true;
  DhclientStart:=false;
  RemoteIPaddress:='none';
  If FileExists (UsrBinDir+'host') then BindUtils:=true else BindUtils:=false;
  MenuItem3.Caption:=message10;
  MenuItem4.Caption:=message11;
  MenuItem5.Caption:=message39;
  MenuItem6.Caption:=message61;
  TrayIcon1.BalloonTitle:=message0;
  If Screen.Height<440 then AFont:=6;
  If Screen.Height<=480 then AFont:=6;
  If Screen.Height<550 then If not (Screen.Height<=480) then AFont:=6;
  If Screen.Height>550 then AFont:=8;
  If Screen.Height>1000 then AFont:=10;
//проверка соединения
str:=ProfileName;
str:=UTF8UpperCase(str);
If str='DEFAULT' then
                           begin
                              Timer1.Enabled:=False;
                              Timer2.Enabled:=False;
                              Form1.Hide;
                              TrayIcon1.Hide;
                              Form3.MyMessageBox(message0,message56+' '+ProfileName+' '+message57,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                              Shell('rm -f '+VarRunVpnpptp+ProfileName);
                              halt;
                           end;
  If ProfileName<>'' then if not DirectoryExists(MyLibDir+ProfileName) then
                                                   begin
                                                     Timer1.Enabled:=False;
                                                     Timer2.Enabled:=False;
                                                     Form1.Hide;
                                                     TrayIcon1.Hide;
                                                     Form3.MyMessageBox(message0,message50+' '+ProfileName+'. ','','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                     Shell('rm -f '+VarRunVpnpptp+ProfileName);
                                                     halt;
                                                   end;
  If ProfileName='' then if FileExists(MyLibDir+'profiles') then if not FileExists(MyLibDir+'default/default') then
                                                            begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                Form1.Hide;
                                                                TrayIcon1.Hide;
                                                                Form3.MyMessageBox(message0,message53+' '+message54+' '+message55,'',message33,message36,MyPixmapsDir+'ponoff.png',false,true,true,AFont,Form1.Icon,true,MyLibDir);
                                                                If Form3.Tag=2 then If Form3.ComboBoxProfile.Text<>'' then
                                                                                                  begin
                                                                                                        ProfileName:=Form3.ComboBoxProfile.Text;
                                                                                                        Shell ('mkdir -p '+MyLibDir+'default');
                                                                                                        Shell ('echo "'+ProfileName+'" > '+MyLibDir+'default/default');
                                                                                                  end;
                                                                If (Form3.Tag=0) or (Form3.Tag=3) or (Form3.ComboBoxProfile.Text='') then
                                                                                                                                     begin
                                                                                                                                          Shell('rm -f '+VarRunVpnpptp+ProfileName);
                                                                                                                                          halt;
                                                                                                                                     end;
                                                                Timer1.Enabled:=true;
                                                                Timer2.Enabled:=true;
                                                                TrayIcon1.Show;
                                                            end;
  //проверка ponoff в процессах root, исключение запуска под иными пользователями
   Apid:=FpGetpid;
   popen (f,'ps -u root |grep ponoff| grep '+IntToStr(Apid),'R');
   If eof(f) then
                   begin
                      //запуск не под root
                      Timer1.Enabled:=False;
                      Timer2.Enabled:=False;
                      Form1.Hide;
                      TrayIcon1.Hide;
                      Form3.MyMessageBox(message0,message1+' '+message25,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                      PClose(f);
                      Shell('rm -f '+VarRunVpnpptp+ProfileName);
                      halt;
                   end;
  PClose(f);
  If not FileExists(MyTmpDir) then Shell ('mkdir -p '+MyTmpDir);
  //обеспечение совместимости старого config с новым
  If FileExists(MyLibDir+ProfileName+'/config') then
     begin
        Memo_config.Lines.LoadFromFile(MyLibDir+ProfileName+'/config');
        If Memo_config.Lines.Count<Config_n then
                                            begin
                                               for i:=Memo_config.Lines.Count to Config_n do
                                                  Shell('printf "none\n" >> '+MyLibDir+ProfileName+'/config');
                                            end;
     end;
  //обеспечение совместимости старого general.conf с новым
  If FileExists(MyLibDir+'general.conf') then
          begin
             Memo_General_conf.Lines.LoadFromFile(MyLibDir+'general.conf');
             If Memo_General_conf.Lines.Count<General_conf_n then
                                                 begin
                                                    for i:=Memo_General_conf.Lines.Count to General_conf_n do
                                                       Shell('printf "none\n" >> '+MyLibDir+'general.conf');
                                                 end;
          end;
 If FileExists(MyLibDir+'general.conf') then begin Memo_General_conf.Lines.LoadFromFile(MyLibDir+'general.conf');end
          else
           begin
            Timer1.Enabled:=False;
            Timer2.Enabled:=False;
            Form1.Hide;
            TrayIcon1.Hide;
            Form3.MyMessageBox(message0,message3+' '+message26,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
            Shell('rm -f '+VarRunVpnpptp+ProfileName);
            halt;
           end;
  If FileExists(MyLibDir+ProfileName+'/config') then begin Memo_Config.Lines.LoadFromFile(MyLibDir+ProfileName+'/config');end
  else
   begin
    Timer1.Enabled:=False;
    Timer2.Enabled:=False;
    Form1.Hide;
    TrayIcon1.Hide;
    Form3.MyMessageBox(message0,message3+' '+message26,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
    Shell('rm -f '+VarRunVpnpptp+ProfileName);
    halt;
   end;
   if Memo_General_conf.Lines[3]<>'none' then AFont:=StrToInt(Memo_General_conf.Lines[3]);
   If Memo_General_conf.Lines[4]='ubuntu' then ubuntu:=true;
   If Memo_General_conf.Lines[4]='debian' then debian:=true;
   If Memo_General_conf.Lines[4]='fedora' then fedora:=true;
   If Memo_General_conf.Lines[4]='suse' then suse:=true;
   If Memo_General_conf.Lines[4]='mandriva' then mandriva:=true;
   Form1.Font.Size:=AFont;
  //определение управляющего сетью сервиса
  NetServiceStr:='none';
  If FileExists (EtcInitDDir+'network') then NetServiceStr:='network';
  If FileExists (EtcInitDDir+'networking') then NetServiceStr:='networking';
  If FileExists (EtcInitDDir+'network-manager') then
                                                    begin
                                                       popen (f,'ps -e |grep NetworkManager','R');
                                                       if not eof(f) then NetServiceStr:='NetworkManager';
                                                       PClose(f);
                                                    end;
  If FileExists (EtcInitDDir+'NetworkManager') then
                                                    begin
                                                       popen (f,'ps -e |grep NetworkManager','R');
                                                       if not eof(f) then NetServiceStr:='NetworkManager';
                                                       PClose(f);
                                                    end;
  If FileExists (EtcInitDDir+'networkmanager') then
                                                    begin
                                                       popen (f,'ps -e |grep networkmanager','R');
                                                       if not eof(f) then NetServiceStr:='networkmanager';
                                                       PClose(f);
                                                    end;
  If NetServiceStr='none' then
                            begin
                               Form1.Timer1.Enabled:=False;
                               Form1.Timer2.Enabled:=False;
                               Form1.Hide;
                               Form1.TrayIcon1.Hide;
                               Form3.MyMessageBox(message0,message2,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                               Form1.Timer1.Enabled:=true;
                               Form1.Timer2.Enabled:=true;
                               Form1.TrayIcon1.Show;
                               Application.ProcessMessages;
                            end;
//проверка ponoff в процессах root, обработка двойного запуска программы
popen (f,'ps -u root | grep ponoff | awk '+chr(39)+'{print $4}'+chr(39),'R');
i:=0;
while not eof(f) do
begin
    readln(f,str);
    i:=i+1;
end;
PClose(f);
If i=1 then
     begin
        Shell('rm -rf '+VarRunVpnpptp);
        Shell('mkdir -p '+VarRunVpnpptp);
        Shell ('echo "'+ProfileName+'" > '+VarRunVpnpptp+ProfileName);
     end;
If i>1 then
              begin
                  DoubleRunPonoff:=true;
                  Apid:=FpGetpid;
                  popen(f1,'cat '+VarRunVpnpptp+'*','R');
                  j:=0;
                  stri:='';
                  while not eof(f1) do
                    begin
                       readln(f1,str);
                       if str<>ProfileName then stri:=stri+str+', ';
                       j:=j+1;
                    end;
                    if stri<>'' then stri:=LeftStr(stri,Length(stri)-2);
                  PClose(f1);
                  if j>1 then
                             begin
                                Timer1.Enabled:=False;
                                Timer2.Enabled:=False;
                                Form1.Hide;
                                TrayIcon1.Hide;
                                Form3.MyMessageBox(message0,message51+' '+stri+'. '+message52,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                Shell('rm -f '+VarRunVpnpptp+ProfileName);
                                halt;
                             end;
               popen(f,'ps -e|grep ponoff|awk '+chr(39)+'{print$1}'+chr(39),'R');
               str:='';
                    While not eof(f) do
                        begin
                            Readln (f,str);
                            If str<>'' then If str<>IntToStr(Apid) then FpKill(StrToInt(str),9);
                        end;
               PClose(f);
            end;
//Проверяем поднялось ли соединение
CheckVPN;
If Code_up_ppp then MenuItem6.Enabled:=true else MenuItem6.Enabled:=false;
If Code_up_ppp then If FileExists (MyDataDir+'on.ico') then If FileExists (MyDataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'on.ico');
If not Code_up_ppp then If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
Application.ProcessMessages;
TrayIcon1.Show;
Application.ProcessMessages;
CheckFiles;//проверка наличия необходимых программе файлов
If not FileExists (MyTmpDir+'DateStart') then DateStart:=0 else
                                       begin
                                            AssignFile (FileDateStart,MyTmpDir+'DateStart');
                                            reset (FileDateStart);
                                            While not eof(FileDateStart) do
                                            begin
                                                 readln(FileDateStart, str);
                                            end;
                                            closefile (FileDateStart);
                                            If str<>'' then DateStart:=StrToInt(str) else DateStart:=0;
                                       end;
//учитывание особенностей openSUSE
If suse then
        begin
             popen(f,'/sbin/ip r|grep dsl','R');
             If not eof(f) then
                                         begin
                                           Timer1.Enabled:=False;
                                           Timer2.Enabled:=False;
                                           Form1.Hide;
                                           TrayIcon1.Hide;
                                           Form3.MyMessageBox(message0,message41,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                           PClose(f);
                                           Shell('rm -f '+VarRunVpnpptp+ProfileName);
                                           halt;
                                         end;
             PClose(f);
        end;
   If Memo_Config.Lines[23]='networktest-no' then NoInternet:=false;
   //проверка состояния сетевого интерфейса
   popen (f,SBinDir+'mii-tool '+Memo_Config.Lines[3],'R');
   str:='';
   while not eof(f) do
        readln(f,str);
   If str<>'' then If RightStr(str,7)='link ok' then link:=1;
   If str<>'' then If RightStr(str,7)='no link' then link:=2;
   If str='' then link:=3;
   PClose(f);
   //определение пропускной способности сети
   zero:=0;
   popen (f,SBinDir+'mii-tool '+Memo_Config.Lines[3]+'|awk '+chr(39)+'{print $3}'+chr(39),'R');
   str:='';
   while not eof(f) do
        readln(f,str);
   if str<>'' then
                begin
                     for i:=1 to Length(str) do
                         if str[i]='0' then zero:=zero+1;
                end;
   PClose(f);
   if zero=0 then MaxSpeed:=0; // пропускная способность сети не определилась
   if zero=1 then MaxSpeed:=(10*1024*1024) div 8; //10 Мбит/с
   if zero=2 then MaxSpeed:=(100*1024*1024) div 8; //100 Мбит/с
   if zero=3 then MaxSpeed:=(1000*1024*1024) div 8; //1000 Мбит/с
   If Memo_Config.Lines[6]='mii-tool-no' then link:=1; //отказ от контроля link
   If Memo_Config.Lines[7]='reconnect-pptp' then link:=1;
   If link=3 then //попытка поднять требуемый интерфейс
                begin
                   AProcess := TAsyncProcess.Create(nil);
                   AProcess.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                   AProcess.Execute;
                   AProcess.Free;
                   For h:=1 to CountInterface do
                                          Shell ('route del default');
                   Ifdown(Memo_Config.Lines[3],false);
                   Mysleep(3000);
                   Ifup(Memo_Config.Lines[3],false);
                   //повторная проверка состояния сетевого интерфейса
                   If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep(3000);
                   popen (f,SBinDir+'mii-tool '+Memo_Config.Lines[3],'R');
                   str:='';
                   while not eof(f) do
                        readln(f,str);
                   If str<>'' then If RightStr(str,7)='link ok' then link:=1;
                   If str<>'' then If RightStr(str,7)='no link' then link:=2;
                   If str='' then link:=3;
                   PClose(f);
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
                 Form3.MyMessageBox(message0,message4+' '+message47,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                 Shell('rm -f '+VarRunVpnpptp+ProfileName);
                 halt;
                end;
   if link=2 then
                begin
                 Form3.MyMessageBox(message0,message5,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                 Timer1.Enabled:=False;
                 Timer2.Enabled:=False;
                 TrayIcon1.Hide;
                 Shell('rm -f '+VarRunVpnpptp+ProfileName);
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
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Form1.Hide;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
 //просто убивает pppd и других демонов и удаляет временные файлы
var
   str:string;
begin
 If DoubleRunPonoff then exit;
//проверка наличия в процессах демона pppd
 popen(f,'ps -u root | grep pppd | awk '+chr(39)+'{print $4}'+chr(39),'R');
 Application.ProcessMessages;
 str:='';
 while not eof(f) do
   begin
     readln(f,str);
     If str<>'' then If (LeftStr(str,4)='pppd') then
                                        begin
                                             If Memo_Config.Lines[39]<>'openl2tp' then If FileExists(MyLibDir+'default/openl2tp-stop') then Shell('sh '+MyLibDir+'default/openl2tp-stop');
                                             Shell('killall pppd');
                                             If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then
                                                                                  begin
                                                                                       AProcess := TAsyncProcess.Create(nil);
                                                                                       AProcess.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                                                                                       AProcess.Execute;
                                                                                       AProcess.Free;
                                                                                       Mysleep(3000);
                                                                                  end;
                                        end;
   end;
 PClose(f);
 If Memo_Config.Lines[39]='pptp' then
                                 begin
                                      Shell (ServiceCommand+'xl2tpd stop');
                                      Shell ('killall xl2tpd');
                                 end;
 If Memo_Config.Lines[39]='openl2tp' then Shell('sh '+MyLibDir+Memo_Config.Lines[0]+'/openl2tp-stop');
 Shell('killall openl2tpd');
 Shell('killall openl2tp');
 Shell('killall l2tpd');
 Application.ProcessMessages;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
//выход без аварии
var h:integer;
begin
 DoubleRunPonoff:=false;
 Timer1.Enabled:=False;
 Timer2.Enabled:=False;
 KillZombieNet_Monitor;
 Shell ('killall net_monitor');
 Shell ('killall balloon');
 If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  MenuItem2Click(Self);
  If Memo_Config.Lines[39]='l2tp' then Shell ('echo "d '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
  If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
  Application.ProcessMessages;
  For h:=1 to CountInterface do
              Shell ('route del default');
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo',false);
  Shell('rm -f '+MyTmpDir+'xl2tpd.conf');
  If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
         If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                         Shell ('cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
  Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
  Shell ('rm -f '+MyTmpDir+'DateStart');
  Shell ('rm -f '+MyTmpDir+'ObnullRX');
  Shell ('rm -f '+MyTmpDir+'ObnullTX');
  Shell ('rm -f '+MyTmpDir+'mtu.checked');
  MakeDefaultGW;
  Shell('rm -f '+VarRunVpnpptp+ProfileName);
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
  KillZombieNet_Monitor;
  Shell ('killall net_monitor');
  Shell ('killall balloon');
  If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
          If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                            Shell ('cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
  MenuItem2Click(Self);
  If Memo_Config.Lines[39]='l2tp' then Shell ('echo "d '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
  If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
  Application.ProcessMessages;
  For i:=0 to 9 do
      begin
        Ifdown('eth'+IntToStr(i),true);
        Ifdown('wlan'+IntToStr(i),true);
        Ifdown('br'+IntToStr(i),true);
        Ifdown('em'+IntToStr(i),true);
      end;
  Shell (ServiceCommand+NetServiceStr+' restart'); // организация конкурса интерфейсов
  If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep(3000);
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo',true);
  Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
 //определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сеть своим алгоритмом
  popen(f,SBinDir+'ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39),'R');
  If eof(f) then
     begin
         For i:=0 to 9 do
             begin
              Ifdown('eth'+IntToStr(i),true);
              Ifdown('wlan'+IntToStr(i),true);
              Ifdown('br'+IntToStr(i),true);
              Ifdown('em'+IntToStr(i),true);
             end;
            Shell (ServiceCommand+NetServiceStr+' restart');
            For i:=0 to 9 do
                 begin
                    Ifup('eth'+IntToStr(i),true);
                    Ifup('wlan'+IntToStr(i),true);
                    Ifup('br'+IntToStr(i),true);
                    Ifup('em'+IntToStr(i),true);
                 end;
           Ifup('lo',true);
     end;
  PClose(f);
  Shell ('rm -f '+MyTmpDir+'DateStart');
  Shell ('rm -f '+MyTmpDir+'ObnullRX');
  Shell ('rm -f '+MyTmpDir+'ObnullTX');
  Shell ('rm -f '+MyTmpDir+'mtu.checked');
  Shell ('rm -f '+VarRunVpnpptp+ProfileName);
  halt;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  If Code_up_ppp then If not Net_MonitorRun then
             begin
                AProcessNet_Monitor := TAsyncProcess.Create(nil);
                AProcessNet_Monitor.CommandLine := UsrBinDir+'net_monitor -i '+PppIface;
                AProcessNet_Monitor.Execute;
                Net_MonitorRun:=true;
             end;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  If Form3.Visible then exit;
  Form3.MyMessageBox(message0+' '+message62,'','','',message33,'',false,false,true,AFont,Form1.Icon,false,MyLibDir);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  MenuItem1Click(Self);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
//индикация иконки в трее, балуны и тест интернета
var
  Str:string;
  TV : timeval;
  DNS3,DNS4:string;
begin
  If not FileExists (VarRunVpnpptp+ProfileName) then Shell ('echo "'+ProfileName+'" > '+VarRunVpnpptp+ProfileName);
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  If Code_up_ppp then MenuItem6.Enabled:=true else MenuItem6.Enabled:=false;
  KillZombieNet_Monitor;
  //определяем скорость, время
  popen (f,'ifconfig '+PppIface+'|grep RX|grep bytes|awk '+chr(39)+'{print $2}'+chr(39),'R');
  RXbyte1:='0';
  While not eof(f) do
     begin
       Readln (f,RXbyte1);
     end;
  PClose(f);
  If RXbyte1='' then RXbyte1:='0';
  popen (f,'ifconfig '+PppIface+'|grep TX|grep bytes|awk '+chr(39)+'{print $6}'+chr(39),'R');
  TXbyte1:='0';
  While not eof(f) do
     begin
       Readln (f,TXbyte1);
     end;
  PClose(f);
  If TXbyte1='' then TXbyte1:='0';
  If RXbyte1<>'0' then Delete(RXbyte1,1,6);
  If TXbyte1<>'0' then Delete(TXbyte1,1,6);
  If MaxSpeed<>0 then If Code_up_ppp then
          begin
                if StrToInt64(RXbyte1)-StrToInt64(RXbyte0)>MaxSpeed then
                                               begin
                                                    LimitRX:=LimitRX+1;
                                                    if LimitRX=3 then
                                                                     begin
                                                                          BalloonMessage(4000,message0,message64,AFont);
                                                                          LimitRX:=0;
                                                                     end;
                                               end else LimitRX:=0;
                 if StrToInt64(TXbyte1)-StrToInt64(TXbyte0)>MaxSpeed then
                                               begin
                                                    LimitTX:=LimitTX+1;
                                                    if LimitTX=3 then
                                                                     begin
                                                                          BalloonMessage(4000,message0,message63,AFont);
                                                                          LimitTX:=0;
                                                                     end;
                                               end else LimitTX:=0;
          end;
  If Code_up_ppp then
        begin
          TrafficRX:=StrToInt64(RXbyte1);
          If StrToInt64(RXbyte1)-StrToInt64(RXbyte0)<0 then
                                                       begin
                                                            ObnullRX:=ObnullRX+1;
                                                            Shell ('printf "'+IntToStr(ObnullRX)+'\n" > '+MyTmpDir+'ObnullRX');
                                                       end;
          TrafficTX:=StrToInt64(TXbyte1);
          If StrToInt64(TXbyte1)-StrToInt64(TXbyte0)<0 then
                                                       begin
                                                            ObnullTX:=ObnullTX+1;
                                                            Shell ('printf "'+IntToStr(ObnullTX)+'\n" > '+MyTmpDir+'ObnullTX');
                                                       end;
        end else
                begin
                    TrafficRX:=0;
                    TrafficTX:=0;
                    RXbyte0:='0';
                    TXbyte0:='0';
                    RXbyte1:='0';
                    TXbyte1:='0';
                    ObnullRX:=0;
                    ObnullTX:=0;
                    DoSpeedCount:=false;
                    Shell ('rm -f '+MyTmpDir+'ObnullRX');
                    Shell ('rm -f '+MyTmpDir+'ObnullTX');
                end;
  If (StrToInt64(RXbyte1)-StrToInt64(RXbyte0))>=0 then RXSpeed:=IntToStr(StrToInt64(RXbyte1)-StrToInt64(RXbyte0)) else RXSpeed:='-';
  If RXSpeed='' then RXSpeed:='0';
  If (StrToInt64(TXbyte1)-StrToInt64(TXbyte0))>=0 then TXSpeed:=IntToStr(StrToInt64(TXbyte1)-StrToInt64(TXbyte0)) else TXSpeed:='-';
  If TXSpeed='' then TXSpeed:='0';
  RXbyte0:=RXbyte1;
  TXbyte0:=TXbyte1;
  If not DoSpeedCount then
                      begin
                         RXSpeed:='-';
                         TXSpeed:='-';
                      end;
  DoSpeedCount:=true;
  If RXSpeed<>'-' then
     begin
        If StrToInt64(RXSpeed)>1048576 then RXSpeed:=IntToStr(StrToInt64(RXSpeed) div 1048576)+' MiB/s'
              else If StrToInt64(RXSpeed)>1024 then RXSpeed:=IntToStr(StrToInt64(RXSpeed) div 1024)+' KiB/s'
                                                                             else RXSpeed:=RXSpeed+' b/s';
     end;
  If TXSpeed<>'-' then
     begin
        If StrToInt64(TXSpeed)>1048576 then TXSpeed:=IntToStr(StrToInt64(TXSpeed) div 1048576)+' MiB/s'
              else If StrToInt64(TXSpeed)>1024 then TXSpeed:=IntToStr(StrToInt64(TXSpeed) div 1024)+' KiB/s'
                                                                             else TXSpeed:=TXSpeed+' b/s';
     end;
  If Code_up_ppp then If DateStart=0 then
                      begin
                           fpGettimeofday(@TV,nil);
                           DateStart:=TV.tv_sec;
                           If not FileExists (MyTmpDir+'DateStart') then Shell ('printf "'+IntToStr(DateStart)+'\n" > '+MyTmpDir+'DateStart');
                      end;
  If Code_up_ppp then
                     begin
                             If Code_up_ppp then If FileExists (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after') then If FileExists (EtcDir+'resolv.conf') then
                                                If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after', EtcDir+'resolv.conf') then
                                                       Shell ('cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after '+EtcDir+'resolv.conf');
                             Application.ProcessMessages;
                             If FileExists (MyDataDir+'on.ico') then If FileExists (MyDataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'on.ico');
                             If StartMessage then BalloonMessage (4000,message0,message6+' '+Memo_Config.Lines[0]+' '+message7+'...',AFont);
                             If Memo_Config.Lines[23]='networktest-no' then NoInternet:=false;
                             If Memo_Config.Lines[29]='pppnotdefault-yes' then NoInternet:=false;
                             If StartMessage then If Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If NoInternet then
                             begin
                                 Mysleep(1000);
                                //определение dns, на которых поднято vpn
                                 DNS3:='none';
                                 DNS4:='none';
                                 If FileExists(EtcDir+'resolv.conf') then
                                    begin
                                      AssignFile (FileResolv_conf,EtcDir+'resolv.conf');
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
                                         Str:='ping -c1 '+DNS3+'|grep '+chr(39)+'1 received'+chr(39);
                                         Application.ProcessMessages;
                                         popen(f,Str,'R');
                                         Application.ProcessMessages;
                                         If eof(f) then
                                                                   begin
                                                                        NoPingDNS3:=true;
                                                                        BalloonMessage (4000,message0,message42,AFont);
                                                                   end;
                                         PClose(f);
                                    end;
                                 //тест dns4-сервера
                                 If DNS4<>'none' then
                                    begin
                                         Str:='ping -c1 '+DNS4+'|grep '+chr(39)+'1 received'+chr(39);
                                         Application.ProcessMessages;
                                         popen(f,Str,'R');
                                         Application.ProcessMessages;
                                         If eof(f) then
                                                                   begin
                                                                        NoPingDNS4:=true;
                                                                        BalloonMessage (4000,message0,message40,AFont);
                                                                   end;
                                         PClose(f);
                                    end;
                                 //тест интернета
                                 Str:='ping -c1 '+Memo_Config.Lines[44]+'|grep '+chr(39)+'1 received'+chr(39);
                                 Application.ProcessMessages;
                                 popen(f,str,'R');
                                 Application.ProcessMessages;
                                 If eof(f) then NoInternet:=true else NoInternet:=false;
                                 PClose(f);
                                 Application.ProcessMessages;
                                 If NoInternet then BalloonMessage (4000,message0,message16,AFont)
                                                    else
                                                         BalloonMessage (4000,message0,message19,AFont);
                                 Application.ProcessMessages;
                             end;
                             StartMessage:=false;
                     end;
  If not Code_up_ppp then
                           begin
                             TrafficRX:=0;
                             TrafficTX:=0;
                             RXbyte0:='0';
                             RXbyte1:='0';
                             TXbyte0:='0';
                             TXbyte1:='0';
                             ObnullRX:=0;
                             ObnullTX:=0;
                             DoSpeedCount:=false;
                             Shell ('rm -f '+MyTmpDir+'ObnullRX');
                             Shell ('rm -f '+MyTmpDir+'ObnullTX');
                             Application.ProcessMessages;
                             If not StartMessage then
                                    begin
                                         If NoConnectMessageShow then BalloonMessage (8000,message0,message6+' '+Memo_Config.Lines[0]+' '+message8+'...',AFont);
                                         NoInternet:=true;
                                         Shell('rm -f '+MyTmpDir+'DateStart');
                                         TrafficRX:=0;
                                         TrafficTX:=0;
                                         RXbyte0:='0';
                                         RXbyte1:='0';
                                         TXbyte0:='0';
                                         TXbyte1:='0';
                                         ObnullRX:=0;
                                         ObnullTX:=0;
                                         DoSpeedCount:=false;
                                         Shell ('rm -f '+MyTmpDir+'ObnullRX');
                                         Shell ('rm -f '+MyTmpDir+'ObnullTX');
                                    end;
                             If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
                             StartMessage:=true;
                           end;
  NoConnectMessageShow:=true;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
end;

procedure TForm1.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  find_net_monitor:boolean;
  str:string;
begin
  If Button=MBLEFT then exit;
  If not FileExists (UsrBinDir+'net_monitor') then begin MenuItem5.Visible:=false; exit;end;
  If not FileExists (UsrBinDir+'vnstat') then begin MenuItem5.Visible:=false; exit;end;
  If Net_MonitorRun then begin MenuItem5.Enabled:=false; exit;end;
  If not Net_MonitorRun then MenuItem5.Enabled:=true;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  If Code_up_ppp then MenuItem6.Enabled:=true else MenuItem6.Enabled:=false;
  find_net_monitor:=false;
  If Code_up_ppp then If FileExists (UsrBinDir+'net_monitor') then if FileExists (UsrBinDir+'vnstat') then
                    begin
                         //проверка net_monitor в процессах root, игнорируя зомби
                         popen(f,'ps -u root | grep net_monitor | awk '+chr(39)+'{print $4$5}'+chr(39),'R');
                         str:='';
                         While not eof(f) do
                              begin
                                   Readln(f,str);
                                   If str='net_monitor' then find_net_monitor:=true;
                              end;
                         PClose(f);
                    end;
  If not find_net_monitor then If not Net_MonitorRun then MenuItem5.Enabled:=true else MenuItem5.Enabled:=false;
  If not Code_up_ppp then MenuItem5.Enabled:=false;
end;

procedure TForm1.TrayIcon1MouseMove(Sender: TObject);
// Вывод информации о соединении
var
  str,StrObnull,strVPN:string;
  SecondsPastRun:int64;
  hour,min,sec:int64;
  Time:string;
  TV : timeval;
  Str_RemoteIPaddress0,RemoteIPaddress0,Str_IPaddress0,IPaddress0:string;
  DNS3,DNS4:string;
  FileObnull:textfile;
  ConnectionInfo,StatusInfo,TimeInNetInfo,DownloadInfo,UploadInfo,InterfaceInfo,IPAddressInfo,GatewayInfo,DNS1Info,DNS2Info:string;
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
  Time:=IntToStr(hour)+' '+message30+' '+IntToStr(min)+' '+message31+' '+IntToStr(sec)+' '+message32;
  PppIface:='';
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  If Code_up_ppp then MenuItem6.Enabled:=true else MenuItem6.Enabled:=false;
  StrObnull:='';
  If FileExists(MyTmpDir+'ObnullRX') then
                                     begin
                                          AssignFile (FileObnull,MyTmpDir+'ObnullRX');
                                          reset (FileObnull);
                                          While not eof(FileObnull) do
                                                     readln(FileObnull, StrObnull);
                                          closefile (FileObnull);
                                     end;
  If StrObnull<>'' then ObnullRX:=StrToInt(StrObnull) else ObnullRX:=0;
  StrObnull:='';
  If FileExists(MyTmpDir+'ObnullTX') then
                                     begin
                                          AssignFile (FileObnull,MyTmpDir+'ObnullTX');
                                          reset (FileObnull);
                                          While not eof(FileObnull) do
                                                     readln(FileObnull, StrObnull);
                                          closefile (FileObnull);
                                     end;
  If StrObnull<>'' then ObnullTX:=StrToInt(StrObnull) else ObnullTX:=0;
  TrafficRX:=StrToInt64(RXbyte1)+4294967296*ObnullRX;
  TrafficTX:=StrToInt64(TXbyte1)+4294967296*ObnullTX;
  If TrafficRX>=1073741824 then RX:=FloatToStr(Round(TrafficRX/1073741824*1000)/1000)+' GiB'
                          else If TrafficRX>=1048576 then RX:=FloatToStr(Round(TrafficRX/1048576*1000)/1000)+' MiB'
                                                    else If TrafficRX>=1024 then RX:=FloatToStr(Round(TrafficRX/1024*1000)/1000)+' KiB'
                                                                           else RX:=IntToStr(TrafficRX)+' b';
  If TrafficTX>=1073741824 then TX:=FloatToStr(Round(TrafficTX/1073741824*1000)/1000)+' GiB'
                          else If TrafficTX>=1048576 then TX:=FloatToStr(Round(TrafficTX/1048576*1000)/1000)+' MiB'
                                                    else If TrafficTX>=1024 then TX:=FloatToStr(Round(TrafficTX/1024*1000)/1000)+' KiB'
                                                                           else TX:=IntToStr(TrafficTX)+' b';
  //определяем Remote_IP_Address0 (шлюз)
  Str_RemoteIPaddress0:='';
  RemoteIPaddress0:='-';
  If Code_up_ppp then
                     begin
                          popen (f,'ifconfig '+PppIface+'|grep P-t-P|awk '+chr(39)+'{print $3}'+chr(39),'R');
                          if not eof(f) then
                                            begin
                                                 While not eof(f) do
                                                       readln(f, Str_RemoteIPaddress0);
                                                 RemoteIPaddress0:=RightStr(Str_RemoteIPaddress0,Length(Str_RemoteIPaddress0)-6);
                                            end;
                          PClose(f);
                     end;
  If RemoteIPaddress0='' then RemoteIPaddress0:='-';
  //определяем IP_Address0
  Str_IPaddress0:='';
  IPaddress0:='-';
  If Code_up_ppp then
                     begin
                          popen (f,'ifconfig '+PppIface+'|grep P-t-P|awk '+chr(39)+'{print $2}'+chr(39),'R');
                          if not eof(f) then
                                            begin
                                                 While not eof(f) do
                                                       readln(f, Str_IPaddress0);
                                                 IPaddress0:=RightStr(Str_IPaddress0,Length(Str_IPaddress0)-5);
                                            end;
                          PClose(f);
                     end;
  If IPaddress0='' then IPaddress0:='-';
  //определение dns, на которых поднято vpn
   DNS3:='-';
   DNS4:='-';
   If Code_up_ppp then If FileExists(EtcDir+'resolv.conf') then
                                                           begin
                                                                AssignFile (FileResolv_conf,EtcDir+'resolv.conf');
                                                                reset (FileResolv_conf);
                                                                While not eof (FileResolv_conf) do
                                                                                                begin
                                                                                                     readln(FileResolv_conf, str);
                                                                                                     If leftstr(str,11)='nameserver ' then If DNS3='-' then DNS3:=RightStr(str,Length(str)-11);
                                                                                                     If leftstr(str,11)='nameserver ' then If DNS4='-' then if DNS3<>'-' then if RightStr(str,Length(str)-11)<>DNS3 then DNS4:=RightStr(str,Length(str)-11);
                                                                                                end;
                                                                closefile(FileResolv_conf);
                                                           end;
  If Memo_Config.Lines[39]='pptp' then strVPN:='VPN PPTP';
  If Memo_Config.Lines[39]='l2tp' then strVPN:='VPN L2TP';
  If Memo_Config.Lines[39]='openl2tp' then strVPN:='VPN OpenL2TP';
                                        If Code_up_ppp then
                                                       begin
                                                            ConnectionInfo:=Memo_Config.Lines[0];
                                                            StatusInfo:=message7+' ('+strVPN+')';
                                                            TimeInNetInfo:=Time;
                                                            DownloadInfo:=RX+' ('+RXSpeed+')';
                                                            UploadInfo:=TX+' ('+TXSpeed+')';
                                                            InterfaceInfo:=PppIface;
                                                            IPAddressInfo:=IPaddress0;
                                                            GatewayInfo:=RemoteIPaddress0;
                                                            DNS1Info:=DNS3;
                                                            DNS2Info:=DNS4;
                                                       end
                                                            else
                                                                begin
                                                                    ConnectionInfo:=Memo_Config.Lines[0];
                                                                    StatusInfo:=message8+' ('+strVPN+')';
                                                                    TimeInNetInfo:='-';
                                                                    DownloadInfo:='-';
                                                                    UploadInfo:='-';
                                                                    InterfaceInfo:='-';
                                                                    IPAddressInfo:='-';
                                                                    GatewayInfo:='-';
                                                                    DNS1Info:='-';
                                                                    DNS2Info:='-';
                                                                end;
  FormHintMatrix.HintMessage(message6+':',message22,message29,message27,message28,message60,message59,message58,'DNS1:','DNS2:',ConnectionInfo,StatusInfo,TimeInNetInfo,DownloadInfo,UploadInfo,InterfaceInfo,IPAddressInfo,GatewayInfo,DNS1Info,DNS2Info,AFont);
  Application.ProcessMessages;
end;


initialization
  {$I unit1.lrs}

  NoConnectMessageShow:=false;
  ProfileName:='';
  ProfileStrDefault:='';
  If Paramcount=0 then if FileExists(MyLibDir+'default/default') then
                              begin
                                   popen(f,'cat '+MyLibDir+'default/default','R');
                                   while not eof(f) do
                                                    readln(f,ProfileStrDefault);
                                   PClose(f);
                                   If ProfileStrDefault<>'' then ProfileName:=ProfileStrDefault;
                              end;
  If Paramcount>0 then ProfileName:=Paramstr(1);
  Shell('mkdir -p '+VarRunVpnpptp);
  Shell ('echo "'+ProfileName+'" > '+VarRunVpnpptp+ProfileName);
  Gettext.GetLanguageIDs(Lang,FallbackLang);
  Translate:=false;
  If FallbackLang='be' then FallbackLang:='ru';
  //FallbackLang:='uk'; //просто для проверки при отладке
  If FallbackLang='ru' then
                            begin
                               POFileName:= MyLangDir+'ponoff.ru.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If FallbackLang='uk' then
                            begin
                               POFileName:= MyLangDir+'ponoff.uk.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If not Translate then
                            begin
                               POFileName:= MyLangDir+'ponoff.en.po';
                               If FileExists (POFileName) then
                                             Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                            end;
end.
