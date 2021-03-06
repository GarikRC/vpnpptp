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
  StdCtrls, ExtCtrls, ComCtrls, unix, Menus, Buttons, AsyncProcess,
  Process, Typinfo, Gettext, BaseUnix, types, Unit2;

type

  { TMyForm }

  TMyForm = class(TForm)
    Button_after_up: TButton;
    Button_after_down: TButton;
    ButtonHelp: TButton;
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
    ComboBox_iface: TComboBox;
    Edit_IPS: TEdit;
    Edit_metric: TEdit;
    Edit_mtu: TEdit;
    Edit_mru: TEdit;
    Edit_passwd: TEdit;
    Edit_iface: TEdit;
    Edit_user: TEdit;
    Label_mtu: TLabel;
    Label_mru: TLabel;
    MyImage: TImage;
    Label_wait: TLabel;
    Label_mppe: TLabel;
    Label_www: TLabel;
    Label_timer: TLabel;
    Label_auth: TLabel;
    Label_IPS: TLabel;
    Label_metric: TLabel;
    Label_iface: TLabel;
    Label_pswd: TLabel;
    Label_user: TLabel;
    MyMemo: TMemo;
    MyPanel: TPanel;
    MyTimer: TTimer;
    procedure ButtonHelpClick(Sender: TObject);
    procedure Button_after_upClick(Sender: TObject);
    procedure Button_after_downClick(Sender: TObject);
    procedure Button_createClick(Sender: TObject);
    procedure Button_exitClick(Sender: TObject);
    procedure CheckBox_no128Change(Sender: TObject);
    procedure CheckBox_no40Change(Sender: TObject);
    procedure CheckBox_no56Change(Sender: TObject);
    procedure CheckBox_rchapChange(Sender: TObject);
    procedure CheckBox_reapChange(Sender: TObject);
    procedure CheckBox_requiredChange(Sender: TObject);
    procedure CheckBox_rmschapChange(Sender: TObject);
    procedure CheckBox_rmschapv2Change(Sender: TObject);
    procedure CheckBox_rpapChange(Sender: TObject);
    procedure CheckBox_statelessChange(Sender: TObject);
    procedure CheckBox_trafficChange(Sender: TObject);
    procedure ComboBox_ifaceChange(Sender: TObject);
    procedure Edit_metricChange(Sender: TObject);
    procedure Edit_mruChange(Sender: TObject);
    procedure Edit_mtuChange(Sender: TObject);
    procedure Edit_passwdChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MyImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MyPanelResize(Sender: TObject);
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
  f, f0, f_bin: text;//текстовый поток
  Code_up_ppp:boolean;//поднято ли VPN на настраиваемом интерфейсе
  PppIface:string;//интерфейс, на котором поднято VPN
  ButtonMiddle:boolean;//отслеживает нажатие средней кнопки мыши на пингвине
  DateStart:int64;//время запуска таймера
  TV:timeval;//время
  error_man_pppd:boolean; //если нет в man про pppd
  default_mppe:boolean; //настройка mppe опциями по-умолчанию
  AProcess: TAsyncProcess; //для запуска внешних приложений

const

  MyLogDir='/var/log/ppp/';
  EtcPppIpUpDDir='/etc/ppp/ip-up.d/';
  EtcPppIpDownDDir='/etc/ppp/ip-down.d/';
  UsrBinDir='/usr/bin/';
  EtcPppPeersDir='/etc/ppp/peers/';
  IfcfgDir='/etc/sysconfig/network-scripts/';
  MyVpnDir='/usr/lib/libDrakX/network/vpn/';
  EtcDir='/etc/';
  VarRunDir='/var/run/';
  UsrSBinDir='/usr/sbin/';
  MyWikiDir='/usr/share/vpnpptp/wiki/';
  MyLibDir='/var/lib/vpnmcc/';

  message0ru='Внимание!';
  message1ru='Поля "Провайдер (IP или имя)", "Пользователь (логин)", "Пароль" обязательны к заполнению.';
  message2ru='Желательно установить метрику меньшую, чем у сетевого интерфейса, на котором будет поднято VPN PPTP.';
  message3ru='Невозможно настроить VPN PPTP в связи с отсутствием пакета pptp-linux.';
  message4ru='Выбор этой опции позволяет пользователям управлять подключением через net_applet без ввода пароля администратора.';
  message5ru='Если выбрать эту опцию, то соединение установится при загрузке системы, при рестарте сети.';
  message6ru='Если выбрать эту опцию, то для соединения будет вестись подсчёт трафика, который можно наблюдать через net_monitor.';
  message7ru='В этом поле указывается адрес vpn-сервера.';
  message8ru='Не найдено ни одного свободного интерфейса pppN, где N в диапазоне [0..100]. Удалите неиспользуемые соединения в Центре Управления.';
  message9ru='Программа завершает свою работу.';
  message10ru='Эту опцию выбрать нельзя, так как не найден';
  message11ru='Соединение было успешно создано.';
  message12ru='Управлять соединением можно через net_applet (пакет drakx-net/drakx-net-applet)';
  message13ru='или в консоли под администратором командами ifup, ifdown, передавая им интерфейс.';
  message14ru='Соединение установится при загрузке системы/при рестарте сети без ввода пароля администратора.';
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
  message25ru='Часто используется шифрование трафика mppe с 128-битным шифрованием - это одновременный выбор required, no40, no56 (если опция no56 есть в pppd).';
  message26ru='Опция stateless пытается реализовать шифрование mppe в режиме без поддержки состояний.';
  message27ru='Опция no40 отключает 40-битное шифрование mppe.';
  message28ru='Опция no56 отключает 56-битное шифрование mppe.';
  message29ru='Опция no128 отключает 128-битное шифрование mppe.';
  message30ru='Запустите эту программу под root';
  message31ru='Выйти из программы';
  message32ru='Эта кнопка создаёт соединение';
  message33ru='При низких разрешениях экрана одновременное нажатие клавиши Alt и левой кнопки мыши поможет переместить окно.';
  message34ru='Нажатие левой/правой кнопкой мыши на пустом месте окна изменяет шрифт.';
  message35ru='Сетевой интерфейс:';
  message36ru='Провайдер (IP или имя)*:';
  message37ru='Пользователь (логин)*:';
  message38ru='Пароль*:';
  message39ru='Метрика:';
  message40ru='Разрешить пользователям управлять подключением';
  message41ru='Устанавливать соединение при загрузке, рестарте сети';
  message42ru='Включить подсчёт трафика';
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
  message66ru='Рекомендуется значение MTU/MRU 1460 или 1472 байт.';
  message67ru='Часто имеет смысл немного подождать, дав возможность установиться соединению.';
  message68ru='Минуточку... Ожидайте...';
  message69ru='Повторить проверку Интернета?';
  message70ru='Соединение VPN PPTP поднято.';
  message71ru='Соединение VPN PPTP не поднято.';
  message72ru='Обнаружено несколько дефолтных маршрутов с одинаковой метрикой. Неверная маршрутизация.';
  message73ru='Нажатие на пингвине средней кнопкой мыши даст тестовые параметры соединения, работоспособные если Интернет уже настроен.';
  message74ru='В процессах обнаружен pppd. Убить все pppd?';
  message75ru='Обнаружено, что VPN PPTP уже поднято на настраиваемом интерфейсе. Оно будет сначала отключено.';
  message76ru='Шифрование mppe может быть настроено неверно, так как отсутствуют: ';
  message77ru='Чтобы использовать шифрование mppe, Вы должны быть аутентифицированы с помощью MS-CHAP или MS-CHAPv2.';
  message78ru='"Refuse" означает "запретить"! Нельзя запретить все виды аутентификации!';
  message79ru='Если выбрать опцию required для шифрования mppe, то нельзя выбрать опцию refuse-mschap одновременно с опцией refuse-mschap-v2, запретив MS-CHAP и MS-CHAPv2.';
  message80ru='Нельзя требовать шифрования mppe опцией required и при этом одновременно запретить все доступные типы шифрования.';
  message81ru='Иногда требуется добавить опцию stateless, но часто она уже используется по-умолчанию.';
  message82ru='Шифрование mppe может быть настроено неверно, так как не удалось свериться с man pppd и отсутствует';
  message83ru='Не найден модуль ppp_mppe, необходимый для работы mppe.';
  message84ru='Значения MTU/MRU можно не вводить, тогда провайдер пришлет их сам (но не всегда).';
  message85ru='Выполнить команды после поднятия VPN';
  message86ru='Выполнить команды после опускания VPN';
  message87ru='Отмена';
  message88ru='Сохранить';
  message89ru='Очистить';
  message90ru='Справка';
  message91ru='Не найдено офисное приложение для вывода справки, читающее формат doc. Вы можете самостоятельно прочитать справку, которая находится:';

  message0uk='Увага!';
  message1uk='Поля "Провайдер (IP або ім’я)", "Користувач (логін)", "Пароль" обов’язкові до заповнення.';
  message2uk='Бажано встановити метрику меншу, ніж у мережевого інтерфейсу, на якому буде піднято VPN PPTP.';
  message3uk='Неможливо налаштувати VPN PPTP у зв''язку з відсутністю пакету pptp-linux.';
  message4uk='Вибір цієї опції дозволяє користувачам керувати підключенням через net_applet без введення пароля адміністратора.';
  message5uk='Якщо вибрати цю опцію, то з''єднання встановиться при завантаженні системи, при рестарті мережі.';
  message6uk='Якщо вибрати цю опцію, то для з''єднання буде вестися підрахунок трафіку, який можна спостерігати через net_monitor.';
  message7uk='У цьому полі вказується адреса vpn-сервера.';
  message8uk='Не знайдено жодного вільного інтерфейсу pppN, де N в діапазоні [0 .. 100]. Видаліть невикористовувані з''єднання в Центрі керування.';
  message9uk='Програма завершує свою роботу.';
  message10uk='Цю опцію вибрати не можна, тому що не знайдено';
  message11uk='З''єднання було успішно створено.';
  message12uk='Керувати з''єднанням можна через net_applet (пакет drakx-net/drakx-net-applet)';
  message13uk='або в консолі під адміністратором командами ifup, ifdown, передаючи їм інтерфейс.';
  message14uk='З''єднання встановиться при завантаженні системи/при рестарті мережі без введення пароля адміністратора.';
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
  message25uk='Часто використовується шифрування трафіку mppe з 128-бітовим шифруванням - це одночасний вибір required, no40, no56 (якщо опція no56 є в pppd).';
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
  message41uk='Встановлювати з''єднання при завантаженні, рестарті мережі';
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
  message66uk='Рекомендується значення MTU/MRU 1460 або 1472 байт.';
  message67uk='Часто має сенс трохи почекати, давши можливість встановитися з''єднанню.';
  message68uk='Хвилиночку... Чекайте...';
  message69uk='Повторити перевірку Інтернету?';
  message70uk='З''єднання VPN PPTP піднято.';
  message71uk='З''єднання VPN PPTP не піднято.';
  message72uk='Виявлено кілька дефолтних маршрутів з однаковою метрикою. Невірна маршрутизація.';
  message73uk='Натискання на пінгвінів середньою кнопкою миші дасть тестові параметри з''єднання, працездатні якщо Інтернет вже налаштований.';
  message74uk='У процесах виявлен pppd. Вбити всі pppd?';
  message75uk='Виявлено, що VPN PPTP вже піднято на розширеному інтерфейсі. Воно буде спочатку відключено.';
  message76uk='Шифрування mppe може бути налаштований невірно, тому що немає: ';
  message77uk='Щоб користуватися шифруванням mppe, Ви повиннi бути аутентiфикованi за допомогою MS-CHAP або MS-CHAPv2.';
  message78uk='"Refuse" означає "заборонити"! Неможно заборонити усi види аутентифiкацiй!';
  message79uk='Якщо обраты опцiю required для шифрування mppe, то неможно обрати опцiю refuse-mschap одночасно с опцiею refuse-mschap-v2, заборонив MS-CHAP та MS-CHAPv2.';
  message80uk='Неможно вимогати шифрування mppe опцією required та при цьюму одночасно заборонити усi доступнi типи шифрування.';
  message81uk='Iнодi потребується добавити опцію stateless, но часто вона вже iспользуеться за умовчанням.';
  message82uk='Шифрування mppe може бути налаштоване невiрно, так як не вдалося звіритися з man pppd та вiдсутнє';
  message83uk='Не знайден модуль ppp_mppe, необхiдний для роботы mppe.';
  message84uk='Значення MTU/MRU можна не вводити, тоді провайдер надішле їхній сам (але не завжди).';
  message85uk='Виконати команди після підняття VPN';
  message86uk='Виконати команди після опускання VPN';
  message87uk='Відміна';
  message88uk='Зберегти';
  message89uk='Очистити';
  message90uk='Довідка';
  message91uk='Не знайдено офісний додаток для виведення довідки, що читає формат doc. Ви можете самостійно прочитати довідку, яка знаходиться:';

  message0en='Attention!';
  message1en='Fields "ISP (IP or Name)", "User name (login)", "Password" is required.';
  message2en='It is desirable to set a metric less than for network interface, which will be to use for VPN PPTP.';
  message3en='Unable to configure VPN PPTP because of absence of package pptp-linux.';
  message4en='Choice of this option allows users to manage connections with help net_applet without entering the root''s password.';
  message5en='If you choose this option, then the connection will be established when the system boots or the network restarts.';
  message6en='If you choose this option, then traffic will be to calculate for the connection, which you can watch with help net_monitor.';
  message7en='In this box you must enter address of vpn-server.';
  message8en='Did not match any of the free interface pppN, where N is in the range [0..100]. Remove unused connections in the Control Center.';
  message9en='The program complete its work.';
  message10en='This option can not be selected, because was not found';
  message11en='The connection was successfully created.';
  message12en='You can manage the connection with help net_applet (package drakx-net/drakx-net-applet)';
  message13en='or in the root''s console by commands: ifup pppN, ifdown pppN.';
  message14en='Connection will be established on boot/on network restart without entering a root''s password.';
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
  message25en='Encryption mppe often used with 128-bit encryption - is the simultaneous selection of required, no40, no56 (if there is the option no56 in pppd).';
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
  message41en='Connect the connection on boot, on network restart';
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
  message66en='It is recommended MTU/MRU of 1460 or 1472 bytes.';
  message67en='Often it makes sense to wait a little, giving the opportunity to establish the connection.';
  message68en='Wait a minute... Expect...';
  message69en='Repeat test of Internet?';
  message70en='VPN PPTP Connection established.';
  message71en='VPN PPTP Connection not established.';
  message72en='Found several default routes with the same metric. Incorrect routing.';
  message73en='Clicking on the penguin middle mouse button will give test the connection settings and workable if the Internet is already configured.';
  message74en='In the process found pppd. Kill all pppd?';
  message75en='Found that VPN PPTP been raised to a customizable interface. It will first be disabled.';
  message76en='Mppe encryption can be configured incorrectly, because there are no: ';
  message77en='If you want to use the encryption mppe, then you must be authenticated using MS-CHAP or MS-CHAPv2.';
  message78en='"Refuse" means "disable"! You can not prohibit all forms of authentication!';
  message79en='If you select the option required for encryption mppe, you can not select the option refuse-mschap together with the option refuse-mschap-v2, banning MS-CHAP and MS-CHAPv2.';
  message80en='You can not require encryption mppe when option required selected and at the same time to ban all available types of encryption.';
  message81en='Sometimes you must add the option stateless, but often it is used by default.';
  message82en='Encryption mppe may be configured incorrectly, because it is not able to consult with man pppd, and missing';
  message83en='Module ppp_mppe can not be found, what is necessary for mppe.';
  message84en='The values of the MTU/MRU can''t write, then the IPS will send them (but not always).';
  message85en='Run commands after connecting VPN';
  message86en='Run commands after disconnecting VPN';
  message87en='Cancel';
  message88en='Save';
  message89en='Clear';
  message90en='Help';
  message91en='Not found Office application to display Help that read the doc. You can to read help, which is:';

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
  If FileExists(VarRunDir+'ppp-vpnmcc.pid') then
                                                 begin
                                                      popen (f,'cat '+VarRunDir+'ppp-vpnmcc.pid|'+'grep ppp','R');
                                                      While not eof(f) do
                                                                begin
                                                                     Readln (f,str);
                                                                     If str<>'' then PppIface:=str;
                                                                end;
                                                      PClose(f);
                                                      if PppIface<>'' then
                                                              begin
                                                                   popen (f,'ifconfig |'+'grep '+PppIface,'R');
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
  y:boolean;
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
FpSystem('printf "DEVICE=ppp'+IntToStr(Number_PPP_Iface)+'\n" > '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_autostart.Checked then FpSystem('printf "ONBOOT=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else FpSystem('printf "ONBOOT=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
FpSystem('printf "METRIC='+Edit_metric.Text+'\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
FpSystem('printf "TYPE=ADSL\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_right.Checked then FpSystem('printf "USERCTL=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else FpSystem('printf "USERCTL=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
if not CheckBox_traffic.Checked then FpSystem('printf "ACCOUNTING=no\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface)) else FpSystem('printf "ACCOUNTING=yes\n" >> '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
FpSystem ('chmod a+x '+IfcfgDir+'ifcfg-ppp'+IntToStr(Number_PPP_Iface));
//запись файла /etc/ppp/ip-up.d/vpnmcc-ip-up
If not DirectoryExists (EtcPppIpUpDDir) then FpSystem ('mkdir -p '+LeftStr(EtcPppIpUpDDir,Length(EtcPppIpUpDDir)-1));
MyMemo.Lines.Clear;
MyMemo.Lines.Add('#!/bin/bash');
MyMemo.Lines.Add('if [ ! $LINKNAME = "vpnmcc" ]');
MyMemo.Lines.Add('then');
MyMemo.Lines.Add('exit 0');
MyMemo.Lines.Add('fi');
MyMemo.Lines.Add('if [ $USEPEERDNS = "1" ]');
MyMemo.Lines.Add('then');
MyMemo.Lines.Add('     [ -n "$DNS1" ] && '+'rm -f '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('     [ -n "$DNS2" ] && '+'rm -f '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('            if [ ! -f '+EtcDir+'resolv.conf ]');
MyMemo.Lines.Add('            then');
MyMemo.Lines.Add('                  '+'cat /etc/resolvconf/resolv.conf.d/head|'+'grep nameserver >> '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('            fi');
MyMemo.Lines.Add('     [ -n "$DNS1" ] && '+'echo "nameserver $DNS1" >> '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('     [ -n "$DNS2" ] && '+'echo "nameserver $DNS2" >> '+EtcDir+'resolv.conf');
MyMemo.Lines.Add('fi');
MyMemo.Lines.SaveToFile(EtcPppIpUpDDir+'vpnmcc-ip-up');
FpSystem('chmod a+x '+EtcPppIpUpDDir+'vpnmcc-ip-up');
//дописываем
If FileExists (MyLibDir+'up-'+Edit_iface.Text) then
                                  FpSystem('cat '+MyLibDir+'up-'+Edit_iface.Text+' >> '+EtcPppIpUpDDir+'vpnmcc-ip-up');
//запись файла /etc/ppp/ip-down.d/vpnmcc-ip-down
If not DirectoryExists (EtcPppIpDownDDir) then FpSystem ('mkdir -p '+LeftStr(EtcPppIpDownDDir,Length(EtcPppIpDownDDir)-1));
MyMemo.Lines.Clear;
MyMemo.Lines.Add('#!/bin/bash');
MyMemo.Lines.Add('if [ ! $LINKNAME = "vpnmcc" ]');
MyMemo.Lines.Add('then');
MyMemo.Lines.Add('exit 0');
MyMemo.Lines.Add('fi');
MyMemo.Lines.SaveToFile(EtcPppIpDownDDir+'vpnmcc-ip-down');
FpSystem('chmod a+x '+EtcPppIpDownDDir+'vpnmcc-ip-down');
//дописываем
If FileExists (MyLibDir+'down-'+Edit_iface.Text) then
                                  FpSystem('cat '+MyLibDir+'down-'+Edit_iface.Text+' >> '+EtcPppIpDownDDir+'vpnmcc-ip-down');
//запись файла /etc/ppp/peers/pppN
If not DirectoryExists (EtcPppPeersDir) then FpSystem ('mkdir -p '+LeftStr(EtcPppPeersDir,Length(EtcPppPeersDir)-1));
MyMemo.Lines.Clear;
MyMemo.Lines.Add('unit '+IntToStr(Number_PPP_Iface));
MyMemo.Lines.Add('noipdefault');
MyMemo.Lines.Add('defaultroute');
MyMemo.Lines.Add('noauth');
MyMemo.Lines.Add('linkname vpnmcc');
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
If CheckBox_nobuffer.Checked then MyMemo.Lines.Add('pty "'+'pptp '+Edit_IPS.Text+' --nolaunchpppd --nobuffer"') else MyMemo.Lines.Add('pty "'+'pptp '+Edit_IPS.Text+' --nolaunchpppd"');
MyMemo.Lines.Add('user "'+Edit_user.Text+'"');
MyMemo.Lines.Add('password "'+Edit_passwd.Text+'"');
If CheckBox_rmschap.Checked then MyMemo.Lines.Add(CheckBox_rmschap.Caption);
If CheckBox_reap.Checked then MyMemo.Lines.Add(CheckBox_reap.Caption);
If CheckBox_rchap.Checked then MyMemo.Lines.Add(CheckBox_rchap.Caption);
If CheckBox_rpap.Checked then MyMemo.Lines.Add(CheckBox_rpap.Caption);
If CheckBox_rmschapv2.Checked then MyMemo.Lines.Add(CheckBox_rmschapv2.Caption);
//Разбираемся с шифрованием
If CheckBox_required.Checked then
                   begin
                      If not FileExistsBin('strings') then If not FileExistsBin('man') then If (CheckBox_required.Checked) or (CheckBox_stateless.Checked) or (CheckBox_no40.Checked) or (CheckBox_no56.Checked) or (CheckBox_no128.Checked) then
                                                                                                     begin
                                                                                                          If FallbackLang='ru' then Application.MessageBox(PChar(message76ru+' '+'strings, '+'man.'),PChar(message0ru),0) else
                                                                                                                                                                                                if FallbackLang='uk' then Application.MessageBox(PChar(message76uk+' '+'strings, '+'man.'),PChar(message0uk),0)
                                                                                                                                                                                                                                      else Application.MessageBox(PChar(message76en+' '+'strings, '+'man.'),PChar(message0en),0);
                                                                                                     end;
                      if error_man_pppd then
                                         begin
                                              If FallbackLang='ru' then Application.MessageBox(PChar(message82ru+' '+'strings.'),PChar(message0ru),0) else
                                                                                                                                            if FallbackLang='uk' then Application.MessageBox(PChar(message82uk+' '+'strings.'),PChar(message0uk),0)
                                                                                                                                                                                                                                      else Application.MessageBox(PChar(message82en+' '+'strings.'),PChar(message0en),0);
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
                                  If mppe_string<>'mppe ' then MyMemo.Lines.Add(mppe_string);
                              end
                                 else
                                    begin
                                       If not CheckBox_no40.Checked then MyMemo.Lines.Add('require-mppe-40');
                                       //If not CheckBox_no56.Checked then MyMemo.Lines.Add('require-mppe-56'); //для наглядности
                                       If not CheckBox_no128.Checked then MyMemo.Lines.Add('require-mppe-128');
                                       If CheckBox_stateless.Checked then MyMemo.Lines.Add('nomppe-stateful');
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
                                                        If FallbackLang='ru' then Application.MessageBox(PChar(message83ru),PChar(message0ru),0) else
                                                                                                                                     If FallbackLang='uk' then Application.MessageBox(PChar(message83uk),PChar(message0uk),0)
                                                                                                                                                                                                        else Application.MessageBox(PChar(message83en),PChar(message0en),0);
                                                   end;
                                     pclose(f);
                                end;
If CheckBox_pppd_log.Checked then
                             begin
                               If not DirectoryExists(MyLogDir) then FpSystem ('mkdir -p '+LeftStr(MyLogDir,Length(MyLogDir)-1));
                                MyMemo.Lines.Add('debug');
                                MyMemo.Lines.Add('logfile '+MyLogDir+'vpnmcc.log');
                             end;
If Edit_mtu.Text <> '' then MyMemo.Lines.Add('mtu '+Edit_mtu.Text);
If Edit_mru.Text <> '' then MyMemo.Lines.Add('mru '+Edit_mru.Text);
MyMemo.Lines.SaveToFile(EtcPppPeersDir+'ppp'+IntToStr(Number_PPP_Iface));
FpSystem ('chmod 600 '+EtcPppPeersDir+'ppp'+IntToStr(Number_PPP_Iface));
//применение изменений для net_applet
FpSystem('kill -s 1 `pidof -x net_applet`');
If FallbackLang='ru' then i:=Application.MessageBox(PChar(message56ru),PChar(message0ru),1) else if FallbackLang='uk' then i:=Application.MessageBox(PChar(message56uk),PChar(message0uk),1)
                                                                                            else i:=Application.MessageBox(PChar(message56en),PChar(message0en),1);
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
                                                                     Label_iface.Enabled:=false;
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
                                                                     AAsyncProcess.CommandLine :='ifdown '+PppIface;
                                                                     AAsyncProcess.Execute;
                                                                     while AAsyncProcess.Running do
                                                                                                 begin
                                                                                                      mysleep(30);
                                                                                                 end;
                                                                     AAsyncProcess.Free;
                                                                     MyForm.Enabled:=true;
                                                                     Label_iface.Enabled:=true;
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
               popen(f,'ps -e | '+'grep pppd','R');
               While not eof(f) do
                                begin
                                    Readln(f,str);
                                    if RightStr(str,9)<>'<defunct>' then FoundPpppd:=true;
                                end;
               PClose(f);
               If FoundPpppd then
                               begin
                                   If FallbackLang='ru' then i:=Application.MessageBox(PChar(message74ru),PChar(message0ru),1) else
                                                                               if FallbackLang='uk' then i:=Application.MessageBox(PChar(message74uk),PChar(message0uk),1)
                                                                                                                else i:=Application.MessageBox(PChar(message74en),PChar(message0en),1);
                                   if i=1 then
                                              begin
                                                  AAsyncProcess := TAsyncProcess.Create(nil);
                                                  AAsyncProcess.CommandLine :='killall pppd';
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
               AAsyncProcess.CommandLine :='ifup ppp'+IntToStr(Number_PPP_Iface);
               AAsyncProcess.Execute;
               AAsyncProcess.Free;
               If FallbackLang='ru' then i:=Application.MessageBox(PChar(message63ru+' '+message67ru),PChar(message0ru),1) else
                                                           if FallbackLang='uk' then i:=Application.MessageBox(PChar(message63uk+' '+message67uk),PChar(message0uk),1)
                                                                                            else i:=Application.MessageBox(PChar(message63en+' '+message67en),PChar(message0en),1);
               if i=1 then
                          begin
                               repeat
                                     //тест интернета
                                     CheckVPN;
                                     MyTimer.Enabled:=true;
                                     MyForm.Enabled:=false;
                                     Label_iface.Enabled:=false;
                                     Label_IPS.Enabled:=false;
                                     Label_user.Enabled:=false;
                                     Label_pswd.Enabled:=false;
                                     Label_metric.Enabled:=false;
                                     Label_auth.Enabled:=false;
                                     Label_mppe.Enabled:=false;
                                     Label_mtu.Enabled:=false;
                                     Label_mru.Enabled:=false;
                                     MyImage.Visible:=false;
                                     Label_wait.Visible:=true;
                                     Label_www.Visible:=true;
                                     Label_timer.Visible:=true;
                                     Application.ProcessMessages;
                                     AStringList := TStringList.Create;
                                     AAsyncProcess := TAsyncProcess.Create(nil);
                                     If (Edit_IPS.Text='connect.lb.swissvpn.net') and (Edit_user.Text='swissvpntest') and (Edit_passwd.Text='swissvpntest') then
                                                                                                                          AAsyncProcess.CommandLine :='ping -c1 swissvpn.net' else
                                                                                                                                        AAsyncProcess.CommandLine :='ping -c1 yandex.ru';
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
                                     Label_iface.Enabled:=true;
                                     Label_IPS.Enabled:=true;
                                     Label_user.Enabled:=true;
                                     Label_pswd.Enabled:=true;
                                     Label_metric.Enabled:=true;
                                     Label_auth.Enabled:=true;
                                     Label_mppe.Enabled:=true;
                                     Label_mtu.Enabled:=true;
                                     Label_mru.Enabled:=true;
                                     MyImage.Visible:=true;
                                     Label_wait.Visible:=false;
                                     Label_www.Visible:=false;
                                     Label_timer.Visible:=false;
                                     MyTimer.Enabled:=false;
                                     Application.ProcessMessages;
                                     If (NoInternet) and (not Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message71ru+' '+message61ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message71uk+' '+message61uk),PChar(message0uk),0)
                                                                                                                              else Application.MessageBox(PChar(message71en+' '+message61en),PChar(message0en),0);
                                     If (not NoInternet) and (Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message70ru+' '+message62ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message70uk+' '+message62uk),PChar(message0uk),0)
                                                                                                                              else Application.MessageBox(PChar(message70en+' '+message62en),PChar(message0en),0);
                                     If (NoInternet) and (Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message64ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message64uk),PChar(message0uk),0)
                                                                                                                              else Application.MessageBox(PChar(message64en),PChar(message0en),0);
                                     If (not NoInternet) and (not Code_up_ppp) then
                                                 If FallbackLang='ru' then Application.MessageBox(PChar(message65ru),PChar(message0ru),0) else
                                                                                        if FallbackLang='uk' then Application.MessageBox(PChar(message65uk),PChar(message0uk),0)
                                                                                                                              else Application.MessageBox(PChar(message65en),PChar(message0en),0);
                                     If (NoInternet) and (Code_up_ppp)  then  //проверка кол-ва дефолтных маршрутов с одинаковой метрикой
                                                                       begin
                                                                           Str:='route -n|'+'awk '+chr(39)+'{print $1" "$5}'+chr(39)+'|'+'grep 0.0.0.0';
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
                                                                                        if FallbackLang='uk' then a:=Application.MessageBox(PChar(message69uk),PChar(message0uk),1)
                                                                                                                             else i:=Application.MessageBox(PChar(message69en),PChar(message0en),1);
                               until (a<>1);
                          end;
           end;
Application.ShowHint:=true;
Application.ProcessMessages;
end;

procedure TMyForm.Button_after_upClick(Sender: TObject);
begin
  FormDop.Position:=poMainFormCenter;
  FormDop.Width:=MyForm.Width div 2;
  FormDop.Height:=MyForm.Height div 2;
  FormDop.ButtonOK.Width:=FormDop.Width div 4;
  FormDop.ButtonOK.Height:=FormDop.Height div 12;
  FormDop.ButtonNO.Width:=FormDop.Width div 4;
  FormDop.ButtonNO.Height:=FormDop.Height div 12;
  FormDop.ButtonClear.Width:=FormDop.Width div 4;
  FormDop.ButtonClear.Height:=FormDop.Height div 12;
  FpSystem('mkdir -p '+LeftStr(MyLibDir,Length(MyLibDir)-1));
  FormDop.FileRoute:=MyLibDir+'up-'+Edit_iface.Text;
  If FallbackLang='ru' then FormDop.Caption:=message85ru else
                                    If FallbackLang='uk' then FormDop.Caption:=message85uk
                                                                     else FormDop.Caption:=message85en;
  If FallbackLang='ru' then FormDop.ButtonNO.Caption:=message87ru else
                                    If FallbackLang='uk' then FormDop.ButtonNO.Caption:=message87uk
                                                                     else FormDop.ButtonNO.Caption:=message87en;
  If FallbackLang='ru' then FormDop.ButtonOK.Caption:=message88ru else
                                    If FallbackLang='uk' then FormDop.ButtonOK.Caption:=message88uk
                                                                     else FormDop.ButtonOK.Caption:=message88en;
  If FallbackLang='ru' then FormDop.ButtonClear.Caption:=message89ru else
                                    If FallbackLang='uk' then FormDop.ButtonClear.Caption:=message89uk
                                                                     else FormDop.ButtonClear.Caption:=message89en;
  FormDop.ShowModal;
end;

procedure TMyForm.ButtonHelpClick(Sender: TObject);
var
   a:boolean;
   StrOffice:string;
begin
     a:=ButtonHelp.Enabled;
     ButtonHelp.Enabled:=false;
     Application.ProcessMessages;
     MyForm.Repaint;
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
                              If FallbackLang='ru' then Application.MessageBox(PChar(message91ru+' '+MyWikiDir+'Help_vpnmcc_ru.doc'),PChar(message0ru),0);
                              //If FallbackLang='uk' then Application.MessageBox(PChar(message91uk+' '+MyWikiDir+'Help_vpnmcc_uk.doc'),PChar(message0uk),0);
                         end;
     If StrOffice<>'' then
                          begin
                               AProcess := TAsyncProcess.Create(nil);
                               If FallbackLang='ru' then AProcess.CommandLine :=StrOffice+' '+MyWikiDir+'Help_vpnmcc_ru.doc';
                               //If FallbackLang='uk' then AProcess.CommandLine :=StrOffice+' '+MyWikiDir+'Help_vpnmcc_uk.doc';
                               AProcess.Options:=AProcess.Options+[poWaitOnExit];
                               AProcess.Execute;
                               sleep(100);
                               AProcess.Free;
                          end;
     ButtonHelp.Enabled:=a;
     Application.ProcessMessages;
     MyForm.Repaint;
end;

procedure TMyForm.Button_after_downClick(Sender: TObject);
begin
  FormDop.Position:=poMainFormCenter;
  FormDop.Width:=MyForm.Width div 2;
  FormDop.Height:=MyForm.Height div 2;
  FormDop.ButtonOK.Width:=FormDop.Width div 4;
  FormDop.ButtonOK.Height:=FormDop.Height div 12;
  FormDop.ButtonNO.Width:=FormDop.Width div 4;
  FormDop.ButtonNO.Height:=FormDop.Height div 12;
  FormDop.ButtonClear.Width:=FormDop.Width div 4;
  FormDop.ButtonClear.Height:=FormDop.Height div 12;
  FpSystem('mkdir -p '+LeftStr(MyLibDir,Length(MyLibDir)-1));
  FormDop.FileRoute:=MyLibDir+'down-'+Edit_iface.Text;
  If FallbackLang='ru' then FormDop.Caption:=message86ru else
                                    If FallbackLang='uk' then FormDop.Caption:=message86uk
                                                                     else FormDop.Caption:=message86en;
  If FallbackLang='ru' then FormDop.ButtonNO.Caption:=message87ru else
                                    If FallbackLang='uk' then FormDop.ButtonNO.Caption:=message87uk
                                                                     else FormDop.ButtonNO.Caption:=message87en;
  If FallbackLang='ru' then FormDop.ButtonOK.Caption:=message88ru else
                                    If FallbackLang='uk' then FormDop.ButtonOK.Caption:=message88uk
                                                                     else FormDop.ButtonOK.Caption:=message88en;
  If FallbackLang='ru' then FormDop.ButtonClear.Caption:=message89ru else
                                    If FallbackLang='uk' then FormDop.ButtonClear.Caption:=message89uk
                                                                     else FormDop.ButtonClear.Caption:=message89en;
  FormDop.ShowModal;
end;

procedure TMyForm.Button_exitClick(Sender: TObject);
begin
     halt;
end;

procedure TMyForm.CheckBox_no128Change(Sender: TObject);
begin
   If CheckBox_no128.Checked then CheckBox_required.Checked:=true;
   //проверка корректности задания шифрования mppe
   If (CheckBox_required.Checked) and (CheckBox_no40.Checked) and (CheckBox_no56.Checked) and (CheckBox_no128.Checked) then
                                                              begin
                                                                   If FallbackLang='ru' then Application.MessageBox(PChar(message80ru),PChar(message0ru),0) else
                                                                                                                                     If FallbackLang='uk' then Application.MessageBox(PChar(message80uk),PChar(message0uk),0)
                                                                                                                                                                                                        else Application.MessageBox(PChar(message80en),PChar(message0en),0);
                                                                   CheckBox_no128.Checked:=false;
                                                                   exit;
                                                              end;
end;

procedure TMyForm.CheckBox_no40Change(Sender: TObject);
begin
    If CheckBox_no40.Checked then CheckBox_required.Checked:=true;
    //проверка корректности задания шифрования mppe
    If (CheckBox_required.Checked) and (CheckBox_no40.Checked) and (CheckBox_no56.Checked) and (CheckBox_no128.Checked) then
                                                               begin
                                                                    If FallbackLang='ru' then Application.MessageBox(PChar(message80ru),PChar(message0ru),0) else
                                                                                                                                     If FallbackLang='uk' then Application.MessageBox(PChar(message80uk),PChar(message0uk),0)
                                                                                                                                                                                                       else Application.MessageBox(PChar(message80en),PChar(message0en),0);
                                                                    CheckBox_no40.Checked:=false;
                                                                    exit;
                                                               end;
end;

procedure TMyForm.CheckBox_no56Change(Sender: TObject);
begin
    If CheckBox_no56.Checked then If CheckBox_no56.Visible then CheckBox_required.Checked:=true;
    //проверка корректности задания шифрования mppe
    If (CheckBox_required.Checked) and (CheckBox_no40.Checked) and (CheckBox_no56.Checked) and (CheckBox_no128.Checked) then
                                                               begin
                                                                    If FallbackLang='ru' then Application.MessageBox(PChar(message80ru),PChar(message0ru),0) else
                                                                                                                                      If FallbackLang='uk' then Application.MessageBox(PChar(message80uk),PChar(message0uk),0)
                                                                                                                                                                                                         else Application.MessageBox(PChar(message80en),PChar(message0en),0);
                                                                    CheckBox_no56.Checked:=false;
                                                                    exit;
                                                               end;
end;

procedure TMyForm.CheckBox_rchapChange(Sender: TObject);
begin
  If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
            begin
              If FallbackLang='ru' then Application.MessageBox(PChar(message78ru),PChar(message0ru),0) else
                                                                                   If FallbackLang='uk' then Application.MessageBox(PChar(message78uk),PChar(message0uk),0)
                                                                                                                                                      else Application.MessageBox(PChar(message78en),PChar(message0en),0);
              CheckBox_rchap.Checked:=false;
              CheckBox_reap.Checked:=false;
              CheckBox_rmschap.Checked:=false;
              CheckBox_rpap.Checked:=false;
              CheckBox_rmschapv2.Checked:=false;
            end;
end;

procedure TMyForm.CheckBox_reapChange(Sender: TObject);
begin
  If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
            begin
              If FallbackLang='ru' then Application.MessageBox(PChar(message78ru),PChar(message0ru),0) else
                                                                                   If FallbackLang='uk' then Application.MessageBox(PChar(message78uk),PChar(message0uk),0)
                                                                                                                                                      else Application.MessageBox(PChar(message78en),PChar(message0en),0);
              CheckBox_rchap.Checked:=false;
              CheckBox_reap.Checked:=false;
              CheckBox_rmschap.Checked:=false;
              CheckBox_rpap.Checked:=false;
              CheckBox_rmschapv2.Checked:=false;
            end;
end;

procedure TMyForm.CheckBox_requiredChange(Sender: TObject);
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
                                                                       If FallbackLang='ru' then Application.MessageBox(PChar(message77ru),PChar(message0ru),0) else
                                                                                   If FallbackLang='uk' then Application.MessageBox(PChar(message77uk),PChar(message0uk),0)
                                                                                                                                                      else Application.MessageBox(PChar(message77en),PChar(message0en),0);
                                                                       CheckBox_required.Checked:=false;
                                                                  end;
end;

procedure TMyForm.CheckBox_rmschapChange(Sender: TObject);
begin
   If CheckBox_rmschapv2.Checked then If CheckBox_rmschap.Checked then If CheckBox_required.Checked then
                                                                   begin
                                                                        If FallbackLang='ru' then Application.MessageBox(PChar(message77ru+' '+message79ru),PChar(message0ru),0) else
                                                                                    If FallbackLang='uk' then Application.MessageBox(PChar(message77uk+' '+message79uk),PChar(message0uk),0)
                                                                                                                                                       else Application.MessageBox(PChar(message77en+' '+message79en),PChar(message0en),0);
                                                                        CheckBox_rmschap.Checked:=false;
                                                                   end;
   If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
             begin
               If FallbackLang='ru' then Application.MessageBox(PChar(message78ru),PChar(message0ru),0) else
                                                                                   If FallbackLang='uk' then Application.MessageBox(PChar(message78uk),PChar(message0uk),0)
                                                                                                                                                      else Application.MessageBox(PChar(message78en),PChar(message0en),0);
               CheckBox_rchap.Checked:=false;
               CheckBox_reap.Checked:=false;
               CheckBox_rmschap.Checked:=false;
               CheckBox_rpap.Checked:=false;
               CheckBox_rmschapv2.Checked:=false;
             end;
end;

procedure TMyForm.CheckBox_rmschapv2Change(Sender: TObject);
begin
   If CheckBox_rmschapv2.Checked then If CheckBox_rmschap.Checked then If CheckBox_required.Checked then
                                                                   begin
                                                                        If FallbackLang='ru' then Application.MessageBox(PChar(message77ru+' '+message79ru),PChar(message0ru),0) else
                                                                                    If FallbackLang='uk' then Application.MessageBox(PChar(message77uk+' '+message79uk),PChar(message0uk),0)
                                                                                                                                                       else Application.MessageBox(PChar(message77en+' '+message79en),PChar(message0en),0);
                                                                        CheckBox_rmschapv2.Checked:=false;
                                                                   end;
   If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
             begin
               If FallbackLang='ru' then Application.MessageBox(PChar(message78ru),PChar(message0ru),0) else
                                                                                       If FallbackLang='uk' then Application.MessageBox(PChar(message78uk),PChar(message0uk),0)
                                                                                                                                                          else Application.MessageBox(PChar(message78en),PChar(message0en),0);
               CheckBox_rchap.Checked:=false;
               CheckBox_reap.Checked:=false;
               CheckBox_rmschap.Checked:=false;
               CheckBox_rpap.Checked:=false;
               CheckBox_rmschapv2.Checked:=false;
             end;
end;

procedure TMyForm.CheckBox_rpapChange(Sender: TObject);
begin
   If (CheckBox_rchap.Checked) and (CheckBox_reap.Checked) and (CheckBox_rmschap.Checked) and (CheckBox_rpap.Checked) and (CheckBox_rmschapv2.Checked) then
             begin
               If FallbackLang='ru' then Application.MessageBox(PChar(message78ru),PChar(message0ru),0) else
                                                                                    If FallbackLang='uk' then Application.MessageBox(PChar(message78uk),PChar(message0uk),0)
                                                                                                                                                       else Application.MessageBox(PChar(message78en),PChar(message0en),0);
               CheckBox_rchap.Checked:=false;
               CheckBox_reap.Checked:=false;
               CheckBox_rmschap.Checked:=false;
               CheckBox_rpap.Checked:=false;
               CheckBox_rmschapv2.Checked:=false;
             end;
end;

procedure TMyForm.CheckBox_statelessChange(Sender: TObject);
begin
  If CheckBox_stateless.Checked then CheckBox_required.Checked:=true;
end;


procedure TMyForm.CheckBox_trafficChange(Sender: TObject);
var
   str:string;
begin
  str:='';
  If FallbackLang='ru' then If not FileExistsBin ('vnstat') then str:=str+message10ru+' '+'vnstat. ';
  If FallbackLang='ru' then If not FileExistsBin ('net_monitor') then str:=str+message10ru+' '+'net_monitor. ';
  If FallbackLang='uk' then If not FileExistsBin ('vnstat') then str:=str+message10uk+' '+'vnstat. ';
  If FallbackLang='uk' then If not FileExistsBin ('net_monitor') then str:=str+message10uk+' '+'net_monitor. ';
  If FallbackLang<>'ru' then If FallbackLang<>'uk' then If not FileExistsBin ('vnstat') then str:=str+message10en+' '+'vnstat. ';
  If FallbackLang<>'ru' then If FallbackLang<>'uk' then If not FileExistsBin ('net_monitor') then str:=str+message10en+' '+'net_monitor. ';
  if str<>'' then if CheckBox_traffic.Checked then
                 begin
                    If FallbackLang='ru' then Application.MessageBox(PChar(str),PChar(message0ru),0) else
                                         If FallbackLang='uk' then Application.MessageBox(PChar(str),PChar(message0uk),0) else
                                                                                  Application.MessageBox(PChar(str),PChar(message0en),0);
                    CheckBox_traffic.Checked:=false;
                 end;
end;

procedure TMyForm.ComboBox_ifaceChange(Sender: TObject);
var
   str:string;
   mppe_notstandart, mppe_standart:boolean;
begin
  str:='';
  Edit_iface.Text:=Combobox_iface.Text;
  str:=RightStr(Combobox_iface.Text,Length(Combobox_iface.Text)-3);
  Number_PPP_Iface:=StrToInt(str);
  //восстанавливаем провайдера
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep pty|awk '+chr(39)+'{print $3}'+chr(39),'R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  Edit_IPS.Text:=str;
  //восстанавливаем пользователя
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep user|awk '+chr(39)+'{print $2}'+chr(39),'R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  str:=copy(str,2,length(str)-2);
  Edit_user.Text:=str;
  //восстанавливаем пароль
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep password|awk '+chr(39)+'{print $2}'+chr(39),'R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  str:=copy(str,2,length(str)-2);
  Edit_passwd.Text:=str;
  //восстанавливаем метрику
  str:='';
  popen (f,'cat /etc/sysconfig/network-scripts/ifcfg-'+Edit_iface.Text+'|grep METRIC|cut -d "=" --fields=2','R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  Edit_metric.Text:=str;
  //восстанавливаем вести ли лог
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep logfile','R');
  If not eof (f) then CheckBox_pppd_log.Checked:=true else CheckBox_pppd_log.Checked:=false;
  pclose(f);
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then CheckBox_pppd_log.Checked:=true;
  //восстанавливаем разрешить ли пользователям управлять подключением
  str:='';
  popen (f,'cat /etc/sysconfig/network-scripts/ifcfg-'+Edit_iface.Text+'|grep USERCTL|cut -d "=" --fields=2','R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  If str='no' then CheckBox_right.Checked:=false else CheckBox_right.Checked:=true;
  If not FileExists('/etc/sysconfig/network-scripts/ifcfg-'+Edit_iface.Text) then CheckBox_right.Checked:=false;
  //восстанавливаем устанавливать ли соединение при загрузке
  str:='';
  popen (f,'cat /etc/sysconfig/network-scripts/ifcfg-'+Edit_iface.Text+'|grep ONBOOT|cut -d "=" --fields=2','R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  If str='no' then CheckBox_autostart.Checked:=false else CheckBox_autostart.Checked:=true;
  If not FileExists('/etc/sysconfig/network-scripts/ifcfg-'+Edit_iface.Text) then CheckBox_autostart.Checked:=false;
  //восстанавливаем есть ли nobuffer
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep nobuffer','R');
  If not eof (f) then CheckBox_nobuffer.Checked:=true else CheckBox_nobuffer.Checked:=false;
  pclose(f);
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then CheckBox_nobuffer.Checked:=true;
  //восстанавливаем считать ли траффик
  str:='';
  popen (f,'cat /etc/sysconfig/network-scripts/ifcfg-'+Edit_iface.Text+'|grep ACCOUNTING|cut -d "=" --fields=2','R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  If str='no' then CheckBox_traffic.Checked:=false else CheckBox_traffic.Checked:=true;
  If not FileExists('/etc/sysconfig/network-scripts/ifcfg-'+Edit_iface.Text) then CheckBox_traffic.Checked:=false;
  //восстанавливаем есть ли refuse-eap
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep refuse-eap','R');
  If not eof (f) then CheckBox_reap.Checked:=true else CheckBox_reap.Checked:=false;
  pclose(f);
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then CheckBox_reap.Checked:=false;
  //восстанавливаем есть ли refuse-pap
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep refuse-pap','R');
  If not eof (f) then CheckBox_rpap.Checked:=true else CheckBox_rpap.Checked:=false;
  pclose(f);
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then CheckBox_rpap.Checked:=false;
  //восстанавливаем есть ли refuse-chap
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep refuse-chap','R');
  If not eof (f) then CheckBox_rchap.Checked:=true else CheckBox_rchap.Checked:=false;
  pclose(f);
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then CheckBox_rchap.Checked:=false;
  //восстанавливаем есть ли refuse-mschap
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep refuse-mschap','R');
  If not eof (f) then CheckBox_rmschap.Checked:=true else CheckBox_rmschap.Checked:=false;
  pclose(f);
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then CheckBox_rmschap.Checked:=false;
  //восстанавливаем есть ли refuse-mschap-v2
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep refuse-mschap-v2','R');
  If not eof (f) then CheckBox_rmschapv2.Checked:=true else CheckBox_rmschapv2.Checked:=false;
  pclose(f);
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then CheckBox_rmschapv2.Checked:=false;
  If not FileExists('/etc/ppp/peers/'+Edit_iface.Text) then
                                     begin
                                        CheckBox_required.Checked:=false;
                                        CheckBox_stateless.Checked:=false;
                                        CheckBox_no40.Checked:=false;
                                        CheckBox_no56.Checked:=false;
                                        CheckBox_no128.Checked:=false;
                                        Edit_mtu.Text:='1460';
                                        Edit_mru.Text:='1460';
                                        Edit_metric.Text:='1';
                                        exit;
                                     end;
  //восстанавливаем mtu
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep mtu|awk '+chr(39)+'{print $2}'+chr(39),'R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  Edit_mtu.Text:=str;
  //восстанавливаем mru
  str:='';
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep mru|awk '+chr(39)+'{print $2}'+chr(39),'R');
  while not eof (f) do
      readln(f,str);
  pclose(f);
  Edit_mru.Text:=str;
  //проверяем тип записи шифрования нестандартный
  mppe_notstandart:=false;
  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep require-mppe','R');
  If not eof (f) then mppe_notstandart:=true;
  pclose(f);
  //проверяем тип записи шифрования стандартный
  If not mppe_notstandart then
              begin
                  mppe_standart:=false;
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep mppe|grep required','R');
                  If not eof (f) then mppe_standart:=true;
                  pclose(f);
              end;
  If (not mppe_notstandart) and (not mppe_standart) then exit; //нет шифрования вообще
  If mppe_standart then
              begin
                  //CheckBox_required.Checked:=true; //не обязательно (включится сам)
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep mppe|grep required|grep stateless','R');
                  If not eof (f) then CheckBox_stateless.Checked:=true else CheckBox_stateless.Checked:=false;
                  pclose(f);
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep mppe|grep required|grep no40','R');
                  If not eof (f) then CheckBox_no40.Checked:=true else CheckBox_no40.Checked:=false;
                  pclose(f);
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep mppe|grep required|grep no56','R');
                  If not eof (f) then CheckBox_no56.Checked:=true else CheckBox_no56.Checked:=false;
                  pclose(f);
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep mppe|grep required|grep no128','R');
                  If not eof (f) then CheckBox_no128.Checked:=true else CheckBox_no128.Checked:=false;
                  pclose(f);
                  If not CheckBox_no56.Visible then CheckBox_no56.Checked:=true;
              end;
  If mppe_notstandart then
              begin
                  CheckBox_required.Checked:=true;
                  CheckBox_no56.Checked:=true;
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep require-mppe-40','R');
                  If not eof (f) then CheckBox_no40.Checked:=false else CheckBox_no40.Checked:=true;
                  pclose(f);
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep require-mppe-128','R');
                  If not eof (f) then CheckBox_no128.Checked:=false else CheckBox_no128.Checked:=true;
                  pclose(f);
                  popen (f,'cat /etc/ppp/peers/'+Edit_iface.Text+'|grep nomppe-stateful','R');
                  If not eof (f) then CheckBox_stateless.Checked:=false else CheckBox_stateless.Checked:=true;
                  pclose(f);
                  If not CheckBox_no56.Visible then CheckBox_no56.Checked:=true;
              end;
end;

procedure TMyForm.Edit_metricChange(Sender: TObject);
  var i:integer;
    str:string;
begin
    str:=Edit_metric.Text;
    for i:=1 to length(str) do
             if not (str[i] in ['0'..'9', #8 ]) then Delete(str,i,1);
    Edit_metric.Text:=str;
end;

procedure TMyForm.Edit_mruChange(Sender: TObject);
var i:integer;
    str:string;
begin
    str:=Edit_mru.Text;
    for i:=1 to length(str) do
             if not (str[i] in ['0'..'9', #8 ]) then Delete(str,i,1);
    Edit_mru.Text:=str;
end;

procedure TMyForm.Edit_mtuChange(Sender: TObject);
var i:integer;
    str:string;
begin
    str:=Edit_mtu.Text;
    for i:=1 to length(str) do
             if not (str[i] in ['0'..'9', #8 ]) then Delete(str,i,1);
    Edit_mtu.Text:=str;
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
ButtonHelp.Enabled:=false;
If FallbackLang='ru' then If FileExists(MyWikiDir+'Help_vpnmcc_ru.doc') then ButtonHelp.Enabled:=true;
//If FallbackLang='uk' then If FileExists(MyWikiDir+'Help_vpnmcc_uk.doc') then ButtonHelp.Enabled:=true;
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
//default_mppe:=false;//для проверки при отладке
if not default_mppe then
               begin
                   CheckBox_no56.Visible:=false;
                   CheckBox_no56.Checked:=true;
               end;
Pclose(f);
Edit_iface.Enabled:=false;
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
//поиск всех интерфейсов pppN
for i:=0 to 100 do
            begin
                 If FileExists(IfcfgDir+'ifcfg-ppp'+IntToStr(i)) then
                                                                     begin
                                                                        ComboBox_iface.AddItem('ppp'+IntToStr(i),nil);
                                                                     end;
            end;
ComboBox_iface.AddItem('ppp'+IntToStr(Number_PPP_Iface),nil);
//Number_PPP_Iface:=101; //просто для проверки при отладке
If Number_PPP_Iface<>101 then Edit_iface.Text:='ppp'+IntToStr(Number_PPP_Iface);
If Edit_iface.Text='' then
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
ComboBox_iface.Text:=Edit_iface.Text;
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
             Label_iface.Hint:=MakeHint(message33ru+' '+message34ru,5);
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
             CheckBox_required.Hint:=MakeHint(message24ru+' '+message25ru+' '+message81ru,6);
             CheckBox_stateless.Hint:=MakeHint(message26ru+' '+message25ru+' '+message81ru,6);
             CheckBox_no40.Hint:=MakeHint(message27ru+' '+message25ru+' '+message81ru,6);
             CheckBox_no56.Hint:=MakeHint(message28ru+' '+message25ru+' '+message81ru,6);
             CheckBox_no128.Hint:=MakeHint(message29ru+' '+message25ru+' '+message81ru,6);
             Label_metric.Hint:=MakeHint(message33ru+' '+message34ru,5);
             MyImage.Hint:=MakeHint(message33ru+' '+message34ru+' '+message73ru,5);
             CheckBox_pppd_log.Hint:=MakeHint(message50ru,6);
             Edit_mtu.Hint:=MakeHint(message66ru+' '+message84ru,5);
             Edit_mru.Hint:=MakeHint(message66ru+' '+message84ru,5);
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
         Label_iface.Hint:=MakeHint(message33uk+' '+message34uk,5);
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
         CheckBox_required.Hint:=MakeHint(message24uk+' '+message25uk+' '+message81uk,6);
         CheckBox_stateless.Hint:=MakeHint(message26uk+' '+message25uk+' '+message81uk,6);
         CheckBox_no40.Hint:=MakeHint(message27uk+' '+message25uk+' '+message81uk,6);
         CheckBox_no56.Hint:=MakeHint(message28uk+' '+message25uk+' '+message81uk,6);
         CheckBox_no128.Hint:=MakeHint(message29uk+' '+message25uk+' '+message81uk,6);
         Label_metric.Hint:=MakeHint(message33uk+' '+message34uk,5);
         MyImage.Hint:=MakeHint(message33uk+' '+message34uk+' '+message73uk,5);
         CheckBox_pppd_log.Hint:=MakeHint(message50uk,6);
         Edit_mtu.Hint:=MakeHint(message66uk+' '+message84uk,5);
         Edit_mru.Hint:=MakeHint(message66uk+' '+message84uk,5);
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
         Label_iface.Hint:=MakeHint(message33en+' '+message34en,5);
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
         CheckBox_required.Hint:=MakeHint(message24en+' '+message25en+' '+message81en,6);
         CheckBox_stateless.Hint:=MakeHint(message26en+' '+message25en+' '+message81en,6);
         CheckBox_no40.Hint:=MakeHint(message27en+' '+message25en+' '+message81en,6);
         CheckBox_no56.Hint:=MakeHint(message28en+' '+message25en+' '+message81en,6);
         CheckBox_no128.Hint:=MakeHint(message29en+' '+message25en+' '+message81en,6);
         Label_metric.Hint:=MakeHint(message33en+' '+message34en,5);
         MyImage.Hint:=MakeHint(message33en+' '+message34en+' '+message73en,5);
         CheckBox_pppd_log.Hint:=MakeHint(message50en,6);
         Edit_mtu.Hint:=MakeHint(message66en+' '+message84en,5);
         Edit_mru.Hint:=MakeHint(message66en+' '+message84en,5);
    end;
end;
//заполнение приложения текстом в соответствии с языком
case q of
    1:
        begin
             MyForm.Caption:=message48ru;
             Label_iface.Caption:=message35ru;
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
             CheckBox_pppd_log.Caption:=message49ru+' '+MyLogDir+'vpnmcc.log';
             Label_wait.Caption:=message68ru;
             Button_after_up.Caption:=message85ru;
             Button_after_down.Caption:=message86ru;
             ButtonHelp.Caption:=message90ru;
        end;
    2:
        begin
             MyForm.Caption:=message48uk;
             Label_iface.Caption:=message35uk;
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
             CheckBox_pppd_log.Caption:=message49uk+' '+MyLogDir+'vpnmcc.log';
             Label_wait.Caption:=message68uk;
             Button_after_up.Caption:=message85uk;
             Button_after_down.Caption:=message86uk;
             ButtonHelp.Caption:=message90uk;
        end;
else
    begin
        MyForm.Caption:=message48en;
        Label_iface.Caption:=message35en;
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
        CheckBox_pppd_log.Caption:=message49en+' '+MyLogDir+'vpnmcc.log';
        Label_wait.Caption:=message68en;
        Button_after_up.Caption:=message85en;
        Button_after_down.Caption:=message86en;
        ButtonHelp.Caption:=message90en;
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
//проверка vpnmcc в процессах root, исключение запуска под иными пользователями
  Apid:=FpGetpid;
  Apidroot:=0;
  popen (f,'ps -u root | '+'grep vpnmcc | '+'awk '+chr(39)+'{print $1}'+chr(39),'R');
  while not eof(f) do
     begin
        readln(f,Apidroot);
        If Apid=Apidroot then break;
     end;
  PClose(f);
  nostart:=false;
  popen (f,'ps -u root | '+'grep vpnmcc | '+'awk '+chr(39)+'{print $4}'+chr(39),'R');
  If eof(f) or (Apid<>Apidroot) then nostart:=true;
  PClose(f);
  If nostart then
                begin
                    If FileExists(MyVpnDir+'vpnmcc.pm') then
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
If not FileExistsBin('pptp') then
                                        begin
                                            If FallbackLang='ru' then Application.MessageBox(PChar(message3ru),PChar(message0ru),0) else
                                                                 If FallbackLang='uk' then Application.MessageBox(PChar(message3uk),PChar(message0uk),0) else
                                                                                                          Application.MessageBox(PChar(message3en),PChar(message0en),0);
                                            Application.ProcessMessages;
                                            MyForm.Repaint;
                                            halt;
                                        end;
//программа устанавливает саму же себя
If DirectoryExists(UsrBinDir) then
     If ParamStr(0)<>UsrBinDir+'vpnmcc' then
        If DirectoryExists(MyVpnDir) then
                                                                  begin
                                                                      If FileExistsBin('vpnmcc') and FileExists (MyVpnDir+'vpnmcc.pm') then ProgramInstalled:=true else ProgramInstalled:=false;
                                                                      FpSystem ('cp -f '+chr(39)+ParamStr(0)+chr(39)+' '+UsrBinDir);
                                                                      MyMemo.Lines.Clear;
                                                                      MyMemo.Lines.Add('package network::vpn::vpnmcc;');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('use base qw(network::vpn);');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('use common;');
                                                                      MyMemo.Lines.Add('use run_program;');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('sub get_type { '+chr(39)+'vpnmcc'+chr(39)+' }');
                                                                      MyMemo.Lines.Add('sub get_description { N("VPN PPTP") }');
                                                                      MyMemo.Lines.Add('sub get_packages { '+chr(39)+'drakx-net'+chr(39)+' }');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('sub read_config {');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('run_program::rooted($::prefix,'+chr(39)+UsrBinDir+'vpnmcc'+chr(39)+');');
                                                                      MyMemo.Lines.Add('end => 1;');
                                                                      MyMemo.Lines.Add('}');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('sub get_settings {');
                                                                      MyMemo.Lines.Add('exit;');
                                                                      MyMemo.Lines.Add('}');
                                                                      MyMemo.Lines.Add('');
                                                                      MyMemo.Lines.Add('1;');
                                                                      MyMemo.Lines.SaveToFile(MyVpnDir+'vpnmcc.pm');
                                                                      If not ProgramInstalled then
                                                                                              begin
                                                                                                   If FallbackLang='ru' then Application.MessageBox(PChar(message17ru+' '+message51ru+' '+UsrBinDir+'vpnmcc, '+MyVpnDir+'vpnmcc.pm.'),PChar(message0ru),0) else
                                                                                                                        If FallbackLang='uk' then Application.MessageBox(PChar(message17uk+' '+message51uk+' '+UsrBinDir+'vpnmcc, '+MyVpnDir+'vpnmcc.pm.'),PChar(message0uk),0) else
                                                                                                                                             Application.MessageBox(PChar(message17en+' '+message51en+' '+UsrBinDir+'vpnmcc, '+MyVpnDir+'vpnmcc.pm.'),PChar(message0en),0);

                                                                                              end
                                                                                                 else
                                                                                                     begin
                                                                                                          If FallbackLang='ru' then Application.MessageBox(PChar(message54ru+' '+message51ru+' '+UsrBinDir+'vpnmcc, '+MyVpnDir+'vpnmcc.pm.'),PChar(message0ru),0) else
                                                                                                                               If FallbackLang='uk' then Application.MessageBox(PChar(message54uk+' '+message51uk+' '+UsrBinDir+'vpnmcc, '+MyVpnDir+'vpnmcc.pm.'),PChar(message0uk),0) else
                                                                                                                                                    Application.MessageBox(PChar(message54en+' '+message51en+' '+UsrBinDir+'vpnmcc, '+MyVpnDir+'vpnmcc.pm.'),PChar(message0en),0);
                                                                                                      end;
                                                                  end;
If (not DirectoryExists(MyVpnDir)) or (not DirectoryExists(UsrBinDir)) then
                                                           begin
                                                                If FallbackLang='ru' then Application.MessageBox(PChar(message16ru),PChar(message0ru),0) else
                                                                                     If FallbackLang='uk' then Application.MessageBox(PChar(message16uk),PChar(message0uk),0) else
                                                                                                                              Application.MessageBox(PChar(message16en),PChar(message0en),0);
                                                           end;
FpSystem('mkdir -p '+LeftStr(MyLibDir,Length(MyLibDir)-1));
//поиск всех интерфейсов pppN, очистка удаленных интерфейсов
for i:=0 to 100 do
            begin
                 If not FileExists(IfcfgDir+'ifcfg-ppp'+IntToStr(i)) then
                                                                     begin
                                                                        FpSystem('rm -f '+MyLibDir+'up-ppp'+IntToStr(i));
                                                                        FpSystem('rm -f '+MyLibDir+'down-ppp'+IntToStr(i));
                                                                        FpSystem('rm -f '+EtcPppPeersDir+'ppp'+IntToStr(i));
                                                                     end;
            end;
If not FileExists(MyLibDir+'down-'+Edit_iface.Text) then
    begin
        If FileExistsBin ('service') then FpSystem('echo '+'service network restart'+' > '+MyLibDir+'down-'+Edit_iface.Text);
        If not FileExistsBin ('service') then if FileExistsBin ('systemctl') then FpSystem('echo '+'systemctl restart network.service'+' > '+MyLibDir+'down-'+Edit_iface.Text);
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

procedure TMyForm.MyPanelResize(Sender: TObject);
begin
   Edit_metric.Width:=Edit_passwd.Width div 5;
   Edit_mtu.Width:=Edit_passwd.Width div 5;
   Edit_mru.Width:=Edit_passwd.Width div 5;
   Edit_mtu.Left:=Edit_metric.Left+Edit_metric.Width*2;
   Edit_mru.Left:=Edit_mtu.Left+Edit_mru.Width*2;
   Button_after_up.Width:=MyForm.Width div 3-8;
   Button_after_down.Width:=MyForm.Width div 3-8;
   ButtonHelp.Width:=MyForm.Width div 3-8;
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
end.

end.

