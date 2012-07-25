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
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, LResources,
  StdCtrls, ExtCtrls, ComCtrls, unix, Menus, Buttons, AsyncProcess, Process,
  Typinfo, Gettext, BaseUnix, types;

type

  { TMyForm }

  TMyForm = class(TForm)
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
    MyImage: TImage;
    Label_wait: TLabel;
    Label_mppe: TLabel;
    Label_www: TLabel;
    Label_timer: TLabel;
    Label_auth: TLabel;
    Label_IPS: TLabel;
    Label_metric: TLabel;
    Label_peer: TLabel;
    Label_pswd: TLabel;
    Label_user: TLabel;
    MyMemo: TMemo;
    MyPanel: TPanel;
    MyTimer: TTimer;
    procedure Button_createClick(Sender: TObject);
    procedure Button_exitClick(Sender: TObject);
    procedure CheckBox_trafficChange(Sender: TObject);
    procedure Edit_passwdChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MyImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabSheet1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MyTimerStartTimer(Sender: TObject);
    procedure MyTimerStopTimer(Sender: TObject);
    procedure MyTimerTimer(Sender: TObject);
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
  MyForm: TMyForm;
  Lang,FallbackLang:string; //язык системы
  Number_PPP_Iface:integer; //номер ближайшего доступного для настройки интерфейса pppN
  AAsyncProcess:TAsyncProcess; //для запуска внешних приложений
  AFont:integer; //шрифт приложения
  f: text;//текстовый поток
  Code_up_ppp:boolean;//поднято ли VPN на настраиваемом интерфейсе
  PppIface:string;//интерфейс, на котором поднято VPN
  ButtonMiddle:boolean;//отслеживает нажатие средней кнопки мыши на пингвине
  DateStart:int64;//время запуска таймера
  TV:timeval;//время

const

  MyLogDir='/var/log/ppp/';
  EtcPppIpUpDDir='/etc/ppp/ip-up.d/';
  EtcPppIpDownDDir='/etc/ppp/ip-down.d/';
  UsrBinDir='/usr/bin/';
  SBinDir='/sbin/';
  BinDir='/bin/';
  UsrSBinDir='/usr/sbin/';
  EtcPppPeersDir='/etc/ppp/peers/';
  IfcfgDir='/etc/sysconfig/network-scripts/';
  EtcInitDDir='/etc/init.d/';
  MyVpnDir='/usr/lib/libDrakX/network/vpn/';
  EtcDir='/etc/';
  VarRunDir='/var/run/';

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
  message12ru='Управлять соединением можно через net_applet (пакет drakx-net/drakx-net-applet)';
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
  message56ru='Установить соединение VPN PPTP сейчас?';
  message57ru='Отсутствует:';
  message58ru='Найден:';
  message59ru='Не найдена директория:';
  message60ru='Следовательно, эта программа не предназначена для Вашего дистрибутива.';
  message61ru='Проверено: Интернет не работает.';
  message62ru='Проверено: Интернет работает.';
  message63ru='Проверить Интернет? Проверка Интернета может занять несколько секунд.';
  message64ru='Соединение VPN PPTP поднято, но Интернет не работает. Возможно необходимо настроить файервол или маршрутизацию.';
  message65ru='Соединение VPN PPTP не поднято, но Интернет работает.';
  message66ru='Не удалось запустить net_applet.';
  message67ru='Часто имеет смысл немного подождать, дав возможность установиться соединению.';
  message68ru='Минуточку... Ожидайте...';
  message69ru='Повторить проверку Интернета?';
  message70ru='Соединение VPN PPTP поднято.';
  message71ru='Соединение VPN PPTP не поднято.';
  message72ru='Обнаружено несколько дефолтных маршрутов с одинаковой метрикой. Неверная маршрутизация.';
  message73ru='Нажатие на пингвине средней кнопкой мыши даст тестовые параметры соединения, работоспособные если Интернет уже настроен.';
  message74ru='В процессах обнаружен pppd. Убить все pppd?';
  message75ru='Обнаружено, что VPN PPTP уже поднято на настраиваемом интерфейсе. Оно будет сначала отключено.';

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
  message12uk='Керувати з''єднанням можна через net_applet (пакет drakx-net/drakx-net-applet)';
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
  message56uk='Встановити з''єднання VPN PPTP зараз?';
  message57uk='Відсутній:';
  message58uk='Знайден:';
  message59uk='Не знайдена директорія:';
  message60uk='Це означає що ця програма не призначена для Вашого дистрибутиву.';
  message61uk='Перевірено: Інтернет не працює.';
  message62uk='Перевірено: Інтернет працює.';
  message63uk='Перевірити Інтернет? Перевірка Інтернету може зайняти кілька секунд.';
  message64uk='З''єднання VPN PPTP піднято, але Інтернет не працює. Можливо необхідно налаштувати файервол або маршрутизацію.';
  message65uk='З''єднання VPN PPTP не піднято, але Інтернет працює.';
  message66uk='Не вдалося запустити net_applet.';
  message67uk='Часто має сенс трохи почекати, давши можливість встановитися з''єднанню.';
  message68uk='Хвилиночку... Чекайте...';
  message69uk='Повторити перевірку Інтернету?';
  message70uk='З''єднання VPN PPTP піднято.';
  message71uk='З''єднання VPN PPTP не піднято.';
  message72uk='Виявлено кілька дефолтних маршрутів з однаковою метрикою. Невірна маршрутизація.';
  message73uk='Натискання на пінгвінів середньою кнопкою миші дасть тестові параметри з''єднання, працездатні якщо Інтернет вже налаштований.';
  message74uk='У процесах виявлен pppd. Вбити всі pppd?';
  message75uk='Виявлено, що VPN PPTP вже піднято на розширеному інтерфейсі. Воно буде спочатку відключено.';

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
  message12en='You can manage the connection with help net_applet (package drakx-net/drakx-net-applet)';
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
  message56en='Connect VPN PPTP now?';
  message57en='Missing:';
  message58en='Find:';
  message59en='Not found directory:';
  message60en='So, this program is not for your distribution.';
  message61en='Checked: Internet does not work.';
  message62en='Checked: Internet works.';
  message63en='Check the Internet? Check the Internet may take several seconds.';
  message64en='VPN PPTP Connection established, but the Internet does not work. Maybe you need to configure a firewall or routing.';
  message65en='VPN PPTP Connection not established, but the Internet works.';
  message66en='Failed to start net_applet.';
  message67en='Often it makes sense to wait a little, giving the opportunity to establish the connection.';
  message68en='Wait a minute... Expect...';
  message69en='Repeat test of Internet?';
  message70en='VPN PPTP Connection established.';
  message71en='VPN PPTP Connection not established.';
  message72en='Found several default routes with the same metric. Incorrect routing.';
  message73en='Clicking on the penguin middle mouse button will give test the connection settings and workable if the Internet is already configured.';
  message74en='In the process found pppd. Kill all pppd?';
  message75en='Found that VPN PPTP been raised to a customizable interface. It will first be disabled.';

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

procedure CheckVPN;
//проверяет поднялось ли соединение на настраиваемом сетевом интерфейсе pppN
var
  str:string;
begin
  str:='';
  PppIface:='';
  Code_up_ppp:=false;
  If FileExists(VarRunDir+'ppp-vpnmandriva.pid') then
                                                 begin
                                                      popen (f,BinDir+'cat '+VarRunDir+'ppp-vpnmandriva.pid|'+BinDir+'grep ppp','R');
                                                      While not eof(f) do
                                                                begin
                                                                     Readln (f,str);
                                                                     If str<>'' then PppIface:=str;
                                                                end;
                                                      PClose(f);
                                                      if PppIface<>'' then
                                                              begin
                                                                   popen (f,SBinDir+'ifconfig |'+BinDir+'grep '+PppIface,'R');
                                                                   If not eof(f) then If PppIface<>'' then Code_up_ppp:=true;
                                                                   PClose(f);
                                                              end;
                                                 end;
end;

{ TMyForm }

procedure TMyForm.Button_createClick(Sender: TObject);
var
  str,str1:string;
  mppe_string:string;
  y,net_applet_root,found_net_applet:boolean;
  StrUsers:string;
  i,a:integer;
  NoInternet,FoundPpppd:boolean;
  AStringList: TStringList;
  x,code:integer;
begin
Label_wait.Font.Size:=MyForm.Font.Size;
Label_www.Font.Size:=MyForm.Font.Size;
Label_timer.Font.Size:=MyForm.Font.Size*10;
Label_timer.Font.Color:=clRed;
Label_timer.Caption:='0';
//выход из создания подключения
y:=false;
Val(Edit_metric.Text,x,code);
if code<>0 then y:=true;
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
Application.ShowHint:=false;
//запись файла /etc/sysconfig/network-scripts/ifcfg-pppN
FpSystem(UsrBinDir+'printf "DEVICE=ppp'+IntToStr(Number_PPP_Iface)+'\n" > '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_autostart.Checked then FpSystem(UsrBinDir+'printf "ONBOOT=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else FpSystem(UsrBinDir+'printf "ONBOOT=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
FpSystem(UsrBinDir+'printf "METRIC='+Edit_metric.Text+'\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
FpSystem(UsrBinDir+'printf "TYPE=ADSL\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_right.Checked then FpSystem(UsrBinDir+'printf "USERCTL=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else FpSystem(UsrBinDir+'printf "USERCTL=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_traffic.Checked then FpSystem(UsrBinDir+'printf "ACCOUNTING=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else FpSystem(UsrBinDir+'printf "ACCOUNTING=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
FpSystem (BinDir+'chmod a+x '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
//запись файла /etc/ppp/ip-up.d/vpnmandriva-ip-up
If not DirectoryExists (EtcPppIpUpDDir) then FpSystem (BinDir+'mkdir -p '+EtcPppIpUpDDir);
MyMemo.Lines.Clear;
MyMemo.Lines.Add('#!/bin/bash');
MyMemo.Lines.Add('if [ ! $LINKNAME = "vpnmandriva" ]');
MyMemo.Lines.Add('then');
MyMemo.Lines.Add('exit 0');
MyMemo.Lines.Add('fi');
MyMemo.Lines.Add('if [ $USEPEERDNS = "1" ]');
MyMemo.Lines.Add('then');
MyMemo.Lines.Add('     [ -n "$DNS1" ] && '+BinDir+'rm -f '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('     [ -n "$DNS2" ] && '+BinDir+'rm -f '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('            if [ ! -f '+EtcDir+'resolv.conf ]');
MyMemo.Lines.Add('            then');
MyMemo.Lines.Add('                  '+BinDir+'cat /etc/resolvconf/resolv.conf.d/head|'+BinDir+'grep nameserver >> '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('            fi');
MyMemo.Lines.Add('     [ -n "$DNS1" ] && '+BinDir+'echo "nameserver $DNS1" >> '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('     [ -n "$DNS2" ] && '+BinDir+'echo "nameserver $DNS2" >> '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('fi');
MyMemo.Lines.SaveToFile(EtcPppIpUpDDir+'vpnmandriva-ip-up');
FpSystem(BinDir+'chmod a+x '+EtcPppIpUpDDir+'vpnmandriva-ip-up');
//запись файла /etc/ppp/ip-down.d/vpnmandriva-ip-down
If not DirectoryExists (EtcPppIpDownDDir) then FpSystem (BinDir+'mkdir -p '+EtcPppIpDownDDir);
MyMemo.Lines.Clear;
MyMemo.Lines.Add('#!/bin/bash');
MyMemo.Lines.Add('if [ ! $LINKNAME = "vpnmandriva" ]');
MyMemo.Lines.Add('then');
MyMemo.Lines.Add('exit 0');
MyMemo.Lines.Add('fi');
//If FileExists (SBinDir+'service') then MyMemo.Lines.Add('service network restart') else MyMemo.Lines.Add(EtcInitDDir+' network restart');h
If FileExists (SBinDir+'service') then MyMemo.Lines.Add(SBinDir+'service network restart');
If FileExists (UsrSBinDir+'service') then MyMemo.Lines.Add(UsrSBinDir+'service network restart');
If not FileExists (SBinDir+'service') then if not FileExists (UsrSBinDir+'service') then MyMemo.Lines.Add(EtcInitDDir+' network restart');
MyMemo.Lines.SaveToFile(EtcPppIpDownDDir+'vpnmandriva-ip-down');
FpSystem(BinDir+'chmod a+x '+EtcPppIpDownDDir+'vpnmandriva-ip-down');
//запись файла /etc/ppp/peers/pppN
If not DirectoryExists (EtcPppPeersDir) then FpSystem (BinDir+'mkdir -p '+EtcPppPeersDir);
MyMemo.Lines.Clear;
MyMemo.Lines.Add('unit '+IntToStr(Number_PPP_Iface));
MyMemo.Lines.Add('noipdefault');
MyMemo.Lines.Add('defaultroute');
MyMemo.Lines.Add('noauth');
MyMemo.Lines.Add('linkname vpnmandriva');
MyMemo.Lines.Add('usepeerdns');
MyMemo.Lines.Add('lock');
MyMemo.Lines.Add('persist');
MyMemo.Lines.Add('nopcomp');
If (not CheckBox_required.Checked) then if (not CheckBox_stateless.Checked) then if (not CheckBox_no40.Checked) then if (not CheckBox_no56.Checked) then if (not CheckBox_no128.Checked) then
                                                                          MyMemo.Lines.Add('noccp');
MyMemo.Lines.Add('novj');
MyMemo.Lines.Add('kdebug 1');
MyMemo.Lines.Add('holdoff 4');
MyMemo.Lines.Add('maxfail 5');
If CheckBox_nobuffer.Checked then MyMemo.Lines.Add('pty "'+UsrSBinDir+'pptp '+Edit_IPS.Text+' --nolaunchpppd --nobuffer"') else MyMemo.Lines.Add('pty "'+UsrSBinDir+'pptp '+Edit_IPS.Text+' --nolaunchpppd"');
MyMemo.Lines.Add('user "'+Edit_user.Text+'"');
MyMemo.Lines.Add('password "'+Edit_passwd.Text+'"');
If CheckBox_rmschap.Checked then MyMemo.Lines.Add(CheckBox_rmschap.Caption);
If CheckBox_reap.Checked then MyMemo.Lines.Add(CheckBox_reap.Caption);
If CheckBox_rchap.Checked then MyMemo.Lines.Add(CheckBox_rchap.Caption);
If CheckBox_rpap.Checked then MyMemo.Lines.Add(CheckBox_rpap.Caption);
If CheckBox_rmschapv2.Checked then MyMemo.Lines.Add(CheckBox_rmschapv2.Caption);
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
   If mppe_string<>'mppe ' then MyMemo.Lines.Add(mppe_string);
If CheckBox_pppd_log.Checked then
                             begin
                                If not DirectoryExists(MyLogDir) then FpSystem (BinDir+'mkdir -p '+MyLogDir);
                                MyMemo.Lines.Add('debug');
                                MyMemo.Lines.Add('logfile '+MyLogDir+'vpnmandriva.log');
                             end;
MyMemo.Lines.SaveToFile(EtcPppPeersDir+'ppp'+IntToStr(Number_PPP_Iface));
FpSystem (BinDir+'chmod 600 '+EtcPppPeersDir+'ppp'+IntToStr(Number_PPP_Iface));
//применение изменений перезапуском net_applet
popen(f,BinDir+'ps -u root|'+BinDir+'grep net_applet','R');
if eof(f) then net_applet_root:=false else net_applet_root:=true;
PClose(f);
str:='';
StrUsers:='';
FpSystem (UsrBinDir+'killall net_applet');
if not net_applet_root then
                             begin
                                  popen (f,UsrBinDir+'who | '+BinDir+'awk '+chr(39)+'{print $1}'+chr(39),'R'); //получение списка пользователей, залогиненных в системе
                                  if eof(f) then popen (f,UsrBinDir+'who /var/log/wtmp | '+BinDir+'awk '+chr(39)+'{print $1}'+chr(39),'R');
                                  While not eof(f) do
                                        begin
                                             readln(f,str);
                                             if str<>'' then if str<>'root' then if pos(str,StrUsers)=0 then
                                                        begin
                                                             AAsyncProcess := TAsyncProcess.Create(nil);
                                                             AAsyncProcess.CommandLine :=BinDir+'su - '+str+' -c "'+UsrBinDir+'net_applet"';
                                                             AAsyncProcess.Execute;
                                                             while not AAsyncProcess.Running do
                                                                                      MySleep(30);
                                                             Sleep(2000);
                                                             AAsyncProcess.Free;
                                                        end;
                                             StrUsers:=StrUsers+str;
                                        end;
                                  PClose(f);
                                  //обработка результата перезапуска net_applet
                                  found_net_applet:=false;
                                  popen (f,BinDir+'ps -e |'+BinDir+'grep net_applet','R');
                                  If not eof(f) then found_net_applet:=true;
                                  PClose(f);
                                  StrUsers:='';
                                  if not found_net_applet then //пытаемся еще раз перезапустить net_applet другой командой
                                             begin
                                                  popen (f,UsrBinDir+'who | '+BinDir+'awk '+chr(39)+'{print $1}'+chr(39),'R'); //получение списка пользователей, залогиненных в системе
                                                  if eof(f) then popen (f,UsrBinDir+'who /var/log/wtmp | '+BinDir+'awk '+chr(39)+'{print $1}'+chr(39),'R');
                                                  While not eof(f) do
                                                        begin
                                                             readln(f,str);
                                                             if str<>'' then if str<>'root' then if pos(str,StrUsers)=0 then
                                                                        begin
                                                                             AAsyncProcess := TAsyncProcess.Create(nil);
                                                                             AAsyncProcess.CommandLine :=BinDir+'su '+str+' -c "'+UsrBinDir+'net_applet"';
                                                                             AAsyncProcess.Execute;
                                                                             while not AAsyncProcess.Running do
                                                                                                      MySleep(30);
                                                                             Sleep(2000);
                                                                             AAsyncProcess.Free;
                                                                        end;
                                                             StrUsers:=StrUsers+str;
                                                        end;
                                                  PClose(f);
                                             end;
                             end;
if net_applet_root then
                      begin
                          AAsyncProcess := TAsyncProcess.Create(nil);
                          AAsyncProcess.CommandLine :=UsrBinDir+'net_applet';
                          AAsyncProcess.Execute;
                          while not AAsyncProcess.Running do
                                                   MySleep(30);
                          Sleep(2000);
                          AAsyncProcess.Free;
                      end;
if FallbackLang='ru' then Application.MessageBox(PChar(message11ru+' '+message12ru+' '+message13ru+' '+message52ru),PChar(message0ru),0) else
                     If FallbackLang='uk' then Application.MessageBox(PChar(message11uk+' '+message12uk+' '+message13uk+' '+message52uk),PChar(message0uk),0) else
                                                              Application.MessageBox(PChar(message11en+' '+message12en+' '+message13en+' '+message52en),PChar(message0en),0);
//обработка результата перезапуска net_applet
found_net_applet:=false;
popen (f,BinDir+'ps -e |'+BinDir+'grep net_applet','R');
If not eof(f) then found_net_applet:=true;
PClose(f);
str:='';
if not found_net_applet then
               begin
                   If FallbackLang='ru' then str:=message66ru else If FallbackLang='uk' then str:=message66uk else str:=message66en;
                   If not FileExists(UsrBinDir+'net_applet') then If FallbackLang='ru' then str:=str+' '+message57ru+' '+UsrBinDir+'net_applet.' else
                                        if FallbackLang='uk' then str:=str+' '+message57uk+' '+UsrBinDir+'net_applet.' else str:=str+' '+message57en+' '+UsrBinDir+'net_applet.';
                   If not FileExists(UsrBinDir+'net_applet') then If FileExists(UsrBinDir+'net_applet.old') then If FallbackLang='ru' then str:=str+' '+message58ru+' '+UsrBinDir+'net_applet.old.' else
                                        if FallbackLang='uk' then str:=str+' '+message58uk+' '+UsrBinDir+'net_applet.old.' else str:=str+' '+message58en+' '+UsrBinDir+'net_applet.old.';
                   If str<>'' then Application.MessageBox(PChar(str),PChar(message0ru),0);
               end;
If FallbackLang='ru' then i:=Application.MessageBox(PChar(message56ru),PChar(message0ru),1) else if FallbackLang='uk' then i:=Application.MessageBox(PChar(message56uk),PChar(message0ru),1)
                                                                                            else i:=Application.MessageBox(PChar(message56en),PChar(message0ru),1);
if i=1 then
           begin
               CheckVPN;
               If Code_up_ppp then If PppIface='ppp'+IntToStr(Number_PPP_Iface) then
                                                                 begin
                                                                     if FallbackLang='ru' then Application.MessageBox(PChar(message75ru),PChar(message0ru),0) else
                                                                                          If FallbackLang='uk' then Application.MessageBox(PChar(message75uk),PChar(message0uk),0) else
                                                                                                                                   Application.MessageBox(PChar(message75en),PChar(message0en),0);
                                                                     MyTimer.Enabled:=true;
                                                                     MyForm.Enabled:=false;
                                                                     Label_peer.Enabled:=false;
                                                                     Label_IPS.Enabled:=false;
                                                                     Label_user.Enabled:=false;
                                                                     Label_pswd.Enabled:=false;
                                                                     Label_metric.Enabled:=false;
                                                                     Label_auth.Enabled:=false;
                                                                     Label_mppe.Enabled:=false;
                                                                     MyImage.Visible:=false;
                                                                     Label_wait.Visible:=true;
                                                                     Label_www.Visible:=true;
                                                                     Label_timer.Visible:=true;
                                                                     Application.ProcessMessages;
                                                                     AAsyncProcess := TAsyncProcess.Create(nil);
                                                                     AAsyncProcess.CommandLine :=SBinDir+'ifdown '+PppIface;
                                                                     AAsyncProcess.Execute;
                                                                     while AAsyncProcess.Running do
                                                                                                 begin
                                                                                                      mysleep(30);
                                                                                                 end;
                                                                     AAsyncProcess.Free;
                                                                     MyForm.Enabled:=true;
                                                                     Label_peer.Enabled:=true;
                                                                     Label_IPS.Enabled:=true;
                                                                     Label_user.Enabled:=true;
                                                                     Label_pswd.Enabled:=true;
                                                                     Label_metric.Enabled:=true;
                                                                     Label_auth.Enabled:=true;
                                                                     Label_mppe.Enabled:=true;
                                                                     MyImage.Visible:=true;
                                                                     Label_wait.Visible:=false;
                                                                     Label_www.Visible:=false;
                                                                     Label_timer.Visible:=false;
                                                                     MyTimer.Enabled:=false;
                                                                     Application.ProcessMessages;
                                                                 end;
               //проверка pppd в процессах, игнорируя зомби
               FoundPpppd:=false;
               popen(f,BinDir+'ps -e | '+BinDir+'grep pppd','R');
               While not eof(f) do
                                begin
                                    Readln(f,str);
                                    if RightStr(str,9)<>'<defunct>' then FoundPpppd:=true;
                                end;
               PClose(f);
               If FoundPpppd then
                               begin
                                   If FallbackLang='ru' then i:=Application.MessageBox(PChar(message74ru),PChar(message0ru),1) else
                                                                               if FallbackLang='uk' then i:=Application.MessageBox(PChar(message74uk),PChar(message0ru),1)
                                                                                                                else i:=Application.MessageBox(PChar(message74en),PChar(message0ru),1);
                                   if i=1 then
                                              begin
                                                  AAsyncProcess := TAsyncProcess.Create(nil);
                                                  AAsyncProcess.CommandLine :=UsrBinDir+'killall pppd';
                                                  AAsyncProcess.Execute;
                                                  while AAsyncProcess.Running do
                                                                              begin
                                                                                   mysleep(30);
                                                                              end;
                                                  MySleep(1000);
                                                  AAsyncProcess.Free;
                                              end;
                               end;
               AAsyncProcess := TAsyncProcess.Create(nil);
               AAsyncProcess.CommandLine :=SBinDir+'ifup ppp'+IntToStr(Number_PPP_Iface);
               AAsyncProcess.Execute;
               AAsyncProcess.Free;
               If FallbackLang='ru' then i:=Application.MessageBox(PChar(message63ru+' '+message67ru),PChar(message0ru),1) else
                                                           if FallbackLang='uk' then i:=Application.MessageBox(PChar(message63uk+' '+message67uk),PChar(message0ru),1)
                                                                                            else i:=Application.MessageBox(PChar(message63en+' '+message67en),PChar(message0ru),1);
               if i=1 then
                          begin
                               repeat
                                     //тест интернета
                                     CheckVPN;
                                     MyTimer.Enabled:=true;
                                     MyForm.Enabled:=false;
                                     Label_peer.Enabled:=false;
                                     Label_IPS.Enabled:=false;
                                     Label_user.Enabled:=false;
                                     Label_pswd.Enabled:=false;
                                     Label_metric.Enabled:=false;
                                     Label_auth.Enabled:=false;
                                     Label_mppe.Enabled:=false;
                                     MyImage.Visible:=false;
                                     Label_wait.Visible:=true;
                                     Label_www.Visible:=true;
                                     Label_timer.Visible:=true;
                                     Application.ProcessMessages;
                                     AStringList := TStringList.Create;
                                     AAsyncProcess := TAsyncProcess.Create(nil);
                                     If (Edit_IPS.Text='connect.lb.swissvpn.net') and (Edit_user.Text='swissvpntest') and (Edit_passwd.Text='swissvpntest') then
                                                                                                                          AAsyncProcess.CommandLine :=SBinDir+'ping -c1 swissvpn.net' else
                                                                                                                                        AAsyncProcess.CommandLine :=SBinDir+'ping -c1 yandex.ru';
                                     AAsyncProcess.Options := AAsyncProcess.Options + [poUsePipes];
                                     AAsyncProcess.Execute;
                                     while AAsyncProcess.Running do
                                                             begin
                                                                 mysleep(30);
                                                             end;
                                     AStringList.LoadFromStream(AAsyncProcess.Output);
                                     NoInternet:=true;
                                     for i:=0 to AStringList.Count-1 do
                                                  if pos('1 received',AStringList[i])<>0 then NoInternet:=false;
                                     AAsyncProcess.Free;
                                     AStringList.Free;
                                     MyForm.Enabled:=true;
                                     Label_peer.Enabled:=true;
                                     Label_IPS.Enabled:=true;
                                     Label_user.Enabled:=true;
                                     Label_pswd.Enabled:=true;
                                     Label_metric.Enabled:=true;
                                     Label_auth.Enabled:=true;
                                     Label_mppe.Enabled:=true;
                                     MyImage.Visible:=true;
                                     Label_wait.Visible:=false;
                                     Label_www.Visible:=false;
                                     Label_timer.Visible:=false;
                                     MyTimer.Enabled:=false;
                                     Application.ProcessMessages;
                                     If (NoInternet) and (not Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message71ru+' '+message61ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message71uk+' '+message61uk),PChar(message0ru),0)
                                                                                                                              else Application.MessageBox(PChar(message71en+' '+message61en),PChar(message0ru),0);
                                     If (not NoInternet) and (Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message70ru+' '+message62ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message70uk+' '+message62uk),PChar(message0ru),0)
                                                                                                                              else Application.MessageBox(PChar(message70en+' '+message62en),PChar(message0ru),0);
                                     If (NoInternet) and (Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message64ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message64uk),PChar(message0ru),0)
                                                                                                                              else Application.MessageBox(PChar(message64en),PChar(message0ru),0);
                                     If (not NoInternet) and (not Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message65ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message65uk),PChar(message0ru),0)
                                                                                                                              else Application.MessageBox(PChar(message65en),PChar(message0ru),0);
                                     If (NoInternet) and (Code_up_ppp)  then  //проверка кол-ва дефолтных маршрутов с одинаковой метрикой
                                                                       begin
                                                                           Str:=SBinDir+'route -n|'+BinDir+'awk '+chr(39)+'{print $1" "$5}'+chr(39)+'|'+BinDir+'grep 0.0.0.0';
                                                                           popen(f,Str,'R');
                                                                           i:=0;
                                                                           str:='';
                                                                           str1:='';
                                                                           while not eof(f) do
                                                                                            begin
                                                                                               Readln(f,str);
                                                                                               if str=str1 then i:=i+1;
                                                                                               str1:=str;
                                                                                            end;
                                                                           PClose(f);
                                                                           if i>0 then
                                                                                      begin
                                                                                            if FallbackLang='ru' then Application.MessageBox(PChar(message72ru),PChar(message0ru),0) else
                                                                                                                If FallbackLang='uk' then Application.MessageBox(PChar(message72uk),PChar(message0uk),0) else
                                                                                                                                                      Application.MessageBox(PChar(message72en),PChar(message0en),0);
                                                                                      end;
                                                                       end;
                                     If FallbackLang='ru' then a:=Application.MessageBox(PChar(message69ru),PChar(message0ru),1) else
                                                                                        if FallbackLang='uk' then a:=Application.MessageBox(PChar(message69uk),PChar(message0ru),1)
                                                                                                                             else i:=Application.MessageBox(PChar(message69en),PChar(message0ru),1);
                               until (a<>1);
                          end;
           end;
Application.ShowHint:=true;
Application.ProcessMessages;
end;


procedure TMyForm.Button_exitClick(Sender: TObject);
begin
     halt;
end;


procedure TMyForm.CheckBox_trafficChange(Sender: TObject);
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

procedure TMyForm.Edit_passwdChange(Sender: TObject);
begin
  if not (Edit_passwd.Text='swissvpntest') then Edit_passwd.EchoMode:=emPassword else Edit_passwd.EchoMode:=emNormal;
end;


procedure TMyForm.FormCreate(Sender: TObject);
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
If not DirectoryExists(IfcfgDir) then
                                     begin
                                         If FallbackLang='ru' then Application.MessageBox(PChar(message59ru+' '+IfcfgDir+'. '+message60ru+ ' '+message9ru),PChar(message0ru),0) else
                                                          If FallbackLang='uk' then Application.MessageBox(PChar(message59uk+' '+IfcfgDir+'. '+message60uk+ ' '+message9uk),PChar(message0uk),0) else
                                                                                                    Application.MessageBox(PChar(message59en+' '+IfcfgDir+'. '+message60en+ ' '+message9en),PChar(message0en),0);
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
             MyForm.Hint:=MakeHint(message33ru+' '+message34ru,5);
             MyPanel.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Edit_metric.Hint:=MakeHint(message2ru,5);
             CheckBox_right.Hint:=MakeHint(message4ru,5);
             CheckBox_autostart.Hint:=MakeHint(message5ru+' '+message14ru,7);
             CheckBox_traffic.Hint:=MakeHint(message6ru,5);
             CheckBox_nobuffer.Hint:=MakeHint(message15ru,5);
             Label_IPS.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_peer.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_user.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_pswd.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_auth.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Label_mppe.Hint:=MakeHint(message33ru+' '+message34ru,5);
             Edit_IPS.Hint:=MakeHint(message1ru+' '+message7ru+' '+message73ru,6);
             Edit_user.Hint:=MakeHint(message1ru+' '+message73ru,7);
             Edit_passwd.Hint:=MakeHint(message1ru+' '+message73ru,7);
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
             MyImage.Hint:=MakeHint(message33ru+' '+message34ru+' '+message73ru,5);
             CheckBox_pppd_log.Hint:=MakeHint(message50ru,6);
        end;
    2:
    begin
         MyForm.Hint:=MakeHint(message33uk+' '+message34uk,5);
         MyPanel.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Edit_metric.Hint:=MakeHint(message2uk,5);
         CheckBox_right.Hint:=MakeHint(message4uk,5);
         CheckBox_autostart.Hint:=MakeHint(message5uk+' '+message14uk,7);
         CheckBox_traffic.Hint:=MakeHint(message6uk,5);
         CheckBox_nobuffer.Hint:=MakeHint(message15uk,5);
         Label_IPS.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_peer.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_user.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_pswd.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_auth.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Label_mppe.Hint:=MakeHint(message33uk+' '+message34uk,5);
         Edit_IPS.Hint:=MakeHint(message1uk+' '+message7uk+' '+message73uk,6);
         Edit_user.Hint:=MakeHint(message1uk+' '+message73uk,7);
         Edit_passwd.Hint:=MakeHint(message1uk+' '+message73uk,7);
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
         MyImage.Hint:=MakeHint(message33uk+' '+message34uk+' '+message73uk,5);
         CheckBox_pppd_log.Hint:=MakeHint(message50uk,6);
    end;
else
    begin
         MyForm.Hint:=MakeHint(message33en+' '+message34en,5);
         MyPanel.Hint:=MakeHint(message33en+' '+message34en,5);
         Edit_metric.Hint:=MakeHint(message2en,5);
         CheckBox_right.Hint:=MakeHint(message4en,5);
         CheckBox_autostart.Hint:=MakeHint(message5en+' '+message14en,7);
         CheckBox_traffic.Hint:=MakeHint(message6en,5);
         CheckBox_nobuffer.Hint:=MakeHint(message15en,5);
         Label_IPS.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_peer.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_user.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_pswd.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_auth.Hint:=MakeHint(message33en+' '+message34en,5);
         Label_mppe.Hint:=MakeHint(message33en+' '+message34en,5);
         Edit_IPS.Hint:=MakeHint(message1en+' '+message7en+' '+message73en,6);
         Edit_user.Hint:=MakeHint(message1en+' '+message73en,7);
         Edit_passwd.Hint:=MakeHint(message1en+' '+message73en,7);
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
         MyImage.Hint:=MakeHint(message33en+' '+message34en+' '+message73en,5);
         CheckBox_pppd_log.Hint:=MakeHint(message50en,6);
    end;
end;
//заполнение приложения текстом в соответствии с языком
case q of
    1:
        begin
             MyForm.Caption:=message48ru;
             Label_peer.Caption:=message35ru;
             Label_IPS.Caption:=message36ru;
             Label_user.Caption:=message37ru;
             Label_pswd.Caption:=message38ru;
             Label_metric.Caption:=message39ru;
             CheckBox_right.Caption:=message40ru;
             CheckBox_autostart.Caption:=message41ru;
             CheckBox_traffic.Caption:=message42ru;
             CheckBox_nobuffer.Caption:=message43ru;
             Label_auth.Caption:=message44ru;
             Label_mppe.Caption:=message45ru;
             Button_exit.Caption:=message46ru;
             Button_create.Caption:=message47ru;
             CheckBox_pppd_log.Caption:=message49ru+' '+MyLogDir+'vpnmandriva.log';
             Label_wait.Caption:=message68ru;
        end;
    2:
        begin
             MyForm.Caption:=message48uk;
             Label_peer.Caption:=message35uk;
             Label_IPS.Caption:=message36uk;
             Label_user.Caption:=message37uk;
             Label_pswd.Caption:=message38uk;
             Label_metric.Caption:=message39uk;
             CheckBox_right.Caption:=message40uk;
             CheckBox_autostart.Caption:=message41uk;
             CheckBox_traffic.Caption:=message42uk;
             CheckBox_nobuffer.Caption:=message43uk;
             Label_auth.Caption:=message44uk;
             Label_mppe.Caption:=message45uk;
             Button_exit.Caption:=message46uk;
             Button_create.Caption:=message47uk;
             CheckBox_pppd_log.Caption:=message49uk+' '+MyLogDir+'vpnmandriva.log';
             Label_wait.Caption:=message68uk;
        end;
else
    begin
        MyForm.Caption:=message48en;
        Label_peer.Caption:=message35en;
        Label_IPS.Caption:=message36en;
        Label_user.Caption:=message37en;
        Label_pswd.Caption:=message38en;
        Label_metric.Caption:=message39en;
        CheckBox_right.Caption:=message40en;
        CheckBox_autostart.Caption:=message41en;
        CheckBox_traffic.Caption:=message42en;
        CheckBox_nobuffer.Caption:=message43en;
        Label_auth.Caption:=message44en;
        Label_mppe.Caption:=message45en;
        Button_exit.Caption:=message46en;
        Button_create.Caption:=message47en;
        CheckBox_pppd_log.Caption:=message49en+' '+MyLogDir+'vpnmandriva.log';
        Label_wait.Caption:=message68en;
    end;
end;
//масштабирование формы в зависимости от разрешения экрана
   MyForm.Position:=poScreenCenter;
   If Screen.Height<440 then
                            begin
                             AFont:=6;
                             MyForm.Height:=Screen.Height-50;
                             MyForm.Width:=Screen.Width;
                            end;
   If Screen.Height<=480 then
                        begin
                             AFont:=6;
                             MyForm.Font.Size:=AFont;
                             MyForm.Height:=Screen.Height-45;
                             MyForm.Width:=Screen.Width;
                        end;
   If Screen.Height<550 then If not (Screen.Height<=480) then
                         begin
                             AFont:=6;
                         end;
   If Screen.Height>550 then   //разрешение в основном нетбуков
                        begin
                             AFont:=8;
                             MyForm.Font.Size:=AFont;
                             MyForm.Height:=550;
                             MyForm.Width:=794;
                        end;
   If Screen.Height>1000 then
                        begin
                             AFont:=10;
                             MyForm.Font.Size:=AFont;
                             MyForm.Height:=650;
                             MyForm.Width:=884;
                         end;
If not FileExists(UsrSBinDir+'pptp') then
                                        begin
                                            If FallbackLang='ru' then Application.MessageBox(PChar(message3ru),PChar(message0ru),0) else
                                                                 If FallbackLang='uk' then Application.MessageBox(PChar(message3uk),PChar(message0uk),0) else
                                                                                                          Application.MessageBox(PChar(message3en),PChar(message0en),0);
                                            Application.ProcessMessages;
                                            MyForm.Repaint;
                                            halt;
                                        end;
//проверка vpnmandriva в процессах root, исключение запуска под иными пользователями
  Apid:=FpGetpid;
  Apidroot:=0;
  popen (f,BinDir+'ps -u root | '+BinDir+'grep vpnmandriva | '+BinDir+'awk '+chr(39)+'{print $1}'+chr(39),'R');
  while not eof(f) do
     begin
        readln(f,Apidroot);
        If Apid=Apidroot then break;
     end;
  PClose(f);
  nostart:=false;
  popen (f,BinDir+'ps -u root | '+BinDir+'grep vpnmandriva | '+BinDir+'awk '+chr(39)+'{print $4}'+chr(39),'R');
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
                    MyForm.Repaint;
                    halt;
                end;
//программа устанавливает саму же себя
If DirectoryExists(UsrBinDir) then
     If ParamStr(0)<>UsrBinDir+'vpnmandriva' then
        If DirectoryExists(MyVpnDir) then
            If ParamStr(0)<>'/vpnpptp/trunk/vpnmandriva/vpnmandriva' then
                                                                  begin
                                                                      If FileExists(UsrBinDir+'vpnmandriva') and FileExists (MyVpnDir+'vpnmandriva.pm') then ProgramInstalled:=true else ProgramInstalled:=false;
                                                                      FpSystem (BinDir+'cp -f '+chr(39)+ParamStr(0)+chr(39)+' '+UsrBinDir);
                                                                      MyMemo.Lines.Clear;
                                                                      MyMemo.Lines.Add('package network::vpn::vpnmandriva;');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('use base qw(network::vpn);');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('use common;');
                                                                      MyMemo.Lines.Add('use run_program;');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('sub get_type { '+chr(39)+'vpnmandriva'+chr(39)+' }');
                                                                      MyMemo.Lines.Add('sub get_description { N("VPN PPTP") }');
                                                                      MyMemo.Lines.Add('sub get_packages { '+chr(39)+'drakx-net'+chr(39)+' }');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('sub read_config {');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('run_program::rooted($::prefix,'+chr(39)+UsrBinDir+'vpnmandriva'+chr(39)+');');
                                                                      MyMemo.Lines.Add('end => 1;');
                                                                      MyMemo.Lines.Add('}');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('sub get_settings {');
                                                                      MyMemo.Lines.Add('exit;');
                                                                      MyMemo.Lines.Add('}');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('1;');
                                                                      MyMemo.Lines.SaveToFile(MyVpnDir+'vpnmandriva.pm');
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

procedure TMyForm.MyImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
If Button=mbmiddle then if ButtonMiddle then
                        begin
                            Edit_IPS.Text:='';
                            Edit_user.Text:='';
                            Edit_passwd.Text:='';
                            ButtonMiddle:=false;
                            exit;
                        end;
 If Button=mbmiddle then if not ButtonMiddle then
                         begin
                             Edit_IPS.Text:='connect.lb.swissvpn.net';
                             Edit_user.Text:='swissvpntest';
                             Edit_passwd.Text:='swissvpntest';
                             ButtonMiddle:=true;
                         end;
 MyForm.TabSheet1MouseDown(Sender,Button,Shift,X,Y);
end;

procedure TMyForm.TabSheet1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   If Button=mbLeft then If MyForm.Font.Size<15 then
                            begin
                                 MyForm.Font.Size:=MyForm.Font.Size+1;
                            end;
   If Button=mbRight then If MyForm.Font.Size>1 then
                             begin
                                 MyForm.Font.Size:=MyForm.Font.Size-1;
                             end;
   AFont:=MyForm.Font.Size;
   MyForm.Repaint;
   Application.ProcessMessages;
   MyForm.Repaint;
end;

procedure TMyForm.MyTimerStartTimer(Sender: TObject);
begin
  fpGettimeofday(@TV,nil);
  DateStart:=TV.tv_sec;
end;

procedure TMyForm.MyTimerStopTimer(Sender: TObject);
begin
  Label_timer.Caption:='0';
end;

procedure TMyForm.MyTimerTimer(Sender: TObject);
begin
  fpGettimeofday(@TV,nil);
  Label_timer.Caption:=IntToStr(TV.tv_sec-DateStart);
end;

initialization

  {$I unit1.lrs}

  Gettext.GetLanguageIDs(Lang,FallbackLang);
  If FallbackLang='be' then FallbackLang:='ru';
  //FallbackLang:='en'; //просто для проверки при отладке
end.

end.

