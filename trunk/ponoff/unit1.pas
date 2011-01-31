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
    Memo_ip_down: TMemo;
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
  pppiface:string; //точный интерфейс pppN
  Net_MonitorRun:boolean; //запущен ли net_monitor

const
  Config_n=47;//определяет сколько строк (кол-во) в файле config программы максимально уже существует, считая от 1, а не от 0
  LibDir='/var/lib/vpnpptp/'; //директория для файлов, создаваемых в процессе работы программы
  TmpDir='/tmp/vpnpptp/'; //директория для временных файлов
  DataDir='/usr/share/vpnpptp/'; //директория для основных неизменных файлов программы
  BinDir='/usr/bin/'; // директория для исполняемых файлов программы

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

implementation

{ TForm1 }

Function DeleteSym(d, s: string): string;
//Удаление любого символа из строки s, где d - символ для удаления
Begin
  While pos(d, s) <> 0 do
  Delete(s, (pos(d, s)), 1); result := s;
End;

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
  pppiface:='';
  popen (f,'ifconfig | grep Link','R');
  Code_up_ppp:=false;
  While not eof(f) do
     begin
         Readln (f,str);
         If str<>'' then if LeftStr(str,3)='ppp' then
                               begin
                                    Code_up_ppp:=true;
                                    pppiface:=LeftStr(str,4);
                               end;
     end;
  PClose(f);
end;

procedure Ifdown (Iface:string;wait:boolean);
//опускает интерфейс
begin
          AProcess := TProcess.Create(nil);
          If FileExists ('/sbin/ifdown') then if not ubuntu then if not fedora then AProcess.CommandLine :='ifdown '+Iface;
          If (not FileExists ('/sbin/ifdown')) or ubuntu or fedora then AProcess.CommandLine :='ifconfig '+Iface+' down';
          if wait then AProcess.Options:=AProcess.Options+[poWaitOnExit];
          AProcess.Execute;
          //Unix.WaitProcess(AProcess.ProcessID);
          AProcess.Free;
end;

procedure Ifup (Iface:string;wait:boolean);
//поднимает интерфейс
begin
          AProcess := TProcess.Create(nil);
          If FileExists ('/sbin/ifup') then if not ubuntu then if not fedora then AProcess.CommandLine :='ifup '+Iface;
          If (not FileExists ('/sbin/ifup')) or ubuntu or fedora then AProcess.CommandLine :='ifconfig '+Iface+' up';
          if wait then AProcess.Options:=AProcess.Options+[poWaitOnExit];
          AProcess.Execute;
          //Unix.WaitProcess(AProcess.ProcessID);
          AProcess.Free;
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
                                  Shell('printf "'+Str_Etc_hosts+'\n" >> '+TmpDir+'hosts.tmp');
               end;
        closefile (FileEtc_hosts);
        Shell('cp -f '+TmpDir+'hosts.tmp /etc/hosts');
        Shell('rm -f '+TmpDir+'hosts.tmp');
        Shell('chmod 0644 /etc/hosts');
    end;
end;

Procedure DoCountInterface;
//считает максимальное кол-во default
var
   str:string;
   i:integer;
  // FileInterface:textfile;
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
{   i:=0;
   Shell ('rm -f '+TmpDir+'CountInterface');
   Shell ('ifconfig |grep eth >>'+TmpDir+'CountInterface & ifconfig |grep wlan >>'+TmpDir+'CountInterface & ifconfig |grep br >>'+TmpDir+'CountInterface');
   AssignFile (FileInterface,TmpDir+'CountInterface');
   reset (FileInterface);
   While not eof (FileInterface) do
   begin
        readln(FileInterface, str);
        i:=i+1;
   end;
   closefile(FileInterface);
   Shell ('rm -f '+TmpDir+'CountInterface');}
   if i=0 then i:=1;
   CountInterface:=i;
end;

procedure BalloonMessage (i:integer;str1:string);
begin
     If Form1.Memo_Config.Lines[24]<>'balloon-no' then exit;
     If Form1.Memo_Config.Lines[23]<>'networktest-yes' then MySleep(1000);
     Unit2.Form2.ShowMyBalloonHint(str1, message0, i, Form1.TrayIcon1.GetPosition.X, Form1.TrayIcon1.GetPosition.Y, AFont);
     Application.ProcessMessages;
end;

procedure MakeDefaultGW;
//определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сетевой интерфейс, на котором настроено VPN
var
  nodefaultgw:boolean;
begin
  nodefaultgw:=false;
  popen (f,'/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39),'R');
  If eof(f) then nodefaultgw:=true;
  PClose(f);
       {Shell ('rm -f '+TmpDir+'gate');
       Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > '+TmpDir+'gate');
       Shell('printf "none" >> '+TmpDir+'gate');
       Form1.Memo_gate.Clear;
       If FileExists(TmpDir+'gate') then Form1.Memo_gate.Lines.LoadFromFile(TmpDir+'gate');
       If Form1.Memo_gate.Lines[0]='none' then}
       If nodefaultgw then
                                          begin
       //исправление default и повторная проверка
                                               Shell ('route add default gw '+Form1.Memo_Config.Lines[2]+' dev '+Form1.Memo_Config.Lines[3]);
                                               nodefaultgw:=false;
                                               popen (f,'/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39),'R');
                                               If eof(f) then nodefaultgw:=true;
                                               PClose(f);
                                               {Shell ('rm -f '+TmpDir+'gate');
                                               Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > '+TmpDir+'gate');
                                               Shell('printf "none" >> '+TmpDir+'gate');
                                               Form1.Memo_gate.Clear;
                                               If FileExists(TmpDir+'gate') then Form1.Memo_gate.Lines.LoadFromFile(TmpDir+'gate');}
                                          end;
       If nodefaultgw then
       //If Form1.Memo_gate.Lines[0]='none' then
                               begin
                                 If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networking') or (NetServiceStr='networkmanager') then
                                                                                                begin
                                                                                                     AProcess := TProcess.Create(nil);
                                                                                                     AProcess.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                                                                                                     AProcess.Execute;
                                                                                                     //Unix.WaitProcess(AProcess.ProcessID);
                                                                                                     AProcess.Free;
                                                                                                end;
                                 Ifdown(Form1.Memo_Config.Lines[3],false);
                                 If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep (3000);
                                 Ifup(Form1.Memo_Config.Lines[3],false);
                                 Ifup('lo',false);
                                 If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep (3000);
                               end;
      // Shell ('rm -f '+TmpDir+'gate');
      // Form1.Memo_gate.Lines.Clear;
end;

procedure KillZombieNet_Monitor;
//следит за дочерним процессом AProcessNet_Monitor, и если он уже только как зомби, то убирает его
var
   find_net_monitor:boolean;
   str:string;
begin
  find_net_monitor:=false;
  If FileExists ('/usr/bin/net_monitor') then if FileExists ('/usr/bin/vnstat') then if Net_MonitorRun then
                    begin
                         //проверка net_monitor в процессах root, игнорируя зомби
                         popen(f,'ps -u root | grep net_monitor | awk '+chr(39)+'{print $4$5}'+chr(39),'R');
                         //Shell('ps -u root | grep net_monitor | awk '+chr(39)+'{print $4$5}'+chr(39)+' > '+TmpDir+'tmpnostart1');
                         //Shell('printf "none" >> '+TmpDir+'tmpnostart1');
                         //Form1.tmpnostart.Clear;
                         //If FileExists(TmpDir+'tmpnostart1') then
                         str:='';
                         While not eof(f) do
                              begin
                                   Readln(f,str);
                                   //tmpnostart.Lines.LoadFromFile(TmpDir+'tmpnostart1');
                                   //For j:=0 to tmpnostart.Lines.Count-1 do
                                     //       If tmpnostart.Lines[j]='net_monitor' then find_net_monitor:=true;
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
    //Code_up_ppp:boolean;
    link:byte;//1-link ok, 2-no link, 3-none, 4-еще не определено
    str,MtuUsed:string;
    Str_networktest, Str_RemoteIPaddress:string;
    FindRemoteIPaddress:boolean;
    //pppiface,
    realpppiface, realpppifacedefault:string;
    none:boolean;
    //ID:integer;
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
  If not FlagLengthSyslog then If FileExists('/var/log/syslog') then If FileSize('/var/log/syslog')>1073741824 then // >1 Гб
           begin
               BalloonMessage (8000,message45+' '+message46);
               MySleep(3000);
               Application.ProcessMessages;
          end;
   FlagLengthSyslog:=true;
   //Проверяем поднялось ли соединение
   CheckVPN;
{   str:='';
   pppiface:='';
   popen (f,'ifconfig | grep Link','R');
   Code_up_ppp:=False;
   While not eof(f) do
      begin
          Readln (f,str);
          If str<>'' then if LeftStr(str,3)='ppp' then
                                begin
                                     Code_up_ppp:=True;
                                     pppiface:=LeftStr(str,4);
                                end;
      end;
   PClose(f); }
{  Shell('rm -f '+TmpDir+'status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+TmpDir+'status.ppp');
  Code_up_ppp:=False;
  If FileExists(TmpDir+'status.ppp') then Memo2.Lines.LoadFromFile(TmpDir+'status.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
         Code_up_ppp:=True;
         pppiface:=LeftStr(Memo2.Lines[j],4);
      end;
   end;}
//проверяем поднялось ли соединение на pppN и если нет, то поднимаем на pppN; переводим pppN в фон
If Memo_Config.Lines[29]='pppnotdefault-yes' then NoInternet:=true;
If Code_up_ppp then
 begin
 realpppiface:='';
 popen (f,'/sbin/ip r|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39),'R');
 While not eof(f) do
    begin
        Readln (f,realpppiface);
    end;
 PClose(f);
 realpppifacedefault:='';
 popen (f,'/sbin/ip r|grep default|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39),'R');
 While not eof(f) do
    begin
        Readln (f,realpppifacedefault);
    end;
 PClose(f);
{  Shell ('rm -f '+TmpDir+'gate');
  Shell('/sbin/ip r|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39)+' > '+TmpDir+'gate');
  Shell('/sbin/ip r|grep default|grep ppp|awk '+ chr(39)+'{print $3}'+chr(39)+' >> '+TmpDir+'gate');
  Shell('printf "none\n" >> '+TmpDir+'gate');
  Shell('printf "none\n" >> '+TmpDir+'gate');
  Memo_gate.Clear;
  If FileExists(TmpDir+'gate') then Memo_gate.Lines.LoadFromFile(TmpDir+'gate');
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then If Memo_gate.Lines[0]<>Memo_gate.Lines[1] then}
  If realpppiface<>'' then if LeftStr(realpppiface,3)='ppp' then If realpppiface<>realpppifacedefault then
                               begin
                                  If Memo_Config.Lines[29]<>'pppnotdefault-yes' then
                                       begin
                                            For h:=1 to CountInterface do
                                                Shell ('/sbin/route del default');
                                            //Shell ('/sbin/route add default dev '+Memo_gate.Lines[0]);
                                            Shell ('/sbin/route add default dev '+realpppiface);
                                       end;
                               end;
  //If LeftStr(Memo_gate.Lines[0],3)='ppp' then If Memo_gate.Lines[0]<>'none' then
  If realpppiface<>'' then if LeftStr(realpppiface,3)='ppp' then
                               begin
                                  If Memo_Config.Lines[29]='pppnotdefault-yes' then
                                           begin
                                             For h:=1 to CountInterface do
                                                 //Shell ('/sbin/route del default dev '+Memo_gate.Lines[0]);
                                                 Shell ('/sbin/route del default dev '+realpppiface);
                                             Shell ('/sbin/route add default gw '+Memo_config.Lines[2]+' dev '+Memo_config.Lines[3]);
                                             NoInternet:=false;//считаем, что типа при этом есть интернет
                                           end;
                               end;
  //Shell ('rm -f '+TmpDir+'gate');
  //Memo_gate.Lines.Clear;
 end;
If Code_up_ppp then If FileExists (LibDir+'resolv.conf.after') then If FileExists ('/etc/resolv.conf') then
                       If not CompareFiles (LibDir+'resolv.conf.after', '/etc/resolv.conf') then
                                            Shell ('cp -f '+LibDir+'resolv.conf.after /etc/resolv.conf');
//Shell('rm -f '+TmpDir+'hosts.tmp');
If not Code_up_ppp then If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
//Проверяем используемое mtu
If not Code_up_ppp then FlagMtu:=false;
MtuUsed:='';
If Code_up_ppp then If not FlagMtu then If not FileExists (TmpDir+'mtu.checked') then
   begin
     popen (f,'ifconfig '+pppiface+'|grep MTU |awk '+ chr(39)+'{print $6}'+chr(39),'R');
     While not eof(f) do
        begin
          Readln (f,MtuUsed);
        end;
     PClose(f);
     If MtuUsed<>'' then If Length(MtuUsed)>=4 then MtuUsed:=RightStr(MtuUsed,Length(MtuUsed)-4);
     If MtuUsed<>'' then If StrToInt(MtuUsed)>1460 then
        begin
             BalloonMessage (8000,message43+' '+MtuUsed+' '+message44);
             Shell('touch '+TmpDir+'mtu.checked');
             MySleep(3000);
             Application.ProcessMessages;
        end;
        FlagMtu:=true;
   end;
//обработка случая когда RemoteIPaddress совпадается с ip-адресом самого vpn-сервера
If Code_up_ppp then If Memo_Config.Lines[46]<>'route-IP-remote-yes' then
               If FileExists(LibDir+'hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                      begin
                                         //Shell('rm -f '+TmpDir+'RemoteIPaddress');
                                         //Shell ('ifconfig|grep P-t-P|awk '+chr(39)+'{print $3}'+chr(39)+' >> '+TmpDir+'RemoteIPaddress');
                                         //If FileSize(TmpDir+'RemoteIPaddress')<>0 then
                                         popen (f,'ifconfig|grep P-t-P|awk '+chr(39)+'{print $3}'+chr(39),'R');
                                         if not eof(f) then
                                                                                 begin
                                                                                    //AssignFile (FileRemoteIPaddress,TmpDir+'RemoteIPaddress');
                                                                                    //reset (FileRemoteIPaddress);
                                                                                    While not eof(f) do
                                                                                          readln(f, Str_RemoteIPaddress);
                                                                                    //readln(FileRemoteIPaddress, Str_RemoteIPaddress);
                                                                                    RemoteIPaddress:=RightStr(Str_RemoteIPaddress,Length(Str_RemoteIPaddress)-6);
                                                                                    //closefile (FileRemoteIPaddress);
                                                                                    //Shell('rm -f '+TmpDir+'RemoteIPaddress');
                                                                                    Memo_bindutilshost0.Lines.LoadFromFile(LibDir+'hosts');
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
                                                                                                                                                       Shell ('printf "'+'/sbin/route add -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-up.d/ip-up');
                                                                                                            //изменение скрипта ip-down
                                                                                                            If Memo_Config.Lines[7]='reconnect-pptp' then if FileExists('/etc/ppp/ip-down.d/ip-down') then
                                                                                                                                                        Shell ('printf "'+'/sbin/route del -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-down.d/ip-down');
                                                                                                            If Memo_Config.Lines[7]='noreconnect-pptp' then if FileExists(LibDir+'ip-down') then
                                                                                                                                                         Shell ('printf "'+'/sbin/route del -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+LibDir+'ip-down');
                                                                                                            Shell('rm -f '+LibDir+'hosts');
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
     popen (f,'/sbin/mii-tool '+Memo_Config.Lines[3],'R');
     str:='';
     while not eof(f) do
        readln(f,str);
     //Shell('rm -f '+TmpDir+'gate1');
     //Shell('/sbin/mii-tool '+Memo_Config.Lines[3]+' >> '+TmpDir+'gate1');
     //Shell('printf "none" >> '+TmpDir+'gate1');
     //Form1.Memo_gate1.Clear;
     //If FileExists(TmpDir+'gate1') then Memo_gate1.Lines.LoadFromFile(TmpDir+'gate1');
     If str<>'' then If RightStr(str,7)='link ok' then link:=1;
     //If RightStr(Memo_gate1.Lines[0],7)='link ok' then link:=1;
     If str<>'' then If RightStr(str,7)='no link' then link:=2;
     //If RightStr(Memo_gate1.Lines[0],7)='no link' then link:=2;
     If str='' then link:=3;
     //If LeftStr(Memo_gate1.Lines[0],4)='none' then link:=3;
     PClose(f);
   end;
If link=1 then If NoInternet then MakeDefaultGW;
If not Code_up_ppp then
       If FileExists(LibDir+'resolv.conf.before') then If FileExists('/etc/resolv.conf') then
             If not CompareFiles (LibDir+'resolv.conf.before', '/etc/resolv.conf') then
                                 Shell ('cp -f '+LibDir+'resolv.conf.before /etc/resolv.conf');
//проверка технической возможности поднятия соединения
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[30]<>'none' then
                            begin //тест dns1-сервера
                            Application.ProcessMessages;
                            popen (f,'ping -c1 '+Memo_config.Lines[30]+'|grep '+chr(39)+'1 received'+chr(39),'R');
                            //Shell('rm -f '+TmpDir+'networktest');
                            //Str:='ping -c1 '+Memo_config.Lines[30]+'|grep '+chr(39)+'1 received'+chr(39)+' > '+TmpDir+'networktest';
                            Application.ProcessMessages;
                            //Shell(str);
                            //Application.ProcessMessages;
                            //If FileSize(TmpDir+'networktest')=0 then
                            If eof(f) then
                                                              begin
                                                                   NoPingDNS1:=true;
                                                                   BalloonMessage (8000,message23);
                                                                   Mysleep(1000);
                                                              end;
                            //Shell('rm -f '+TmpDir+'networktest');
                            PClose(f);
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[31]<>'none' then
                            begin //тест dns2-сервера
                                 {Shell('rm -f '+TmpDir+'networktest');
                                 Str:='ping -c1 '+Memo_config.Lines[31]+'|grep '+chr(39)+'1 received'+chr(39)+' > '+TmpDir+'networktest';
                                 Application.ProcessMessages;
                                 Shell(str);
                                 Application.ProcessMessages;
                                 If FileSize(TmpDir+'networktest')=0 then
                                                                   begin
                                                                        NoPingDNS2:=true;
                                                                        BalloonMessage (8000,message24);
                                                                        Mysleep(1000);
                                                                   end;
                                 Shell('rm -f '+TmpDir+'networktest');}
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
                                 //Shell('rm -f '+TmpDir+'networktest');
                                 //Str:='ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39)+' > '+TmpDir+'networktest';
                                 Application.ProcessMessages;
                                 popen (f,'ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39),'R');
                                 //Shell(str);
                                 Application.ProcessMessages;
                                 //Shell('printf "none\n" >> '+TmpDir+'networktest');
                                 //Memo_networktest.Lines.LoadFromFile(TmpDir+'networktest');
                                 //If Memo_networktest.Lines[0]='none' then NoPingIPS:=true;
                                 //Shell('rm -f '+TmpDir+'networktest');
                                 If eof(f) then NoPingIPS:=true;
                                 PClose(f);
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then
                            begin //тест шлюза локальной сети
                                 //Shell('rm -f '+TmpDir+'networktest');
                                 //Str:='ping -c1 '+Memo_config.Lines[2]+'|grep '+chr(39)+'1 received'+chr(39)+' > '+TmpDir+'networktest';
                                 Application.ProcessMessages;
                                 //Shell(str);
                                 popen (f,'ping -c1 '+Memo_config.Lines[2]+'|grep '+chr(39)+'1 received'+chr(39),'R');
                                 Application.ProcessMessages;
                                 //Shell('printf "none\n" >> '+TmpDir+'networktest');
                                 //Memo_networktest.Lines.LoadFromFile(TmpDir+'networktest');
                                 //If Memo_networktest.Lines[0]='none' then NoPingGW:=true;
                                 //Shell('rm -f '+TmpDir+'networktest');
                                 If eof(f) then NoPingGW:=true;
                                 PClose(f);
                            end;
If not Code_up_ppp then DhclientStart:=false;
If not Code_up_ppp then If link=1 then If Memo_Config.Lines[9]='dhcp-route-yes' then //старт dhclient
                           begin
                              AProcessDhclient := TProcess.Create(nil);
                              AProcessDhclient.CommandLine :='dhclient '+Memo_Config.Lines[3];
                              Application.ProcessMessages;
                              If not NoPingIPS then If not NoDNS then If not NoPingGW then //If Memo_Config.Lines[9]='dhcp-route-yes' then
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
                              If link=1 then If NoInternet then //If Memo_Config.Lines[9]='dhcp-route-yes' then //проверка поднялся ли интерфейс после dhclient
                              begin
                                   none:=false;
                                   popen (f,'/sbin/ip r|grep '+Memo_Config.Lines[3],'R');
                                   If eof(f) then none:=true;
                                   PClose(f);
                                 //Shell ('rm -f '+TmpDir+'gate');
                                 //Shell('/sbin/ip r|grep '+Memo_Config.Lines[3]+' > '+TmpDir+'gate');
                                 //Shell('printf "none" >> '+TmpDir+'gate');
                                 //Memo_gate.Clear;
                                 //If FileExists(TmpDir+'gate') then Memo_gate.Lines.LoadFromFile(TmpDir+'gate');
                                 //If Memo_gate.Lines[0]='none' then
                                 if none then
                                    begin
                                         Mysleep(StrToInt(Memo_Config.Lines[5]) div 3);
                                         none:=false;
                                         popen (f,'/sbin/ip r|grep '+Memo_Config.Lines[3],'R');
                                         If eof(f) then none:=true;
                                         PClose(f);
                                         //Shell('rm -f '+TmpDir+'gate');
                                         //Shell('/sbin/ip r|grep '+Memo_Config.Lines[3]+' > '+TmpDir+'gate');
                                         //Shell('printf "none" >> '+TmpDir+'gate');
                                         //Memo_gate.Clear;
                                         //If FileExists(TmpDir+'gate') then Memo_gate.Lines.LoadFromFile(TmpDir+'gate');
                                         //If Memo_gate.Lines[0]='none' then
                                         if none then
                                                 begin
                                                      Ifup(Form1.Memo_Config.Lines[3],false);
                                                      DhclientStart:=false;
                                                 end;
                                    end;
                                 //Shell ('rm -f '+TmpDir+'gate');
                                 //Memo_gate.Lines.Clear;
                              end;
                              //ID:=0;
                              //ID:=AProcessDhclient.ProcessID;
                              //If ID<>0 then Shell ('kill '+IntToStr(ID));
                              //Unix.WaitProcess(AProcessDhclient.ProcessID);
                              //AProcessDhclient.WaitOnExit;
                              //AProcessDhclient.Free;
                           end;
  //определение и сохранение всех актуальных в данный момент ip-адресов vpn-сервера с занесением маршрутов везде
  If not FileExists(LibDir+'hosts') then NewIPS:=false;
  if BindUtils then Str:='host '+Memo_config.Lines[1]+'|grep address|grep '+Memo_config.Lines[1]+'|awk '+ chr(39)+'{print $4}'+chr(39);
  if not BindUtils then Str:='ping -c1 '+Memo_config.Lines[1]+'|grep '+Memo_config.Lines[1]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39);
  If not Code_up_ppp then If link=1 then
               If FileExists(LibDir+'hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                              begin
                                                  //Shell('rm -f '+TmpDir+'hosts');
                                                  Application.ProcessMessages;
                                                  popen (f,Str,'R');
                                                  //Shell (Str+' >> '+TmpDir+'hosts');
                                                  Application.ProcessMessages;
                                                  If eof(f) then If not BindUtils then
                                                  //If FileSize(TmpDir+'hosts')=0 then If not BindUtils then
                                                                                             NoPingIPS:=true;
                                                  If eof(f) then If BindUtils then
                                                  //If FileSize(TmpDir+'hosts')=0 then If BindUtils then
                                                                                             NoDNS:=true;
                                                  //PClose(f);
                                                  Memo_bindutilshost0.Lines.LoadFromFile(LibDir+'hosts');
                                                  //AssignFile (Filenetworktest,TmpDir+'hosts');
                                                  //reset (Filenetworktest);
                                              //While not eof(Filenetworktest) do
                                              While not eof(f) do
                                              begin
                                                  //readln(Filenetworktest, Str_networktest);
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
                                              If Memo_Config.Lines[41]='etc-hosts-yes' then Shell ('printf "'+Str_networktest+' '+Memo_config.Lines[1]+'\n" >> /etc/hosts');
                                              If NewIPS then
                                                  begin //определился новый, неизвестный ранее ip-адрес vpn-сервера
                                                        Shell('printf "'+Str_networktest+'\n'+'" >> '+LibDir+'hosts');
                                                        //проверка на наличие добавляемого маршрута в таблице маршрутизации и его добавление если нету
                                                        popen (f1,'/sbin/route -n|grep '+Str_networktest+'|grep '+Memo_config.Lines[2]+'|grep '+Memo_config.Lines[3]+'|awk '+ chr(39)+'{print $0}'+chr(39),'R');
                                                        //Shell('/sbin/route -n|grep '+Str_networktest+'|grep '+Memo_config.Lines[2]+'|grep '+Memo_config.Lines[3]+'|awk '+ chr(39)+'{print $0}'+chr(39)+' > '+TmpDir+'gatevpn');
                                                        //Shell('printf "none" >> '+TmpDir+'gatevpn');
                                                        //Memo_gatevpn.Clear;
                                                        //If FileExists(TmpDir+'gatevpn') then Memo_gatevpn.Lines.LoadFromFile(TmpDir+'gatevpn');
                                                        //немедленно добавить маршрут в таблицу маршрутизации
                                                        //If Memo_gatevpn.Lines[0]='none' then
                                                        if eof(f1) then
                                                                                        Shell ('/sbin/route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]);
                                                        //Shell('rm -f '+TmpDir+'gatevpn');
                                                        PClose(f1);
                                                        //изменение скрипта ip-up
                                                        If FileExists('/etc/ppp/ip-up.d/ip-up') then
                                                                                        Shell ('printf "'+'/sbin/route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-up.d/ip-up');
                                                        //изменение скрипта ip-down
                                                        If Memo_Config.Lines[7]='reconnect-pptp' then if FileExists('/etc/ppp/ip-down.d/ip-down') then
                                                                                        Shell ('printf "'+'/sbin/route del -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> /etc/ppp/ip-down.d/ip-down');
                                                        If Memo_Config.Lines[7]='noreconnect-pptp' then if FileExists(LibDir+'ip-down') then
                                                                                        Shell ('printf "'+'/sbin/route del -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+LibDir+'ip-down');
                                                  end;
                                              end;
                                           //closefile (Filenetworktest);
                                           PClose(f);
                                           end;
                                           //Shell('rm -f '+TmpDir+'hosts');
If Code_up_ppp then If link<>1 then //когда связи по факту нет, но в NetApplet и в ifconfig ppp0 числится, а pppd продолжает сидеть в процессах
                               begin
                                 MenuItem2Click(Self);
                                 If FileExists (DataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'off.ico');
                                 exit;
                               end;

If Code_up_ppp then Timer1.Interval:=StrToInt64(Memo_Config.Lines[4]) else Timer1.Interval:=StrToInt64(Memo_Config.Lines[5]);
If Code_up_ppp then If Timer1.Interval=0 then Timer1.Interval:=1000;

If not Code_up_ppp then If link=3 then
                                  begin
                                   MenuItem2Click(Self);
                                   If FileExists (DataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                TrayIcon1.Hide;
                                                                Unit2.Form2.Hide;
                                                                Form3.MyMessageBox(message0,message9,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
                                                                MenuItem2Click(Self);
                                                                If Memo_Config.Lines[7]='noreconnect-pptp' then
                                                                   begin
                                                                     Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                                                     Memo_ip_down.Clear;
                                                                     If FileExists(LibDir+'ip-down') then
                                                                                                   begin
                                                                                                      Memo_ip_down.Lines.LoadFromFile(LibDir+'ip-down');
                                                                                                      Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                                      Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                                      Shell ('rm -f '+LibDir+'ip-down');
                                                                                                    end;
                                                                   end;
                                                                halt;
                                                              end;
                                  end;
If not Code_up_ppp then If link=2 then
                                  begin
                                   MenuItem2Click(Self);
                                   If FileExists (DataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                TrayIcon1.Hide;
                                                                Unit2.Form2.Hide;
                                                                Form3.MyMessageBox(message0,message9,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
                                                                MenuItem2Click(Self);
                                                                If Memo_Config.Lines[7]='noreconnect-pptp' then
                                                                   begin
                                                                     Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                                                     Memo_ip_down.Clear;
                                                                     If FileExists(LibDir+'ip-down') then
                                                                                                   begin
                                                                                                       Memo_ip_down.Lines.LoadFromFile(LibDir+'ip-down');
                                                                                                       Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                                       Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                                       Shell('rm -f '+LibDir+'ip-down');
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
                                                      For h:=1 to CountInterface do
                                                                                Shell ('route del default');
                                                      Ifdown(Memo_Config.Lines[3],false);
                                                      Ifup(Form1.Memo_Config.Lines[3],false);
                                                   end;
                                  If not NoPingIPS then If not NoDNS then If not NoPingGW then
                                                   begin
                                                      If FileExists(LibDir+'resolv.conf.before') then If FileExists('/etc/resolv.conf') then
                                                           If not CompareFiles (LibDir+'resolv.conf.before', '/etc/resolv.conf') then
                                                               Shell ('cp -f '+LibDir+'resolv.conf.before /etc/resolv.conf');
                                                      If not FileExists(TmpDir+'ObnullRX') then ObnullRX:=false else ObnullRX:=true;
                                                      If not FileExists(TmpDir+'ObnullTX') then ObnullTX:=false else ObnullTX:=true;
                                                      If not FileExists(TmpDir+'DateStart') then DateStart:=0;
                                                      If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo',false);
                                                      For h:=1 to CountInterface do
                                                                          Shell ('route del default');
                                                      Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
                                                      DoubleRunPonoff:=false;
                                                      If Memo_Config.Lines[39]<>'l2tp' then
                                                                                    Shell ('/usr/sbin/pppd call '+Memo_Config.Lines[0]) else
                                                                                                              begin
                                                                                                                   //проверка xl2tpd в процессах
                                                                                                                   //Shell('ps -A | grep xl2tpd > '+TmpDir+'tmpnostart1');
                                                                                                                   popen(f,'ps -A | grep xl2tpd','R');
                                                                                                                   //If FileExists(TmpDir+'tmpnostart1') then If FileSize (TmpDir+'tmpnostart1')=0 then
                                                                                                                   If eof(f) then
                                                                                                                        begin
                                                                                                                             Shell (ServiceCommand+'xl2tpd stop');
                                                                                                                             Shell (ServiceCommand+'xl2tpd start');
                                                                                                                             Form1.Repaint;
                                                                                                                             BalloonMessage (3000,message47);
                                                                                                                             Mysleep(3000);
                                                                                                                        end;
                                                                                                                  //Shell ('rm -f '+TmpDir+'tmpnostart1');
                                                                                                                  PClose(f);
                                                                                                                  Shell ('echo "c '+Memo_Config.Lines[0]+'" > /var/run/xl2tpd/l2tp-control');
                                                                                                              end;
                                                   end;
                                  //If not Code_up_ppp then If link=1 then
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
  i,h:integer;
  str:string;
  Apid,Apidroot:tpid;
  //Code_up_ppp,
  //nostart:boolean;
begin
  Application.CreateForm(TForm2, Form2);
  If FileExists ('/sbin/service') or FileExists ('/usr/sbin/service') then ServiceCommand:='service ' else ServiceCommand:='/etc/init.d/';
  DoubleRunPonoff:=false;
  ubuntu:=false;
  debian:=false;
  fedora:=false;
  suse:=false;
  mandriva:=false;
  Application.CreateForm(TForm3, Form3);
  Application.ShowMainForm:=false;
  Application.Minimize;
  If FileExists (DataDir+'ponoff.png') then Image1.Picture.LoadFromFile(DataDir+'ponoff.png');
  Panel1.Caption:=message37+' '+message38;
  Form1.Height:=152;
  Form1.Width:=670;
  Form1.Font.Size:=AFont;
  RXbyte:='0';
  TXbyte:='0';
  RXSpeed:='0b/s';
  TXSpeed:='0b/s';
  Count:=0;
  Net_MonitorRun:=false;
  CountInterface:=1;
  FlagMtu:=false;
  FlagLengthSyslog:=false;
  Form1.Visible:=false;
  Form1.WindowState:=wsMinimized;
  Form1.Hide;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
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
  // nostart:=false;
   Apid:=FpGetpid;
   //Apidroot:=FpGetpid;
   Apidroot:=0;
   popen (f,'ps -u root | grep ponoff | awk '+chr(39)+'{print $1}'+chr(39),'R');
   while not eof(f) do
        begin
           readln(f,Apidroot);
           If Apid=Apidroot then break;
        end;
   PClose(f);
   popen (f,'ps -u root | grep ponoff | awk '+chr(39)+'{print $4}'+chr(39),'R');
   If eof(f) or (Apid<>Apidroot) then //nostart:=true;
//   If nostart then
                   begin
                      //запуск не под root
                      Timer1.Enabled:=False;
                      Timer2.Enabled:=False;
                      Form1.Hide;
                      TrayIcon1.Hide;
                      Form3.MyMessageBox(message0,message1+' '+message25,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
                      PClose(f);
                      halt;
                   end;
  PClose(f);
  If not FileExists(TmpDir) then Shell ('mkdir -p '+TmpDir);
  //обеспечение совместимости старого config с новым
  If FileExists(LibDir+'config') then
     begin
        Memo_config.Lines.LoadFromFile(LibDir+'config');
        If Memo_config.Lines.Count<Config_n then
                                            begin
                                               for i:=Memo_config.Lines.Count to Config_n do
                                                  Shell('printf "none\n" >> '+LibDir+'config');
                                            end;
     end;
  If FileExists(LibDir+'config') then begin Memo_Config.Lines.LoadFromFile(LibDir+'config');end
  else
   begin
    Timer1.Enabled:=False;
    Timer2.Enabled:=False;
    Form1.Hide;
    TrayIcon1.Hide;
    Form3.MyMessageBox(message0,message3+' '+message26,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
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
  If FileExists ('/etc/init.d/network') then NetServiceStr:='network';
  If FileExists ('/etc/init.d/networking') then NetServiceStr:='networking';
  If FileExists ('/etc/init.d/network-manager') then NetServiceStr:='network-manager';
  If FileExists ('/etc/init.d/NetworkManager') then NetServiceStr:='NetworkManager';
  If FileExists ('/etc/init.d/networkmanager') then NetServiceStr:='networkmanager';
  If NetServiceStr='none' then
                            begin
                               Form3.MyMessageBox(message0,message2,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
                               Application.ProcessMessages;
                            end;
  //Проверяем поднялось ли соединение
  CheckVPN;
{  str:='';
//  pppiface:='';
  popen (f,'ifconfig | grep Link','R');
  Code_up_ppp:=False;
  While not eof(f) do
     begin
         Readln (f,str);
         If str<>'' then if LeftStr(str,3)='ppp' then
                               begin
                                    Code_up_ppp:=True;
                                    //pppiface:=LeftStr(str,4);
                               end;
     end;
  PClose(f);}
{  //Проверяем поднялось ли соединение
  Shell('rm -f '+TmpDir+'status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+TmpDir+'status.ppp');
  Code_up_ppp:=False;
  If FileExists(TmpDir+'status.ppp') then Memo2.Lines.LoadFromFile(TmpDir+'status.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       Code_up_ppp:=True;
      end;
   end; }
If Code_up_ppp then If FileExists (DataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'on.ico');
If not Code_up_ppp then If FileExists (DataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'off.ico');
TrayIcon1.Show;
Application.ProcessMessages;
//проверка ponoff в процессах root, обработка двойного запуска программы
popen (f,'ps -u root | grep ponoff | awk '+chr(39)+'{print $4}'+chr(39),'R');
i:=0;
while not eof(f) do
begin
    readln(f,str);
    i:=i+1;
end;
PClose(f);
If i>1 then
           begin
               DoubleRunPonoff:=true;
               Apid:=FpGetpid;
               //Shell('ps -e|grep ponoff|awk '+chr(39)+'{print$1}'+chr(39)+' >'+TmpDir+'doublerun');
               popen(f,'ps -e|grep ponoff|awk '+chr(39)+'{print$1}'+chr(39),'R');
               //AssignFile (FileDoubleRun,TmpDir+'doublerun');
               //reset (FileDoubleRun);
               //While not eof(FileDoubleRun) do
               str:='';
               While not eof(f) do
                        begin
                            //Readln (FileDoubleRun,str);
                            Readln (f,str);
                            If str<>'' then If str<>IntToStr(Apid) then
                                                                   FpKill(StrToInt(str),9);
                        end;
               //closefile (FileDoubleRun);
               //Shell('rm -f '+TmpDir+'doublerun')
               PClose(f);
           end;
If not FileExists (TmpDir+'DateStart') then DateStart:=0 else
                                       begin
                                            AssignFile (FileDateStart,TmpDir+'DateStart');
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
             popen(f,'/sbin/ip r|grep dsl','R');
             //Shell('/sbin/ip r|grep dsl > '+TmpDir+'gate');
             //If FileExists (TmpDir+'gate') then if FileSize(TmpDir+'gate')<>0 then
             If not eof(f) then
                                         begin
                                           Timer1.Enabled:=False;
                                           Timer2.Enabled:=False;
                                           Form1.Hide;
                                           TrayIcon1.Hide;
                                           Form3.MyMessageBox(message0,message41,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
                                           //Shell('rm -f '+TmpDir+'gate');
                                           PClose(f);
                                           halt;
                                         end;
             PClose(f);
        end;
   //Shell('rm -f '+TmpDir+'tmpnostart1');
   If Memo_Config.Lines[23]='networktest-no' then NoInternet:=false;
   If FileExists(LibDir+'ip-down') then  //возврат к изначальной настройке скрипта ip-down
                                                                              begin
                                                                                  Memo_ip_down.Clear;
                                                                                  Shell('rm -f /etc/ppp/ip-down.d/ip-down');
                                                                                  Memo_ip_down.Lines.LoadFromFile(LibDir+'ip-down');
                                                                                  Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                  Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                              end;
   If Memo_Config.Lines[7]='noreconnect-pptp' then
                                             begin
                                                Shell('rm -f '+LibDir+'ip-down');
                                                Memo_ip_down.Clear;
                                                If FileExists('/etc/ppp/ip-down.d/ip-down') then Memo_ip_down.Lines.LoadFromFile('/etc/ppp/ip-down.d/ip-down');
                                                Memo_ip_down.Lines.SaveToFile(LibDir+'ip-down');
                                                Shell('rm -f /etc/ppp/ip-down.d/ip-down');
                                                Shell('printf "#!/bin/sh\n" >> /etc/ppp/ip-down.d/ip-down');
                                                Shell('chmod a+x '+LibDir+'ip-down');
                                                Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                             end;
   //проверка состояния сетевого интерфейса
   popen (f,'/sbin/mii-tool '+Memo_Config.Lines[3],'R');
   str:='';
   while not eof(f) do
        readln(f,str);
   If str<>'' then If RightStr(str,7)='link ok' then link:=1;
   If str<>'' then If RightStr(str,7)='no link' then link:=2;
   If str='' then link:=3;
   PClose(f);
   //Shell('rm -f '+TmpDir+'gate2');
   //Shell('/sbin/mii-tool '+Memo_Config.Lines[3]+' >> '+TmpDir+'gate2');
   //Shell('printf "none" >> '+TmpDir+'gate2');
   //Form1.Memo_gate1.Clear;
   //If FileExists(TmpDir+'gate2') then Memo_gate1.Lines.LoadFromFile(TmpDir+'gate2');
   //If RightStr(Memo_gate1.Lines[0],7)='link ok' then link:=1;
   //If RightStr(Memo_gate1.Lines[0],7)='no link' then link:=2;
   //If LeftStr(Memo_gate1.Lines[0],4)='none' then link:=3;
   If Memo_Config.Lines[6]='mii-tool-no' then link:=1; //отказ от контроля link
   If Memo_Config.Lines[7]='reconnect-pptp' then link:=1;
   If link=3 then //попытка поднять требуемый интерфейс
                begin
                   AProcess := TProcess.Create(nil);
                   AProcess.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                   AProcess.Execute;
                   //Unix.WaitProcess(AProcess.ProcessID);
                   AProcess.Free;
                   For h:=1 to CountInterface do
                                          Shell ('route del default');
                   Ifdown(Memo_Config.Lines[3],false);
                   Mysleep(3000);
                   Ifup(Memo_Config.Lines[3],false);
                   //повторная проверка состояния сетевого интерфейса
                   If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep(3000);
                   popen (f,'/sbin/mii-tool '+Memo_Config.Lines[3],'R');
                   str:='';
                   while not eof(f) do
                        readln(f,str);
                   If str<>'' then If RightStr(str,7)='link ok' then link:=1;
                   If str<>'' then If RightStr(str,7)='no link' then link:=2;
                   If str='' then link:=3;
                   PClose(f);
                   //Shell('rm -f '+TmpDir+'gate2');
                  // Shell('/sbin/mii-tool '+Memo_Config.Lines[3]+' >> '+TmpDir+'gate2');
                  // Shell('printf "none" >> '+TmpDir+'gate2');
                   //Form1.Memo_gate1.Clear;
                   //If FileExists(TmpDir+'gate2') then Memo_gate1.Lines.LoadFromFile(TmpDir+'gate2');
                   //If RightStr(Memo_gate1.Lines[0],7)='link ok' then link:=1;
                   //If RightStr(Memo_gate1.Lines[0],7)='no link' then link:=2;
                   //If LeftStr(Memo_gate1.Lines[0],4)='none' then link:=3;
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
                 Form3.MyMessageBox(message0,message4,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
                 halt;
                end;
   if link=2 then
                begin
                 Form3.MyMessageBox(message0,message5,'','',message33,DataDir+'ponoff.png',false,false,true,AFont,Form1.Icon);
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
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
 //просто убивает pppd и других демонов и удаляет временные файлы
var
   //i:integer;
   str:string;
begin
 If DoubleRunPonoff then exit;
//проверка наличия в процессах демона pppd
 popen(f,'ps -u root | grep pppd | awk '+chr(39)+'{print $4}'+chr(39),'R');
 //Shell('ps -u root | grep pppd | awk '+chr(39)+'{print $4}'+chr(39)+' > '+TmpDir+'tmp_pppd');
 //Form1.tmp_pppd.Clear;
 //If FileExists(TmpDir+'tmp_pppd') then tmp_pppd.Lines.LoadFromFile(TmpDir+'tmp_pppd');
 Application.ProcessMessages;
 //For i:=0 to tmp_pppd.Lines.Count-1 do
 str:='';
 while not eof(f) do
   begin
     readln(f,str);
     //If (LeftStr(tmp_pppd.Lines[i],4)='pppd') then
     If str<>'' then If (LeftStr(str,4)='pppd') then
                                        begin
                                             Shell('killall pppd');
                                             If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then
                                                                                  begin
                                                                                       AProcess := TProcess.Create(nil);
                                                                                       AProcess.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                                                                                       AProcess.Execute;
                                                                                       //Unix.WaitProcess(AProcess.ProcessID);
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
// Shell('rm -f '+TmpDir+'status.ppp');
// Shell('rm -f '+TmpDir+'tmp');
// Shell('rm -f '+TmpDir+'gate');
// Shell('rm -f '+TmpDir+'gate1');
 //Shell('rm -f '+TmpDir+'gate2');
// Shell('rm -f '+TmpDir+'users');
// Shell('rm -f '+TmpDir+'tmpnostart1');
// Shell('rm -f '+TmpDir+'status3.ppp');
// Shell('rm -f '+TmpDir+'status.ppp');
// Shell('rm -f '+TmpDir+'tmp_pppd');
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
 If Memo_Config.Lines[7]='noreconnect-pptp' then
                                            begin
                                              Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                              Memo_ip_down.Clear;
                                              If FileExists(LibDir+'ip-down') then
                                                                            begin
                                                                                 Memo_ip_down.Lines.LoadFromFile(LibDir+'ip-down');
                                                                                 Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                 Shell ('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                 Shell ('rm -f '+LibDir+'ip-down');
                                                                            end;
                                            end;
  MenuItem2Click(Self);
  Shell ('echo "d '+Memo_Config.Lines[0]+'" > /var/run/xl2tpd/l2tp-control');
  If FileExists (DataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'off.ico');
  Application.ProcessMessages;
//  Shell ('rm -f '+TmpDir+'gate');
  For h:=1 to CountInterface do
              Shell ('route del default');
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo',false);
  Shell('rm -f '+TmpDir+'xl2tpd.conf');
  If FileExists(LibDir+'resolv.conf.before') then If FileExists('/etc/resolv.conf') then
         If not CompareFiles (LibDir+'resolv.conf.before', '/etc/resolv.conf') then
                         Shell ('cp -f '+LibDir+'resolv.conf.before /etc/resolv.conf');
  Shell ('route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
  Shell ('rm -f '+TmpDir+'DateStart');
  Shell ('rm -f '+TmpDir+'ObnullRX');
  Shell ('rm -f '+TmpDir+'ObnullTX');
  Shell ('rm -f '+TmpDir+'mtu.checked');
//  Shell ('rm -f '+TmpDir+'status3.ppp');
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
  KillZombieNet_Monitor;
  Shell ('killall net_monitor');
  If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  If FileExists(LibDir+'resolv.conf.before') then If FileExists('/etc/resolv.conf') then
          If not CompareFiles (LibDir+'resolv.conf.before', '/etc/resolv.conf') then
                            Shell ('cp -f '+LibDir+'resolv.conf.before /etc/resolv.conf');
  If Memo_Config.Lines[7]='noreconnect-pptp' then
                                            begin
                                              Shell ('rm -f /etc/ppp/ip-down.d/ip-down');
                                              Memo_ip_down.Clear;
                                              If FileExists(LibDir+'ip-down') then
                                                                            begin
                                                                                 Memo_ip_down.Lines.LoadFromFile(LibDir+'ip-down');
                                                                                 Memo_ip_down.Lines.SaveToFile('/etc/ppp/ip-down.d/ip-down');
                                                                                 Shell('chmod a+x /etc/ppp/ip-down.d/ip-down');
                                                                                 Shell ('rm -f '+LibDir+'ip-down');
                                                                             end;
                                            end;
  MenuItem2Click(Self);
  Shell ('echo "d '+Memo_Config.Lines[0]+'" > /var/run/xl2tpd/l2tp-control');
  If FileExists (Datadir+'off.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'off.ico');
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
  popen(f,'/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39),'R');
  //Shell ('rm -f '+TmpDir+'gate');
//  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > '+TmpDir+'gate');
  //Shell('printf "none" >> '+TmpDir+'gate');
  //Memo_gate.Clear;
  //If FileExists(TmpDir+'gate') then Memo_gate.Lines.LoadFromFile(TmpDir+'gate');
  //If Memo_gate.Lines[0]='none' then
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
  //Shell ('rm -f '+TmpDir+'gate');
  //Memo_gate.Lines.Clear;
  Shell ('rm -f '+TmpDir+'DateStart');
  Shell ('rm -f '+TmpDir+'ObnullRX');
  Shell ('rm -f '+TmpDir+'ObnullTX');
  Shell ('rm -f '+TmpDir+'mtu.checked');
//  Shell ('rm -f '+TmpDir+'status3.ppp');
  halt;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
//var
  //ID:integer;
  //j:integer;
  //Code_up_ppp:boolean;
  //pppiface,
  //str:string;
begin
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
{  str:='';
  pppiface:='';
  popen (f,'ifconfig | grep Link','R');
  Code_up_ppp:=False;
  While not eof(f) do
     begin
         Readln (f,str);
         If str<>'' then if LeftStr(str,3)='ppp' then
                               begin
                                    Code_up_ppp:=True;
                                    pppiface:=LeftStr(str,4);
                               end;
     end;
  PClose(f);}
{  //Проверяем поднялось ли соединение
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  Shell('rm -f '+TmpDir+'status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+TmpDir+'status.ppp');
  Code_up_ppp:=False;
  If FileExists(TmpDir+'status.ppp') then Memo2.Lines.LoadFromFile(TmpDir+'status.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       pppiface:=LeftStr(Memo2.Lines[j],4);
       Code_up_ppp:=True;
      end;
   end;}
  If Code_up_ppp then If not Net_MonitorRun then
             begin
                AProcessNet_Monitor := TProcess.Create(nil);
                AProcessNet_Monitor.CommandLine := '/usr/bin/net_monitor -i '+pppiface;
                AProcessNet_Monitor.Execute;
                Net_MonitorRun:=true;
                //Unix.WaitProcess(AProcess.ProcessID);
                //AProcessNet_Monitor.WaitOnExit;
                //ID:=0;
                //ID:=AProcess.ProcessID;
                //AProcess.Free;
                //If ID<>0 then Shell ('kill '+IntToStr(ID));
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
  //j:integer;
  //Code_up_ppp:boolean;
  //pppiface,
  Str:string;
  RXbyte1,TXbyte1:string;
  TV : timeval;
  DNS3,DNS4:string;
 // find_net_monitor:boolean;
begin
  Count:=Count+1;
  If Count=3 then Count:=1;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  KillZombieNet_Monitor;
{  str:='';
  pppiface:='';
  popen (f,'ifconfig | grep Link','R');
  Code_up_ppp:=False;
  While not eof(f) do
     begin
         Readln (f,str);
         If str<>'' then if LeftStr(str,3)='ppp' then
                               begin
                                    Code_up_ppp:=True;
                                    //pppiface:=LeftStr(str,4);
                               end;
     end;
  PClose(f);}
  {//Проверяем поднялось ли соединение
  Shell('rm -f '+TmpDir+'status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+TmpDir+'status.ppp');
  Code_up_ppp:=False;
  If FileExists(TmpDir+'status.ppp') then Memo2.Lines.LoadFromFile(TmpDir+'status.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       pppiface:=LeftStr(Memo2.Lines[j],4);
       Code_up_ppp:=True;
      end;
   end;}
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
  If StrToInt64(RXbyte1)>=4242538496 then begin ObnullRX:=true; Shell ('touch '+TmpDir+'ObnullRX'); end;//реакция программы за 3сек до факта обнуления значений
  If StrToInt64(TXbyte1)>=4242538496 then begin ObnullTX:=true; Shell ('touch '+TmpDir+'ObnullTX'); end;//2^32-4сек*100MБит/сек=4294967296-4сек*13107200Б/сек
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
                           If not FileExists (TmpDir+'DateStart') then Shell ('printf "'+IntToStr(DateStart)+'\n" > '+TmpDir+'DateStart');
                      end;
  If Code_up_ppp then
                     begin
                             If Code_up_ppp then If FileExists (LibDir+'resolv.conf.after') then If FileExists ('/etc/resolv.conf') then
                                                If not CompareFiles (LibDir+'resolv.conf.after', '/etc/resolv.conf') then
                                                       Shell ('cp -f '+LibDir+'resolv.conf.after /etc/resolv.conf');
                             Application.ProcessMessages;
                             If FileExists (DataDir+'on.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'on.ico');
                             If StartMessage then BalloonMessage (8000,message6+' '+Memo_Config.Lines[0]+' '+message7+'...');
                             If Memo_Config.Lines[23]='networktest-no' then NoInternet:=false;
                             If Memo_Config.Lines[29]='pppnotdefault-yes' then NoInternet:=false;
                             //If FileExists ('/usr/bin/vnstat') then Shell ('vnstat -u -i '+pppiface);
                             If StartMessage then If Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If NoInternet then
                             begin
                                 Mysleep(1000);
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
                                         //Shell('rm -f '+TmpDir+'networktest');
                                         Str:='ping -c1 '+DNS3+'|grep '+chr(39)+'1 received'+chr(39);//+' > '+TmpDir+'networktest';
                                         Application.ProcessMessages;
                                         //Shell(str);
                                         popen(f,Str,'R');
                                         Application.ProcessMessages;
                                         //If FileSize(TmpDir+'networktest')=0 then
                                         If eof(f) then
                                                                   begin
                                                                        NoPingDNS3:=true;
                                                                        BalloonMessage (8000,message42);
                                                                        Mysleep(1000);
                                                                   end;
                                         //Shell('rm -f '+TmpDir+'networktest');
                                         PClose(f);
                                    end;
                                 //тест dns4-сервера
                                 If DNS4<>'none' then
                                    begin
                                         //Shell('rm -f '+TmpDir+'networktest');
                                         Str:='ping -c1 '+DNS4+'|grep '+chr(39)+'1 received'+chr(39);//+' > '+TmpDir+'networktest';
                                         Application.ProcessMessages;
                                         //Shell(str);
                                         popen(f,Str,'R');
                                         Application.ProcessMessages;
                                         //If FileSize(TmpDir+'networktest')=0 then
                                         If eof(f) then
                                                                   begin
                                                                        NoPingDNS4:=true;
                                                                        BalloonMessage (8000,message40);
                                                                        Mysleep(1000);
                                                                   end;
                                         //Shell('rm -f '+TmpDir+'networktest');
                                         PClose(f);
                                    end;
                                 //тест интернета
                                 //Shell('rm -f '+TmpDir+'networktest');
                                 Str:='ping -c1 '+Memo_Config.Lines[44]+'|grep '+Memo_Config.Lines[44]+'|awk '+chr(39)+'{print $3}'+chr(39)+'|grep '+chr(39)+'('+chr(39);//+' > '+TmpDir+'networktest';
                                 Application.ProcessMessages;
                                 //Shell(str);
                                 popen(f,str,'R');
                                 Application.ProcessMessages;
                                 //Shell('printf "none\n" >> '+TmpDir+'networktest');
                                 //Memo_networktest.Lines.LoadFromFile(TmpDir+'networktest');
                                 //If Memo_networktest.Lines[0]='none' then NoInternet:=true else NoInternet:=false;
                                 If eof(f) then NoInternet:=true else NoInternet:=false;
                                 //Shell('rm -f '+TmpDir+'networktest');
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
                                         Shell('rm -f '+TmpDir+'DateStart');
                                         Shell('rm -f '+TmpDir+'ObnullRX');
                                         Shell('rm -f '+TmpDir+'ObnullTX');
                                    end;
                             If FileExists (DataDir+'off.ico') then TrayIcon1.Icon.LoadFromFile(DataDir+'off.ico');
                             StartMessage:=true;
                           end;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
end;

procedure TForm1.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  //j:integer;
  //Code_up_ppp,
  find_net_monitor:boolean;
  str:string;
begin
  If Button=MBLEFT then exit;
  If not FileExists ('/usr/bin/net_monitor') then begin MenuItem5.Visible:=false; exit;end;
  If not FileExists ('/usr/bin/vnstat') then begin MenuItem5.Visible:=false; exit;end;
  If Net_MonitorRun then begin MenuItem5.Enabled:=false; exit;end;
  If not Net_MonitorRun then MenuItem5.Enabled:=true;
  Application.ProcessMessages;
  TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
{  str:='';
//  pppiface:='';
  popen (f,'ifconfig | grep Link','R');
  Code_up_ppp:=False;
  While not eof(f) do
     begin
         Readln (f,str);
         If str<>'' then if LeftStr(str,3)='ppp' then
                               begin
                                    Code_up_ppp:=True;
                                    //pppiface:=LeftStr(str,4);
                               end;
     end;
  PClose(f);}
  {Shell('rm -f '+TmpDir+'status.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+TmpDir+'status.ppp');
  Code_up_ppp:=False;
  If FileExists(TmpDir+'status.ppp') then Memo2.Lines.LoadFromFile(TmpDir+'status.ppp');
  Memo2.Lines.Add(' ');
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       Code_up_ppp:=True;
      end;
   end;}
  find_net_monitor:=false;
  If Code_up_ppp then If FileExists ('/usr/bin/net_monitor') then if FileExists ('/usr/bin/vnstat') then
                    begin
                         //проверка net_monitor в процессах root, игнорируя зомби
                         popen(f,'ps -u root | grep net_monitor | awk '+chr(39)+'{print $4$5}'+chr(39),'R');
                         //Shell('ps -u root | grep net_monitor | awk '+chr(39)+'{print $4$5}'+chr(39)+' > '+TmpDir+'tmpnostart1');
                         //Shell('printf "none" >> '+TmpDir+'tmpnostart1');
                         //Form1.tmpnostart.Clear;
                         //If FileExists(TmpDir+'tmpnostart1') then
                         str:='';
                         While not eof(f) do
                              begin
                                   Readln(f,str);
                                   //tmpnostart.Lines.LoadFromFile(TmpDir+'tmpnostart1');
                                   //For j:=0 to tmpnostart.Lines.Count-1 do
                                     //       If tmpnostart.Lines[j]='net_monitor' then find_net_monitor:=true;
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
  //j:integer;
  //Code_up_ppp:boolean;
  str:string;
  //pppiface:string;
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
  //Проверяем поднялось ли соединение
  CheckVPN;
{  str:='';
  pppiface:='';
  popen (f,'ifconfig | grep Link','R');
  Code_up_ppp:=False;
  While not eof(f) do
     begin
         Readln (f,str);
         If str<>'' then if LeftStr(str,3)='ppp' then
                               begin
                                    Code_up_ppp:=True;
                                    pppiface:=LeftStr(str,4);
                               end;
     end;
  PClose(f);}
  {Shell('rm -f '+TmpDir+'status3.ppp');
  Memo2.Clear;
  Shell('ifconfig | grep Link > '+TmpDir+'status3.ppp');
  Code_up_ppp:=False;
  If FileExists(TmpDir+'status3.ppp') then Memo2.Lines.LoadFromFile(TmpDir+'status3.ppp');
  Memo2.Lines.Add(' ');
  Application.ProcessMessages;
  For j:=0 to Memo2.Lines.Count-1 do
   begin
     If LeftStr(Memo2.Lines[j],3)='ppp' then
      begin
       pppiface:=LeftStr(Memo2.Lines[j],4);
       Code_up_ppp:=True;
      end;
   end;}
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
  If ObnullRX or FileExists(TmpDir+'ObnullRX')then RX:='>4GiB';
  If ObnullTX or FileExists(TmpDir+'ObnullTX')then TX:='>4GiB';
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
  Gettext.GetLanguageIDs(Lang,FallbackLang);
  Translate:=false;
  //FallbackLang:='uk'; //просто для проверки при отладке
  If FallbackLang='ru' then
                            begin
                               POFileName:= DataDir+'lang/ponoff.ru.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If FallbackLang='uk' then
                            begin
                               POFileName:= DataDir+'lang/ponoff.uk.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If not Translate then
                            begin
                               POFileName:= DataDir+'lang/ponoff.en.po';
                               If FileExists (POFileName) then
                                             Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                            end;
end.
