{ PPTP/L2TP/OpenL2TP VPN setup

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
  UnitMyMessageBox, AsyncProcess, StdCtrls, ExtCtrls, ComCtrls, unix,
  Translations, Menus, Unit2, Process, Typinfo, Gettext, BaseUnix, types,
  LCLProc, Buttons, IniPropStorage;

type

  { TForm1 }

  TForm1 = class(TForm)
    Autostartpppd: TCheckBox;
    Autostart_ponoff: TCheckBox;
    balloon: TCheckBox;
    CheckBox_shorewall: TCheckBox;
    Delete: TButton;
    ButtonTest: TButton;
    ButtonRestart: TButton;
    ButtonVPN: TButton;
    ButtonHidePass: TButton;
    Button_create: TButton;
    ButtonHelp: TButton;
    Button_exit: TButton;
    Button_more: TButton;
    Button_next1: TButton;
    Button_next2: TButton;
    dhcp_route: TCheckBox;
    etc_hosts: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    ComboBoxDistr: TComboBox;
    CheckBox_required: TCheckBox;
    CheckBox_no128: TCheckBox;
    CheckBox_rpap: TCheckBox;
    CheckBox_rmschapv2: TCheckBox;
    ComboBoxVPN: TComboBox;
    EditDNS3: TEdit;
    EditDNS4: TEdit;
    Edit_mru: TEdit;
    IniPropStorage1: TIniPropStorage;
    Label13: TLabel;
    Label14: TLabel;
    Label44: TLabel;
    Label9: TLabel;
    LabelDNS3: TLabel;
    LabelDNS4: TLabel;
    Label_mru: TLabel;
    Memo2: TMemo;
    MemoTest: TMemo;
    EditDNSdop3: TEdit;
    EditDNS1: TEdit;
    EditDNS2: TEdit;
    Edit_mtu: TEdit;
    LabelDNS2: TLabel;
    LabelDNS1: TLabel;
    Label_mtu: TLabel;
    Memonew1: TMemo;
    Memonew2: TMemo;
    Memo_Autostartpppd: TMemo;
    Memo_sudo: TMemo;
    Memo_vpnpptp_ponoff_desktop: TMemo;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Memo_networktest: TMemo;
    Memo_bindutilshost: TMemo;
    Memo_ip_IPS: TMemo;
    Metka: TLabel;
    Memo_config: TMemo;
    CheckBox_desktop: TCheckBox;
    CheckBox_no40: TCheckBox;
    CheckBox_no56: TCheckBox;
    CheckBox_rchap: TCheckBox;
    CheckBox_reap: TCheckBox;
    CheckBox_rmschap: TCheckBox;
    CheckBox_stateless: TCheckBox;
    Label41: TLabel;
    Edit_MinTime: TEdit;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Edit_MaxTime: TEdit;
    Edit_eth: TEdit;
    Edit_gate: TEdit;
    Edit_IPS: TEdit;
    Edit_passwd: TEdit;
    Edit_peer: TEdit;
    Edit_user: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label25: TLabel;
    Label3: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label4: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label_IPS: TLabel;
    Label_gate: TLabel;
    Label_peer: TLabel;
    Label_route: TLabel;
    Label_user: TLabel;
    Label_pswd: TLabel;
    Memo_eth: TMemo;
    Memo_peer: TMemo;
    Memo_ip_up: TMemo;
    Memo_ip_down: TMemo;
    Memo_gate: TMemo;
    Memo_create: TMemo;
    Memo_route: TMemo;
    Memo_users: TMemo;
    Mii_tool_no: TCheckBox;
    networktest: TCheckBox;
    nobuffer: TCheckBox;
    PageControl1: TPageControl;
    Pppd_log: TCheckBox;
    pppnotdefault: TCheckBox;
    Reconnect_pptp: TCheckBox;
    routeDNSauto: TCheckBox;
    routevpnauto: TCheckBox;
    route_IP_remote: TCheckBox;
    Sudo_configure: TCheckBox;
    Widget: TCheckBox;
    Sudo_ponoff: TCheckBox;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Timer1: TTimer;
    Tmpnostart: TMemo;
    procedure AutostartpppdChange(Sender: TObject);
    procedure Autostart_ponoffChange(Sender: TObject);
    procedure balloonChange(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure ButtonHidePassClick(Sender: TObject);
    procedure ButtonRestartClick(Sender: TObject);
    procedure ButtonTestClick(Sender: TObject);
    procedure ButtonVPNClick(Sender: TObject);
    procedure Button_createClick(Sender: TObject);
    procedure Button_exitClick(Sender: TObject);
    procedure Button_moreClick(Sender: TObject);
    procedure Button_next1Click(Sender: TObject);
    procedure Button_next2Click(Sender: TObject);
    procedure CheckBox_no128Change(Sender: TObject);
    procedure CheckBox_no40Change(Sender: TObject);
    procedure CheckBox_no56Change(Sender: TObject);
    procedure CheckBox_rchapChange(Sender: TObject);
    procedure CheckBox_reapChange(Sender: TObject);
    procedure CheckBox_requiredChange(Sender: TObject);
    procedure CheckBox_rmschapChange(Sender: TObject);
    procedure CheckBox_rmschapv2Change(Sender: TObject);
    procedure CheckBox_rpapChange(Sender: TObject);
    procedure CheckBox_shorewallChange(Sender: TObject);
    procedure CheckBox_statelessChange(Sender: TObject);
    procedure ComboBoxDistrKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBoxVPNChange(Sender: TObject);
    procedure ComboBoxVPNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeleteClick(Sender: TObject);
    procedure Edit_peerChange(Sender: TObject);
    procedure etc_hostsChange(Sender: TObject);
    procedure GroupBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GroupBox2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GroupBox3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure networktestChange(Sender: TObject);
    procedure pppnotdefaultChange(Sender: TObject);
    procedure routevpnautoChange(Sender: TObject);
    procedure dhcp_routeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Sudo_configureChange(Sender: TObject);
    procedure Sudo_ponoffChange(Sender: TObject);
    procedure TabSheet1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoIconDesktop(uin,prilozh:string;dodelete:boolean;Profile:string);
    procedure DoIconDesktopForAll(Prilozh:string);
    procedure CheckFiles;
    procedure Timer1Timer(Sender: TObject);
    procedure GetTestLog(str_log:string);
  private
    { private declarations }
  public
    { public declarations }
  end;

  TMyHintWindow = class(THintWindow)
  public
    procedure ActivateHint(Rect: TRect; const AHint: string); override;
    constructor Create(AOwner: TComponent); override;
  end;

{ TTranslator }
TTranslator = class(TAbstractTranslator)
private
  FFormClassName : String;
  FPOFile:TPOFile;
public
  constructor Create(POFileName:string);
  destructor Destroy;override;
  procedure TranslateStringProperty(Sender:TObject; const Instance: TPersistent; PropInfo: PPropInfo; var Content:string);override;
end;

var
  Form1: TForm1;
  POFileName : string; //файл перевода
  Lang,FallbackLang:string; //язык системы
  Translate:boolean; // переведено или еще не переведено
  dhclient:boolean; // запущен ли и установлен ли dhclient
  IPS: boolean; // если true, то в поле vpn-сервера введён ip; если false - то имя
  StartMessage:boolean; // принудительное блокирование сообщений
  BindUtils:boolean; //установлен ли пакет bind-utils
  Sudo:boolean; //установлен ли пакет sudo
  More:boolean; //отслеживает, что кнопку Button_more уже нажимали
  DNS_auto:boolean; //если false, то DNS провайдер выдает для ручного ввода
  DNSA,DNSB,DNSdopC,DNSC,DNSD:string; //автоопределенные конфигуратором DNS
  AProcess: TAsyncProcess; //для запуска внешних приложений
  AFont:integer; //шрифт приложения
  ubuntu:boolean; //используется ли дистрибутив ubuntu
  debian:boolean; //используется ли дистрибутив debian
  suse:boolean; //используется ли дистрибутив suse
  mageia:boolean; //используется ли дистрибутив mageia
  fedora:boolean; //используется ли дистрибутив fedora
  CountInterface:integer; //считает сколько в системе поддерживаемых программой интерфейсов
  PressCreate:boolean; //нажата ли кнопка Create, запущен процесс создания подключения
  PingInternetStr:string; //адрес внешнего пингуемого сайта
  NetServiceStr:string; //какой сервис управляет сетью
  ServiceCommand:string; //команда service или systemctl, или другая команда
  DhclientStartGood:boolean; //false если dhclient стартанул неудачно или не стартовал вообще
  f,f0,f_bin: text;//текстовый поток
  Code_up_ppp:boolean; //существует ли интерфейс pppN
  PppIface:string; //точный интерфейс pppN
  ProfileName:string; //определяет какое имя соединения использовать
  ProfileStrDefault:string; //имя соединения, используемое по-умолчанию
  ProfileForDelete:string; //имя соединения для удаления
  link_on_desktop:boolean; //создался ли ярлык на рабочем столе
  StartKoli4estvo:int64; //сколько последних строк лога просматривать в тестовом запуске
  str_date:string; //дата-метка в логе для поиска
  z_num:integer; //считает сколько строк в тестовом запуске уже выведено на экран
  no_resolv_conf:boolean; //существует ли файл /etc/resolv.conf
  error_man_pppd:boolean; //если нет в man про pppd
  default_mppe:boolean; //настройка mppe опциями по-умолчанию
  First_Label1:string; //изначальное значение для Form1.Label1

const
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
  EtcDir='/etc/';
  VarLogDir='/var/log/ppp/';
  UsrSBinDir='/usr/sbin/';
  VarRunXl2tpdDir='/var/run/xl2tpd/';
  EtcInitDDir='/etc/init.d/';
  SystemdDir='/lib/systemd/system/';
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
  UsrLibPppdDir='/usr/lib/pppd/';
  UsrLib64PppdDir='/usr/lib64/pppd/';

resourcestring
  message0='Внимание!';
  message1='Поля "Провайдер (IP или имя)", "Имя соединения", "Пользователь", "Пароль" обязательны к заполнению.';
  message2='Не найдено офисное приложение для вывода справки, читающее формат doc. Вы можете самостоятельно прочитать справку, которая находится:';
  message3='Так как Вы не выбрали реконнект, то выбор встроенного в демон pppd/xl2tpd/openl2tp/openl2tpd реконнекта проигнорирован.';
  message4='Модуль ponoff еще не завершил свою работу. Дождитесь завершения работы модуля ponoff и повторно запустите конфигуратор vpnpptp.';
  message5='Невозможно одновременно не контролировать state сетевого кабеля и задать время реконнекта 0. Время реконнекта было возвращено на значение по умолчанию:';
  message6='Для того, чтобы разрешить пользователям конфигурировать соединение сначала установите пакет sudo.';
  message7='Рабочий стол';//папка (директория) пользователя
  message8='В поле "Время дозвона" можно ввести лишь число в пределах от 5 до 255 сек.';
  message9='Эта опция позволяет пользователям запускать конфигуратор VPN PPTP/L2TP/OpenL2TP без пароля администратора и конфигурировать соединение.';
  message10='В поле "Время реконнекта" можно ввести лишь число в пределах от 0 до 255 сек.';
  message11='<Да> - установить в графике, <Нет> - установить без графики, <Отмена> - отмена.';
  message12='Сетевой интерфейс не определился.';
  message13='Сетевой кабель для автоматического определения шлюза локальной сети не подключен.';
  message14='Не удалось автоматически определить шлюз локальной сети.';
  message15='Поле "Сетевой интерфейс" заполнено неверно. Оно не может быть пустым и не может быть none.';
  message16='Поле "Шлюз локальной сети" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message17='Поле "MTU" заполнено неверно. Разрешен лишь диапазон [576..1460..1492..1500].';
  message18='Запуск этой программы возможен только под администратором или с разрешения администратора. Нажмите <ОК> для отказа от запуска.';
  message19='Другая такая же программа уже пытается сконфигурировать VPN PPTP/L2TP/OpenL2TP. Нажмите <ОК> для отказа от двойного запуска.';
  message20='Невозможно настроить VPN PPTP в связи с отсутствием пакета pptp-linux или пакета pptp.';
  message21='Эта опция позволяет запустить модуль ponoff при старте операционной системы и установить соединение VPN PPTP/L2TP/OpenL2TP автозагрузкой.';
  message22='Невозможно создать ярлык на Рабочем столе, так как используется нестандартный идентификатор пользователя и/или локализация.';
  message23='Невозможно создать ярлык на Рабочем столе, так как отсутствует файл';
  message24='Для того, чтобы разрешить автозапуск интернета при старте системы сначала установите пакет sudo.';
  message25='Не установлен и не запущен dhclient (то есть пакет dhcp-client). Возможны проблемы в работе сети.';
  message26='Не удалось определить IP-адрес VPN-сервера. VPN-сервер не пингуется. Или он введён неправильно, или проблема с DNS.';
  message27='Маршруты не могут приходить через DHCP, так как не установлен и не запущен dhclient (то есть пакет dhcp-client).';
  message28='Нельзя определить IP-адрес VPN-сервера, так как строка для ввода не заполнена.';
  message29='Его установка необязательна, но она ускорит механизм программного добавления маршрута к VPN-серверу.';
  message30='Используйте опцию отключения контроля state сетевого кабеля если только по другому не работает (об этом попросит сама программа).';
  message31='Встроенный в демон pppd/xl2tpd/openl2tp/openl2tpd механизм реконнекта не умеет контролировать state сетевого кабеля,';
  message32='Ведите лог pppd для того, чтобы выяснить ошибки настройки соединения, ошибки при соединении и т.д.';
  message33='Получение маршрутов через DHCP необходимо для одновременной работы локальной сети и интернета, но провайдер не всегда их присылает.';
  message34='Эта опция настраивает файервол лишь для интернета, но не для p2p и не для других соединений.';
  message35='Отменив получение маршрутов через DHCP, не будут одновременно работать интернет и локальная сеть, а будет работать только интернет.';
  message36='Отменить настройку файервола программой стоит только если файервол отключен, или файервол Вами самостоятельно настраивается.';
  message37='Маршрутизируйте VPN-сервер всегда, кроме случаев если его маршрутизация в силу различных причин не требуется.';
  message38='При выборе этой опции проверяется пинг VPN-, DNS-сервера, пинг шлюза локальной сети, пинг yandex.ru, выявляются основные проблемы, выводя сообщения.';
  message39='Отменить эту опцию стоит только если у Вас стабильные локальная сеть и интернет, и они никогда не падают.';
  message40='Эта опция блокирует все всплывающие сообщения из трея/виджета, а также отключает проверку DNS-, VPN-сервера, шлюза локальной сети и есть ли интернет.';
  message41='Проверка показала, что маршруты через DHCP не приходят, или настройка не требуется.';
  message42='Получение маршрутов через DHCP будет отменено, так как маршруты через DHCP не приходят, или настройка не требуется.';
  message43='VPN-сервер не пингуется. Устраните проблему и заново запустите конфигуратор.';
  message44='Шлюз локальной сети не пингуется или теряются пакеты. Но это не всегда влияет на поднятие VPN.';
  message45='Пингуется VPN-сервер. Ожидайте...';
  message46='Определяется IP-адрес VPN-сервера через команду ping. Ожидайте...';
  message47='Пингуется шлюз локальной сети. Ожидайте...';
  message48='Осуществляется подготовка сети для проверки приходят ли маршруты через DHCP. Ожидайте...';
  message49='Сеть подготовлена для проверки приходят ли маршруты через DHCP. Вызывается dhclient. Ожидайте...';
  message50='Определяются IP-адреса VPN-сервера через команду host из пакета bind-utils. Ожидайте...';
  message51='Опции в этой секции устанавливаются только для текущего соединения';
  message52='Пинг проверен';
  message53='Минуточку...';
  message54='Не определилось ни одного IP-адреса VPN-сервера.';
  message55='Часто используется аутентификация mschap v2 - это одновременный выбор refuse-eap, refuse-chap, refuse-mschap, refuse-pap.';
  message56='Эта опция создает ярлык ponoff на Рабочем столе для доступа в интернет пользователю, позволяя ему управлять соединением через иконку в трее.';
  message57='Для того, чтобы разрешить пользователям управлять подключением сначала установите пакет sudo.';
  message58='При использовании опции refuse-chap демон pppd не согласится аутентифицировать себя по протоколу CHAP.';
  message59='Выбор опции автозапуска интернета при старте системы возможен только при выборе опции разрешения пользователям управлять подключением.';
  message60='Автозапуск интернета при старте системы не настроен. Отсутствует ~/.config/autostart/ или используется нестандартный идентификатор пользователя.';
  message61='Автозапуск интернета при старте системы не настроен. Отсутствует файл /usr/share/applications/ponoff.desktop.';
  message62='Эта опция осуществляет автозапуск интернета при старте системы без использования ponoff.';
  message63='Автозапуск интернета при старте системы демоном pppd/xl2tpd/openl2tp/openl2tpd без графики был отменён для соединения';
  message64='Эта опция полезна если VPN PPTP/L2TP/OpenL2TP не должно быть главным.';
  message65='Пока нельзя одновременно выбрать автозапуск интернета демоном pppd/xl2tpd/openl2tp/openl2tpd и не изменять дефолтный шлюз, запустив VPN PPTP/L2TP/OpenL2TP в фоне.';
  message66='Не удалось автоматически определить ни DNS1 до поднятия VPN, ни DNS2 до поднятия VPN.';
  message67='Поле "DNS1 до поднятия VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message68='Поле "DNS2 до поднятия VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message69='Возникла ситуация когда не были заданы DNS1 при поднятом VPN, DNS2 при поднятом VPN, и при этом не была выбрана опция usepeerdns.';
  message70='При использовании опции refuse-eap демон pppd не согласится аутентифицировать себя по протоколу EAP.';
  message71='Эта опция часто позволяет достичь ускорения интернета, но не у всех провайдеров и невсегда.';
  message72='При использовании опции refuse-mschap демон pppd не согласится аутентифицировать себя по протоколу MS-CHAP.';
  message73='Пингуется DNS1-сервер до поднятия VPN. Ожидайте...';
  message74='DNS1-сервер до поднятия VPN не пингуется или теряются пакеты. Устраните проблему и заново запустите конфигуратор.';
  message75='Пингуется DNS2-сервер до поднятия VPN. Ожидайте...';
  message76='DNS2-сервер до поднятия VPN не пингуется или теряются пакеты. Устраните проблему и заново запустите конфигуратор.';
  message77='При использовании опции refuse-pap демон pppd не согласится аутентифицировать себя по протоколу PAP.';
  message78='При использовании опции refuse-mschap-v2 демон pppd не согласится аутентифицировать себя по протоколу MS-CHAPv2.';
  message79='Опция required делает шифрование mppe обязательным и требует его использовать - не соединяться если провайдер не поддерживает шифрование mppe.';
  message80='Выбрана опция usepeerdns: если VPN-сервер предоставит свои DNS, то будут использоваться они, невзирая на другие настройки DNS.';
  message81='Поле "DNS1 при поднятом VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message82='Поле "DNS2 при поднятом VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message83='Желательно ввести хотя бы одно DNS1 при поднятом VPN или DNS2 при поднятом VPN.';
  message84='DNS2-сервер до поднятия VPN не пингуется или теряются пакеты, но пингуется DNS1-сервер до поднятия VPN, поэтому это некритично.';
  message85='DNS1-сервер до поднятия VPN не пингуется или теряются пакеты, но пингуется DNS2-сервер до поднятия VPN, поэтому возможны тормоза.';
  message86='Показать пароль';
  message87='Скрыть пароль';
  message88='Часто используется шифрование трафика mppe с 128-битным шифрованием - это одновременный выбор required, no40, no56 (если опция no56 есть в pppd).';
  message89='Опция stateless пытается реализовать шифрование mppe в режиме без поддержки состояний.';
  message90='Опция no40 отключает 40-битное шифрование mppe.';
  message91='Опция no56 отключает 56-битное шифрование mppe.';
  message92='Опция no128 отключает 128-битное шифрование mppe.';
  message93='Принудительный рестарт сети';
  message94='Невозможно выбрать VPN L2TP, так как не установлен пакет xl2tpd.';
  message95='Для работы программы требуется хотя бы один из пакетов: pptp-linux(pptp), xl2tpd, openl2tp, но ни один из них не установлен.';
  message96='Использовать встроенный в демон xl2tpd механизм реконнекта (не рекомендуется если несколько сетевых карт)';
  message97='Дистрибутив определяется автоматически, но если этого не произошло, то выберите наиболее подходящий из списка.';
  message98='Автозапуск интернета при старте системы демоном xl2tpd без графики (не рекомендуется использовать)';
  message99='(например, vpn.internet.beeline.ru)';
  message100='(например, tp.internet.beeline.ru)';
  message101='Отсутствуют некритичные файлы: ';
  message102='Шифрование mppe может быть настроено неверно, так как отсутствуют: ';
  //message103='';
  message104='Поле "MRU" заполнено неверно. Разрешен лишь диапазон [576..1460..1492..1500].';
  message105='Обнаружено, что VPN PPTP/L2TP/OpenL2TP поднято. <ОК> - продолжить, убив VPN PPTP/L2TP/OpenL2TP и перезапустив сеть. <Отмена> - отмена запуска конфигуратора.';
  message106='Встроенный в демон xl2tpd механизм реконнекта будет работать корректно, только если Вы используете пропатченный xl2tpd.';
  message107='Запустить конфигуратор VPN PPTP/L2TP/OpenL2TP можно также из Центра Управления->Сеть и Интернет->Настройка VPN-соединений->VPN PPTP/L2TP/OpenL2TP.';
  message108='Установить тестовое соединение VPN PPTP/L2TP/OpenL2TP в графике/без графики сейчас?';
  message109='Тестовый запуск';
  message110='Лог ведётся неполный или не ведётся, так как Вы не выбрали опцию ведения лога pppd в /var/log/ppp/vpnlog.';
  message111='Команда запуска:';
  message112='Выбор этой опции позволяет установить соединение со случайным адресом VPN-сервера, заданного по имени, устанавливая соединение мгновенно.';
  message113='При отмене этой опции соединение не всегда сможет установиться мгновенно с еще неизвестным адресом VPN-сервера, особенно если их много.';
  message114='Адрес VPN-сервера задан по IP, поэтому опцию использования /etc/hosts выбрать нельзя.';
  message115='Его установка необязательна, но она ускорит механизм определения IP-адреса VPN-сервера, и быстрее соединится.';
  message116='Так как использование /etc/hosts является методом программной маршрутизации VPN-сервера, дополнительным к основному, то выбор будет исправлен.';
  message117='Значения MTU, MRU должны быть заданы вручную, так как выбрана опция default-mru.';
  message118='Рекомендуется значение MTU 1460 или 1472 байт.';
  message119='Так как значения MTU, MRU не заданы вручную, то рекомендуется отключить опцию default-mru.';
  message120='<ОК> - игнорировать это предупреждение и продолжить. <Отмена> - поправить.';
  message121='Не установлен пакет bind-utils.';
  message122='ОК';
  message123='Да';
  message124='Нет';
  message125='Отмена';
  message126='Тип VPN';
  message127='Внимательно читаем инструкцию и не забываем писать пожелания и замечания';
  message128='Здесь также можно указать команды, которые выполнятся сразу, как только соединение VPN PPTP/L2TP/OpenL2TP будет установлено.';
  message129='Значения MTU/MRU можно не вводить, тогда если не указана опция default-mru, то провайдер пришлет их сам (но не всегда).';
  message130='Шаблон: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message131='Шаблон: отсутствует.';
  message132='Эта кнопка вызывает справку, но при условиях, что она есть, и что установлено офисное приложение';
  message133='Перейти к следующей странице настройки';
  message134='Выйти из программы';
  message135='Эта кнопка настраивает (перенастраивает) соединение';
  message136='Эта кнопка позволяет изменить предложенные по умолчанию или дополнить опции демона pppd';
  message137='Эта кнопка позволяет проверить правильно ли было настроено соединение';
 //message138='';
  message139='Иногда может помочь принудительный рестарт сети.';
  message140='В Вашем дистрибутиве не используется shorewall, поэтому его настройка не требуется.';
  message141='В Вашем дистрибутиве получение маршрутов через DHCP настроено по-умолчанию, или оно настраивается средствами Вашего дистрибутива.';
  message142='Нельзя отключить всплывающие сообщения и одновременно выводить через отключенные всплывающие сообщения результаты проверок.';
  message143='При низких разрешениях экрана одновременное нажатие клавиши Alt и левой кнопки мыши поможет переместить окно.';
  message144='Отсутствует дефолтный шлюз, и это невозможно исправить автоматически.';
  message145='Укажите вручную сетевой интерфейс и шлюз локальной сети - программа сама сделает его дефолтным.';
  message146='Для настройки VPN L2TP требуется версия xl2tpd не ниже 1.3.6. Ваша версия xl2tpd:';
  message147='Настройте sudo средствами Вашего дистрибутива.';
  message148='Обнаружено активное соединение dsl. Отключите его командой ifdown dsl0. Нажмите <ОК> для отказа от запуска.';
  message149='Нажатие левой/правой кнопкой мыши на пустом месте окна изменяет шрифт.';
  message150='и аналоги';
  message151='Выберите дистрибутив...';
  message152='Выбор дистрибутива обязателен, но неправильный выбор опасен!';
  message153='Для того чтобы интернет был настроен для детей, опция usepeerdns была автоматически отключена.';
  message154='Если ввести 0, то реконнекта не будет.';
  message155='Если у Вас низкоскоростное соединение, то отключите эту опцию.';
  message156='Но её отключение при средне- или высокоскоростном соединении замедлит интернет.';
  message157='Эта опция используется только с VPN PPTP.';
  message158='Одновременное получение маршрутов через DHCP, автозапуск интернета при старте системы демоном pppd/xl2tpd/openl2tp/openl2tpd без графики';
  message159='- такое сочетание в Вашем дистрибутиве может работать некорректно.';
  message160='Не обнаружено ни одного сервиса, способного управлять сетью. Корректная работа программы невозможна!';
  message161='Будут проигнорированы недетские DNS при поднятом VPN. VPN будет поднято только на детских DNS.';
  message162='Запуск конфигуратора может занять некоторое время, так как требуется предварительная автоматическая подготовка сети.';
  message163='Рекомендуется вручную уменьшить MTU/MRU, так как используемое значение MTU =';
  message164='байт слишком большое.';
  message165='Если remote IP address не совпадает с IP-адресом VPN-сервера, то может потребоваться маршрутизировать его в шлюз локальной сети.';
  message166='Если remote IP address совпадает с IP-адресом VPN-сервера, то эта опция позволит наилучшим способом маршрутизировать VPN-сервер';
  message167='без необходимости иных методов маршрутизации VPN-сервера.';
  message168='Требуется выбрать тип VPN.';
  message169='Вы ввели имя соединения';
  message170='Имени соединения';
  message171='не найдено. Будет предложено создать новое соединение с именем';
  message172='Выберите соединение из выпадающего списка, которое Вы хотели бы отредактировать или удалить.';
  message173='<ОК> - выбрать из списка. <Новое> - создать новое соединение.';
  message174='По-умолчанию модулем ponoff используется имя соединения';
  message175='Установить соединение с именем';
  message176='соединением по-умолчанию? <ОК> - установить, <Отмена> - оставить соединение по-умолчанию без изменений.';
  message177='Определение соединения по-умолчанию...';
  message178='Соединение по-умолчанию используется модулем ponoff при его запуске без параметров.';
  message179='Вы уверены, что хотите удалить соединение с именем';
  message180='Соединение с именем';
  message181='было успешно удалено.';
  message182='Удалить соединение';
  message183='Эта кнопка удалит текущее соединение навсегда';
  message184='Будьте осторожны, так как Вы пытаетесь удалить соединение, используемое по-умолчанию!';
  message185='Необходимо будет потом самостоятельно выбрать имя соединения, которое использовать по-умолчанию.';
  message186='которое не может быть использовано, так как оно зарезервировано программой.';
  message187='Новое';
  message188='Опции в этой секции устанавливаются для текущего соединения, но отменяются у других соединений';
  message189='Опции в этой секции устанавливаются одновременно сразу для всех соединений';
  message190='Графический автозапуск интернета при старте системы был отменён для соединения';
  message191='и был установлен для соединения';
  message192='Взаимоисключение...';
  message193='Обнаружено, что использовался скрипт от mr. Peabody, который изменил оригинальный скрипт';
  message194='Восстановите этот скрипт вручную.';
  message195='<ОК> - выйти из конфигуратора vpnpptp.';
  message196='Для детей введите NetPolice DNS: 81.176.72.82 и 81.176.72.83, или Yandex Семейный DNS (рекомендуется): 77.88.8.3 и 77.88.8.7.';
  message197='Это некритично, так как адрес VPN-сервера задан по IP.';
  message198='Это критично, так как адрес VPN-сервера задан по имени.';
  message199='Задайте адрес VPN-сервера по IP или добейтесь автоматического определения DNS1 до поднятия VPN, DNS2 до поднятия VPN.';
  message200='Программа завершает свою работу.';
  message201='Также можно будет далее указать опцию usepeerdns и надеяться, что провайдер пришлёт DNS1 при поднятом VPN, DNS2 при поднятом VPN.';
  message202='Выбрана опция usepeerdns (она выбрана по-умолчанию), не введены DNS1 при поднятом VPN, DNS2 при поднятом VPN.';
  message203='<ОК> - продолжить и надеяться, что провайдер пришлёт DNS1 при поднятом VPN, DNS2 при поднятом VPN, <Отмена> - исправить вручную сейчас.';
  message204='<ОК> - продолжить, <Отмена> - исправить вручную сейчас.';
  message205='<ОК> - включить опцию usepeerdns автоматически и продолжить (рекомендуется), <Отмена> - оставить всё как есть и продолжить (не рекомендуется).';
  message206='Опция usepeerdns не выбрана.';
  //message207='';
  message208='<ОК> - оставить как есть и продолжить. <Отмена> - исправить.';
  //message209='';
  message210='Одновременная работа интернета и лок. сети не настроена или не требует настройки.';
  message211='Google Public DNS: 8.8.8.8 и 8.8.4.4. OpenDNS: 208.67.222.222 и 208.67.220.220.';
  message212='поэтому он не желателен к использованию.';
  message213='Невозможно выбрать VPN OpenL2TP, так как не установлен пакет openl2tp.';
  //message214='';
  message215='Отсутствует файл /etc/resolv.conf. Файл /etc/resolv.conf был создан автоматически. Правильность дальнейшей настройки VPN не гарантируется.';
  message216='Автозапуск интернета при старте системы демоном openl2tp/openl2tpd без графики (не рекомендуется использовать)';
  message217='Использовать встроенный в демон openl2tp/openl2tpd механизм реконнекта (не рекомендуется если несколько сетевых карт)';
  message218='Рекомендуется использовать с pppd/xl2tpd/openl2tp/openl2tpd-реконнектом.';
  message219='Невозможно выбрать VPN OpenL2TP.';
  message220='Не найден модуль ядра';
  message221='Не найден плагин';
  message222='Пакет ppp версии 2.4.5 и выше может содержать плагины pppol2tp.so, openl2tp.so; также они могут быть в пакете openl2tp.';
  //message223='';
  message224='<ОК> - игнорировать это предупреждение и продолжить (рекомендуется). <Отмена> - поправить.';
  message225='В Fedora если не работает, то может потребоваться настройка SELinux. SELinux можно также отключить.';
  message226='Введите пароль root:';
  message227='Эта опция позволяет модулю ponoff использовать виджет вместо трея в качестве альтернативы';
  message228='Для запуска с правами root требуется что-нибудь: xroot/kdesu/gksu/beesu. Рекомендуется установить пакет xroot.';
  message229='Чтобы использовать шифрование mppe, Вы должны быть аутентифицированы с помощью MS-CHAP или MS-CHAPv2.';
  message230='"Refuse" означает "запретить"! Нельзя запретить все виды аутентификации!';
  message231='Если выбрать опцию required для шифрования mppe, то нельзя выбрать опцию refuse-mschap одновременно с опцией refuse-mschap-v2, запретив MS-CHAP и MS-CHAPv2.';
  message232='Нельзя требовать шифрования mppe опцией required и при этом одновременно запретить все доступные типы шифрования.';
  message233='Иногда требуется добавить опцию stateless, но часто она уже используется по-умолчанию.';
  message234='Шифрование mppe может быть настроено неверно, так как не удалось свериться с man pppd и отсутствует';
  message235='Не найден модуль ppp_mppe, необходимый для работы mppe.';
  message236='Настраивается трей...';
  message237='Пожалуйста, перезагрузите самостоятельно компьютер, чтобы ponoff мог использовать трей.';

implementation

function ForkStartProgram (path:string;param1:string):longint;
var
  child_pid:longint;
begin
  child_pid:=FpFork;
  ForkStartProgram:=child_pid; // Возвращаем результат fork
  if child_pid<0 then exit; //error
  if child_pid=0 then
                  begin
                    fpsignal (SIGHUP,signalhandler(SIG_IGN)); // Отцепляем подчинённый процесс
                    fpexeclp (path,[param1]);
                  end;
end;

function MyStrToInt(Str:string):integer;
var
  x:integer;
  code:integer;
begin
  Val(str,x,code);
  if code<>0 then Result:=0 else Result:=StrToInt(str);
  x:=x+0;
end;

function MyStrToInt64(Str:string):int64;
var
  x:int64;
  code:integer;
begin
  Val(str,x,code);
  if code<>0 then Result:=0 else Result:=StrToInt64(str);
  x:=x+0;
end;

function ProgrammRoot(Name:string;DoHalt:boolean):boolean;
//возвращает истину если программа запущена под root
//прерывает выполнение если DoHalt истина и программа под root
var
  Apid:tpid;
begin
     If DoHalt then
                begin
                  popen (f,'ps -u root |'+'awk '+ chr(39)+'{print $4}'+chr(39)+'|'+'grep -x '+Name,'R');
                  If not eof(f) then halt;
                  PClose(f);
                end;
     Apid:=FpGetpid;
     popen (f,'ps -u root |'+'grep '+Name+'| '+'grep '+IntToStr(Apid),'R');
     If eof(f) then Result:=false else Result:=true;
     PClose(f);
end;

procedure CheckVPN;
//проверяет поднялось ли соединение и на каком точно интерфейсе поднялось
var
  str:string;
begin
  str:='';
  PppIface:='';
  Code_up_ppp:=false;
  If FileExists(VarRunDir+'ppp-'+Form1.Edit_peer.Text+'.pid') then
                                                                  begin
                                                                      popen (f,'cat '+VarRunDir+'ppp-'+Form1.Edit_peer.Text+'.pid|'+'grep ppp','R');
                                                                      While not eof(f) do
                                                                                     begin
                                                                                         Readln (f,str);
                                                                                         If str<>'' then PppIface:=str;
                                                                                     end;
                                                                      PClose(f);
                                                                      If PppIface<>'' then
                                                                             begin
                                                                                  popen (f,'ifconfig |'+'grep '+PppIface,'R');
                                                                                  If not eof(f) then If PppIface<>'' then Code_up_ppp:=true;
                                                                                  PClose(f);
                                                                             end;
                                                                  end;
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

Function DeleteSym(d, s: string): string;
//Удаление любого символа из строки s, где d - символ для удаления
Begin
While pos(d, s) <> 0 do
Delete(s, (pos(d, s)), 1); result := s;
End;

Function FileExistsBin (s:string):boolean;
//Существует ли исполняемый файл
var
  fbin:boolean;
begin
  fbin:=false;
  popen (f_bin,'which '+s,'R');
  if eof(f_bin) then fbin:=false else fbin:=true;
  PClose(f_bin);
  Result:=fbin;
end;

procedure DoCountInterface;
//считает максимальное кол-во default
var
   str:string;
   i:integer;
   FileInterface:textfile;
begin
   i:=0;
   if FileExists('/proc/net/dev') then
         begin
           FpSystem ('rm -f '+MyTmpDir+'CountInterface');
           FpSystem ('cat /proc/net/dev | awk -F : '+chr(39)+'{if (NR>2) print $1}'+chr(39)+' >>'+MyTmpDir+'CountInterface');
           if FileExists (MyTmpDir+'CountInterface') then
                           begin
                                AssignFile (FileInterface,MyTmpDir+'CountInterface');
                                reset (FileInterface);
                                While not eof (FileInterface) do
                                begin
                                     readln(FileInterface, str);
                                     i:=i+1;
                                end;
                                closefile(FileInterface);
                                FpSystem ('rm -f '+MyTmpDir+'CountInterface');
                           end;
         end;
   if i=0 then i:=1;
   CountInterface:=i;
end;

procedure Ifdown (Iface:string);
//опускает интерфейс
begin
          If FileExistsBin ('ifdown') then if not ubuntu then if not fedora then FpSystem ('ifdown '+Iface);
          If (not FileExistsBin ('ifdown')) or ubuntu or fedora then FpSystem ('ifconfig '+Iface+' down');
end;

procedure Ifup (Iface:string);
//поднимает интерфейс
begin
          If FileExistsBin ('ifup') then if not ubuntu then if not fedora then FpSystem ('ifup '+Iface);
          If (not FileExistsBin ('ifup')) or ubuntu or fedora then FpSystem ('ifconfig '+Iface+' up');
end;

{ TMyHintWindow }

constructor TMyHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with Canvas.Font do
  begin
    Size := AFont;
    Color:=clBlack;
    Alignment:=taLeftJustify;
  end;
end;

procedure TMyHintWindow.ActivateHint(Rect: TRect; const AHint: string);
begin
  Canvas.Font.Size:=AFont;
  Canvas.Font.Color := clBlack;
  inherited;
end;

{ TTranslator }

constructor TTranslator.Create(POFileName: string);
begin
  inherited Create;
  FPOFile := TPOFile.Create(POFileName);
end;

destructor TTranslator.Destroy;
begin
  FPOFile.Free;
  inherited Destroy;
end;

procedure TTranslator.TranslateStringProperty(Sender: TObject;
  const Instance: TPersistent; PropInfo: PPropInfo; var Content: string);
begin
  if Instance.InheritsFrom(TForm) then
    begin
      FFormClassName := Instance.ClassName;
      DebugLn(UTF8UpperCase(FFormClassName + '.'+PropInfo^.Name) + '=' + Content);
      Content := FPOFile.Translate(UTF8UpperCase(FFormClassName + '.' + PropInfo^.Name), Content);
    end
  else
    begin
      DebugLn(UTF8UpperCase(FFormClassName + '.'+Instance.GetNamePath + '.' + PropInfo^.Name) + '=' + Content);
      Content := FPOFile.Translate(UTF8UpperCase(FFormClassName + '.'+Instance.GetNamePath + '.'+ PropInfo^.Name), Content);
    end;
  Content := UTF8ToSystemCharSet(Content); // перевод UTF8 в текущую локаль
end;

{ TForm1 }

procedure TForm1.GetTestLog(str_log:string);
var
   str:string;
   i,k:integer;
begin
popen(f,'tail -'+IntToStr(StartKoli4estvo)+' '+str_log,'R');
str:='';
while not eof(f) do
                 begin
                      Readln(f,str);
                      MemoTest.Lines.Add(str);
                 end;
pclose(f);
k:=0;
For i:=0 to MemoTest.Lines.Count-1 do
        if Trim(MemoTest.Lines[i])=Trim(str_date) then k:=i;
for i:=k+z_num to MemoTest.Lines.Count-1 do
         begin
           Memo_create.Lines.Add(MemoTest.Lines[i]);
           z_num:=z_num+1;
           Application.ProcessMessages;
           Form1.Repaint;
         end;
end;

procedure TForm1.CheckFiles;
//проверяет наличие необходимых программе файлов
var
    str:string;
begin
    //некритичные файлы
    str:=message101;
    If not FileExists(MyPixmapsDir+'vpnpptp.png') then str:=str+MyPixmapsDir+'vpnpptp.png, ';
    If not FileExists(MyScriptsDir+'dhclient-exit-hooks') then str:=str+MyScriptsDir+'dhclient-exit-hooks, ';
    If not FileExists(MyScriptsDir+'dhclient.conf') then str:=str+MyScriptsDir+'dhclient.conf, ';
    If FallbackLang='ru' then
                     begin
                          If not FileExists(MyLangDir+'vpnpptp.ru.po') then str:=str+MyLangDir+'vpnpptp.ru.po, ';
                          If not FileExists(MyLangDir+'success.ru') then str:=str+MyLangDir+'success.ru, ';
                          If not FileExists(MyWikiDir+'Help_ru.doc') then str:=str+MyWikiDir+'Help_ru.doc, ';
                     end;
    If FallbackLang='en' then
                     begin
                          If not FileExists(MyLangDir+'vpnpptp.en.po') then str:=str+MyLangDir+'vpnpptp.en.po, ';
                          If not FileExists(MyLangDir+'success.en') then str:=str+MyLangDir+'success.en, ';
                          //If not FileExists(MyWikiDir+'Help_en.doc') then str:=str+MyWikiDir+'Help_en.doc, ';
                     end;
    If FallbackLang='uk' then
                     begin
                          If not FileExists(MyLangDir+'vpnpptp.uk.po') then str:=str+MyLangDir+'vpnpptp.uk.po, ';
                          If not FileExists(MyLangDir+'success.uk') then str:=str+MyLangDir+'success.uk, ';
                          If not FileExists(MyWikiDir+'Help_uk.doc') then str:=str+MyWikiDir+'Help_uk.doc, ';
                     end;
    If str<>message101 then
                       begin
                            str:=LeftStr(str,Length(str)-2);
                            Form3.MyMessageBox(message0,str,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                       end;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
    str_log:string;
begin
   str_log:=VarLogDir+'vpnlog';
   GetTestLog(str_log);
   StartKoli4estvo:=StartKoli4estvo+10;
end;

procedure TForm1.DoIconDesktop(uin,prilozh:string;dodelete:boolean;Profile:string);
var
   i:integer;
   NoLinkDesktop:boolean;
begin
NoLinkDesktop:=false;
If FileExists(MyLibDir+Profile+'/config') then
                      begin
                           Memo_config.Clear;
                           Memo_config.Lines.LoadFromFile(MyLibDir+Profile+'/config');
                           for i:=0 to Memo_config.Lines.Count-1 do
                                    If Memo_config.Lines[i]='link-desktop-no' then NoLinkDesktop:=true;
                           Memo_config.Clear;
                      end;
If NoLinkDesktop then
                   begin
                     link_on_desktop:=true;
                     exit;
                   end;
If prilozh='ponoff' then
begin
  Memo_create.Clear;
  Memo_create.Lines.Add('#!/usr/bin/env xdg-open');
  Memo_create.Lines.Add('');
  Memo_create.Lines.Add('[Desktop Entry]');
  Memo_create.Lines.Add('Encoding=UTF-8');
  Memo_create.Lines.Add('Comment[ru]=Управление соединением VPN PPTP/L2TP/OpenL2TP');
  Memo_create.Lines.Add('Comment[uk]=Управління з'' єднанням VPN PPTP/L2TP/OpenL2TP');
  Memo_create.Lines.Add('Comment=Control VPN via PPTP/L2TP/OpenL2TP');
  If not Sudo_ponoff.Checked then Memo_create.Lines.Add('Exec=ponoff '+Profile);
  If Sudo_ponoff.Checked then Memo_create.Lines.Add('Exec=xsudo '+'ponoff '+Profile);
  Memo_create.Lines.Add('GenericName[ru]=Управление соединением VPN PPTP/L2TP/OpenL2TP');
  Memo_create.Lines.Add('GenericName[uk]=Управління з'' єднанням VPN PPTP/L2TP/OpenL2TP');
  Memo_create.Lines.Add('GenericName=VPN PPTP/L2TP/OpenL2TP Control');
  Memo_create.Lines.Add('Icon='+MyPixmapsDir+'ponoff.png');
  Memo_create.Lines.Add('Name[ru]=Подключение '+Profile);
  Memo_create.Lines.Add('Name[uk]=Підключення '+Profile);
  Memo_create.Lines.Add('Name=Connect '+Profile);
  Memo_create.Lines.Add('StartupNotify=true');
  Memo_create.Lines.Add('Terminal=false');
  Memo_create.Lines.Add('Type=Application');
  Memo_create.Lines.Add('Categories=GTK;System;Monitor;X-MageiaLinux-CrossDesktop');
  Memo_create.Lines.Add('X-KDE-autostart-after=kdesktop');
  Memo_create.Lines.Add('StartupNotify=false');
end;
If prilozh='vpnpptp' then
   begin
     Memo_create.Clear;
     Memo_create.Lines.Add('#!/usr/bin/env xdg-open');
     Memo_create.Lines.Add('');
     Memo_create.Lines.Add('[Desktop Entry]');
     Memo_create.Lines.Add('Encoding=UTF-8');
     Memo_create.Lines.Add('Comment[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP');
     Memo_create.Lines.Add('Comment[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP');
     Memo_create.Lines.Add('Comment=Setup VPN via PPTP/L2TP/OpenL2TP');
     If not Sudo_configure.Checked then Memo_create.Lines.Add('Exec=vpnpptp '+Profile);
     If Sudo_configure.Checked then Memo_create.Lines.Add('Exec=xsudo '+'vpnpptp '+Profile);
     Memo_create.Lines.Add('GenericName[ru]=Настройка соединения VPN PPTP/L2TP/OpenL2TP');
     Memo_create.Lines.Add('GenericName[uk]=Налаштування з’єднання VPN PPTP/L2TP/OpenL2TP');
     Memo_create.Lines.Add('GenericName=VPN PPTP/L2TP/OpenL2TP Setup');
     Memo_create.Lines.Add('Icon='+MyPixmapsDir+'vpnpptp.png');
     Memo_create.Lines.Add('Name[ru]=Настройка '+Profile);
     Memo_create.Lines.Add('Name[uk]=Налаштування '+Profile);
     Memo_create.Lines.Add('Name=Setup '+Profile);
     Memo_create.Lines.Add('StartupNotify=true');
     Memo_create.Lines.Add('Terminal=false');
     Memo_create.Lines.Add('Type=Application');
     Memo_create.Lines.Add('Categories=GTK;System;Monitor;X-MageiaLinux-CrossDesktop');
     Memo_create.Lines.Add('X-KDE-autostart-after=kdesktop');
     Memo_create.Lines.Add('StartupNotify=false');
   end;
//Получаем список пользователей для создания иконки на рабочем столе
  FpSystem('cat '+EtcDir+'passwd | '+'grep '+uin+' | '+'cut -d: -f1 > '+MyTmpDir+'users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile(MyTmpDir+'users');
  FpSystem('rm -f '+MyTmpDir+'users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if (DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/')) or (DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/')) then
      begin
       if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then FpSystem('rm -f '+'"'+'/home/'+Memo_users.Lines[i]+'/'+message7+'/'+prilozh+'.desktop'+'"');
       if dodelete then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then FpSystem('rm -f '+'"'+'/home/'+Memo_users.Lines[i]+'/'+message7+'/'+Profile+'-'+prilozh+'.desktop'+'"');
       if not dodelete then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+message7+'/'+Profile+'-'+prilozh+'.desktop');
       if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then FpSystem ('chmod a+x '+'"'+'/home/'+Memo_users.Lines[i]+'/'+message7+'/'+Profile+'-'+prilozh+'.desktop'+'"');
       If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then FpSystem('rm -f /home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/'+prilozh+'.desktop');
       if dodelete then If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then FpSystem('rm -f '+'"'+'/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/'+Profile+'-'+prilozh+'.desktop'+'"');
       if not dodelete then If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/'+Profile+'-'+prilozh+'.desktop');
       If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then FpSystem ('chmod a+x '+'"'+'/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/'+Profile+'-'+prilozh+'.desktop'+'"');
       FpSystem ('chown '+Memo_users.Lines[i]+' /home/'+Memo_users.Lines[i]+'/Desktop/'+Profile+'-'+prilozh+'.desktop');
       FpSystem ('chown '+Memo_users.Lines[i]+' /home/'+Memo_users.Lines[i]+'/'+chr(39)+message7+chr(39)+'/'+Profile+'-'+prilozh+'.desktop');
       link_on_desktop:=true;
      end;
      i:=i+1;
    end;
end;

procedure TForm1.DoIconDesktopForAll(Prilozh:string);
var
   FileProfiles:textfile;
   str:string;
begin
If not FileExists(UsrShareApplicationsDir+Prilozh+'.desktop') then
                                                              begin
                                                                  //невозможно создать ярлык на рабочем столе
                                                                  Label14.Caption:=message23+' '+UsrShareApplicationsDir+Prilozh+'.desktop.';
                                                                  Application.ProcessMessages;
                                                                  Form1.Repaint;
                                                                  Form3.MyMessageBox(message0,message23+' '+UsrShareApplicationsDir+Prilozh+'.desktop.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                  StartMessage:=false;
                                                                  StartMessage:=true;
                                                                  Application.ProcessMessages;
                                                                  Form1.Repaint;
                                                              end;
//пересоздание всех иконок ponoff
link_on_desktop:=false;
If FileExists(MyLibDir+'profiles') then
                                        begin
                                           AssignFile(FileProfiles,MyLibDir+'profiles');
                                           reset (FileProfiles);
                                           str:='';
                                           While not eof (FileProfiles) do
                                                begin
                                                   readln(FileProfiles, str);
                                                   If str<>'' then
                                                            begin
                                                               DoIconDesktop('50',Prilozh,false,str);
                                                               DoIconDesktop('100',Prilozh,false,str);
                                                            end;
                                                end;
                                           closefile(FileProfiles);
                                        end;
If not link_on_desktop then If FileExists(UsrShareApplicationsDir+Prilozh+'.desktop') then
                           begin
                                Label14.Caption:=message22;
                                Application.ProcessMessages;
                                Form1.Repaint;
                                Form3.MyMessageBox(message0,message22,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                Application.ProcessMessages;
                                Form1.Repaint;
                           end;
end;

procedure TForm1.Button_createClick(Sender: TObject);
var mppe_string:string;
    i,j:integer;
    Str,str0:string;
    flag:boolean;
    FileSudoers,FileAutostartpppd,FileResolvConf,FileProfiles,FileLac:textfile;
    FlagAutostartPonoff:boolean;
    EditDNS1ping, EditDNS2ping:boolean;
    endprint:boolean;
    N:byte;
    exit0find,found,foundlac:boolean;
    Children,need_restart:boolean;
begin
FlagAutostartPonoff:=false;
StartMessage:=true;
Children:=false;
DhclientStartGood:=false;
If Unit2.Form2.CheckBoxusepeerdns.Checked then If ((EditDNS3.Text='81.176.72.82') or (EditDNS3.Text='81.176.72.83') or (EditDNS4.Text='81.176.72.82') or (EditDNS4.Text='81.176.72.83'))
                                         or ((EditDNS3.Text='77.88.8.3') or (EditDNS3.Text='77.88.8.7') or (EditDNS4.Text='77.88.8.3') or (EditDNS4.Text='77.88.8.7')) then
                                         begin //автоматическая поправка на детские DNS
                                            Form3.MyMessageBox(message0,message153,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                            Children:=true;
                                            Unit2.Form2.CheckBoxusepeerdns.Checked:=false;
                                            Application.ProcessMessages;
                                            Form1.Repaint;
                                         end;
If (((EditDNS3.Text='81.176.72.82') or (EditDNS3.Text='81.176.72.83')) and (EditDNS4.Text<>'81.176.72.82') and (EditDNS4.Text<>'81.176.72.83')) or
   (((EditDNS4.Text='81.176.72.82') or (EditDNS4.Text='81.176.72.83')) and (EditDNS3.Text<>'81.176.72.82') and (EditDNS3.Text<>'81.176.72.83')) or
   (((EditDNS3.Text='77.88.8.3') or (EditDNS3.Text='77.88.8.7')) and (EditDNS4.Text<>'77.88.8.3') and (EditDNS4.Text<>'77.88.8.7')) or
   (((EditDNS4.Text='77.88.8.3') or (EditDNS4.Text='77.88.8.7')) and (EditDNS3.Text<>'77.88.8.3') and (EditDNS3.Text<>'77.88.8.7'))then
                                         begin //игнорирование недетских DNS
                                            Form3.MyMessageBox(message0,message161,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                            Application.ProcessMessages;
                                            Form1.Repaint;
                                         end;
If (Mii_tool_no.Checked) and (Edit_MinTime.Text='0') then
                                         begin //нулевое время реконнекта невозможно
                                            Edit_MinTime.Text:='3';
                                            Form3.MyMessageBox(message0,message5+' '+Edit_MinTime.Text+'.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                            Application.ProcessMessages;
                                            Form1.Repaint;
                                         end;
//сообщения, которые могут привести к выходу из Создания подключения
If ((Edit_mtu.Text='') or (Edit_mru.Text='')) then If Unit2.Form2.CheckBoxdefaultmru.Checked then
                                      begin
                                        Form3.MyMessageBox(message0,message119+' '+message120,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                        if (Form3.Tag=3) or (Form3.Tag=0) then
                                                                                  begin
                                                                                      Label14.Caption:='';
                                                                                      Application.ProcessMessages;
                                                                                      Form1.Repaint;
                                                                                      exit;
                                                                                  end;
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                      end;
If Unit2.Form2.CheckBoxusepeerdns.Checked then
                                         begin
                                            Form3.MyMessageBox(message0,message80+' '+message224,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                            if (Form3.Tag=3) or (Form3.Tag=0) then
                                                                                 begin
                                                                                      Label14.Caption:='';
                                                                                      Application.ProcessMessages;
                                                                                      Form1.Repaint;
                                                                                      exit;
                                                                                 end;
                                            Application.ProcessMessages;
                                            Form1.Repaint;
                                         end;
If fedora then If dhcp_route.Checked then if Autostartpppd.Checked then
                                         begin
                                            Form3.MyMessageBox(message0,message158+' '+message159+' '+message120,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                            if (Form3.Tag=3) or (Form3.Tag=0) then
                                                                                 begin
                                                                                      Label14.Caption:='';
                                                                                      Application.ProcessMessages;
                                                                                      Form1.Repaint;
                                                                                      exit;
                                                                                 end;
                                            Application.ProcessMessages;
                                            Form1.Repaint;
                                         end;
Label42.Caption:=' ';
Label43.Caption:=' ';
Application.ProcessMessages;
Form1.Repaint;
DoCountInterface;
PressCreate:=true;
FpSystem('mkdir -p '+MyLibDir+'default');
FpSystem('chmod 777 '+MyLibDir+'default');
FpSystem('mkdir -p '+MyLibDir+Edit_peer.Text);
FpSystem('chmod 777 '+MyLibDir+Edit_peer.Text);
FpSystem ('rm -f '+MyLibDir+Edit_peer.Text+'/resolv.conf.before');
FpSystem ('rm -f '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
If not DirectoryExists(MyTmpDir) then begin FpSystem ('mkdir -p '+MyTmpDir); FpSystem ('chmod 777 '+MyTmpDir);end;
If not DirectoryExists(EtcPppPeersDir) then FpSystem ('mkdir -p '+EtcPppPeersDir);
If not DirectoryExists(MyLibDir) then begin FpSystem ('mkdir -p '+MyLibDir); FpSystem ('chmod 777 '+MyLibDir);end;
If fedora then If not DirectoryExists(EtcDhcpDir) then FpSystem ('mkdir -p '+EtcDhcpDir);
For i:=1 to CountInterface do
                           FpSystem('route del default');
FpSystem ('route add default gw '+Edit_gate.Text+' dev '+Edit_eth.Text);
//проверка текущего состояния дополнительных сторонних пакетов и других зависимостей
   If ((EditDNS3.Text='none') or (EditDNS3.Text='')) then if ((EditDNS4.Text='none') or (EditDNS4.Text='')) then If not Unit2.Form2.CheckBoxusepeerdns.Checked then
                                     begin
                                          Form3.MyMessageBox(message0,message69+' '+message205,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                          if (Form3.Tag=2) then Unit2.Form2.CheckBoxusepeerdns.Checked:=true;
                                          Application.ProcessMessages;
                                          Form1.Repaint;
                                     end;
   If FileExistsBin ('sudo') then Sudo:=true else Sudo:=false;
   If IPS then If etc_hosts.Checked then
                     begin
                          Label14.Caption:=message114;
                          Form3.MyMessageBox(message0,message114,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          etc_hosts.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                     end;
   If StartMessage then If Sudo_ponoff.Checked then If not Sudo then
                       begin
                          Label14.Caption:=message57;
                          Form3.MyMessageBox(message0,message57,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Sudo_ponoff.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
   If StartMessage then If Sudo_configure.Checked then If not Sudo then
                       begin
                          Label14.Caption:=message6;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Form3.MyMessageBox(message0,message6,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Sudo_configure.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo then
                       begin
                          Label14.Caption:=message24;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Form3.MyMessageBox(message0,message24,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Autostart_ponoff.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
  If StartMessage then If dhcp_route.Checked then if not dhclient then
                       begin
                          Label14.Caption:=message27;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Form3.MyMessageBox(message0,message27,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          dhcp_route.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
   If FileExistsBin ('host') then BindUtils:=true else BindUtils:=false;
   If (StartMessage) and (routevpnauto.Checked) and (etc_hosts.Checked) and (not BindUtils) then
                     begin
                          Label14.Caption:=message121+' '+message29+' '+message115;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Form3.MyMessageBox(message0,message121+' '+message29+' '+message115,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          Application.ProcessMessages;
                          Form1.Repaint;
                     end;
   If (StartMessage) and (routevpnauto.Checked) and (not BindUtils) and (not ((routevpnauto.Checked) and (etc_hosts.Checked))) then
                       begin
                          Label14.Caption:=message121+' '+message29;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Form3.MyMessageBox(message0,message121+' '+message29,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
   If StartMessage then If not IPS then If etc_hosts.Checked then If not routevpnauto.Checked then
                       begin
                          Label14.Caption:=message116;
                          Form3.MyMessageBox(message0,message116,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          routevpnauto.Checked:=true;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
Button_more.Visible:=false;
Button_create.Enabled:=false;
Button_exit.Enabled:=false;
TabSheet1.Hint:='';
TabSheet2.Hint:='';
TabSheet3.Hint:='';
Form1.Hint:='';
Label14.Hint:='';
Application.ProcessMessages;
Form1.Repaint;
Application.ShowHint:=false;
If EditDNSdop3.Text='' then EditDNSdop3.Text:='none';
If FileExists (EtcDir+'hosts.old') then FpSystem ('cp -f '+EtcDir+'hosts.old '+EtcDir+'hosts');
FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/hosts');
if FileExists(EtcPppDir+'options.pptp.old') then //для совместимости с пред.версиями
                                   begin
                                      FpSystem('cp -f '+EtcPppDir+'options.pptp.old '+EtcPppDir+'options.pptp');
                                      FpSystem('rm -f '+EtcPppDir+'options.pptp.old');
                                   end;
If Reconnect_pptp.Checked then If Edit_MinTime.Text='0' then
                        begin
                          Label14.Caption:=message3;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Form3.MyMessageBox(message0,message3,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Reconnect_pptp.Checked:=False;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                        end;
 If not FileExists(EtcDir+'dhclient-exit-hooks.old') then FpSystem('cp -f '+EtcDir+'dhclient.conf '+EtcDir+'dhclient.conf.old');
 if not FileExists(EtcDir+'dhclient-exit-hooks.old') then FpSystem('cp -f '+EtcDir+'dhclient-exit-hooks '+EtcDir+'dhclient-exit-hooks.old');
 If dhcp_route.Checked then
                       begin
                          if FileExists(MyScriptsDir+'dhclient.conf') then FpSystem('cp -f '+MyScriptsDir+'dhclient.conf '+EtcDir+'dhclient.conf');
                          if FileExists(MyScriptsDir+'dhclient-exit-hooks') then FpSystem('cp -f '+MyScriptsDir+'dhclient-exit-hooks '+EtcDir+'dhclient-exit-hooks');
                          if fedora then
                                        begin
                                           FpSystem('ln -s '+EtcDir+'dhclient-exit-hooks '+EtcDhcpDir+'dhclient-exit-hooks');
                                           FpSystem('ln -s '+EtcDir+'dhclient.conf '+EtcDhcpDir+'dhclient.conf');
                                           FpSystem('killall dhclient');
                                        end;
                          //проверка получаются ли маршруты по dhcp и настройка - если получаются или отмена - если не получаются
                          Label14.Caption:=message48;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Ifdown(Edit_eth.Text);
                          Application.ProcessMessages;
                          Form1.Repaint;
                          If (NetServiceStr='network-manager.service') or (NetServiceStr='NetworkManager.service') or (NetServiceStr='networkmanager.service') then sleep (10000);
                          Ifup(Edit_eth.Text);
                          Application.ProcessMessages;
                          Form1.Repaint;
                          FpSystem ('rm -f '+MyTmpDir+'dhclienttest1');
                          If (NetServiceStr='network-manager.service') or (NetServiceStr='NetworkManager.service') or (NetServiceStr='networkmanager.service') then sleep (10000);
                          FpSystem ('route -n|'+'grep '+Edit_eth.Text+ '|'+'grep '+Edit_gate.Text+' >'+MyTmpDir+'dhclienttest1');
                          FpSystem ('rm -f '+MyTmpDir+'dhclienttest2');
                          Label14.Caption:=message49;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          FpSystem ('dhclient '+Edit_eth.Text);
                          DhclientStartGood:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          Sleep(6000);
                          FpSystem ('route -n|'+'grep '+Edit_eth.Text+ '|'+'grep '+Edit_gate.Text+' >'+MyTmpDir+'dhclienttest2');
                          //проверка поднялся ли интерфейс после dhclient
                          FpSystem('ip r|'+'grep '+Edit_eth.Text+' > '+MyTmpDir+'gate');
                          FpSystem('printf "none" >> '+MyTmpDir+'gate');
                          Memo_gate.Clear;
                          If FileExists(MyTmpDir+'gate') then Memo_gate.Lines.LoadFromFile(MyTmpDir+'gate');
                          If Memo_gate.Lines[0]='none' then
                                                           begin
                                                                 Ifup(Edit_eth.Text);
                                                                 If (NetServiceStr='network-manager.service') or (NetServiceStr='NetworkManager.service') or (NetServiceStr='networkmanager.service') then sleep (10000);
                                                                 Sleep(6000);
                                                           end;
                          FpSystem ('rm -f '+MyTmpDir+'gate');
                          Memo_gate.Lines.Clear;
                          For i:=1 to CountInterface do
                                                     FpSystem('route del default');
                          FpSystem ('route add default gw '+Edit_gate.Text+' dev '+Edit_eth.Text);
                          If FileSize(MyTmpDir+'dhclienttest2')<=FileSize(MyTmpDir+'dhclienttest1') then
                                                                                               begin
                                                                                                 Label14.Caption:=message41+' '+message210+' '+message42;
                                                                                                 Application.ProcessMessages;
                                                                                                 Form1.Repaint;
                                                                                                 Form3.MyMessageBox(message0,message41+' '+message210+' '+message42,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                                 StartMessage:=false;
                                                                                                 dhcp_route.Checked:=false;
                                                                                                 DhclientStartGood:=false;
                                                                                                 StartMessage:=true;
                                                                                                 Application.ProcessMessages;
                                                                                                 Form1.Repaint;
                                                                                               end;
                         FpSystem('rm -f '+MyTmpDir+'dhclienttest1');
                         FpSystem('rm -f '+MyTmpDir+'dhclienttest2');
                       end;
 If CheckBox_shorewall.Checked then If not FileExists(EtcShorewallDir+'interfaces.old') then
                       begin
                          if FileExists(EtcShorewallDir+'interfaces') then
                                                                     begin
                                                                        FpSystem('cp -f '+EtcShorewallDir+'interfaces '+EtcShorewallDir+'interfaces.old');
                                                                        FpSystem('printf "# vpnpptp changed this config\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp0    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp1    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp2    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp3    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp4    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp5    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp6    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp7    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp8    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "net    ppp9    detect\n" >> '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('printf "# vpnpptp changed this config\n" >> '+EtcShorewallDir+'interfaces');
                                                                        If ServiceCommand='systemctl ' then FpSystem(ServiceCommand+'restart '+'shorewall.service') else FpSystem(ServiceCommand+'shorewall'+' restart');
                                                                        FpSystem ('chmod 600 '+EtcShorewallDir+'interfaces');
                                                                     end;
                       end;
 If not CheckBox_shorewall.Checked then If FileExists(EtcShorewallDir+'interfaces.old') then
                                                                  begin
                                                                        FpSystem('cp -f '+EtcShorewallDir+'interfaces.old '+EtcShorewallDir+'interfaces');
                                                                        FpSystem('rm -f '+EtcShorewallDir+'interfaces.old');
                                                                        If ServiceCommand='systemctl ' then FpSystem(ServiceCommand+'restart '+'shorewall.service') else FpSystem(ServiceCommand+'shorewall'+' restart');
                                                                  end;
 If FileExists(EtcPppPeersDir+Edit_peer.Text) then FpSystem('cp -f '+EtcPppPeersDir+Edit_peer.Text+' '+EtcPppPeersDir+Edit_peer.Text+chr(46)+'old');
 Unit2.Form2.Obrabotka(Edit_peer.Text, more, AFont, MyLibDir, EtcPppPeersDir);
 If Children then Unit2.Form2.CheckBoxusepeerdns.Checked:=false;
 FpSystem('rm -f '+EtcPppPeersDir+Edit_peer.Text);
 Memo_peer.Clear;
 If ComboBoxVPN.Text='VPN PPTP' then
                                begin
                                     if nobuffer.Checked then Memo_peer.Lines.Add('pty "'+'pptp ' +Edit_IPS.Text +' --nolaunchpppd --nobuffer"');
                                     if not nobuffer.Checked then Memo_peer.Lines.Add('pty "'+'pptp ' +Edit_IPS.Text +' --nolaunchpppd"');
                                end;
 If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then Memo_peer.Lines.Add('#pty "'+'pptp ' +Edit_IPS.Text +' --nolaunchpppd --nobuffer"');
 Memo_peer.Lines.Add('remotename '+Edit_peer.Text);
 Memo_peer.Lines.Add('user "'+Edit_user.Text+'"');
 Memo_peer.Lines.Add('password "'+Edit_passwd.Text+'"');
 Memo_peer.Lines.Add('linkname '+Edit_peer.Text);
 If Unit2.Form2.CheckBoxlock.Checked then Memo_peer.Lines.Add('lock');
 If Unit2.Form2.CheckBoxusepeerdns.Checked then Memo_peer.Lines.Add('usepeerdns');
 If Unit2.Form2.CheckBoxnodeflate.Checked then Memo_peer.Lines.Add('nodeflate');
 If Unit2.Form2.CheckBoxnobsdcomp.Checked then Memo_peer.Lines.Add('nobsdcomp');
 If Unit2.Form2.CheckBoxnoauth.Checked then Memo_peer.Lines.Add('noauth');
 If Unit2.Form2.CheckBoxpersist.Checked then Memo_peer.Lines.Add('persist');
 If Unit2.Form2.CheckBoxnoipdefault.Checked then Memo_peer.Lines.Add('noipdefault');
 If Unit2.Form2.CheckBoxnomppe.Checked then Memo_peer.Lines.Add('nomppe');
 If Unit2.Form2.CheckBoxnomppc.Checked then Memo_peer.Lines.Add('nomppc');
 If Unit2.Form2.CheckBoxdefaultroute.Checked then Memo_peer.Lines.Add('defaultroute');
 If Unit2.Form2.CheckBoxnopcomp.Checked then Memo_peer.Lines.Add('nopcomp');
 If Unit2.Form2.CheckBoxnoccp.Checked then Memo_peer.Lines.Add('noccp');
 If Unit2.Form2.CheckBoxnovj.Checked then Memo_peer.Lines.Add('novj');
 If Unit2.Form2.CheckBoxnovjccomp.Checked then Memo_peer.Lines.Add('novjccomp');
 If Unit2.Form2.CheckBoxnoaccomp.Checked then Memo_peer.Lines.Add('noaccomp');
 If Unit2.Form2.CheckBoxnoipv6.Checked then Memo_peer.Lines.Add('noipv6');
 If Unit2.Form2.CheckBoxreceiveall.Checked then Memo_peer.Lines.Add('receive-all');
 If Unit2.Form2.CheckBoxdump.Checked then Memo_peer.Lines.Add('dump');
 If Unit2.Form2.CheckBoxnodetach.Checked then Memo_peer.Lines.Add('nodetach');
 If Unit2.Form2.CheckBoxreplacedefaultroute.Checked then Memo_peer.Lines.Add('replacedefaultroute');
 If Unit2.Form2.CheckBoxauth.Checked then Memo_peer.Lines.Add('auth');
 If Unit2.Form2.CheckBoxpassive.Checked then Memo_peer.Lines.Add('passive');
 If Unit2.Form2.CheckBoxnodefaultroute.Checked then Memo_peer.Lines.Add('nodefaultroute');
 If Unit2.Form2.CheckBoxdefaultmru.Checked then Memo_peer.Lines.Add('default-mru');
 If not Reconnect_pptp.Checked then Memo_peer.Lines.Add('maxfail 10');
 If Reconnect_pptp.Checked then
                                    begin
                                      Memo_peer.Lines.Add('maxfail 0');
                                      Memo_peer.Lines.Add('holdoff '+Edit_MaxTime.Text);
                                      Memo_peer.Lines.Add('lcp-echo-interval '+Edit_MinTime.Text);
                                      Memo_peer.Lines.Add('lcp-echo-failure 4');
                                    end;
 If Pppd_log.Checked then Memo_peer.Lines.Add('debug');
 If Pppd_log.Checked then Memo_peer.Lines.Add('logfile '+VarLogDir+'vpnlog');
 If Edit_mtu.Text <> '' then Memo_peer.Lines.Add('mtu '+Edit_mtu.Text);
 If Edit_mru.Text <> '' then Memo_peer.Lines.Add('mru '+Edit_mru.Text);
//Разбираемся с аутентификацией
 If CheckBox_rmschap.Checked then Memo_peer.Lines.Add(CheckBox_rmschap.Caption);
 If CheckBox_reap.Checked then Memo_peer.Lines.Add(CheckBox_reap.Caption);
 If CheckBox_rchap.Checked then Memo_peer.Lines.Add(CheckBox_rchap.Caption);
 If CheckBox_rpap.Checked then Memo_peer.Lines.Add(CheckBox_rpap.Caption);
 If CheckBox_rmschapv2.Checked then Memo_peer.Lines.Add(CheckBox_rmschapv2.Caption);
//Разбираемся с шифрованием
 If CheckBox_required.Checked then
                    begin
                       If not FileExistsBin('strings') then If not FileExistsBin('man') then If (CheckBox_required.Checked) or (CheckBox_stateless.Checked) or (CheckBox_no40.Checked) or (CheckBox_no56.Checked) or (CheckBox_no128.Checked) then
                                                                                                      begin
                                                                                                           Label14.Caption:=message102+' '+'strings, '+'man.';
                                                                                                           Form3.MyMessageBox(message0,message102+' '+'strings, '+'man.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                                           Application.ProcessMessages;
                                                                                                           Form1.Repaint;
                                                                                                      end;
                       if error_man_pppd then
                                          begin
                                               Label14.Caption:=message234+' '+'strings.';
                                               Form3.MyMessageBox(message0,message234+' '+'strings.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                               Application.ProcessMessages;
                                               Form1.Repaint;
                                          end;
                       if default_mppe then
                               begin
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
                                   If mppe_string<>'mppe ' then Memo_peer.Lines.Add(mppe_string);
                               end
                                  else
                                     begin
                                        If not CheckBox_no40.Checked then Memo_peer.Lines.Add('require-mppe-40');
                                        //If not CheckBox_no56.Checked then Memo_peer.Lines.Add('require-mppe-56'); //для наглядности
                                        If not CheckBox_no128.Checked then Memo_peer.Lines.Add('require-mppe-128');
                                        If CheckBox_stateless.Checked then Memo_peer.Lines.Add('nomppe-stateful');
                                     end;
                    end;
 //разбираемся с whitelist в Unity
  Label14.Caption:=message236;
  Application.ProcessMessages;
  Form1.Repaint;
  need_restart:=false;
  FpSystem('cat '+EtcDir+'passwd | '+'grep '+'50'+' | '+'cut -d: -f1 > '+MyTmpDir+'users');
  FpSystem('cat '+EtcDir+'passwd | '+'grep '+'100'+' | '+'cut -d: -f1 >> '+MyTmpDir+'users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile(MyTmpDir+'users');
  FpSystem('rm -f '+MyTmpDir+'users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if DirectoryExists('/home/'+Memo_users.Lines[i]+'/') then
      begin
          popen(f,'su '+Memo_users.Lines[i]+' --login -p -c "'+MyScriptsDir+'whitelist.sh ponoff"','R');
              while not eof(f) do
                  begin
                    str:='';
                    Readln(f,str);
                    if pos('was added in whitelist',str) >0 then need_restart:=true;
                  end;
          pclose(f);
      end;
      i:=i+1;
    end;
  if need_restart then if not Widget.Checked then
                      begin
                           Form3.MyMessageBox(message0,message237,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                           Application.ProcessMessages;
                           Form1.Repaint;
                      end;
 Memo_peer.Lines.SaveToFile(EtcPppPeersDir+Edit_peer.Text); //записываем провайдерский профиль подключения
 FpSystem ('chmod 600 '+EtcPppPeersDir+Edit_peer.Text);
 If not DirectoryExists(VarLogDir) then FpSystem ('mkdir -p '+VarLogDir);
//удаляем временные, старые файлы и ссылки
 FpSystem('rm -f '+EtcDir+'resolv.conf.lock');
 FpSystem('rm -f '+MyLibDir+'ip-down');
 FpSystem('rm -f '+EtcPppIpUpDDir+'ip-up.old');
 FpSystem('rm -f '+EtcPppIpDownDDir+'ip-down.old');
 FpSystem('rm -f '+EtcPppDir+'ip-up.local');
 FpSystem('rm -f '+EtcPppDir+'ip-down.local');
 FpSystem('rm -f '+EtcDhcpDir+'dhclient-exit-hooks');
 FpSystem('rm -f '+EtcDhcpDir+'dhclient.conf');
 FpSystem('rm -f '+EtcPppIpUpDDir+'ip-up');
 FpSystem('rm -f '+EtcPppIpDownDDir+'ip-down');
 FpSystem('rm -f '+MyLibDir+'config');
 FpSystem('rm -f '+MyLibDir+'route');
 FpSystem('rm -f '+MyLibDir+'resolv.conf.before');
 FpSystem('rm -f '+MyLibDir+'resolv.conf.after');
 FpSystem('rm -f '+MyLibDir+'hosts');
 //переписываем скрипт ip-up.local
If fedora then
 begin
    If not FileExists(EtcPppDir+'ip-up.local.old') then FpSystem ('cp -f '+EtcPppDir+'ip-up.local '+EtcPppDir+'ip-up.local.old');
    FpSystem('rm -f '+EtcPppDir+'ip-up.local');
    FpSystem('echo "#!/bin/bash" > '+EtcPppDir+'ip-up.local');
    FpSystem('echo "if [ -d /etc/ppp/ip-up.d/ -a -x /usr/bin/run-parts ]; then" >> '+EtcPppDir+'ip-up.local');
    FpSystem('echo "    /usr/bin/run-parts /etc/ppp/ip-up.d/" >> '+EtcPppDir+'ip-up.local');
    FpSystem('echo "fi" >> '+EtcPppDir+'ip-up.local');
    FpSystem('chmod a+x '+EtcPppDir+'ip-up.local')
 end;
 //перезаписываем скрипт поднятия соединения имя_соединения-ip-up
 If not DirectoryExists(EtcPppIpUpDDir) then FpSystem ('mkdir -p '+EtcPppIpUpDDir);
 FpSystem('rm -f '+EtcPppIpUpDDir+Edit_peer.Text+'-ip-up');
 Memo_ip_up.Clear;
 Memo_ip_up.Lines.Add('#!/bin/bash');
 Memo_ip_up.Lines.Add('if [ ! -f '+UsrBinDir+'ponoff ]');
 Memo_ip_up.Lines.Add('then');
 Memo_ip_up.Lines.Add('     exit 0');
 Memo_ip_up.Lines.Add('fi');
 Memo_ip_up.Lines.Add('if [ ! $LINKNAME = "'+Edit_peer.Text+'" ]');
 Memo_ip_up.Lines.Add('then');
 Memo_ip_up.Lines.Add('     exit 0');
 Memo_ip_up.Lines.Add('fi');
 If routevpnauto.Checked then if IPS then Memo_ip_up.Lines.Add('route add -host ' + Edit_IPS.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 flag:=false;
 If routevpnauto.Checked then if not IPS then  //определение всех актуальных в данный момент ip-адресов vpn-сервера с занесением в Memo_bindutilshost.Lines и в файл hosts
                                              begin
                                                  if BindUtils then Str:='host '+Edit_IPS.Text+'|'+'grep address|'+'grep '+Edit_IPS.Text+'|'+'awk '+ chr(39)+'{print $4}'+chr(39);
                                                  if not BindUtils then Str:='ping -c1 '+Edit_IPS.Text+'|'+'grep '+Edit_IPS.Text+'|'+'awk '+chr(39)+'{print $3}'+chr(39)+'|'+'grep '+chr(39)+'('+chr(39);
                                                  If not BindUtils then Label14.Caption:=message46 else Label14.Caption:=message50;
                                                  Application.ProcessMessages;
                                                  Form1.Repaint;
                                                  FpSystem (Str+' > '+MyLibDir+Edit_peer.Text+'/hosts');
                                                  If not BindUtils then flag:=true;
                                                  Application.ProcessMessages;
                                                  Form1.Repaint;
                                                  Memo_bindutilshost.Lines.LoadFromFile(MyLibDir+Edit_peer.Text+'/hosts');
                                                  If FileSize(MyLibDir+Edit_peer.Text+'/hosts')<>0 then If Memo_bindutilshost.Lines[0]<>'none' then
                                                                                         begin
                                                                                            For i:=0 to Memo_bindutilshost.Lines.Count-1 do
                                                                                               begin
                                                                                                  Memo_bindutilshost.Lines[i]:=DeleteSym(')',Memo_bindutilshost.Lines[i]);
                                                                                                  Memo_bindutilshost.Lines[i]:=DeleteSym('(',Memo_bindutilshost.Lines[i]);
                                                                                                  If Memo_bindutilshost.Lines[i]<>'none' then If Memo_bindutilshost.Lines[i]<>'' then Memo_ip_up.Lines.Add('route add -host ' + Memo_bindutilshost.Lines[i] + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
                                                                                               end;
                                                                                         if not BindUtils then
                                                                                                              begin //просто перезаписать файл hosts
                                                                                                                FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/hosts');
                                                                                                                Str:=Memo_bindutilshost.Lines[0];
                                                                                                                If Str<>'' then If Str<>'none' then FpSystem('printf "'+Str+'\n" >> '+MyLibDir+Edit_peer.Text+'/hosts');
                                                                                                              end;
                                                                                         end;
                                                  If FileSize(MyLibDir+Edit_peer.Text+'/hosts')=0 then
                                                                                             begin
                                                                                                  If BindUtils then Label14.Caption:=message54 else Label14.Caption:=message43;
                                                                                                  Application.ProcessMessages;
                                                                                                  Form1.Repaint;
                                                                                                  If BindUtils then Form3.MyMessageBox(message0,message54,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                                  If not BindUtils then Form3.MyMessageBox(message0,message43,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                                  Application.ProcessMessages;
                                                                                                  Form1.Repaint;
                                                                                             end;
                                              end;
 If Memo_route.Lines.Text <>'' then
 If Memo_route.Lines[0]<>'' then
  begin
   i:=0;
   While Memo_route.Lines.Count > i do
    begin
     Memo_ip_up.Lines.Add(Memo_route.Lines[i]);
     i:=i+1;
    end;
  end;
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS1.Text<>'none' then Memo_ip_up.Lines.Add('route add -host ' + EditDNS1.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS2.Text<>'none' then Memo_ip_up.Lines.Add('route add -host ' + EditDNS2.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If pppnotdefault.Checked then
                                                       begin
                                                           Memo_ip_up.Lines.Add('route add -host ' + EditDNS3.Text + ' gw $IPREMOTE dev $IFNAME');
                                                           Memo_ip_up.Lines.Add('route add -host ' + EditDNS4.Text + ' gw $IPREMOTE dev $IFNAME');
                                                           Memo_ip_up.Lines.Add('route add -host $DNS1 gw $IPREMOTE dev $IFNAME');
                                                           Memo_ip_up.Lines.Add('route add -host $DNS2 gw $IPREMOTE dev $IFNAME');
                                                       end;
 For i:=1 to CountInterface do
          If not pppnotdefault.Checked then Memo_ip_up.Lines.Add('route del default');
 If not pppnotdefault.Checked then Memo_ip_up.Lines.Add('route del default');
 If not pppnotdefault.Checked then Memo_ip_up.Lines.Add('route add default dev $IFNAME');
 If Unit2.Form2.CheckBoxusepeerdns.Checked then
        begin
           Memo_ip_up.Lines.Add('if [ $USEPEERDNS = "1" ]');
           Memo_ip_up.Lines.Add('then');
             Memo_ip_up.Lines.Add('     [ -n "$DNS1" ] && '+'rm -f '+MyLibDir+'$LINKNAME/resolv.conf.after');
             Memo_ip_up.Lines.Add('     [ -n "$DNS2" ] && '+'rm -f '+MyLibDir+'$LINKNAME/resolv.conf.after');
             Memo_ip_up.Lines.Add('            if [ ! -f '+MyLibDir+'$LINKNAME/resolv.conf.after ]');
             Memo_ip_up.Lines.Add('            then');
             Memo_ip_up.Lines.Add('                  '+'cat /etc/resolvconf/resolv.conf.d/head|'+'grep nameserver >> '+MyLibDir+'$LINKNAME/resolv.conf.after');
             Memo_ip_up.Lines.Add('            fi');
             Memo_ip_up.Lines.Add('     [ -n "$DNS1" ] && '+'echo "nameserver $DNS1" >> '+MyLibDir+'$LINKNAME/resolv.conf.after');
             Memo_ip_up.Lines.Add('     [ -n "$DNS2" ] && '+'echo "nameserver $DNS2" >> '+MyLibDir+'$LINKNAME/resolv.conf.after');
             Memo_ip_up.Lines.Add('fi');
        end;
 Memo_ip_up.Lines.Add('cp -f '+MyLibDir+'$LINKNAME/resolv.conf.after '+EtcDir+'resolv.conf');
 If FileExistsBin ('vnstat') then
                                begin
                                   Memo_ip_up.Lines.Add('vnstat -u -i $IFNAME');
                                   If ServiceCommand='systemctl ' then Memo_ip_up.Lines.Add(ServiceCommand+' restart vnstat.service') else Memo_ip_up.Lines.Add(ServiceCommand+'vnstat restart');
                                end;
 If route_IP_remote.Checked then
                                Memo_ip_up.Lines.Add ('route add -host $IPREMOTE gw '+Edit_gate.Text+ ' dev '+Edit_eth.Text);
 Memo_ip_up.Lines.Add('echo "#!/bin/bash" > '+EtcPppIpDownDDir+'$LINKNAME-ip-down');
 Memo_ip_up.Lines.Add('export >> '+EtcPppIpDownDDir+'$LINKNAME-ip-down');
 Memo_ip_up.Lines.Add('echo "'+EtcPppIpDownLDir+'$LINKNAME-ip-down" >> '+EtcPppIpDownDDir+'$LINKNAME-ip-down');
 Memo_ip_up.Lines.Add('chmod +x '+EtcPppIpDownDDir+'$LINKNAME-ip-down');
 Memo_ip_up.Lines.SaveToFile(EtcPppIpUpDDir+Edit_peer.Text+'-ip-up');
 if Memo_route.Lines.Text <> '' then //сохранение введённых пользователем маршрутов в файл
                                       Memo_route.Lines.SaveToFile(MyLibDir+Edit_peer.Text+'/route');
 if Memo_route.Lines.Text = '' then
                                         FpSystem ('rm -f '+MyLibDir+Edit_peer.Text+'/route');
 FpSystem('chmod a+x '+EtcPppIpUpDDir+Edit_peer.Text+'-ip-up');
//поправка на debian
if FileExists(EtcPppIpUpDDir+'exim4') then
                                           begin
                                                FpSystem ('cp -f '+EtcPppIpUpDDir+'exim4 '+MyScriptsDir);
                                                FpSystem ('rm -f '+EtcPppIpUpDDir+'exim4');
                                                FpSystem ('printf "Program vpnpptp moved script exim4 in directory '+MyScriptsDir+'\n" > '+EtcPppIpUpDDir+'exim4.move');
                                           end;
//переписываем скрипт ip-down.local
If fedora then
begin
   If not FileExists(EtcPppDir+'ip-down.local.old') then FpSystem ('cp -f '+EtcPppDir+'ip-down.local '+EtcPppDir+'ip-down.local.old');
   FpSystem('rm -f '+EtcPppDir+'ip-down.local');
   FpSystem('echo "#!/bin/bash" > '+EtcPppDir+'ip-down.local');
   FpSystem('echo "if [ -d /etc/ppp/ip-down.d/ -a -x /usr/bin/run-parts ]; then" >> '+EtcPppDir+'ip-down.local');
   FpSystem('echo "    /usr/bin/run-parts /etc/ppp/ip-down.d/" >> '+EtcPppDir+'ip-down.local');
   FpSystem('echo "fi" >> '+EtcPppDir+'ip-down.local');
   FpSystem('chmod a+x '+EtcPppDir+'ip-down.local')
end;
//перезаписываем скрипт опускания соединения имя_соединения-ip-down
 If not DirectoryExists(EtcPppIpDownDDir) then FpSystem ('mkdir -p '+EtcPppIpDownDDir);
 If not DirectoryExists(EtcPppIpDownLDir) then FpSystem ('mkdir -p '+EtcPppIpDownLDir);
 FpSystem('rm -f '+EtcPppIpDownDDir+Edit_peer.Text+'-ip-down');
 FpSystem('rm -f '+EtcPppIpDownLDir+Edit_peer.Text+'-ip-down');
 Memo_ip_down.Clear;
 Memo_ip_down.Lines.Add('#!/bin/bash');
 Memo_ip_down.Lines.Add('if [ ! -f '+UsrBinDir+'ponoff ]');
 Memo_ip_down.Lines.Add('then');
 Memo_ip_down.Lines.Add('     exit 0');
 Memo_ip_down.Lines.Add('fi');
 Memo_ip_down.Lines.Add('if [ ! $LINKNAME = "'+Edit_peer.Text+'" ]');
 Memo_ip_down.Lines.Add('then');
 Memo_ip_down.Lines.Add('     exit 0');
 Memo_ip_down.Lines.Add('fi');
 If routevpnauto.Checked then if not IPS then //отмена маршрутов, полученных от команды host или ping
               If FileSize(MyLibDir+Edit_peer.Text+'/hosts')<>0 then
                                                        begin
                                                           For i:=0 to Memo_bindutilshost.Lines.Count-1 do
                                                             begin
                                                               If LeftStr(Memo_bindutilshost.Lines[i],4)<>'none' then If Memo_bindutilshost.Lines[i]<>'' then Memo_ip_down.Lines.Add('route del -host ' + Memo_bindutilshost.Lines[i] + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
                                                             end;
                                                        end;
 If not pppnotdefault.Checked then Memo_ip_down.Lines.Add('route del default');
 if Edit_gate.Text <> '' then
                           Memo_ip_down.Lines.Add('route add default gw '+Edit_gate.Text+' dev '+Edit_eth.Text);
 If routevpnauto.Checked then if IPS then Memo_ip_down.Lines.Add('route del -host ' + Edit_IPS.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS1.Text<>'none' then Memo_ip_down.Lines.Add('route del -host ' + EditDNS1.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS2.Text<>'none' then Memo_ip_down.Lines.Add('route del -host ' + EditDNS2.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If pppnotdefault.Checked then
                                                       begin
                                                           Memo_ip_up.Lines.Add('route del -host ' + EditDNS3.Text + ' gw $IPREMOTE dev $IFNAME');
                                                           Memo_ip_up.Lines.Add('route del -host ' + EditDNS4.Text + ' gw $IPREMOTE dev $IFNAME');
                                                           Memo_ip_up.Lines.Add('route del -host $DNS1 gw $IPREMOTE dev $IFNAME');
                                                           Memo_ip_up.Lines.Add('route del -host $DNS2 gw $IPREMOTE dev $IFNAME');
                                                       end;
 Memo_ip_down.Lines.Add('cp -f '+MyLibDir+'$LINKNAME/resolv.conf.before '+EtcDir+'resolv.conf');
 If suse then
         begin
                Memo_ip_down.Lines.Add('netconfig update -f');
                Memo_ip_down.Lines.Add('if [ -a '+EtcDir+'resolv.conf.netconfig ]');
                Memo_ip_down.Lines.Add('then');
                Memo_ip_down.Lines.Add('     '+'cp -f '+EtcDir+'resolv.conf.netconfig '+EtcDir+'resolv.conf');
                Memo_ip_down.Lines.Add('     '+'rm -f '+EtcDir+'resolv.conf.netconfig');
                Memo_ip_down.Lines.Add('fi');
         end;
 If route_IP_remote.Checked then
                                Memo_ip_down.Lines.Add ('route del -host $IPREMOTE gw '+Edit_gate.Text+ ' dev '+Edit_eth.Text);
 Memo_ip_down.Lines.SaveToFile(EtcPppIpDownLDir+Edit_peer.Text+'-ip-down');
 FpSystem('chmod a+x '+EtcPppIpDownLDir+Edit_peer.Text+'-ip-down');
 //Записываем готовый config, кроме логина и пароля
 If Edit_MinTime.Text<>'0' then Edit_MinTime.Text:=Edit_MinTime.Text+'000';
 Edit_MaxTime.Text:=Edit_MaxTime.Text+'000';
 If Edit_mtu.Text='' then Edit_mtu.Text:='mtu-none';
 If Edit_mru.Text='' then Edit_mru.Text:='mru-none';
 FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_peer.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_IPS.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_gate.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_eth.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_MinTime.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_MaxTime.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If Mii_tool_no.Checked then FpSystem('printf "mii-tool-no\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "mii-tool-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If Reconnect_pptp.Checked then FpSystem('printf "reconnect-pptp\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "noreconnect-pptp\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If Pppd_log.Checked then FpSystem('printf "pppd-log-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "pppd-log-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If dhcp_route.Checked then FpSystem('printf "dhcp-route-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "dhcp-route-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_mtu.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_required.Checked then FpSystem('printf "required-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "required-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_rchap.Checked then FpSystem('printf "rchap-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "rchap-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_reap.Checked then FpSystem('printf "reap-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "reap-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_rmschap.Checked then FpSystem('printf "rmschap-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "rmschap-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_stateless.Checked then FpSystem('printf "stateless-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "stateless-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_no40.Checked then FpSystem('printf "no40-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "no40-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If (CheckBox_no56.Checked) and (CheckBox_no56.Visible) then FpSystem('printf "no56-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "no56-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
  FpSystem('printf "none\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_desktop.Checked then FpSystem('printf "link-desktop-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "link-desktop-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_no128.Checked then FpSystem('printf "no128-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "no128-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If IPS then FpSystem('printf "IPS-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "IPS-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If routevpnauto.Checked then FpSystem('printf "routevpnauto-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "routevpnauto-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If networktest.Checked then FpSystem('printf "networktest-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "networktest-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If balloon.Checked then FpSystem('printf "balloon-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "balloon-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "none\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "none\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If Autostart_ponoff.Checked then FpSystem('printf "autostart-ponoff-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "autostart-ponoff-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If Autostartpppd.Checked then FpSystem('printf "autostart-pppd-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "autostart-pppd-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If pppnotdefault.Checked then FpSystem('printf "pppnotdefault-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "pppnotdefault-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+EditDNS1.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+EditDNS2.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+EditDNSdop3.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If routeDNSauto.Checked then FpSystem('printf "routednsauto-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "routednsauto-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If Unit2.Form2.CheckBoxusepeerdns.Checked then FpSystem ('printf "usepeerdns-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem ('printf "usepeerdns-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+EditDNS3.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+EditDNS4.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_rpap.Checked then FpSystem('printf "rpap-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "rpap-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If CheckBox_rmschapv2.Checked then FpSystem('printf "rmschapv2-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "rmschapv2-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If ComboBoxVPN.Text='VPN L2TP' then FpSystem('printf "l2tp\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If ComboBoxVPN.Text='VPN PPTP' then FpSystem('printf "pptp\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If ComboBoxVPN.Text='VPN OpenL2TP' then FpSystem('printf "openl2tp\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+Edit_mru.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If etc_hosts.Checked then FpSystem('printf "etc-hosts-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "etc-hosts-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "none\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "none\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem('printf "'+PingInternetStr+'\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If nobuffer.Checked then FpSystem('printf "nobuffer-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "nobuffer-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 If route_IP_remote.Checked then FpSystem('printf "route-IP-remote-yes\n" >> '+MyLibDir+Edit_peer.Text+'/config') else
                                              FpSystem('printf "route-IP-remote-no\n" >> '+MyLibDir+Edit_peer.Text+'/config');
 FpSystem ('chmod 600 '+MyLibDir+Edit_peer.Text+'/config');
 //Записываем готовый general.conf, кроме логина и пароля
 FpSystem('rm -f '+MyLibDir+'general.conf');
 If CheckBox_shorewall.Checked then FpSystem('printf "shorewall-yes\n" >> '+MyLibDir+'general.conf') else
                                               FpSystem('printf "shorewall-no\n" >> '+MyLibDir+'general.conf');
 If Sudo_ponoff.Checked then FpSystem('printf "sudo-yes\n" >> '+MyLibDir+'general.conf') else
                                              FpSystem('printf "sudo-no\n" >> '+MyLibDir+'general.conf');
 If Sudo_configure.Checked then FpSystem('printf "sudo-configure-yes\n" >> '+MyLibDir+'general.conf') else
                                              FpSystem('printf "sudo-configure-no\n" >> '+MyLibDir+'general.conf');
 FpSystem('printf "'+IntToStr(AFont)+'\n" >> '+MyLibDir+'general.conf');
 If ComboBoxDistr.Text='Ubuntu '+message150 then FpSystem('printf "ubuntu\n" >> '+MyLibDir+'general.conf');
 If ComboBoxDistr.Text='Debian '+message150 then FpSystem('printf "debian\n" >> '+MyLibDir+'general.conf');
 If ComboBoxDistr.Text='Fedora '+message150 then FpSystem('printf "fedora\n" >> '+MyLibDir+'general.conf');
 If ComboBoxDistr.Text='openSUSE '+message150 then FpSystem('printf "suse\n" >> '+MyLibDir+'general.conf');
 If ComboBoxDistr.Text='Mageia '+message150 then FpSystem('printf "mageia\n" >> '+MyLibDir+'general.conf');
 FpSystem ('chmod 600 '+MyLibDir+'general.conf');
//настройка sudoers
If FileExists(UsrShareApplicationsDir+'ponoff.desktop.old') then //восстанавливаем ярлык запуска ponoff
                                            begin
                                              FpSystem('cp -f '+UsrShareApplicationsDir+'ponoff.desktop.old '+UsrShareApplicationsDir+'ponoff.desktop');
                                              FpSystem('rm -f '+UsrShareApplicationsDir+'ponoff.desktop.old');
                                            end;
If FileExists(UsrShareApplicationsDir+'vpnpptp.desktop.old') then //восстанавливаем ярлык запуска vpnpptp
                                            begin
                                              FpSystem('cp -f '+UsrShareApplicationsDir+'vpnpptp.desktop.old '+UsrShareApplicationsDir+'vpnpptp.desktop');
                                              FpSystem('rm -f '+UsrShareApplicationsDir+'vpnpptp.desktop.old');
                                            end;
If FileExists (EtcDir+'sudoers') then If ((Sudo_ponoff.Checked) or (Sudo_configure.Checked)) then
                              begin
                                AssignFile (FileSudoers,EtcDir+'sudoers');
                                reset (FileSudoers);
                                Memo_sudo.Lines.Clear;
                                If not FileExists (EtcDir+'sudoers.old') then FpSystem('cp -f '+EtcDir+'sudoers '+EtcDir+'sudoers.old');
                                While not eof (FileSudoers) do
                                   begin
                                     readln(FileSudoers, str);
                                     If (Sudo_ponoff.Checked) or (Sudo_configure.Checked) then //очистка от старых записей
                                           begin
                                             If ((str<>'ALL ALL=NOPASSWD:'+UsrBinDir+'ponoff') and (str<>'ALL ALL=NOPASSWD:'+UsrBinDir+'vpnpptp')) then
                                             If (RightStr(str,10)<>'requiretty') then Memo_sudo.Lines.Add(str);
                                             If (RightStr(str,10)='requiretty') then Memo_sudo.Lines.Add('# Defaults requiretty');
                                           end;
                                   end;
                                 If not FileExistsBin('xsudo') then Memo_sudo.Lines.Add('Defaults env_keep += "DISPLAY XAUTHORITY XAUTHLOCALHOSTNAME"');
                                 If Sudo_ponoff.Checked then Memo_sudo.Lines.Add('ALL ALL=NOPASSWD:'+UsrBinDir+'ponoff');
                                 If Sudo_configure.Checked then Memo_sudo.Lines.Add('ALL ALL=NOPASSWD:'+UsrBinDir+'vpnpptp');
                                 closefile(FileSudoers);
                                 FpSystem('rm -f '+EtcDir+'sudoers');
                                 Memo_sudo.Lines.SaveToFile(EtcDir+'sudoers');
                                 FpSystem ('chmod 0440 '+EtcDir+'sudoers');
                              end;
If FileExists (EtcDir+'sudoers') then If (not(Sudo_ponoff.Checked) and (not Sudo_configure.Checked)) then  //очистка от старых записей
                              begin
                                AssignFile (FileSudoers,EtcDir+'sudoers');
                                reset (FileSudoers);
                                Memo_sudo.Lines.Clear;
                                While not eof (FileSudoers) do
                                   begin
                                     readln(FileSudoers, str);
                                     If ((str<>'ALL ALL=NOPASSWD:'+UsrBinDir+'ponoff') and (str<>'ALL ALL=NOPASSWD:'+UsrBinDir+'vpnpptp')) then
                                          Memo_sudo.Lines.Add(str);
                                   end;
                                 closefile(FileSudoers);
                                 FpSystem('rm -f '+EtcDir+'sudoers');
                                 Memo_sudo.Lines.SaveToFile(EtcDir+'sudoers');
                                 FpSystem ('chmod 0440 '+EtcDir+'sudoers');
                              end;
If Sudo_configure.Checked then If not FileExists(UsrShareApplicationsDir+'vpnpptp.desktop.old') then
                     If FileExists(UsrShareApplicationsDir+'vpnpptp.desktop') then //правим ярлык запуска vpnpptp
                        begin
                            FpSystem('cp -f '+UsrShareApplicationsDir+'vpnpptp.desktop '+UsrShareApplicationsDir+'vpnpptp.desktop.old');
                            Memo_vpnpptp_ponoff_desktop.Lines.LoadFromFile(UsrShareApplicationsDir+'vpnpptp.desktop');
                            Memonew1.Lines.Clear;
                            For i:=0 to Memo_vpnpptp_ponoff_desktop.Lines.Count-1 do
                              begin
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)='Exec=' then Memonew1.Lines.Add('Exec=xsudo vpnpptp');
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)<>'Exec=' then
                                    If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-SubstituteUID=true' then
                                       If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-Username=root' then
                                           Memonew1.Lines.Add(Memo_vpnpptp_ponoff_desktop.Lines[i]);
                              end;
                            Memonew1.Lines.SaveToFile(UsrShareApplicationsDir+'vpnpptp.desktop');
                        end;
If Sudo_ponoff.Checked then If not FileExists(UsrShareApplicationsDir+'ponoff.desktop.old') then
                     If FileExists(UsrShareApplicationsDir+'ponoff.desktop') then //правим ярлык запуска ponoff
                        begin
                            FpSystem('cp -f '+UsrShareApplicationsDir+'ponoff.desktop '+UsrShareApplicationsDir+'ponoff.desktop.old');
                            Memo_vpnpptp_ponoff_desktop.Lines.Clear;
                            Memo_vpnpptp_ponoff_desktop.Lines.LoadFromFile(UsrShareApplicationsDir+'ponoff.desktop');
                            Memonew2.Lines.Clear;
                            For i:=0 to Memo_vpnpptp_ponoff_desktop.Lines.Count-1 do
                              begin
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)='Exec=' then Memonew2.Lines.Add('Exec=xsudo ponoff');
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)<>'Exec=' then
                                    If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-SubstituteUID=true' then
                                       If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-Username=root' then
                                           Memonew2.Lines.Add(Memo_vpnpptp_ponoff_desktop.Lines[i]);
                              end;
                            Memonew2.Lines.SaveToFile(UsrShareApplicationsDir+'ponoff.desktop');
                        end;
If FileExists (EtcDir+'sudoers') then If ((Sudo_ponoff.Checked) or (Sudo_configure.Checked)) then If not FileExistsBin ('xsudo') then
                              begin // создание скрипта xsudo
                                 Memo_sudo.Lines.Clear;
                                 Memo_sudo.Lines.Add('#!/bin/bash');
                                 Memo_sudo.Lines.Add('[ -n "$XAUTHORITY" ] || XAUTHORITY="$HOME/.Xauthority"');
                                 Memo_sudo.Lines.Add('export XAUTHORITY');
                                 Memo_sudo.Lines.Add('exec sudo "$@"');
                                 Memo_sudo.Lines.SaveToFile(UsrBinDir+'xsudo');
                                 FpSystem ('chmod a+x '+UsrBinDir+'xsudo');
                              end;
//настройка /etc/rc.d/rc.local
If mageia then If (Autostartpppd.Checked) then If not suse then
            If (not FileExists (EtcRcDDir+'rc.local'))
               then
                  begin
                    FpSystem ('echo "#!/bin/bash" > '+EtcRcDDir+'rc.local');
                    FpSystem ('chmod +x '+EtcRcDDir+'rc.local');
                    if (not FileExists (EtcDir+'rc.local'))
                                    then FpSystem ('ln -s '+EtcRcDDir+'rc.local'+' '+EtcDir+'rc.local');
                    FpSystem ('systemctl enable rc-local.service');
                  end;
If FileExists (EtcRcDDir+'rc.local') then If (Autostartpppd.Checked) then If not suse then
                              begin
                                AssignFile (FileAutostartpppd,EtcRcDDir+'rc.local');
                                reset (FileAutostartpppd);
                                Memo_Autostartpppd.Lines.Clear;
                                If not FileExists (EtcRcDDir+'rc.local.old') then FpSystem('cp -f '+EtcRcDDir+'rc.local '+EtcRcDDir+'rc.local.old');
                                While not eof (FileAutostartpppd) do
                                   begin
                                     readln(FileAutostartpppd, str);
                                     If (leftstr(str,8)<>'dhclient') and (leftstr(str,9)<>'pppd call') and (leftstr(str,22)<>'service xl2tpd restart') and (RightStr(str,14)<>'openl2tp-start') then
                                                                     Memo_Autostartpppd.Lines.Add(str);
                                   end;
                                 If dhcp_route.Checked then Memo_Autostartpppd.Lines.Add('dhclient '+Edit_eth.Text);
                                 If ComboBoxVPN.Text='VPN PPTP' then Memo_Autostartpppd.Lines.Add('pppd call '+Edit_peer.Text);
                                 If ComboBoxVPN.Text='VPN L2TP' then If not ubuntu then If not debian then
                                               If ServiceCommand='systemctl ' then Memo_Autostartpppd.Lines.Add(ServiceCommand+'restart xl2tpd.service') else Memo_Autostartpppd.Lines.Add(ServiceCommand+'xl2tpd restart');
                                 If ComboBoxVPN.Text='VPN OpenL2TP' then Memo_Autostartpppd.Lines.Add(MyLibDir+Edit_peer.Text+'/openl2tp-start');
                                 closefile(FileAutostartpppd);
                                 FpSystem('rm -f '+EtcRcDDir+'rc.local');
                                 Memo_Autostartpppd.Lines.SaveToFile(EtcRcDDir+'rc.local');
                                 FpSystem ('chmod +x '+EtcRcDDir+'rc.local');
                              end;
If FileExists (EtcRcDDir+'rc.local') then If not Autostartpppd.Checked then If not suse then //очистка от старых записей
                              begin
                                AssignFile (FileAutostartpppd,EtcRcDDir+'rc.local');
                                reset (FileAutostartpppd);
                                Memo_Autostartpppd.Lines.Clear;
                                While not eof (FileAutostartpppd) do
                                   begin
                                     readln(FileAutostartpppd, str);
                                     If (leftstr(str,8)<>'dhclient') and (leftstr(str,9)<>'pppd call') and (leftstr(str,22)<>'service xl2tpd restart') and (RightStr(str,14)<>'openl2tp-start') then
                                                                     Memo_Autostartpppd.Lines.Add(str);
                                   end;
                                 closefile(FileAutostartpppd);
                                 FpSystem('rm -f '+EtcRcDDir+'rc.local');
                                 Memo_Autostartpppd.Lines.SaveToFile(EtcRcDDir+'rc.local');
                                 FpSystem ('chmod +x '+EtcRcDDir+'rc.local');
                              end;
//настройка /etc/rc.local
exit0find:=false;
If not FileExists (EtcRcDDir+'rc.local') then If FileExists (EtcDir+'rc.local') then If (Autostartpppd.Checked) then If not suse then
                              begin
                                AssignFile (FileAutostartpppd,EtcDir+'rc.local');
                                reset (FileAutostartpppd);
                                Memo_Autostartpppd.Lines.Clear;
                                If not FileExists (EtcDir+'rc.local.old') then FpSystem('cp -f '+EtcDir+'rc.local '+EtcDir+'rc.local.old');
                                While not eof (FileAutostartpppd) do
                                   begin
                                     readln(FileAutostartpppd, str);
                                     if str='exit 0' then exit0find:=true;
                                     If (str<>'exit 0') and (leftstr(str,8)<>'dhclient') and (leftstr(str,9)<>'pppd call') and (leftstr(str,5)<>'sleep') and (leftstr(str,22)<>'service xl2tpd restart') and (RightStr(str,14)<>'openl2tp-start') then
                                                                    Memo_Autostartpppd.Lines.Add(str);
                                   end;
                                 If dhcp_route.Checked then Memo_Autostartpppd.Lines.Add('dhclient '+Edit_eth.Text);
                                 If dhcp_route.Checked then if fedora then Memo_Autostartpppd.Lines.Add('sleep 10');
                                 If ComboBoxVPN.Text='VPN PPTP' then Memo_Autostartpppd.Lines.Add('pppd call '+Edit_peer.Text);
                                 If ComboBoxVPN.Text='VPN L2TP' then If not ubuntu then If not debian then
                                               If ServiceCommand='systemctl ' then Memo_Autostartpppd.Lines.Add(ServiceCommand+'restart xl2tpd.service') else Memo_Autostartpppd.Lines.Add(ServiceCommand+'xl2tpd restart');
                                 If ComboBoxVPN.Text='VPN OpenL2TP' then Memo_Autostartpppd.Lines.Add(MyLibDir+Edit_peer.Text+'/openl2tp-start');
                                 if exit0find then Memo_Autostartpppd.Lines.Add(str);
                                 closefile(FileAutostartpppd);
                                 FpSystem('rm -f '+EtcDir+'rc.local');
                                 Memo_Autostartpppd.Lines.SaveToFile(EtcDir+'rc.local');
                                 FpSystem ('chmod +x '+EtcDir+'rc.local');
                              end;
If not FileExists (EtcRcDDir+'rc.local') then If FileExists (EtcDir+'rc.local') then If not Autostartpppd.Checked then If not suse then //очистка от старых записей
                              begin
                                AssignFile (FileAutostartpppd,EtcDir+'rc.local');
                                reset (FileAutostartpppd);
                                Memo_Autostartpppd.Lines.Clear;
                                While not eof (FileAutostartpppd) do
                                   begin
                                     readln(FileAutostartpppd, str);
                                     If (leftstr(str,8)<>'dhclient') and (leftstr(str,9)<>'pppd call') and (leftstr(str,5)<>'sleep') and (leftstr(str,22)<>'service xl2tpd restart') and (RightStr(str,14)<>'openl2tp-start') then
                                                                     Memo_Autostartpppd.Lines.Add(str);
                                   end;
                                 closefile(FileAutostartpppd);
                                 FpSystem('rm -f '+EtcDir+'rc.local');
                                 Memo_Autostartpppd.Lines.SaveToFile(EtcDir+'rc.local');
                                 FpSystem ('chmod +x '+EtcDir+'rc.local');
                              end;
//настройка /etc/init.d/after.local
If suse then If Autostartpppd.Checked then If ComboBoxVPN.Text='VPN PPTP' then
                begin
                   If FileExists (EtcInitDDir+'after.local') then If not FileExists (EtcInitDDir+'after.local.old') then
                                                             begin
                                                                  FpSystem ('cp -f '+EtcInitDDir+'after.local '+EtcInitDDir+'after.local.old');
                                                                  FpSystem ('rm -f '+EtcInitDDir+'after.local');
                                                             end;
                   FpSystem ('touch '+EtcInitDDir+'after.local');
                   FpSystem ('printf "#!/bin/bash\n" >> '+EtcInitDDir+'after.local');
                   FpSystem ('printf "pppd call '+Edit_peer.Text+'\n" >> '+EtcInitDDir+'after.local');
                   FpSystem ('chmod +x '+EtcInitDDir+'after.local');
                end;
If suse then If Autostartpppd.Checked then If ComboBoxVPN.Text='VPN L2TP' then
                begin
                   If FileExists (EtcInitDDir+'after.local') then If not FileExists (EtcInitDDir+'after.local.old') then
                                                             begin
                                                                  FpSystem ('cp -f '+EtcInitDDir+'after.local '+EtcInitDDir+'after.local.old');
                                                                  FpSystem ('rm -f '+EtcInitDDir+'after.local');
                                                             end;
                   FpSystem ('touch '+EtcInitDDir+'after.local');
                   FpSystem ('printf "#!/bin/bash\n" >> '+EtcInitDDir+'after.local');
                   FpSystem ('printf "'+ServiceCommand+'xl2tpd restart\n" >> '+EtcInitDDir+'after.local');
                   If ServiceCommand='systemctl ' then FpSystem('printf "'+ServiceCommand+'restart xl2tpd.service\n" >> '+EtcInitDDir+'after.local')
                                                                                    else FpSystem('printf "'+ServiceCommand+'xl2tpd restart\n" >> '+EtcInitDDir+'after.local');
                   FpSystem ('chmod +x '+EtcInitDDir+'after.local');
                end;
If suse then If Autostartpppd.Checked then If ComboBoxVPN.Text='VPN OpenL2TP' then
                begin
                   If FileExists (EtcInitDDir+'after.local') then If not FileExists (EtcInitDDir+'after.local.old') then
                                                             begin
                                                                  FpSystem ('cp -f '+EtcInitDDir+'after.local '+EtcInitDDir+'after.local.old');
                                                                  FpSystem ('rm -f '+EtcInitDDir+'after.local');
                                                             end;
                   FpSystem ('touch '+EtcInitDDir+'after.local');
                   FpSystem ('printf "#!/bin/bash\n" >> '+EtcInitDDir+'after.local');
                   FpSystem ('printf "'+MyLibDir+Edit_peer.Text+'/openl2tp-start\n" >> '+EtcInitDDir+'after.local');
                   FpSystem ('chmod +x '+EtcInitDDir+'after.local');
                end;
If suse then if not Autostartpppd.Checked then
                begin
                   If FileExists (EtcInitDDir+'after.local') then If not FileExists (EtcInitDDir+'after.local.old') then
                                                                  FpSystem ('cp -f '+EtcInitDDir+'after.local '+EtcInitDDir+'after.local.old');
                   FpSystem ('rm -f '+EtcInitDDir+'after.local');
                end;
//настраиваем resolv.conf.after
 endprint:=false;
 i:=0;
 N:=0;
 if EditDNS3.Text='' then EditDNS3.Text:='none';
 if EditDNS4.Text='' then EditDNS4.Text:='none';
 if EditDNS3.Text<>'none' then if EditDNS4.Text<>'none' then N:=2;
 if (EditDNS3.Text='none') or (EditDNS4.Text='none') then N:=1;
 if EditDNS3.Text='none' then if EditDNS4.Text='none' then N:=0;
 If FileExists(EtcDir+'resolv.conf') then
    begin
       AssignFile (FileResolvConf,EtcDir+'resolv.conf');
       reset (FileResolvConf);
       If not (EditDNS3.Text='81.176.72.82') and not (EditDNS3.Text='81.176.72.83') and not (EditDNS4.Text='81.176.72.82') and not (EditDNS4.Text='81.176.72.83')
          and not (EditDNS3.Text='77.88.8.3') and not (EditDNS3.Text='77.88.8.7') and not (EditDNS4.Text='77.88.8.3') and not (EditDNS4.Text='77.88.8.7')
                                                then
       While not eof (FileResolvConf) do
           begin
              readln(FileResolvConf, str);
              if LeftStr(str,11)<>'nameserver ' then FpSystem('printf "'+str+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
              if LeftStr(str,11)='nameserver ' then i:=i+1;
              if LeftStr(str,11)='nameserver ' then if not endprint then
                                             begin
                                                  if EditDNS3.Text<>'' then if EditDNS3.Text<>'none' then FpSystem ('printf "nameserver '+EditDNS3.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
                                                  if EditDNS4.Text<>'' then if EditDNS4.Text<>'none' then FpSystem ('printf "nameserver '+EditDNS4.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
                                                  endprint:=true;
                                             end;
              if LeftStr(str,11)='nameserver ' then if i>N then FpSystem('printf "'+str+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
           end;
         closefile(FileResolvConf);
    end;
 If ((EditDNS3.Text='81.176.72.82') or (EditDNS3.Text='81.176.72.83') or (EditDNS4.Text='81.176.72.82') or (EditDNS4.Text='81.176.72.83')) then
   begin
      if EditDNS3.Text<>'' then if EditDNS3.Text<>'none' then if (EditDNS3.Text='81.176.72.82') or (EditDNS3.Text='81.176.72.83') then
                                FpSystem ('printf "nameserver '+EditDNS3.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
      if EditDNS4.Text<>'' then if EditDNS4.Text<>'none' then if (EditDNS4.Text='81.176.72.82') or (EditDNS4.Text='81.176.72.83') then
                                FpSystem ('printf "nameserver '+EditDNS4.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
   end;
 If ((EditDNS3.Text='77.88.8.3') or (EditDNS3.Text='77.88.8.7') or (EditDNS4.Text='77.88.8.3') or (EditDNS4.Text='77.88.8.7')) then
     begin
        if EditDNS3.Text<>'' then if EditDNS3.Text<>'none' then if (EditDNS3.Text='77.88.8.3') or (EditDNS3.Text='77.88.8.7') then
                                  FpSystem ('printf "nameserver '+EditDNS3.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
        if EditDNS4.Text<>'' then if EditDNS4.Text<>'none' then if (EditDNS4.Text='77.88.8.3') or (EditDNS4.Text='77.88.8.7') then
                                  FpSystem ('printf "nameserver '+EditDNS4.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/resolv.conf.after');
     end;
//настройка /etc/ppp/chap-secrets
If FileExists(EtcPppDir+'chap-secrets.old') then
                                            begin
                                               FpSystem('cp -f '+EtcPppDir+'chap-secrets.old '+EtcPppDir+'chap-secrets');
                                               FpSystem('rm -f '+EtcPppDir+'chap-secrets.old');
                                            end;
FpSystem ('rm -f '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
If not FileExists(EtcXl2tpdDir+'xl2tpd.conf.old') then FpSystem('cp -f '+EtcXl2tpdDir+'xl2tpd.conf '+EtcXl2tpdDir+'xl2tpd.conf.old');
FpSystem ('rm -f '+EtcXl2tpdDir+'xl2tpd.conf');
//настройка файла profiles
   found:=false;
   If FileExists(MyLibDir+'profiles') then
                                                begin
                                                   AssignFile(FileProfiles,MyLibDir+'profiles');
                                                   reset (FileProfiles);
                                                   str:='';
                                                   While not eof (FileProfiles) do
                                                        begin
                                                           readln(FileProfiles, str);
                                                           If str=Edit_peer.Text then found:=true;
                                                        end;
                                                   closefile(FileProfiles);
                                                end;
   if (not found) or (not FileExists(MyLibDir+'profiles')) then FpSystem('printf "'+Edit_peer.Text+'\n" >> '+MyLibDir+'profiles');
//убираем autodial везде
If FileExists(MyLibDir+'profiles') then
                                        begin
                                           AssignFile(FileProfiles,MyLibDir+'profiles');
                                           reset (FileProfiles);
                                           str:='';
                                           While not eof (FileProfiles) do
                                                begin
                                                   readln(FileProfiles, str);
                                                   If FileExists(MyLibDir+str+'/xl2tpd.conf.lac') then
                                                                                                  begin
                                                                                                       FpSystem('rm -f '+MyTmpDir+'xl2tpd.conf.lac');
                                                                                                       AssignFile(FileLac,MyLibDir+str+'/xl2tpd.conf.lac');
                                                                                                       reset (FileLac);
                                                                                                       While not eof (FileLac) do
                                                                                                                 begin
                                                                                                                    readln(FileLac,str0);
                                                                                                                    if LeftStr(str0,8)<>'autodial' then
                                                                                                                          FpSystem('printf "'+str0+'\n" >> '+MyTmpDir+'xl2tpd.conf.lac');
                                                                                                                 end;
                                                                                                       closefile(FileLac);
                                                                                                       FpSystem('cp -f '+MyTmpDir+'xl2tpd.conf.lac '+MyLibDir+str+'/xl2tpd.conf.lac');
                                                                                                       FpSystem('rm -f '+MyTmpDir+'xl2tpd.conf.lac');
                                                                                                   end;
                                                end;
                                           closefile(FileProfiles);
                                        end;
If ComboBoxVPN.Text='VPN L2TP' then
                                  begin
                                     FpSystem('printf "\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     FpSystem('printf "'+'[lac '+Edit_peer.Text+']'+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     FpSystem('printf "'+'name = '+Edit_user.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     FpSystem('printf "'+'lns = '+Edit_IPS.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     If Reconnect_pptp.Checked then If Edit_MinTime.Text<>'0' then FpSystem('printf "'+'redial = yes'+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     If Reconnect_pptp.Checked then If Edit_MinTime.Text='0' then FpSystem('printf "'+'redial = no'+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     If Reconnect_pptp.Checked then If Edit_MinTime.Text<>'0' then FpSystem('printf "'+'redial timeout = '+LeftStr(Edit_MinTime.Text,Length(Edit_MinTime.Text)-3)+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     FpSystem('printf "'+'pppoptfile = '+EtcPppPeersDir+Edit_peer.Text+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     If Autostartpppd.Checked then FpSystem('printf "'+'autodial = yes'+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     If Pppd_log.Checked then FpSystem('printf "'+'ppp debug = yes'+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     FpSystem('printf "'+'tunnel rws = 8'+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                     FpSystem('printf "'+'tx bps = 100000000'+'\n" >> '+MyLibDir+Edit_peer.Text+'/xl2tpd.conf.lac');
                                  end;
foundlac:=false;
If FileExists(MyLibDir+'profiles') then
                                        begin
                                           FpSystem ('rm -f '+EtcXl2tpdDir+'xl2tpd.conf');
                                           AssignFile(FileProfiles,MyLibDir+'profiles');
                                           reset (FileProfiles);
                                           str:='';
                                           FpSystem('printf "'+'[global]'+'\n" >> '+EtcXl2tpdDir+'xl2tpd.conf');
                                           FpSystem('printf "'+'access control = yes'+'\n" >> '+EtcXl2tpdDir+'xl2tpd.conf');
                                           While not eof (FileProfiles) do
                                                begin
                                                   readln(FileProfiles, str);
                                                   If FileExists(MyLibDir+str+'/xl2tpd.conf.lac') then
                                                                                                  begin
                                                                                                       FpSystem ('cat '+MyLibDir+str+'/xl2tpd.conf.lac >> '+EtcXl2tpdDir+'xl2tpd.conf');
                                                                                                       foundlac:=true;
                                                                                                  end;
                                                end;
                                           closefile(FileProfiles);
                                        end;
If not foundlac then FpSystem ('rm -f '+EtcXl2tpdDir+'xl2tpd.conf');
If not FileExists(EtcXl2tpdDir+'xl2tpd.conf') then FpSystem('cp -f '+EtcXl2tpdDir+'xl2tpd.conf.old '+EtcXl2tpdDir+'xl2tpd.conf');
 //настройка /etc/ppp/options
 if not FileExists(EtcPppDir+'options.old') then FpSystem('cp -f '+EtcPppDir+'options '+EtcPppDir+'options.old');
 FpSystem('echo "#Clear config file" > '+EtcPppDir+'options');
 //учитывание особенностей SELinux в Fedora
  If fedora then if (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then If Pppd_log.Checked then
                 begin
                      If not FileExists(VarLogDir+'vpnlog') then FpSystem ('touch '+VarLogDir+'vpnlog');
                      FpSystem('restorecon -R -v '+VarLogDir);
                 end;
  FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/openl2tp-start');
  FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/openl2tp-stop');
  FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/openl2tpd.conf');
  If ComboBoxVPN.Text='VPN OpenL2TP' then
                                     begin
                                          //создание скрипта включения для VPN OpenL2TP
                                          Memo2.Clear;
                                          Memo2.Lines.Add('#!/bin/bash');
                                          Memo2.Lines.Add('echo "call '+Edit_peer.Text+'" > '+EtcPppDir+'options');
                                          Memo2.Lines.Add('killall xl2tpd');
                                          Memo2.Lines.Add('cp -f '+MyLibDir+Edit_peer.Text+'/openl2tpd.conf '+EtcDir+'openl2tpd.conf');
                                          If FileExistsBin('portmap') then
                                                              If ServiceCommand='systemctl ' then Memo2.Lines.Add(ServiceCommand+'restart portmap.service') else Memo2.Lines.Add(ServiceCommand+'portmap restart');
                                          If FileExistsBin('rpcbind') then
                                                              If ServiceCommand='systemctl ' then Memo2.Lines.Add(ServiceCommand+'restart rpcbind.service') else Memo2.Lines.Add(ServiceCommand+'rpcbind restart');
                                          If ServiceCommand='systemctl ' then Memo2.Lines.Add(ServiceCommand+'stop openl2tp.service') else Memo2.Lines.Add(ServiceCommand+'openl2tp stop');
                                          Memo2.Lines.Add('killall openl2tp');
                                          Memo2.Lines.Add('killall openl2tpd');
                                          Memo2.Lines.Add('rm -f '+VarRunDir+'openl2tpd.pid');
                                          If ServiceCommand='systemctl ' then Memo2.Lines.Add(ServiceCommand+'start openl2tp.service') else Memo2.Lines.Add(ServiceCommand+'openl2tp start');
                                          Memo2.Lines.SaveToFile(MyLibDir+Edit_peer.Text+'/openl2tp-start');
                                          FpSystem('chmod a+x '+MyLibDir+Edit_peer.Text+'/openl2tp-start');
                                          //создание скрипта отключения для VPN OpenL2TP
                                          Memo2.Clear;
                                          Memo2.Lines.Add('#!/bin/bash');
                                          Memo2.Lines.Add('echo "#Clear config file" > '+EtcPppDir+'options');
                                          Memo2.Lines.Add('rm -f '+EtcDir+'openl2tpd.conf');
                                          If ServiceCommand='systemctl ' then Memo2.Lines.Add(ServiceCommand+'stop openl2tp.service') else Memo2.Lines.Add(ServiceCommand+'openl2tp stop');
                                          Memo2.Lines.Add('killall openl2tp');
                                          Memo2.Lines.Add('killall openl2tpd');
                                          Memo2.Lines.Add('rm -f '+VarRunDir+'openl2tpd.pid');
                                          Memo2.Lines.SaveToFile(MyLibDir+Edit_peer.Text+'/openl2tp-stop');
                                          Memo2.Lines.SaveToFile(MyLibDir+'default/openl2tp-stop');
                                          FpSystem('chmod a+x '+MyLibDir+Edit_peer.Text+'/openl2tp-stop');
                                          FpSystem('chmod a+x '+MyLibDir+'default/openl2tp-stop');
                                     end;
 //создаем конфиг openl2tpd.conf для VPN OpenL2TP
  If ComboBoxVPN.Text='VPN OpenL2TP' then
                                     begin
                                        If FileExists(EtcDir+'openl2tpd.conf') then if not FileExists(EtcDir+'openl2tpd.conf.old') then FpSystem ('cp -f '+EtcDir+'openl2tpd.conf '+EtcDir+'openl2tpd.conf.old');
                                        Memo2.Clear;
                                        Memo2.Lines.Add('system modify \');
                                        Memo2.Lines.Add('deny_remote_tunnel_creates=yes \');
                                        Memo2.Lines.Add('tunnel_establish_timeout='+LeftStr(Edit_MaxTime.Text,Length(Edit_MaxTime.Text)-3)+' \');
                                        Memo2.Lines.Add('session_establish_timeout='+LeftStr(Edit_MinTime.Text,Length(Edit_MinTime.Text)-3)+' \');
                                        Memo2.Lines.Add('tunnel_persist_pend_timeout='+LeftStr(Edit_MaxTime.Text,Length(Edit_MaxTime.Text)-3)+' \');
                                        Memo2.Lines.Add('session_persist_pend_timeout='+LeftStr(Edit_MinTime.Text,Length(Edit_MinTime.Text)-3)+' \');
                                        Memo2.Lines.Add('');
                                        Memo2.Lines.Add('peer profile modify \');
                                        Memo2.Lines.Add('profile_name=default \');
                                        Memo2.Lines.Add('lac_lns=lac \');
                                        Memo2.Lines.Add('');
                                        Memo2.Lines.Add('ppp profile modify \');
                                        Memo2.Lines.Add('profile_name=default \');
                                        If Edit_mru.Text<>'' then if Edit_mru.Text<>'mru-none' then Memo2.Lines.Add('mru='+Edit_mru.Text+' \');
                                        If Edit_mtu.Text<>'' then if Edit_mtu.Text<>'mtu-none' then Memo2.Lines.Add('mtu='+Edit_mtu.Text+' \');
                                        If CheckBox_rpap.Checked then Memo2.Lines.Add('auth_pap=no \') else Memo2.Lines.Add('auth_pap=yes \');
                                        If CheckBox_reap.Checked then Memo2.Lines.Add('auth_eap=no \') else Memo2.Lines.Add('auth_eap=yes \');
                                        If Form2.CheckBoxnoauth.Checked then Memo2.Lines.Add('auth_none=no \');
                                        If Form2.CheckBoxauth.Checked then Memo2.Lines.Add('auth_none=yes \');
                                        If Form2.CheckBoxnodefaultroute.Checked then Memo2.Lines.Add('default_route=no \');
                                        If Form2.CheckBoxdefaultroute.Checked then Memo2.Lines.Add('default_route=yes \');
                                        Memo2.Lines.Add('proxy_arp=no \');
                                        If CheckBox_rchap.Checked then Memo2.Lines.Add('auth_chap=no \') else Memo2.Lines.Add('auth_chap=yes \');
                                        If CheckBox_rmschap.Checked then Memo2.Lines.Add('auth_mschapv1=no \') else Memo2.Lines.Add('auth_mschapv1=yes \');
                                        If CheckBox_rmschapv2.Checked then Memo2.Lines.Add('auth_mschapv2=no \') else Memo2.Lines.Add('auth_mschapv2=yes \');
                                        Memo2.Lines.Add('');
                                        Memo2.Lines.Add('tunnel create \');
                                        Memo2.Lines.Add('tunnel_name=default \');
                                        Memo2.Lines.Add('dest_ipaddr='+Edit_IPS.Text+' \');
                                        If Form2.CheckBoxpersist.Checked then Memo2.Lines.Add('persist=yes \') else Memo2.Lines.Add('persist=no \');
                                        Memo2.Lines.Add('');
                                        Memo2.Lines.Add('session create \');
                                        Memo2.Lines.Add('tunnel_name=default \');
                                        Memo2.Lines.Add('session_name=default \');
                                        //Memo2.Lines.Add('user_name="'+Edit_user.Text+'" user_password="'+Edit_passwd.Text+'"');
                                        Memo2.Lines.Add('user_name="'+Edit_user.Text+'"');
                                        Memo2.Lines.SaveToFile(MyLibDir+Edit_peer.Text+'/openl2tpd.conf');
                                        FpSystem('chmod 600 '+MyLibDir+Edit_peer.Text+'/openl2tpd.conf');
                                     end;
 //настройка ponoff.conf.ini
 IniPropStorage1.IniFileName:=MyLibDir+'ponoff.conf.ini';
 IniPropStorage1.IniSection:='TApplication.Widget';
 If Widget.Checked then
       begin
           If not FileExists(MyLibDir+'ponoff.conf.ini') then
                 begin
                    IniPropStorage1.StoredValue['Widget']:='true';
                    IniPropStorage1.StoredValue['Widget_Height']:='40';
                    IniPropStorage1.StoredValue['Widget_Left']:='1';
                    IniPropStorage1.StoredValue['Widget_Top']:='1';
                    IniPropStorage1.StoredValue['Widget_Width']:='40';
                    IniPropStorage1.Save;
                 end;
           If FileExists(MyLibDir+'ponoff.conf.ini') then
                 begin
                    IniPropStorage1.StoredValue['Widget']:='true';
                    IniPropStorage1.Save;
                 end;
        end;
 If not Widget.Checked then
       begin
           If FileExists(MyLibDir+'ponoff.conf.ini') then
                 begin
                    IniPropStorage1.StoredValue['Widget']:='false';
                    IniPropStorage1.Save;
                 end;
        end;
 FpSystem('chmod 666 '+MyLibDir+'ponoff.conf.ini');
 //настройка /etc/sysconfig/network (нужно для xl2tpd)
 if DirectoryExists ('/etc/sysconfig') then
       begin
           if not FileExists('/etc/sysconfig/network') then FpSystem ('touch /etc/sysconfig/network');
           FpSystem('sed -i "/NETWORKING/d" /etc/sysconfig/network');
           FpSystem('echo "NETWORKING=yes" >> /etc/sysconfig/network');
       end;
 //убираем сервисы из автозагрузки
 FpSystem ('systemctl disable openl2tp.service');
 FpSystem ('systemctl disable openl2tpd.service');
 FpSystem ('systemctl disable xl2tpd.service');
 //проверка технической возможности поднятия соединения
 EditDNS1ping:=true;
 EditDNS2ping:=true;
   //тест EditDNS1-сервера
If EditDNS1.Text<>'' then if EditDNS1.Text<>'none' then
  begin
     If EditDNS1.Text='127.0.0.1' then Ifup('lo');
     FpSystem('rm -f '+MyTmpDir+'networktest');
     Str:='ping -c2 '+EditDNS1.Text+'|'+'grep '+chr(39)+'2 received'+chr(39)+' > '+MyTmpDir+'networktest';
     Label14.Caption:=message73;
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem(str);
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem('printf "none\n" >> '+MyTmpDir+'networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile(MyTmpDir+'networktest');
     If Memo_networktest.Lines[0]='none' then EditDNS1ping:=false;
     FpSystem('rm -f '+MyTmpDir+'networktest');
  end;
   //тест EditDNS2-сервера
If EditDNS2.Text<>'' then if EditDNS2.Text<>'none' then If not no_resolv_conf then
  begin
     If EditDNS2.Text='127.0.0.1' then Ifup('lo');
     FpSystem('rm -f '+MyTmpDir+'networktest');
     Str:='ping -c2 '+EditDNS2.Text+'|'+'grep '+chr(39)+'2 received'+chr(39)+' > '+MyTmpDir+'networktest';
     Label14.Caption:=message75;
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem(str);
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem('printf "none\n" >> '+MyTmpDir+'networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile(MyTmpDir+'networktest');
     If Memo_networktest.Lines[0]='none' then EditDNS2ping:=false;
     FpSystem('rm -f '+MyTmpDir+'networktest');
  end;
If (not EditDNS1ping) and (not EditDNS2ping) then
                                         begin
                                                Label14.Caption:=message74;
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                Form3.MyMessageBox(message0,message74,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                Label14.Caption:=message76;
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                Form3.MyMessageBox(message0,message76,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                         end;
If (EditDNS1ping) and (not EditDNS2ping) then
                                         begin
                                                Label14.Caption:=message84;
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                Form3.MyMessageBox(message0,message84,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                         end;
If (not EditDNS1ping) and (EditDNS2ping) then
                                         begin
                                                Label14.Caption:=message85;
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                Form3.MyMessageBox(message0,message85,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                         end;
   //тест vpn-сервера
If not flag then
   begin
     FpSystem('rm -f '+MyTmpDir+'networktest');
     Str:='ping -c1 '+Edit_IPS.Text+'|'+'grep '+Edit_IPS.Text+'|'+'awk '+chr(39)+'{print $3}'+chr(39)+'|'+'grep '+chr(39)+'('+chr(39)+' > '+MyTmpDir+'networktest';
     Label14.Caption:=message45;
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem(str);
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem('printf "none\n" >> '+MyTmpDir+'networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile(MyTmpDir+'networktest');
     If Memo_networktest.Lines[0]='none' then
                                         begin
                                                Label14.Caption:=message43;
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                Form3.MyMessageBox(message0,message43,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                         end;
     FpSystem('rm -f '+MyTmpDir+'networktest');
   end;
   //тест шлюза локальной сети
     FpSystem('rm -f '+MyTmpDir+'networktest');
     Str:='ping -c2 '+Edit_gate.Text+'|'+'grep '+chr(39)+'2 received'+chr(39)+' > '+MyTmpDir+'networktest';
     Label14.Caption:=message47;
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem(str);
     Application.ProcessMessages;
     Form1.Repaint;
     FpSystem('printf "none\n" >> '+MyTmpDir+'networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile(MyTmpDir+'networktest');
     If Memo_networktest.Lines[0]='none' then
                                         begin
                                                Label14.Caption:=message44;
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                Form3.MyMessageBox(message0,message44,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                         end;
     FpSystem('rm -f '+MyTmpDir+'networktest');
//запоминаем текущий /etc/resolv.conf
FpSystem ('cp -f '+EtcDir+'resolv.conf '+MyLibDir+Edit_peer.Text+'/resolv.conf.before');
//удаление вообще всех ярлыков на рабочем столе
If FileExists(MyLibDir+'profiles') then
                                                 begin
                                                    AssignFile(FileProfiles,MyLibDir+'profiles');
                                                    reset (FileProfiles);
                                                    str:='';
                                                    While not eof (FileProfiles) do
                                                         begin
                                                            readln(FileProfiles, str);
                                                            If str<>'' then
                                                                     begin
                                                                        DoIconDesktop('50','ponoff',true,str);
                                                                        DoIconDesktop('100','ponoff',true,str);
                                                                        DoIconDesktop('50','vpnpptp',true,str);
                                                                        DoIconDesktop('100','vpnpptp',true,str);
                                                                     end;
                                                         end;
                                                    closefile(FileProfiles);
                                                 end;
//Создаем ярлык для подключения ponoff и vpnpptp для каждого соединения, для которого конфигом предусмотрен ярлык
DoIconDesktopForAll('ponoff');
DoIconDesktopForAll('vpnpptp');
//Получаем список пользователей для автозапуска ponoff при старте системы и организация автозапуска
  FpSystem('cat '+EtcDir+'passwd | '+'grep 100 | '+'cut -d: -f1 > '+MyTmpDir+'users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile(MyTmpDir+'users');
  FpSystem('rm -f '+MyTmpDir+'users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if not DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then begin FpSystem ('mkdir -p /home/'+Memo_users.Lines[i]+'/.config/autostart/'); FpSystem ('chmod -R 777 /home/'+Memo_users.Lines[i]+'/.config/autostart/');end;
      if DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then
      begin
       FlagAutostartPonoff:=true;
       If Autostart_ponoff.Checked then FpSystem ('cp -f '+UsrShareApplicationsDir+'ponoff.desktop /home/'+Memo_users.Lines[i]+'/.config/autostart/');
       if FileExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop') then
                                                                     begin
                                                                          Memo_create.Clear;
                                                                          Memo_create.Lines.LoadFromFile('/home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
                                                                          for j:=0 to Memo_create.Lines.Count-1 do
                                                                                      if Length(Memo_create.Lines[j])>=4 then if LeftStr(Memo_create.Lines[j],4)='Exec' then Memo_create.Lines[j]:=Memo_create.Lines[j]+' '+Edit_peer.Text;
                                                                          Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
                                                                          Memo_create.Clear;
                                                                     end;
       If not Autostart_ponoff.Checked then FpSystem ('rm -f /home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
      end;
      i:=i+1;
    end;
  FpSystem('cat '+EtcDir+'passwd | '+'grep 50 | '+'cut -d: -f1 > '+MyTmpDir+'users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile(MyTmpDir+'users');
  FpSystem('rm -f '+MyTmpDir+'users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if not DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then begin FpSystem ('mkdir /home/'+Memo_users.Lines[i]+'/.config/autostart/'); FpSystem ('chmod -R 777 /home/'+Memo_users.Lines[i]+'/.config/autostart/');end;
      if DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then
      begin
       FlagAutostartPonoff:=true;
       If Autostart_ponoff.Checked then FpSystem ('cp -f '+UsrShareApplicationsDir+'ponoff.desktop /home/'+Memo_users.Lines[i]+'/.config/autostart/');
       if FileExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop') then
                                                                     begin
                                                                          Memo_create.Clear;
                                                                          Memo_create.Lines.LoadFromFile('/home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
                                                                          for j:=0 to Memo_create.Lines.Count-1 do
                                                                                      if Length(Memo_create.Lines[j])>=4 then if LeftStr(Memo_create.Lines[j],4)='Exec' then Memo_create.Lines[j]:=Memo_create.Lines[j]+' '+Edit_peer.Text;
                                                                          Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
                                                                          Memo_create.Clear;
                                                                     end;
       If not Autostart_ponoff.Checked then FpSystem ('rm -f /home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
      end;
      i:=i+1;
    end;
 //обработка ошибок организации автозапуска ponoff
  If Autostart_ponoff.Checked then If not FlagAutostartPonoff then
                               begin
                                    Label14.Caption:=message60;
                                    Application.ProcessMessages;
                                    Form1.Repaint;
                                    Form3.MyMessageBox(message0,message60,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                    Application.ProcessMessages;
                                    Form1.Repaint;
                               end;
 If Autostart_ponoff.Checked then If not FileExists (UsrShareApplicationsDir+'ponoff.desktop') then
                               begin
                                    Label14.Caption:=message61;
                                    Application.ProcessMessages;
                                    Form1.Repaint;
                                    Form3.MyMessageBox(message0,message61,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                    Application.ProcessMessages;
                                    Form1.Repaint;
                               end;
 //корректирование конфигов для каждого соединения (взаимоисключающие для всех соединений настройки)
 If FileExists(MyLibDir+'profiles') then if (Autostart_ponoff.Checked) or (Autostartpppd.Checked) then
                                    begin
                                       AssignFile(FileProfiles,MyLibDir+'profiles');
                                       reset(FileProfiles);
                                              while not eof(FileProfiles) do
                                                        begin
                                                          readln(FileProfiles,str);
                                                          if str<>'' then If str<>Edit_peer.Text then If FileExists(MyLibDir+str+'/config') then
                                                                       begin
                                                                          Memo_config.Clear;
                                                                          Memo_config.Lines.LoadFromFile(MyLibDir+str+'/config');
                                                                          for i:=0 to Memo_config.Lines.Count-1 do
                                                                             begin
                                                                               If Autostart_ponoff.Checked then if Memo_config.Lines[i]='autostart-ponoff-yes' then
                                                                                                                                                        begin
                                                                                                                                                               Memo_config.Lines[i]:='autostart-ponoff-no';
                                                                                                                                                               Label14.Caption:=message192;
                                                                                                                                                               Application.ProcessMessages;
                                                                                                                                                               Form1.Repaint;
                                                                                                                                                               Form3.MyMessageBox(message0,message190+' '+str+' '+message191+' '+Edit_peer.Text+'.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                                                                                        end;
                                                                               If Autostartpppd.Checked then if Memo_config.Lines[i]='autostart-pppd-yes' then
                                                                                                                                                        begin
                                                                                                                                                               Memo_config.Lines[i]:='autostart-pppd-no';
                                                                                                                                                               Label14.Caption:=message192;
                                                                                                                                                               Application.ProcessMessages;
                                                                                                                                                               Form1.Repaint;
                                                                                                                                                               Form3.MyMessageBox(message0,message63+' '+str+' '+message191+' '+Edit_peer.Text+'.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                                                                                        end;
                                                                             end;
                                                                          Memo_config.Lines.SaveToFile(MyLibDir+str+'/config');
                                                                          Memo_config.Clear;
                                                                       end;
                                                        end;
                                       CloseFile(FileProfiles);
                                    end;
 //сброс конфига для ponoff (для совместимости с предыдущими версиями)
  FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/ponoff.conf');
  FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'/nocolor');
 //обработка соединения по-умолчанию
  If not FileExists(MyLibDir+'default/default') then FpSystem ('echo "'+Edit_peer.Text+'" > '+MyLibDir+'default/default');
  found:=false;
  If FileExists(MyLibDir+'default/default') then
          begin
               ProfileStrDefault:='';
               popen(f,'cat '+MyLibDir+'default/default','R');
               while not eof(f) do
                     begin
                        readln(f,ProfileStrDefault);
                        if ProfileStrDefault=Edit_peer.Text then found:=true;
                     end;
               PClose(f);
         end;
  FpSystem ('rm -f '+MyTmpDir+'test_vpn');
  If not found then If ProfileStrDefault<>'' then
          begin
            Label14.Caption:=message177;
            Application.ProcessMessages;
            Form1.Repaint;
            Form3.MyMessageBox(message0,message174+' '+ProfileStrDefault+'. '+message178+' '+message175+' '+Edit_peer.Text+' '+message176,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
            if Form3.Tag=2 then FpSystem ('echo "'+Edit_peer.Text+'" > '+MyLibDir+'default/default');
            Application.ProcessMessages;
            Form1.Repaint;
          end;
 If fedora then //предупреждение о SELinux в Fedora
                                  begin
                                       Label14.Caption:=message225;
                                       Application.ProcessMessages;
                                       Form1.Repaint;
                                       Form3.MyMessageBox(message0,message225,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                       Application.ProcessMessages;
                                       Form1.Repaint;
                                  end;
 Button_create.Visible:=True;
 TabSheet2.TabVisible:= False;
 TabSheet1.TabVisible:= False;
 TabSheet3.TabVisible:= False;
 TabSheet4.TabVisible:= True;
 PageControl1.ActivePageIndex:=3;
 Button_next2.Visible:=False;
 Memo_create.Clear;
 If FallbackLang='ru' then If FileExists (MyLangDir+'success.ru') then begin Memo_create.Lines.LoadFromFile(MyLangDir+'success.ru'); Translate:=true; end;
 If FallbackLang='uk' then If FileExists (MyLangDir+'success.uk') then begin Memo_create.Lines.LoadFromFile(MyLangDir+'success.uk'); Translate:=true; end;
 If not Translate then If FileExists (MyLangDir+'success.en') then Memo_create.Lines.LoadFromFile(MyLangDir+'success.en');
 Button_create.Visible:=False;
 Button_exit.Enabled:=true;
 ButtonTest.Caption:=message109;
 ButtonTest.Visible:=true;
 Application.ShowHint:=true;
 Application.ProcessMessages;
 Form1.Repaint;
 FpSystem('rm -f '+EtcDir+'resolv.conf.old');
end;

procedure TForm1.ButtonVPNClick(Sender: TObject);
//определение ip vpn-сервера по кнопке
var
   str0,str:string;
begin
  str0:=ButtonVPN.Caption;
  ButtonVPN.Caption:=message53;
  Application.ProcessMessages;
  Form1.Repaint;
  FpSystem('rm -f '+MyTmpDir+'ip_IPS');
  If StartMessage then If Edit_IPS.Text='' then
                                             begin
                                                ButtonVPN.Caption:=str0;
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                Form3.MyMessageBox(message0,message28,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                Application.ProcessMessages;
                                                Form1.Repaint;
                                                exit;
                                             end;
  FpSystem('ping -c1 '+Edit_IPS.Text+'|'+'grep '+Edit_IPS.Text+'|'+'awk '+chr(39)+'{print $3}'+chr(39)+'|'+'grep '+chr(39)+'('+chr(39)+' > '+MyTmpDir+'ip_IPS');
  FpSystem('printf "none" >> '+MyTmpDir+'ip_IPS');
  Memo_ip_IPS.Clear;
  If FileExists(MyTmpDir+'ip_IPS') then Memo_ip_IPS.Lines.LoadFromFile(MyTmpDir+'ip_IPS');
  Str:=Memo_ip_IPS.Lines[0];
  If StartMessage then If Str='none' then
                                     begin
                                          ButtonVPN.Caption:=str0;
                                          Application.ProcessMessages;
                                          Form1.Repaint;
                                          Form3.MyMessageBox(message0,message26,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                          Application.ProcessMessages;
                                          Form1.Repaint;
                                          exit;
                                     end;
If Str <>'none' then Str:=DeleteSym(')',Str);
If Str <>'none' then Str:=DeleteSym('(',Str);
If Str <>'none' then Edit_IPS.Text:=Str;
FpSystem('rm -f '+MyTmpDir+'ip_IPS');
ButtonVPN.Caption:=message52;
Application.ProcessMessages;
Form1.Repaint;
sleep(2000);
ButtonVPN.Caption:=str0;
Application.ProcessMessages;
Form1.Repaint;
end;

procedure TForm1.ButtonHelpClick(Sender: TObject);
var
   a:boolean;
   StrOffice:string;
begin
     a:=ButtonHelp.Enabled;
     ButtonHelp.Enabled:=false;
     Application.ProcessMessages;
     Form1.Repaint;
     StrOffice:='';
     popen (f,'for i in {,/usr,/usr/local}{/bin,/lib} /opt /home;  do   '+'find  $i  -name oowriter -type f 2>/dev/null; done;','R');
     While not eof(f) do
            Readln (f,StrOffice);
     PClose(f);
     If StrOffice='' then
        begin
             popen (f,'for i in {,/usr,/usr/local}{/bin,/lib} /opt /home;  do   '+'find  $i  -name soffice -type f 2>/dev/null; done;','R');
             While not eof(f) do
                   Readln (f,StrOffice);
             PClose(f);
        end;
     If StrOffice='' then
                         begin
                              If FallbackLang='ru' then Form3.MyMessageBox(message0,message2+' '+MyWikiDir+'Help_ru.doc','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                              If FallbackLang='uk' then Form3.MyMessageBox(message0,message2+' '+MyWikiDir+'Help_uk.doc','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                         end;
     If StrOffice<>'' then
                          begin
                               AProcess := TAsyncProcess.Create(nil);
                               If FallbackLang='ru' then AProcess.CommandLine :=StrOffice+' '+MyWikiDir+'Help_ru.doc';
                               If FallbackLang='uk' then AProcess.CommandLine :=StrOffice+' '+MyWikiDir+'Help_uk.doc';
                               AProcess.Options:=AProcess.Options+[poWaitOnExit];
                               AProcess.Execute;
                               sleep(100);
                               AProcess.Free;
                          end;
     ButtonHelp.Enabled:=a;
     Application.ProcessMessages;
     Form1.Repaint;
end;

procedure TForm1.ButtonHidePassClick(Sender: TObject);
begin
  If Edit_passwd.EchoMode=emPassword then
     begin
          Edit_passwd.EchoMode:=emNormal;
          ButtonHidePass.Caption:=message87;
          Application.ProcessMessages;
          Form1.Repaint;
          exit;
    end;
  If Edit_passwd.EchoMode=emNormal then
     begin
          Edit_passwd.EchoMode:=emPassword;
          ButtonHidePass.Caption:=message86;
          Application.ProcessMessages;
          Form1.Repaint;
          exit;
    end;
end;

procedure TForm1.ButtonRestartClick(Sender: TObject);
//рестарт сети
var
  a,b,c:boolean;
  str:string;
  FileInterface:textfile;
begin
a:=ButtonHelp.Enabled;
b:=ComboBoxDistr.Enabled;
c:=Delete.Enabled;
ButtonRestart.Caption:=message53;
Button_exit.Enabled:=false;
Button_next1.Enabled:=false;
ButtonHelp.Enabled:=false;
ButtonVPN.Enabled:=false;
ButtonRestart.Enabled:=false;
ButtonHidePass.Enabled:=false;
Edit_IPS.Enabled:=false;
Edit_peer.Enabled:=false;
Edit_user.Enabled:=false;
Edit_passwd.Enabled:=false;
Edit_MaxTime.Enabled:=false;
Edit_MinTime.Enabled:=false;
ComboBoxVPN.Enabled:=false;
ComboBoxDistr.Enabled:=false;
Delete.Enabled:=false;
Application.ProcessMessages;
Form1.Repaint;
If suse then
            begin
                FpSystem ('netconfig update -f');
                If FileExists (EtcDir+'resolv.conf.netconfig') then
                              begin
                                 FpSystem ('cp -f '+EtcDir+'resolv.conf.netconfig '+EtcDir+'resolv.conf');
                                 FpSystem ('rm -f '+EtcDir+'resolv.conf.netconfig');
                              end;
            end;
If ServiceCommand='systemctl' then FpSystem (ServiceCommand+' restart '+NetServiceStr) else FpSystem (ServiceCommand+NetServiceStr+' restart');
FpSystem ('rm -f '+MyTmpDir+'Interfaces');
FpSystem ('cat /proc/net/dev | awk -F : '+chr(39)+'{if (NR>2) print $1}'+chr(39)+' >>'+MyTmpDir+'Interfaces');
AssignFile (FileInterface,MyTmpDir+'Interfaces');
reset (FileInterface);
While not eof (FileInterface) do
   begin
        readln(FileInterface, str);
        Ifdown(DeleteSym (' ',str));
        Ifup(DeleteSym (' ',str));
   end;
closefile(FileInterface);
FpSystem ('rm -f '+MyTmpDir+'Interfaces');
Ifup('lo');
ButtonRestart.Caption:=message93;
Button_exit.Enabled:=true;
Button_next1.Enabled:=true;
ButtonHelp.Enabled:=a;
ComboBoxDistr.Enabled:=b;
Delete.Enabled:=c;
ButtonVPN.Enabled:=true;
ButtonRestart.Enabled:=true;
ButtonHidePass.Enabled:=true;
Edit_IPS.Enabled:=true;
Edit_peer.Enabled:=true;
Edit_user.Enabled:=true;
Edit_passwd.Enabled:=true;
Edit_MaxTime.Enabled:=true;
Edit_MinTime.Enabled:=true;
ComboBoxVPN.Enabled:=true;
Application.ProcessMessages;
Form1.Repaint;
end;

procedure TForm1.ButtonTestClick(Sender: TObject);
 //тестовый запуск сконфигурированного соединения
var
 str_log:string;
 FlagMtu:boolean;
 MtuUsed:string;
 FileSizeStart:int64;
begin
 z_num:=0;
 Form3.MyMessageBox(message0,message108+' '+message11,message123,message124,message125,MyPixmapsDir+'vpnpptp.png',true,true,true,AFont,Form1.Icon,false,MyLibDir);
 Application.ProcessMessages;
 Form1.Repaint;
 if (Form3.Tag=3) or (Form3.Tag=0) then begin Application.ProcessMessages; Form1.Repaint; exit; end;
 ButtonTest.Enabled:=false;
 if Form3.Tag=1 then begin Application.ProcessMessages; Form1.Repaint; end;
 Memo_create.Clear;
 if Form3.Tag=1 then ForkStartProgram ('ponoff',Edit_peer.Text);
 if Form3.Tag=2 then if dhcp_route.Checked then if not DhclientStartGood then
                                    begin
                                        if fedora then FpSystem('killall dhclient');
                                        Memo_create.Lines.Add(message53);
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                        FpSystem ('dhclient '+Edit_eth.Text);
                                        if fedora then Sleep (10000) else Sleep(3000);
                                        Memo_create.Clear;
                                    end;
 str_date:='';
 popen(f,'date','R');
      While not eof(f) do
      Readln(f,str_date);
 pclose(f);
 If ComboBoxVPN.Text='VPN L2TP' then
                                    begin
                                       If Pppd_log.Checked then FpSystem('printf "'+str_date+'\n" >> '+VarLogDir+'vpnlog');
                                       If Pppd_log.Checked then FpSystem('printf "'+message109+' VPN L2TP ('+VarLogDir+'vpnlog)\n" >> '+VarLogDir+'vpnlog');
                                       If not Pppd_log.Checked then Memo_create.Lines.Add(message109+' VPN L2TP ('+VarLogDir+'vpnlog)');
                                       If Pppd_log.Checked then If Form3.Tag=1 then FpSystem('printf "'+message111+' '+'ponoff '+Edit_peer.Text+'\n" >> '+VarLogDir+'vpnlog');
                                       If not Pppd_log.Checked then if Form3.Tag=1 then Memo_create.Lines.Add (message111+' '+'ponoff');
                                       If Pppd_log.Checked then if Form3.Tag=2 then
                                                                 begin
                                                                      If ServiceCommand='systemctl ' then FpSystem('printf "'+message111+ServiceCommand+'stop xl2tpd.service'+'\n" >> '+VarLogDir+'vpnlog')
                                                                                    else FpSystem('printf "'+message111+ServiceCommand+'xl2tpd stop'+'\n" >> '+VarLogDir+'vpnlog');
                                                                      If ServiceCommand='systemctl ' then FpSystem('printf "'+message111+ServiceCommand+'start xl2tpd.service'+'\n" >> '+VarLogDir+'vpnlog')
                                                                                    else FpSystem('printf "'+message111+ServiceCommand+'xl2tpd start'+'\n" >> '+VarLogDir+'vpnlog');
                                                                 end;
                                       If not Pppd_log.Checked then if Form3.Tag=2 then
                                             If ServiceCommand='systemctl ' then Memo_create.Lines.Add(message111+ServiceCommand+'restart xl2tpd.service')
                                                      else Memo_create.Lines.Add(message111+ServiceCommand+'xl2tpd restart');
                                       if Form3.Tag=2 then
                                                                 begin
                                                                      //проверка xl2tpd в процессах
                                                                      FpSystem('ps -A | '+'grep xl2tpd > '+MyTmpDir+'tmpnostart1');
                                                                      If FileExists(MyTmpDir+'tmpnostart1') then If FileSize (MyTmpDir+'tmpnostart1')=0 then
                                                                                   begin
                                                                                        Memo_create.Lines.Add(message53);
                                                                                        Application.ProcessMessages;
                                                                                        Form1.Repaint;
                                                                                        If ServiceCommand='systemctl ' then FpSystem(ServiceCommand+'stop xl2tpd.service') else FpSystem(ServiceCommand+'xl2tpd stop');
                                                                                        If ServiceCommand='systemctl ' then FpSystem(ServiceCommand+'start xl2tpd.service') else FpSystem(ServiceCommand+'xl2tpd start');
                                                                                        Sleep (5000);
                                                                                   end;
                                                                      FpSystem ('rm -f '+MyTmpDir+'tmpnostart1');
                                                                      FpSystem ('echo "c '+Edit_peer.Text+'" > '+VarRunXl2tpdDir+'l2tp-control');
                                                                 end;
                                    end;
 If ComboBoxVPN.Text='VPN PPTP' then
                                    begin
                                        If Pppd_log.Checked then FpSystem('printf "'+str_date+'\n" >> '+VarLogDir+'vpnlog');
                                        If Pppd_log.Checked then FpSystem('printf "'+message109+' VPN PPTP ('+VarLogDir+'vpnlog)\n" >> '+VarLogDir+'vpnlog');
                                        If not Pppd_log.Checked then Memo_create.Lines.Add (message109+' VPN PPTP ('+VarLogDir+'vpnlog)');
                                        If Pppd_log.Checked then if Form3.Tag=1 then FpSystem('printf "'+message111+' '+'ponoff '+Edit_peer.Text+'\n" >> '+VarLogDir+'vpnlog');
                                        If not Pppd_log.Checked then if Form3.Tag=1 then Memo_create.Lines.Add (message111+' '+'ponoff '+Edit_peer.Text);
                                        If Pppd_log.Checked then if Form3.Tag=2 then FpSystem('printf "'+message111+' '+'pppd call '+Edit_peer.Text+'\n" >> '+VarLogDir+'vpnlog');
                                        If not Pppd_log.Checked then If Form3.Tag=2 then Memo_create.Lines.Add (message111+' '+'pppd call '+Edit_peer.Text);
                                        if Form3.Tag=2 then FpSystem ('pppd call '+Edit_peer.Text);
                                    end;
 If ComboBoxVPN.Text='VPN OpenL2TP' then
                                    begin
                                        If Pppd_log.Checked then FpSystem('printf "'+str_date+'\n" >> '+VarLogDir+'vpnlog');
                                        If Pppd_log.Checked then FpSystem('printf "'+message109+' VPN OpenL2TP ('+VarLogDir+'vpnlog)\n" >> '+VarLogDir+'vpnlog');
                                        If not Pppd_log.Checked then Memo_create.Lines.Add (message109+' VPN OpenL2TP ('+VarLogDir+'vpnlog)');
                                        If Pppd_log.Checked then if Form3.Tag=1 then FpSystem('printf "'+message111+' '+'ponoff '+Edit_peer.Text+'\n" >> '+VarLogDir+'vpnlog');
                                        If not Pppd_log.Checked then if Form3.Tag=1 then Memo_create.Lines.Add (message111+' '+'ponoff '+Edit_peer.Text);
                                        If Pppd_log.Checked then if Form3.Tag=2 then FpSystem('printf "'+message111+' '+'bash '+MyLibDir+Edit_peer.Text+'/openl2tp-start\n" >> '+VarLogDir+'vpnlog');
                                        If not Pppd_log.Checked then If Form3.Tag=2 then Memo_create.Lines.Add (message111+' '+'bash '+MyLibDir+Edit_peer.Text+'/openl2tp-start');
                                        if Form3.Tag=2 then FpSystem ('bash '+MyLibDir+Edit_peer.Text+'/openl2tp-start');
                                    end;
If not Pppd_log.Checked then Memo_create.Lines.Add (message110);
Memo_create.Hint:=message109;
Application.ProcessMessages;
Form1.Repaint;
str_log:=VarLogDir+'vpnlog';
FlagMtu:=false;
If Pppd_log.Checked then
begin
 FileSizeStart:=FileSize(str_log);
 Memo_create.Lines.Add(message53);
 Timer1.Enabled:=true;
 Timer1.Interval:=10000;
 StartKoli4estvo:=1000;
 While true do
     begin
          Application.ProcessMessages;
          while FileSize(str_log)<=FileSizeStart do
                                                   begin
                                                        sleep(100);
                                                        Application.ProcessMessages;
                                                   end;
          If FileSize(str_log)>FileSizeStart then
                                             begin
                                                      Timer1.Enabled:=false;
                                                      GetTestLog(str_log);
                                                      FileSizeStart:=FileSize(str_log);
                                                      If not FlagMtu then
                                                          begin
                                                                //Проверяем поднялось ли соединение
                                                                CheckVPN;
                                                                //Проверяем используемое mtu
                                                                MtuUsed:='';
                                                                If Code_up_ppp then
                                                                   begin
                                                                     popen (f,'ifconfig '+PppIface+'|'+'grep MTU |'+'awk '+ chr(39)+'{print $6}'+chr(39)+'|'+'cut -d ":" --fields=2','R');
                                                                     if eof(f) then begin PClose(f); popen (f,'ifconfig '+PppIface+'|'+'grep mtu |'+'awk '+ chr(39)+'{print $4}'+chr(39),'R');end;
                                                                     While not eof(f) do
                                                                        begin
                                                                          Readln (f,MtuUsed);
                                                                        end;
                                                                     PClose(f);
                                                                     If MtuUsed<>'' then If MyStrToInt(MtuUsed)>1472 then
                                                                             FpSystem('printf "'+'vpnpptp: '+message163+' '+MtuUsed+' '+message164+'\n" >> '+VarLogDir+'vpnlog');
                                                                     FlagMtu:=true;
                                                                   end;
                                                          end;
                                                      Application.ProcessMessages;
                                                      Timer1.Enabled:=true;
                                             end;
     end;
end;
end;

procedure TForm1.Autostart_ponoffChange(Sender: TObject);
begin
   //проверка установлен ли пакет Sudo
   If FileExistsBin ('sudo') then Sudo:=true else Sudo:=false;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo then
                       begin
                          Form3.MyMessageBox(message0,message24,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Autostart_ponoff.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          exit;
                       end;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo_ponoff.Checked then
                       begin
                          Form3.MyMessageBox(message0,message59,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Sudo_ponoff.Checked:=true;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
end;

procedure TForm1.balloonChange(Sender: TObject);
begin
  If StartMessage then If balloon.Checked then if networktest.Checked then
                       begin
                          Form3.MyMessageBox(message0,message142,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          networktest.Checked:=false;
                          StartMessage:=true;
                       end;
  Application.ProcessMessages;
  Form1.Repaint;
end;

procedure TForm1.AutostartpppdChange(Sender: TObject);
begin
If StartMessage then If pppnotdefault.Checked then If Autostartpppd.Checked then
                       begin
                          Form3.MyMessageBox(message0,message65,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Autostartpppd.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
end;

procedure TForm1.Button_exitClick(Sender: TObject);
begin
  Timer1.Enabled:=false;
  halt;
end;

procedure TForm1.Button_moreClick(Sender: TObject);
begin
     Unit2.Form2.Obrabotka(Edit_peer.Text,more, AFont, MyLibDir, EtcPppPeersDir);
     Form2.Hint:=MakeHint(message143+' '+message149,5);
     Unit2.Form2.OnMouseDown:=Form1.OnMouseDown;
     Unit2.Form2.ShowModal;
     more:=true;
end;

procedure TForm1.CheckBox_shorewallChange(Sender: TObject);
begin
   If StartMessage then If CheckBox_shorewall.Checked then if not FileExistsBin('shorewall') then
                                             begin
                                                Form3.MyMessageBox(message0,message140,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                CheckBox_shorewall.Checked:=false;
                                             end;
   Application.ProcessMessages;
   Form1.Repaint;
end;

procedure TForm1.CheckBox_statelessChange(Sender: TObject);
begin
   If CheckBox_stateless.Checked then CheckBox_required.Checked:=true;
end;

procedure TForm1.ComboBoxDistrKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=16 then Edit_MaxTime.SetFocus;
  if Key=9 then Edit_MinTime.SetFocus;
  Key:=0;
end;

procedure TForm1.ComboBoxVPNChange(Sender: TObject);
var
   Str:string;
   Problem:boolean;
   FindModule_l2tp_ppp,FindModule_pppol2tp:boolean;
   openl2tp,pppol2tp_so:boolean;
begin
  Problem:=false;
  FindModule_l2tp_ppp:=false;
  FindModule_pppol2tp:=false;
  If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then Label1.Caption:=First_Label1+' '+message100 else Label1.Caption:=First_Label1+' '+message99;
  Application.ProcessMessages;
  Form1.Repaint;
  If ComboBoxVPN.Text='VPN PPTP' then If not FileExistsBin('pptp') then
                                     begin
                                        Form3.MyMessageBox(message0,message20,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                        ComboBoxVPN.Text:='';
                                        If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then Label1.Caption:=First_Label1+' '+message100 else Label1.Caption:=First_Label1+' '+message99;
                                        exit;
                                     end;
  If ComboBoxVPN.Text='VPN PPTP' then exit;
  If ComboBoxVPN.Text='VPN L2TP' then if not FileExistsBin ('xl2tpd') then
                                                                              begin
                                                                                   Form3.MyMessageBox(message0,message94,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                   ComboBoxVPN.Text:='';
                                                                                   If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then Label1.Caption:=First_Label1+' '+message100 else Label1.Caption:=First_Label1+' '+message99;
                                                                                   exit;
                                                                              end;
  If ComboBoxVPN.Text='VPN L2TP' then exit;
  str:=message219+' ';
  pppol2tp_so:=false;
  openl2tp:=false;
  If ComboBoxVPN.Text='VPN OpenL2TP' then if not FileExistsBin ('openl2tpd') then
                                                                                         begin
                                                                                              str:=str+message213+' ';
                                                                                              Problem:=true;
                                                                                         end;
  If ComboBoxVPN.Text='VPN OpenL2TP' then If DirectoryExists(UsrLib64PppdDir) then
                                                                                  begin
                                                                                       popen(f,'find '+UsrLib64PppdDir+' -name pppol2tp.so','R');
                                                                                       if eof(f) then pppol2tp_so:=false else pppol2tp_so:=true;
                                                                                       pclose(f);
                                                                                       popen(f,'find '+UsrLib64PppdDir+' -name openl2tp.so','R');
                                                                                       if eof(f) then openl2tp:=false else openl2tp:=true;
                                                                                       pclose(f);
                                                                                  end;
  If ComboBoxVPN.Text='VPN OpenL2TP' then If DirectoryExists(UsrLibPppdDir) then
                                                                                begin
                                                                                    if not pppol2tp_so then
                                                                                                           begin
                                                                                                                popen(f,'find '+UsrLibPppdDir+' -name pppol2tp.so','R');
                                                                                                                if eof(f) then pppol2tp_so:=false else pppol2tp_so:=true;
                                                                                                                pclose(f);
                                                                                                           end;
                                                                                    if not openl2tp then
                                                                                                           begin
                                                                                                                popen(f,'find '+UsrLibPppdDir+' -name openl2tp.so','R');
                                                                                                                if eof(f) then openl2tp:=false else openl2tp:=true;
                                                                                                                pclose(f);
                                                                                                           end;
                                                                                end;
  If ComboBoxVPN.Text='VPN OpenL2TP' then If (not openl2tp) or (not pppol2tp_so) then
                                                                                     begin
                                                                                          if not openl2tp then str:=str+message221+' openl2tp.so. ';
                                                                                          if not pppol2tp_so then str:=str+message221+' pppol2tp.so. ';
                                                                                          str:=str+message222+' ';
                                                                                          Problem:=true;
                                                                                     end;
  If ComboBoxVPN.Text='VPN OpenL2TP' then
                                         begin
                                              if FileExistsBin ('openl2tpd') then
                                                                                         begin
                                                                                              FpSystem('modprobe -r l2tp_ppp');
                                                                                              FpSystem('modprobe -r pppol2tp');
                                                                                              FpSystem('modprobe l2tp_ppp');
                                                                                              FpSystem('modprobe pppol2tp');
                                                                                              popen(f,'lsmod | '+'awk '+chr(39)+'{print $1}'+chr(39)+'|'+'grep l2tp_ppp','R');
                                                                                              if not eof(f) then FindModule_l2tp_ppp:=true;
                                                                                              pclose(f);
                                                                                              popen(f,'lsmod | '+'awk '+chr(39)+'{print $1}'+chr(39)+'|'+'grep pppol2tp','R');
                                                                                              if not eof(f) then FindModule_pppol2tp:=true;
                                                                                              pclose(f);
                                                                                              If not FindModule_pppol2tp then if not FindModule_l2tp_ppp then
                                                                                                                                                             begin
                                                                                                                                                                  Problem:=true;
                                                                                                                                                                  str:=str+message220+' l2tp_ppp. '+message220+' pppol2tp. ';
                                                                                                                                                             end;
                                                                                         end;
                                         end;
  If Problem then
                 begin
                      ComboBoxVPN.Text:='';
                      Form3.MyMessageBox(message0,LeftStr(str,Length(str)-1),'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                 end;
  If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then Label1.Caption:=First_Label1+' '+message100 else Label1.Caption:=First_Label1+' '+message99;
end;

procedure TForm1.ComboBoxVPNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=16 then Edit_user.SetFocus;
  if Key=9 then Edit_passwd.SetFocus;
  Key:=0;
end;

procedure TForm1.DeleteClick(Sender: TObject);
var
    found:boolean;
    FileProfiles:textfile;
    str:string;
begin
  link_on_desktop:=false;
  //обработка соединения по-умолчанию
   found:=false;
   If FileExists(MyLibDir+'default/default') then
           begin
                ProfileStrDefault:='';
                popen(f,'cat '+MyLibDir+'default/default','R');
                while not eof(f) do
                      begin
                         readln(f,ProfileStrDefault);
                         if ProfileStrDefault=ProfileForDelete then found:=true;
                      end;
                PClose(f);
          end;
    Application.ProcessMessages;
    Form1.Repaint;
    If not found then Form3.MyMessageBox(message0,message179+' '+ProfileForDelete+'?','',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
    If found then If ProfileStrDefault<>'' then Form3.MyMessageBox(message0,message179+' '+ProfileForDelete+'? '+message184+' '+message185,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
    if Form3.Tag=2 then
                              begin
                                Form1.Hide;
                                DoIconDesktop('50','vpnpptp',true,ProfileForDelete);
                                DoIconDesktop('100','vpnpptp',true,ProfileForDelete);
                                DoIconDesktop('50','ponoff',true,ProfileForDelete);
                                DoIconDesktop('100','ponoff',true,ProfileForDelete);
                                FpSystem('rm -f '+EtcPppPeersDir+ProfileForDelete);
                                FpSystem('rm -f '+EtcPppPeersDir+ProfileForDelete+'.old');
                                FpSystem('rm -f '+EtcPppIpDownDDir+ProfileForDelete+'-ip-down');
                                FpSystem('rm -f '+EtcPppIpDownLDir+ProfileForDelete+'-ip-down');
                                FpSystem('rm -f '+EtcPppIpUpDDir+ProfileForDelete+'-ip-up');
                                FpSystem('rm -rf '+MyLibDir+ProfileForDelete);
                                If FileExists (MyLibDir+'profiles') then
                                                                     begin
                                                                        AssignFile (FileProfiles,MyLibDir+'profiles');
                                                                        reset(FileProfiles);
                                                                        FpSystem('rm -f '+MyTmpDir+'profiles.tmp');
                                                                        FpSystem('touch '+MyTmpDir+'profiles.tmp');
                                                                        str:='';
                                                                        While not eof (FileProfiles) do
                                                                        begin
                                                                             readln(FileProfiles, str);
                                                                             if str<>'' then if str<>ProfileForDelete then FpSystem ('printf "'+str+'\n" >> '+MyTmpDir+'profiles.tmp');
                                                                        end;
                                                                        closefile(FileProfiles);
                                                                        FpSystem('cp -f '+MyTmpDir+'profiles.tmp '+MyLibDir+'profiles');
                                                                        FpSystem('rm -f '+MyTmpDir+'profiles.tmp');
                                                                     end;
                                If FileExists(MyLibDir+'profiles') then if FileExists(EtcXl2tpdDir+'xl2tpd.conf') then
                                                                        begin
                                                                           FpSystem('rm -f '+EtcXl2tpdDir+'xl2tpd.conf');
                                                                           FpSystem('mkdir -p '+EtcXl2tpdDir);
                                                                           FpSystem('printf "'+'[global]'+'\n" >> '+EtcXl2tpdDir+'xl2tpd.conf');
                                                                           FpSystem('printf "'+'access control = yes'+'\n" >> '+EtcXl2tpdDir+'xl2tpd.conf');
                                                                           AssignFile(FileProfiles,MyLibDir+'profiles');
                                                                           reset (FileProfiles);
                                                                           str:='';
                                                                           While not eof (FileProfiles) do
                                                                                begin
                                                                                   readln(FileProfiles, str);
                                                                                   If FileExists(MyLibDir+str+'/xl2tpd.conf.lac') then FpSystem ('cat '+MyLibDir+str+'/xl2tpd.conf.lac >> '+EtcXl2tpdDir+'xl2tpd.conf');
                                                                                end;
                                                                           closefile(FileProfiles);
                                                                        end;
                                If FileExists(MyLibDir+'profiles') then if FileSize(MyLibDir+'profiles')=0 then FpSystem ('rm -f '+MyLibDir+'profiles');
                                If found then If ProfileStrDefault<>'' then FpSystem('rm -f '+MyLibDir+'default/default');
                                If not FileExists(MyLibDir+'profiles') then If not FileExists(MyLibDir+'default/default') then FpSystem ('rm -rf '+MyLibDir+'default');
                                If not FileExists(MyLibDir+'profiles') then FpSystem ('rm -f '+MyLibDir+'general.conf');
                                If not FileExists(MyLibDir+'profiles') then FpSystem ('rm -f '+MyLibDir+'ponoff.conf.ini');
                                If not FileExists(MyLibDir+'profiles') then If FileExists(EtcDir+'openl2tpd.conf.old') then
                                                                                                                           begin
                                                                                                                                FpSystem('cp -f '+EtcDir+'openl2tpd.conf.old '+EtcDir+'openl2tpd.conf');
                                                                                                                                FpSystem('rm -f '+EtcDir+'openl2tpd.conf.old');
                                                                                                                           end;
                                Form3.MyMessageBox(message0,message180+' '+ProfileForDelete+' '+message181,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                halt;
                              end;
    Application.ProcessMessages;
    Form1.Repaint;
end;

procedure TForm1.Edit_peerChange(Sender: TObject);
var
    i:integer;
begin
    If Length(Edit_peer.Text)=0 then exit;
    Edit_peer.Text:=DeleteSym (' ',Edit_peer.Text);
    Edit_peer.Text:=DeleteSym ('/',Edit_peer.Text);
    If Length(Edit_peer.Text)>=2 then If RightStr(Edit_peer.Text,2)='..' then
                                                    Edit_peer.Text:=LeftStr(Edit_peer.Text,(Length(Edit_peer.Text))-1);
    If Length(Edit_peer.Text)>=1 then if (Edit_peer.Text[1] in ['0'..'9']) then Edit_peer.Text:=DeleteSym(Edit_peer.Text[1],Edit_peer.Text);
    For i:=1 to Length(Edit_peer.Text) do
      If Length(Edit_peer.Text)>0 then
        begin
             If not (Edit_peer.Text[i] in ['a'..'z']) then If not (Edit_peer.Text[i] in ['A'..'Z']) then
                            If not (Edit_peer.Text[i] in ['0'..'9']) then
                                              Edit_peer.Text:=DeleteSym(Edit_peer.Text[i],Edit_peer.Text);
        end;
end;

procedure TForm1.etc_hostsChange(Sender: TObject);
begin
  If StartMessage then If IPS then If etc_hosts.Checked then
                       begin
                          Form3.MyMessageBox(message0,message114,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          etc_hosts.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          exit;
                       end;
  If StartMessage then If not IPS then If etc_hosts.Checked then If not routevpnauto.Checked then
                       begin
                          Form3.MyMessageBox(message0,message116,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          routevpnauto.Checked:=true;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          exit;
                       end;
   If FileExistsBin ('host') then BindUtils:=true else BindUtils:=false;
   If StartMessage then If etc_hosts.Checked then If not BindUtils then
                       begin
                          Form3.MyMessageBox(message0,message121+' '+message115,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
end;

procedure TForm1.GroupBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   If PressCreate then exit;
   If Button=mbLeft then If Form1.Font.Size<15 then
                            begin
                                 Form1.Font.Size:=Form1.Font.Size+1;
                                 Form2.Font.Size:=Form2.Font.Size+1;
                            end;
   If Button=mbRight then If Form1.Font.Size>1 then
                             begin
                                 Form1.Font.Size:=Form1.Font.Size-1;
                                 Form2.Font.Size:=Form2.Font.Size-1;
                             end;
   AFont:=Form1.Font.Size;
   Form1.Repaint;
   Application.ProcessMessages;
   Form1.Repaint;
end;

procedure TForm1.GroupBox2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   If PressCreate then exit;
   If Button=mbLeft then If Form1.Font.Size<15 then
                            begin
                                 Form1.Font.Size:=Form1.Font.Size+1;
                                 Form2.Font.Size:=Form2.Font.Size+1;
                            end;
   If Button=mbRight then If Form1.Font.Size>1 then
                             begin
                                 Form1.Font.Size:=Form1.Font.Size-1;
                                 Form2.Font.Size:=Form2.Font.Size-1;
                             end;
   AFont:=Form1.Font.Size;
   Form1.Repaint;
   Application.ProcessMessages;
   Form1.Repaint;
end;

procedure TForm1.GroupBox3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   If PressCreate then exit;
   If Button=mbLeft then If Form1.Font.Size<15 then
                            begin
                                 Form1.Font.Size:=Form1.Font.Size+1;
                                 Form2.Font.Size:=Form2.Font.Size+1;
                            end;
   If Button=mbRight then If Form1.Font.Size>1 then
                             begin
                                 Form1.Font.Size:=Form1.Font.Size-1;
                                 Form2.Font.Size:=Form2.Font.Size-1;
                             end;
   AFont:=Form1.Font.Size;
   Form1.Repaint;
   Application.ProcessMessages;
   Form1.Repaint;
end;

procedure TForm1.networktestChange(Sender: TObject);
begin
  If StartMessage then If networktest.Checked then If balloon.Checked then
                       begin
                          Form3.MyMessageBox(message0,message142,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          balloon.Checked:=false;
                          StartMessage:=true;
                       end;
  Application.ProcessMessages;
  Form1.Repaint;
end;

procedure TForm1.pppnotdefaultChange(Sender: TObject);
begin
If StartMessage then If pppnotdefault.Checked then If Autostartpppd.Checked then
                       begin
                          Form3.MyMessageBox(message0,message65,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          pppnotdefault.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
end;

procedure TForm1.routevpnautoChange(Sender: TObject);
begin
   If FileExistsBin ('host') then BindUtils:=true else BindUtils:=false;
   If StartMessage then If not IPS then If etc_hosts.Checked then If not routevpnauto.Checked then
                       begin
                          Form3.MyMessageBox(message0,message116,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          etc_hosts.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          exit;
                       end;
   If StartMessage then If routevpnauto.Checked then If not BindUtils then
                       begin
                          Form3.MyMessageBox(message0,message121+' '+message29,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
end;

procedure TForm1.dhcp_routeChange(Sender: TObject);
begin
  If StartMessage then If dhcp_route.Checked then if not dhclient then
                       begin
                          Form3.MyMessageBox(message0,message27,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          dhcp_route.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          exit;
                       end;
  If StartMessage then if ubuntu or debian or suse then
                       begin
                          Form3.MyMessageBox(message0,message141,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          dhcp_route.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
end;

procedure TForm1.Button_next1Click(Sender: TObject);
var
   i:word;
   y:boolean;
   j:byte; //точка в написании шлюза
   a,b,c,d:string; //a.b.c.d-это шлюз
   FileResolv_conf:textfile;
   str,str1,str0:string;
   x,code:integer;
begin
 y:=false;
 default_mppe:=true;
 error_man_pppd:=false;
 If FileExistsBin('strings') then popen (f,'strings '+UsrSbinDir+'pppd | '+'grep require-mppe','R');
 If not FileExistsBin('strings') then If FileExistsBin('man') then
                                                                               begin
                                                                                    popen (f0,'man pppd','R');
                                                                                    If not eof(f0) then popen (f,'man pppd | '+'grep require-mppe','R') else error_man_pppd:=true;
                                                                                    pclose(f0);
                                                                               end;
 If FileExistsBin('strings') or FileExistsBin('man') then
                               if not eof(f) then default_mppe:=false;
 //default_mppe:=true;//для проверки при отладке
 if not default_mppe then
                begin
                    CheckBox_no56.Visible:=false;
                    CheckBox_no56.Checked:=true;
                end;
 Pclose(f);
//проверка корректности имени соединения
  str:=Edit_peer.Text;
  str:=UTF8UpperCase(str);
  if Length(str)>=3 then str1:=LeftStr(str,3);
  if (str='DEFAULT') or (str='VPNMCC') or (str1='PPP') then
                         begin
                             Form3.MyMessageBox(message0,message169+' '+Edit_peer.Text+', '+message186,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                             Edit_peer.Text:='';
                             Application.ProcessMessages;
                             Form1.Repaint;
                             exit;
                         end;
//проверка корректности ввода времени дозвона
    if  Length(Edit_MaxTime.Text)>1 then if Edit_MaxTime.Text[1]='0' then Edit_MaxTime.Text:='0';
    for i:=1 to Length(Edit_MaxTime.Text) do
        if not (Edit_MaxTime.Text[i] in ['0'..'9']) then y:=true;
    if y or (Edit_MaxTime.Text='') or (Edit_MaxTime.Text='0') or (Length(Edit_MaxTime.Text)>3) then
            begin
              Form3.MyMessageBox(message0,message8,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
              Edit_MaxTime.Text:='10';
              Application.ProcessMessages;
              Form1.Repaint;
              exit;
            end;
    if (MyStrToInt(Edit_MaxTime.Text)<5) or (MyStrToInt(Edit_MaxTime.Text)>255) then
             begin
               Form3.MyMessageBox(message0,message8,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
               Edit_MaxTime.Text:='10';
               Application.ProcessMessages;
               Form1.Repaint;
               exit;
             end;
//проверка корректности ввода времени реконнекта
y:=false;
    if  Length(Edit_MinTime.Text)>1 then if Edit_MinTime.Text[1]='0' then Edit_MinTime.Text:='0';
    for i:=1 to Length(Edit_MinTime.Text) do
        if not (Edit_MinTime.Text[i] in ['0'..'9']) then y:=true;
    if y or (Edit_MinTime.Text='') or (MyStrToInt(Edit_MinTime.Text)>255) or (Length(Edit_MinTime.Text)>3) then
            begin
              Form3.MyMessageBox(message0,message10,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
              Edit_MinTime.Text:='3';
              Application.ProcessMessages;
              Form1.Repaint;
              exit;
            end;
//проверка корректности ввода иных полей настроек подключения
if (Edit_IPS.Text='') or (Edit_peer.Text='') or (Edit_user.Text='') or (Edit_passwd.Text='') then
                            begin
                                Form3.MyMessageBox(message0,message1,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                Application.ProcessMessages;
                                Form1.Repaint;
                                exit;
                            end;
//проверка версии xl2tpd
str:='';
str0:='';
If ComboBoxVPN.Text='VPN L2TP' then
               begin
                  popen (f,'xl2tpd -v','R');
                  While not eof(f) do
                      readln(f,str);
                  PClose(f);
                  if str<>'' then str:=RightStr(str,5);
                  if str<>'' then
                                 begin
                                    for i:=1 to Length(str) do
                                        if str[i]<>'.' then str0:=str0+str[i];
                                    Val(str0,x,code);
                                    if code=0 then if x<136 then
                                                   begin
                                                       Form3.MyMessageBox(message0,message146+' '+str+'.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                       Application.ProcessMessages;
                                                       Form1.Repaint;
                                                       exit;
                                                   end;
                                 end;
               end;
//запрет на невыбор типа VPN
If ComboBoxVPN.Text='' then
                           begin
                              Form3.MyMessageBox(message0,message168,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                              Application.ProcessMessages;
                              Form1.Repaint;
                              exit;
                           end;
//запрет на выбор типа VPN при отсутствии требующегося для его работы пакета
If ComboBoxVPN.Text='VPN PPTP' then If not FileExistsBin('pptp') then
                                   begin
                                      Form3.MyMessageBox(message0,message20,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                      Application.ProcessMessages;
                                      Form1.Repaint;
                                      exit;
                                   end;
If ComboBoxVPN.Text='VPN L2TP' then if not FileExistsBin ('xl2tpd') then
                                  begin
                                       Form3.MyMessageBox(message0,message94,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                       Application.ProcessMessages;
                                       Form1.Repaint;
                                       exit;
                                  end;
If ComboBoxVPN.Text='VPN OpenL2TP' then if not FileExistsBin ('openl2tpd') then
                                begin
                                     Form3.MyMessageBox(message0,message213,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                     Application.ProcessMessages;
                                     Form1.Repaint;
                                     exit;
                                end;
//проверка выбора дистрибутива
if ComboBoxDistr.Text=message151 then
                            begin
                                Form3.MyMessageBox(message0,message152,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                Application.ProcessMessages;
                                Form1.Repaint;
                                exit;
                            end;
If ComboBoxVPN.Text='VPN L2TP' then Reconnect_pptp.Caption:=message96;
If ComboBoxVPN.Text='VPN OpenL2TP' then Reconnect_pptp.Caption:=message217;
If ComboBoxVPN.Text='VPN L2TP' then Autostartpppd.Caption:=message98;
If ComboBoxVPN.Text='VPN OpenL2TP' then Autostartpppd.Caption:=message216;
If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then
               begin
                  CheckBox_required.Hint:=MakeHint(message79+' '+message88+' '+message233,5);
                  CheckBox_stateless.Hint:=MakeHint(message89+' '+message88+' '+message233,5);
                  CheckBox_no40.Hint:=MakeHint(message90+' '+message88+' '+message233,5);
                  CheckBox_no56.Hint:=MakeHint(message91+' '+message88+' '+message233,5);
                  CheckBox_no128.Hint:=MakeHint(message92+' '+message88+' '+message233,5);
               end;
if not y then
              begin
                TabSheet1.TabVisible:= False;
                TabSheet2.TabVisible:= True;
                TabSheet3.TabVisible:= False;
                TabSheet4.TabVisible:= False;
                PageControl1.ActivePageIndex:=1;
                Button_create.Visible:=False;
                Button_next1.Visible:=False;
                Button_next2.Visible:=True;
              end;
If ComboBoxDistr.Text='Ubuntu '+message150 then begin ubuntu:=true;debian:=false;suse:=false;mageia:=false;fedora:=false;end;
If ComboBoxDistr.Text='Debian '+message150 then begin debian:=true;ubuntu:=false;suse:=false;mageia:=false;fedora:=false;end;
If ComboBoxDistr.Text='Fedora '+message150 then begin fedora:=true;debian:=false;ubuntu:=false;suse:=false;mageia:=false;end;
If ComboBoxDistr.Text='openSUSE '+message150 then begin suse:=true;ubuntu:=false;debian:=false;mageia:=false;fedora:=false;end;
If ComboBoxDistr.Text='Mageia '+message150 then begin mageia:=true;ubuntu:=false;debian:=false;suse:=false;fedora:=false;end;
//проверка строки vpn-сервера
y:=false;
If (Form1.Edit_IPS.Text='none') or (Form1.Edit_IPS.Text='') or (Length(Form1.Edit_gate.Text)>15) then //15-макс.длина шлюза 255.255.255.255
                    begin
                      y:=true;
                    end;
j:=0;
a:=''; b:=''; c:=''; d:='';
y:=false;
For i:=1 to Length (Form1.Edit_IPS.Text) do //символьная строка шлюза разбивается на октеты (или квадранты)
    begin
      if j=0 then if Form1.Edit_IPS.Text[i]<>'.' then a:=a+Form1.Edit_IPS.Text[i];
      if j=1 then if Form1.Edit_IPS.Text[i]<>'.' then b:=b+Form1.Edit_IPS.Text[i];
      if j=2 then if Form1.Edit_IPS.Text[i]<>'.' then c:=c+Form1.Edit_IPS.Text[i];
      if j=3 then if Form1.Edit_IPS.Text[i]<>'.' then d:=d+Form1.Edit_IPS.Text[i];
      if Form1.Edit_IPS.Text[i]='.' then j:=j+1;
    end;
If (j>3) or (Length(a)>3) or (Length(b)>3) or (Length(c)>3) or (Length(d)>3)
or (a='') or (b='') or (c='') or (d='') then y:=true;
//проверка на то, а все ли цифры, нет ли букв и иных символов
Val(a,x,code);
if code<>0 then y:=true;
Val(b,x,code);
if code<>0 then y:=true;
Val(c,x,code);
if code<>0 then y:=true;
Val(d,x,code);
if code<>0 then y:=true;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
If not y then if not ((MyStrToInt(a)>=0) and (MyStrToInt(a)<=255)) then y:=true;
If not y then if not ((MyStrToInt(b)>=0) and (MyStrToInt(b)<=255)) then y:=true;
If not y then if not ((MyStrToInt(c)>=0) and (MyStrToInt(c)<=255)) then y:=true;
If not y then if not ((MyStrToInt(d)>=0) and (MyStrToInt(d)<=255)) then y:=true;
If not y then if not y then Form1.Edit_IPS.Text:=IntToStr(MyStrToInt(a))+'.'+IntToStr(MyStrToInt(b))+'.'+IntToStr(MyStrToInt(c))+'.'+IntToStr(MyStrToInt(d)); //сократятся лишние нули, введённые в начале любого из октетов (или квадрантов)
If not y then IPS:=true else IPS:=false;
//определяем шлюз по умолчанию
  FpSystem('ip r|'+'grep default|'+'awk '+ chr(39)+'{print $3}'+chr(39)+' > '+MyTmpDir+'gate');
  FpSystem('printf "none" >> '+MyTmpDir+'gate');
  Memo_gate.Clear;
  If FileExists(MyTmpDir+'gate') then Memo_gate.Lines.LoadFromFile(MyTmpDir+'gate');
  Edit_gate.Text:=Memo_gate.Lines[0];
  FpSystem('rm -f '+MyTmpDir+'gate');
//определяем сетевой интерфейс по умолчанию
  FpSystem('ip r|'+'grep default| '+'awk '+chr(39)+'{print $5}'+chr(39)+' > '+MyTmpDir+'eth');
  FpSystem('printf "none" >> '+MyTmpDir+'eth');
  Memo_eth.Clear;
  If FileExists(MyTmpDir+'eth') then Memo_eth.Lines.LoadFromFile(MyTmpDir+'eth');
  FpSystem('rm -f '+MyTmpDir+'eth');
  Edit_eth.Text:=Memo_eth.Lines[0];
  If Edit_eth.Text='link' then Edit_eth.Text:='none';
  If Edit_eth.Text='none' then
                           begin
                             Edit_gate.Text:='none';
                             Form3.MyMessageBox(message0,message12,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                             Application.ProcessMessages;
                             Form1.Repaint;
                           end;
  If RightStr(Memo_eth.Lines[0],7)='no link' then
                           begin
                             Edit_eth.Text:='none';
                             Edit_gate.Text:='none';
                             Form3.MyMessageBox(message0,message13,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                             Application.ProcessMessages;
                             Form1.Repaint;
                           end;
  If Edit_gate.Text='none' then
                           begin
                             Edit_eth.Text:='none';
                             Form3.MyMessageBox(message0,message14,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                             Application.ProcessMessages;
                             Form1.Repaint;
                           end;
  //определяем DNSA, DNSB и DNSdopC
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then
                                         begin
                                              DNSA:='none';
                                              DNSB:='none';
                                              DNSdopC:='none';
                                         end;
  If FileExists(EtcDir+'resolv.conf') then If not (LeftStr(Memo_gate.Lines[0],3)='ppp') then
                                    begin
                                      AssignFile (FileResolv_conf,EtcDir+'resolv.conf');
                                      reset (FileResolv_conf);
                                      While not eof (FileResolv_conf) do
                                          begin
                                           readln(FileResolv_conf, str);
                                           If leftstr(str,11)='nameserver ' then If DNSA='none' then DNSA:=RightStr(str,Length(str)-11);
                                           If leftstr(str,11)='nameserver ' then If DNSB='none' then if DNSA<>'none' then if RightStr(str,Length(str)-11)<>DNSA then DNSB:=RightStr(str,Length(str)-11);
                                           If leftstr(str,11)='nameserver ' then If DNSB<>'none' then if DNSA<>'none' then if RightStr(str,Length(str)-11)<>DNSA then if RightStr(str,Length(str)-11)<>DNSB then DNSdopC:=RightStr(str,Length(str)-11);
                                         end;
                                      closefile(FileResolv_conf);
                                    end;
  If DNSA='none' then if DNSB='none' then If FileExists(EtcDir+'resolv.conf') then
                           begin
                             DNS_auto:=false;
                             If IPS then Form3.MyMessageBox(message0,message66+' '+message197,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                             If not IPS then begin Form3.MyMessageBox(message0,message66+' '+message198+' '+message199+' '+message200,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir); halt;end;
                             Application.ProcessMessages;
                             Form1.Repaint;
                           end;
  If not FileExists(EtcDir+'resolv.conf') then
                                          begin
                                               no_resolv_conf:=true;
                                               FpSystem ('printf "nameserver 127.0.0.1'+'\n" >> '+EtcDir+'resolv.conf');
                                               FpSystem ('printf "nameserver 8.8.8.8'+'\n" >> '+EtcDir+'resolv.conf');
                                               FpSystem ('printf "nameserver 8.8.4.4'+'\n" >> '+EtcDir+'resolv.conf');
                                               Form3.MyMessageBox(message0,message215,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                               DNSA:='127.0.0.1';
                                               DNSB:='8.8.8.8';
                                               DNSdopC:='8.8.4.4';
                                               Application.ProcessMessages;
                                               Form1.Repaint;
                                          end;
  EditDNS1.Text:=DNSA;
  EditDNS2.Text:=DNSB;
  DNSC:=DNSA;
  DNSD:=DNSB;
  EditDNSdop3.Text:=DNSdopC;
  EditDNS3.Text:=DNSA;
  EditDNS4.Text:=DNSB;
  If not FileExists (MyLibDir+Edit_peer.Text+'/route') then Memo_route.Clear;
  if not FileExistsBin('shorewall') then
                                             begin
                                                StartMessage:=false;
                                                CheckBox_shorewall.Checked:=false;
                                                StartMessage:=true;
                                             end;
  If ubuntu or debian or suse then
                begin
                     StartMessage:=false;
                     dhcp_route.Checked:=false;
                     StartMessage:=true;
                end;
  If not FileExists(MyScriptsDir+'dhclient-exit-hooks') then
                begin
                     StartMessage:=false;
                     dhcp_route.Checked:=false;
                     dhcp_route.Enabled:=false;
                     StartMessage:=true;
                end;
  If not FileExists(MyScriptsDir+'dhclient.conf') then
               begin
                     StartMessage:=false;
                     dhcp_route.Checked:=false;
                     dhcp_route.Enabled:=false;
                     StartMessage:=true;
               end;
  GroupBox3.Caption:=GroupBox3.Caption+' '+Edit_peer.Text;
  Application.ProcessMessages;
  Form1.Repaint;
end;

procedure TForm1.Button_next2Click(Sender: TObject);
var
   i:byte;
   j:byte; //точка в написании шлюза
   y:boolean;
   a,b,c,d:string; //a.b.c.d-это шлюз
   x,code:integer;
begin
y:=true;
//проверка корректности ввода сетевого интерфейса
If (Edit_eth.Text='') or (Edit_eth.Text='none') then
                    begin
                         Form3.MyMessageBox(message0,message15,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                         TabSheet2.TabVisible:= True;
                         Application.ProcessMessages;
                         Form1.Repaint;
                         exit;
                    end;
//проверка поддержки mii-tool
If not FileExists(MyLibDir+Edit_peer.Text+'/config') then
                 begin
                      FpSystem ('mii-tool '+Edit_eth.Text+' >'+MyTmpDir+'mii');
                      If FileSize(MyTmpDir+'mii')=0 then
                              begin
                                   StartMessage:=false;
                                   Mii_tool_no.Checked:=true;
                                   StartMessage:=true;
                              end;
                      FpSystem('rm -f '+MyTmpDir+'mii');
                 end;
//восстановление опции показа виджета
IniPropStorage1.IniFileName:=MyLibDir+'ponoff.conf.ini';
IniPropStorage1.IniSection:='TApplication.Widget';
If FileExists(MyLibDir+'ponoff.conf.ini') then If IniPropStorage1.ReadString ('Widget','null')='true' then  Widget.Checked:=true else Widget.Checked:=false;
//wlanN не поддерживается mii-tool
popen(f,'iwconfig '+Edit_eth.Text+'|grep "no wireless extensions"','R');
If not FileExists(MyLibDir+Edit_peer.Text+'/config') then if not eof(f) then
                                                                           begin
                                                                              StartMessage:=false;
                                                                              Mii_tool_no.Checked:=true;
                                                                              StartMessage:=true;
                                                                           end;
pclose(f);
//VmWare не поддерживает mii-tool, получение маршрутов через dhcp при использовании NAT
If not FileExists(MyLibDir+Edit_peer.Text+'/config') then if (Edit_gate.Text=EditDNS3.Text) then
                                                                                 begin
                                                                                   StartMessage:=false;
                                                                                   Mii_tool_no.Checked:=true;
                                                                                   dhcp_route.Checked:=false;
                                                                                   StartMessage:=true;
                                                                                 end;
//проверка корректности ввода шлюза локальной сети
If (Edit_gate.Text='none') or (Edit_gate.Text='') or (Length(Edit_gate.Text)>15) then //15-макс.длина шлюза 255.255.255.255
                    begin
                         Form3.MyMessageBox(message0,message16,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                         Edit_gate.Text:=Memo_gate.Lines[0];
                         If LeftStr(Edit_gate.Text,3)='ppp' then Edit_gate.Text:='none';
                         Application.ProcessMessages;
                         Form1.Repaint;
                         exit;
                    end;
j:=0;
a:=''; b:=''; c:=''; d:='';
y:=false;
For i:=1 to Length (Edit_gate.Text) do //символьная строка шлюза разбивается на октеты (или квадранты)
    begin
      if j=0 then if Edit_gate.Text[i]<>'.' then a:=a+Edit_gate.Text[i];
      if j=1 then if Edit_gate.Text[i]<>'.' then b:=b+Edit_gate.Text[i];
      if j=2 then if Edit_gate.Text[i]<>'.' then c:=c+Edit_gate.Text[i];
      if j=3 then if Edit_gate.Text[i]<>'.' then d:=d+Edit_gate.Text[i];
      if Edit_gate.Text[i]='.' then j:=j+1;
    end;
If (j>3) or (Length(a)>3) or (Length(b)>3) or (Length(c)>3) or (Length(d)>3)
or (a='') or (b='') or (c='') or (d='') then y:=true;
//проверка на то, а все ли цифры, нет ли букв и иных символов
Val(a,x,code);
if code<>0 then y:=true;
Val(b,x,code);
if code<>0 then y:=true;
Val(c,x,code);
if code<>0 then y:=true;
Val(d,x,code);
if code<>0 then y:=true;
If y then
         begin
           Form3.MyMessageBox(message0,message16,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
           Edit_gate.Text:=Memo_gate.Lines[0];
           Application.ProcessMessages;
           Form1.Repaint;
           exit;
         end;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
If not ((MyStrToInt(a)>=0) and (MyStrToInt(a)<=255)) then y:=true;
If not ((MyStrToInt(b)>=0) and (MyStrToInt(b)<=255)) then y:=true;
If not ((MyStrToInt(c)>=0) and (MyStrToInt(c)<=255)) then y:=true;
If not ((MyStrToInt(d)>=0) and (MyStrToInt(d)<=255)) then y:=true;
If y then
         begin
           Form3.MyMessageBox(message0,message16,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
           Edit_gate.Text:=Memo_gate.Lines[0];
           Application.ProcessMessages;
           Form1.Repaint;
           exit;
         end;
 Edit_gate.Text:=IntToStr(MyStrToInt(a))+'.'+IntToStr(MyStrToInt(b))+'.'+IntToStr(MyStrToInt(c))+'.'+IntToStr(MyStrToInt(d)); //сократятся лишние нули, введённые в начале любого из октетов (или квадрантов)
//проверка корректности ввода EditDNS3
If Length(EditDNS3.Text)>15 then //15-макс.длина шлюза 255.255.255.255
                    begin
                         Form3.MyMessageBox(message0,message81,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                         EditDNS3.Text:='none';
                         Application.ProcessMessages;
                         Form1.Repaint;
                         exit;
                    end;
j:=0;
a:=''; b:=''; c:=''; d:='';
y:=false;
For i:=1 to Length (EditDNS3.Text) do //символьная строка шлюза разбивается на октеты (или квадранты)
    begin
      if j=0 then if EditDNS3.Text[i]<>'.' then a:=a+EditDNS3.Text[i];
      if j=1 then if EditDNS3.Text[i]<>'.' then b:=b+EditDNS3.Text[i];
      if j=2 then if EditDNS3.Text[i]<>'.' then c:=c+EditDNS3.Text[i];
      if j=3 then if EditDNS3.Text[i]<>'.' then d:=d+EditDNS3.Text[i];
      if EditDNS3.Text[i]='.' then j:=j+1;
    end;
If (j>3) or (Length(a)>3) or (Length(b)>3) or (Length(c)>3) or (Length(d)>3)
or (a='') or (b='') or (c='') or (d='') then y:=true;
//проверка на то, а все ли цифры, нет ли букв и иных символов
if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then
Val(a,x,code);
if code<>0 then y:=true;
Val(b,x,code);
if code<>0 then y:=true;
Val(c,x,code);
if code<>0 then y:=true;
Val(d,x,code);
if code<>0 then y:=true;
If y then if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then
         begin
           Form3.MyMessageBox(message0,message81,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
           EditDNS3.Text:='none';
           Application.ProcessMessages;
           Form1.Repaint;
           exit;
         end;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then
begin
If not ((MyStrToInt(a)>=0) and (MyStrToInt(a)<=255)) then y:=true;
If not ((MyStrToInt(b)>=0) and (MyStrToInt(b)<=255)) then y:=true;
If not ((MyStrToInt(c)>=0) and (MyStrToInt(c)<=255)) then y:=true;
If not ((MyStrToInt(d)>=0) and (MyStrToInt(d)<=255)) then y:=true;
end;
If y then if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then
         begin
           Form3.MyMessageBox(message0,message81,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
           EditDNS3.Text:='none';
           Application.ProcessMessages;
           Form1.Repaint;
           exit;
         end;
if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then EditDNS3.Text:=IntToStr(MyStrToInt(a))+'.'+IntToStr(MyStrToInt(b))+'.'+IntToStr(MyStrToInt(c))+'.'+IntToStr(MyStrToInt(d)); //сократятся лишние нули, введённые в начале любого из октетов (или квадрантов)
//проверка корректности ввода EditDNS4
If Length(EditDNS4.Text)>15 then //15-макс.длина шлюза 255.255.255.255
                    begin
                         Form3.MyMessageBox(message0,message82,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                         EditDNS4.Text:='none';
                         Application.ProcessMessages;
                         Form1.Repaint;
                         exit;
                    end;
j:=0;
a:=''; b:=''; c:=''; d:='';
y:=false;
For i:=1 to Length (EditDNS4.Text) do //символьная строка шлюза разбивается на октеты (или квадранты)
    begin
      if j=0 then if EditDNS4.Text[i]<>'.' then a:=a+EditDNS4.Text[i];
      if j=1 then if EditDNS4.Text[i]<>'.' then b:=b+EditDNS4.Text[i];
      if j=2 then if EditDNS4.Text[i]<>'.' then c:=c+EditDNS4.Text[i];
      if j=3 then if EditDNS4.Text[i]<>'.' then d:=d+EditDNS4.Text[i];
      if EditDNS4.Text[i]='.' then j:=j+1;
    end;
If (j>3) or (Length(a)>3) or (Length(b)>3) or (Length(c)>3) or (Length(d)>3)
or (a='') or (b='') or (c='') or (d='') then y:=true;
//проверка на то, а все ли цифры, нет ли букв и иных символов
if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then
Val(a,x,code);
if code<>0 then y:=true;
Val(b,x,code);
if code<>0 then y:=true;
Val(c,x,code);
if code<>0 then y:=true;
Val(d,x,code);
if code<>0 then y:=true;
If y then if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then
         begin
           Form3.MyMessageBox(message0,message82,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
           EditDNS4.Text:='none';
           Application.ProcessMessages;
           Form1.Repaint;
           exit;
         end;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then
begin
If not ((MyStrToInt(a)>=0) and (MyStrToInt(a)<=255)) then y:=true;
If not ((MyStrToInt(b)>=0) and (MyStrToInt(b)<=255)) then y:=true;
If not ((MyStrToInt(c)>=0) and (MyStrToInt(c)<=255)) then y:=true;
If not ((MyStrToInt(d)>=0) and (MyStrToInt(d)<=255)) then y:=true;
end;
If y then if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then
         begin
           Form3.MyMessageBox(message0,message82,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
           EditDNS4.Text:='none';
           Application.ProcessMessages;
           Form1.Repaint;
           exit;
         end;
Unit2.Form2.Obrabotka(Edit_peer.Text, more, AFont, MyLibDir, EtcPppPeersDir);
if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then EditDNS4.Text:=IntToStr(MyStrToInt(a))+'.'+IntToStr(MyStrToInt(b))+'.'+IntToStr(MyStrToInt(c))+'.'+IntToStr(MyStrToInt(d)); //сократятся лишние нули, введённые в начале любого из октетов (или квадрантов)
If ((EditDNS3.Text='none') or (EditDNS3.Text='')) then if ((EditDNS4.Text='none') or (EditDNS4.Text='')) then
                           begin
                             If not Unit2.Form2.CheckBoxusepeerdns.Checked then
                                                                           begin
                                                                                Form3.MyMessageBox(message0,message206+' '+message83+ ' '+message201+ ' '+message204,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                if (Form3.Tag=3) or (Form3.Tag=0) then exit;
                                                                           end;
                             If Unit2.Form2.CheckBoxusepeerdns.Checked then
                                                                           begin
                                                                                Form3.MyMessageBox(message0,message202+' '+message203,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                if (Form3.Tag=3) or (Form3.Tag=0) then exit;
                                                                           end;
                             Application.ProcessMessages;
                             Form1.Repaint;
                           end;
If EditDNS3.Text='' then EditDNS3.Text:='none';
If EditDNS4.Text='' then EditDNS4.Text:='none';
//проверка ввода mtu, разрешен диапазон [576..1500], рекомендуется 1472
For i:=1 to Length(Edit_mtu.Text) do
begin
   if not (Edit_mtu.Text[i] in ['0'..'9']) then
                                      begin
                                        Form3.MyMessageBox(message0,message17,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                        Edit_mtu.Clear;
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                        exit;
                                      end;
If (MyStrToInt(Edit_mtu.Text)>1500) or (MyStrToInt(Edit_mtu.Text)<576) then
                                      begin
                                        Form3.MyMessageBox(message0,message17,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                        Edit_mtu.Clear;
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                        exit;
                                      end;
end;
//проверка ввода mru, разрешен диапазон [576..1500]
For i:=1 to Length(Edit_mru.Text) do
begin
   If not (Edit_mru.Text[i] in ['0'..'9']) then
                                      begin
                                        Form3.MyMessageBox(message0,message104,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                        Edit_mru.Clear;
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                        exit;
                                      end;
  If (MyStrToInt(Edit_mru.Text)>1500) or (MyStrToInt(Edit_mru.Text)<576) then
                                      begin
                                        Form3.MyMessageBox(message0,message104,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                        Edit_mru.Clear;
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                        exit;
                                      end;
end;
//проверка модуля ppp_mppe
If CheckBox_required.Checked then
                                begin
                                     FpSystem('modprobe -r ppp_mppe');
                                     FpSystem('modprobe ppp_mppe');
                                     popen(f,'lsmod | '+'awk '+chr(39)+'{print $1}'+chr(39)+'|'+'grep ppp_mppe','R');
                                     if eof(f) then
                                                   begin
                                                        Form3.MyMessageBox(message0,message235,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                        //CheckBox_required.Checked:=false; //на будущее
                                                        Application.ProcessMessages;
                                                        Form1.Repaint;
                                                   end;
                                     pclose(f);
                                end;
Unit2.Form2.Obrabotka(Edit_peer.Text, more, AFont, MyLibDir, EtcPppPeersDir);
If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then
                               begin
                                   nobuffer.Enabled:=false;
                                   nobuffer.Checked:=true;
                               end;
If Edit_mtu.Text<>'' then if (MyStrToInt(Edit_mtu.Text)>1472) then
                                      begin
                                        Form3.MyMessageBox(message0,message118+' '+message120,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                        if (Form3.Tag=3) or (Form3.Tag=0) then begin Application.ProcessMessages; Form1.Repaint; exit; end;
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                      end;
If ((Edit_mtu.Text='') or (Edit_mru.Text='')) then If Unit2.Form2.CheckBoxdefaultmru.Checked then
                                      begin
                                        Form3.MyMessageBox(message0,message117+' '+message118+' '+message120,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                        if (Form3.Tag=3) or (Form3.Tag=0) then begin Application.ProcessMessages; Form1.Repaint; exit; end;
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                      end;
 If ComboBoxVPN.Text='VPN PPTP' then Reconnect_pptp.Hint:=MakeHint(message31+' '+message212,6);
 Button_more.Visible:=True;
 Button_create.Visible:=True;
 TabSheet1.TabVisible:= False;
 TabSheet2.TabVisible:= False;
 TabSheet3.TabVisible:= True;
 Button_next2.Visible:=False;
 ButtonHelp.Visible:=false;
 x:=x+0;
end;

procedure TForm1.CheckBox_no128Change(Sender: TObject);
begin
   If CheckBox_no128.Checked then CheckBox_required.Checked:=true;
   //проверка корректности задания шифрования mppe
   If (CheckBox_required.Checked) and (CheckBox_no40.Checked) and (CheckBox_no56.Checked) and (CheckBox_no128.Checked) then
                                                              begin
                                                                   Form3.MyMessageBox(message0,message232,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                   CheckBox_no128.Checked:=false;
                                                                   Application.ProcessMessages;
                                                                   Form1.Repaint;
                                                                   exit;
                                                              end;
end;

procedure TForm1.CheckBox_no40Change(Sender: TObject);
begin
    If CheckBox_no40.Checked then CheckBox_required.Checked:=true;
    //проверка корректности задания шифрования mppe
    If (CheckBox_required.Checked) and (CheckBox_no40.Checked) and (CheckBox_no56.Checked) and (CheckBox_no128.Checked) then
                                                               begin
                                                                    Form3.MyMessageBox(message0,message232,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                    CheckBox_no40.Checked:=false;
                                                                    Application.ProcessMessages;
                                                                    Form1.Repaint;
                                                                    exit;
                                                               end;
end;

procedure TForm1.CheckBox_no56Change(Sender: TObject);
begin
    If CheckBox_no56.Checked then If CheckBox_no56.Visible then CheckBox_required.Checked:=true;
    //проверка корректности задания шифрования mppe
    If (CheckBox_required.Checked) and (CheckBox_no40.Checked) and (CheckBox_no56.Checked) and (CheckBox_no128.Checked) then
                                                               begin
                                                                    Form3.MyMessageBox(message0,message232,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                    CheckBox_no56.Checked:=false;
                                                                    Application.ProcessMessages;
                                                                    Form1.Repaint;
                                                                    exit;
                                                               end;
end;

procedure TForm1.CheckBox_rchapChange(Sender: TObject);
begin
  If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
            begin
              If StartMessage then Form3.MyMessageBox(message0,message230,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
              CheckBox_rchap.Checked:=false;
              CheckBox_reap.Checked:=false;
              CheckBox_rmschap.Checked:=false;
              CheckBox_rpap.Checked:=false;
              CheckBox_rmschapv2.Checked:=false;
              Application.ProcessMessages;
              Form1.Repaint;
            end;
end;

procedure TForm1.CheckBox_reapChange(Sender: TObject);
begin
  If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
            begin
              If StartMessage then Form3.MyMessageBox(message0,message230,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
              CheckBox_rchap.Checked:=false;
              CheckBox_reap.Checked:=false;
              CheckBox_rmschap.Checked:=false;
              CheckBox_rpap.Checked:=false;
              CheckBox_rmschapv2.Checked:=false;
              Application.ProcessMessages;
              Form1.Repaint;
            end;
end;

procedure TForm1.CheckBox_requiredChange(Sender: TObject);
begin
   If not CheckBox_required.Checked then
                  begin
                      CheckBox_stateless.Checked:=false;
                      CheckBox_no40.Checked:=false;
                      If CheckBox_no56.Visible then CheckBox_no56.Checked:=false;
                      CheckBox_no128.Checked:=false;
                  end;
   If CheckBox_rmschapv2.Checked then If CheckBox_rmschap.Checked then If CheckBox_required.Checked then
                                                                  begin
                                                                       If StartMessage then Form3.MyMessageBox(message0,message229+' '+message231,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                       CheckBox_required.Checked:=false;
                                                                       Application.ProcessMessages;
                                                                       Form1.Repaint;
                                                                  end;
end;

procedure TForm1.CheckBox_rmschapChange(Sender: TObject);
begin
   If CheckBox_rmschapv2.Checked then If CheckBox_rmschap.Checked then If CheckBox_required.Checked then
                                                                   begin
                                                                        If StartMessage then Form3.MyMessageBox(message0,message229+' '+message231,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                        CheckBox_rmschap.Checked:=false;
                                                                        Application.ProcessMessages;
                                                                        Form1.Repaint;
                                                                   end;
   If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
             begin
               If StartMessage then Form3.MyMessageBox(message0,message230,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
               CheckBox_rchap.Checked:=false;
               CheckBox_reap.Checked:=false;
               CheckBox_rmschap.Checked:=false;
               CheckBox_rpap.Checked:=false;
               CheckBox_rmschapv2.Checked:=false;
               Application.ProcessMessages;
               Form1.Repaint;
             end;
end;

procedure TForm1.CheckBox_rmschapv2Change(Sender: TObject);
begin
   If CheckBox_rmschapv2.Checked then If CheckBox_rmschap.Checked then If CheckBox_required.Checked then
                                                                   begin
                                                                        If StartMessage then Form3.MyMessageBox(message0,message229+' '+message231,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                        CheckBox_rmschapv2.Checked:=false;
                                                                        Application.ProcessMessages;
                                                                        Form1.Repaint;
                                                                   end;
   If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
             begin
               If StartMessage then Form3.MyMessageBox(message0,message230,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
               CheckBox_rchap.Checked:=false;
               CheckBox_reap.Checked:=false;
               CheckBox_rmschap.Checked:=false;
               CheckBox_rpap.Checked:=false;
               CheckBox_rmschapv2.Checked:=false;
               Application.ProcessMessages;
               Form1.Repaint;
             end;
end;

procedure TForm1.CheckBox_rpapChange(Sender: TObject);
begin
   If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
             begin
               If StartMessage then Form3.MyMessageBox(message0,message230,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
               CheckBox_rchap.Checked:=false;
               CheckBox_reap.Checked:=false;
               CheckBox_rmschap.Checked:=false;
               CheckBox_rpap.Checked:=false;
               CheckBox_rmschapv2.Checked:=false;
               Application.ProcessMessages;
               Form1.Repaint;
             end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
    len:integer;
    str, str1:string;
    nostart:boolean;
    PeabodyIpUp, PeabodyIpDown:boolean;
    DopParam:string;
begin
  First_Label1:=Label1.Caption;
  Label1.Caption:=Label1.Caption+' '+message99;
  Application.CreateForm(TForm3, Form3);
 //проверка vpnpptp в процессах root, исключение запуска под иными пользователями
  If not ProgrammRoot('vpnpptp',false) then nostart:=true else nostart:=false;
  DopParam:=' ';
  If ParamStr(1)<>'' then DopParam:=DopParam+ParamStr(1)+' ';
  If DopParam=' ' then DopParam:='';
  If DopParam<>'' then DopParam:=LeftStr(DopParam,Length(DopParam)-1);
  If nostart then If FileExists('/usr/bin/xroot') then If FileExists(Paramstr(0)) then //запускаем vpnpptp с правами root через xroot
          begin
               AProcess := TAsyncProcess.Create(nil);
               AProcess.CommandLine :='/usr/bin/xroot '+'"'+Paramstr(0)+DopParam+'" auto_su_sudo';
               AProcess.Execute;
               while AProcess.Running do
               begin
                   ProgrammRoot('vpnpptp',true);
                   sleep(100);
               end;
               Application.ProcessMessages;
               AProcess.Free;
          end;
  If nostart then If FileExists('/usr/lib64/kde4/libexec/kdesu') then If FileExists(Paramstr(0)) then //запускаем vpnpptp с правами root через kdesu
          begin
               AProcess := TAsyncProcess.Create(nil);
               AProcess.CommandLine :='/usr/lib64/kde4/libexec/kdesu -c '+'"'+Paramstr(0)+DopParam+'"'+' -d --noignorebutton';
               AProcess.Execute;
               while AProcess.Running do
               begin
                   ProgrammRoot('vpnpptp',true);
                   sleep(100);
               end;
               Application.ProcessMessages;
               AProcess.Free;
          end;
  If nostart then If FileExists('/usr/lib/kde4/libexec/kdesu') then If FileExists(Paramstr(0)) then //запускаем vpnpptp с правами root через kdesu
             begin
                  AProcess := TAsyncProcess.Create(nil);
                  AProcess.CommandLine :='/usr/lib/kde4/libexec/kdesu -c '+'"'+Paramstr(0)+DopParam+'"'+' -d --noignorebutton';
                  AProcess.Execute;
                  while AProcess.Running do
                  begin
                      ProgrammRoot('vpnpptp',true);
                      sleep(100);
                  end;
                  Application.ProcessMessages;
                  AProcess.Free;
             end;
  If nostart then If FileExistsBin('beesu') then If FileExists(Paramstr(0)) then //запускаем vpnpptp с правами root через beesu
         begin
              AProcess := TAsyncProcess.Create(nil);
              AProcess.CommandLine :='beesu - '+'"'+Paramstr(0)+DopParam+'"';
              AProcess.Execute;
              while AProcess.Running do
              begin
                  ProgrammRoot('vpnpptp',true);
                  sleep(100);
              end;
              Application.ProcessMessages;
              AProcess.Free;
         end;
  If nostart then If FileExistsBin('gksu') then If FileExists(Paramstr(0)) then //запускаем vpnpptp с правами root через gksu
             begin
                  AProcess := TAsyncProcess.Create(nil);
                  AProcess.CommandLine :='gksu -g -u root '+'"'+Paramstr(0)+DopParam+'"'+' -m "'+message226+'"';
                  AProcess.Execute;
                  while AProcess.Running do
                  begin
                      ProgrammRoot('vpnpptp',true);
                      sleep(100);
                  end;
                  Application.ProcessMessages;
                  AProcess.Free;
             end;
  If not ProgrammRoot('vpnpptp',false) then
     If (not FileExists('/usr/bin/xroot')) and (not FileExists('/usr/lib64/kde4/libexec/kdesu')) and (not FileExists('/usr/lib/kde4/libexec/kdesu'))
          and (not FileExistsBin('beesu')) and (not FileExistsBin('gksu')) then
                begin
                    Form3.MyMessageBox(message0,message228,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                    Application.ProcessMessages;
                    Form1.Repaint;
                end;
  If not ProgrammRoot('vpnpptp',false) then
                begin
                    If mageia then Form3.MyMessageBox(message0,message18+' '+message107,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir)
                                          else Form3.MyMessageBox(message0,message18,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                    Application.ProcessMessages;
                    Form1.Repaint;
                    halt;
                end;
Screen.HintFont.Size:=30;
Screen.MenuFont.Size:=30;
if FileSize(MyLibDir+'profiles')=0 then FpSystem ('rm -f '+MyLibDir+'profiles');
if FileSize(MyLibDir+'default/default')=0 then FpSystem ('rm -f '+MyLibDir+'default/default');
ubuntu:=false;
debian:=false;
fedora:=false;
suse:=false;
mageia:=false;
ProfileForDelete:='';
Delete.Caption:=message182;
Delete.Enabled:=false;
If FileExistsBin ('service') then ServiceCommand:='service ' else ServiceCommand:='systemctl ';
//определение дистрибутива
popen (f,'cat '+EtcDir+'issue|'+'grep Ubuntu','R');
If not eof(f) then ubuntu:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep Debian','R');
If not eof(f) then debian:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep Fedora','R');
If not eof(f) then fedora:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep RFRemix','R');
If not eof(f) then fedora:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep openSUSE','R');
If not eof(f) then suse:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue| '+'grep Mageia','R');
If not eof(f) then mageia:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep PCLinuxOS','R');
If not eof(f) then mageia:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep MagOS','R');
If not eof(f) then mageia:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep ROSA','R');
If not eof(f) then mageia:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep Kubuntu','R');
If not eof(f) then ubuntu:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep Mint','R');
If not eof(f) then ubuntu:=true;
PClose(f);
popen (f,'cat '+EtcDir+'issue|'+'grep BackTrack','R');
If not eof(f) then ubuntu:=true;
PClose(f);
ComboBoxDistr.Text:=message151;
ComboBoxDistr.Items.Add('Mageia '+message150);
ComboBoxDistr.Items.Add('Ubuntu '+message150);
ComboBoxDistr.Items.Add('Debian '+message150);
ComboBoxDistr.Items.Add('Fedora '+message150);
ComboBoxDistr.Items.Add('openSUSE '+message150);
PressCreate:=false;
//присваивание хинтов элементам формы и их настройка
HintWindowClass := TMyHintWindow;
Application.HintColor:=$0092FFF8;
Application.ShowHint := True;
Widget.Hint:=MakeHint(message227,5);
TabSheet1.Hint:=MakeHint(message143+' '+message149,5);
TabSheet2.Hint:=MakeHint(message143+' '+message149,5);
TabSheet3.Hint:=MakeHint(message143+' '+message149,5);
Form1.Hint:=MakeHint(message143+' '+message149,5);
Label1.Hint:=MakeHint(message143+' '+message149,5);
Label_IPS.Hint:=MakeHint(message143+' '+message149,5);
Label2.Hint:=MakeHint(message143+' '+message149,5);
Label_peer.Hint:=MakeHint(message143+' '+message149,5);
Label3.Hint:=MakeHint(message143+' '+message149,5);
Label_user.Hint:=MakeHint(message143+' '+message149,5);
Label4.Hint:=MakeHint(message143+' '+message149,5);
Label_pswd.Hint:=MakeHint(message143+' '+message149,5);
Label36.Hint:=MakeHint(message143+' '+message149,5);
Label35.Hint:=MakeHint(message143+' '+message149,5);
Label38.Hint:=MakeHint(message143+' '+message149,5);
Label40.Hint:=MakeHint(message143+' '+message149,5);
Label6.Hint:=MakeHint(message143+' '+message149,5);
Label8.Hint:=MakeHint(message143+' '+message149,5);
Label7.Hint:=MakeHint(message143+' '+message149,5);
Label11.Hint:=MakeHint(message143+' '+message149,5);
Label37.Hint:=MakeHint(message143+' '+message149,5);
Label39.Hint:=MakeHint(message143+' '+message149,5);
Label41.Hint:=MakeHint(message143+' '+message149,5);
Label25.Hint:=MakeHint(message143+' '+message149,5);
Label_gate.Hint:=MakeHint(message143+' '+message149,5);
LabelDNS1.Hint:=MakeHint(message143+' '+message149,5);
LabelDNS2.Hint:=MakeHint(message143+' '+message149,5);
LabelDNS3.Hint:=MakeHint(message143+' '+message149,5);
LabelDNS4.Hint:=MakeHint(message143+' '+message149,5);
Label_mtu.Hint:=MakeHint(message143+' '+message149,5);
Label_mru.Hint:=MakeHint(message143+' '+message149,5);
Label_route.Hint:=MakeHint(message143+' '+message149,5);
Label10.Hint:=MakeHint(message143+' '+message149,5);
Label5.Hint:=MakeHint(message143+' '+message149,5);
Label9.Hint:=MakeHint(message143+' '+message149,5);
Label13.Hint:=MakeHint(message143+' '+message149,5);
Label12.Hint:=MakeHint(message143+' '+message149,5);
Label45.Hint:=MakeHint(message143+' '+message149,5);
Label46.Hint:=MakeHint(message143+' '+message149,5);
Label47.Hint:=MakeHint(message143+' '+message149,5);
Label14.Hint:=MakeHint(message143+' '+message149,5);
Label42.Hint:=MakeHint(message143+' '+message149,5);
Label43.Hint:=MakeHint(message143+' '+message149,5);
Label44.Hint:=MakeHint(message143+' '+message149,5);
Edit_IPS.Hint:=MakeHint(message1,7);
ButtonVPN.Hint:=ButtonVPN.Caption;
Edit_peer.Hint:=MakeHint(message1,7);
ButtonRestart.Hint:=message93;
Edit_user.Hint:=MakeHint(message1,7);
ComboBoxVPN.Hint:=message126;
ComboBoxDistr.Hint:=MakeHint(message97+' '+message152,5);
Edit_passwd.Hint:=MakeHint(message1,7);
ButtonHidePass.Hint:=message86+' / '+message87;
Edit_MaxTime.Hint:=MakeHint(message8,8);
Edit_MinTime.Hint:=MakeHint(message10+' '+message154,8);
Button_exit.Hint:=MakeHint(message134,6);
Button_next1.Hint:=message133;
Button_next2.Hint:=message133;
Button_create.Hint:=MakeHint(message135,3);
Button_more.Hint:=MakeHint(message136,4);
ButtonHelp.Hint:=MakeHint(message132,6);
ButtonTest.Hint:=MakeHint(message137,4);
Edit_eth.Hint:=MakeHint(message131,5);
Edit_gate.Hint:=MakeHint(message130,5);
EditDNS1.Hint:=MakeHint(message130,7);
EditDNS2.Hint:=MakeHint(message130,7);
EditDNS3.Hint:=MakeHint(message130+' '+message211+' '+message196,6);
EditDNS4.Hint:=MakeHint(message130+' '+message211+' '+message196,6);
Edit_mtu.Hint:=MakeHint(message129,5);
Edit_mru.Hint:=MakeHint(message129,5);
Memo_route.Hint:=MakeHint((LeftStr(Label_route.Caption,Length(Label_route.Caption)-1)+'. '+message128),5);
ChecKBox_desktop.Hint:=ChecKBox_desktop.Caption;
CheckBox_rchap.Hint:=MakeHint(message58+' '+message55,6);
CheckBox_reap.Hint:=MakeHint(message70+' '+message55,6);
CheckBox_rmschap.Hint:=MakeHint(message72+' '+message55,6);
CheckBox_rpap.Hint:=MakeHint(message77+' '+message55,6);
CheckBox_rmschapv2.Hint:=MakeHint(message78+' '+message55,6);
CheckBox_required.Hint:=MakeHint(message79+' '+message88+' '+message233,6);
CheckBox_stateless.Hint:=MakeHint(message89+' '+message88+' '+message233,6);
CheckBox_no40.Hint:=MakeHint(message90+' '+message88+' '+message233,6);
CheckBox_no56.Hint:=MakeHint(message91+' '+message88+' '+message233,6);
CheckBox_no128.Hint:=MakeHint(message92+' '+message88+' '+message233,6);
Mii_tool_no.Hint:=MakeHint(message30,6);
Reconnect_pptp.Hint:=MakeHint(message31+' '+message212+' '+message106,7);
Pppd_log.Hint:=MakeHint(message32,5);
dhcp_route.Hint:=MakeHint(message33+' '+message35,6);
CheckBox_shorewall.Hint:=MakeHint(message34+' '+message36,6);
routevpnauto.Hint:=MakeHint(message37,7);
etc_hosts.Hint:=MakeHint(message112+' '+message113,7);
routeDNSauto.Hint:=MakeHint(message71,7);
networktest.Hint:=MakeHint(message38+' '+message39,6);
balloon.Hint:=MakeHint(message40,7);
Sudo_ponoff.Hint:=MakeHint(message56,7);
Sudo_configure.Hint:=MakeHint(message9,7);
Autostart_ponoff.Hint:=MakeHint(message21,6);
Autostartpppd.Hint:=MakeHint(message62+' '+message218,6);
pppnotdefault.Hint:=MakeHint(message64,6);
Memo_create.Hint:=MakeHint(message127,5);
nobuffer.Hint:=MakeHint(message155+' '+message156+' '+message157,6);
route_IP_remote.Hint:=MakeHint(message165+' '+message166+' '+message167,7);
Delete.Hint:=MakeHint(message183,5);
GroupBox3.Hint:=MakeHint(message51,5);
GroupBox2.Hint:=MakeHint(message188,5);
GroupBox1.Hint:=MakeHint(message189,5);
ButtonHidePass.Caption:=message86;
ButtonRestart.Caption:=message93;
StartMessage:=false;
more:=false;
EditDNS1.Text:='none';
EditDNS2.Text:='none';
EditDNSdop3.Text:='none';
EditDNS3.Text:='none';
EditDNS4.Text:='none';
DNSA:='none';
DNSB:='none';
DNSdopC:='none';
DNSC:='none';
DNSD:='none';
ButtonHelp.Visible:=true;
ButtonHelp.Enabled:=false;
PageControl1.ShowTabs:=false;
//масштабирование формы в зависимости от разрешения экрана
   Form1.Position:=poScreenCenter;
   If Screen.Height<440 then
                            begin
                             AFont:=6;
                             Form1.Font.Size:=AFont;
                             ComboBoxVPN.Font.Size:=AFont;
                             ComboBoxDistr.Font.Size:=AFont;
                             Form1.Height:=Screen.Height-50;
                             Form1.Width:=Screen.Width;
                            end;
   If Screen.Height<=480 then
                        begin
                             AFont:=6;
                             Form1.Font.Size:=AFont;
                             ComboBoxVPN.Font.Size:=AFont;
                             ComboBoxDistr.Font.Size:=AFont;
                             Form1.Height:=Screen.Height-45;
                             Form1.Width:=Screen.Width;
                        end;
   If Screen.Height<550 then If not (Screen.Height<=480) then
                         begin
                             AFont:=6;
                             Form1.Font.Size:=AFont;
                             ComboBoxVPN.Font.Size:=AFont;
                             ComboBoxDistr.Font.Size:=AFont;
                         end;
   If Screen.Height>550 then   //разрешение в основном нетбуков
                        begin
                             AFont:=8;
                             Form1.Font.Size:=AFont;
                             ComboBoxVPN.Font.Size:=AFont;
                             ComboBoxDistr.Font.Size:=AFont;
                             Form1.Height:=550;
                             Form1.Width:=794;
                        end;
   If Screen.Height>1000 then
                        begin
                             AFont:=10;
                             Form1.Font.Size:=AFont;
                             ComboBoxVPN.Font.Size:=AFont;
                             ComboBoxDistr.Font.Size:=AFont;
                             Form1.Height:=700;
                             Form1.Width:=1020;
                         end;
 CheckFiles;//проверка наличия необходимых программе файлов
 //проверка использовался ли скрипт mr. Peabody
 PeabodyIpUp:=false;
 PeabodyIpDown:=false;
 popen (f,'cat '+EtcPppDir+'ip-up|'+'grep '+EtcPppIpUpDDir+chr(39)+'$6 $1 $2 $3 $4 $5 $6'+chr(39),'R');
 If not eof(f) then PeabodyIpUp:=true;
 PClose(f);
 popen (f,'cat '+EtcPppDir+'ip-down|'+'grep '+EtcPppIpDownDDir+chr(39)+'$6 $1 $2 $3 $4 $5 $6'+chr(39),'R');
 If not eof(f) then PeabodyIpDown:=true;
 PClose(f);
 If PeabodyIpUp and PeabodyIpDown then
                                      begin
                                          Form3.MyMessageBox(message0,message193+' '+EtcPppDir+'ip-up'+'. '+message194+' '+message193+' '+EtcPppDir+'ip-down'+'. '+message194+' '+message195,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                          halt;
                                      end;
 If PeabodyIpUp then
                  begin
                     Form3.MyMessageBox(message0,message193+' '+EtcPppDir+'ip-up'+'. '+message194+' '+message195,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                     halt;
                  end;
 If PeabodyIpDown then
                  begin
                     Form3.MyMessageBox(message0,message193+' '+EtcPppDir+'ip-down'+'. '+message194+' '+message195,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                     halt;
                  end;
 //проверка зависимостей-плагинов
 If not FileExistsBin('pptp') then if not FileExistsBin ('xl2tpd') then if not FileExistsBin ('openl2tpd') then
                                    begin
                                       Form3.MyMessageBox(message0,message95,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                       halt;
                                    end;
  If not FileExists(MyTmpDir) then begin FpSystem ('mkdir -p '+MyTmpDir);FpSystem ('chmod 777 '+MyTmpDir);end;
 CountInterface:=1;
 DoCountInterface;
 //обеспечение совместимости старого general.conf с новым
  If FileExists(MyLibDir+'general.conf') then
      begin
         Memo_config.Lines.LoadFromFile(MyLibDir+'general.conf');
         If Memo_config.Lines.Count<General_conf_n then
                                             begin
                                                for i:=Memo_config.Lines.Count to General_conf_n do
                                                   FpSystem('printf "none\n" >> '+MyLibDir+'general.conf');
                                             end;
      end;
  //восстановление предыдущих введённых данных в конфигураторе (general.conf)
   If FileExists(MyLibDir+'general.conf') then
       begin
          Memo_config.Lines.LoadFromFile(MyLibDir+'general.conf');
          If Memo_config.Lines[0]='shorewall-yes' then CheckBox_shorewall.Checked:=true else CheckBox_shorewall.Checked:=false;
          If Memo_config.Lines[1]='sudo-yes' then Sudo_ponoff.Checked:=true else Sudo_ponoff.Checked:=false;
          If Memo_config.Lines[2]='sudo-configure-yes' then Sudo_configure.Checked:=true else Sudo_configure.Checked:=false;
          If Memo_config.Lines[3]<>'none' then AFont:=MyStrToInt(Memo_config.Lines[3]);
          If Memo_config.Lines[4]='ubuntu' then ComboBoxDistr.Text:='Ubuntu '+message150;
          If Memo_config.Lines[4]='debian' then ComboBoxDistr.Text:='Debian '+message150;
          If Memo_config.Lines[4]='fedora' then ComboBoxDistr.Text:='Fedora '+message150;
          If Memo_config.Lines[4]='suse' then ComboBoxDistr.Text:='openSUSE '+message150;
          If Memo_config.Lines[4]='mageia' then ComboBoxDistr.Text:='Mageia '+message150;
          If Memo_config.Lines[4]='none' then
                                               begin
                                                  If ubuntu then ComboBoxDistr.Text:='Ubuntu '+message150;
                                                  If debian then ComboBoxDistr.Text:='Debian '+message150;
                                                  If fedora then ComboBoxDistr.Text:='Fedora '+message150;
                                                  If suse then ComboBoxDistr.Text:='openSUSE '+message150;
                                                  If mageia then ComboBoxDistr.Text:='Mageia '+message150;
                                               end;
       end;
   If not FileExists(MyLibDir+'general.conf') then
                                            begin
                                                 If ubuntu then ComboBoxDistr.Text:='Ubuntu '+message150;
                                                 If debian then ComboBoxDistr.Text:='Debian '+message150;
                                                 If fedora then ComboBoxDistr.Text:='Fedora '+message150;
                                                 If suse then ComboBoxDistr.Text:='openSUSE '+message150;
                                                 If mageia then ComboBoxDistr.Text:='Mageia '+message150;
                                            end;
 //определяем произошел ли запуск при поднятом pppN
   FpSystem('ip r|'+'grep ppp > '+MyTmpDir+'gate');
   If FileExists (MyTmpDir+'gate') then if FileSize(MyTmpDir+'gate')<>0 then
                                          begin
                                            Form3.MyMessageBox(message0,message105,'',message122,message125,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,false,MyLibDir);
                                            if (Form3.Tag=3) or (Form3.Tag=0) then begin Application.ProcessMessages; Form1.Repaint; halt; end;
                                            Application.ProcessMessages;
                                            Form1.Repaint;
                                            FpSystem('killall ponoff');
                                            If FileExists(MyLibDir+'default/openl2tp-stop') then FpSystem('bash '+MyLibDir+'default/openl2tp-stop');
                                            FpSystem('killall pppd');
                                            If ServiceCommand='systemctl ' then FpSystem(ServiceCommand+'stop xl2tpd.service') else FpSystem(ServiceCommand+'xl2tpd stop');
                                            FpSystem('killall xl2tpd');
                                            FpSystem('killall openl2tpd');
                                            FpSystem('killall openl2tp');
                                            FpSystem('killall l2tpd');
                                            ButtonRestartClick(Sender);
                                            Sleep(3000);
                                            if ComboBoxDistr.Text<>message151 then ComboBoxDistr.Enabled:=false;
                                          end;
 FpSystem ('killall ponoff');
 If FileExists(MyLibDir+'default/openl2tp-stop') then FpSystem('bash '+MyLibDir+'default/openl2tp-stop');
 FpSystem ('killall pppd');
 If ServiceCommand='systemctl ' then FpSystem(ServiceCommand+'stop xl2tpd.service') else FpSystem(ServiceCommand+'xl2tpd stop');
 FpSystem ('killall xl2tpd');
 FpSystem ('killall openl2tpd');
 FpSystem ('killall openl2tp');
 FpSystem ('killall l2tpd');
 FpSystem ('rm -f '+MyTmpDir+'ObnullRX');
 FpSystem ('rm -f '+MyTmpDir+'ObnullTX');
 FpSystem ('rm -f '+MyTmpDir+'DateStart');
 FpSystem ('rm -f '+MyTmpDir+'gate');
 //проверка vpnpptp в процессах root, исключение двойного запуска программы
 FpSystem('ps -u root | '+'grep vpnpptp | '+'awk '+chr(39)+'{print $4}'+chr(39)+' > '+MyTmpDir+'tmpnostart');
 FpSystem('printf "none" >> '+MyTmpDir+'tmpnostart');
 Form1.tmpnostart.Clear;
 If FileExists(MyTmpDir+'tmpnostart') then tmpnostart.Lines.LoadFromFile(MyTmpDir+'tmpnostart');
 FpSystem('rm -f '+MyTmpDir+'tmpnostart');
 If (LeftStr(tmpnostart.Lines[0],7)='vpnpptp') and (LeftStr(tmpnostart.Lines[0],13)<>'vpnpptp_setup') then if (LeftStr(tmpnostart.Lines[1],7)='vpnpptp') and (LeftStr(tmpnostart.Lines[1],13)<>'vpnpptp_setup') then
                                                                                                     begin
                                                                                                       //двойной запуск
                                                                                                       Form3.MyMessageBox(message0,message19,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                                                                       FpSystem('rm -f '+MyTmpDir+'tmpnostart');
                                                                                                       Application.ProcessMessages;
                                                                                                       Form1.Repaint;
                                                                                                       halt;
                                                                                                     end;
 //подсказка о желательности параметра приложению
 If ProfileName='' then If FileExists(MyLibDir+'profiles') then
                             begin
                                    Form3.MyMessageBox(message0,message172+' '+message173,'',message122,message187,MyPixmapsDir+'vpnpptp.png',false,true,true,AFont,Form1.Icon,true,MyLibDir);
                                    If Form3.Tag=2 then If Form3.ComboBoxProfile.Text<>'' then ProfileName:=Form3.ComboBoxProfile.Text;
                                    If Form3.Tag=0 then halt;
                             end;
 //проверка существования соединения
 str:=ProfileName;
 str:=UTF8UpperCase(str);
 if Length(str)>=3 then str1:=LeftStr(str,3);
 if (str='DEFAULT') or (str='VPNMCC') or (str1='PPP') then
                       begin
                          Form3.MyMessageBox(message0,message169+' '+ProfileName+', '+message186,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          Application.ProcessMessages;
                          Form1.Repaint;
                          halt;
                       end;
   If not FileExists(MyLibDir+ProfileName+'/config') then If ProfileName<>'' then
                            begin
                                 Form3.MyMessageBox(message0,message170+' '+ProfileName+' '+message171+' '+ProfileName+'.','','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                 Edit_peer.Text:=ProfileName;
                            end;
//обеспечение совместимости старого config с новым
 If FileExists(MyLibDir+ProfileName+'/config') then
     begin
        Memo_config.Lines.LoadFromFile(MyLibDir+ProfileName+'/config');
        If Memo_config.Lines.Count<Config_n then
                                            begin
                                               for i:=Memo_config.Lines.Count to Config_n do
                                                  FpSystem('printf "none\n" >> '+MyLibDir+ProfileName+'/config');
                                            end;
     end;
 //восстановление предыдущих введённых данных в конфигураторе (config)
 If FileExists(MyLibDir+ProfileName+'/config') then
     begin
        Delete.Enabled:=true;
        Memo_config.Lines.LoadFromFile(MyLibDir+ProfileName+'/config');
        Edit_peer.Text:=Memo_config.Lines[0];
        ProfileForDelete:=Memo_config.Lines[0];
        Edit_IPS.Text:=Memo_config.Lines[1];
        len:=Length(Memo_config.Lines[4]);
        If Memo_config.Lines[4]<>'0' then Edit_MinTime.Text:=LeftStr(Memo_config.Lines[4],len-3);
        If Memo_config.Lines[4]='0' then Edit_MinTime.Text:=Memo_config.Lines[4];
        len:=Length(Memo_config.Lines[5]);
        Edit_MaxTime.Text:=LeftStr(Memo_config.Lines[5],len-3);
        If Memo_config.Lines[6]='mii-tool-yes' then Mii_tool_no.Checked:=false else Mii_tool_no.Checked:=true;
        If Memo_config.Lines[7]='noreconnect-pptp' then Reconnect_pptp.Checked:=false else Reconnect_pptp.Checked:=true;
        If Memo_config.Lines[8]='pppd-log-yes' then Pppd_log.Checked:=true else Pppd_log.Checked:=false;
        If Memo_config.Lines[9]='dhcp-route-yes' then dhcp_route.Checked:=true else dhcp_route.Checked:=false;
        Edit_mtu.Text:=Memo_config.Lines[10];
        If Edit_mtu.Text='mtu-none' then Edit_mtu.Text:='';
        If Memo_config.Lines[11]='required-yes' then CheckBox_required.Checked:= true else CheckBox_required.Checked:=false;
        If Memo_config.Lines[11]='shifr-yes' then CheckBox_required.Checked:=true;
        If Memo_config.Lines[12]='rchap-yes' then CheckBox_rchap.Checked:=true else CheckBox_rchap.Checked:=false;
        If Memo_config.Lines[13]='reap-yes' then CheckBox_reap.Checked:=true else CheckBox_reap.Checked:=false;
        If Memo_config.Lines[14]='rmschap-yes' then CheckBox_rmschap.Checked:=true else CheckBox_rmschap.Checked:=false;
        If Memo_config.Lines[15]='stateless-yes' then CheckBox_stateless.Checked:=true else CheckBox_stateless.Checked:=false;
        If Memo_config.Lines[16]='no40-yes' then CheckBox_no40.Checked:=true else CheckBox_no40.Checked:=false;
        If Memo_config.Lines[17]='no56-yes' then CheckBox_no56.Checked:=true else CheckBox_no56.Checked:=false;
        If Memo_config.Lines[19]='link-desktop-yes' then CheckBox_desktop.Checked:=true else CheckBox_desktop.Checked:=false;
        If Memo_config.Lines[20]='no128-yes' then CheckBox_no128.Checked:=true else CheckBox_no128.Checked:=false;
        If Memo_config.Lines[21]='IPS-yes' then IPS:=true else IPS:=false;
        If Memo_config.Lines[22]='routevpnauto-yes' then routevpnauto.Checked:=true else routevpnauto.Checked:=false;
        If Memo_config.Lines[23]='networktest-yes' then networktest.Checked:=true else networktest.Checked:=false;
        If Memo_config.Lines[24]='balloon-yes' then balloon.Checked:=true else balloon.Checked:=false;
        If Memo_config.Lines[27]='autostart-ponoff-yes' then Autostart_ponoff.Checked:=true else Autostart_ponoff.Checked:=false;
        If Memo_config.Lines[28]='autostart-pppd-yes' then Autostartpppd.Checked:=true else Autostartpppd.Checked:=false;
        If Memo_config.Lines[29]='pppnotdefault-yes' then pppnotdefault.Checked:=true else pppnotdefault.Checked:=false;
        If Memo_config.Lines[33]='routednsauto-yes' then routeDNSauto.Checked:=true else routeDNSauto.Checked:=false;
        If Memo_config.Lines[37]='rpap-yes' then CheckBox_rpap.Checked:=true else CheckBox_rpap.Checked:=false;
        If Memo_config.Lines[38]='rmschapv2-yes' then CheckBox_rmschapv2.Checked:=true else CheckBox_rmschapv2.Checked:=false;
        If Memo_config.Lines[39]='l2tp' then ComboBoxVPN.Text:='VPN L2TP';
        If Memo_config.Lines[39]='pptp' then ComboBoxVPN.Text:='VPN PPTP';
        If Memo_config.Lines[39]='openl2tp' then ComboBoxVPN.Text:='VPN OpenL2TP';
        If (Memo_config.Lines[39]='l2tp') or (Memo_config.Lines[39]='openl2tp') then Label1.Caption:=First_Label1+' '+message100 else Label1.Caption:=First_Label1+' '+message99;
        Edit_mru.Text:=Memo_config.Lines[40];
        If Edit_mru.Text='mru-none' then Edit_mru.Text:='';
        If Memo_config.Lines[41]='etc-hosts-yes' then etc_hosts.Checked:=true else etc_hosts.Checked:=false;
        PingInternetStr:=Memo_config.Lines[44];
        If (PingInternetStr='') or (PingInternetStr='none') then PingInternetStr:='yandex.ru';
        If Memo_config.Lines[45]='nobuffer-no' then nobuffer.Checked:=false else nobuffer.Checked:=true;
        If Memo_config.Lines[46]='route-IP-remote-yes' then route_IP_remote.Checked:=true else route_IP_remote.Checked:=false;
        If FileExists(EtcPppPeersDir+Edit_peer.Text) then //восстановление логина и пароля
                begin
                    Memo_config.Clear;
                    Memo_config.Lines.LoadFromFile(EtcPppPeersDir+Edit_peer.Text);
                    len:=Length(Memo_config.Lines[2]);
                    Edit_user.Text:=RightStr(Memo_config.Lines[2],len-6);
                    len:=Length(Edit_user.Text);
                    Edit_user.Text:=LeftStr(Edit_user.Text,len-1);
                    len:=Length(Memo_config.Lines[3]);
                    Edit_passwd.Text:=RightStr(Memo_config.Lines[3],len-10);
                    len:=Length(Edit_passwd.Text);
                    Edit_passwd.Text:=LeftStr(Edit_passwd.Text,len-1);
                end;
     end;
  If not FileExists(MyLibDir+ProfileName+'/config') then
                                           begin
                                                ComboBoxVPN.Text:='VPN PPTP';
                                                PingInternetStr:='yandex.ru';
                                           end;
  if ComboBoxDistr.Text<>message151 then ComboBoxDistr.Enabled:=false;
  If FileExists (MyLibDir+Edit_peer.Text+'/route') then Memo_route.Lines.LoadFromFile(MyLibDir+Edit_peer.Text+'/route'); //восстановление маршрутов
  Form1.Font.Size:=AFont;
//учитывание особенностей openSUSE
If suse then
            begin
                 FpSystem('ip r|'+'grep dsl > '+MyTmpDir+'gate');
                 If FileExists (MyTmpDir+'gate') then if FileSize(MyTmpDir+'gate')<>0 then
                                         begin
                                           Form3.MyMessageBox(message0,message148,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                           FpSystem('rm -f '+MyTmpDir+'gate');
                                           halt;
                                         end;
                 FpSystem('rm -f '+MyTmpDir+'gate');
            end;
If FallbackLang='ru' then If FileExists(MyWikiDir+'Help_ru.doc') then ButtonHelp.Enabled:=true;
If FallbackLang='uk' then If FileExists(MyWikiDir+'Help_uk.doc') then ButtonHelp.Enabled:=true;
DNS_auto:=true; //полагается, что EditDNS1 и EditDNS2 получаются автоматически пока не будет доказано обратного
If not Translate then Label25.Caption:='              '+Label25.Caption;
//проверка ponoff в процессах root
   FpSystem('ps -u root | '+'grep ponoff | '+'awk '+chr(39)+'{print $4}'+chr(39)+' > '+MyTmpDir+'tmpnostart');
   FpSystem('printf "none" >> '+MyTmpDir+'tmpnostart');
   Form1.tmpnostart.Clear;
   If FileExists(MyTmpDir+'tmpnostart') then tmpnostart.Lines.LoadFromFile(MyTmpDir+'tmpnostart');
   FpSystem('rm -f '+MyTmpDir+'tmpnostart');
   If LeftStr(tmpnostart.Lines[0],6)='ponoff' then
                                                       begin
                                                         Form3.MyMessageBox(message0,message4,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                         Application.ProcessMessages;
                                                         Form1.Repaint;
                                                         halt;
                                                       end;
//определение управляющего сетью сервиса
NetServiceStr:='none';
If FileExists (EtcInitDDir+'network') then NetServiceStr:='network';
If FileExists (EtcInitDDir+'networking') then NetServiceStr:='networking';
If FileExists (SystemdDir+'network-manager.service') then NetServiceStr:='network-manager.service';
If FileExists (SystemdDir+'NetworkManager.service') then NetServiceStr:='NetworkManager.service';
If FileExists (SystemdDir+'networkmanager.service') then NetServiceStr:='networkmanager.service';
If NetServiceStr='none' then
                            begin
                               Form3.MyMessageBox(message0,message160,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                               Application.ProcessMessages;
                               Form1.Repaint;
                            end;
//проверка dhclient в процессах root и установлен ли пакет
   dhclient:=true;
   FpSystem('ps -u root | '+'grep dhclient | '+'awk '+chr(39)+'{print $4}'+chr(39)+' > '+MyTmpDir+'tmpnostart');
   FpSystem('printf "none" >> '+MyTmpDir+'tmpnostart');
   Form1.tmpnostart.Clear;
   If FileExists(MyTmpDir+'tmpnostart') then tmpnostart.Lines.LoadFromFile(MyTmpDir+'tmpnostart');
   FpSystem('rm -f '+MyTmpDir+'tmpnostart');
   If not (LeftStr(tmpnostart.Lines[0],8)='dhclient') then If not FileExistsBin ('dhclient') then
                                                       begin
                                                         dhclient:=false;
                                                         Form3.MyMessageBox(message0,message25,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                                         Application.ProcessMessages;
                                                         Form1.Repaint;
                                                       end;
//проверка установлен ли пакет Sudo
  If FileExistsBin ('sudo') then Sudo:=true else Sudo:=false;
  FpSystem('rm -f '+MyLibDir+'ip-down');
  FpSystem('rm -f '+MyLibDir+Edit_peer.Text+'-ip-down');
  TabSheet1.TabVisible:= True;
  TabSheet2.TabVisible:= False;
  TabSheet3.TabVisible:= False;
  TabSheet4.TabVisible:= False;
  PageControl1.ActivePageIndex:=0;
  Button_create.Visible:=False;
  Button_next1.Visible:=True;
  Button_next2.Visible:=False;
  If FileExistsBin ('host') then BindUtils:=true else BindUtils:=false;
  StartMessage:=true;
//определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сеть
  FpSystem('ip r|'+'grep default|'+'awk '+ chr(39)+'{print $3}'+chr(39)+' > '+MyTmpDir+'gate');
  FpSystem('printf "none" >> '+MyTmpDir+'gate');
  Memo_gate.Clear;
  If FileExists(MyTmpDir+'gate') then Memo_gate.Lines.LoadFromFile(MyTmpDir+'gate');
  If Memo_gate.Lines[0]='none' then
                               begin
                                    Form3.MyMessageBox(message0,message162,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                    Application.ProcessMessages;
                                    Form1.Repaint;
                                    If ServiceCommand='systemctl' then FpSystem (ServiceCommand+' restart '+NetServiceStr) else FpSystem (ServiceCommand+NetServiceStr+' restart');
                               end;
  FpSystem ('rm -f '+MyTmpDir+'gate');
//повторная проверка дефолтного шлюза
  If Memo_gate.Lines[0]='none' then Sleep(3000);
  Memo_gate.Lines.Clear;
  FpSystem('ip r|'+'grep default|'+'awk '+ chr(39)+'{print $3}'+chr(39)+' > '+MyTmpDir+'gate');
  FpSystem('printf "none" >> '+MyTmpDir+'gate');
  Memo_gate.Clear;
  If FileExists(MyTmpDir+'gate') then Memo_gate.Lines.LoadFromFile(MyTmpDir+'gate');
  If Memo_gate.Lines[0]='none' then //ничего не помогло
                                   begin
                                        Form3.MyMessageBox(message0,message144+' '+message145+' '+message139,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                                        Application.ProcessMessages;
                                        Form1.Repaint;
                                   end;
  FpSystem ('rm -f '+MyTmpDir+'gate');
  Memo_gate.Lines.Clear;
  If (ComboBoxVPN.Text='VPN L2TP') or (ComboBoxVPN.Text='VPN OpenL2TP') then ComboBoxVPNChange(nil);
end;

procedure TForm1.Sudo_configureChange(Sender: TObject);
begin
   //проверка установлен ли пакет Sudo
   If FileExistsBin ('sudo') then Sudo:=true else Sudo:=false;
   If StartMessage then If Sudo_configure.Checked then If not Sudo then
                       begin
                          Form3.MyMessageBox(message0,message6,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Sudo_configure.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          exit;
                       end;
end;

procedure TForm1.Sudo_ponoffChange(Sender: TObject);
begin
   //проверка установлен ли пакет Sudo
   If FileExistsBin ('sudo') then Sudo:=true else Sudo:=false;
   If StartMessage then If Sudo_ponoff.Checked then If not Sudo then
                       begin
                          Form3.MyMessageBox(message0,message57,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Sudo_ponoff.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                          exit;
                       end;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo_ponoff.Checked then
                       begin
                          Form3.MyMessageBox(message0,message59,'','',message122,MyPixmapsDir+'vpnpptp.png',false,false,true,AFont,Form1.Icon,false,MyLibDir);
                          StartMessage:=false;
                          Autostart_ponoff.Checked:=false;
                          StartMessage:=true;
                          Application.ProcessMessages;
                          Form1.Repaint;
                       end;
end;

procedure TForm1.TabSheet1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   If PressCreate then exit;
   If Button=mbLeft then If Form1.Font.Size<15 then
                            begin
                                 Form1.Font.Size:=Form1.Font.Size+1;
                                 Form2.Font.Size:=Form2.Font.Size+1;
                                 Form2.Label1.Font.Size:=Form1.Font.Size+1;
                            end;
   If Button=mbRight then If Form1.Font.Size>2 then
                             begin
                                 Form1.Font.Size:=Form1.Font.Size-1;
                                 Form2.Font.Size:=Form2.Font.Size-1;
                                 Form2.Label1.Font.Size:=Form1.Font.Size-1;
                             end;
   AFont:=Form1.Font.Size;
   Form1.Repaint;
   Application.ProcessMessages;
   Form1.Repaint;
end;

initialization

  {$I unit1.lrs}
  no_resolv_conf:=false;
  If Paramcount=0 then ProfileName:='';
  If Paramcount>0 then ProfileName:=Paramstr(1);
  Gettext.GetLanguageIDs(Lang,FallbackLang);
  Translate:=false;
  //Belarusian, Bashkir (Белорусский, Башкирский)
  if (FallbackLang='be') or (FallbackLang='ba')
  //Bulgarian, Chechen, Church Slavic (Болгарский, Чеченский, Церковнославянский)
  or (FallbackLang='bg') or (FallbackLang='ce') or (FallbackLang='cu')
  //Chuvash, Kazakh, Komi (Чувашский, Казахский, Коми)
  or (FallbackLang='cv') or (FallbackLang='kk') or (FallbackLang='kv')
  //Moldavian, Tatar (Молдавский, Татарский)
  or (FallbackLang='mo') or (FallbackLang='tt')
                                               then FallbackLang:='ru';
  //FallbackLang:='en'; //просто для проверки при отладке
  If FallbackLang='ru' then
                            begin
                               POFileName:= MyLangDir+'vpnpptp.ru.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If FallbackLang='uk' then
                            begin
                               POFileName:= MyLangDir+'vpnpptp.uk.po';
                               If FileExists (POFileName) then
                               begin
                                    Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                                    Translate:=true;
                               end;
                            end;
  If not Translate then
                            begin
                               POFileName:= MyLangDir+'vpnpptp.en.po';
                               If FileExists (POFileName) then
                                          Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                            end;
If FileExists (POFileName) then LRSTranslator := TTranslator.Create(POFileName); //перевод (локализация) всей формы приложения
end.

end.

