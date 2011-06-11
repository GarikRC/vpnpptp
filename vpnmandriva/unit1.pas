{ PPTP VPN setup

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
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, unix, Menus, Buttons, AsyncProcess, Process,
  Typinfo, Gettext, BaseUnix, types;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button_create: TBitBtn;
    Button_exit: TBitBtn;
    CheckBox_autostart: TCheckBox;
    CheckBox_no128: TCheckBox;
    CheckBox_no40: TCheckBox;
    CheckBox_no56: TCheckBox;
    CheckBox_nobuffer: TCheckBox;
    CheckBox_pppd_log: TCheckBox;
    CheckBox_rchap: TCheckBox;
    CheckBox_reap: TCheckBox;
    CheckBox_required: TCheckBox;
    CheckBox_right: TCheckBox;
    CheckBox_rmschap: TCheckBox;
    CheckBox_rmschapv2: TCheckBox;
    CheckBox_rpap: TCheckBox;
    CheckBox_stateless: TCheckBox;
    CheckBox_traffic: TCheckBox;
    Edit_IPS: TEdit;
    Edit_metric: TEdit;
    Edit_passwd: TEdit;
    Edit_peer: TEdit;
    Edit_user: TEdit;
    Image1: TImage;
    Label13: TLabel;
    Label9: TLabel;
    Label_IPS: TLabel;
    Label_metric: TLabel;
    Label_peer: TLabel;
    Label_pswd: TLabel;
    Label_user: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure Button_createClick(Sender: TObject);
    procedure Button_exitClick(Sender: TObject);
    procedure CheckBox_trafficChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabSheet1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

    { TTranslator }

  TMyHintWindow = class(THintWindow)
  public
    procedure ActivateHint(Rect: TRect; const AHint: string); override;
    constructor Create(AOwner: TComponent); override;
  end;

var
  Form1: TForm1;
  Lang,FallbackLang:string; //язык системы
  Number_PPP_Iface:integer; //номер ближайшего доступного для настройки интерфейса pppN
  AAsyncProcess:TAsyncProcess; //для запуска внешних приложений
  AFont:integer; //шрифт приложения
  f: text;//текстовый поток

const
  MyTmpDir='/tmp/'; //директория для временных файлов
  MyLangDir='/usr/share/vpnmandriva/lang/'; //директория для файлов переводов программы
  MyLogDir='/var/log/ppp/'; //директория для логов pppd
  EtcPppIpUpDDir='/etc/ppp/ip-up.d/';
  EtcPppIpDownDDir='/etc/ppp/ip-down.d/';
  UsrBinDir='/usr/bin/';
  SBinDir='/sbin/';
  UsrSBinDir='/usr/sbin/';
  EtcPppPeersDir='/etc/ppp/peers/';
  IfcfgDir='/etc/sysconfig/network-scripts/';
  EtcInitDDir='/etc/init.d/';
  MyVpnDir='/usr/lib/libDrakX/network/vpn/';

resourcestring
  message0ru='Внимание!';
  message1ru='Поля "Провайдер (IP или имя)", "Пользователь (логин)", "Пароль" обязательны к заполнению.';
  message2ru='Желательно установить метрику меньшую, чем у сетевого интерфейса, на котором будет поднято VPN PPTP.';
  message3ru='Невозможно настроить VPN PPTP в связи с отсутствием пакета pptp-linux.';
  message4ru='Выбор этой опции позволяет пользователям управлять подключением через net_applet без ввода пароля администратора.';
  message5ru='Если выбрать эту опцию, то соединение установится при загрузке системы.';
  message6ru='Если выбрать эту опцию, то для соединения будет вестись подсчет трафика, который можно наблюдать через net_monitor.';
  message7ru='В этом поле указывается адрес vpn-сервера.';
  message8ru='Не найдено ни одного свободного интерфейса pppN, где N в диапазоне [0..100]. Удалите неиспользуемые соединения в Центре Управления.';
  message9ru='Программа завершает свою работу.';
  message10ru='Эту опцию выбрать нельзя, так как не найден';
  message11ru='Соединение было успешно создано.';
  message12ru='Управлять соединением можно через net_applet (пакет drakx-net)';
  message13ru='или в консоли под администратором командами ifup, ifdown, передавая им интерфейс.';
  message14ru='Соединение установится при загрузке системы без ввода пароля администратора.';
  message15ru='При выборе опции nobuffer не будет буферизации, что желательно для быстрого соединения, но нежелательно для медленного, нестабильного.';
  message16ru='Программа не смогла установиться.';
  message17ru='Программа была успешно установлена.';
  message18ru='Часто используется аутентификация mschap v2 - это одновременный выбор refuse-eap, refuse-chap, refuse-mschap, refuse-pap.';
  message19ru='При использовании опции refuse-chap демон pppd не согласится аутентифицировать себя по протоколу CHAP.';
  message20ru='При использовании опции refuse-eap демон pppd не согласится аутентифицировать себя по протоколу EAP.';
  message21ru='При использовании опции refuse-mschap демон pppd не согласится аутентифицировать себя по протоколу MS-CHAP.';
  message22ru='При использовании опции refuse-pap демон pppd не согласится аутентифицировать себя по протоколу PAP.';
  message23ru='При использовании опции refuse-mschap-v2 демон pppd не согласится аутентифицировать себя по протоколу MS-CHAPv2.';
  message24ru='Опция required делает шифрование mppe обязательным и требует его использовать - не соединяться если провайдер не поддерживает шифрование mppe.';
  message25ru='Часто используется шифрование трафика mppe с 128-битным шифрованием - это одновременный выбор required, stateless, no40, no56.';
  message26ru='Опция stateless пытается реализовать шифрование mppe в режиме без поддержки состояний.';
  message27ru='Опция no40 отключает 40-битное шифрование mppe.';
  message28ru='Опция no56 отключает 56-битное шифрование mppe.';
  message29ru='Опция no128 отключает 128-битное шифрование mppe.';
  message30ru='Запустите эту программу под root';
  message31ru='Выйти из программы';
  message32ru='Эта кнопка создает соединение';
  message33ru='При низких разрешениях экрана одновременное нажатие клавиши Alt и левой кнопки мыши поможет переместить окно.';
  message34ru='Нажатие левой/правой кнопкой мыши на пустом месте окна изменяет шрифт.';
  message35ru='Сетевой интерфейс:';
  message36ru='Провайдер (IP или имя)*:';
  message37ru='Пользователь (логин)*:';
  message38ru='Пароль*:';
  message39ru='Метрика:';
  message40ru='Разрешить пользователям управлять подключением';
  message41ru='Устанавливать соединение при загрузке';
  message42ru='Включить подсчет трафика';
  message43ru='Не буферизировать пакеты (nobuffer)';
  message44ru='Аутентификация:';
  message45ru='Шифрование mppe:';
  message46ru='Выход  ';//общая длина 7 символов
  message47ru='Создать';
  message48ru='Настройка VPN PPTP';
  message49ru='Вести подробный лог pppd в';
  message50ru='Ведите лог pppd для того, чтобы выяснить ошибки настройки соединения, ошибки при соединении и т.д.';
  message51ru='Для удаления программы удалите:';
  message52ru='Не забудьте настроить файервол.';
  message53ru='или из Центра Управления->Сеть и Интернет->Настройка VPN-соединений->VPN PPTP.';
  message54ru='Программа была успешно обновлена.';
  message55ru='В поле "Метрика" должно быть введено числовое значение.';
  message56ru='Не удалось запустить net_applet.';
  message57ru='Отсутствует:';
  message58ru='Найден:';

  message0uk='Увага!';
  message1uk='Поля "Провайдер (IP або ім’я)", "Користувач (логін)", "Пароль" обов’язкові до заповнення.';
  message2uk='Бажано встановити метрику меншу, ніж у мережевого інтерфейсу, на якому буде піднято VPN PPTP.';
  message3uk='Неможливо налаштувати VPN PPTP у зв''язку з відсутністю пакету pptp-linux.';
  message4uk='Вибір цієї опції дозволяє користувачам керувати підключенням через net_applet без введення пароля адміністратора.';
  message5uk='Якщо вибрати цю опцію, то з''єднання встановиться при завантаженні системи.';
  message6uk='Якщо вибрати цю опцію, то для з''єднання буде вестися підрахунок трафіку, який можна спостерігати через net_monitor.';
  message7uk='У цьому полі вказується адреса vpn-сервера.';
  message8uk='Не знайдено жодного вільного інтерфейсу pppN, де N в діапазоні [0 .. 100]. Видаліть невикористовувані з''єднання в Центрі керування.';
  message9uk='Програма завершує свою роботу.';
  message10uk='Цю опцію вибрати не можна, тому що не знайдено';
  message11uk='З''єднання було успішно створено.';
  message12uk='Керувати з''єднанням можна через net_applet (пакет drakx-net)';
  message13uk='або в консолі під адміністратором командами ifup, ifdown, передаючи їм інтерфейс.';
  message14uk='З''єднання встановиться при завантаженні системи без введення пароля адміністратора.';
  message15uk='При виборі опції nobuffer не буде буферизації, що бажано для швидкого з''єднання, але небажано для повільного, нестабільного.';
  message16uk='Програма не змогла встановитися.';
  message17uk='Програма була успішно встановлена.';
  message18uk='Часто використовується аутентифікація mschap v2 - це одночасний вибір refuse-eap, refuse-chap, refuse-mschap, refuse-pap.';
  message19uk='При використанні опції refuse-chap демон pppd не погодиться аутентіфіцировать себе по протоколу CHAP.';
  message20uk='При використанні опції refuse-eap демон pppd не погодиться аутентіфіцировать себе по протоколу EAP.';
  message21uk='При використанні опції refuse-mschap демон pppd не погодиться аутентіфіцировать себе по протоколу MS-CHAP.';
  message22uk='При використанні опції refuse-pap демон pppd не погодиться аутентіфіцировать себе по протоколу PAP.';
  message23uk='При використанні опції refuse-mschap-v2 демон pppd не погодиться аутентіфіцировать себе по протоколу MS-CHAPv2.';
  message24uk='Опція required робить шифрування mppe обов''язковим і вимагає його використовувати - не з''єднуватися якщо провайдер не підтримує шифрування mppe.';
  message25uk='Часто використовується шифрування трафіку mppe з 128-бітовим шифруванням - це одночасний вибір required, stateless, no40, no56.';
  message26uk='Опція stateless намагається реалізувати шифрування mppe в режимі без підтримки станів.';
  message27uk='Опція no40 відключає 40-бітове шифрування mppe.';
  message28uk='Опція no56 відключає 56-бітове шифрування mppe.';
  message29uk='Опція no128 відключає 128-бітове шифрування mppe.';
  message30uk='Запустіть цю програму під root';
  message31uk='Вийти із програми';
  message32uk='Ця кнопка створює з''єднання';
  message33uk='При низьких дозволах екрана одночасне натискання клавіші Alt і лівої кнопки миші допоможе перемістити вікно.';
  message34uk='Натискання лівої/правою кнопкою миші на порожньому місці вікна змінює шрифт.';
  message35uk='Мережевий інтерфейс:';
  message36uk='Провайдер (IP або ім’я)*:';
  message37uk='Користувач (логін)*';
  message38uk='Пароль*:';
  message39uk='Метрика:';
  message40uk='Дозволити користувачам керувати підключенням';
  message41uk='Встановлювати з''єднання при завантаженні';
  message42uk='Дозволити підрахунок трафіку';
  message43uk='Не буферізувати пакети (nobuffer)';
  message44uk='Аутентифікація:';
  message45uk='Шифрування mppe:';
  message46uk='Вихід  ';//общая длина 7 символов
  message47uk='Створити';
  message48uk='Налаштування VPN PPTP';
  message49uk='Вести докладна лог pppd в';
  message50uk='Ведіть лог pppd для того, щоб з''ясувати помилки налаштування з''єднання, помилки при з''єднанні і т.п.';
  message51uk='Для видалення програми видаліть:';
  message52uk='Не забудьте налаштувати файервол.';
  message53uk='або з Центру Управління-> Мережа та Інтернет-> Налаштування VPN-з''єднань-> VPN PPTP.';
  message54uk='Програма була успішно оновлена.';
  message55uk='У полі "Метрика" повинно бути введено числове значення.';
  message56uk='Не вдалося запустити net_applet.';
  message57uk='Відсутній:';
  message58uk='Знайден:';

  message0en='Attention!';
  message1en='Fields "ISP (IP or Name)", "User name (login)", "Password" is required.';
  message2en='It is desirable to set a metric less than for network interface, which will be to use for VPN PPTP.';
  message3en='Unable to configure VPN PPTP because of absence of package pptp-linux.';
  message4en='Choice of this option allows users to manage connections with help net_applet without entering the root''s password.';
  message5en='If you choose this option, then the connection will be established when the system boots.';
  message6en='If you choose this option, then traffic will be to calculate for the connection, which you can watch with help net_monitor.';
  message7en='In this box you must enter address of vpn-server.';
  message8en='Did not match any of the free interface pppN, where N is in the range [0..100]. Remove unused connections in the Control Center.';
  message9en='The program complete its work.';
  message10en='This option can not be selected, because was not found';
  message11en='The connection was successfully created.';
  message12en='You can manage the connection with help net_applet (package drakx-net)';
  message13en='or in the root''s console by commands: ifup pppN, ifdown pppN.';
  message14en='Connection will be established at boot without entering a root''s password.';
  message15en='When you select nobuffer, then will not be buffering; it is desirable for fast connections, but not desirable for a unstable.';
  message16en='Program failed to install.';
  message17en='The program was successfully installed.';
  message18en='Authentication of mschap v2 is used frequently - this is a simultaneous choice of refuse-eap, refuse-chap, refuse-mschap, refuse-pap.';
  message19en='With option refuse-chap, pppd will not agree to authenticate itself to the peer using CHAP.';
  message20en='With option refuse-eap, pppd will not agree to authenticate itself to the peer using EAP.';
  message21en='With option refuse-mschap, pppd will not agree to authenticate itself to the peer using MS-CHAP.';
  message22en='With option refuse-pap, pppd will not agree to authenticate itself to the peer using PAP.';
  message23en='With option refuse-mschap-v2, pppd will not agree to authenticate itself to the peer using MS-CHAPv2.';
  message24en='required - require mppe; disconnect if peer doesn''t support it.';
  message25en='Encryption mppe often used with 128-bit encryption - is the simultaneous selection of required, stateless, no40, no56.';
  message26en='stateless - try to negotiate stateless mode.';
  message27en='no40 - disable 40 bit keys.';
  message28en='no56 - disable 56 bit keys.';
  message29en='no128 - disable 128 bit keys.';
  message30en='Run this program as root';
  message31en='Quit';
  message32en='This button creates the connection';
  message33en='At low screen resolutions simultaneously pressing the Alt key and left mouse button will move the window.';
  message34en='Pressing the left/right click on the window changes the font.';
  message35en='     Network:';
  message36en='ISP (IP or name)*:';
  message37en='User (login)*:';
  message38en='Password*:';
  message39en='Metric:';
  message40en='Let users operate the connection';
  message41en='Connect the connection at boot';
  message42en='Enable to calculate traffic';
  message43en='Not buffered packets (nobuffer)';
  message44en='Authentication:';
  message45en='Encription mppe:';
  message46en='Exit   ';//общая длина 7 символов
  message47en='Create';
  message48en='VPN PPTP Setup';
  message49en='pppd detailed log on';
  message50en='Use a log of pppd in order to identify the connection setup errors, errors when connecting, etc.';
  message51en='For uninstall, remove:';
  message52en='Do not forget to configure the firewall.';
  message53en='or from the Control Center->Network and  Internet->Setting VPN-connections->VPN PPTP.';
  message54en='The program was successfully updeted.';
  message55en='You must enter a numeric value in field "metric".';
  message56en='Failed to start net_applet.';
  message57en='Missing:';
  message58en='Find:';


implementation

uses
LCLProc;

constructor TMyHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with Canvas.Font do
  begin
    Size := AFont;
    Color:=clBlack;
  end;
end;

procedure TMyHintWindow.ActivateHint(Rect: TRect; const AHint: string);
begin
  Canvas.Font.Size:=AFont;
  Canvas.Font.Color := clBlack;
  inherited;
end;

Function MakeHint(str:string;n:byte):string;
//создает многострочный хинт
var
  i,j:integer;
  str0:string;
 begin
   str0:='';
   j:=0;
   For i:=1 to Length(str) do
            begin
               str0:=str0+str[i];
               If str[i]=' ' then j:=j+1;
               if j=n then begin str0:=str0+#13#10;j:=0;end;
            end;
   MakeHint:=str0;
end;

{ TForm1 }

procedure TForm1.Button_createClick(Sender: TObject);
var
  str,mppe_string:string;
  y,net_applet_root:boolean;
  StrUsers:string;
begin
//выход из создания подключения
y:=false;
Try
    StrToInt(Edit_metric.Text);
  except
    On EConvertError do
      y:=true;
  end;
If y then
        begin
           If FallbackLang='ru' then Application.MessageBox(PChar(message55ru),PChar(message0ru),0) else
                               If FallbackLang='uk' then Application.MessageBox(PChar(message55uk),PChar(message0uk),0) else
                                                                           Application.MessageBox(PChar(message55en),PChar(message0en),0);
           Edit_metric.SetFocus;
           exit;
        end;




If (Edit_IPS.Text='') or (Edit_user.Text='') or (Edit_passwd.Text='') then
                    begin
                       If FallbackLang='ru' then Application.MessageBox(PChar(message1ru),PChar(message0ru),0) else
                                            If FallbackLang='uk' then Application.MessageBox(PChar(message1uk),PChar(message0uk),0) else
                                                                                     Application.MessageBox(PChar(message1en),PChar(message0en),0);
                       exit;
                    end;
//запись файла /etc/sysconfig/network-scripts/ifcfg-pppN
Shell('printf "DEVICE=ppp'+IntToStr(Number_PPP_Iface)+'\n" > '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_autostart.Checked then Shell('printf "ONBOOT=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else Shell('printf "ONBOOT=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
Shell('printf "METRIC='+Edit_metric.Text+'\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
Shell('printf "TYPE=ADSL\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_right.Checked then Shell('printf "USERCTL=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else Shell('printf "USERCTL=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_traffic.Checked then Shell('printf "ACCOUNTING=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else Shell('printf "ACCOUNTING=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
Shell ('chmod a+x '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
{//запись файла /etc/ppp/ip-up.d/vpnmandriva-ip-up
If not DirectoryExists (EtcPppIpUpDDir) then Shell ('mkdir '+EtcPppIpUpDDir);
Memo1.Lines.Clear;
Memo1.Lines.Add('#!/bin/sh');
Memo1.Lines.Add('if [ ! $LINKNAME = "vpnmandriva" ]');
Memo1.Lines.Add('then');
Memo1.Lines.Add('exit 0');
Memo1.Lines.Add('fi');
Memo1.Lines.Add('/sbin/route del default');
Memo1.Lines.Add('/sbin/route del default');
Memo1.Lines.Add('/sbin/route add default dev $IFNAME');
Memo1.Lines.SaveToFile(EtcPppIpUpDDir+'vpnmandriva-ip-up');
Shell('chmod a+x '+EtcPppIpUpDDir+'vpnmandriva-ip-up');}
//запись файла /etc/ppp/ip-down.d/vpnmandriva-ip-down
If not DirectoryExists (EtcPppIpDownDDir) then Shell ('mkdir '+EtcPppIpDownDDir);
Memo1.Lines.Clear;
Memo1.Lines.Add('#!/bin/sh');
Memo1.Lines.Add('if [ ! $LINKNAME = "vpnmandriva" ]');
Memo1.Lines.Add('then');
Memo1.Lines.Add('exit 0');
Memo1.Lines.Add('fi');
If FileExists (SBinDir+'service') then Memo1.Lines.Add('service network restart') else Memo1.Lines.Add(EtcInitDDir+' network restart');
Memo1.Lines.SaveToFile(EtcPppIpDownDDir+'vpnmandriva-ip-down');
Shell('chmod a+x '+EtcPppIpDownDDir+'vpnmandriva-ip-down');
//запись файла /etc/ppp/peers/pppN
Memo1.Lines.Clear;
Memo1.Lines.Add('unit '+IntToStr(Number_PPP_Iface));
Memo1.Lines.Add('noipdefault');
Memo1.Lines.Add('defaultroute');
Memo1.Lines.Add('noauth');
Memo1.Lines.Add('linkname vpnmandriva');
Memo1.Lines.Add('usepeerdns');
Memo1.Lines.Add('lock');
Memo1.Lines.Add('persist');
Memo1.Lines.Add('nopcomp');
If (not CheckBox_required.Checked) then if (not CheckBox_stateless.Checked) then if (not CheckBox_no40.Checked) then if (not CheckBox_no56.Checked) then if (not CheckBox_no128.Checked) then
                                                                          Memo1.Lines.Add('noccp');
Memo1.Lines.Add('novj');
Memo1.Lines.Add('kdebug 1');
Memo1.Lines.Add('holdoff 4');
Memo1.Lines.Add('maxfail 5');
If CheckBox_nobuffer.Checked then Memo1.Lines.Add('pty "/usr/sbin/pptp '+Edit_IPS.Text+' --nolaunchpppd --nobuffer"') else Memo1.Lines.Add('pty "/usr/sbin/pptp '+Edit_IPS.Text+' --nolaunchpppd"');
Memo1.Lines.Add('user "'+Edit_user.Text+'"');
Memo1.Lines.Add('password "'+Edit_passwd.Text+'"');
If CheckBox_rmschap.Checked then Memo1.Lines.Add(CheckBox_rmschap.Caption);
If CheckBox_reap.Checked then Memo1.Lines.Add(CheckBox_reap.Caption);
If CheckBox_rchap.Checked then Memo1.Lines.Add(CheckBox_rchap.Caption);
If CheckBox_rpap.Checked then Memo1.Lines.Add(CheckBox_rpap.Caption);
If CheckBox_rmschapv2.Checked then Memo1.Lines.Add(CheckBox_rmschapv2.Caption);
mppe_string:='mppe ';
if CheckBox_required.Checked then mppe_string:=mppe_string+CheckBox_required.Caption;
   if CheckBox_required.Checked then if CheckBox_stateless.Checked or CheckBox_no40.Checked or CheckBox_no56.Checked or CheckBox_no128.Checked then mppe_string:=mppe_string+',';
if CheckBox_stateless.Checked then mppe_string:=mppe_string+CheckBox_stateless.Caption;
   if CheckBox_stateless.Checked then if CheckBox_no40.Checked or CheckBox_no56.Checked or CheckBox_no128.Checked then mppe_string:=mppe_string+',';
if CheckBox_no40.Checked then mppe_string:=mppe_string+CheckBox_no40.Caption;
   if CheckBox_no40.Checked then if CheckBox_no56.Checked or CheckBox_no128.Checked then mppe_string:=mppe_string+',';
if CheckBox_no56.Checked then mppe_string:=mppe_string+CheckBox_no56.Caption;
   if CheckBox_no56.Checked then if CheckBox_no128.Checked then mppe_string:=mppe_string+',';
if CheckBox_no128.Checked then mppe_string:=mppe_string+CheckBox_no128.Caption;
   If mppe_string<>'mppe ' then Memo1.Lines.Add(mppe_string);
If CheckBox_pppd_log.Checked then
                             begin
                                If not DirectoryExists(MyLogDir) then Shell ('mkdir -p '+MyLogDir);
                                Memo1.Lines.Add('debug');
                                Memo1.Lines.Add('logfile '+MyLogDir+'vpnmandriva.log');
                             end;
Memo1.Lines.SaveToFile(EtcPppPeersDir+'ppp'+IntToStr(Number_PPP_Iface));
Shell ('chmod 600 '+EtcPppPeersDir+'ppp'+IntToStr(Number_PPP_Iface));
//применение изменений перезапуском net_applet
popen(f,'ps -u root|grep net_applet','R');
if eof(f) then net_applet_root:=false else net_applet_root:=true;
PClose(f);
str:='';
StrUsers:='';
Shell ('killall net_applet');
if not net_applet_root then
                             begin
                                  popen (f,'who | awk '+chr(39)+'{print $1}'+chr(39),'R'); //получение списка пользователей, залогиненных в системе
                                  While not eof(f) do
                                        begin
                                             readln(f,str);
                                             if str<>'' then if pos(str,StrUsers)=0 then
                                                        begin
                                                             AAsyncProcess := TAsyncProcess.Create(nil);
                                                             AAsyncProcess.CommandLine :='su - '+str+' -c "'+UsrBinDir+'net_applet"';
                                                             AAsyncProcess.Execute;
                                                             sleep(3000);
                                                             AAsyncProcess.Free;
                                                        end;
                                             StrUsers:=StrUsers+str;
                                        end;
                                  PClose(f);
                             end;
if net_applet_root then
                      begin
                          AAsyncProcess := TAsyncProcess.Create(nil);
                          AAsyncProcess.CommandLine :=UsrBinDir+'net_applet';
                          AAsyncProcess.Execute;
                          sleep(3000);
                          AAsyncProcess.Free;
                      end;
If FallbackLang='ru' then Application.MessageBox(PChar(message11ru+' '+message12ru+' '+message13ru+' '+message52ru),PChar(message0ru),0) else
                     If FallbackLang='uk' then Application.MessageBox(PChar(message11uk+' '+message12uk+' '+message13uk+' '+message52uk),PChar(message0uk),0) else
                                                              Application.MessageBox(PChar(message11en+' '+message12en+' '+message13en+' '+message52en),PChar(message0en),0);
//обработка результата перезапуска net_applet
popen (f,'ps -e|grep net_applet','R');
str:='';
If eof(f) then
               begin
                   If FallbackLang='ru' then str:=message56ru else If FallbackLang='uk' then str:=message56uk else str:=message56en;
                   If not FileExists(UsrBinDir+'net_applet') then If FallbackLang='ru' then str:=str+' '+message57ru+' '+UsrBinDir+'net_applet.' else
                                        if FallbackLang='uk' then str:=str+' '+message57uk+' '+UsrBinDir+'net_applet.' else str:=str+' '+message57en+' '+UsrBinDir+'net_applet.';
                   If not FileExists(UsrBinDir+'net_applet') then If FileExists(UsrBinDir+'net_applet.old') then If FallbackLang='ru' then str:=str+' '+message58ru+' '+UsrBinDir+'net_applet.old.' else
                                        if FallbackLang='uk' then str:=str+' '+message58uk+' '+UsrBinDir+'net_applet.old.' else str:=str+' '+message58en+' '+UsrBinDir+'net_applet.old.';
                   Application.MessageBox(PChar(str),PChar(message0ru),0);
               end;
PClose(f);
end;


procedure TForm1.Button_exitClick(Sender: TObject);
begin
  halt;
end;


procedure TForm1.CheckBox_trafficChange(Sender: TObject);
var
   str:string;
begin
  str:='';
  If FallbackLang='ru' then If not FileExists (UsrBinDir+'vnstat') then str:=str+message10ru+' '+UsrBinDir+'vnstat. ';
  If FallbackLang='ru' then If not FileExists (UsrBinDir+'net_monitor') then str:=str+message10ru+' '+UsrBinDir+'net_monitor. ';
  If FallbackLang='uk' then If not FileExists (UsrBinDir+'vnstat') then str:=str+message10uk+' '+UsrBinDir+'vnstat. ';
  If FallbackLang='uk' then If not FileExists (UsrBinDir+'net_monitor') then str:=str+message10uk+' '+UsrBinDir+'net_monitor. ';
  If FallbackLang<>'ru' then If FallbackLang<>'uk' then If not FileExists (UsrBinDir+'vnstat') then str:=str+message10en+' '+UsrBinDir+'vnstat. ';
  If FallbackLang<>'ru' then If FallbackLang<>'uk' then If not FileExists (UsrBinDir+'net_monitor') then str:=str+message10en+' '+UsrBinDir+'net_monitor. ';
  if str<>'' then if CheckBox_traffic.Checked then
                 begin
                    If FallbackLang='ru' then Application.MessageBox(PChar(str),PChar(message0ru),0) else
                                         If FallbackLang='uk' then Application.MessageBox(PChar(str),PChar(message0uk),0) else
                                                                                  Application.MessageBox(PChar(str),PChar(message0en),0);
                    CheckBox_traffic.Checked:=false;
                 end;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
    nostart:boolean;
    Apid,Apidroot:tpid;
    i:integer;
    q:byte;
    ProgramInstalled:boolean;
begin
Edit_peer.Enabled:=false;
Number_PPP_Iface:=101;
//поиск доступного интерфейса pppN
for i:=0 to 100 do
            begin
                 If not FileExists(IfcfgDir+'ifcfg-ppp'+IntToStr(i)) then
                                                                     begin
                                                                         Number_PPP_Iface:=i;
                                                                         break;
                                                                     end;
            end;
//Number_PPP_Iface:=101; //просто для проверки при отладке
If Number_PPP_Iface<>101 then Edit_peer.Text:='ppp'+IntToStr(Number_PPP_Iface);
If Edit_peer.Text='' then
                    begin
                       If FallbackLang='ru' then Application.MessageBox(PChar(message8ru+' '+message9ru),PChar(message0ru),0) else
                                            If FallbackLang='uk' then Application.MessageBox(PChar(message8uk+' '+message9uk),PChar(message0uk),0) else
                                                                                     Application.MessageBox(PChar(message8en+' '+message9en),PChar(message0en),0);
                       halt;
                    end;
//присваивание хинтов элементам формы и их настройка
HintWindowClass := TMyHintWindow;
Application.HintColor:=$0092FFF8;
Application.ShowHint := False;
Application.ShowHint := True;
q:=0;
If FallbackLang='ru' then q:=1;
If FallbackLang='uk' then q:=2;
case q of
    1:
        begin
             Form1.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Panel1.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Edit_metric.Hint:=MakeHint(message2ru,5);
             CheckBox_right.Hint:=MakeHint(message4ru,5);
             CheckBox_autostart.Hint:=MakeHint(message5ru+' '+message14ru,7);
             CheckBox_traffic.Hint:=MakeHint(message6ru,5);
             CheckBox_nobuffer.Hint:=MakeHint(message15ru,5);
             Label_IPS.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_peer.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_user.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_pswd.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label9.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label13.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Edit_IPS.Hint:=MakeHint(message1ru+' '+message7ru,7);
             Edit_user.Hint:=MakeHint(message1ru,7);
             Edit_passwd.Hint:=MakeHint(message1ru,7);
             Button_exit.Hint:=MakeHint(message31ru,6);
             Button_create.Hint:=MakeHint(message32ru,3);
             CheckBox_rchap.Hint:=MakeHint(message19ru+' '+message18ru,6);
             CheckBox_reap.Hint:=MakeHint(message20ru+' '+message18ru,6);
             CheckBox_rmschap.Hint:=MakeHint(message21ru+' '+message18ru,6);
             CheckBox_rpap.Hint:=MakeHint(message22ru+' '+message18ru,6);
             CheckBox_rmschapv2.Hint:=MakeHint(message23ru+' '+message18ru,6);
             CheckBox_required.Hint:=MakeHint(message24ru+' '+message25ru,6);
             CheckBox_stateless.Hint:=MakeHint(message26ru+' '+message25ru,6);
             CheckBox_no40.Hint:=MakeHint(message27ru+' '+message25ru,6);
             CheckBox_no56.Hint:=MakeHint(message28ru+' '+message25ru,6);
             CheckBox_no128.Hint:=MakeHint(message29ru+' '+message25ru,6);
             Label_metric.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Image1.Hint:=MakeHint(message33ru+' '+message34ru,5);
             CheckBox_pppd_log.Hint:=MakeHint(message50ru,6);
        end;
    2:
    begin
         Form1.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Panel1.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Edit_metric.Hint:=MakeHint(message2uk,5);
         CheckBox_right.Hint:=MakeHint(message4uk,5);
         CheckBox_autostart.Hint:=MakeHint(message5uk+' '+message14uk,7);
         CheckBox_traffic.Hint:=MakeHint(message6uk,5);
         CheckBox_nobuffer.Hint:=MakeHint(message15uk,5);
         Label_IPS.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_peer.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_user.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_pswd.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label9.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label13.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Edit_IPS.Hint:=MakeHint(message1uk+' '+message7uk,7);
         Edit_user.Hint:=MakeHint(message1uk,7);
         Edit_passwd.Hint:=MakeHint(message1uk,7);
         Button_exit.Hint:=MakeHint(message31uk,6);
         Button_create.Hint:=MakeHint(message32uk,3);
         CheckBox_rchap.Hint:=MakeHint(message19uk+' '+message18uk,6);
         CheckBox_reap.Hint:=MakeHint(message20uk+' '+message18uk,6);
         CheckBox_rmschap.Hint:=MakeHint(message21uk+' '+message18uk,6);
         CheckBox_rpap.Hint:=MakeHint(message22uk+' '+message18uk,6);
         CheckBox_rmschapv2.Hint:=MakeHint(message23uk+' '+message18uk,6);
         CheckBox_required.Hint:=MakeHint(message24uk+' '+message25uk,6);
         CheckBox_stateless.Hint:=MakeHint(message26uk+' '+message25uk,6);
         CheckBox_no40.Hint:=MakeHint(message27uk+' '+message25uk,6);
         CheckBox_no56.Hint:=MakeHint(message28uk+' '+message25uk,6);
         CheckBox_no128.Hint:=MakeHint(message29uk+' '+message25uk,6);
         Label_metric.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Image1.Hint:=MakeHint(message33uk+' '+message34uk,5);
         CheckBox_pppd_log.Hint:=MakeHint(message50uk,6);
    end;
else
    begin
         Form1.Hint:=MakeHint(message33en+' '+message34en,5);
         Panel1.Hint:=MakeHint(message33en+' '+message34en,5);
         Edit_metric.Hint:=MakeHint(message2en,5);
         CheckBox_right.Hint:=MakeHint(message4en,5);
         CheckBox_autostart.Hint:=MakeHint(message5en+' '+message14en,7);
         CheckBox_traffic.Hint:=MakeHint(message6en,5);
         CheckBox_nobuffer.Hint:=MakeHint(message15en,5);
         Label_IPS.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_peer.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_user.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_pswd.Hint:=MakeHint(message33en+' '+message34en,5);
         Label9.Hint:=MakeHint(message33en+' '+message34en,5);
         Label13.Hint:=MakeHint(message33en+' '+message34en,5);
         Edit_IPS.Hint:=MakeHint(message1en+' '+message7en,7);
         Edit_user.Hint:=MakeHint(message1en,7);
         Edit_passwd.Hint:=MakeHint(message1en,7);
         Button_exit.Hint:=MakeHint(message31en,6);
         Button_create.Hint:=MakeHint(message32en,3);
         CheckBox_rchap.Hint:=MakeHint(message19en+' '+message18en,6);
         CheckBox_reap.Hint:=MakeHint(message20en+' '+message18en,6);
         CheckBox_rmschap.Hint:=MakeHint(message21en+' '+message18en,6);
         CheckBox_rpap.Hint:=MakeHint(message22en+' '+message18en,6);
         CheckBox_rmschapv2.Hint:=MakeHint(message23en+' '+message18en,6);
         CheckBox_required.Hint:=MakeHint(message24en+' '+message25en,6);
         CheckBox_stateless.Hint:=MakeHint(message26en+' '+message25en,6);
         CheckBox_no40.Hint:=MakeHint(message27en+' '+message25en,6);
         CheckBox_no56.Hint:=MakeHint(message28en+' '+message25en,6);
         CheckBox_no128.Hint:=MakeHint(message29en+' '+message25en,6);
         Label_metric.Hint:=MakeHint(message33en+' '+message34en,5);
         Image1.Hint:=MakeHint(message33en+' '+message34en,5);
         CheckBox_pppd_log.Hint:=MakeHint(message50en,6);
    end;
end;
//заполнение приложения текстом в соответствии с языком
case q of
    1:
        begin
             Form1.Caption:=message48ru;
             Label_peer.Caption:=message35ru;
             Label_IPS.Caption:=message36ru;
             Label_user.Caption:=message37ru;
             Label_pswd.Caption:=message38ru;
             Label_metric.Caption:=message39ru;
             CheckBox_right.Caption:=message40ru;
             CheckBox_autostart.Caption:=message41ru;
             CheckBox_traffic.Caption:=message42ru;
             CheckBox_nobuffer.Caption:=message43ru;
             Label9.Caption:=message44ru;
             Label13.Caption:=message45ru;
             Button_exit.Caption:=message46ru;
             Button_create.Caption:=message47ru;
             CheckBox_pppd_log.Caption:=message49ru+' '+MyLogDir+'vpnmandriva.log';
        end;
    2:
        begin
             Form1.Caption:=message48uk;
             Label_peer.Caption:=message35uk;
             Label_IPS.Caption:=message36uk;
             Label_user.Caption:=message37uk;
             Label_pswd.Caption:=message38uk;
             Label_metric.Caption:=message39uk;
             CheckBox_right.Caption:=message40uk;
             CheckBox_autostart.Caption:=message41uk;
             CheckBox_traffic.Caption:=message42uk;
             CheckBox_nobuffer.Caption:=message43uk;
             Label9.Caption:=message44uk;
             Label13.Caption:=message45uk;
             Button_exit.Caption:=message46uk;
             Button_create.Caption:=message47uk;
             CheckBox_pppd_log.Caption:=message49uk+' '+MyLogDir+'vpnmandriva.log';
        end;
else
    begin
        Form1.Caption:=message48en;
        Label_peer.Caption:=message35en;
        Label_IPS.Caption:=message36en;
        Label_user.Caption:=message37en;
        Label_pswd.Caption:=message38en;
        Label_metric.Caption:=message39en;
        CheckBox_right.Caption:=message40en;
        CheckBox_autostart.Caption:=message41en;
        CheckBox_traffic.Caption:=message42en;
        CheckBox_nobuffer.Caption:=message43en;
        Label9.Caption:=message44en;
        Label13.Caption:=message45en;
        Button_exit.Caption:=message46en;
        Button_create.Caption:=message47en;
        CheckBox_pppd_log.Caption:=message49en+' '+MyLogDir+'vpnmandriva.log';
    end;
end;
//масштабирование формы в зависимости от разрешения экрана
   Form1.Height:=600;
   Form1.Width:=794;
   Form1.Position:=poDefault;
   Form1.Top:=0;
   Form1.Left:=0;
   If Screen.Height<440 then
                            begin
                             Form1.Position:=poScreenCenter;
                             AFont:=6;
                             Form1.Height:=Screen.Height-50;
                             Form1.Width:=Screen.Width;
                             Form1.Constraints.MaxHeight:=Screen.Height-50;
                             Form1.Constraints.MinHeight:=Screen.Height-50;
                             Button_create.BorderSpacing.Left:=Screen.Width-182;
                            end;
   If Screen.Height<=480 then
                        begin
                             Form1.Position:=poScreenCenter;
                             AFont:=6;
                             Form1.Font.Size:=AFont;
                             Form1.Height:=Screen.Height-45;
                             Form1.Width:=Screen.Width;
                             Form1.Constraints.MaxHeight:=Screen.Height-45;
                             Form1.Constraints.MinHeight:=Screen.Height-45;
                        end;
   If Screen.Height<550 then If not (Screen.Height<=480) then
                         begin
                             Form1.Position:=poScreenCenter;
                             AFont:=6;
                             Form1.Constraints.MaxHeight:=Screen.Height;
                             Form1.Constraints.MinHeight:=Screen.Height;
                         end;
   If Screen.Height>550 then   //разрешение в основном нетбуков
                        begin
                             Form1.Position:=poScreenCenter;
                             AFont:=8;
                             Form1.Font.Size:=AFont;
                             Form1.Height:=550;
                             Form1.Width:=794;
                             Form1.Constraints.MaxHeight:=550;
                             Form1.Constraints.MinHeight:=550;
                             Form1.Constraints.MaxWidth:=794;
                             Form1.Constraints.MinWidth:=794;
                        end;
   If Screen.Height>1000 then
                        begin
                             Form1.Position:=poScreenCenter;
                             AFont:=10;
                             Form1.Font.Size:=AFont;
                             Form1.Height:=650;
                             Form1.Width:=884;
                             Form1.Constraints.MaxHeight:=650;
                             Form1.Constraints.MinHeight:=650;
                             Form1.Constraints.MaxWidth:=884;
                             Form1.Constraints.MinWidth:=884;
                         end;
If not FileExists(UsrSBinDir+'pptp') then
                                        begin
                                            If FallbackLang='ru' then Application.MessageBox(PChar(message3ru),PChar(message0ru),0) else
                                                                 If FallbackLang='uk' then Application.MessageBox(PChar(message3uk),PChar(message0uk),0) else
                                                                                                          Application.MessageBox(PChar(message3en),PChar(message0en),0);
                                            Application.ProcessMessages;
                                            Form1.Repaint;
                                            halt;
                                        end;
//проверка vpnmandriva в процессах root, исключение запуска под иными пользователями
  Apid:=FpGetpid;
  Apidroot:=0;
  popen (f,'ps -u root | grep vpnmandriva | awk '+chr(39)+'{print $1}'+chr(39),'R');
  while not eof(f) do
     begin
        readln(f,Apidroot);
        If Apid=Apidroot then break;
     end;
  PClose(f);
  nostart:=false;
  popen (f,'ps -u root | grep vpnmandriva | awk '+chr(39)+'{print $4}'+chr(39),'R');
  If eof(f) or (Apid<>Apidroot) then nostart:=true;
  PClose(f);
  If nostart then
                begin
                    If FileExists(MyVpnDir+'vpnmandriva.pm') then
                                  begin
                                       If FallbackLang='ru' then Application.MessageBox(PChar(message30ru+' '+message53ru),PChar(message0ru),0) else
                                                            If FallbackLang='uk' then Application.MessageBox(PChar(message30uk+' '+message53uk),PChar(message0uk),0) else
                                                                                                                                 Application.MessageBox(PChar(message30en+' '+message53en),PChar(message0en),0);

                                  end
                                     else
                                     begin
                                          If FallbackLang='ru' then Application.MessageBox(PChar(message30ru+'.'),PChar(message0ru),0) else
                                                               If FallbackLang='uk' then Application.MessageBox(PChar(message30uk+'.'),PChar(message0uk),0) else
                                                                                                                                    Application.MessageBox(PChar(message30en+'.'),PChar(message0en),0);

                                     end;
                    Application.ProcessMessages;
                    Form1.Repaint;
                    halt;
                end;
//программа устанавливает саму же себя
If DirectoryExists(UsrBinDir) then
     If ParamStr(0)<>UsrBinDir+'vpnmandriva' then
        If DirectoryExists(MyVpnDir) then
            If ParamStr(0)<>'/vpnpptp/trunk/vpnmandriva/vpnmandriva' then
                                                                  begin
                                                                      If FileExists(UsrBinDir+'vpnmandriva') and FileExists (MyVpnDir+'vpnmandriva.pm') then ProgramInstalled:=true else ProgramInstalled:=false;
                                                                      Shell ('cp -f '+chr(39)+ParamStr(0)+chr(39)+' '+UsrBinDir);
                                                                      Memo1.Lines.Clear;
                                                                      Memo1.Lines.Add('package network::vpn::vpnmandriva;');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('use base qw(network::vpn);');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('use common;');
                                                                      Memo1.Lines.Add('use run_program;');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('sub get_type { '+chr(39)+'vpnmandriva'+chr(39)+' }');
                                                                      Memo1.Lines.Add('sub get_description { N("VPN PPTP") }');
                                                                      Memo1.Lines.Add('sub get_packages { '+chr(39)+'drakx-net'+chr(39)+' }');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('sub read_config {');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('run_program::rooted($::prefix,'+chr(39)+UsrBinDir+'vpnmandriva'+chr(39)+');');
                                                                      Memo1.Lines.Add('end => 1;');
                                                                      Memo1.Lines.Add('}');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('sub get_settings {');
                                                                      Memo1.Lines.Add('exit;');
                                                                      Memo1.Lines.Add('}');
                                                                      Memo1.Lines.Add('');
                                                                      Memo1.Lines.Add('1;');
                                                                      Memo1.Lines.SaveToFile(MyVpnDir+'vpnmandriva.pm');
                                                                      If not ProgramInstalled then
                                                                                              begin
                                                                                                   If FallbackLang='ru' then Application.MessageBox(PChar(message17ru+' '+message51ru+' '+UsrBinDir+'vpnmandriva, '+MyVpnDir+'vpnmandriva.pm.'),PChar(message0ru),0) else
                                                                                                                        If FallbackLang='uk' then Application.MessageBox(PChar(message17uk+' '+message51uk+' '+UsrBinDir+'vpnmandriva, '+MyVpnDir+'vpnmandriva.pm.'),PChar(message0uk),0) else
                                                                                                                                             Application.MessageBox(PChar(message17en+' '+message51en+' '+UsrBinDir+'vpnmandriva, '+MyVpnDir+'vpnmandriva.pm.'),PChar(message0en),0);

                                                                                              end
                                                                                                 else
                                                                                                     begin
                                                                                                          If FallbackLang='ru' then Application.MessageBox(PChar(message54ru+' '+message51ru+' '+UsrBinDir+'vpnmandriva, '+MyVpnDir+'vpnmandriva.pm.'),PChar(message0ru),0) else
                                                                                                                               If FallbackLang='uk' then Application.MessageBox(PChar(message54uk+' '+message51uk+' '+UsrBinDir+'vpnmandriva, '+MyVpnDir+'vpnmandriva.pm.'),PChar(message0uk),0) else
                                                                                                                                                    Application.MessageBox(PChar(message54en+' '+message51en+' '+UsrBinDir+'vpnmandriva, '+MyVpnDir+'vpnmandriva.pm.'),PChar(message0en),0);
                                                                                                      end;
                                                                  end;
If (not DirectoryExists(MyVpnDir)) or  (not DirectoryExists(UsrBinDir)) then
                                                           begin
                                                                If FallbackLang='ru' then Application.MessageBox(PChar(message16ru),PChar(message0ru),0) else
                                                                                     If FallbackLang='uk' then Application.MessageBox(PChar(message16uk),PChar(message0uk),0) else
                                                                                                                              Application.MessageBox(PChar(message16en),PChar(message0en),0);
                                                           end;
end;

procedure TForm1.TabSheet1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   If Button=mbLeft then If Form1.Font.Size<15 then
                            begin
                                 Form1.Font.Size:=Form1.Font.Size+1;
                            end;
   If Button=mbRight then If Form1.Font.Size>1 then
                             begin
                                 Form1.Font.Size:=Form1.Font.Size-1;
                             end;
   AFont:=Form1.Font.Size;
   Form1.Repaint;
   Application.ProcessMessages;
   Form1.Repaint;
end;

initialization

  {$I unit1.lrs}

  Gettext.GetLanguageIDs(Lang,FallbackLang);
  If FallbackLang='be' then FallbackLang:='ru';
  //FallbackLang:='uk'; //просто для проверки при отладке
end.

end.

