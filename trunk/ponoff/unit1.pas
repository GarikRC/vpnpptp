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
  ExtCtrls, Menus, StdCtrls, Unix, Gettext, Translations,UnitMyMessageBox, BaseUnix, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Memo_bindutilshost0: TMemo;
    MenuItem5: TMenuItem;
    Panel1: TPanel;
    Memo_Config: TMemo;
    MenuItem4: TMenuItem;
    Timer2: TTimer;
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
    procedure PopupMenu1Popup(Sender: TObject);
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
  RX,TX:string;//объем загруженного/отданного
  RXbyte,TXbyte:string;//объем загруженного/отданного в байтах
  DateStart,DateStop:int64;//время запуска/время текущее
  RXSpeed,TXSpeed:string;//скорость загрузки/отдачи
  Count:byte;//счетчик времени
  DoCount:boolean;//выводить ли скорость
  ObnullRX,ObnullTX:boolean; //отслеживает обнуление счетчика RX/TX
  AFont:integer; //шрифт приложения
  AProcess,AProcessDhclient,AProcessNet_Monitor: TProcess; //для запуска внешних приложений
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
  Code_up_ppp:boolean; //существует ли интерфейс pppN
  PppIface:string; //точный интерфейс pppN
  Net_MonitorRun:boolean; //запущен ли net_monitor
  ProfileName:string; //определяет какое имя соединения использовать
  ProfileStrDefault:string; //имя соединения, используемое по-умолчанию

const
  Config_n=47;//определяет сколько строк (кол-во) в файле config программы максимально уже существует, считая от 1, а не от 0
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

resourcestring
  message0='Внимание!';
  message1='Запуск этой программы возможен только под администратором или с разрешения администратора. Нажмите <ОК> для отказа от запуска.';
  message2='Не обнаружено ни одного сервиса, способного управлять сетью. Корректная работа программы невозможна!';
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
  message43='Рекомендуется вручную уменьшить MTU/MRU, так как используемое значение MTU =';
  message44='байт слишком большое.';
  message45='Размер файла-лога /var/log/syslog больше 1 GiB.';
  message46='Возможны проблемы с установлением соединения...';
  message47='Запускается сервис xl2tpd...';
  message48='Отсутствуют некритичные файлы: ';
  message49='Отсутствуют критичные файлы: ';
  message50='Не найдено соединение:';
  message51='Обнаружено активное соединение с именем:';
  message52='Одновременный запуск нескольких соединений с разными именами недопустим.';
  message53='Отсутствует дефолтное соединение.';
  message54='Выберите одно из доступных соединений, неявляющихся дефолтными, из выпадающего списка. Это соединение станет дефолтным.';
  message55='<ОК> - выбрать. <Отмена> - отказаться и выйти.';
  message56='Соединение с именем';
  message57='не может существовать, так как это имя зарезервировано программой.';

implementation

{ TForm1 }

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

procedure BalloonMessage (i:integer;str1:string);
begin
     If Form1.Memo_Config.Lines[24]<>'balloon-no' then exit;
     If Form1.Memo_Config.Lines[23]<>'networktest-yes' then MySleep(1000);
     Unit2.Form2.ShowMyBalloonHint(str1, message0, i, Form1.TrayIcon1.GetPosition.X, Form1.TrayIcon1.GetPosition.Y, AFont);
     Application.ProcessMessages;
end;

procedure CheckFiles;
//проверяет наличие необходимых программе файлов
var
    str:string;
begin
    //критичные файлы
    str:=message49;
    If not FileExists(MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.before') then str:=str+MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.before, ';
    If not FileExists(MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.after') then str:=str+MyLibDir+Form1.Memo_Config.Lines[0]+'/resolv.conf.after, ';
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
                          BalloonMessage (8000,str);
                          MySleep(8000);
                          Application.ProcessMessages;
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

procedure CheckVPN;
//проверяет поднялось ли соединение и на каком точно интерфейсе поднялось
var
  str:string;
begin
  str:='';
  PppIface:='';
  popen (f,'ifconfig | grep Link','R');
  Code_up_ppp:=false;
  While not eof(f) do
     begin
         Readln (f,str);
         If str<>'' then if LeftStr(str,3)='ppp' then
                               begin
                                    Code_up_ppp:=true;
                                    PppIface:=LeftStr(str,4);
                               end;
     end;
  PClose(f);
end;

procedure Ifdown (Iface:string;wait:boolean);
//опускает интерфейс
begin
          AProcess := TProcess.Create(nil);
          If FileExists (SBinDir+'ifdown') then if not ubuntu then if not fedora then AProcess.CommandLine :='ifdown '+Iface;
          If (not FileExists (SBinDir+'ifdown')) or ubuntu or fedora then AProcess.CommandLine :='ifconfig '+Iface+' down';
          if wait then AProcess.Options:=AProcess.Options+[poWaitOnExit];
          AProcess.Execute;
          AProcess.Free;
end;

procedure Ifup (Iface:string;wait:boolean);
//поднимает интерфейс
begin
          AProcess := TProcess.Create(nil);
          If FileExists (SBinDir+'ifup') then if not ubuntu then if not fedora then AProcess.CommandLine :='ifup '+Iface;
          If (not FileExists (SBinDir+'ifup')) or ubuntu or fedora then AProcess.CommandLine :='ifconfig '+Iface+' up';
          if wait then AProcess.Options:=AProcess.Options+[poWaitOnExit];
          AProcess.Execute;
          AProcess.Free;
end;

procedure ClearEtc_hosts;
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

Procedure DoCountInterface;
//считает максимальное кол-во default
var
   str:string;
   i:integer;
begin
  i:=0;
  popen (f,'ifconfig |grep '+chr(39)+'eth'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  popen (f,'ifconfig |grep '+chr(39)+'wlan'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  popen (f,'ifconfig |grep '+chr(39)+'br'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  if i=0 then i:=1;
  CountInterface:=i;
end;

procedure MakeDefaultGW;
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
                                                                                                     AProcess := TProcess.Create(nil);
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
               BalloonMessage (8000,message45+' '+message46);
               MySleep(3000);
               Application.ProcessMessages;
           end;
   FlagLengthSyslog:=true;
//Проверяем поднялось ли соединение
CheckVPN;
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
             BalloonMessage (8000,message43+' '+MtuUsed+' '+message44);
             Shell('touch '+MyTmpDir+'mtu.checked');
             MySleep(3000);
             Application.ProcessMessages;
        end;
        FlagMtu:=true;
   end;
//обработка случая когда RemoteIPaddress совпадается с ip-адресом самого vpn-сервера
If Code_up_ppp then If Memo_Config.Lines[46]<>'route-IP-remote-yes' then
               If FileExists(MyLibDir+Memo_Config.Lines[0]+'/hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                      begin
                                         popen (f,'ifconfig|grep P-t-P|awk '+chr(39)+'{print $3}'+chr(39),'R');
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
                                                                                                            BalloonMessage (8000,str);
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
                                                                   BalloonMessage (8000,message23);
                                                                   Mysleep(1000);
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
                                                                        BalloonMessage (8000,message24);
                                                                        Mysleep(1000);
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
                              AProcessDhclient := TProcess.Create(nil);
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
                                                        //проверка на наличие добавляемого маршрута в таблице маршрутизации и его добавление если нету
                                                        popen (f1,SBinDir+'route -n|grep '+Str_networktest+'|grep '+Memo_config.Lines[2]+'|grep '+Memo_config.Lines[3]+'|awk '+ chr(39)+'{print $0}'+chr(39),'R');
                                                        //немедленно добавить маршрут в таблицу маршрутизации
                                                        if eof(f1) then
                                                                                        Shell (SBinDir+'route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]);
                                                        PClose(f1);
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
                                                                Unit2.Form2.Hide;
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
                                                                Unit2.Form2.Hide;
                                                                Form3.MyMessageBox(message0,message9,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                MenuItem2Click(Self);
                                                                Shell('rm -f '+VarRunVpnpptp+ProfileName);
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
                                                      If not FileExists(MyTmpDir+'ObnullRX') then ObnullRX:=false else ObnullRX:=true;
                                                      If not FileExists(MyTmpDir+'ObnullTX') then ObnullTX:=false else ObnullTX:=true;
                                                      If not FileExists(MyTmpDir+'DateStart') then DateStart:=0;
                                                      If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo',false);
                                                      For h:=1 to CountInterface do
                                                                          Shell ('route del default');
                                                      Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
                                                      DoubleRunPonoff:=false;
                                                      If Memo_Config.Lines[39]<>'l2tp' then
                                                                                    Shell (UsrSBinDir+'pppd call '+Memo_Config.Lines[0]) else
                                                                                                              begin
                                                                                                                   //проверка xl2tpd в процессах
                                                                                                                   popen(f,'ps -A | grep xl2tpd','R');
                                                                                                                   If eof(f) then
                                                                                                                        begin
                                                                                                                             Shell (ServiceCommand+'xl2tpd stop');
                                                                                                                             Shell (ServiceCommand+'xl2tpd start');
                                                                                                                             Form1.Repaint;
                                                                                                                             BalloonMessage (3000,message47);
                                                                                                                             Mysleep(3000);
                                                                                                                        end;
                                                                                                                  PClose(f);
                                                                                                                  Shell ('echo "c '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
                                                                                                              end;
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
  i,j,h:integer;
  str,stri:string;
  Apid:tpid;
begin
if FileSize(MyLibDir+'profiles')=0 then Shell ('rm -f '+MyLibDir+'profiles');
  Application.CreateForm(TForm2, Form2);
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
  RXbyte:='0';
  TXbyte:='0';
  RXSpeed:='0b/s';
  TXSpeed:='0b/s';
  Count:=0;
  DoCount:=false;
  Net_MonitorRun:=false;
  CountInterface:=1;
  FlagMtu:=false;
  FlagLengthSyslog:=false;
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
  TrayIcon1.BalloonTitle:=message0;
  If Screen.Height<440 then AFont:=6;
  If Screen.Height<=480 then AFont:=6;
  If Screen.Height<550 then If not (Screen.Height<=480) then AFont:=6;
  If Screen.Height>550 then AFont:=8;
  If Screen.Height>1000 then AFont:=10;
//проверка соединения
str:=ProfileName;
for i:=1 to Length(str) do
     str[i]:=UpCase(str[i]);
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
  If Memo_Config.Lines[42]<>'none' then AFont:=StrToInt(Memo_Config.Lines[42]);
  If Memo_Config.Lines[43]='ubuntu' then ubuntu:=true;
  If Memo_Config.Lines[43]='debian' then debian:=true;
  If Memo_Config.Lines[43]='fedora' then fedora:=true;
  If Memo_Config.Lines[43]='suse' then suse:=true;
  If Memo_Config.Lines[43]='mandriva' then mandriva:=true;
  Form1.Font.Size:=AFont;
  //определение управляющего сетью сервиса
  NetServiceStr:='none';
  If FileExists (EtcInitDDir+'network') then NetServiceStr:='network';
  If FileExists (EtcInitDDir+'networking') then NetServiceStr:='networking';
  If FileExists (EtcInitDDir+'network-manager') then NetServiceStr:='network-manager';
  If FileExists (EtcInitDDir+'NetworkManager') then NetServiceStr:='NetworkManager';
  If FileExists (EtcInitDDir+'networkmanager') then NetServiceStr:='networkmanager';
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
CheckFiles;//проверка наличия необходимых программе файлов
//Проверяем поднялось ли соединение
CheckVPN;
If Code_up_ppp then If FileExists (MyDataDir+'on.ico') then If FileExists (MyDataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'on.ico');
If not Code_up_ppp then If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
Application.ProcessMessages;
TrayIcon1.Show;
Application.ProcessMessages;
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
   If Memo_Config.Lines[6]='mii-tool-no' then link:=1; //отказ от контроля link
   If Memo_Config.Lines[7]='reconnect-pptp' then link:=1;
   If link=3 then //попытка поднять требуемый интерфейс
                begin
                   AProcess := TProcess.Create(nil);
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
                 Form3.MyMessageBox(message0,message4,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
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
                                             Shell('killall pppd');
                                             If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then
                                                                                  begin
                                                                                       AProcess := TProcess.Create(nil);
                                                                                       AProcess.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                                                                                       AProcess.Execute;
                                                                                       AProcess.Free;
                                                                                       Mysleep(3000);
                                                                                  end;
                                        end;
   end;
 PClose(f);
 If Memo_Config.Lines[39]<>'l2tp' then
                                 begin
                                      Shell (ServiceCommand+'xl2tpd stop');
                                      Shell ('killall xl2tpd');
                                 end;
 Shell('killall openl2tpd');
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
 If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  MenuItem2Click(Self);
  //Shell ('echo "d '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
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
  If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
          If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                            Shell ('cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
  MenuItem2Click(Self);
  //Shell ('echo "d '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
  If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
  Application.ProcessMessages;
  For i:=0 to 9 do
      begin
        Ifdown('eth'+IntToStr(i),true);
        Ifdown('wlan'+IntToStr(i),true);
        Ifdown('br'+IntToStr(i),true);
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
             end;
            Shell (ServiceCommand+NetServiceStr+' restart');
            For i:=0 to 9 do
                 begin
                    Ifup('eth'+IntToStr(i),true);
                    Ifup('wlan'+IntToStr(i),true);
                    Ifup('br'+IntToStr(i),true);
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
                AProcessNet_Monitor := TProcess.Create(nil);
                AProcessNet_Monitor.CommandLine := UsrBinDir+'net_monitor -i '+PppIface;
                AProcessNet_Monitor.Execute;
                Net_MonitorRun:=true;
             end;
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
  Application.ProcessMessages;
  Unit2.Form2.Hide;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  MenuItem1Click(Self);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
//индикация иконки в трее, балуны и тест интернета
var
  Str:string;
  RXbyte1,TXbyte1:string;
  TV : timeval;
  DNS3,DNS4:string;
begin
  If not FileExists (VarRunVpnpptp+ProfileName) then Shell ('echo "'+ProfileName+'" > '+VarRunVpnpptp+ProfileName);
  Count:=Count+1;
  If Count=3 then Count:=1;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  KillZombieNet_Monitor;
  //определяем скорость, время
  popen (f,'ifconfig '+PppIface+'|grep RX|grep bytes|awk '+chr(39)+'{print $2}'+chr(39),'R');
  If eof(f) then RXbyte1:='0';
  While not eof(f) do
     begin
       Readln (f,RXbyte1);
     end;
  PClose(f);
  If RXbyte1='' then RXbyte1:='0';
  popen (f,'ifconfig '+PppIface+'|grep TX|grep bytes|awk '+chr(39)+'{print $6}'+chr(39),'R');
  If eof(f) then TXbyte1:='0';
  While not eof(f) do
     begin
       Readln (f,TXbyte1);
     end;
  PClose(f);
  If TXbyte1='' then TXbyte1:='0';
  Delete(RXbyte1,1,6);
  Delete(TXbyte1,1,6);
  If StrToInt64(RXbyte1)>=4242538496 then begin ObnullRX:=true; Shell ('touch '+MyTmpDir+'ObnullRX'); end;//реакция программы за 3сек до факта обнуления значений
  If StrToInt64(TXbyte1)>=4242538496 then begin ObnullTX:=true; Shell ('touch '+MyTmpDir+'ObnullTX'); end;//2^32-4сек*100MБит/сек=4294967296-4сек*13107200Б/сек
  If Count=2 then
  begin
     If not DoCount then RXSpeed:='?' else RXSpeed:=IntToStr((abs(StrToInt64(RXbyte1)-StrToInt64(RXbyte)) div (Timer2.Interval div 1000)) div Count);
     If RXSpeed='' then RXSpeed:='0';
     If not DoCount then TXSpeed:='?' else TXSpeed:=IntToStr((abs(StrToInt64(TXbyte1)-StrToInt64(TXbyte)) div (Timer2.Interval div 1000)) div Count);
     If TXSpeed='' then TXSpeed:='0';
     RXbyte:=RXbyte1;
     TXbyte:=TXbyte1;
     If RXSpeed<>'?' then
     begin
     If StrToInt64(RXSpeed)>1048576 then RXSpeed:=IntToStr(StrToInt64(RXSpeed) div 1048576)+'MiB/s'
           else If StrToInt64(RXSpeed)>1024 then RXSpeed:=IntToStr(StrToInt64(RXSpeed) div 1024)+'KiB/s'
                                                                             else RXSpeed:=RXSpeed+'b/s';
     end;
     If TXSpeed<>'?' then
     begin
     If StrToInt64(TXSpeed)>1048576 then TXSpeed:=IntToStr(StrToInt64(TXSpeed) div 1048576)+'MiB/s'
           else If StrToInt64(TXSpeed)>1024 then TXSpeed:=IntToStr(StrToInt64(TXSpeed) div 1024)+'KiB/s'
                                                                             else TXSpeed:=TXSpeed+'b/s';
     end;
     DoCount:=true;
  end;
  If Count<2 then If not DoCount then
  begin
      RXSpeed:='?';
      TXSpeed:='?';
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
                             If StartMessage then BalloonMessage (8000,message6+' '+Memo_Config.Lines[0]+' '+message7+'...');
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
                                                                        BalloonMessage (8000,message42);
                                                                        Mysleep(1000);
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
                                                                        BalloonMessage (8000,message40);
                                                                        Mysleep(1000);
                                                                   end;
                                         PClose(f);
                                    end;
                                 //тест интернета
                                 Str:='ping -c1 '+Memo_Config.Lines[44]+'|grep '+Memo_Config.Lines[44]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39);
                                 Application.ProcessMessages;
                                 popen(f,str,'R');
                                 Application.ProcessMessages;
                                 If eof(f) then NoInternet:=true else NoInternet:=false;
                                 PClose(f);
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
                                         Shell('rm -f '+MyTmpDir+'DateStart');
                                         Shell('rm -f '+MyTmpDir+'ObnullRX');
                                         Shell('rm -f '+MyTmpDir+'ObnullTX');
                                    end;
                             If FileExists (MyDataDir+'off.ico') then If FileExists (MyDataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(MyDataDir+'off.ico');
                             StartMessage:=true;
                           end;
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
  str:string;
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
  PppIface:='';
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  popen (f,'ifconfig '+PppIface+'|grep RX|grep bytes|awk '+chr(39)+'{print $3$4}'+chr(39),'R');
  If eof(f) then RX:='0';
  While not eof(f) do
     begin
       Readln (f,RX);
     end;
  PClose(f);
  popen (f,'ifconfig '+PppIface+'|grep TX|grep bytes|awk '+chr(39)+'{print $7$8}'+chr(39),'R');
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
  If ObnullRX or FileExists(MyTmpDir+'ObnullRX')then RX:='>4GiB';
  If ObnullTX or FileExists(MyTmpDir+'ObnullTX')then TX:='>4GiB';
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
  Unit2.Form2.ShowMyHint (str, 3000, Form1.TrayIcon1.GetPosition.X, Form1.TrayIcon1.GetPosition.Y, AFont);
  Application.ProcessMessages;
end;

initialization
  {$I unit1.lrs}
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
