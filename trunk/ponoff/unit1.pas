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
    ImageIconDefaultOn: TImage;
    ImageIconDefaultOff: TImage;
    Memo_Ponoff_conf_ini: TMemo;
    Memo_General_conf: TMemo;
    Memo_bindutilshost0: TMemo;
    MenuItem5: TMenuItem;
    Memo_Config: TMemo;
    MenuItem4: TMenuItem;
    MenuItem6: TMenuItem;
    ColorIcon: TMenuItem;
    NoColorIcon: TMenuItem;
    Minus: TMenuItem;
    Plus: TMenuItem;
    Panel1: TPanel;
    Timer2: TTimer;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    procedure ColorIconClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MinusClick(Sender: TObject);
    procedure PlusClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrayIcon1MouseMove(Sender: TObject);
    procedure BalloonMessage (time_of_show_msec:integer;msg_title,msg_text:string;font_size:integer);
    procedure CheckFiles;
    procedure CheckVPN;
    procedure ClearEtc_hosts;
    procedure MakeDefaultGW;
    procedure LoadIconForTray(PathToIcon,NameIcon:string);
    procedure IconForTrayPlus;
    procedure IconForTrayMinus;
    procedure Ifdown (Iface:string);
    procedure Ifup (Iface:string);
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
  BinDir='/bin/';
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
  AProcess,AProcessDhclient,AProcessNet_Monitor,A_Process: TAsyncProcess; //для запуска внешних приложений
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
  ProfileName:string; //определяет какое имя соединения использовать
  ProfileStrDefault:string; //имя соединения, используемое по-умолчанию
  TrafficRX, TrafficTX:int64; //общий трафик RX/TX
  DoSpeedCount:boolean; //выводить ли скорость загрузки/отдачи
  MaxSpeed:int64; //максимальная пропускная способность сети
  LimitRX,LimitTX:byte; //счетчик сколько раз превышалась пропускная способность сети
  NoConnectMessageShow:boolean; //выводить ли сообщение об отсутствии соединения
  nostart:boolean;
  DopParam:string;
  Apid:tpid;
  EnablePseudoTray:boolean;
  ErrorShowIcon:boolean;
  ImageIconBitmap:tBitmap;
  IconTmp:tIcon;
  TmpBmp: TBitmap;
  file1, file2: TMemoryStream;
  //last_mem_size_icon:  integer;
  tray_status,last_tray:(bw_on,bw_off,col_on,col_off);

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
  message66='Увеличить иконку';
  message67='Уменьшить иконку';
  message68='Цветная иконка';
  message69='Черно-белая иконка';
  message70='Введите пароль root:';
  message71='Ошибка отображения иконки в трее. Используйте вместо ponoff скрипт /usr/bin/vpnlinux. Автоматическое переключение на виджет.';

implementation

uses balloon_matrix, hint_matrix, Unitpseudotray;

function ProgrammRoot(Name:string;DoHalt:boolean):boolean;
//возвращает истину если программа запущена под root
//прерывает выполнение если DoHalt истина и программа под root
var
  Apid:tpid;
begin
     If DoHalt then
                begin
                  popen (f,BinDir+'ps -u root |'+BinDir+'grep '+Name,'R');
                  If not eof(f) then halt;
                  PClose(f);
                end;
     Apid:=FpGetpid;
     popen (f,BinDir+'ps -u root |'+BinDir+'grep '+Name+'| '+BinDir+'grep '+IntToStr(Apid),'R');
     If eof(f) then Result:=false else Result:=true;
     PClose(f);
end;

procedure RestartPonoff;
//проверка ponoff в процессах root, исключение запуска под иными пользователями
begin
    If not ProgrammRoot('ponoff',false) then nostart:=true else nostart:=false;
    DopParam:=' ';
    If ParamStr(1)<>'' then DopParam:=DopParam+ParamStr(1)+' ';
    If DopParam=' ' then DopParam:='';
    If DopParam<>'' then DopParam:=LeftStr(DopParam,Length(DopParam)-1);
    If ErrorShowIcon then
                         begin
                              A_Process.Active:=false;
                              A_Process.CommandLine :=Paramstr(0)+DopParam;
                              //A_Process.CommandLine :=UsrBinDir+'ponoff'+DopParam; //для отладки
                              A_Process.Execute;
                              halt;
                              Application.ProcessMessages;
                         end;
    If nostart then If FileExists('/usr/lib64/kde4/libexec/kdesu') then If FileExists(Paramstr(0)) then //запускаем ponoff с правами root через kdesu
            begin
                 A_Process.Active:=false;
                 A_Process.CommandLine :='/usr/lib64/kde4/libexec/kdesu -c '+'"'+Paramstr(0)+DopParam+'"'+' -d --noignorebutton';
                 A_Process.Execute;
                 while A_Process.Running do
                 begin
                     ProgrammRoot('ponoff',true);
                     sleep(100);
                 end;
                 Application.ProcessMessages;
            end;
    If nostart then If FileExists('/usr/lib/kde4/libexec/kdesu') then If FileExists(Paramstr(0)) then //запускаем ponoff с правами root через kdesu
               begin
                    A_Process.Active:=false;
                    A_Process.CommandLine :='/usr/lib/kde4/libexec/kdesu -c '+'"'+Paramstr(0)+DopParam+'"'+' -d --noignorebutton';
                    A_Process.Execute;
                    while A_Process.Running do
                    begin
                        ProgrammRoot('ponoff',true);
                        sleep(100);
                    end;
                    Application.ProcessMessages;
               end;
    If nostart then If FileExists(UsrBinDir+'beesu') then If FileExists(Paramstr(0)) then //запускаем ponoff с правами root через beesu
           begin
                A_Process.Active:=false;
                A_Process.CommandLine :=UsrBinDir+'beesu - '+'"'+Paramstr(0)+DopParam+'"';
                A_Process.Execute;
                while A_Process.Running do
                begin
                    ProgrammRoot('ponoff',true);
                    sleep(100);
                end;
                Application.ProcessMessages;
           end;
    If nostart then If FileExists(UsrBinDir+'gksu') then If FileExists(Paramstr(0)) then //запускаем ponoff с правами root через gksu
               begin
                    A_Process.Active:=false;
                    A_Process.CommandLine :=UsrBinDir+'gksu -g -u root '+'"'+Paramstr(0)+DopParam+'"'+' -m "'+message70+'"';
                    A_Process.Execute;
                    while A_Process.Running do
                    begin
                        ProgrammRoot('ponoff',true);
                        sleep(100);
                    end;
                    Application.ProcessMessages;
               end;
    If not ProgrammRoot('ponoff',false) then
                  begin
                       Form3.MyMessageBox(message0,message1+' '+message25,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                       PClose(f);
                       FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                       halt;
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
  popen (f,SBinDir+'ifconfig |'+BinDir+'grep '+chr(39)+'eth'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  str:='';
  popen (f,SBinDir+'ifconfig |'+BinDir+'grep '+chr(39)+'wlan'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  str:='';
  popen (f,SBinDir+'ifconfig |'+BinDir+'grep '+chr(39)+'br'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  str:='';
  popen (f,SBinDir+'ifconfig |'+BinDir+'grep '+chr(39)+'em'+chr(39),'R');
  While not eof(f) do
     begin
       Readln (f,str);
       i:=i+1;
     end;
  PClose(f);
  if i=0 then i:=1;
  CountInterface:=i;
end;

procedure TForm1.Ifdown (Iface:string);
//опускает интерфейс
var
   str:string;
begin
         str:='';
         If FileExists (SBinDir+'ifdown') then if not ubuntu then if not fedora then str:=SBinDir+'ifdown '+Iface;
         If (not FileExists (SBinDir+'ifdown')) or ubuntu or fedora then str:=SBinDir+'ifconfig '+Iface+' down';
         if str<>'' then
                        begin
                             Timer1.Enabled:=false;
                             Timer2.Enabled:=false;
                             A_Process.Active:=false;
                             A_Process.Options:=A_Process.Options+[poWaitOnExit];
                             A_Process.CommandLine:=str;
                             A_Process.Execute;
                             Timer1.Enabled:=true;
                             Timer2.Enabled:=true;
                        end;
end;

procedure TForm1.Ifup (Iface:string);
//поднимает интерфейс
var
   str:string;
begin
         str:='';
         If FileExists (SBinDir+'ifup') then if not ubuntu then if not fedora then str:=SBinDir+'ifup '+Iface;
         If (not FileExists (SBinDir+'ifup')) or ubuntu or fedora then str:=SBinDir+'ifconfig '+Iface+' up';
         if str<>'' then
                        begin
                             Timer1.Enabled:=false;
                             Timer2.Enabled:=false;
                             A_Process.Active:=false;
                             A_Process.Options:=A_Process.Options+[poWaitOnExit];
                             A_Process.CommandLine:=str;
                             A_Process.Execute;
                             Timer1.Enabled:=true;
                             Timer2.Enabled:=true;
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
begin
  Result := false;
  file1.Clear;
  file2.Clear;
  try
    file1.LoadFromFile(FirstFile);
    file2.LoadFromFile(SecondFile);
    if file1.Size = file2.Size then
           Result := CompareMem(file1.Memory, file2.memory, file1.Size);
  finally
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

procedure ResizeBmp(bitmp: TBitmap; wid, hei: Integer);
//растягивает картинку
 var
    //TmpBmp: TBitmap;
    ARect: TRect;
 begin
   If (Wid=0) or (hei=0) then exit;
   try
     //TmpBmp := TBitmap.Create;
     TmpBmp.Clear;
     try
       TmpBmp.Width  := wid;
       TmpBmp.Height := hei;
       ARect := Rect(0,0, wid, hei);
       TmpBmp.Canvas.StretchDraw(ARect, Bitmp);
       bitmp.Assign(TmpBmp);
     finally
       //TmpBmp.Free;
     end;
   except
   end;
 end;

{ TForm1 }

procedure TForm1.IconForTrayPlus;
 var
   //ImageIconBitmap:tBitmap;
   wid,hei:integer;
   //IconTmp:tIcon;
begin
  if EnablePseudoTray then
  begin
    Widget.Width:=Widget.Width+5;
    Widget.Height:=Widget.Height+5;
    Widget.IniPropStorage1.Save;
    exit;
  end;
  //IconTmp:= TIcon.create;
  IconTmp.Clear;
  // Здесь ничего не делаем в unity
  wid:=TrayIcon1.Icon.Width;
  hei:=TrayIcon1.Icon.Height;
  if (wid>100) or (hei>100) then exit;
  CheckVPN;
  If (not FileExists (MyDataDir+'off.ico')) or (not FileExists (MyDataDir+'on.ico') or (Widget.IniPropStorage1.ReadString ('black_and_white_icon','null')=true_str)) then
         begin
               If Code_up_ppp then IconTmp.Assign(ImageIconDefaultOn.Picture);
               If not Code_up_ppp then IconTmp.Assign(ImageIconDefaultOff.Picture);
               if EnablePseudoTray then Widget.Image1.Picture.Bitmap.Assign(IconTmp) else TrayIcon1.Icon.Assign(IconTmp);
         end
  else
       begin
            If Code_up_ppp then IconTmp.LoadFromFile(MyDataDir+'on.ico');
            If not Code_up_ppp then IconTmp.LoadFromFile(MyDataDir+'off.ico');
            if EnablePseudoTray then Widget.Image1.Picture.Bitmap.Assign(IconTmp) else TrayIcon1.Icon.Assign(IconTmp);
       end;
  //ImageIconBitmap:= TBitmap.create;
  ImageIconBitmap.Clear;
  ImageIconBitmap.Assign(TrayIcon1.Icon);
  ResizeBmp(ImageIconBitmap,wid+1,hei+1);
  TrayIcon1.Icon.Assign(ImageIconBitmap);
  //ImageIconBitmap.Free;
  FpSystem(UsrBinDir+'printf "'+IntToStr(wid+1)+'\n" > '+MyLibDir+Memo_config.Lines[0]+'/ponoff.conf');
  //IconTmp.Free;
end;

procedure TForm1.IconForTrayMinus;
var
   //ImageIconBitmap:tBitmap;
   wid,hei:integer;
   //IconTmp:tIcon;
begin
  if EnablePseudoTray then
  begin
    Widget.Width:=Widget.Width-5;
    Widget.Height:=Widget.Height-5;
    Widget.IniPropStorage1.Save;
    exit;
  end;
  //IconTmp:= TIcon.create;
  IconTmp.Clear;
  wid:=TrayIcon1.Icon.Width;
  hei:=TrayIcon1.Icon.Height;
  if (wid<3) or (hei<3) then exit;
  CheckVPN;
  If (not FileExists (MyDataDir+'off.ico')) or (not FileExists (MyDataDir+'on.ico') or (Widget.IniPropStorage1.ReadString ('black_and_white_icon','null')=true_str)) then
         begin
              If Code_up_ppp then IconTmp.Assign(ImageIconDefaultOn.Picture);
              If not Code_up_ppp then IconTmp.Assign(ImageIconDefaultOff.Picture);
              if EnablePseudoTray then Widget.Image1.Picture.Bitmap.Assign(IconTmp) else TrayIcon1.Icon.Assign(IconTmp);
          end
            else
                begin
                     If Code_up_ppp then IconTmp.LoadFromFile(MyDataDir+'on.ico');
                     If not Code_up_ppp then IconTmp.LoadFromFile(MyDataDir+'off.ico');
                     if EnablePseudoTray then Widget.Image1.Picture.Bitmap.Assign(IconTmp) else TrayIcon1.Icon.Assign(IconTmp);
                end;
  //ImageIconBitmap:= TBitmap.create;
  ImageIconBitmap.Clear;
  ImageIconBitmap.Assign(TrayIcon1.Icon);
  ResizeBmp(ImageIconBitmap,wid-1,hei-1);
  TrayIcon1.Icon.Assign(ImageIconBitmap);
  //ImageIconBitmap.Free;
  FpSystem(UsrBinDir+'printf "'+IntToStr(wid-1)+'\n" > '+MyLibDir+Memo_config.Lines[0]+'/ponoff.conf');
  //IconTmp.Free;
end;

procedure TForm1.LoadIconForTray(PathToIcon,NameIcon:string);
var
  //ImageIconBitmap:tBitmap;
  //IconTmp:tIcon;
  wid,hei:integer;
  str:string;
begin
   wid:=TrayIcon1.Icon.Width;
  hei:=TrayIcon1.Icon.Height;
  str:='';
  If FileExists(MyLibDir+Memo_config.Lines[0]+'/ponoff.conf') then
         begin
              popen(f,BinDir+'cat '+MyLibDir+Memo_config.Lines[0]+'/ponoff.conf','R');
              while not eof(f) do
                    Readln(f,str);
                    if str<>'' then
                               begin
                                    wid:=StrToInt(str);
                                    hei:=StrToInt(str);
                               end;
                    pclose(f);
         end;
  CheckVPN;

  If (not FileExists (MyDataDir+'off.ico')) or (not FileExists (MyDataDir+'on.ico') or (Widget.IniPropStorage1.ReadString ('black_and_white_icon','null')=true_str)) then    //
  begin
    IconTmp.Clear;
    ImageIconBitmap.Clear;
    If Code_up_ppp then begin IconTmp.Assign(ImageIconDefaultOn.Picture); tray_status:=bw_on; end;
    If not Code_up_ppp then begin IconTmp.Assign(ImageIconDefaultOff.Picture);tray_status:=bw_off; end;
    ImageIconBitmap.Assign(IconTmp);
    ResizeBmp(ImageIconBitmap,wid,hei);
    if EnablePseudoTray then Widget.Image1.Picture.Bitmap.Assign(ImageIconBitmap) else TrayIcon1.Icon.Assign(ImageIconBitmap);
    last_tray:=tray_status;
    exit;
  end;

  if  NameIcon='on.ico' then tray_status:=col_on;
  if  NameIcon='off.ico' then tray_status:=col_off;
  if last_tray=tray_status then exit;
  last_tray:=tray_status;
  ImageIconBitmap.Clear;
  IconTmp.Clear;
  if EnablePseudoTray then Widget.Image1.Picture.LoadFromFile(PathToIcon+NameIcon) else IconTmp.LoadFromFile(PathToIcon+NameIcon);
  ImageIconBitmap.Assign(IconTmp);
  ResizeBmp(ImageIconBitmap,wid,hei);
  TrayIcon1.Icon.Assign(ImageIconBitmap);
end;

procedure TForm1.BalloonMessage (time_of_show_msec:integer;msg_title,msg_text:string;font_size:integer);
begin
         If Form1.Memo_Config.Lines[24]<>'balloon-no' then exit;
         FormHintMatrix.HintHide;
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
    If str<>message49 then
                     begin
                          Form1.Timer1.Enabled:=False;
                          Form1.Timer2.Enabled:=False;
                          Form1.Hide;
                          if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                          str:=LeftStr(str,Length(str)-2);
                          Form3.MyMessageBox(message0,str,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                          FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
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
                          if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
                          MySleep(1000);
                          BalloonMessage (3000,message0,str,AFont);
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
                                                                             popen (f,BinDir+'cat '+VarRunDir+'ppp-'+Form1.Memo_Config.Lines[0]+'.pid|'+BinDir+'grep ppp','R');
                                                                             While not eof(f) do
                                                                                              begin
                                                                                                   Readln (f,str);
                                                                                                   If str<>'' then PppIface:=str;
                                                                                              end;
                                                                             PClose(f);
                                                                             If PppIface<>'' then
                                                                                    begin
                                                                                         popen (f,SBinDir+'ifconfig |'+BinDir+'grep '+PppIface,'R');
                                                                                         If not eof(f) then If PppIface<>'' then Code_up_ppp:=true;
                                                                                         PClose(f);
                                                                                    end;
                                                                      end;
end;

procedure TForm1.ClearEtc_hosts;
//очистка /etc/hosts от старых мешающих записей
var
   Str_Etc_hosts:string;
begin
If FileExists (EtcDir+'hosts') then
    begin
        If not FileExists (EtcDir+'hosts.old') then FpSystem (BinDir+'cp -f '+EtcDir+'hosts '+EtcDir+'hosts.old');
        AssignFile (FileEtc_hosts,EtcDir+'hosts');
        reset (FileEtc_hosts);
        While not eof(FileEtc_hosts) do
               begin
                   readln(FileEtc_hosts, Str_Etc_hosts);
                   If not (RightStr(Str_Etc_hosts,Length(Form1.Memo_Config.Lines[1]))=Form1.Memo_Config.Lines[1]) then
                                  FpSystem(UsrBinDir+'printf "'+Str_Etc_hosts+'\n" >> '+MyTmpDir+'hosts.tmp');
               end;
        closefile (FileEtc_hosts);
        FpSystem(BinDir+'cp -f '+MyTmpDir+'hosts.tmp '+EtcDir+'hosts');
        FpSystem(BinDir+'rm -f '+MyTmpDir+'hosts.tmp');
        FpSystem(BinDir+'chmod 0644 '+EtcDir+'hosts');
    end;
end;

procedure TForm1.MakeDefaultGW;
//определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сетевой интерфейс, на котором настроено VPN
var
  nodefaultgw:boolean;
begin
  nodefaultgw:=false;
  popen (f,SBinDir+'ip r|'+BinDir+'grep default|'+BinDir+'awk '+ chr(39)+'{print $3}'+chr(39),'R');
  If eof(f) then nodefaultgw:=true;
  PClose(f);
  If nodefaultgw then //исправление default и повторная проверка
                      begin
                          FpSystem (SBinDir+'route add default gw '+Form1.Memo_Config.Lines[2]+' dev '+Form1.Memo_Config.Lines[3]);
                          nodefaultgw:=false;
                          popen (f,SBinDir+'ip r|'+BinDir+'grep default|'+BinDir+'awk '+ chr(39)+'{print $3}'+chr(39),'R');
                          If eof(f) then nodefaultgw:=true;
                          PClose(f);
                     end;
  If nodefaultgw then
                     begin
                         If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networking') or (NetServiceStr='networkmanager') then
                                                                                                begin
                                                                                                    A_Process.Active:=false;
                                                                                                    A_Process.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                                                                                                    A_Process.Execute;
                                                                                                end;
                          Ifdown(Form1.Memo_Config.Lines[3]);
                          If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep (3000);
                          Ifup(Form1.Memo_Config.Lines[3]);
                          Ifup('lo');
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
               BalloonMessage (3000,message0,message45+' '+message46,AFont);
               Application.ProcessMessages;
           end;
   FlagLengthSyslog:=true;
   //Проверяем размер файла-лога /var/log/vpnlog
   If not FlagLengthVpnlog then If FileExists(VarLogDir+'vpnlog') then If FileSize(VarLogDir+'vpnlog')>1073741824 then // >1 Гб
            begin
                BalloonMessage (3000,message0,message65+' '+message46,AFont);
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
 popen (f,SBinDir+'ip r|'+BinDir+'grep ppp|'+BinDir+'awk '+ chr(39)+'{print $3}'+chr(39),'R');
 While not eof(f) do
    begin
        Readln (f,RealPppIface);
    end;
 PClose(f);
 RealPppIfaceDefault:='';
 popen (f,SBinDir+'ip r|'+BinDir+'grep default|'+BinDir+'grep ppp|'+BinDir+'awk '+ chr(39)+'{print $3}'+chr(39),'R');
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
                                                FpSystem (SBinDir+'route del default');
                                            FpSystem (SBinDir+'route add default dev '+RealPppIface);
                                       end;
                               end;
  If RealPppIface<>'' then if LeftStr(RealPppIface,3)='ppp' then
                               begin
                                  If Memo_Config.Lines[29]='pppnotdefault-yes' then
                                           begin
                                             For h:=1 to CountInterface do
                                                 FpSystem (SBinDir+'route del default dev '+RealPppIface);
                                             FpSystem (SBinDir+'route add default gw '+Memo_config.Lines[2]+' dev '+Memo_config.Lines[3]);
                                             NoInternet:=false;//считаем, что типа при этом есть интернет
                                           end;
                               end;
end;
If Code_up_ppp then If FileExists (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after') then If FileExists (EtcDir+'resolv.conf') then
                       If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after', EtcDir+'resolv.conf') then
                                            FpSystem (BinDir+'cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after '+EtcDir+'resolv.conf');
If not Code_up_ppp then If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
//Проверяем используемое mtu
If not Code_up_ppp then FlagMtu:=false;
MtuUsed:='';
If Code_up_ppp then If not FlagMtu then If not FileExists (MyTmpDir+'mtu.checked') then
   begin
     popen (f,SBinDir+'ifconfig '+PppIface+'|'+BinDir+'grep MTU |'+BinDir+'awk '+ chr(39)+'{print $6}'+chr(39),'R');
     While not eof(f) do
        begin
          Readln (f,MtuUsed);
        end;
     PClose(f);
     If MtuUsed<>'' then If Length(MtuUsed)>=4 then MtuUsed:=RightStr(MtuUsed,Length(MtuUsed)-4);
     If MtuUsed<>'' then If StrToInt(MtuUsed)>1460 then
        begin
             BalloonMessage (3000,message0,message43+' '+MtuUsed+' '+message44,AFont);
             FpSystem(BinDir+'touch '+MyTmpDir+'mtu.checked');
             Application.ProcessMessages;
        end;
        FlagMtu:=true;
   end;
//обработка случая когда RemoteIPaddress совпадается с ip-адресом самого vpn-сервера
If Code_up_ppp then If Memo_Config.Lines[46]<>'route-IP-remote-yes' then
               If FileExists(MyLibDir+Memo_Config.Lines[0]+'/hosts') then If Memo_config.Lines[22]='routevpnauto-yes' then
                            if Memo_config.Lines[21]='IPS-no' then
                                      begin
                                         popen (f,SBinDir+'ifconfig '+PppIface+'|'+BinDir+'grep P-t-P|'+BinDir+'awk '+chr(39)+'{print $3}'+chr(39),'R');
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
                                                                                                            BalloonMessage (3000,message0,str,AFont);
                                                                                                            Application.ProcessMessages;
                                                                                                            If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
                                                                                                            //изменение скрипта имя_соединения-ip-up
                                                                                                            If FileExists(EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up') then
                                                                                                                                               FpSystem (UsrBinDir+'printf "'+SBinDir+'route add -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up');
                                                                                                            //изменение скрипта имя_соединения-ip-down
                                                                                                            if FileExists(EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down') then
                                                                                                                                                        FpSystem (UsrBinDir+'printf "'+SBinDir+'route del -host \$IPREMOTE gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down');
                                                                                                            FpSystem(BinDir+'rm -f '+MyLibDir+Memo_Config.Lines[0]+'/hosts');
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
                                 FpSystem (BinDir+'cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
//проверка технической возможности поднятия соединения
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[30]<>'none' then
                            begin //тест dns1-сервера
                            Application.ProcessMessages;
                            popen (f,BinDir+'ping -c1 '+Memo_config.Lines[30]+'|'+BinDir+'grep '+chr(39)+'1 received'+chr(39),'R');
                            Application.ProcessMessages;
                            If eof(f) then
                                                              begin
                                                                   NoPingDNS1:=true;
                                                                   BalloonMessage (3000,message0,message23,AFont);
                                                              end;
                            PClose(f);
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then If Memo_config.Lines[31]<>'none' then
                            begin //тест dns2-сервера
                                 Application.ProcessMessages;
                                 popen (f,BinDir+'ping -c1 '+Memo_config.Lines[31]+'|'+BinDir+'grep '+chr(39)+'1 received'+chr(39),'R');
                                 Application.ProcessMessages;
                                 If eof(f) then
                                                                   begin
                                                                        NoPingDNS2:=true;
                                                                        BalloonMessage (3000,message0,message24,AFont);
                                                                   end;
                                 PClose(f);
                            end;
If not Code_up_ppp then If ((Memo_Config.Lines[23]='networktest-yes') and (BindUtils)) or ((Memo_Config.Lines[23]='networktest-yes') and (Memo_config.Lines[22]='routevpnauto-no')) then
                            begin //тест vpn-сервера
                                 Application.ProcessMessages;
                                 popen (f,BinDir+'ping -c1 '+Memo_config.Lines[1]+'|'+BinDir+'grep '+Memo_config.Lines[1]+'|'+BinDir+'awk '+chr(39)+'{print $3}'+chr(39)+'|'+BinDir+'grep '+chr(39)+'('+chr(39),'R');
                                 Application.ProcessMessages;
                                 If eof(f) then NoPingIPS:=true;
                                 PClose(f);
                            end;
If not Code_up_ppp then If Memo_Config.Lines[23]='networktest-yes' then
                            begin //тест шлюза локальной сети
                                 Application.ProcessMessages;
                                 popen (f,BinDir+'ping -c1 '+Memo_config.Lines[2]+'|'+BinDir+'grep '+chr(39)+'1 received'+chr(39),'R');
                                 Application.ProcessMessages;
                                 If eof(f) then NoPingGW:=true;
                                 PClose(f);
                            end;
If not Code_up_ppp then DhclientStart:=false;
If not Code_up_ppp then If link=1 then If Memo_Config.Lines[9]='dhcp-route-yes' then //старт dhclient
                           begin
                              AProcessDhclient.Active:=false;
                              AProcessDhclient.CommandLine :=SBinDir+'dhclient '+Memo_Config.Lines[3];
                              Application.ProcessMessages;
                              If not NoPingIPS then If not NoDNS then If not NoPingGW then
                              begin
                                For h:=1 to CountInterface do
                                                            FpSystem (SBinDir+'route del default');
                                FpSystem (SBinDir+'route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
                                If not DhclientStart then
                                                      begin
                                                           if fedora then FpSystem(UsrBinDir+'killall dhclient');
                                                          AProcessDhclient.Execute;
                                                           Mysleep(StrToInt(Memo_Config.Lines[5]) div 3);
                                                           Application.ProcessMessages;
                                                      end;
                                DhclientStart:=true;
                              end;
                              If link=1 then If NoInternet then //проверка поднялся ли интерфейс после dhclient
                              begin
                                   none:=false;
                                   popen (f,SBinDir+'ip r|'+BinDir+'grep '+Memo_Config.Lines[3],'R');
                                   If eof(f) then none:=true;
                                   PClose(f);
                                   if none then
                                      begin
                                         Mysleep(StrToInt(Memo_Config.Lines[5]) div 3);
                                         none:=false;
                                         popen (f,SBinDir+'ip r|'+BinDir+'grep '+Memo_Config.Lines[3],'R');
                                         If eof(f) then none:=true;
                                         PClose(f);
                                         if none then
                                                 begin
                                                      Ifup(Form1.Memo_Config.Lines[3]);
                                                      DhclientStart:=false;
                                                 end;
                                      end;
                              end;
                           end;
  //определение и сохранение всех актуальных в данный момент ip-адресов vpn-сервера с занесением маршрутов везде
  If not FileExists(MyLibDir+Memo_Config.Lines[0]+'/hosts') then NewIPS:=false;
  if BindUtils then Str:=UsrBinDir+'host '+Memo_config.Lines[1]+'|'+BinDir+'grep address|'+BinDir+'grep '+Memo_config.Lines[1]+'|'+BinDir+'awk '+ chr(39)+'{print $4}'+chr(39);
  if not BindUtils then Str:=BinDir+'ping -c1 '+Memo_config.Lines[1]+'|'+BinDir+'grep '+Memo_config.Lines[1]+'|'+BinDir+'awk '+chr(39)+'{print $3}'+chr(39)+'|'+BinDir+'grep '+chr(39)+'('+chr(39);
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
                                                  If Memo_Config.Lines[41]='etc-hosts-yes' then FpSystem (UsrBinDir+'printf "'+Str_networktest+' '+Memo_config.Lines[1]+'\n" >> '+EtcDir+'hosts');
                                                  If NewIPS then
                                                     begin //определился новый, неизвестный ранее ip-адрес vpn-сервера
                                                        FpSystem(UsrBinDir+'printf "'+Str_networktest+'\n'+'" >> '+MyLibDir+Memo_Config.Lines[0]+'/hosts');
                                                        FpSystem (SBinDir+'route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]);
                                                        //изменение скрипта имя_соединения-ip-up
                                                        If FileExists(EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up') then
                                                                                        FpSystem (UsrBinDir+'printf "'+SBinDir+'route add -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpUpDDir+Memo_Config.Lines[0]+'-ip-up');
                                                        //изменение скрипта имя_соединения-ip-down
                                                        if FileExists(EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down') then
                                                                                        FpSystem (UsrBinDir+'printf "'+SBinDir+'route del -host ' + Str_networktest + ' gw '+ Memo_config.Lines[2]+ ' dev '+ Memo_config.Lines[3]+'\n" >> '+EtcPppIpDownLDir+Memo_Config.Lines[0]+'-ip-down');
                                                    end;
                                              end;
                                           PClose(f);
                                    end;
If Code_up_ppp then If link<>1 then //когда связи по факту нет, но в NetApplet и в ifconfig ppp0 числится, а pppd продолжает сидеть в процессах
                               begin
                                 MenuItem2Click(Self);
                                 LoadIconForTray(MyDataDir,'off.ico');
                                 exit;
                               end;

If Code_up_ppp then Timer1.Interval:=StrToInt64(Memo_Config.Lines[4]) else Timer1.Interval:=StrToInt64(Memo_Config.Lines[5]);
If Code_up_ppp then If Timer1.Interval=0 then Timer1.Interval:=1000;

If not Code_up_ppp then If link=3 then
                                  begin
                                   MenuItem2Click(Self);
                                   LoadIconForTray(MyDataDir,'off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                                                                Form3.MyMessageBox(message0,message9,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                                                                MenuItem2Click(Self);
                                                                FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                                                                halt;
                                                              end;
                                  end;
If not Code_up_ppp then If link=2 then
                                  begin
                                   MenuItem2Click(Self);
                                   LoadIconForTray(MyDataDir,'off.ico');
                                       If Memo_Config.Lines[4]='0' then
                                                              begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                                                                Form3.MyMessageBox(message0,message9,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                                                                MenuItem2Click(Self);
                                                                FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                                                                halt;
                                                              end;
                                  end;
If not Code_up_ppp then If ((link=2) or (link=3)) then
                           begin
                                  Application.ProcessMessages;
                                  If NoPingDNS1 then BalloonMessage (3000,message0,message23,AFont);
                                  If NoPingDNS2 then BalloonMessage (3000,message0,message24,AFont);
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
                                  If (NoPingIPS) or (NoPingGW) or (NoDNS) then BalloonMessage (3000,message0,str,AFont);
                           end;
If not Code_up_ppp then If link=1 then
                           begin
                                  Form1.MenuItem2Click(Self);//на всякий случай отключаем вдруг созданное ppp
                                  Application.ProcessMessages;
                                  If NoPingDNS1 then BalloonMessage (3000,message0,message23,AFont);
                                  If NoPingDNS2 then BalloonMessage (3000,message0,message24,AFont);
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
                                  BalloonMessage (3000,message0,str,AFont);
                                  Application.ProcessMessages;
                                  If NoPingIPS or NoDNS then
                                                   begin
                                                      For h:=1 to CountInterface do
                                                                                FpSystem (SBinDir+'route del default');
                                                      Ifdown(Memo_Config.Lines[3]);
                                                      Ifup(Form1.Memo_Config.Lines[3]);
                                                   end;
                                  If not NoPingIPS then If not NoDNS then If not NoPingGW then
                                                   begin
                                                      If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
                                                           If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                                                               FpSystem (BinDir+'cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
                                                      TrafficRX:=0;
                                                      TrafficTX:=0;
                                                      RXbyte0:='0';
                                                      TXbyte0:='0';
                                                      RXbyte1:='0';
                                                      TXbyte1:='0';
                                                      ObnullRX:=0;
                                                      ObnullTX:=0;
                                                      DoSpeedCount:=false;
                                                      FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullRX');
                                                      FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullTX');
                                                      If not FileExists(MyTmpDir+'DateStart') then DateStart:=0;
                                                      If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo');
                                                      For h:=1 to CountInterface do
                                                                          FpSystem (SBinDir+'route del default');
                                                      FpSystem (SBinDir+'route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
                                                      DoubleRunPonoff:=false;
                                                      If Memo_Config.Lines[39]='pptp' then
                                                                                    FpSystem (UsrSBinDir+'pppd call '+Memo_Config.Lines[0]);
                                                      If Memo_Config.Lines[39]='l2tp' then
                                                                                          begin
                                                                                              //проверка xl2tpd в процессах
                                                                                              popen(f,BinDir+'ps -A | '+BinDir+'grep xl2tpd','R');
                                                                                              If eof(f) then
                                                                                                            begin
                                                                                                                 FpSystem (ServiceCommand+'xl2tpd stop');
                                                                                                                 A_Process.Active:=false;
                                                                                                                 A_Process.CommandLine :=ServiceCommand+'xl2tpd start';
                                                                                                                 A_Process.Execute;
                                                                                                                 while A_Process.Running do
                                                                                                                                         MySleep(30);
                                                                                                             end;
                                                                                               PClose(f);
                                                                                               FpSystem (BinDir+'echo "c '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
                                                                                          end;
                                                       If Memo_Config.Lines[39]='openl2tp' then FpSystem(BinDir+'sh '+MyLibDir+Memo_Config.Lines[0]+'/openl2tp-start');
                                                   end;
                                  If Memo_Config.Lines[9]='dhcp-route-yes' then
                                                begin
                                                    Timer1.Enabled:=false;
                                                    Timer2.Enabled:=false;
                                                    AProcessDhclient.WaitOnExit;
                                                    Timer1.Enabled:=true;
                                                    Timer2.Enabled:=true;
                                                end;
                           end;
Application.ProcessMessages;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  link:byte; //1-link ok, 2-no link, 3-none
  i,j,h,ii,zero,Xa,Yb:integer;
  str,stri,StrObnull:string;
  FileObnull:textfile;
begin
  ErrorShowIcon:=false;
  tray_status:=col_on;
  A_Process := TAsyncProcess.Create(self);
  AProcessDhclient := TAsyncProcess.Create(self);
  AProcessNet_Monitor := TAsyncProcess.Create(self);
  IconTmp:= TIcon.create;
  TmpBmp := TBitmap.Create;
  file1 := TMemoryStream.Create;
  file2 := TMemoryStream.Create;
  ImageIconBitmap:= TBitmap.create;
  with Widget.IniPropStorage1 do
  begin
    // Если значение в конфиге пустое, то заполняем по умолчанию
    if (ReadString ('black_and_white_icon','null')<>false_str)
       and
       (ReadString ('black_and_white_icon','null')<>true_str)
       then StoredValue['black_and_white_icon']:=false_str;     // Таким образом сохраняем значение переменной в конфиг
    if (ReadString ('Widget','null')<>false_str)
       and
       (ReadString ('Widget','null')<>true_str)
       then StoredValue['Widget']:=false_str;
    Save;
  end;
  if Widget.IniPropStorage1.ReadString ('Widget','null')=true_str then EnablePseudoTray:=true else EnablePseudoTray:=false;

  Timer1.Enabled:=False;
  Timer2.Enabled:=False;
  If not ProgrammRoot('ponoff',false) then
                          begin
                               Form1.Hide;
                               if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                               Application.ProcessMessages;
                          end;
  if EnablePseudoTray then
  begin
    TrayIcon1.Visible:=false;
    Widget.Show;
  end;
  Application.CreateForm(TFormHintMatrix, FormHintMatrix);
  Application.CreateForm(TFormBalloonMatrix, FormBalloonMatrix);
  RestartPonoff;
  Timer1.Enabled:=true;
  Timer2.Enabled:=true;
  if FileSize(MyLibDir+'profiles')=0 then FpSystem (BinDir+'rm -f '+MyLibDir+'profiles');
  if FileSize(MyLibDir+'default/default')=0 then FpSystem (BinDir+'rm -f '+MyLibDir+'default/default');
  If FileExists (SBinDir+'service') then ServiceCommand:=SBinDir+'service ';
  If FileExists (UsrSBinDir+'service') then ServiceCommand:=UsrSBinDir+'service ';
  If not FileExists (SBinDir+'service') then if not FileExists (UsrSBinDir+'service') then ServiceCommand:=EtcInitDDir;
  DoubleRunPonoff:=false;
  StartMessage:=true;
  ubuntu:=false;
  debian:=false;
  fedora:=false;
  suse:=false;
  mandriva:=false;
  Application.ShowMainForm:=false;
  Application.Minimize;
  If FileExists (MyPixmapsDir+'ponoff.png') then Image1.Picture.LoadFromFile(MyPixmapsDir+'ponoff.png');
  Panel1.Caption:=message37+' '+message38;
  Plus.Caption:=message66;
  Minus.Caption:=message67;
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
                              if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                              Form3.MyMessageBox(message0,message56+' '+ProfileName+' '+message57,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                              FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                              halt;
                           end;
  If ProfileName<>'' then if not DirectoryExists(MyLibDir+ProfileName) then
                                                   begin
                                                     Timer1.Enabled:=False;
                                                     Timer2.Enabled:=False;
                                                     Form1.Hide;
                                                     if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                                                     Form3.MyMessageBox(message0,message50+' '+ProfileName+'. ','','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                                                     FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                                                     halt;
                                                   end;
  If ProfileName='' then if FileExists(MyLibDir+'profiles') then if not FileExists(MyLibDir+'default/default') then
                                                            begin
                                                                Timer1.Enabled:=False;
                                                                Timer2.Enabled:=False;
                                                                Form1.Hide;
                                                                if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                                                                Form3.MyMessageBox(message0,message53+' '+message54+' '+message55,'',message33,message36,MyPixmapsDir+'ponoff.png',false,true,true,AFont,Form1.Icon,true,MyLibDir,2);
                                                                If Form3.Tag=2 then If Form3.ComboBoxProfile.Text<>'' then
                                                                                                  begin
                                                                                                        ProfileName:=Form3.ComboBoxProfile.Text;
                                                                                                        FpSystem (BinDir+'mkdir -p '+MyLibDir+'default');
                                                                                                        FpSystem (BinDir+'echo "'+ProfileName+'" > '+MyLibDir+'default/default');
                                                                                                  end;
                                                                If (Form3.Tag=0) or (Form3.Tag=3) or (Form3.ComboBoxProfile.Text='') then
                                                                                                                                     begin
                                                                                                                                          FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                                                                                                                                          halt;
                                                                                                                                     end;
                                                                Timer1.Enabled:=true;
                                                                Timer2.Enabled:=true;
                                                                if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
                                                            end;
  If not FileExists(MyTmpDir) then FpSystem (BinDir+'mkdir -p '+MyTmpDir);
  //обеспечение совместимости старого config с новым
  If FileExists(MyLibDir+ProfileName+'/config') then
     begin
        Memo_config.Lines.LoadFromFile(MyLibDir+ProfileName+'/config');
        If Memo_config.Lines.Count<Config_n then
                                            begin
                                               for i:=Memo_config.Lines.Count to Config_n do
                                                  FpSystem(UsrBinDir+'printf "none\n" >> '+MyLibDir+ProfileName+'/config');
                                            end;
     end;
  //обеспечение совместимости старого general.conf с новым
  If FileExists(MyLibDir+'general.conf') then
          begin
             Memo_General_conf.Lines.LoadFromFile(MyLibDir+'general.conf');
             If Memo_General_conf.Lines.Count<General_conf_n then
                                                 begin
                                                    for i:=Memo_General_conf.Lines.Count to General_conf_n do
                                                       FpSystem(UsrBinDir+'printf "none\n" >> '+MyLibDir+'general.conf');
                                                 end;
          end;
 If FileExists(MyLibDir+'general.conf') then begin Memo_General_conf.Lines.LoadFromFile(MyLibDir+'general.conf');end
          else
           begin
            Timer1.Enabled:=False;
            Timer2.Enabled:=False;
            Form1.Hide;
            if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
            Form3.MyMessageBox(message0,message3+' '+message26,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
            FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
            halt;
           end;
  If FileExists(MyLibDir+ProfileName+'/config') then begin Memo_Config.Lines.LoadFromFile(MyLibDir+ProfileName+'/config');end
  else
   begin
    Timer1.Enabled:=False;
    Timer2.Enabled:=False;
    Form1.Hide;
    if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
    Form3.MyMessageBox(message0,message3+' '+message26,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
    FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
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
                                                       popen (f,BinDir+'ps -e |'+BinDir+'grep NetworkManager','R');
                                                       if not eof(f) then NetServiceStr:='NetworkManager';
                                                       PClose(f);
                                                    end;
  If FileExists (EtcInitDDir+'NetworkManager') then
                                                    begin
                                                       popen (f,BinDir+'ps -e |'+BinDir+'grep NetworkManager','R');
                                                       if not eof(f) then NetServiceStr:='NetworkManager';
                                                       PClose(f);
                                                    end;
  If FileExists (EtcInitDDir+'networkmanager') then
                                                    begin
                                                       popen (f,BinDir+'ps -e |'+BinDir+'grep networkmanager','R');
                                                       if not eof(f) then NetServiceStr:='networkmanager';
                                                       PClose(f);
                                                    end;
  If NetServiceStr='none' then
                            begin
                               Form1.Timer1.Enabled:=False;
                               Form1.Timer2.Enabled:=False;
                               Form1.Hide;
                               if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                               Form3.MyMessageBox(message0,message2,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                               Form1.Timer1.Enabled:=true;
                               Form1.Timer2.Enabled:=true;
                               if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
                               Application.ProcessMessages;
                            end;
//проверка ponoff в процессах root, обработка двойного запуска программы
popen (f,BinDir+'ps -u root | '+BinDir+'grep ponoff | '+BinDir+'awk '+chr(39)+'{print $4}'+chr(39),'R');
i:=0;
while not eof(f) do
begin
    readln(f,str);
    i:=i+1;
end;
PClose(f);
If i=1 then
     begin
        FpSystem(BinDir+'rm -rf '+VarRunVpnpptp);
        FpSystem(BinDir+'mkdir -p '+VarRunVpnpptp);
        FpSystem(BinDir+'echo "'+ProfileName+'" > '+VarRunVpnpptp+ProfileName);
     end;
If i>1 then
              begin
                  DoubleRunPonoff:=true;
                  Apid:=FpGetpid;
                  popen(f1,BinDir+'cat '+VarRunVpnpptp+'*','R');
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
                                if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                                Form3.MyMessageBox(message0,message51+' '+stri+'. '+message52,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                                FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                                halt;
                             end;
               popen(f,BinDir+'ps -e|'+BinDir+'grep ponoff|'+BinDir+'awk '+chr(39)+'{print$1}'+chr(39),'R');
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
If Code_up_ppp then LoadIconForTray(MyDataDir,'on.ico');
If not Code_up_ppp then LoadIconForTray(MyDataDir,'off.ico');
Application.ProcessMessages;
if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
Xa:=0;
Yb:=0;
if EnablePseudoTray then Xa:=Widget.Left else Xa:=Form1.TrayIcon1.GetPosition.X;
if EnablePseudoTray then Yb:=Widget.Top else Yb:=Form1.TrayIcon1.GetPosition.Y;
If (Xa=0) and (Yb=0) and (not (Memo_Config.Lines[27]='autostart-ponoff-yes')) then mysleep(10000);
If (Xa=0) and (Yb=0) and (Memo_Config.Lines[27]='autostart-ponoff-yes') then mysleep(10000);
if EnablePseudoTray then Xa:=Widget.Left else Xa:=Form1.TrayIcon1.GetPosition.X;
if EnablePseudoTray then Yb:=Widget.Top else Yb:=Form1.TrayIcon1.GetPosition.Y;
//Xa:=0; Yb:=0; //для отладки
If Xa=0 then if Yb=0 then
     begin
          Timer1.Enabled:=False;
          Timer2.Enabled:=False;
          Form1.Hide;
          Form3.MyMessageBox(message0,message71,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
          FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
          ErrorShowIcon:=true;
          If not FileExists(MyLibDir+'ponoff.conf.ini') then
                 begin
                    FpSystem(UsrBinDir+'printf "'+'[TApplication.Widget]'+'\n" >> '+MyLibDir+'ponoff.conf.ini');
                    FpSystem(UsrBinDir+'printf "'+'Widget=true'+'\n" >> '+MyLibDir+'ponoff.conf.ini');
                 end;
          If FileExists(MyLibDir+'ponoff.conf.ini') then
                           begin
                              Memo_ponoff_conf_ini.Lines.LoadFromFile(MyLibDir+'ponoff.conf.ini');
                              For ii:=0 to Memo_ponoff_conf_ini.Lines.Count-1 do
                                           If Memo_ponoff_conf_ini.Lines[ii]='Widget=false' then Memo_ponoff_conf_ini.Lines[ii]:='Widget=true';
                              Memo_ponoff_conf_ini.Lines.SaveToFile(MyLibDir+'ponoff.conf.ini');
                           end;
          RestartPonoff;
     end;
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
             popen(f,SBinDir+'ip r|'+BinDir+'grep dsl','R');
             If not eof(f) then
                                         begin
                                           Timer1.Enabled:=False;
                                           Timer2.Enabled:=False;
                                           Form1.Hide;
                                           if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                                           Form3.MyMessageBox(message0,message41,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                                           PClose(f);
                                           FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
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
   popen (f,SBinDir+'mii-tool '+Memo_Config.Lines[3]+'|'+BinDir+'awk '+chr(39)+'{print $3}'+chr(39),'R');
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
                   A_Process.Active:=false;
                   A_Process.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                   A_Process.Execute;
                   For h:=1 to CountInterface do
                                          FpSystem (SBinDir+'route del default');
                   Ifdown(Memo_Config.Lines[3]);
                   Mysleep(3000);
                   Ifup(Memo_Config.Lines[3]);
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
                 if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                 Form3.MyMessageBox(message0,message4+' '+message47,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                 FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
                 halt;
                end;
   if link=2 then
                begin
                 Form3.MyMessageBox(message0,message5,'','',message33,MyPixmapsDir+'ponoff.png',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
                 Timer1.Enabled:=False;
                 Timer2.Enabled:=False;
                 if EnablePseudoTray then if Widget.Showing then Widget.Hide else if Form1.TrayIcon1.Visible then Form1.TrayIcon1.Hide;
                 FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
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

procedure TForm1.FormDestroy(Sender: TObject);
begin
  A_Process.Free;
  AProcessDhclient.Free;
  AProcessNet_Monitor.Free;
  ImageIconBitmap.Free;
  IconTmp.Free;
  TmpBmp.Free;
  file2.Free;
  file1.Free;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Form1.Hide;
end;

procedure TForm1.ColorIconClick(Sender: TObject);
begin
  If Code_up_ppp then LoadIconForTray(MyDataDir,'on.ico');
  If not Code_up_ppp then LoadIconForTray(MyDataDir,'off.ico');
  if  Widget.IniPropStorage1.ReadString ('black_and_white_icon','null')=true_str  then  Widget.IniPropStorage1.StoredValue['black_and_white_icon']:=false_str ;
  if  Widget.IniPropStorage1.ReadString ('black_and_white_icon','null')=false_str then  Widget.IniPropStorage1.StoredValue['black_and_white_icon']:=true_str  ;
  Widget.IniPropStorage1.Save;
  If Widget.IniPropStorage1.ReadString ('black_and_white_icon','null')=true_str then
  begin
    PopupMenu1.Items[1].Caption:=message68;
    tray_status:=bw_on;
  end
  else
  begin
    PopupMenu1.Items[1].Caption:=message69;
    tray_status:=bw_off;
  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
 //просто убивает pppd и других демонов и удаляет временные файлы
var
   str:string;
begin
 If DoubleRunPonoff then exit;
//проверка наличия в процессах демона pppd
 popen(f,BinDir+'ps -u root | '+BinDir+'grep pppd | '+BinDir+'awk '+chr(39)+'{print $4}'+chr(39),'R');
 Application.ProcessMessages;
 str:='';
 while not eof(f) do
   begin
     readln(f,str);
     If str<>'' then If (LeftStr(str,4)='pppd') then
                                        begin
                                             If Memo_Config.Lines[39]<>'openl2tp' then If FileExists(MyLibDir+'default/openl2tp-stop') then FpSystem(BinDir+'sh '+MyLibDir+'default/openl2tp-stop');
                                             FpSystem(UsrBinDir+'killall pppd');
                                             If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then
                                                                                  begin
                                                                                       A_Process.Active:=false;
                                                                                       A_Process.CommandLine :=ServiceCommand+NetServiceStr+' restart';
                                                                                       A_Process.Execute;
                                                                                       Mysleep(3000);
                                                                                  end;
                                        end;
   end;
 PClose(f);
 If Memo_Config.Lines[39]='pptp' then
                                 begin
                                      FpSystem (ServiceCommand+'xl2tpd stop');
                                      FpSystem (UsrBinDir+'killall xl2tpd');
                                 end;
 If Memo_Config.Lines[39]='openl2tp' then FpSystem(BinDir+'sh '+MyLibDir+Memo_Config.Lines[0]+'/openl2tp-stop');
 FpSystem(UsrBinDir+'killall openl2tpd');
 FpSystem(UsrBinDir+'killall openl2tp');
 FpSystem(UsrBinDir+'killall l2tpd');
 Application.ProcessMessages;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
//выход без аварии
var h:integer;
begin
 DoubleRunPonoff:=false;
 Timer1.Enabled:=False;
 Timer2.Enabled:=False;
 FpSystem (UsrBinDir+'killall net_monitor');
 If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  MenuItem2Click(Self);
  If Memo_Config.Lines[39]='l2tp' then FpSystem (BinDir+'echo "d '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
  LoadIconForTray(MyDataDir,'off.ico');
  Application.ProcessMessages;
  For h:=1 to CountInterface do
              FpSystem (SBinDir+'route del default');
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo');
  FpSystem(BinDir+'rm -f '+MyTmpDir+'xl2tpd.conf');
  If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
         If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                         FpSystem (BinDir+'cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
  FpSystem (SBinDir+'route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
  FpSystem (BinDir+'rm -f '+MyTmpDir+'DateStart');
  FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullRX');
  FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullTX');
  FpSystem (BinDir+'rm -f '+MyTmpDir+'mtu.checked');
  MakeDefaultGW;
  FpSystem(BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
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
  FpSystem (UsrBinDir+'killall net_monitor');
  If Memo_Config.Lines[41]='etc-hosts-yes' then ClearEtc_hosts;
  If FileExists(MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before') then If FileExists(EtcDir+'resolv.conf') then
          If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before', EtcDir+'resolv.conf') then
                            FpSystem (BinDir+'cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.before '+EtcDir+'resolv.conf');
  MenuItem2Click(Self);
  If Memo_Config.Lines[39]='l2tp' then FpSystem (BinDir+'echo "d '+Memo_Config.Lines[0]+'" > '+VarRunXl2tpdDir+'l2tp-control');
  LoadIconForTray(MyDataDir,'off.ico');
  Application.ProcessMessages;
  For i:=0 to 9 do
      begin
        Ifdown('eth'+IntToStr(i));
        Ifdown('wlan'+IntToStr(i));
        Ifdown('br'+IntToStr(i));
        Ifdown('em'+IntToStr(i));
      end;
  FpSystem (ServiceCommand+NetServiceStr+' restart'); // организация конкурса интерфейсов
  If (NetServiceStr='network-manager') or (NetServiceStr='NetworkManager') or (NetServiceStr='networkmanager') then Mysleep(3000);
  If (Memo_Config.Lines[30]='127.0.0.1') or (Memo_Config.Lines[31]='127.0.0.1') then Ifup('lo');
  FpSystem (SBinDir+'route add default gw '+Memo_Config.Lines[2]+' dev '+Memo_Config.Lines[3]);
 //определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сеть своим алгоритмом
  popen(f,SBinDir+'ip r|'+BinDir+'grep default|'+BinDir+'awk '+ chr(39)+'{print $3}'+chr(39),'R');
  If eof(f) then
     begin
         For i:=0 to 9 do
             begin
              Ifdown('eth'+IntToStr(i));
              Ifdown('wlan'+IntToStr(i));
              Ifdown('br'+IntToStr(i));
              Ifdown('em'+IntToStr(i));
             end;
            FpSystem (ServiceCommand+NetServiceStr+' restart');
            For i:=0 to 9 do
                 begin
                    Ifup('eth'+IntToStr(i));
                    Ifup('wlan'+IntToStr(i));
                    Ifup('br'+IntToStr(i));
                    Ifup('em'+IntToStr(i));
                 end;
           Ifup('lo');
     end;
  PClose(f);
  FpSystem (BinDir+'rm -f '+MyTmpDir+'DateStart');
  FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullRX');
  FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullTX');
  FpSystem (BinDir+'rm -f '+MyTmpDir+'mtu.checked');
  FpSystem (BinDir+'rm -f '+VarRunVpnpptp+ProfileName);
  halt;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  Application.ProcessMessages;
  if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  If Code_up_ppp then
             begin
                AProcessNet_Monitor.Active:=false;
                AProcessNet_Monitor.CommandLine := UsrBinDir+'net_monitor -i '+PppIface;
                AProcessNet_Monitor.Execute;
             end;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  If Form3.Visible then exit;
  Form3.MyMessageBox(message0+' '+message62,'','','',message33,'',false,false,true,AFont,Form1.Icon,false,MyLibDir,3);
end;

procedure TForm1.MinusClick(Sender: TObject);
begin
  IconForTrayMinus;
end;

procedure TForm1.PlusClick(Sender: TObject);
begin
  IconForTrayPlus;
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
  If not FileExists (VarRunVpnpptp+ProfileName) then FpSystem (BinDir+'echo "'+ProfileName+'" > '+VarRunVpnpptp+ProfileName);
  Application.ProcessMessages;
  if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  If Code_up_ppp then MenuItem6.Enabled:=true else MenuItem6.Enabled:=false;
  //определяем скорость, время
  If Code_up_ppp then
            begin
                popen (f,SBinDir+'ifconfig '+PppIface+'|'+BinDir+'grep RX|'+BinDir+'grep bytes|'+BinDir+'awk '+chr(39)+'{print $2}'+chr(39),'R');
                RXbyte1:='0';
                While not eof(f) do
                   begin
                     Readln (f,RXbyte1);
                   end;
                PClose(f);
                If RXbyte1='' then RXbyte1:='0';
                popen (f,SBinDir+'ifconfig '+PppIface+'|'+BinDir+'grep TX|'+BinDir+'grep bytes|'+BinDir+'awk '+chr(39)+'{print $6}'+chr(39),'R');
                TXbyte1:='0';
                While not eof(f) do
                   begin
                     Readln (f,TXbyte1);
                   end;
                PClose(f);
                If TXbyte1='' then TXbyte1:='0';
                If RXbyte1<>'0' then Delete(RXbyte1,1,6);
                If TXbyte1<>'0' then Delete(TXbyte1,1,6);
            end;
  If MaxSpeed<>0 then If Code_up_ppp then
          begin
                if StrToInt64(RXbyte1)-StrToInt64(RXbyte0)>MaxSpeed then
                                               begin
                                                    LimitRX:=LimitRX+1;
                                                    if LimitRX=3 then
                                                                     begin
                                                                          BalloonMessage(3000,message0,message64,AFont);
                                                                          LimitRX:=0;
                                                                     end;
                                               end else LimitRX:=0;
                 if StrToInt64(TXbyte1)-StrToInt64(TXbyte0)>MaxSpeed then
                                               begin
                                                    LimitTX:=LimitTX+1;
                                                    if LimitTX=3 then
                                                                     begin
                                                                          BalloonMessage(3000,message0,message63,AFont);
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
                                                            FpSystem (UsrBinDir+'printf "'+IntToStr(ObnullRX)+'\n" > '+MyTmpDir+'ObnullRX');
                                                       end;
          TrafficTX:=StrToInt64(TXbyte1);
          If StrToInt64(TXbyte1)-StrToInt64(TXbyte0)<0 then
                                                       begin
                                                            ObnullTX:=ObnullTX+1;
                                                            FpSystem (UsrBinDir+'printf "'+IntToStr(ObnullTX)+'\n" > '+MyTmpDir+'ObnullTX');
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
                    FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullRX');
                    FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullTX');
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
                           If not FileExists (MyTmpDir+'DateStart') then FpSystem (UsrBinDir+'printf "'+IntToStr(DateStart)+'\n" > '+MyTmpDir+'DateStart');
                      end;
  If Code_up_ppp then
                     begin
                             If Code_up_ppp then If FileExists (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after') then If FileExists (EtcDir+'resolv.conf') then
                                                If not CompareFiles (MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after', EtcDir+'resolv.conf') then
                                                       FpSystem (BinDir+'cp -f '+MyLibDir+Memo_Config.Lines[0]+'/resolv.conf.after '+EtcDir+'resolv.conf');
                             Application.ProcessMessages;
                             LoadIconForTray(MyDataDir,'on.ico');
                             If StartMessage then BalloonMessage (3000,message0,message6+' '+Memo_Config.Lines[0]+' '+message7+'...',AFont);
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
                                         Str:=BinDir+'ping -c1 '+DNS3+'|'+BinDir+'grep '+chr(39)+'1 received'+chr(39);
                                         Application.ProcessMessages;
                                         popen(f,Str,'R');
                                         Application.ProcessMessages;
                                         If eof(f) then
                                                                   begin
                                                                        NoPingDNS3:=true;
                                                                        BalloonMessage (3000,message0,message42,AFont);
                                                                   end;
                                         PClose(f);
                                    end;
                                 //тест dns4-сервера
                                 If DNS4<>'none' then
                                    begin
                                         Str:=BinDir+'ping -c1 '+DNS4+'|'+BinDir+'grep '+chr(39)+'1 received'+chr(39);
                                         Application.ProcessMessages;
                                         popen(f,Str,'R');
                                         Application.ProcessMessages;
                                         If eof(f) then
                                                                   begin
                                                                        NoPingDNS4:=true;
                                                                        BalloonMessage (3000,message0,message40,AFont);
                                                                   end;
                                         PClose(f);
                                    end;
                                 //тест интернета
                                 Str:=BinDir+'ping -c1 '+Memo_Config.Lines[44]+'|'+BinDir+'grep '+chr(39)+'1 received'+chr(39);
                                 Application.ProcessMessages;
                                 popen(f,str,'R');
                                 Application.ProcessMessages;
                                 If eof(f) then NoInternet:=true else NoInternet:=false;
                                 PClose(f);
                                 Application.ProcessMessages;
                                 If NoInternet then BalloonMessage (3000,message0,message16,AFont)
                                                    else
                                                         BalloonMessage (3000,message0,message19,AFont);
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
                             FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullRX');
                             FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullTX');
                             Application.ProcessMessages;
                             If not StartMessage then
                                    begin
                                         If NoConnectMessageShow then BalloonMessage (6000,message0,message6+' '+Memo_Config.Lines[0]+' '+message8+'...',AFont);
                                         NoInternet:=true;
                                         FpSystem(BinDir+'rm -f '+MyTmpDir+'DateStart');
                                         TrafficRX:=0;
                                         TrafficTX:=0;
                                         RXbyte0:='0';
                                         RXbyte1:='0';
                                         TXbyte0:='0';
                                         TXbyte1:='0';
                                         ObnullRX:=0;
                                         ObnullTX:=0;
                                         DoSpeedCount:=false;
                                         FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullRX');
                                         FpSystem (BinDir+'rm -f '+MyTmpDir+'ObnullTX');
                                    end;
                             LoadIconForTray(MyDataDir,'off.ico');
                             StartMessage:=true;
                           end;
  NoConnectMessageShow:=true;
  Application.ProcessMessages;
  if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
  Application.ProcessMessages;
end;

procedure TForm1.TrayIcon1Click(Sender: TObject);
begin

end;

procedure TForm1.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  find_net_monitor:boolean;
  str:string;
begin
  If Button=MBLEFT then exit;
  If (not FileExists (MyDataDir+'off.ico')) or (not FileExists (MyDataDir+'on.ico')) then
                                                         ColorIcon.Enabled:=false
                                                                               else
                                                                                  ColorIcon.Enabled:=true;
  If Widget.IniPropStorage1.ReadString ('black_and_white_icon','null')=true_str then PopupMenu1.Items[1].Caption:=message68 else PopupMenu1.Items[1].Caption:=message69;
  If not FileExists (UsrBinDir+'net_monitor') then begin MenuItem5.Visible:=false; exit;end;
  If not FileExists (UsrBinDir+'vnstat') then begin MenuItem5.Visible:=false; exit;end;
  Application.ProcessMessages;
  if EnablePseudoTray then  begin if not Widget.Showing then Widget.Show; end else if not Form1.TrayIcon1.Visible then Form1.TrayIcon1.Show;
  Application.ProcessMessages;
  //Проверяем поднялось ли соединение
  CheckVPN;
  If Code_up_ppp then MenuItem6.Enabled:=true else MenuItem6.Enabled:=false;
  find_net_monitor:=false;
  If Code_up_ppp then If FileExists (UsrBinDir+'net_monitor') then if FileExists (UsrBinDir+'vnstat') then
                    begin
                         //проверка net_monitor в процессах root, игнорируя зомби
                         popen(f,BinDir+'ps -u root | '+BinDir+'grep net_monitor | '+BinDir+'awk '+chr(39)+'{print $4$5}'+chr(39),'R');
                         str:='';
                         While not eof(f) do
                              begin
                                   Readln(f,str);
                                   If str='net_monitor' then find_net_monitor:=true;
                              end;
                         PClose(f);
                    end;
  If not find_net_monitor then MenuItem5.Enabled:=true else MenuItem5.Enabled:=false;
  If not Code_up_ppp then MenuItem5.Enabled:=false;
  Application.ProcessMessages;
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
                          popen (f,SBinDir+'ifconfig '+PppIface+'|'+BinDir+'grep P-t-P|'+BinDir+'awk '+chr(39)+'{print $3}'+chr(39),'R');
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
                          popen (f,SBinDir+'ifconfig '+PppIface+'|'+BinDir+'grep P-t-P|'+BinDir+'awk '+chr(39)+'{print $2}'+chr(39),'R');
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
                                                            ConnectionInfo:=Trim(Memo_Config.Lines[0]);
                                                            StatusInfo:=Trim(message7+' ('+strVPN+')');
                                                            TimeInNetInfo:=Trim(Time);
                                                            DownloadInfo:=Trim(RX+' ('+RXSpeed+')');
                                                            UploadInfo:=Trim(TX+' ('+TXSpeed+')');
                                                            InterfaceInfo:=Trim(PppIface);
                                                            IPAddressInfo:=Trim(IPaddress0);
                                                            GatewayInfo:=Trim(RemoteIPaddress0);
                                                            DNS1Info:=Trim(DNS3);
                                                            DNS2Info:=Trim(DNS4);
                                                       end
                                                            else
                                                                begin
                                                                    ConnectionInfo:=Trim(Memo_Config.Lines[0]);
                                                                    StatusInfo:=Trim(message8+' ('+strVPN+')');
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
                                   popen(f,BinDir+'cat '+MyLibDir+'default/default','R');
                                   while not eof(f) do
                                                    readln(f,ProfileStrDefault);
                                   PClose(f);
                                   If ProfileStrDefault<>'' then ProfileName:=ProfileStrDefault;
                              end;
  If Paramcount>0 then ProfileName:=Paramstr(1);
  FpSystem(BinDir+'mkdir -p '+VarRunVpnpptp);
  FpSystem(BinDir+'echo "'+ProfileName+'" > '+VarRunVpnpptp+ProfileName);
  Gettext.GetLanguageIDs(Lang,FallbackLang);
  Translate:=false;
  If FallbackLang='be' then FallbackLang:='ru';
  //FallbackLang:='ru'; //просто для проверки при отладке
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
