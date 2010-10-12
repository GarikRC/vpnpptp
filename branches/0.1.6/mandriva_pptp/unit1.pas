{ PPTP/L2TP VPN setup

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
  StdCtrls, ExtCtrls, ComCtrls, unix, Translations, Menus, Gettext, Typinfo, Unit2, Process;

type

  { TForm1 }

  TForm1 = class(TForm)
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
    balloon: TCheckBox;
    Autostart_ponoff: TCheckBox;
    Autostartpppd: TCheckBox;
    CheckBox_required: TCheckBox;
    CheckBox_no128: TCheckBox;
    CheckBox_rpap: TCheckBox;
    CheckBox_rmschapv2: TCheckBox;
    ComboBoxVPN: TComboBox;
    EditDNS3: TEdit;
    EditDNS4: TEdit;
    Edit_mru: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    Label9: TLabel;
    LabelDNS3: TLabel;
    LabelDNS4: TLabel;
    Label_mru: TLabel;
    MemoTest: TMemo;
    routeDNSauto: TCheckBox;
    EditDNSdop3: TEdit;
    EditDNS1: TEdit;
    EditDNS2: TEdit;
    Edit_mtu: TEdit;
    LabelDNS2: TLabel;
    LabelDNS1: TLabel;
    Label_mtu: TLabel;
    Memonew1: TMemo;
    Memonew2: TMemo;
    pppnotdefault: TCheckBox;
    Memo_Autostartpppd: TMemo;
    Memo_sudo: TMemo;
    Memo_vpnpptp_ponoff_desktop: TMemo;
    Sudo_configure: TCheckBox;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Sudo_ponoff: TCheckBox;
    Memo_networktest: TMemo;
    networktest: TCheckBox;
    Memo_bindutilshost: TMemo;
    routevpnauto: TCheckBox;
    Memo_ip_IPS: TMemo;
    CheckBox_shorewall: TCheckBox;
    dhcp_route: TCheckBox;
    Metka: TLabel;
    Memo_config: TMemo;
    Memo_shorewall: TMemo;
    Pppd_log: TCheckBox;
    Reconnect_pptp: TCheckBox;
    Mii_tool_no: TCheckBox;
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
    Label44: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label_IPS: TLabel;
    Label_gate: TLabel;
    Label_ip_down: TLabel;
    Label_ip_up: TLabel;
    Label_peer: TLabel;
    Label_peername: TLabel;
    Label_route: TLabel;
    Label_user: TLabel;
    Label_pswd: TLabel;
    Memo_eth: TMemo;
    Memo_pptp: TMemo;
    Memo_peer: TMemo;
    Memo_ip_up: TMemo;
    Memo_ip_down: TMemo;
    Memo_gate: TMemo;
    Memo_create: TMemo;
    Memo_route: TMemo;
    Memo_users: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Tmpnostart: TMemo;
    procedure AutostartpppdChange(Sender: TObject);
    procedure Autostart_ponoffChange(Sender: TObject);
    procedure balloonChange(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure ButtonHidePassClick(Sender: TObject);
    procedure ButtonRestartClick(Sender: TObject);
    procedure ButtonTestClick(Sender: TObject);
    procedure ButtonVPNClick(Sender: TObject);
    procedure Button_addoptionsClick(Sender: TObject);
    procedure Button_createClick(Sender: TObject);
    procedure Button_exitClick(Sender: TObject);
    procedure Button_moreClick(Sender: TObject);
    procedure Button_next1Click(Sender: TObject);
    procedure Button_next2Click(Sender: TObject);
    procedure Button_next3Click(Sender: TObject);
    procedure CheckBox_desktopChange(Sender: TObject);
    procedure CheckBox_no128Change(Sender: TObject);
    procedure CheckBox_requiredChange(Sender: TObject);
    procedure CheckBox_rmschapv2Change(Sender: TObject);
    procedure CheckBox_rpapChange(Sender: TObject);
    procedure ComboBoxVPNChange(Sender: TObject);
    procedure ComboBoxVPNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit_mruChange(Sender: TObject);
    procedure Edit_mtuChange(Sender: TObject);
    procedure Edit_peerChange(Sender: TObject);
    procedure Edit_userChange(Sender: TObject);
    procedure MetkaClick(Sender: TObject);
    procedure networktestChange(Sender: TObject);
    procedure pppnotdefaultChange(Sender: TObject);
    procedure routeDNSautoChange(Sender: TObject);
    procedure routevpnautoChange(Sender: TObject);
    procedure CheckBox_no40Change(Sender: TObject);
    procedure CheckBox_no56Change(Sender: TObject);
    procedure CheckBox_rchapChange(Sender: TObject);
    procedure CheckBox_reapChange(Sender: TObject);
    procedure CheckBox_rmschapChange(Sender: TObject);
    procedure CheckBox_shorewallChange(Sender: TObject);
    procedure CheckBox_statelessChange(Sender: TObject);
    procedure dhcp_routeChange(Sender: TObject);
    procedure Label38Click(Sender: TObject);
    procedure Memo_configChange(Sender: TObject);
    procedure Memo_createChange(Sender: TObject);
    procedure Mii_tool_noChange(Sender: TObject);
    procedure Edit_IPSChange(Sender: TObject);
    procedure Edit_MaxTimeChange(Sender: TObject);
    procedure Edit_MinTimeChange(Sender: TObject);
    procedure Edit_passwdChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label_IPSClick(Sender: TObject);
    procedure Label_pswdClick(Sender: TObject);
    procedure Label_userClick(Sender: TObject);
    procedure Memo_gateChange(Sender: TObject);
    procedure Off_eth_Click(Sender: TObject);
    procedure On_eth_Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Off_ethChange(Sender: TObject);
    procedure On_ethChange(Sender: TObject);
    procedure Pppd_logChange(Sender: TObject);
    procedure Reconnect_pptpChange(Sender: TObject);
    procedure Sudo_configureChange(Sender: TObject);
    procedure Sudo_ponoffChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
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
  POFileName : String;
  Lang,FallbackLang:String;
  Translate:boolean; // переведено или еще не переведено
  dhclient:boolean; // запущен ли и установлен ли dhclient
  IPS: boolean; // если true, то в поле vpn-сервера введен ip; если false - то имя
  StartMessage:boolean; // принудительное блокирование сообщений
  BindUtils:boolean; //установлен ли пакет bind-utils
  Sudo:boolean; //установлен ли пакет sudo
  More:boolean; //отслеживает, что кнопку Button_more уже нажимали
  DNS_auto:boolean; //если false, то DNS провайдер выдает для ручного ввода
  DNSA,DNSB,DNSdopC,DNSC,DNSD:string; //автоопределенные конфигуратором DNS
  Stroowriter:string;
  AProcess: TProcess;

const
  Config_n=41;//определяет сколько строк (кол-во) в файле config программы максимально уже существует, считая от 1, а не от 0
resourcestring
  message0='Внимание!';
  message1='Поля "Провайдер (IP или имя)", "Имя соединения", "Пользователь", "Пароль" обязательны к заполнению.';
  message2='Так как Вы отказались от контроля state сетевого кабеля, то в целях снижения нагрузки на систему время дозвона установлено в 20 сек.';
  message3='Так как Вы не выбрали реконнект, то выбор встроенного в демон pppd(xl2tpd) реконнекта проигнорирован.';
  message4='Модуль ponoff еще не завершил свою работу. Дождитесь завершения работы модуля ponoff и повторно запустите конфигуратор vpnpptp.';
  message5='Не изменять дефолтный шлюз, запустив VPN L2TP в фоне';
  message6='Для того, чтобы разрешить пользователям конфигурировать соединение сначала установите пакет sudo.';
  message7='Рабочий стол';//папка (директория) пользователя
  message8='В поле "Время дозвона" можно ввести лишь число в пределах от 5 до 255 сек.';
  message9='Эта опция позволяет пользователям запускать конфигуратор VPN PPTP/L2TP без пароля администратора и конфигурировать соединение.';
  message10='В поле "Время реконнекта" можно ввести лишь число в пределах от 0 до 255 сек.';
  message11='Рекомендуется отключить поднятое VPN PPTP/L2TP - тогда шлюз локальной сети определится автоматически.';
  message12='Сетевой интерфейс не определился.';
  message13='Сетевой кабель для автоматического определения шлюза локальной сети не подключен.';
  message14='Не удалось автоматически определить шлюз локальной сети.';
  message15='Поле "Сетевой интерфейс" заполнено неверно. Правильно от eth0 до eth9 или от wlan0 до wlan9.';
  message16='Поле "Шлюз локальной сети" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message17='Поле "MTU" заполнено неверно. Разрешен лишь диапазон [576..1460..1492..1500]. Рекомендуется MTU=1460.';
  message18='Запуск этой программы возможен только под администратором или с разрешения администратора. Нажмите <OK> для отказа от запуска.';
  message19='Другая такая же программа уже пытается сконфигурировать VPN PPTP/L2TP. Нажмите <OK> для отказа от двойного запуска.';
  message20='Невозможно настроить VPN PPTP/L2TP в связи с отсутствием пакета pptp-linux.';
  message21='Эта опция позволяет запустить модуль ponoff при старте операционной системы и установить соединение VPN PPTP/L2TP автозагрузкой.';
  message22='Невозможно создать ярлык на рабочем столе, так как используется нестандартный идентификатор пользователя и/или локализация.';
  message23='Невозможно создать ярлык на рабочем столе, так как отсутствует файл /usr/share/applications/ponoff.desktop.';
  message24='Для того, чтобы разрешить автозапуск интернета при старте системы сначала установите пакет sudo.';
  message25='Не установлен и не запущен dhclient (то есть пакет dhcp-client). Возможны проблемы в работе сети.';
  message26='Не удалось определить IP-адрес VPN-сервера. VPN-сервер не пингуется. Или он введен неправильно, или проблема с DNS.';
  message27='Маршруты не могут приходить через dhcp, так как не установлен и не запущен dhclient (то есть пакет dhcp-client).';
  message28='Нельзя определить IP-адрес VPN-сервера, так как строка для ввода не заполнена.';
  message29='Не установлен пакет bind-utils. Его установка необязательна, но она ускорит механизм программного добавления маршрута к vpn-серверу.';
  message30='Используйте опцию отключения контроля state сетевого кабеля если только по другому не работает (об этом попросит сама программа).';
  message31='Встроенный в демон pppd(xl2tpd) механизм реконнекта не умеет контролировать state сетевого кабеля, поэтому он не желателен к использованию.';
  message32='Ведите лог pppd(xl2tpd) для того, чтобы выяснить ошибки настройки соединения, ошибки при соединении и т.д.';
  message33='Получение маршрутов через dhcp необходимо для одновременной работы локальной сети и интернета, но провайдер не всегда их присылает.';
  message34='Эта опция настраивает файервол лишь для интернета, но не для p2p и не для других соединений.';
  message35='Отменив получение маршрутов через dhcp, не будут одновременно работать интернет и локальная сеть, а будет работать только интернет.';
  message36='Отменить настройку файервола программой стоит только если файервол отключен, или файервол Вами самостоятельно настраивается.';
  message37='Если интернет хорошо работает без опции программного добавления маршрута к vpn-серверу, то не стоит нагружать систему.';
  message38='При выборе этой опции проверяется пинг vpn-, dns-сервера, пинг шлюза локальной сети, пинг yandex.ru, выявляются основные проблемы, выводя сообщения.';
  message39='Отменить эту опцию стоит только если у Вас стабильные локальная сеть и интернет, и они никогда не падают.';
  message40='Эта опция блокирует все всплывающие сообщения из трея, а также отключает проверку dns-, vpn-сервера, шлюза локальной сети и есть ли интернет.';
  message41='Проверка показала, что маршруты через dhcp не приходят. Одновременная работа интернета и лок. сети не настроена.';
  message42='Получение маршрутов через dhcp будет отменено, так как маршруты через dhcp не приходят.';
  message43='Vpn-сервер не пингуется. Устраните проблему и заново запустите конфигуратор.';
  message44='Шлюз локальной сети не пингуется или теряются пакеты. Устраните проблему и заново запустите конфигуратор.';
  message45='Пингуется vpn-сервер. Ожидайте...';
  message46='Определяется ip-адрес vpn-сервера через команду ping. Ожидайте...';
  message47='Пингуется шлюз локальной сети. Ожидайте...';
  message48='Осуществляется подготовка сети для проверки приходят ли маршруты через dhcp. Ожидайте...';
  message49='Сеть подготовлена для проверки приходят ли маршруты через dhcp. Вызывается dhclient. Ожидайте...';
  message50='Определяются ip-адреса vpn-сервера через команду host из пакета bind-utils. Ожидайте...';
  message51='Отменяется получение маршрутов через dhcp. Ожидайте...';
  message52='Пинг проверен';
  message53='Минуточку...';
  message54='Не определилось ни одного ip-адреса vpn-сервера.';
  message55='Часто используется аутентификация mschap v2 - это одновременный выбор refuse-eap, refuse-chap, refuse-mschap, refuse-pap.';
  message56='Эта опция создает ярлык ponoff на Рабочем столе для доступа в интернет пользователю, позволяя ему управлять соединением через иконку в трее.';
  message57='Для того, чтобы разрешить пользователям управлять подключением сначала установите пакет sudo.';
  message58='При использовании опции refuse-chap демон pppd не согласится аутентифицировать себя по протоколу CHAP.';
  message59='Выбор опции автозапуска интернета при старте системы возможен только при выборе опции разрешения пользователям управлять подключением.';
  message60='Автозапуск интернета при старте системы не настроен. Отсутствует ~/.config/autostart/ или используется нестандартный идентификатор пользователя.';
  message61='Автозапуск интернета при старте системы не настроен. Отсутствует файл /usr/share/applications/ponoff.desktop.';
  message62='Эта опция осуществляет автозапуск интернета при старте системы без использования ponoff. Рекомендуется использовать с pppd(xl2tpd)-реконнектом.';
  message63='Не допустим одновременный выбор графического автозапуска интернета при старте системы и автозапуск демоном pppd(xl2tpd) без графики.';
  message64='Эта опция полезна если VPN PPTP/L2TP не должно быть главным.';
  message65='Пока нельзя одновременно выбрать автозапуск интернета демоном pppd(xl2tpd) и не изменять дефолтный шлюз, запустив VPN PPTP/L2TP в фоне.';
  message66='Не удалось автоматически определить ни DNS1 до поднятия VPN, ни DNS2 до поднятия VPN.';
  message67='Поле "DNS1 до поднятия VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message68='Поле "DNS2 до поднятия VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message69='Необходимо ввести хотя бы одно DNS1 до поднятия VPN или DNS2 до поднятия VPN.';
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
  message80='Выбрана опция usepeerdns: если vpn-сервер предоставит свои dns, то будут использоваться они, невзирая на другие настройки dns.';
  message81='Поле "DNS1 при поднятом VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message82='Поле "DNS2 при поднятом VPN" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message83='Необходимо ввести хотя бы одно DNS1 при поднятом VPN или DNS2 при поднятом VPN.';
  message84='DNS2-сервер до поднятия VPN не пингуется или теряются пакеты, но пингуется DNS1-сервер до поднятия VPN, поэтому это некритично.';
  message85='DNS1-сервер до поднятия VPN не пингуется или теряются пакеты, но пингуется DNS2-сервер до поднятия VPN, поэтому будут тормоза.';
  message86='Показать пароль';
  message87='Скрыть пароль';
  message88='Часто используется шифрование трафика mppe с 128-битным шифрованием - это одновременный выбор required, stateless, no40, no56.';
  message89='Опция stateless пытается реализовать шифрование mppe в режиме без поддержки состояний.';
  message90='Опция no40 отключает 40-битное шифрование mppe.';
  message91='Опция no56 отключает 56-битное шифрование mppe.';
  message92='Опция no128 отключает 128-битное шифрование mppe.';
  message93='Принудительный рестарт сети';
  message94='Невозможно выбрать VPN L2TP, так как не установлен пакет xl2tpd.';
  message95='Соединение будет сконфигурировано по протоколу VPN PPTP.';
  message96='Использовать встроенный в демон xl2tpd механизм реконнекта (не рекомендуется если несколько сетевых карт)';
  message97='Вести лог xl2tpd в /var/log/xl2tpd.log';
  message98='Автозапуск интернета при старте системы демоном xl2tpd без графики (не рекомендуется использовать)';
  message99='I) Введите адрес vpn-сервера... (например, vpn.internet.beeline.ru)';
  message100='I) Введите адрес vpn-сервера... (например, tp.internet.beeline.ru)';
  message101='Для VPN L2TP значение MTU должно быть меньше, чем для VPN PPTP как минимум на 20 байт, но не более чем 1460 байт.';
  message102='Рекомендуется значение MTU 1400 байт. <ОК> - игнорировать это предупреждение и продолжить. <Cancel> - поправить.';
  message103='Настройка VPN PPTP/L2TP';
  message104='Поле "MRU" заполнено неверно. Разрешен лишь диапазон [576..1460..1492..1500].';
  message105='Обнаружено, что VPN PPTP/L2TP поднято. <OK> - продолжить, убив VPN PPTP/L2TP и перезапустив сеть. <Cancel> - отмена запуска конфигуратора.';
  message106='Обнаружено, что используется пакет xl2tpd не из репозитория EduMandriva, поэтому встроенный в демон xl2tpd механизм реконнекта выбрать нельзя.';
  message107='Запустить конфигуратор VPN PPTP/L2TP можно также из Центра Управления->Сеть и Интернет->Настройка VPN-соединений->VPN PPTP/L2TP.';
  message108='Установить тестовое соединение VPN PPTP/L2TP в графике/без графики сейчас? <Yes> - установить в графике, <No> - установить без графики, <Cancel> - отмена.';
  message109='Тестовый запуск';
  message110='Лог не ведется, так как Вы не выбрали опцию ведения лога pppd в /var/log/pppd.log (лога xl2tpd в /var/log/xl2tpd.log).';
  message111='Команда запуска:';

implementation

uses
LCLProc;

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
      DebugLn(UpperCase(FFormClassName + '.'+PropInfo^.Name) + '=' + Content);
      Content := FPOFile.Translate(UpperCase(FFormClassName + '.' + PropInfo^.Name), Content);
    end
  else
    begin
      DebugLn(UpperCase(FFormClassName + '.'+Instance.GetNamePath + '.' + PropInfo^.Name) + '=' + Content);
      Content := FPOFile.Translate(UpperCase(FFormClassName + '.'+Instance.GetNamePath + '.'+ PropInfo^.Name), Content);
    end;
  Content := UTF8ToSystemCharSet(Content); // перевод UTF8 в текущую локаль
end;

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

procedure TForm1.Button_createClick(Sender: TObject);
var mppe_string:string;
    i:integer;
    pchar_message0,pchar_message1:pchar;
    gksu, link_on_desktop:boolean;
    Str,Str1:string;
    flag:boolean;
    FileSudoers,FileAutostartpppd,FileResolvConf,FileSyslog:textfile;
    FlagAutostartPonoff:boolean;
    EditDNS1ping, EditDNS2ping:boolean;
    endprint:boolean;
    N:byte;
begin
FlagAutostartPonoff:=false;
StartMessage:=true;
//сообщения, которые могут привести к выходу из Создания подключения
If Unit2.Form2.CheckBoxusepeerdns.Checked then
                                         begin
                                            pchar_message0:=Pchar(message0);
                                            pchar_message1:=Pchar(message80);
                                            if Application.MessageBox(pchar_message1,pchar_message0, 1)<>mrOK then
                                                                                                              begin
                                                                                                                 Label42.Visible:=true;
                                                                                                                 Label43.Visible:=true;
                                                                                                                 Label14.Caption:='';
                                                                                                                 Application.ProcessMessages;
                                                                                                                 exit;
                                                                                                              end;
                                         end;
Label42.Visible:=false;
Label43.Visible:=false;
Application.ProcessMessages;
//проверка текущего состояния дополнительных сторонних пакетов и других зависимостей
   If FileExists ('/usr/bin/sudo') then Sudo:=true else Sudo:=false;
   If ComboBoxVPN.Text='VPN L2TP' then if not FileExists ('/usr/sbin/xl2tpd') then
                     begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message94+' '+message95);
                          Label14.Caption:=message94+' '+message95;
                          Application.ProcessMessages;
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          ComboBoxVPN.Text:='VPN PPTP';
                     end;
   If StartMessage then If Sudo_ponoff.Checked then If not Sudo then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message57);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Sudo_ponoff.Checked:=false;
                          StartMessage:=true;
                       end;
   If StartMessage then If Sudo_configure.Checked then If not Sudo then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message6);
                          Label14.Caption:=message6;
                          Application.ProcessMessages;
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Sudo_configure.Checked:=false;
                          StartMessage:=true;
                       end;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message24);
                          Label14.Caption:=message24;
                          Application.ProcessMessages;
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Autostart_ponoff.Checked:=false;
                          StartMessage:=true;
                       end;
  If StartMessage then If dhcp_route.Checked then if not dhclient then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message27);
                          Label14.Caption:=message27;
                          Application.ProcessMessages;
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          dhcp_route.Checked:=false;
                          StartMessage:=true;
                       end;
   If StartMessage then If routevpnauto.Checked then If not BindUtils then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message29);
                          Label14.Caption:=message29;
                          Application.ProcessMessages;
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
   If ComboBoxVPN.Text='VPN L2TP' then If Reconnect_pptp.Checked then If FileExists ('/bin/rpm') then
                               begin
                                 Shell ('rm -f /tmp/ver_xl2tpd');
                                 Shell ('rpm xl2tpd -qa|grep edm >> /tmp/ver_xl2tpd');
                                 If FileSize ('/tmp/ver_xl2tpd') = 0 then
                                                                 begin
                                                                      pchar_message0:=Pchar(message0);
                                                                      pchar_message1:=Pchar(message106);
                                                                      Label14.Caption:=message106;
                                                                      Application.ProcessMessages;
                                                                      Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                      StartMessage:=false;
                                                                      Reconnect_pptp.Checked:=false;
                                                                      StartMessage:=true;
                                                                 end;
                                 Shell ('rm -f /tmp/ver_xl2tpd');
                               end;
Button_more.Visible:=false;
Button_create.Enabled:=false;
Button_exit.Enabled:=false;
Application.ProcessMessages;
If EditDNSdop3.Text='' then EditDNSdop3.Text:='none';
Shell('rm -f /opt/vpnpptp/hosts');
If FileExists('/etc/ppp/ip-up.old') then //сброс настройки маршрутизации remote ip address в шлюз локальной сети
                                         //оставлено для совместимости с пред.версиями
                                   begin
                                      Shell('cp -f /etc/ppp/ip-up.old /etc/ppp/ip-up');
                                      Shell('chmod a+x /etc/ppp/ip-up');
                                      Shell('rm -f /etc/ppp/ip-up.old');
                                   end;
if FileExists('/etc/ppp/options.pptp.old') then //для совместимости с пред.версиями
                                   begin
                                      Shell('cp -f /etc/ppp/options.pptp.old /etc/ppp/options.pptp');
                                      Shell('rm -f /etc/ppp/options.pptp.old');
                                   end;
If Mii_tool_no.Checked then If StrToInt(Edit_MaxTime.Text)<20 then
                        begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message2);
                          Label14.Caption:=message2;
                          Application.ProcessMessages;
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Edit_MaxTime.Text:='20';
                        end;
If Reconnect_pptp.Checked then If Edit_MinTime.Text='0' then
                        begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message3);
                          Label14.Caption:=message3;
                          Application.ProcessMessages;
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Reconnect_pptp.Checked:=False;
                          StartMessage:=true;
                        end;
 If dhcp_route.Checked then
                       begin
                          If not FileExists('/etc/dhclient-exit-hooks') then Shell('printf "#!/bin/sh\n" >> /etc/dhclient-exit-hooks');
                          If not FileExists('/etc/dhclient.conf') then Shell('printf "#Clear config file\n" >> /etc/dhclient.conf');
                        end;
 If dhcp_route.Checked then If not FileExists('/etc/dhclient-exit-hooks.old') then
                       begin
                          if FileExists('/etc/dhclient.conf') then Shell('cp -f /etc/dhclient.conf /etc/dhclient.conf.old');
                          Shell('rm -f /etc/dhclient.conf');
                          if FileExists('/opt/vpnpptp/scripts/dhclient.conf') then Shell('cp -f /opt/vpnpptp/scripts/dhclient.conf /etc/dhclient.conf');
                          if FileExists('/etc/dhclient-exit-hooks') then Shell('cp -f /etc/dhclient-exit-hooks /etc/dhclient-exit-hooks.old');
                          Shell('rm -f /etc/dhclient-exit-hooks');
                          if FileExists('/opt/vpnpptp/scripts/dhclient-exit-hooks') then Shell('cp -f /opt/vpnpptp/scripts/dhclient-exit-hooks /etc/dhclient-exit-hooks');
                          //проверка получаются ли маршруты по dhcp и настройка - если получаются или отмена - если не получаются
                          Label14.Caption:=message48;
                          Application.ProcessMessages;
                          Shell ('ifdown '+Edit_eth.Text);
                          Shell ('ifup '+Edit_eth.Text);
                          Application.ProcessMessages;
                          Shell ('rm -f /tmp/dhclienttest1');
                          Shell ('route -n|grep '+Edit_eth.Text+ '|grep '+Edit_gate.Text+' >/tmp/dhclienttest1');
                          Shell ('rm -f /tmp/dhclienttest2');
                          Label14.Caption:=message49;
                          Application.ProcessMessages;
                          Shell ('dhclient '+Edit_eth.Text);
                          Application.ProcessMessages;
                          Shell ('route -n|grep '+Edit_eth.Text+ '|grep '+Edit_gate.Text+' >/tmp/dhclienttest2');
                          //проверка поднялся ли интерфейс после dhclient
                          Shell ('rm -f /tmp/gate');
                          Shell('/sbin/ip r|grep '+Edit_eth.Text+' > /tmp/gate');
                          Shell('printf "none" >> /tmp/gate');
                          Memo_gate.Clear;
                          If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
                          If Memo_gate.Lines[0]='none' then Shell ('ifup '+Edit_eth.Text);
                          Shell ('rm -f /tmp/gate');
                          Memo_gate.Lines.Clear;
                          If FileSize('/tmp/dhclienttest2')<=FileSize('/tmp/dhclienttest1') then
                                                                                               begin
                                                                                                 Label14.Caption:=message41;
                                                                                                 Application.ProcessMessages;
                                                                                                 pchar_message0:=Pchar(message0);
                                                                                                 pchar_message1:=Pchar(message42);
                                                                                                 Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                                                 StartMessage:=false;
                                                                                                 dhcp_route.Checked:=false;
                                                                                                 StartMessage:=true;
                                                                                               end;
                         Shell('rm -f /tmp/dhclienttest1');
                         Shell('rm -f /tmp/dhclienttest2');
                       end;
If not dhcp_route.Checked then If FileExists('/etc/dhclient-exit-hooks.old') then
                       begin
                          if FileExists('/etc/dhclient.conf.old') then Shell('cp -f /etc/dhclient.conf.old /etc/dhclient.conf');
                          Shell('rm -f /etc/dhclient.conf.old');
                          if FileExists('/etc/dhclient-exit-hooks.old') then Shell('cp -f /etc/dhclient-exit-hooks.old /etc/dhclient-exit-hooks');
                          Shell('rm -f /etc/dhclient-exit-hooks.old');
                          Label14.Caption:=message51;
                          Application.ProcessMessages;
                          Shell ('ifdown '+Edit_eth.Text);
                          Shell ('ifup '+Edit_eth.Text);
                          Application.ProcessMessages;
                       end;
 If CheckBox_shorewall.Checked then If not FileExists('/etc/shorewall/interfaces.old') then
                       begin
                          if FileExists('/etc/shorewall/interfaces') then
                                                                     begin
                                                                        Shell('cp -f /etc/shorewall/interfaces /etc/shorewall/interfaces.old');
                                                                        Memo_shorewall.Lines.Clear;
                                                                        Memo_shorewall.Lines.LoadFromFile('/etc/shorewall/interfaces');
                                                                        i:=0;
                                                                        Repeat
                                                                        i:=i+1;
                                                                        until LeftStr(Memo_shorewall.Lines[i], 10)='#LAST LINE';
                                                                        Str:=Memo_shorewall.Lines[i];
                                                                        Shell('rm -f /etc/shorewall/interfaces');
                                                                        Memo_shorewall.Lines[0]:='# vpnpptp changed this config';
                                                                        For i:=0 to i-1 do
                                                                        begin
                                                                              Str1:='printf "'+Memo_shorewall.Lines[i]+'\n" >> /etc/shorewall/interfaces';
                                                                              Shell (Str1);
                                                                        end;
                                                                        Shell('printf "net    ppp0    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp1    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp2    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp3    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp4    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp5    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp6    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp7    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp8    detect\n" >> /etc/shorewall/interfaces');
                                                                        Shell('printf "net    ppp9    detect\n" >> /etc/shorewall/interfaces');
                                                                        Str:='printf "'+Str+'\n" >> /etc/shorewall/interfaces';
                                                                        Shell (Str);
                                                                        Shell ('/etc/init.d/shorewall restart');
                                                                        Shell ('chmod 600 /etc/shorewall/interfaces');
                                                                     end;
                       end;
 If not CheckBox_shorewall.Checked then If FileExists('/etc/shorewall/interfaces.old') then
                                                                  begin
                                                                        Shell('cp -f /etc/shorewall/interfaces.old /etc/shorewall/interfaces');
                                                                        Shell('rm -f /etc/shorewall/interfaces.old');
                                                                        Shell ('/etc/init.d/shorewall restart');
                                                                  end;
 If FileExists('/etc/ppp/peers/'+Edit_peer.Text) then Shell('cp -f /etc/ppp/peers/'+Edit_peer.Text+' /etc/ppp/peers/'+Edit_peer.Text+chr(46)+'old');
 Label_peername.Caption:='/etc/ppp/peers/'+Edit_peer.Text;
 Unit2.Form2.Obrabotka(Edit_peer.Text, more);
 Shell('rm -f '+ Label_peername.Caption);
 Memo_peer.Clear;
 If ComboBoxVPN.Text<>'VPN L2TP' then Memo_peer.Lines.Add('pty "pptp ' +Edit_IPS.Text +' --nolaunchpppd --nobuffer"') else
                                 Memo_peer.Lines.Add('#pty "pptp ' +Edit_IPS.Text +' --nolaunchpppd --nobuffer"');
 Memo_peer.Lines.Add('remotename '+Edit_peer.Text);
 Memo_peer.Lines.Add('user "'+Edit_user.Text+'"');
 Memo_peer.Lines.Add('password "'+Edit_passwd.Text+'"');
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
 If Unit2.Form2.CheckBoxnodetach.Checked then Memo_peer.Lines.Add('nodetach');
 If Unit2.Form2.CheckBoxreplacedefaultroute.Checked then Memo_peer.Lines.Add('replacedefaultroute');
 If Unit2.Form2.CheckBoxauth.Checked then Memo_peer.Lines.Add('auth');
 If Unit2.Form2.CheckBoxpassive.Checked then Memo_peer.Lines.Add('passive');
 If Unit2.Form2.CheckBoxnodefaultroute.Checked then Memo_peer.Lines.Add('nodefaultroute');
 If not Reconnect_pptp.Checked then Memo_peer.Lines.Add('maxfail 10');
 If Reconnect_pptp.Checked then
                                    begin
                                      Memo_peer.Lines.Add('maxfail 0');
                                      Memo_peer.Lines.Add('holdoff '+Edit_MaxTime.Text);
                                      Memo_peer.Lines.Add('lcp-echo-interval '+Edit_MinTime.Text);
                                      Memo_peer.Lines.Add('lcp-echo-failure 4');
                                    end;
 If Pppd_log.Checked then Memo_peer.Lines.Add('debug');
 If Edit_mtu.Text <> '' then Memo_peer.Lines.Add('mtu '+Edit_mtu.Text);
 If Edit_mru.Text <> '' then Memo_peer.Lines.Add('mru '+Edit_mru.Text);
//Разбираемся с аутентификацией
   If CheckBox_rmschap.Checked then Memo_peer.Lines.Add(CheckBox_rmschap.Caption);
   If CheckBox_reap.Checked then Memo_peer.Lines.Add(CheckBox_reap.Caption);
   If CheckBox_rchap.Checked then Memo_peer.Lines.Add(CheckBox_rchap.Caption);
   If CheckBox_rpap.Checked then Memo_peer.Lines.Add(CheckBox_rpap.Caption);
   If CheckBox_rmschapv2.Checked then Memo_peer.Lines.Add(CheckBox_rmschapv2.Caption);
//Разбираемся с шифрованием
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
 Memo_peer.Lines.SaveToFile(Label_peername.Caption); //записываем провайдерский профиль подключения
 Shell ('chmod 600 '+Label_peername.Caption);
//удаляем временные файлы
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');
//перезаписываем скрипт поднятия соединения ip-up
 if FileExists(Label_ip_up.Caption) then If not FileExists (Label_ip_up.Caption+chr(46)+'old') then Shell('cp -f '+ Label_ip_up.Caption+' '+Label_ip_up.Caption+chr(46)+'old');
 Shell('rm -f '+ Label_ip_up.Caption);
 Memo_ip_up.Clear;
 Memo_ip_up.Lines.Add('#!/bin/sh');
 If routevpnauto.Checked then if IPS then Memo_ip_up.Lines.Add('/sbin/route add -host ' + Edit_IPS.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 flag:=false;
 If routevpnauto.Checked then if not IPS then  //определение всех актуальных в данный момент ip-адресов vpn-сервера с занесением в Memo_bindutilshost.Lines и в файл /opt/vpnpptp/hosts
                                              begin
                                                  if BindUtils then Str:='host '+Edit_IPS.Text+'|grep address|grep '+Edit_IPS.Text+'|awk '+ chr(39)+'{print $4}'+chr(39);
                                                  if not BindUtils then Str:= 'ping -c1 '+Edit_IPS.Text+'|grep '+Edit_IPS.Text+'|awk '+chr(39)+'{ print $3 }'+chr(39)+'|grep '+chr(39)+'('+chr(39);
                                                  If not BindUtils then Label14.Caption:=message46 else Label14.Caption:=message50;
                                                  Application.ProcessMessages;
                                                  Shell (Str+' > /opt/vpnpptp/hosts');
                                                  If not BindUtils then flag:=true;
                                                  Application.ProcessMessages;
                                                  Memo_bindutilshost.Lines.LoadFromFile('/opt/vpnpptp/hosts');
                                                  If FileSize('/opt/vpnpptp/hosts')<>0 then If Memo_bindutilshost.Lines[0]<>'none' then
                                                                                         begin
                                                                                            For i:=0 to Memo_bindutilshost.Lines.Count-1 do
                                                                                               begin
                                                                                                  Memo_bindutilshost.Lines[i]:=DeleteSym(')',Memo_bindutilshost.Lines[i]);
                                                                                                  Memo_bindutilshost.Lines[i]:=DeleteSym('(',Memo_bindutilshost.Lines[i]);
                                                                                                  If Memo_bindutilshost.Lines[i]<>'none' then Memo_ip_up.Lines.Add('/sbin/route add -host ' + Memo_bindutilshost.Lines[i] + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
                                                                                               end;
                                                                                         if not BindUtils then
                                                                                                              begin //просто перезаписать файл /opt/vpnpptp/hosts
                                                                                                                Shell('rm -f /opt/vpnpptp/hosts');
                                                                                                                Str:=Memo_bindutilshost.Lines[0];
                                                                                                                Shell('printf "'+Str+'\n" >> /opt/vpnpptp/hosts');
                                                                                                              end;
                                                                                         end;
                                                  If FileSize('/opt/vpnpptp/hosts')=0 then
                                                                                             begin
                                                                                                  If BindUtils then Label14.Caption:=message54 else Label14.Caption:=message43;
                                                                                                  Application.ProcessMessages;
                                                                                                  pchar_message0:=Pchar(message0);
                                                                                                  If BindUtils then pchar_message1:=Pchar(message54) else pchar_message1:=Pchar(message43);
                                                                                                  Application.MessageBox(pchar_message1,pchar_message0, 0);
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
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS1.Text<>'none' then Memo_ip_up.Lines.Add('/sbin/route add -host ' + EditDNS1.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS2.Text<>'none' then Memo_ip_up.Lines.Add('/sbin/route add -host ' + EditDNS2.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If pppnotdefault.Checked then
                                                       begin
                                                          Memo_ip_up.Lines.Add('/sbin/route add -host ' + EditDNS3.Text + ' gw $PPP_REMOTE dev $PPP_IFACE');
                                                          Memo_ip_up.Lines.Add('/sbin/route add -host ' + EditDNS4.Text + ' gw $PPP_REMOTE dev $PPP_IFACE');
                                                          Memo_ip_up.Lines.Add('/sbin/route add -host $DNS1 gw $PPP_REMOTE dev $PPP_IFACE');
                                                          Memo_ip_up.Lines.Add('/sbin/route add -host $DNS2 gw $PPP_REMOTE dev $PPP_IFACE');
                                                       end;
 If not pppnotdefault.Checked then Memo_ip_up.Lines.Add('/sbin/route del default');
 If not pppnotdefault.Checked then Memo_ip_up.Lines.Add('/sbin/route add default dev $PPP_IFACE');
 Memo_ip_up.Lines.Add('cp -f /etc/resolv.conf /etc/resolv.conf.lock');
 Memo_ip_up.Lines.Add('cp -f /var/run/ppp/resolv.conf /etc/resolv.conf');
 Memo_ip_up.Lines.SaveToFile(Label_ip_up.Caption);
 if Memo_route.Lines.Text <> '' then Memo_route.Lines.SaveToFile('/opt/vpnpptp/route'); //сохранение введенных пользователем маршрутов в файл
 if Memo_route.Lines.Text = '' then Shell ('rm -f /opt/vpnpptp/route');
 Shell('chmod a+x '+ Label_ip_up.Caption);
//перезаписываем скрипт опускания соединения ip-down
 if FileExists(Label_ip_down.Caption) then If not FileExists (Label_ip_down.Caption+chr(46)+'old') then Shell('cp -f '+ Label_ip_down.Caption+' '+Label_ip_down.Caption+chr(46)+'old');
 Shell('rm -f '+ Label_ip_down.Caption);
 Memo_ip_down.Clear;
 Memo_ip_down.Lines.Add('#!/bin/sh');
 //отмена введенных пользователем маршрутов через скрипт ip-down
 If FileExists ('/opt/vpnpptp/route') then
 begin
 Memo_route.Lines.Clear;
 Memo_route.Lines.LoadFromFile('/opt/vpnpptp/route');
 i:=0;
 For i:=0 to Memo_route.Lines.Count-1 do
     begin
         Memo_route.Lines[i]:=StringReplace(Memo_route.Lines[i],'add','del',[rfReplaceAll]);
     end;
 If Memo_route.Lines[0]<>'' then
  begin
   i:=0;
   While Memo_route.Lines.Count > i do
    begin
     Memo_ip_down.Lines.Add(Memo_route.Lines[i]);
     i:=i+1;
    end;
  end;
 end;
 If routevpnauto.Checked then if not IPS then //отмена маршрутов, полученных от команды host или ping
               If FileSize('/opt/vpnpptp/hosts')<>0 then
                                                        begin
                                                           For i:=0 to Memo_bindutilshost.Lines.Count-1 do
                                                             begin
                                                               If LeftStr(Memo_bindutilshost.Lines[i],4)<>'none' then Memo_ip_down.Lines.Add('/sbin/route del -host ' + Memo_bindutilshost.Lines[i] + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
                                                             end;
                                                        end;
 If not pppnotdefault.Checked then Memo_ip_down.Lines.Add('/sbin/route del default');
 if Edit_gate.Text <> '' then
                           Memo_ip_down.Lines.Add('/sbin/route add default gw '+Edit_gate.Text+' dev '+Edit_eth.Text);
 If routevpnauto.Checked then if IPS then Memo_ip_down.Lines.Add('/sbin/route del -host ' + Edit_IPS.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS1.Text<>'none' then Memo_ip_down.Lines.Add('/sbin/route del -host ' + EditDNS1.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If not pppnotdefault.Checked then If EditDNS2.Text<>'none' then Memo_ip_down.Lines.Add('/sbin/route del -host ' + EditDNS2.Text + ' gw '+ Edit_gate.Text+ ' dev '+ Edit_eth.Text);
 If routeDNSauto.Checked then If pppnotdefault.Checked then
                                                       begin
                                                          Memo_ip_up.Lines.Add('/sbin/route del -host ' + EditDNS3.Text + ' gw $PPP_REMOTE dev $PPP_IFACE');
                                                          Memo_ip_up.Lines.Add('/sbin/route del -host ' + EditDNS4.Text + ' gw $PPP_REMOTE dev $PPP_IFACE');
                                                          Memo_ip_up.Lines.Add('/sbin/route del -host $DNS1 gw $PPP_REMOTE dev $PPP_IFACE');
                                                          Memo_ip_up.Lines.Add('/sbin/route del -host $DNS2 gw $PPP_REMOTE dev $PPP_IFACE');
                                                       end;
 Memo_ip_down.Lines.Add('cp -f /etc/resolv.conf.lock /etc/resolv.conf');
 Memo_ip_down.Lines.Add('rm -f /etc/resolv.conf.lock');
 Memo_ip_down.Lines.SaveToFile(Label_ip_down.Caption);
 Shell('chmod a+x '+ Label_ip_down.Caption);
//Записываем готовый конфиг, кроме логина и пароля
 If Edit_MinTime.Text<>'0' then Edit_MinTime.Text:=Edit_MinTime.Text+'000';
 Edit_MaxTime.Text:=Edit_MaxTime.Text+'000';
 If Edit_mtu.Text='' then Edit_mtu.Text:='mtu-none';
 If Edit_mru.Text='' then Edit_mru.Text:='mru-none';
 Shell('rm -f /opt/vpnpptp/config');
 Shell('printf "'+Edit_peer.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_IPS.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_gate.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_eth.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_MinTime.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_MaxTime.Text+'\n" >> /opt/vpnpptp/config');
 If Mii_tool_no.Checked then Shell('printf "mii-tool-no\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "mii-tool-yes\n" >> /opt/vpnpptp/config');
 If Reconnect_pptp.Checked then Shell('printf "reconnect-pptp\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "noreconnect-pptp\n" >> /opt/vpnpptp/config');
 If Pppd_log.Checked then Shell('printf "pppd-log-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "pppd-log-no\n" >> /opt/vpnpptp/config');
 If dhcp_route.Checked then Shell('printf "dhcp-route-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "dhcp-route-no\n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_mtu.Text+'\n" >> /opt/vpnpptp/config');
 If CheckBox_required.Checked then Shell('printf "required-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "required-no\n" >> /opt/vpnpptp/config');
 If CheckBox_rchap.Checked then Shell('printf "rchap-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "rchap-no\n" >> /opt/vpnpptp/config');
 If CheckBox_reap.Checked then Shell('printf "reap-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "reap-no\n" >> /opt/vpnpptp/config');
 If CheckBox_rmschap.Checked then Shell('printf "rmschap-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "rmschap-no\n" >> /opt/vpnpptp/config');
 If CheckBox_stateless.Checked then Shell('printf "stateless-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "stateless-no\n" >> /opt/vpnpptp/config');
 If CheckBox_no40.Checked then Shell('printf "no40-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "no40-no\n" >> /opt/vpnpptp/config');
 If CheckBox_no56.Checked then Shell('printf "no56-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "no56-no\n" >> /opt/vpnpptp/config');
 If CheckBox_shorewall.Checked then Shell('printf "shorewall-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "shorewall-no\n" >> /opt/vpnpptp/config');
 If CheckBox_desktop.Checked then Shell('printf "link-desktop-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "link-desktop-no\n" >> /opt/vpnpptp/config');
 If CheckBox_no128.Checked then Shell('printf "no128-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "no128-no\n" >> /opt/vpnpptp/config');
 If IPS then Shell('printf "IPS-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "IPS-no\n" >> /opt/vpnpptp/config');
 If routevpnauto.Checked then Shell('printf "routevpnauto-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "routevpnauto-no\n" >> /opt/vpnpptp/config');
 If networktest.Checked then Shell('printf "networktest-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "networktest-no\n" >> /opt/vpnpptp/config');
 If balloon.Checked then Shell('printf "balloon-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "balloon-no\n" >> /opt/vpnpptp/config');
 If Sudo_ponoff.Checked then Shell('printf "sudo-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "sudo-no\n" >> /opt/vpnpptp/config');
 If Sudo_configure.Checked then Shell('printf "sudo-configure-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "sudo-configure-no\n" >> /opt/vpnpptp/config');
 If Autostart_ponoff.Checked then Shell('printf "autostart-ponoff-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "autostart-ponoff-no\n" >> /opt/vpnpptp/config');
 If Autostartpppd.Checked then Shell('printf "autostart-pppd-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "autostart-pppd-no\n" >> /opt/vpnpptp/config');
 If pppnotdefault.Checked then Shell('printf "pppnotdefault-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "pppnotdefault-no\n" >> /opt/vpnpptp/config');
 Shell('printf "'+EditDNS1.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+EditDNS2.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+EditDNSdop3.Text+'\n" >> /opt/vpnpptp/config');
 If routeDNSauto.Checked then Shell('printf "routednsauto-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "routednsauto-no\n" >> /opt/vpnpptp/config');
 If Unit2.Form2.CheckBoxusepeerdns.Checked then Shell ('printf "usepeerdns-yes\n" >> /opt/vpnpptp/config') else
                                              Shell ('printf "usepeerdns-no\n" >> /opt/vpnpptp/config');
 Shell('printf "'+EditDNS3.Text+'\n" >> /opt/vpnpptp/config');
 Shell('printf "'+EditDNS4.Text+'\n" >> /opt/vpnpptp/config');
 If CheckBox_rpap.Checked then Shell('printf "rpap-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "rpap-no\n" >> /opt/vpnpptp/config');
 If CheckBox_rmschapv2.Checked then Shell('printf "rmschapv2-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "rmschapv2-no\n" >> /opt/vpnpptp/config');
 If ComboBoxVPN.Text='VPN L2TP' then Shell('printf "l2tp\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "pptp\n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_mru.Text+'\n" >> /opt/vpnpptp/config');

 Shell ('chmod 600 /opt/vpnpptp/config');
//настройка sudoers
If FileExists('/usr/share/applications/ponoff.desktop.old') then //восстанавливаем ярлык запуска ponoff
                                            begin
                                              Shell('cp -f /usr/share/applications/ponoff.desktop.old /usr/share/applications/ponoff.desktop');
                                              Shell('rm -f /usr/share/applications/ponoff.desktop.old');
                                            end;
If FileExists('/usr/share/applications/vpnpptp.desktop.old') then //восстанавливаем ярлык запуска vpnpptp
                                            begin
                                              Shell('cp -f /usr/share/applications/vpnpptp.desktop.old /usr/share/applications/vpnpptp.desktop');
                                              Shell('rm -f /usr/share/applications/vpnpptp.desktop.old');
                                            end;
If FileExists ('/etc/sudoers') then If ((Sudo_ponoff.Checked) or (Sudo_configure.Checked)) then
                              begin
                                AssignFile (FileSudoers,'/etc/sudoers');
                                reset (FileSudoers);
                                Memo_sudo.Lines.Clear;
                                If not FileExists ('/etc/sudoers.old') then Shell('cp -f /etc/sudoers /etc/sudoers.old');
                                While not eof (FileSudoers) do
                                   begin
                                     readln(FileSudoers, str);
                                     If (Sudo_ponoff.Checked) or (Sudo_configure.Checked) then //очистка от старых записей
                                           begin
                                             If ((str<>'ALL ALL=NOPASSWD:/opt/vpnpptp/ponoff') and (str<>'ALL ALL=NOPASSWD:/opt/vpnpptp/vpnpptp')) then
                                             Memo_sudo.Lines.Add(str);
                                           end;
                                   end;
                                 If Sudo_ponoff.Checked then Memo_sudo.Lines.Add('ALL ALL=NOPASSWD:/opt/vpnpptp/ponoff');
                                 If Sudo_configure.Checked then Memo_sudo.Lines.Add('ALL ALL=NOPASSWD:/opt/vpnpptp/vpnpptp');
                                 closefile(FileSudoers);
                                 Shell('rm -f /etc/sudoers');
                                 Memo_sudo.Lines.SaveToFile('/etc/sudoers');
                                 Shell ('chmod 0440 /etc/sudoers');
                              end;
If FileExists ('/etc/sudoers') then If (not(Sudo_ponoff.Checked) and (not Sudo_configure.Checked)) then  //очистка от старых записей
                              begin
                                AssignFile (FileSudoers,'/etc/sudoers');
                                reset (FileSudoers);
                                Memo_sudo.Lines.Clear;
                                While not eof (FileSudoers) do
                                   begin
                                     readln(FileSudoers, str);
                                     If ((str<>'ALL ALL=NOPASSWD:/opt/vpnpptp/ponoff') and (str<>'ALL ALL=NOPASSWD:/opt/vpnpptp/vpnpptp')) then
                                          Memo_sudo.Lines.Add(str);
                                   end;
                                 closefile(FileSudoers);
                                 Shell('rm -f /etc/sudoers');
                                 Memo_sudo.Lines.SaveToFile('/etc/sudoers');
                                 Shell ('chmod 0440 /etc/sudoers');
                              end;
If Sudo_configure.Checked then If not FileExists('/usr/share/applications/vpnpptp.desktop.old') then
                     If FileExists('/usr/share/applications/vpnpptp.desktop') then //правим ярлык запуска vpnpptp
                        begin
                            Shell('cp -f /usr/share/applications/vpnpptp.desktop /usr/share/applications/vpnpptp.desktop.old');
                            Memo_vpnpptp_ponoff_desktop.Lines.LoadFromFile('/usr/share/applications/vpnpptp.desktop');
                            Memonew1.Lines.Clear;
                            For i:=0 to Memo_vpnpptp_ponoff_desktop.Lines.Count-1 do
                              begin
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)='Exec=' then Memonew1.Lines.Add('Exec=sudo /opt/vpnpptp/vpnpptp');
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)<>'Exec=' then
                                    If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-SubstituteUID=true' then
                                       If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-Username=root' then
                                           Memonew1.Lines.Add(Memo_vpnpptp_ponoff_desktop.Lines[i]);
                              end;
                            Memonew1.Lines.SaveToFile('/usr/share/applications/vpnpptp.desktop');
                        end;
If Sudo_ponoff.Checked then If not FileExists('/usr/share/applications/ponoff.desktop.old') then
                     If FileExists('/usr/share/applications/ponoff.desktop') then //правим ярлык запуска ponoff
                        begin
                            Shell('cp -f /usr/share/applications/ponoff.desktop /usr/share/applications/ponoff.desktop.old');
                            Memo_vpnpptp_ponoff_desktop.Lines.Clear;
                            Memo_vpnpptp_ponoff_desktop.Lines.LoadFromFile('/usr/share/applications/ponoff.desktop');
                            Memonew2.Lines.Clear;
                            For i:=0 to Memo_vpnpptp_ponoff_desktop.Lines.Count-1 do
                              begin
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)='Exec=' then Memonew2.Lines.Add('Exec=sudo /opt/vpnpptp/ponoff');
                                 If LeftStr(Memo_vpnpptp_ponoff_desktop.Lines[i],5)<>'Exec=' then
                                    If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-SubstituteUID=true' then
                                       If Memo_vpnpptp_ponoff_desktop.Lines[i]<>'X-KDE-Username=root' then
                                           Memonew2.Lines.Add(Memo_vpnpptp_ponoff_desktop.Lines[i]);
                              end;
                            Memonew2.Lines.SaveToFile('/usr/share/applications/ponoff.desktop');
                        end;
//настройка /etc/rc.d/rc.local
If FileExists ('/etc/rc.d/rc.local') then If (Autostartpppd.Checked) then
                              begin
                                AssignFile (FileAutostartpppd,'/etc/rc.d/rc.local');
                                reset (FileAutostartpppd);
                                Memo_Autostartpppd.Lines.Clear;
                                If not FileExists ('/etc/rc.d/rc.local.old') then Shell('cp -f /etc/rc.d/rc.local /etc/rc.d/rc.local.old');
                                While not eof (FileAutostartpppd) do
                                   begin
                                     readln(FileAutostartpppd, str);
                                     If (leftstr(str,8)<>'dhclient') and (leftstr(str,9)<>'pppd call') and (leftstr(str,26)<>'/etc/init.d/xl2tpd restart') then
                                     Memo_Autostartpppd.Lines.Add(str);
                                   end;
                                 If dhcp_route.Checked then Memo_Autostartpppd.Lines.Add('dhclient '+Edit_eth.Text);
                                 If ComboBoxVPN.Text='VPN PPTP' then Memo_Autostartpppd.Lines.Add('pppd call '+Edit_peer.Text)
                                                                     else Memo_Autostartpppd.Lines.Add('/etc/init.d/xl2tpd restart');
                                 closefile(FileAutostartpppd);
                                 Shell('rm -f /etc/rc.d/rc.local');
                                 Memo_Autostartpppd.Lines.SaveToFile('/etc/rc.d/rc.local');
                                 Shell ('chmod +x /etc/rc.d/rc.local');
                              end;
If FileExists ('/etc/rc.d/rc.local') then If not Autostartpppd.Checked then  //очистка от старых записей
                              begin
                                AssignFile (FileAutostartpppd,'/etc/rc.d/rc.local');
                                reset (FileAutostartpppd);
                                Memo_Autostartpppd.Lines.Clear;
                                While not eof (FileAutostartpppd) do
                                   begin
                                     readln(FileAutostartpppd, str);
                                     If (leftstr(str,8)<>'dhclient') and (leftstr(str,9)<>'pppd call') and (leftstr(str,26)<>'/etc/init.d/xl2tpd restart') then
                                     Memo_Autostartpppd.Lines.Add(str);
                                   end;
                                 closefile(FileAutostartpppd);
                                 Shell('rm -f /etc/rc.d/rc.local');
                                 Memo_Autostartpppd.Lines.SaveToFile('/etc/rc.d/rc.local');
                                 Shell ('chmod +x /etc/rc.d/rc.local');
                              end;
 //настраиваем /var/run/ppp/resolv.conf
 endprint:=false;
 i:=0;
 N:=0;
 if EditDNS3.Text='' then EditDNS3.Text:='none';
 if EditDNS4.Text='' then EditDNS4.Text:='none';
 if EditDNS3.Text<>'none' then if EditDNS4.Text<>'none' then N:=2;
 if (EditDNS3.Text='none') or (EditDNS4.Text='none') then N:=1;
 if EditDNS3.Text='none' then if EditDNS4.Text='none' then N:=0;
 AssignFile (FileResolvConf,'/etc/resolv.conf');
 reset (FileResolvConf);
 While not eof (FileResolvConf) do
     begin
        readln(FileResolvConf, str);
        if LeftStr(str,11)<>'nameserver ' then Shell('printf "'+str+'\n" >> /var/run/ppp/resolv.conf');
        if LeftStr(str,11)='nameserver ' then i:=i+1;
        if LeftStr(str,11)='nameserver ' then if not endprint then
                                       begin
                                            if EditDNS3.Text<>'' then if EditDNS3.Text<>'none' then Shell ('printf "nameserver '+EditDNS3.Text+'\n" >> /var/run/ppp/resolv.conf');
                                            if EditDNS4.Text<>'' then if EditDNS4.Text<>'none' then Shell ('printf "nameserver '+EditDNS4.Text+'\n" >> /var/run/ppp/resolv.conf');
                                            endprint:=true;
                                       end;
        if LeftStr(str,11)='nameserver ' then if i>N then Shell('printf "'+str+'\n" >> /var/run/ppp/resolv.conf');
     end;
 closefile(FileResolvConf);
//настройка /etc/ppp/chap-secrets
If FileExists('/etc/ppp/chap-secrets.old') then
                                            begin
                                               Shell('cp -f /etc/ppp/chap-secrets.old /etc/ppp/chap-secrets');
                                               Shell ('rm -f /etc/ppp/chap-secrets.old');
                                            end;
//настройка /etc/xl2tpd/xl2tpd.conf
 If ComboBoxVPN.Text='VPN L2TP' then If not FileExists('/etc/xl2tpd/xl2tpd.conf.old') then Shell('cp -f /etc/xl2tpd/xl2tpd.conf /etc/xl2tpd/xl2tpd.conf.old');
 If ComboBoxVPN.Text='VPN L2TP' then Shell ('rm -f /etc/xl2tpd/xl2tpd.conf');
 If ComboBoxVPN.Text='VPN L2TP' then
                                  begin
                                       Shell('printf "'+'[global]'+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       Shell('printf "'+'access control = yes'+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       Shell('printf "\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       Shell('printf "'+'[lac '+Edit_peer.Text+']'+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       Shell('printf "'+'name = '+Edit_user.Text+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       Shell('printf "'+'lns = '+Edit_IPS.Text+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       If Reconnect_pptp.Checked then If Edit_MinTime.Text<>'0' then Shell('printf "'+'redial = yes'+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       If Reconnect_pptp.Checked then If Edit_MinTime.Text='0' then Shell('printf "'+'redial = no'+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       If Reconnect_pptp.Checked then If Edit_MinTime.Text<>'0' then Shell('printf "'+'redial timeout = '+LeftStr(Edit_MinTime.Text,Length(Edit_MinTime.Text)-3)+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       Shell('printf "'+'pppoptfile = /etc/ppp/peers/'+Edit_peer.Text+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       Shell('printf "'+'autodial = yes'+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                       If Pppd_log.Checked then Shell('printf "'+'ppp debug = yes'+'\n" >> /etc/xl2tpd/xl2tpd.conf');
                                  end;
 //настройка ведения логов
 Shell ('rm -f /etc/syslog.conf.tmp');
 AssignFile (FileSyslog,'/etc/syslog.conf');
 reset (FileSyslog);
 While not eof (FileSyslog) do
     begin
         readln(FileSyslog, str);
         If LeftStr(str,5)<>'!pppd' then if LeftStr(str,4)<>'!ppp' then
                     if RightStr(str,17)<>'/var/log/pppd.log' then
                                    if RightStr(str,16)<>'/var/log/ppp.log' then
                                          if LeftStr(str,7)<>'!xl2tpd' then if RightStr(str,19)<>'/var/log/xl2tpd.log' then
                                                       Shell ('printf "'+str+'\n" >> /etc/syslog.conf.tmp');
     end;
 closefile(FileSyslog);
 Shell ('cp -f /etc/syslog.conf.tmp /etc/syslog.conf');
 Shell ('rm -f /etc/syslog.conf.tmp');
 If Pppd_log.Checked then If FileExists ('/etc/syslog.conf') then
                          begin
                              If ComboBoxVPN.Text='VPN PPTP' then Shell ('sed -i '+chr(39)+'$ a !pppd\n*.*\t\t\t\t\t\t/var/log/pppd.log'+chr(39)+' /etc/syslog.conf');
                              If ComboBoxVPN.Text='VPN L2TP' then Shell ('sed -i '+chr(39)+'$ a !xl2tpd\n*.*\t\t\t\t\t\t/var/log/xl2tpd.log'+chr(39)+' /etc/syslog.conf');
                          end;
 Shell ('/etc/rc.d/init.d/syslog restart');
 Shell ('/etc/rc.d/init.d/rsyslog restart');
 //настройка /etc/ppp/options
 if not FileExists('/etc/ppp/options.old') then Shell('cp -f /etc/ppp/options /etc/ppp/options.old');
 Shell('echo "#Clear config file" > /etc/ppp/options');
//проверка технической возможности поднятия соединения
EditDNS1ping:=true;
EditDNS2ping:=true;
   //тест EditDNS1-сервера
If EditDNS1.Text<>'' then if EditDNS1.Text<>'none' then
  begin
     If EditDNS1.Text='127.0.0.1' then Shell ('ifup lo');
     Shell('rm -f /tmp/networktest');
     Str:='ping -c2 '+EditDNS1.Text+'|grep '+chr(39)+'2 received'+chr(39)+' > /tmp/networktest';
     Label14.Caption:=message73;
     Application.ProcessMessages;
     Shell(str);
     Application.ProcessMessages;
     Shell('printf "none\n" >> /tmp/networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile('/tmp/networktest');
     If Memo_networktest.Lines[0]='none' then EditDNS1ping:=false;
     Shell('rm -f /tmp/networktest');
  end;
   //тест EditDNS2-сервера
If EditDNS2.Text<>'' then if EditDNS2.Text<>'none' then
  begin
     If EditDNS2.Text='127.0.0.1' then Shell ('ifup lo');
     Shell('rm -f /tmp/networktest');
     Str:='ping -c2 '+EditDNS2.Text+'|grep '+chr(39)+'2 received'+chr(39)+' > /tmp/networktest';
     Label14.Caption:=message75;
     Application.ProcessMessages;
     Shell(str);
     Application.ProcessMessages;
     Shell('printf "none\n" >> /tmp/networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile('/tmp/networktest');
     If Memo_networktest.Lines[0]='none' then EditDNS2ping:=false;
     Shell('rm -f /tmp/networktest');
  end;
If (not EditDNS1ping) and (not EditDNS2ping) then
                                         begin
                                                Label14.Caption:=message74;
                                                Application.ProcessMessages;
                                                pchar_message0:=Pchar(message0);
                                                pchar_message1:=Pchar(message74);
                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                Label14.Caption:=message76;
                                                Application.ProcessMessages;
                                                pchar_message0:=Pchar(message0);
                                                pchar_message1:=Pchar(message76);
                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                         end;
If (EditDNS1ping) and (not EditDNS2ping) then
                                         begin
                                                Label14.Caption:=message84;
                                                Application.ProcessMessages;
                                                pchar_message0:=Pchar(message0);
                                                pchar_message1:=Pchar(message84);
                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                         end;
If (not EditDNS1ping) and (EditDNS2ping) then
                                         begin
                                                Label14.Caption:=message85;
                                                Application.ProcessMessages;
                                                pchar_message0:=Pchar(message0);
                                                pchar_message1:=Pchar(message85);
                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                         end;
   //тест vpn-сервера
If not flag then
   begin
     Shell('rm -f /tmp/networktest');
     Str:='ping -c1 '+Edit_IPS.Text+'|grep '+Edit_IPS.Text+'|awk '+chr(39)+'{ print $3 }'+chr(39)+'|grep '+chr(39)+'('+chr(39)+' > /tmp/networktest';
     Label14.Caption:=message45;
     Application.ProcessMessages;
     Shell(str);
     Application.ProcessMessages;
     Shell('printf "none\n" >> /tmp/networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile('/tmp/networktest');
     If Memo_networktest.Lines[0]='none' then
                                         begin
                                                Label14.Caption:=message43;
                                                Application.ProcessMessages;
                                                pchar_message0:=Pchar(message0);
                                                pchar_message1:=Pchar(message43);
                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                         end;
     Shell('rm -f /tmp/networktest');
   end;
   //тест шлюза локальной сети
     Shell('rm -f /tmp/networktest');
     Str:='ping -c2 '+Edit_gate.Text+'|grep '+chr(39)+'2 received'+chr(39)+' > /tmp/networktest';
     Label14.Caption:=message47;
     Application.ProcessMessages;
     Shell(str);
     Application.ProcessMessages;
     Shell('printf "none\n" >> /tmp/networktest');
     Memo_networktest.Lines.Clear;
     Memo_networktest.Lines.LoadFromFile('/tmp/networktest');
     If Memo_networktest.Lines[0]='none' then
                                         begin
                                                Label14.Caption:=message44;
                                                Application.ProcessMessages;
                                                pchar_message0:=Pchar(message0);
                                                pchar_message1:=Pchar(message44);
                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                         end;
     Shell('rm -f /tmp/networktest');
//Создаем ярлык для подключения
 gksu:=false;
 link_on_desktop:=false;
 If CheckBox_desktop.Checked then If FileExists('/usr/share/applications/ponoff.desktop') then
                                                        begin
                                                              Memo_create.Clear;
                                                              Memo_create.Lines.LoadFromFile('/usr/share/applications/ponoff.desktop');
                                                              For i:=0 to Memo_create.Lines.Count-1 do
                                                                begin
                                                                    If LeftStr(Memo_create.Lines[i],9)='Exec=gksu' then gksu:=true;
                                                                end;
                                                        end;
 If CheckBox_desktop.Checked then If not FileExists('/usr/share/applications/ponoff.desktop') then
                                                               begin
                                                                   //невозможно создать ярлык на рабочем столе
                                                                   pchar_message0:=Pchar(message0);
                                                                   pchar_message1:=Pchar(message23);
                                                                   Label14.Caption:=message23;
                                                                   Application.ProcessMessages;
                                                                   Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                   StartMessage:=false;
                                                                   CheckBox_desktop.Checked:=false;
                                                                   StartMessage:=true;
                                                               end;
 If CheckBox_desktop.Checked then
begin
  Memo_create.Clear;
  Memo_create.Lines.Add('[Desktop Entry]');
  Memo_create.Lines.Add('Encoding=UTF-8');
  Memo_create.Lines.Add('Comment[ru]=Управление соединением VPN PPTP/L2TP');
  Memo_create.Lines.Add('Comment[uk]=Управління з'' єднанням VPN PPTP/L2TP');
  Memo_create.Lines.Add('Comment=Control VPN via PPTP/L2TP');
  If not Sudo_ponoff.Checked then
     begin
         If not gksu then Memo_create.Lines.Add('Exec=/opt/vpnpptp/ponoff') else Memo_create.Lines.Add('Exec=gksu -u root -l /opt/vpnpptp/ponoff');
     end;
  If Sudo_ponoff.Checked then
     begin
         Memo_create.Lines.Add('Exec=sudo /opt/vpnpptp/ponoff');
     end;
  Memo_create.Lines.Add('GenericName[ru]=Управление соединением VPN PPTP/L2TP');
  Memo_create.Lines.Add('GenericName[uk]=Управління з'' єднанням VPN PPTP/L2TP');
  Memo_create.Lines.Add('GenericName=VPN PPTP/L2TP Control');
  Memo_create.Lines.Add('Icon=/opt/vpnpptp/ponoff.png');
  Memo_create.Lines.Add('MimeType=');
  Memo_create.Lines.Add('Name[ru]=Подключение '+Edit_peer.Text);
  Memo_create.Lines.Add('Name[uk]=Підключення '+Edit_peer.Text);
  Memo_create.Lines.Add('Name=Connect '+Edit_peer.Text);
  Memo_create.Lines.Add('Path=');
  Memo_create.Lines.Add('StartupNotify=true');
  Memo_create.Lines.Add('Terminal=false');
  Memo_create.Lines.Add('TerminalOptions=');
  Memo_create.Lines.Add('Type=Application');
  Memo_create.Lines.Add('Categories=GTK;System;Monitor;X-MandrivaLinux-CrossDesktop');
  If not Sudo_ponoff.Checked then Memo_create.Lines.Add('X-KDE-SubstituteUID=true');
  If not Sudo_ponoff.Checked then Memo_create.Lines.Add('X-KDE-Username=root');
  Memo_create.Lines.Add('X-KDE-autostart-after=kdesktop');
  Memo_create.Lines.Add('StartupNotify=false');
//Получаем список пользователей для создания иконки на рабочем столе
  Shell('cat /etc/passwd | grep 100 | cut -d: -f1 > /tmp/users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile('/tmp/users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if (DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/')) or (DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/')) then
      begin
       if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+message7+'/ponoff.desktop');
       if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then Shell ('chmod a+x '+'"'+'/home/'+Memo_users.Lines[i]+'/'+message7+'/ponoff.desktop'+'"');
       If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/ponoff.desktop');
       If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then Shell ('chmod a+x '+'"'+'/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/ponoff.desktop'+'"');
       link_on_desktop:=true;
      end;
      i:=i+1;
    end;
  Shell('cat /etc/passwd | grep 50 | cut -d: -f1 > /tmp/users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile('/tmp/users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if (DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/')) or (DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/')) then
      begin
       if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+message7+'/ponoff.desktop');
       if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then Shell ('chmod a+x '+'"'+'/home/'+Memo_users.Lines[i]+'/'+message7+'/ponoff.desktop'+'"');
       If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/ponoff.desktop');
       If message7<>'Desktop' then if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/') then Shell ('chmod a+x '+'"'+'/home/'+Memo_users.Lines[i]+'/'+'Desktop'+'/ponoff.desktop'+'"');
       link_on_desktop:=true;
      end;
      i:=i+1;
    end;
end;
    If CheckBox_desktop.Checked then If not link_on_desktop then If FileExists('/usr/share/applications/ponoff.desktop') then
                               begin
                                    pchar_message0:=Pchar(message0);
                                    pchar_message1:=Pchar(message22);
                                    Label14.Caption:=message22;
                                    Application.ProcessMessages;
                                    Application.MessageBox(pchar_message1,pchar_message0, 0);
                               end;
//Получаем список пользователей для автозапуска ponoff при старте системы и организация автозапуска
  Shell('cat /etc/passwd | grep 100 | cut -d: -f1 > /tmp/users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile('/tmp/users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if not DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then Shell ('mkdir /home/'+Memo_users.Lines[i]+'/.config/autostart/');
      if DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then
      begin
       FlagAutostartPonoff:=true;
       If Autostart_ponoff.Checked then Shell ('cp -f /usr/share/applications/ponoff.desktop /home/'+Memo_users.Lines[i]+'/.config/autostart/');
       If not Autostart_ponoff.Checked then Shell ('rm -f /home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
      end;
      i:=i+1;
    end;
  Shell('cat /etc/passwd | grep 50 | cut -d: -f1 > /tmp/users');
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile('/tmp/users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if not DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then Shell ('mkdir /home/'+Memo_users.Lines[i]+'/.config/autostart/');
      if DirectoryExists('/home/'+Memo_users.Lines[i]+'/.config/autostart/') then
      begin
       FlagAutostartPonoff:=true;
       If Autostart_ponoff.Checked then Shell ('cp -f /usr/share/applications/ponoff.desktop /home/'+Memo_users.Lines[i]+'/.config/autostart/');
       If not Autostart_ponoff.Checked then Shell ('rm -f /home/'+Memo_users.Lines[i]+'/.config/autostart/ponoff.desktop');
      end;
      i:=i+1;
    end;
 //обработка ошибок организации автозапуска ponoff
  If Autostart_ponoff.Checked then If not FlagAutostartPonoff then
                               begin
                                    pchar_message0:=Pchar(message0);
                                    pchar_message1:=Pchar(message60);
                                    Label14.Caption:=message60;
                                    Application.ProcessMessages;
                                    Application.MessageBox(pchar_message1,pchar_message0, 0);
                               end;
 If Autostart_ponoff.Checked then If not FileExists ('/usr/share/applications/ponoff.desktop') then
                               begin
                                    pchar_message0:=Pchar(message0);
                                    pchar_message1:=Pchar(message61);
                                    Label14.Caption:=message61;
                                    Application.ProcessMessages;
                                    Application.MessageBox(pchar_message1,pchar_message0, 0);
                               end;
              Button_create.Visible:=True;
              TabSheet2.TabVisible:= False;
              TabSheet1.TabVisible:= False;
              TabSheet3.TabVisible:= False;
              TabSheet4.TabVisible:= True;
              PageControl1.ActivePageIndex:=3;
              Button_next2.Visible:=False;
 Memo_create.Clear;
 If FallbackLang='ru' then  begin Memo_create.Lines.LoadFromFile('/opt/vpnpptp/lang/success.ru'); Translate:=true; end;
 If FallbackLang='uk' then  begin Memo_create.Lines.LoadFromFile('/opt/vpnpptp/lang/success.uk'); Translate:=true; end;
 If not Translate then  Memo_create.Lines.LoadFromFile('/opt/vpnpptp/lang/success.en');
 Button_create.Visible:=False;
 Shell('rm -f /tmp/users');
 Button_exit.Enabled:=true;
 ButtonTest.Caption:=message109;
 ButtonTest.Visible:=true;
 Application.ProcessMessages;
end;

procedure TForm1.Button_addoptionsClick(Sender: TObject);
begin

end;

procedure TForm1.ButtonVPNClick(Sender: TObject);
//определение ip vpn-сервера по кнопке
var
   str0,str:string;
   pchar_message0,pchar_message1:pchar;
begin
  str0:=ButtonVPN.Caption;
  ButtonVPN.Caption:=message53;
  Application.ProcessMessages;
  Shell('rm -f /tmp/ip_IPS');
  If StartMessage then If Edit_IPS.Text='' then
                                             begin
                                                ButtonVPN.Caption:=str0;
                                                Application.ProcessMessages;
                                                pchar_message0:=Pchar(message0);
                                                pchar_message1:=Pchar(message28);
                                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                exit;
                                             end;
  Shell('ping -c1 '+Edit_IPS.Text+'|grep '+Edit_IPS.Text+'|awk '+chr(39)+'{ print $3 }'+chr(39)+'|grep '+chr(39)+'('+chr(39)+' > /tmp/ip_IPS');
  Shell('printf "none" >> /tmp/ip_IPS');
  Memo_ip_IPS.Clear;
  If FileExists('/tmp/ip_IPS') then Memo_ip_IPS.Lines.LoadFromFile('/tmp/ip_IPS');
  Str:=Memo_ip_IPS.Lines[0];
  If StartMessage then If Str='none' then
                                     begin
                                          ButtonVPN.Caption:=str0;
                                          Application.ProcessMessages;
                                          pchar_message0:=Pchar(message0);
                                          pchar_message1:=Pchar(message26);
                                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                                          exit;
                                     end;
If Str <>'none' then Str:=DeleteSym(')',Str);
If Str <>'none' then Str:=DeleteSym('(',Str);
If Str <>'none' then Edit_IPS.Text:=Str;
Shell('rm -f /tmp/ip_IPS');
ButtonVPN.Caption:=message52;
Application.ProcessMessages;
sleep(2000);
ButtonVPN.Caption:=str0;
Application.ProcessMessages;
end;

procedure TForm1.balloonChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
 If balloon.Checked then
                         balloon.Checked:=true
                                                   else
                                                       balloon.Checked:=false;
  If StartMessage then If balloon.Checked then
                       begin
                          StartMessage:=false;
                          networktest.Checked:=false;
                          StartMessage:=true;
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message40);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.ButtonHelpClick(Sender: TObject);
begin
    If FallbackLang='ru' then Shell(Stroowriter+' /opt/vpnpptp/wiki/Help_ru.doc');
    If FallbackLang='uk' then Shell(Stroowriter+' /opt/vpnpptp/wiki/Help_uk.doc');
end;

procedure TForm1.ButtonHidePassClick(Sender: TObject);
begin
  If Edit_passwd.EchoMode=emPassword then
     begin
          Edit_passwd.EchoMode:=emNormal;
          ButtonHidePass.Caption:=message87;
          Application.ProcessMessages;
          exit;
    end;
  If Edit_passwd.EchoMode=emNormal then
     begin
          Edit_passwd.EchoMode:=emPassword;
          ButtonHidePass.Caption:=message86;
          Application.ProcessMessages;
          exit;
    end;
end;

procedure TForm1.ButtonRestartClick(Sender: TObject);
var i:integer;
    a:boolean;
//рестарт сети
begin
a:=ButtonHelp.Enabled;
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
Application.ProcessMessages;
    For i:=0 to 9 do
        begin
          Shell ('ifdown eth'+IntToStr(i));
          Shell ('ifdown wlan'+IntToStr(i));
        end;
    Shell ('/etc/init.d/network stop');
    Shell ('/etc/init.d/network start');
    For i:=0 to 9 do
        begin
          Shell ('ifup eth'+IntToStr(i));
          Shell ('ifup wlan'+IntToStr(i));
        end;
    Shell ('ifup lo');
ButtonRestart.Caption:=message93;
Button_exit.Enabled:=true;
Button_next1.Enabled:=true;
ButtonHelp.Enabled:=a;
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
end;

procedure TForm1.ButtonTestClick(Sender: TObject);
 //тестовый запуск сконфигурированного соединения
var
 pchar_message0,pchar_message1:pchar;
 Otvet:integer;
 i,j,k:integer;
 flag:boolean;
begin
 pchar_message0:=Pchar(message0);
 pchar_message1:=Pchar(message108);
 Otvet:=Application.MessageBox(pchar_message1,pchar_message0, 3);
 If Otvet=mrCancel then exit;
 ButtonTest.Enabled:=false;
 If Otvet=mrYes then AProcess := TProcess.Create(nil);
 Shell ('rm -f /tmp/test_vpn');
 Memo_create.Clear;
 If Otvet=mrYes then AProcess.CommandLine := '/opt/vpnpptp/ponoff';
 If Otvet=mrYes then AProcess.Execute;
 If ComboBoxVPN.Text='VPN L2TP' then
                                    begin
                                       If Pppd_log.Checked then Shell('printf "\n" >> /var/log/xl2tpd.log');
                                       If Pppd_log.Checked then Shell('printf "'+message109+' VPN L2TP (/var/log/xl2tpd.log)\n" >> /var/log/xl2tpd.log');
                                       If not Pppd_log.Checked then Memo_create.Lines.Add(message109+' VPN L2TP (/var/log/xl2tpd.log)');
                                       If Pppd_log.Checked then If Otvet=mrYes then Shell('printf "'+message111+' /opt/vpnpptp/ponoff'+'\n" >> /var/log/xl2tpd.log');
                                       If not Pppd_log.Checked then If Otvet=mrYes then Memo_create.Lines.Add (message111+' /opt/vpnpptp/ponoff');
                                       If Pppd_log.Checked then If Otvet=mrNo then Shell('printf "'+message111+' /etc/init.d/xl2tpd restart'+'\n" >> /var/log/xl2tpd.log');
                                       If not Pppd_log.Checked then If Otvet=mrNo then Memo_create.Lines.Add (message111+' /etc/init.d/xl2tpd restart');
                                       If Otvet=mrNo then Shell ('/etc/init.d/xl2tpd restart');
                                    end;
 If ComboBoxVPN.Text='VPN PPTP' then
                                    begin
                                        If Pppd_log.Checked then Shell('printf "\n" >> /var/log/pppd.log');
                                        If Pppd_log.Checked then Shell('printf "'+message109+' VPN PPTP (/var/log/pppd.log)\n" >> /var/log/pppd.log');
                                        If not Pppd_log.Checked then Memo_create.Lines.Add (message109+' VPN PPTP (/var/log/pppd.log)');
                                        If Pppd_log.Checked then If Otvet=mrYes then Shell('printf "'+message111+' /opt/vpnpptp/ponoff'+'\n" >> /var/log/pppd.log');
                                        If not Pppd_log.Checked then If Otvet=mrYes then Memo_create.Lines.Add (message111+' /opt/vpnpptp/ponoff');
                                        If Pppd_log.Checked then If Otvet=mrNo then Shell('printf "'+message111+' pppd call '+Edit_peer.Text+'\n" >> /var/log/pppd.log');
                                        If not Pppd_log.Checked then If Otvet=mrNo then Memo_create.Lines.Add (message111+' pppd call '+Edit_peer.Text);
                                        If Otvet=mrNo then Shell ('pppd call '+Edit_peer.Text);
                                    end;
If not Pppd_log.Checked then Memo_create.Lines.Add (message110);
Application.ProcessMessages;
If Pppd_log.Checked then
begin
 While true do
    begin
       If ComboBoxVPN.Text='VPN PPTP' then Shell ('tail -40 /var/log/pppd.log > /tmp/test_vpn');
       If ComboBoxVPN.Text='VPN L2TP' then Shell ('tail -40 /var/log/xl2tpd.log > /tmp/test_vpn');
       If FileExists ('/tmp/test_vpn') then MemoTest.Lines.LoadFromFile('/tmp/test_vpn');
       j:=0;
       While j<=MemoTest.Lines.Count-1 do
         begin
           flag:=false;
           For i:=0 to Memo_create.Lines.Count-1 do
              begin
                    If Memo_create.Lines[i]=MemoTest.Lines[j] then flag:=true;
              end;
           If not flag then If MemoTest.Lines[j]<>'' then
                                                         begin
                                                             For k:=j to MemoTest.Lines.Count-1 do
                                                                  begin
                                                                     Memo_create.Lines.Add(MemoTest.Lines[k]);
                                                                     Application.ProcessMessages;
                                                                  end;
                                                             j:=MemoTest.Lines.Count;
                                                         end;
           j:=j+1;
         end;
       Application.ProcessMessages;
       Sleep(100);
    end;
end;
 Shell ('rm -f /tmp/test_vpn');
 If Otvet=mrYes then AProcess.Free;
end;

procedure TForm1.Autostart_ponoffChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
//проверка установлен ли пакет Sudo
If FileExists ('/usr/bin/sudo') then Sudo:=true else Sudo:=false;
   If Autostart_ponoff.Checked then Autostart_ponoff.Checked:=true else Autostart_ponoff.Checked:=false;
   If StartMessage then If Autostart_ponoff.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message21);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message24);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Autostart_ponoff.Checked:=false;
                          StartMessage:=true;
                          exit;
                       end;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo_ponoff.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message59);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Sudo_ponoff.Checked:=true;
                          StartMessage:=true;
                       end;
   If StartMessage then If Autostartpppd.Checked then If Autostart_ponoff.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message63);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Autostartpppd.Checked:=false;
                          StartMessage:=true;
                       end;
end;

procedure TForm1.AutostartpppdChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
   If Autostartpppd.Checked then Autostartpppd.Checked:=true else Autostartpppd.Checked:=false;
   If StartMessage then If Autostartpppd.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message62);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
   If StartMessage then If Autostartpppd.Checked then If Autostart_ponoff.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message63);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Autostart_ponoff.Checked:=false;
                          StartMessage:=true;
                       end;
If StartMessage then If pppnotdefault.Checked then If Autostartpppd.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message65);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Autostartpppd.Checked:=false;
                          StartMessage:=true;
                       end;
end;

procedure TForm1.Button_exitClick(Sender: TObject);
begin
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');
  Shell ('rm -f /tmp/test_vpn');
  halt;
end;

procedure TForm1.Button_moreClick(Sender: TObject);
begin
     Unit2.Form2.Obrabotka(Edit_peer.Text,more);
     Unit2.Form2.ShowModal;
     more:=true;
end;

procedure TForm1.Button_next3Click(Sender: TObject);
begin
                TabSheet1.TabVisible:= False;
                TabSheet2.TabVisible:= False;
                TabSheet3.TabVisible:= False;
                TabSheet4.TabVisible:= True;
                PageControl1.ActivePageIndex:=3;
                Button_create.Visible:=True;
                Button_next1.Visible:=False;
                Button_next2.Visible:=False;
end;

procedure TForm1.CheckBox_desktopChange(Sender: TObject);
begin

end;

procedure TForm1.CheckBox_no128Change(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_no128.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message92+' '+message88);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_requiredChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_required.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message79+' '+message88);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_rmschapv2Change(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_rmschapv2.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message78+' '+message55);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;

end;

procedure TForm1.CheckBox_rpapChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_rpap.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message77+' '+message55);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.ComboBoxVPNChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
   If ComboBoxVPN.Text='VPN L2TP' then if not FileExists ('/usr/sbin/xl2tpd') then
                     begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message94);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          ComboBoxVPN.Text:='VPN PPTP';
                     end;
   If ComboBoxVPN.Text='VPN L2TP' then Label1.Caption:=message100 else Label1.Caption:=message99;
   Application.ProcessMessages;
end;

procedure TForm1.ComboBoxVPNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=16 then Edit_user.SetFocus;
  if Key=9 then Edit_passwd.SetFocus;
  Key:=0;
end;

procedure TForm1.Edit_mruChange(Sender: TObject);
begin

end;

procedure TForm1.Edit_mtuChange(Sender: TObject);
begin

end;

procedure TForm1.Edit_peerChange(Sender: TObject);
begin

end;

procedure TForm1.Edit_userChange(Sender: TObject);
begin

end;

procedure TForm1.MetkaClick(Sender: TObject);
begin

end;

procedure TForm1.networktestChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
 If networktest.Checked then
                         networktest.Checked:=true
                                                   else
                                                       networktest.Checked:=false;
  If StartMessage then If networktest.Checked then
                       begin
                          StartMessage:=false;
                          balloon.Checked:=false;
                          StartMessage:=true;
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message38);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
  If StartMessage then If not networktest.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message39);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.pppnotdefaultChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
   If StartMessage then If pppnotdefault.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message64);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
If StartMessage then If pppnotdefault.Checked then If Autostartpppd.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message65);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          pppnotdefault.Checked:=false;
                          StartMessage:=true;
                       end;
end;

procedure TForm1.routeDNSautoChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
   If StartMessage then If routeDNSauto.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message71);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.routevpnautoChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
   If FileExists ('/usr/bin/host') then BindUtils:=true else BindUtils:=false;
   If routevpnauto.Checked then routevpnauto.Checked:=true else routevpnauto.Checked:=false;
   If StartMessage then If routevpnauto.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message37);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
   If StartMessage then If routevpnauto.Checked then If not BindUtils then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message29);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_no40Change(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_no40.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message90+' '+message88);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_no56Change(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_no56.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message91+' '+message88);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_rchapChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_rchap.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message58+' '+message55);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_reapChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_reap.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message70+' '+message55);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_rmschapChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_rmschap.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message72+' '+message55);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_shorewallChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If CheckBox_shorewall.Checked then
                         CheckBox_shorewall.Checked:=true
                                                   else
                                                       CheckBox_shorewall.Checked:=false;
  If StartMessage then If CheckBox_shorewall.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message34);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
  If StartMessage then If not CheckBox_shorewall.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message36);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.CheckBox_statelessChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If StartMessage then If CheckBox_stateless.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message89+' '+message88);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.dhcp_routeChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If dhcp_route.Checked then
                         dhcp_route.Checked:=true
                                                   else
                                                       dhcp_route.Checked:=false;
  If StartMessage then If dhcp_route.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message33);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
  If StartMessage then If dhcp_route.Checked then if not dhclient then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message27);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          dhcp_route.Checked:=false;
                          StartMessage:=true;
                          exit;
                       end;
  If StartMessage then If not dhcp_route.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message35);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.Label38Click(Sender: TObject);
begin

end;

procedure TForm1.Memo_configChange(Sender: TObject);
begin

end;

procedure TForm1.Memo_createChange(Sender: TObject);
begin

end;


procedure TForm1.Mii_tool_noChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
  If Mii_tool_no.Checked then
                         Mii_tool_no.Checked:=true
                                                   else
                                                       Mii_tool_no.Checked:=false;
   If StartMessage then If Mii_tool_no.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message30);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.Button_next1Click(Sender: TObject);
var
   i:word;
   y:boolean;
   pchar_message0,pchar_message1:pchar;
   j:byte; //точка в написании шлюза
   a,b,c,d:string; //a.b.c.d-это шлюз
   FileResolv_conf:textfile;
   str:string;
begin
 y:=false;
//проверка корректности ввода времени дозвона
    if  Length(Edit_MaxTime.Text)>1 then if Edit_MaxTime.Text[1]='0' then Edit_MaxTime.Text:='0';
    for i:=1 to Length(Edit_MaxTime.Text) do
        if not (Edit_MaxTime.Text[i] in ['0'..'9']) then y:=true;
    if y or (Edit_MaxTime.Text='') or (Edit_MaxTime.Text='0') or (Length(Edit_MaxTime.Text)>3) then
            begin
              pchar_message0:=Pchar(message0);
              pchar_message1:=Pchar(message8);
              Application.MessageBox(pchar_message1,pchar_message0, 0);
              Edit_MaxTime.Text:='10';
              exit;
            end;
    if (StrToInt(Edit_MaxTime.Text)<5) or (StrToInt(Edit_MaxTime.Text)>255) then
             begin
               pchar_message0:=Pchar(message0);
               pchar_message1:=Pchar(message8);
               Application.MessageBox(pchar_message1,pchar_message0, 0);
               Edit_MaxTime.Text:='10';
               exit;
             end;
//проверка корректности ввода времени реконнекта
y:=false;
    if  Length(Edit_MinTime.Text)>1 then if Edit_MinTime.Text[1]='0' then Edit_MinTime.Text:='0';
    for i:=1 to Length(Edit_MinTime.Text) do
        if not (Edit_MinTime.Text[i] in ['0'..'9']) then y:=true;
    if y or (Edit_MinTime.Text='') or (StrToInt(Edit_MinTime.Text)>255) or (Length(Edit_MinTime.Text)>3) then
            begin
              pchar_message0:=Pchar(message0);
              pchar_message1:=Pchar(message10);
              Application.MessageBox(pchar_message1,pchar_message0, 0);
              Edit_MinTime.Text:='3';
              exit;
            end;
//проверка корректности ввода иных полей настроек подключения
if (Edit_IPS.Text='') or (Edit_peer.Text='') or (Edit_user.Text='') or (Edit_passwd.Text='') then
                            begin
                                pchar_message0:=Pchar(message0);
                                pchar_message1:=Pchar(message1);
                                Application.MessageBox(pchar_message1,pchar_message0, 0);
                                exit;
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
Try
    StrToInt(a);
    StrToInt(b);
    StrToInt(c);
    StrToInt(d);
  except
    On EConvertError do
      y:=true;
  end;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
If not y then if not ((StrToInt(a)>=0) and (StrToInt(a)<=255)) then y:=true;
If not y then if not ((StrToInt(b)>=0) and (StrToInt(b)<=255)) then y:=true;
If not y then if not ((StrToInt(c)>=0) and (StrToInt(c)<=255)) then y:=true;
If not y then if not ((StrToInt(d)>=0) and (StrToInt(d)<=255)) then y:=true;
If not y then if not y then Form1.Edit_IPS.Text:=IntToStr(StrToInt(a))+'.'+IntToStr(StrToInt(b))+'.'+IntToStr(StrToInt(c))+'.'+IntToStr(StrToInt(d)); //сократятся лишние нули, введенные в начале любого из октетов (или квадрантов)
If not y then IPS:=true else IPS:=false;
//определяем шлюз по умолчанию
  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('printf "none" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  Edit_gate.Text:=Memo_gate.Lines[0];
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then
                                         begin
                                           Edit_gate.Text:='none';
                                           Edit_eth.Text:='none';
                                           pchar_message0:=Pchar(message0);
                                           pchar_message1:=Pchar(message11);
                                           Application.MessageBox(pchar_message1,pchar_message0, 0);
                                         end;
//определяем сетевой интерфейс по умолчанию
  Shell('/sbin/ip r|grep default| awk '+chr(39)+'{ print $5 }'+chr(39)+' > /tmp/eth');
  Shell('printf "none" >> /tmp/eth');
  Memo_eth.Clear;
  If FileExists('/tmp/eth') then Memo_eth.Lines.LoadFromFile('/tmp/eth');
  Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],4);
  If Edit_eth.Text='wlan' then Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],5);
  If Edit_eth.Text='none' then
                           begin
                             Edit_gate.Text:='none';
                             pchar_message0:=Pchar(message0);
                             pchar_message1:=Pchar(message12);
                             Application.MessageBox(pchar_message1,pchar_message0, 0);
                           end;
  If RightStr(Memo_eth.Lines[0],7)='no link' then
                           begin
                             Edit_eth.Text:='none';
                             Edit_gate.Text:='none';
                             pchar_message0:=Pchar(message0);
                             pchar_message1:=Pchar(message13);
                             Application.MessageBox(pchar_message1,pchar_message0, 0);
                           end;
  If Edit_gate.Text='none' then
                           begin
                             Edit_eth.Text:='none';
                             pchar_message0:=Pchar(message0);
                             pchar_message1:=Pchar(message14);
                             Application.MessageBox(pchar_message1,pchar_message0, 0);
                           end;
  //определяем DNSA, DNSB и DNSdopC
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then
                                         begin
                                              DNSA:='none';
                                              DNSB:='none';
                                              DNSdopC:='none';
                                         end;
  If FileExists('/etc/resolv.conf') then If not (LeftStr(Memo_gate.Lines[0],3)='ppp') then
                                    begin
                                      AssignFile (FileResolv_conf,'/etc/resolv.conf');
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
  If DNSA='none' then if DNSB='none' then
                           begin
                             DNS_auto:=false;
                             pchar_message0:=Pchar(message0);
                             pchar_message1:=Pchar(message66);
                             Application.MessageBox(pchar_message1,pchar_message0, 0);
                           end;
  EditDNS1.Text:=DNSA;
  EditDNS2.Text:=DNSB;
  DNSC:=DNSA;
  DNSD:=DNSB;
  EditDNSdop3.Text:=DNSdopC;
  EditDNS3.Text:=DNSA;
  EditDNS4.Text:=DNSB;
  If not FileExists ('/opt/vpnpptp/route') then Memo_route.Clear;
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');
  If ComboBoxVPN.Text='VPN L2TP' then Reconnect_pptp.Caption:=message96;
  If ComboBoxVPN.Text='VPN L2TP' then Pppd_log.Caption:=message97;
  If ComboBoxVPN.Text='VPN L2TP' then Autostartpppd.Caption:=message98;
  If ComboBoxVPN.Text='VPN L2TP' then pppnotdefault.Caption:=message5;
  If ComboBoxVPN.Text='VPN L2TP' then begin StartMessage:=false; CheckBox_required.Enabled:=false; CheckBox_required.Checked:=false; StartMessage:=true; end;
  If ComboBoxVPN.Text='VPN L2TP' then begin StartMessage:=false; CheckBox_stateless.Enabled:=false; CheckBox_stateless.Checked:=false; StartMessage:=true; end;
  If ComboBoxVPN.Text='VPN L2TP' then begin StartMessage:=false; CheckBox_no40.Enabled:=false; CheckBox_no40.Checked:=false; StartMessage:=true; end;
  If ComboBoxVPN.Text='VPN L2TP' then begin StartMessage:=false; CheckBox_no56.Enabled:=false; CheckBox_no56.Checked:=false; StartMessage:=true; end;
  If ComboBoxVPN.Text='VPN L2TP' then begin StartMessage:=false; CheckBox_no128.Enabled:=false; CheckBox_no128.Checked:=false; StartMessage:=true; end;
  Application.ProcessMessages;
end;

procedure TForm1.Button_next2Click(Sender: TObject);
var
   i:byte;
   j:byte; //точка в написании шлюза
   y:boolean;
   a,b,c,d:string; //a.b.c.d-это шлюз
   pchar_message0,pchar_message1:pchar;
begin
y:=false;
//проверка корректности ввода сетевого интерфейса
If (Edit_eth.Text='none') or (Edit_eth.Text='') then
                    begin
                         pchar_message0:=Pchar(message0);
                         pchar_message1:=Pchar(message15);
                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                         Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],4);
                         If Edit_eth.Text='wlan' then Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],5);
                         If Edit_eth.Text='link' then
                                                 begin
                                                      Edit_eth.Text:='none';
                                                      Edit_gate.Text:='none';
                                                 end;
                         TabSheet2.TabVisible:= True;
                         exit;
                    end;
if not Length(Edit_eth.Text) in [4,5] then
                    begin
                         pchar_message0:=Pchar(message0);
                         pchar_message1:=Pchar(message15);
                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                         Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],4);
                         If Edit_eth.Text='wlan' then Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],5);
                         TabSheet2.TabVisible:= True;
                         exit;
                    end;
if not ((Edit_eth.Text[1]='e') and  (Edit_eth.Text[2]='t') and  (Edit_eth.Text[3]='h')) then y:=true;
if not (Edit_eth.Text[4] in ['0'..'9']) then y:=true;
if (Edit_eth.Text[1]='w') then if (Edit_eth.Text[2]='l') then if (Edit_eth.Text[3]='a') then if (Edit_eth.Text[4]='n') then if (Edit_eth.Text[5] in ['0'..'9']) then y:=false;
if y then
                    begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message15);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],4);
                          If Edit_eth.Text='wlan' then Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],5);
                          TabSheet2.TabVisible:= True;
                          exit;
                    end;
//wlanN не поддерживается mii-tool
If not FileExists('/opt/vpnpptp/config') then if LeftStr(Edit_eth.Text,4)='wlan' then
                                                                                 begin
                                                                                   StartMessage:=false;
                                                                                   Mii_tool_no.Checked:=true;
                                                                                   StartMessage:=true;
                                                                                 end;
//VmWare не поддерживает mii-tool при использовании NAT
If not FileExists('/opt/vpnpptp/config') then if ((Edit_gate.Text='172.16.16.2') and (EditDNS3.Text='172.16.16.2')) then
                                                                                 begin
                                                                                   StartMessage:=false;
                                                                                   Mii_tool_no.Checked:=true;
                                                                                   StartMessage:=true;
                                                                                 end;
//проверка корректности ввода шлюза локальной сети
If (Edit_gate.Text='none') or (Edit_gate.Text='') or (Length(Edit_gate.Text)>15) then //15-макс.длина шлюза 255.255.255.255
                    begin
                         pchar_message0:=Pchar(message0);
                         pchar_message1:=Pchar(message16);
                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                         Edit_gate.Text:=Memo_gate.Lines[0];
                         If LeftStr(Edit_gate.Text,3)='ppp' then Edit_gate.Text:='none';
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
Try
    StrToInt(a);
    StrToInt(b);
    StrToInt(c);
    StrToInt(d);
  except
    On EConvertError do
      y:=true;
  end;
If y then
         begin
           pchar_message0:=Pchar(message0);
           pchar_message1:=Pchar(message16);
           Application.MessageBox(pchar_message1,pchar_message0, 0);
           Edit_gate.Text:=Memo_gate.Lines[0];
           exit;
         end;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
If not ((StrToInt(a)>=0) and (StrToInt(a)<=255)) then y:=true;
If not ((StrToInt(b)>=0) and (StrToInt(b)<=255)) then y:=true;
If not ((StrToInt(c)>=0) and (StrToInt(c)<=255)) then y:=true;
If not ((StrToInt(d)>=0) and (StrToInt(d)<=255)) then y:=true;
If y then
         begin
           pchar_message0:=Pchar(message0);
           pchar_message1:=Pchar(message16);
           Application.MessageBox(pchar_message1,pchar_message0, 0);
           Edit_gate.Text:=Memo_gate.Lines[0];
           exit;
         end;
 Edit_gate.Text:=IntToStr(StrToInt(a))+'.'+IntToStr(StrToInt(b))+'.'+IntToStr(StrToInt(c))+'.'+IntToStr(StrToInt(d)); //сократятся лишние нули, введенные в начале любого из октетов (или квадрантов)
//проверка корректности ввода EditDNS3
If Length(EditDNS3.Text)>15 then //15-макс.длина шлюза 255.255.255.255
                    begin
                         pchar_message0:=Pchar(message0);
                         pchar_message1:=Pchar(message81);
                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                         EditDNS3.Text:='none';
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
Try
    StrToInt(a);
    StrToInt(b);
    StrToInt(c);
    StrToInt(d);
  except
    On EConvertError do
      y:=true;
  end;
If y then if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then
         begin
           pchar_message0:=Pchar(message0);
           pchar_message1:=Pchar(message81);
           Application.MessageBox(pchar_message1,pchar_message0, 0);
           EditDNS3.Text:='none';
           exit;
         end;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then
begin
If not ((StrToInt(a)>=0) and (StrToInt(a)<=255)) then y:=true;
If not ((StrToInt(b)>=0) and (StrToInt(b)<=255)) then y:=true;
If not ((StrToInt(c)>=0) and (StrToInt(c)<=255)) then y:=true;
If not ((StrToInt(d)>=0) and (StrToInt(d)<=255)) then y:=true;
end;
If y then if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then
         begin
           pchar_message0:=Pchar(message0);
           pchar_message1:=Pchar(message81);
           Application.MessageBox(pchar_message1,pchar_message0, 0);
           EditDNS3.Text:='none';
           exit;
         end;
if EditDNS3.Text<>'none' then if EditDNS3.Text<>'' then EditDNS3.Text:=IntToStr(StrToInt(a))+'.'+IntToStr(StrToInt(b))+'.'+IntToStr(StrToInt(c))+'.'+IntToStr(StrToInt(d)); //сократятся лишние нули, введенные в начале любого из октетов (или квадрантов)
//проверка корректности ввода EditDNS4
If Length(EditDNS4.Text)>15 then //15-макс.длина шлюза 255.255.255.255
                    begin
                         pchar_message0:=Pchar(message0);
                         pchar_message1:=Pchar(message82);
                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                         EditDNS4.Text:='none';
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
Try
    StrToInt(a);
    StrToInt(b);
    StrToInt(c);
    StrToInt(d);
  except
    On EConvertError do
      y:=true;
  end;
If y then if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then
         begin
           pchar_message0:=Pchar(message0);
           pchar_message1:=Pchar(message82);
           Application.MessageBox(pchar_message1,pchar_message0, 0);
           EditDNS4.Text:='none';
           exit;
         end;
//каждый октет (или квадрант) может принимать значение от 0 до 255, итого 256 значений
if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then
begin
If not ((StrToInt(a)>=0) and (StrToInt(a)<=255)) then y:=true;
If not ((StrToInt(b)>=0) and (StrToInt(b)<=255)) then y:=true;
If not ((StrToInt(c)>=0) and (StrToInt(c)<=255)) then y:=true;
If not ((StrToInt(d)>=0) and (StrToInt(d)<=255)) then y:=true;
end;
If y then if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then
         begin
           pchar_message0:=Pchar(message0);
           pchar_message1:=Pchar(message82);
           Application.MessageBox(pchar_message1,pchar_message0, 0);
           EditDNS4.Text:='none';
           exit;
         end;
if EditDNS4.Text<>'none' then if EditDNS4.Text<>'' then EditDNS4.Text:=IntToStr(StrToInt(a))+'.'+IntToStr(StrToInt(b))+'.'+IntToStr(StrToInt(c))+'.'+IntToStr(StrToInt(d)); //сократятся лишние нули, введенные в начале любого из октетов (или квадрантов)
If ((EditDNS3.Text='none') or (EditDNS3.Text='')) then if ((EditDNS4.Text='none') or (EditDNS4.Text='')) then
                           begin
                             pchar_message0:=Pchar(message0);
                             pchar_message1:=Pchar(message83);
                             Application.MessageBox(pchar_message1,pchar_message0, 0);
                             exit;
                           end;
If EditDNS3.Text='' then EditDNS3.Text:='none';
If EditDNS4.Text='' then EditDNS4.Text:='none';
//проверка ввода mtu, разрешен диапазон [576..1500], рекомендуется 1400, 1460
For i:=1 to Length(Edit_mtu.Text) do
begin
   if not (Edit_mtu.Text[i] in ['0'..'9']) then
                                      begin
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message17);
                                        Application.MessageBox(pchar_message1,pchar_message0, 0);
                                        Edit_mtu.Clear;
                                        exit;
                                      end;
If (StrToInt(Edit_mtu.Text)>1500) or (StrToInt(Edit_mtu.Text)<576) then
                                      begin
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message17);
                                        Application.MessageBox(pchar_message1,pchar_message0, 0);
                                        Edit_mtu.Clear;
                                        exit;
                                      end;
end;
//проверка ввода mru, разрешен диапазон [576..1500]
For i:=1 to Length(Edit_mru.Text) do
begin
   If not (Edit_mru.Text[i] in ['0'..'9']) then
                                      begin
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message104);
                                        Application.MessageBox(pchar_message1,pchar_message0, 0);
                                        Edit_mru.Clear;
                                        exit;
                                      end;
  If (StrToInt(Edit_mru.Text)>1500) or (StrToInt(Edit_mru.Text)<576) then
                                      begin
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message104);
                                        Application.MessageBox(pchar_message1,pchar_message0, 0);
                                        Edit_mru.Clear;
                                        exit;
                                      end;
end;
If ComboBoxVPN.Text='VPN L2TP' then
                               begin
                                   If Edit_mtu.Text<>'' then if (StrToInt(Edit_mtu.Text)>1460) then
                                      begin
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message101+' '+message102);
                                        if Application.MessageBox(pchar_message1,pchar_message0, 1)<>mrOK then exit;
                                      end;
                               end;
If ComboBoxVPN.Text='VPN L2TP' then
                               begin
                                   If Edit_mtu.Text='' then
                                      begin
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message101+' '+message102);
                                        if Application.MessageBox(pchar_message1,pchar_message0, 1)<>mrOK then exit;
                                      end;
                               end;
 Button_more.Visible:=True;
 Button_create.Visible:=True;
 TabSheet1.TabVisible:= False;
 TabSheet2.TabVisible:= False;
 TabSheet3.TabVisible:= True;
 Button_next2.Visible:=False;
 Unit2.Form2.Obrabotka(Edit_peer.Text, more);
 ButtonHelp.Visible:=false;
end;

procedure TForm1.Edit_IPSChange(Sender: TObject);
begin
    Edit_IPS.Text:=DeleteSym (' ',Edit_IPS.Text);
    Edit_IPS.Text:=DeleteSym ('/',Edit_IPS.Text);
    If Length(Edit_IPS.Text)>=2 then If RightStr(Edit_IPS.Text,2)='..' then
                                                    Edit_IPS.Text:=LeftStr(Edit_IPS.Text,(Length(Edit_IPS.Text))-1);
end;

procedure TForm1.Edit_MaxTimeChange(Sender: TObject);
begin

end;

procedure TForm1.Edit_MinTimeChange(Sender: TObject);
begin

end;

procedure TForm1.Edit_passwdChange(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
    pchar_message0,pchar_message1:pchar;
    len:integer;
    Fileoowriter_find:textfile;
    str:string;
begin
//определяем произошел ли запуск при поднятом pppN
  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('printf "none" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then
                                         begin
                                           pchar_message0:=Pchar(message0);
                                           pchar_message1:=Pchar(message105);
                                           if Application.MessageBox(pchar_message1,pchar_message0, 1)<>mrOK then halt;
                                           Shell ('killall ponoff');
                                           Shell('killall pppd');
                                           Shell ('/etc/init.d/xl2tpd stop');
                                           Shell ('killall xl2tpd');
                                           Shell ('killall openl2tpd');
                                           Shell ('killall l2tpd');
                                           ButtonRestartClick(Sender);
                                         end;
Shell ('rm -f /var/run/ppp/resolv.conf');
If not FileExists('/etc/resolv.conf') then //отмена реализации в дистрибутиве отличных от мандривы механизмов работы с resolv.conf
    begin
       Shell ('rm -f /etc/resolv.conf');
       Shell ('rm -f /var/run/ppp/resolv.conf');
       Shell ('resolvconf -u');
    end;
Form1.Caption:=message103;
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
Shell('rm -f /tmp/oowriter_find');
Stroowriter:='none';
Shell ('find /usr/bin/ -name oowriter* >/tmp/oowriter_find');
Shell('printf "none" >> /tmp/oowriter_find');
AssignFile (Fileoowriter_find,'/tmp/oowriter_find');
reset (Fileoowriter_find);
While not eof (Fileoowriter_find) do
       begin
         readln(Fileoowriter_find, str);
         If str<>'none' then If leftstr(str,17)='/usr/bin/oowriter' then Stroowriter:=str;
       end;
closefile(Fileoowriter_find);
Shell('rm -f /tmp/oowriter_find');
If Stroowriter<> 'none' then If FileExists(Stroowriter) then If FallbackLang='ru' then If FileExists('/opt/vpnpptp/wiki/Help_ru.doc') then ButtonHelp.Enabled:=true;
If Stroowriter<> 'none' then If FileExists(Stroowriter) then If FallbackLang='uk' then If FileExists('/opt/vpnpptp/wiki/Help_uk.doc') then ButtonHelp.Enabled:=true;
DNS_auto:=true; //полагается, что EditDNS1 и EditDNS2 получаются автоматически пока не будет доказано обратного
If not Translate then Label25.Caption:='              '+Label25.Caption;
//масштабирование формы в зависимости от разрешения экрана
   Form1.Height:=600;
   Form1.Width:=794;
   //PageControl1.Top:=-26;
   PageControl1.Top:=-31;
   Form1.Position:=poDefault;
   Form1.Top:=0;
   Form1.Left:=0;
   If Screen.Height<440 then
                            begin
                             Form1.Height:=Screen.Height-50;
                             Form1.Width:=Screen.Width;
                             Label1.BorderSpacing.Around:=0;
                             Edit_IPS.BorderSpacing.Around:=0;
                             Label2.BorderSpacing.Around:=0;
                             Edit_peer.BorderSpacing.Around:=0;
                             Label3.BorderSpacing.Around:=0;
                             Edit_user.BorderSpacing.Around:=0;
                             Label4.BorderSpacing.Around:=0;
                             Edit_passwd.BorderSpacing.Around:=0;
                             Label36.BorderSpacing.Around:=0;
                             Edit_MaxTime.BorderSpacing.Around:=0;
                             Label38.BorderSpacing.Around:=0;
                             Edit_MinTime.BorderSpacing.Around:=0;
                             Label6.BorderSpacing.Around:=0;
                             Label8.BorderSpacing.Around:=0;
                             Label7.BorderSpacing.Around:=0;
                             Label11.BorderSpacing.Around:=0;
                             Label37.BorderSpacing.Around:=0;
                             Label39.BorderSpacing.Around:=0;
                             Label41.BorderSpacing.Around:=0;
                             Form1.Constraints.MaxHeight:=Screen.Height-50;
                             Form1.Constraints.MinHeight:=Screen.Height-50;
                             Button_create.BorderSpacing.Left:=Screen.Width-182;
                             ButtonHelp.BorderSpacing.Left:=Screen.Width-182;
                             ButtonTest.BorderSpacing.Left:=Screen.Width-182;
                             PageControl1.Height:=Screen.Height-200;
                             Button_next1.BorderSpacing.Left:=180;
                             Button_next2.BorderSpacing.Left:=180;
                             Button_more.BorderSpacing.Left:=180;
                             Memo_route.Width:=400;
                            end;
   If Screen.Height<=480 then
                        begin
                             Form1.Font.Size:=6;
                             ComboBoxVPN.Font.Size:=6;
                             Form1.Height:=Screen.Height-45;
                             Form1.Width:=Screen.Width;
                             PageControl1.Width:=Screen.Width-1;
                             PageControl1.Height:=Screen.Height-50;
                             Button_create.BorderSpacing.Left:=Screen.Width-182;
                             ButtonHelp.BorderSpacing.Left:=Screen.Width-182;
                             ButtonTest.BorderSpacing.Left:=Screen.Width-182;
                             Memo_create.Width:=Screen.Width-5;
                             Form1.Constraints.MaxHeight:=Screen.Height-45;
                             Form1.Constraints.MinHeight:=Screen.Height-45;
                             Metka.BorderSpacing.Top:=0;
                             Button_next1.BorderSpacing.Left:=220;
                             Button_next2.BorderSpacing.Left:=220;
                             Button_more.BorderSpacing.Left:=220;
                             LabelDNS1.BorderSpacing.Top:=27;
                             LabelDNS2.BorderSpacing.Top:=21;
                             LabelDNS3.BorderSpacing.Top:=27;
                             Memo_route.Width:=470;
                        end;
   If Screen.Height<550 then If not (Screen.Height<=480) then
                         begin
                             Label1.BorderSpacing.Around:=0;
                             Edit_IPS.BorderSpacing.Around:=0;
                             Label2.BorderSpacing.Around:=0;
                             Edit_peer.BorderSpacing.Around:=0;
                             Label3.BorderSpacing.Around:=0;
                             Edit_user.BorderSpacing.Around:=0;
                             Label4.BorderSpacing.Around:=0;
                             Edit_passwd.BorderSpacing.Around:=0;
                             Label36.BorderSpacing.Around:=0;
                             Edit_MaxTime.BorderSpacing.Around:=0;
                             Label38.BorderSpacing.Around:=0;
                             Edit_MinTime.BorderSpacing.Around:=0;
                             Label6.BorderSpacing.Around:=0;
                             Label8.BorderSpacing.Around:=0;
                             Label7.BorderSpacing.Around:=0;
                             Label11.BorderSpacing.Around:=0;
                             Label37.BorderSpacing.Around:=0;
                             Label39.BorderSpacing.Around:=0;
                             Label41.BorderSpacing.Around:=0;
                             Form1.Constraints.MaxHeight:=Screen.Height;
                             Form1.Constraints.MinHeight:=Screen.Height;
                         end;
If Screen.Height>550 then   //разрешение в основном нетбуков
                        begin
                             Form1.Font.Size:=8;
                             ComboBoxVPN.Font.Size:=8;
                             Form1.Height:=550;
                             Form1.Width:=794;
                             Memo_create.Width:=788;
                             Button_create.BorderSpacing.Left:=615;
                             ButtonHelp.BorderSpacing.Left:=615;
                             ButtonTest.BorderSpacing.Left:=615;
                             Form1.Constraints.MaxHeight:=550;
                             Form1.Constraints.MinHeight:=550;
                             Form1.Constraints.MaxWidth:=794;
                             Form1.Constraints.MinWidth:=794;
                        end;
If Screen.Height>1000 then
                        begin
                             Form1.Position:=poScreenCenter;
                             Form1.Font.Size:=10;
                             ComboBoxVPN.Font.Size:=10;
                             Form1.Height:=650;
                             Form1.Width:=884;
                             Memo_create.Width:=880;
                             Button_create.BorderSpacing.Left:=705;
                             ButtonHelp.BorderSpacing.Left:=705;
                             ButtonTest.BorderSpacing.Left:=705;
                             Form1.Constraints.MaxHeight:=650;
                             Form1.Constraints.MinHeight:=650;
                             Form1.Constraints.MaxWidth:=884;
                             Form1.Constraints.MinWidth:=884;
                             PageControl1.Height:=640;
                             Button_next1.BorderSpacing.Left:=350;
                             Button_next2.BorderSpacing.Left:=350;
                             Button_more.BorderSpacing.Left:=350;
                             Label_mtu.BorderSpacing.Top:=20;
                             EditDNS2.BorderSpacing.Top:=40;
                             EditDNS4.BorderSpacing.Top:=35;
                             Memo_route.Width:=650;
                             Edit_mru.BorderSpacing.Top:=40;
                         end;
//проверка vpnpptp в процессах root, исключение двойного запуска программы, исключение запуска под иными пользователями
   Shell('ps -u root | grep vpnpptp | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart');
   Shell('printf "none" >> /tmp/tmpnostart');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart');
   If not (LeftStr(tmpnostart.Lines[0],7)='vpnpptp') then
                                                       begin
                                                         //запуск не под root
                                                         pchar_message0:=Pchar(message0);
                                                         pchar_message1:=Pchar(message18+' '+message107);
                                                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                         Shell('rm -f /tmp/tmpnostart');
                                                         halt;
                                                       end;
   If LeftStr(tmpnostart.Lines[0],7)='vpnpptp' then if LeftStr(tmpnostart.Lines[1],7)='vpnpptp' then
                                                                                                    begin
                                                                                                      //двойной запуск
                                                                                                      pchar_message0:=Pchar(message0);
                                                                                                      pchar_message1:=Pchar(message19);
                                                                                                      Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                                                      Shell('rm -f /tmp/tmpnostart');
                                                                                                      halt;
                                                                                                    end;
//проверка ponoff в процессах root
   Shell('ps -u root | grep ponoff | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart');
   Shell('printf "none" >> /tmp/tmpnostart');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart');
   If LeftStr(tmpnostart.Lines[0],6)='ponoff' then
                                                       begin
                                                         pchar_message0:=Pchar(message0);
                                                         pchar_message1:=Pchar(message4);
                                                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                         Shell('rm -f /tmp/tmpnostart');
                                                         halt;
                                                       end;
//проверка dhclient в процессах root и установлен ли пакет
   dhclient:=true;
   Shell('ps -u root | grep dhclient | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart');
   Shell('printf "none" >> /tmp/tmpnostart');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart');
   If not (LeftStr(tmpnostart.Lines[0],8)='dhclient') then If not FileExists ('/sbin/dhclient') then
                                                       begin
                                                         dhclient:=false;
                                                         pchar_message0:=Pchar(message0);
                                                         pchar_message1:=Pchar(message25);
                                                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                         Shell('rm -f /tmp/tmpnostart');
                                                       end;
//проверка установлен ли пакет Sudo
If FileExists ('/usr/bin/sudo') then Sudo:=true else Sudo:=false;
  Shell('rm -f /tmp/tmpnostart');
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');
  Shell ('rm -f /tmp/ip-down');
 If not FileExists('/usr/sbin/pptp') then
                                    begin
                                       pchar_message0:=Pchar(message0);
                                       pchar_message1:=Pchar(message20);
                                       Application.MessageBox(pchar_message1,pchar_message0, 0);
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
  //восстановление предыдущих введенных данных в конфигураторе
 If FileExists('/opt/vpnpptp/config') then
     begin
        Memo_config.Lines.LoadFromFile('/opt/vpnpptp/config');
        Edit_peer.Text:=Memo_config.Lines[0];
        Edit_IPS.Text:=Memo_config.Lines[1];
        //Edit_gate.Text:=Memo_config.Lines[2];
        //Edit_eth.Text:=Memo_config.Lines[3];
        len:=Length(Memo_config.Lines[4]);
        Edit_MinTime.Text:=LeftStr(Memo_config.Lines[4],len-3);
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
        If Memo_config.Lines[18]='shorewall-yes' then CheckBox_shorewall.Checked:=true else CheckBox_shorewall.Checked:=false;
        If Memo_config.Lines[19]='link-desktop-yes' then CheckBox_desktop.Checked:=true else CheckBox_desktop.Checked:=false;
        If Memo_config.Lines[20]='no128-yes' then CheckBox_no128.Checked:=true else CheckBox_no128.Checked:=false;
        If Memo_config.Lines[21]='IPS-yes' then IPS:=true else IPS:=false;
        If Memo_config.Lines[22]='routevpnauto-yes' then routevpnauto.Checked:=true else routevpnauto.Checked:=false;
        If Memo_config.Lines[23]='networktest-yes' then networktest.Checked:=true else networktest.Checked:=false;
        If Memo_config.Lines[24]='balloon-yes' then balloon.Checked:=true else balloon.Checked:=false;
        If Memo_config.Lines[25]='sudo-yes' then Sudo_ponoff.Checked:=true else Sudo_ponoff.Checked:=false;
        If Memo_config.Lines[26]='sudo-configure-yes' then Sudo_configure.Checked:=true else Sudo_configure.Checked:=false;
        If Memo_config.Lines[27]='autostart-ponoff-yes' then Autostart_ponoff.Checked:=true else Autostart_ponoff.Checked:=false;
        If Memo_config.Lines[28]='autostart-pppd-yes' then Autostartpppd.Checked:=true else Autostartpppd.Checked:=false;
        If Memo_config.Lines[29]='pppnotdefault-yes' then pppnotdefault.Checked:=true else pppnotdefault.Checked:=false;
        //EditDNS1.Text:=Memo_config.Lines[30];
        //EditDNS2.Text:=Memo_config.Lines[31];
        //EditDNSdop3.Text:=Memo_config.Lines[32];
        If Memo_config.Lines[33]='routednsauto-yes' then routeDNSauto.Checked:=true else routeDNSauto.Checked:=false;
        //Memo_config.Lines[34] не восстанавливается из конфига
        //EditDNS3.Text:=Memo_config.Lines[35];
        //EditDNS4.Text:=Memo_config.Lines[36];
        If Memo_config.Lines[37]='rpap-yes' then CheckBox_rpap.Checked:=true else CheckBox_rpap.Checked:=false;
        If Memo_config.Lines[38]='rmschapv2-yes' then CheckBox_rmschapv2.Checked:=true else CheckBox_rmschapv2.Checked:=false;
        If Memo_config.Lines[39]='l2tp' then ComboBoxVPN.Text:='VPN L2TP' else ComboBoxVPN.Text:='VPN PPTP';
        If Memo_config.Lines[39]='l2tp' then Label1.Caption:=message100 else Label1.Caption:=message99;
        Edit_mru.Text:=Memo_config.Lines[40];
        If Edit_mru.Text='mru-none' then Edit_mru.Text:='';
            If FileExists('/etc/ppp/peers/'+Edit_peer.Text) then //восстановление логина и пароля
                begin
                    Memo_config.Clear;
                    Memo_config.Lines.LoadFromFile('/etc/ppp/peers/'+Edit_peer.Text);
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
  If not FileExists('/opt/vpnpptp/config') then ComboBoxVPN.Text:='VPN PPTP';
  If FileExists ('/opt/vpnpptp/route') then Memo_route.Lines.LoadFromFile('/opt/vpnpptp/route'); //восстановление маршрутов
  TabSheet1.TabVisible:= True;
  TabSheet2.TabVisible:= False;
  TabSheet3.TabVisible:= False;
  TabSheet4.TabVisible:= False;
  PageControl1.ActivePageIndex:=0;
  Button_create.Visible:=False;
  Button_next1.Visible:=True;
  Button_next2.Visible:=False;
If FileExists ('/usr/bin/host') then BindUtils:=true else BindUtils:=false;
StartMessage:=true;
//определяем текущий шлюз, и если нет дефолтного шлюза, то перезапускаем сеть
  Shell ('rm -f /tmp/gate');
  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('printf "none" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  If Memo_gate.Lines[0]='none' then Shell ('/etc/init.d/network restart');
  Shell ('rm -f /tmp/gate');
  Memo_gate.Lines.Clear;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin

end;

procedure TForm1.Label_IPSClick(Sender: TObject);
begin

end;

procedure TForm1.Label_pswdClick(Sender: TObject);
begin

end;

procedure TForm1.Label_userClick(Sender: TObject);
begin

end;

procedure TForm1.Memo_gateChange(Sender: TObject);
begin

end;

procedure TForm1.Off_eth_Click(Sender: TObject);
begin

end;

procedure TForm1.On_eth_Click(Sender: TObject);
begin

end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin

end;

procedure TForm1.Off_ethChange(Sender: TObject);
begin

end;

procedure TForm1.On_ethChange(Sender: TObject);
begin

end;

procedure TForm1.Pppd_logChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
    If Pppd_log.Checked then
                         Pppd_log.Checked:=true
                                                   else
                                                       Pppd_log.Checked:=false;
    If StartMessage then If Pppd_log.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message32);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.Reconnect_pptpChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
    //проверка версии пакета xl2tpd
    If ComboBoxVPN.Text='VPN L2TP' then If Reconnect_pptp.Checked then If FileExists ('/bin/rpm') then
                               begin
                                 Shell ('rm -f /tmp/ver_xl2tpd');
                                 Shell ('rpm xl2tpd -qa|grep edm >> /tmp/ver_xl2tpd');
                                 If FileSize ('/tmp/ver_xl2tpd') = 0 then If StartMessage then
                                                                 begin
                                                                      pchar_message0:=Pchar(message0);
                                                                      pchar_message1:=Pchar(message106);
                                                                      Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                                      Reconnect_pptp.Checked:=false;
                                                                      exit;
                                                                 end;
                                 Shell ('rm -f /tmp/ver_xl2tpd');
                               end;
    If Reconnect_pptp.Checked then
                         Reconnect_pptp.Checked:=true
                                                   else
                                                       Reconnect_pptp.Checked:=false;
    If StartMessage then If Reconnect_pptp.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message31);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
end;

procedure TForm1.Sudo_configureChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
//проверка установлен ли пакет Sudo
If FileExists ('/usr/bin/sudo') then Sudo:=true else Sudo:=false;
   If Sudo_configure.Checked then Sudo_configure.Checked:=true else Sudo_configure.Checked:=false;
   If StartMessage then If Sudo_configure.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message9);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
   If StartMessage then If Sudo_configure.Checked then If not Sudo then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message6);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Sudo_configure.Checked:=false;
                          StartMessage:=true;
                          exit;
                       end;
end;

procedure TForm1.Sudo_ponoffChange(Sender: TObject);
var
   pchar_message0,pchar_message1:pchar;
begin
//проверка установлен ли пакет Sudo
If FileExists ('/usr/bin/sudo') then Sudo:=true else Sudo:=false;
   If Sudo_ponoff.Checked then Sudo_ponoff.Checked:=true else Sudo_ponoff.Checked:=false;
   If StartMessage then If Sudo_ponoff.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message56);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                       end;
   If StartMessage then If Sudo_ponoff.Checked then If not Sudo then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message57);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Sudo_ponoff.Checked:=false;
                          StartMessage:=true;
                          exit;
                       end;
   If StartMessage then If Autostart_ponoff.Checked then If not Sudo_ponoff.Checked then
                       begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message59);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          StartMessage:=false;
                          Autostart_ponoff.Checked:=false;
                          StartMessage:=true;
                       end;
end;


initialization

  {$I unit1.lrs}
  Gettext.GetLanguageIDs(Lang,FallbackLang);
  Translate:=false;
  //FallbackLang:='en'; //просто для проверки при отладке
  If FallbackLang='ru' then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/vpnpptp.ru.po';
                               Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                               Translate:=true;
                            end;
  If FallbackLang='uk' then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/vpnpptp.uk.po';
                               Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                               Translate:=true;
                            end;
  If not Translate then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/vpnpptp.en.po';
                               Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                            end;
LRSTranslator := TTranslator.Create(POFileName); //перевод (локализация) всей формы приложения
end.

end.
