{ PPTP VPN setup

  Copyright (C) 2009 Alexander Kazancev kazancas@gmail.com

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
  StdCtrls, ExtCtrls, ComCtrls, unix, Translations, Gettext, Typinfo;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button_create: TButton;
    Button_exit: TButton;
    Button_next1: TButton;
    Button_next2: TButton;
    CheckBox_shorewall: TCheckBox;
    dhcp_route: TCheckBox;
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
    CheckBox_shifr: TCheckBox;
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
    Edit_mtu: TEdit;
    Edit_passwd: TEdit;
    Edit_peer: TEdit;
    Edit_user: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label4: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label_IPS: TLabel;
    Label_gate: TLabel;
    Label_IPS2: TLabel;
    Label_ip_down: TLabel;
    Label_ip_up: TLabel;
    Label_peer: TLabel;
    Label_peer1: TLabel;
    Label_peername: TLabel;
    Label_route: TLabel;
    Label_user: TLabel;
    Label_pswd: TLabel;
    Label_mtu: TLabel;
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
    procedure Button_addoptionsClick(Sender: TObject);
    procedure Button_createClick(Sender: TObject);
    procedure Button_exitClick(Sender: TObject);
    procedure Button_next1Click(Sender: TObject);
    procedure Button_next2Click(Sender: TObject);
    procedure Button_next3Click(Sender: TObject);
    procedure CheckBox_shorewallChange(Sender: TObject);
    procedure dhcp_routeChange(Sender: TObject);
    procedure Memo_configChange(Sender: TObject);
    procedure Mii_tool_noChange(Sender: TObject);
    procedure CheckBox_shifrChange(Sender: TObject);
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
  Lang,FallbackLang:string;
resourcestring
  message0='Внимание!';
  message1='Поля "Провайдер (IP или имя)", "Имя соединения", "Пользователь", "Пароль" обязательны к заполнению.';
  message2='Так как Вы отказались от контроля state сетевого кабеля, то в целях снижения нагрузки на систему время дозвона установлено в 20 сек.';
  message3='Так как Вы не выбрали реконнект, то выбор встроенного в демон pppd реконнекта проигнорирован.';
  message4='Так как реконнект будет реализован встроенным в демон pppd методом, то время реконнекта (время отправки LCP эхо-запросов) установлено в 20 сек.';
  message5='Так как реконнект будет реализован встроенным в демон pppd методом, то время дозвона не используется за ненадобностью.';
  message6='Так как выбрана/изменена опция получения маршрутов через DHCP, то сеть будет перезапущена.';
  message7='Рабочий стол';//папка (директория) пользователя
  message8='В поле "Время дозвона" можно ввести лишь число в пределах от 5 до 255 сек.';
  message9='Так как выбрана опция добавления интерфейсов [ppp0..ppp9] в исключения файервола, то файервол будет перезапущен.';
  message10='В поле "Время реконнекта" можно ввести лишь число в пределах от 0 до 255 сек.';
  message11='Рекомендуется отключить поднятое VPN PPTP - тогда шлюз локальной сети определится автоматически.';
  message12='Сетевой интерфейс не определился.';
  message13='Сетевой кабель для автоматического определения шлюза локальной сети не подключен.';
  message14='Не удалось автоматически определить шлюз локальной сети.';
  message15='Поле "Сетевой интерфейс" заполнено неверно. Правильно от eth0 до eth9.';
  message16='Поле "Шлюз локальной сети" заполнено неверно. Правильно: xxx.xxx.xxx.xxx, где xxx - число от 0 до 255.';
  message17='Поле "MTU" заполнено неверно. Разрешен лишь диапазон [576..1460..1492..1500]. Рекомендуется MTU=1460.';
  message18='Запуск этой программы возможен только под администратором и live-пользователем. Нажмите <OK> для отказа от запуска.';
  message19='Другая такая же программа уже пытается сконфигурировать VPN PPTP. Нажмите <OK> для отказа от двойного запуска.';
  message20='Невозможно настроить VPN PPTP в связи с отсутствием пакета pptp-linux и невозможностью его автоматической установки.';
  message21='Установка не удалась';//выхлоп urpmi --auto pptp-linux
  message22='Рекомендуется запускать эту программу под администратором.';

  message24='Файервол уже настроен.';

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
  Content := UTF8ToSystemCharSet(Content); // convert UTF8 to current local
end;

{ TForm1 }

procedure TForm1.Button_createClick(Sender: TObject);
var mppe_string:string;
    i:integer;
    pchar_message0,pchar_message1:pchar;
begin
If Mii_tool_no.Checked then If StrToInt(Edit_MaxTime.Text)<20 then
                        begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message2);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Edit_MaxTime.Text:='20';
                        end;
If Reconnect_pptp.Checked then If Edit_MinTime.Text='0' then
                        begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message3);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Reconnect_pptp.Checked:=False;
                        end;
If Reconnect_pptp.Checked then If StrToInt(Edit_MinTime.Text)<20 then
                        begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message4);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Edit_MinTime.Text:='20';
                        end;
If Reconnect_pptp.Checked then
                        begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message5);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                        end;
 If dhcp_route.Checked then If not FileExists('/etc/dhclient-exit-hooks.old') then
                       begin
                          if FileExists('/etc/dhclient.conf') then Shell('cp -f /etc/dhclient.conf'+' '+'/etc/dhclient.conf.old');
                          Shell('rm -f /etc/dhclient.conf');
                          if FileExists('/opt/vpnpptp/scripts/dhclient.conf') then Shell('cp -f /opt/vpnpptp/scripts/dhclient.conf'+' '+'/etc/dhclient.conf');
                          if FileExists('/etc/dhclient-exit-hooks') then Shell('cp -f /etc/dhclient-exit-hooks'+' '+'/etc/dhclient-exit-hooks.old');
                          Shell('rm -f /etc/dhclient-exit-hooks');
                          if FileExists('/opt/vpnpptp/scripts/dhclient-exit-hooks') then Shell('cp -f /opt/vpnpptp/scripts/dhclient-exit-hooks'+' '+'/etc/dhclient-exit-hooks');
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message6);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Shell ('/etc/init.d/network restart');
                       end;
If not dhcp_route.Checked then If FileExists('/etc/dhclient-exit-hooks.old') then
                       begin
                          if FileExists('/etc/dhclient.conf.old') then Shell('cp -f /etc/dhclient.conf.old'+' '+'/etc/dhclient.conf');
                          Shell('rm -f /etc/dhclient.conf.old');
                          if FileExists('/etc/dhclient-exit-hooks.old') then Shell('cp -f /etc/dhclient-exit-hooks.old'+' '+'/etc/dhclient-exit-hooks');
                          Shell('rm -f /etc/dhclient-exit-hooks.old');
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message6);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Shell ('/etc/init.d/network restart');
                       end;
 If CheckBox_shorewall.Checked then
                        begin
                          If FileExists('/etc/shorewall/interfaces') then
                              begin
                                 Memo_shorewall.Lines.Clear;
                                 Memo_shorewall.Lines.LoadFromFile('/etc/shorewall/interfaces');
                                   If Memo_shorewall.Lines[0]='# vpnpptp changed this config' then
                                      begin
                                        CheckBox_shorewall.Checked:=false;
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message24);
                                        Application.MessageBox(pchar_message1,pchar_message0, 0);
                                      end;
                                   If Memo_shorewall.Lines[0]<>'# vpnpptp changed this config' then
                                      begin
                                        pchar_message0:=Pchar(message0);
                                        pchar_message1:=Pchar(message9);
                                        Application.MessageBox(pchar_message1,pchar_message0, 0);
                                        i:=0;
                                        Repeat
                                        i:=i+1;
                                        until Memo_shorewall.Lines[i]='#LAST LINE -- DO NOT REMOVE';
                                        Shell('rm -f /etc/shorewall/interfaces');
                                        Memo_shorewall.Lines[0]:='# vpnpptp changed this config';
                                        Memo_shorewall.Lines[i]:='net    ppp0    detect          ';
                                        Memo_shorewall.Lines.SaveToFile('/etc/shorewall/interfaces');
                                        Shell('printf "\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp1    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp2    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp3    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp4    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp5    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp6    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp7    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp8    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "net    ppp9    detect\n" >> /etc/shorewall/interfaces');
                                        Shell('printf "#LAST LINE -- DO NOT REMOVE\n" >> /etc/shorewall/interfaces');
                                        Shell ('/etc/init.d/shorewall restart');
                                      end;
                              end;
                       end;
 if FileExists('/etc/ppp/peers/'+Edit_peer.Text) then Shell('cp -f /etc/ppp/peers/'+Edit_peer.Text+' /etc/ppp/peers/'+Edit_peer.Text+chr(46)+'old');
 Label_peername.Caption:='/etc/ppp/peers/'+Edit_peer.Text;
 Shell('rm -f '+ Label_peername.Caption);
 Memo_peer.Clear;
 Memo_peer.Lines.Add('pty "pptp ' +Edit_IPS.Text +' --nolaunchpppd"');
 Memo_peer.Lines.Add('remotename pptp');
 Memo_peer.Lines.Add('user "'+Edit_user.Text+'"');
 Memo_peer.Lines.Add('password "'+Edit_passwd.Text+'"');
 Memo_peer.Lines.Add('lock');
 Memo_peer.Lines.Add('usepeerdns');
 Memo_peer.Lines.Add('nodeflate');
 Memo_peer.Lines.Add('nobsdcomp');
 Memo_peer.Lines.Add('noauth');
 Memo_peer.Lines.Add('persist');
 If not Reconnect_pptp.Checked then Memo_peer.Lines.Add('maxfail 10') else
                                    begin
                                      Memo_peer.Lines.Add('maxfail 0');
                                      Memo_peer.Lines.Add('lcp-echo-interval '+Edit_MinTime.Text);
                                      Memo_peer.Lines.Add('lcp-echo-failure 4');
                                    end;
 Memo_peer.Lines.Add('defaultroute');
 If Pppd_log.Checked then Memo_peer.Lines.Add('debug');
 If Edit_mtu.Text <> '' then Memo_peer.Lines.Add('mtu '+Edit_mtu.Text);
//Разбираемся с шифрованием
 If CheckBox_shifr.Checked then
  begin
   mppe_string:='mppe required';
   if CheckBox_stateless.Checked then mppe_string:=mppe_string+','+CheckBox_stateless.Caption;
   if CheckBox_no40.Checked then mppe_string:=mppe_string+','+CheckBox_no40.Caption;
   if CheckBox_no56.Checked then mppe_string:=mppe_string+','+CheckBox_no56.Caption;
   If CheckBox_rmschap.Checked then Memo_peer.Lines.Add(CheckBox_rmschap.Caption);
   If CheckBox_reap.Checked then Memo_peer.Lines.Add(CheckBox_reap.Caption);
   If CheckBox_rchap.Checked then Memo_peer.Lines.Add(CheckBox_rchap.Caption);
   Memo_peer.Lines.Add(mppe_string);
  end;
 Memo_peer.Lines.SaveToFile(Label_peername.Caption); //записываем профиль подключения
//удаляем временные файлы
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');
//Делаем ссылку из /sbin/ip в /bin/ip
 if not(FileExists('/bin/ip')) then Shell('ln -s /sbin/ip /bin/ip');
//перезаписываем скрипт поднятия соединения ip-up
 if FileExists(Label_ip_up.Caption) then Shell('cp -f '+ Label_ip_up.Caption+' '+Label_ip_up.Caption+chr(46)+'old');
 Shell('rm -f '+ Label_ip_up.Caption);
 Memo_ip_up.Clear;
 Memo_ip_up.Lines.Add('#!/bin/sh');
 If Memo_route.Lines[0]<>'' then
  begin
   i:=0;
   While Memo_route.Lines.Count > i do
    begin
     Memo_ip_up.Lines.Add(Memo_route.Lines[i]);
     i:=i+1;
    end;
  end;
 Memo_ip_up.Lines.Add('/sbin/route del default');
 Memo_ip_up.Lines.Add('/sbin/route add default dev ppp0');
 Memo_ip_up.Lines.SaveToFile(Label_ip_up.Caption);
 Shell('chmod a+x '+ Label_ip_up.Caption);
//перезаписываем скрипт опускания соединения ip-down
 if FileExists(Label_ip_down.Caption) then Shell('cp -f '+ Label_ip_down.Caption+' '+Label_ip_down.Caption+chr(46)+'old');
 Shell('rm -f '+ Label_ip_down.Caption);
 Memo_ip_down.Clear;
 Memo_ip_down.Lines.Add('#!/bin/sh');
 Memo_ip_down.Lines.Add('/sbin/route del default');
 if Edit_gate.Text <> '' then
  begin
   Memo_ip_down.Lines.Add('/sbin/route add default gw '+Edit_gate.Text);
  end;
 Memo_ip_down.Lines.SaveToFile(Label_ip_down.Caption);
 Shell('chmod a+x '+ Label_ip_down.Caption);

//Записываем готовый конфиг, кроме логина и пароля
 If Edit_MinTime.Text<>'0' then Edit_MinTime.Text:=Edit_MinTime.Text+'000';
 Edit_MaxTime.Text:=Edit_MaxTime.Text+'000';
 If Edit_mtu.Text='' then Edit_mtu.Text:='mtu-none';
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
 If CheckBox_shifr.Checked then Shell('printf "shifr-yes\n" >> /opt/vpnpptp/config') else
                                              Shell('printf "shifr-no\n" >> /opt/vpnpptp/config');
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
//Создаем ярлык для подключения
 If CheckBox_desktop.Checked then
  begin
  Memo_create.Clear;
  Memo_create.Lines.Add('[Desktop Entry]');
  Memo_create.Lines.Add('Encoding=UTF-8');
  Memo_create.Lines.Add('Comment[ru]=Управление соединением VPN PPTP');
  Memo_create.Lines.Add('Comment=Control MS VPN via PPTP');
  Memo_create.Lines.Add('Exec=/opt/vpnpptp/ponoff');
  Memo_create.Lines.Add('GenericName[ru]=Управление соединением VPN PPTP');
  Memo_create.Lines.Add('GenericName=VPN PPTP Control');
  Memo_create.Lines.Add('Icon=/opt/vpnpptp/ponoff.png');
  Memo_create.Lines.Add('MimeType=');
  Memo_create.Lines.Add('Name[ru]=Подключение '+Edit_peer.Text);
  Memo_create.Lines.Add('Name=Connect '+Edit_peer.Text);
  Memo_create.Lines.Add('Path=');
  Memo_create.Lines.Add('StartupNotify=true');
  Memo_create.Lines.Add('Terminal=false');
  Memo_create.Lines.Add('TerminalOptions=');
  Memo_create.Lines.Add('Type=Application');
  Memo_create.Lines.Add('Categories=GTK;System;Monitor;X-MandrivaLinux-CrossDesktop');
  Memo_create.Lines.Add('X-KDE-SubstituteUID=true');
  Memo_create.Lines.Add('X-KDE-Username=root');
  Memo_create.Lines.Add('StartupNotify=false');
//Получаем список пользователей
  Shell('cat /etc/passwd | grep 100 | cut -d: -f1 > /tmp/users');  //для новых идентификаторов
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile('/tmp/users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
      if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then
      begin
       Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+message7+'/ponoff.desktop');
      end;
      i:=i+1;
    end;
  Shell('cat /etc/passwd | grep 50 | cut -d: -f1 > /tmp/users');   //для старых идентификаторов
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile('/tmp/users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
     if DirectoryExists('/home/'+Memo_users.Lines[i]+'/'+message7+'/') then
      begin
       Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/'+message7+'/ponoff.desktop');
      end;
      i:=i+1;
    end;
  end;
              Button_create.Visible:=True;
              TabSheet2.TabVisible:= False;
              TabSheet1.TabVisible:= False;
              TabSheet3.TabVisible:= False;
              TabSheet4.TabVisible:= True;
              PageControl1.ActivePageIndex:=3;
              Button_next2.Visible:=False;
 Memo_create.Clear;
 If FallbackLang='ru' then  Memo_create.Lines.LoadFromFile('/opt/vpnpptp/lang/success.ru');
 If FallbackLang<>'ru' then  Memo_create.Lines.LoadFromFile('/opt/vpnpptp/lang/success.en');
 Button_create.Visible:=False;
 Shell('rm -f /tmp/users');
 //применяем дополнительные настройки
 If Pppd_log.Checked then Shell ('/opt/vpnpptp/scripts/pppdlog');
end;

procedure TForm1.Button_addoptionsClick(Sender: TObject);
begin

end;

procedure TForm1.Button_exitClick(Sender: TObject);
begin
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');
  halt;
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

procedure TForm1.CheckBox_shorewallChange(Sender: TObject);
begin
  If CheckBox_shorewall.Checked then
                         CheckBox_shorewall.Checked:=true
                                                   else
                                                       CheckBox_shorewall.Checked:=false;
end;

procedure TForm1.dhcp_routeChange(Sender: TObject);
begin
  If dhcp_route.Checked then
                         dhcp_route.Checked:=true
                                                   else
                                                       dhcp_route.Checked:=false;
end;

procedure TForm1.Memo_configChange(Sender: TObject);
begin

end;


procedure TForm1.Mii_tool_noChange(Sender: TObject);
begin
  If Mii_tool_no.Checked then
                         Mii_tool_no.Checked:=true
                                                   else
                                                       Mii_tool_no.Checked:=false;
end;

procedure TForm1.Button_next1Click(Sender: TObject);
var
   i:word;
   y:boolean;
   pchar_message0,pchar_message1:pchar;
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
              Edit_MaxTime.Text:='20';
              exit;
            end;
    if (StrToInt(Edit_MaxTime.Text)<5) or (StrToInt(Edit_MaxTime.Text)>255) then
             begin
               pchar_message0:=Pchar(message0);
               pchar_message1:=Pchar(message8);
               Application.MessageBox(pchar_message1,pchar_message0, 0);
               Edit_MaxTime.Text:='20';
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
              Edit_MinTime.Text:='1';
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
//определяем шлюз по умолчанию
  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('printf "none" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  Edit_gate.Text:=Memo_gate.Lines[0];
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then
                                         begin
                                           Edit_gate.Text:='none';
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
  Memo_route.Clear;
  Memo_route.Lines[0]:='';
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');

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
                         TabSheet2.TabVisible:= True;
                         exit;
                    end;
if Length(Edit_eth.Text)<>4 then
                    begin
                         pchar_message0:=Pchar(message0);
                         pchar_message1:=Pchar(message15);
                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                         Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],4);
                         TabSheet2.TabVisible:= True;
                         exit;
                    end;
if not ((Edit_eth.Text[1]='e') and  (Edit_eth.Text[2]='t') and  (Edit_eth.Text[3]='h')) then y:=true;
if not (Edit_eth.Text[4] in ['0'..'9']) then y:=true;
if y then
                    begin
                          pchar_message0:=Pchar(message0);
                          pchar_message1:=Pchar(message15);
                          Application.MessageBox(pchar_message1,pchar_message0, 0);
                          Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],4);
                          TabSheet2.TabVisible:= True;
                          exit;
                    end;
//проверка корректности ввода шлюза локальной сети
If (Edit_gate.Text='none') or (Edit_gate.Text='') or (Length(Edit_gate.Text)>15) then //15-макс.длина шлюза 255.255.255.255
                    begin
                         pchar_message0:=Pchar(message0);
                         pchar_message1:=Pchar(message16);
                         Application.MessageBox(pchar_message1,pchar_message0, 0);
                         Edit_gate.Text:=Memo_gate.Lines[0];
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
//проверка ввода mtu, разрешен диапазон [576..1500], рекомендуется 1460
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
 Edit_gate.Text:=IntToStr(StrToInt(a))+'.'+IntToStr(StrToInt(b))+'.'+IntToStr(StrToInt(c))+'.'+IntToStr(StrToInt(d)); //сократятся лишние нули, введенные в начале любого из октетов (или квадрантов)
 Button_create.Visible:=True;
 TabSheet1.TabVisible:= False;
 TabSheet2.TabVisible:= False;
 TabSheet3.TabVisible:= True;
 Button_next2.Visible:=False;
end;

procedure TForm1.CheckBox_shifrChange(Sender: TObject);
var
  b:boolean;
begin
  b :=  CheckBox_shifr.Checked;

  CheckBox_no40.Checked:=b;
  CheckBox_no56.Checked:=b;
  CheckBox_rchap.Checked:=b;
  CheckBox_reap.Checked:=b;
  CheckBox_rmschap.Checked:=b;
  CheckBox_stateless.Checked:=b;

end;

procedure TForm1.Edit_IPSChange(Sender: TObject);
begin

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
var i,j:integer;
    k:boolean; //запуск под root, под live
    m:boolean; //двойной запуск,
    pchar_message0,pchar_message1:pchar;
    len:integer;
begin
   k:=false;
   m:=false;
//проверка vpnpptp в процессах root, live, исключение двойного запуска программы, исключение запуска под иными пользователями
   Shell('ps -u root | grep vpnpptp | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart');
   Shell('printf "none" >> /tmp/tmpnostart');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart');
   If LeftStr(tmpnostart.Lines[0],7)='vpnpptp' then k:=true;
   If LeftStr(tmpnostart.Lines[0],7)='vpnpptp' then if LeftStr(tmpnostart.Lines[1],7)='vpnpptp' then m:=true;
   Shell('ps -u live | grep vpnpptp | awk '+chr(39)+'{ print $4 }'+chr(39)+' > /tmp/tmpnostart');
   Shell('printf "none" >> /tmp/tmpnostart');
   Form1.tmpnostart.Clear;
   If FileExists('/tmp/tmpnostart') then tmpnostart.Lines.LoadFromFile('/tmp/tmpnostart');
   If LeftStr(tmpnostart.Lines[0],7)='vpnpptp' then
                                                   begin
                                                      k:=true;
                                                      pchar_message0:=Pchar(message0);
                                                      pchar_message1:=Pchar(message22);
                                                      Shell('rm -f /tmp/tmpnostart');
                                                      Application.MessageBox(pchar_message1,pchar_message0, 0);
                                                      halt;
                                                   end;
   If LeftStr(tmpnostart.Lines[0],7)='vpnpptp' then if LeftStr(tmpnostart.Lines[1],7)='vpnpptp' then m:=true;
   If not k then
             begin
               pchar_message0:=Pchar(message0);
               pchar_message1:=Pchar(message18);
               Application.MessageBox(pchar_message1,pchar_message0, 0);
               Shell('rm -f /tmp/tmpnostart');
               halt;
             end;
   If m then
             begin
               pchar_message0:=Pchar(message0);
               pchar_message1:=Pchar(message19);
               Application.MessageBox(pchar_message1,pchar_message0, 0);
               Shell('rm -f /tmp/tmpnostart');
               halt;
             end;
  Shell('rm -f /tmp/tmpnostart');
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');
  Shell('urpmi --auto pptp-linux >> /tmp/tmpsetup');
  Shell('printf "none" >> /tmp/tmpsetup');
  Memo_pptp.Clear;
  If FileExists('/tmp/tmpsetup') then Memo_pptp.Lines.LoadFromFile('/tmp/tmpsetup');
  For j:=0 to Memo_pptp.Lines.Count-1 do
  For i:=0 to 255 do
   begin
     If LeftStr(Memo_pptp.Lines[j],i)=message21 then
      begin
          pchar_message0:=Pchar(message0);
          pchar_message1:=Pchar(message20);
          Application.MessageBox(pchar_message1,pchar_message0, 0);
          Shell('rm -f /tmp/tmpsetup');
          halt;
      end;
   end;
  Shell('echo "#Clear config file" > /etc/ppp/options');
  Shell('echo "#Clear config file" > /etc/ppp/options.pptp');
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
        If Memo_config.Lines[11]='shifr-yes' then CheckBox_shifr.Checked:= true else CheckBox_shifr.Checked:= false;
        If Memo_config.Lines[12]='rchap-yes' then CheckBox_rchap.Checked:= true else CheckBox_rchap.Checked:= false;
        If Memo_config.Lines[13]='reap-yes' then CheckBox_reap.Checked:= true else CheckBox_reap.Checked:= false;
        If Memo_config.Lines[14]='rmschap-yes' then CheckBox_rmschap.Checked:= true else CheckBox_rmschap.Checked:= false;
        If Memo_config.Lines[15]='stateless-yes' then CheckBox_stateless.Checked:= true else CheckBox_stateless.Checked:= false;
        If Memo_config.Lines[16]='no40-yes' then CheckBox_no40.Checked:= true else CheckBox_no40.Checked:= false;
        If Memo_config.Lines[17]='no56-yes' then CheckBox_no56.Checked:= true else CheckBox_no56.Checked:= false;
        If Memo_config.Lines[18]='shorewall-yes' then CheckBox_shorewall.Checked:=true else CheckBox_shorewall.Checked:=false;
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
  TabSheet1.TabVisible:= True;
  TabSheet2.TabVisible:= False;
  TabSheet3.TabVisible:= False;
  TabSheet4.TabVisible:= False;
  PageControl1.ActivePageIndex:=0;
  Button_create.Visible:=False;
  Button_next1.Visible:=True;
  Button_next2.Visible:=False;
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
begin
    If Pppd_log.Checked then
                         Pppd_log.Checked:=true
                                                   else
                                                       Pppd_log.Checked:=false;
end;

procedure TForm1.Reconnect_pptpChange(Sender: TObject);
begin
    If Reconnect_pptp.Checked then
                         Reconnect_pptp.Checked:=true
                                                   else
                                                       Reconnect_pptp.Checked:=false;
end;

initialization

  {$I unit1.lrs}
  Gettext.GetLanguageIDs(Lang,FallbackLang);
//  FallbackLang:='en'; //просто для проверки при отладке
  If FallbackLang<>'ru' then
                            begin
                               POFileName:= '/opt/vpnpptp/lang/vpnpptp.en.po';
                               Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
                            end;
  If FallbackLang='ru' then
                            begin
                            end;
//  If FallbackLang='en' then
//                           begin
//                              POFileName:= '/opt/vpnpptp/lang/vpnpptp.en.po';
//                              Translations.TranslateUnitResourceStrings('Unit1',POFileName,lang,Fallbacklang);
//                           end;
If FallbackLang<>'ru' then LRSTranslator := TTranslator.Create(POFileName); //перевод (локализация) всей формы приложения
end.

end.
