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
  StdCtrls, ExtCtrls, ComCtrls, unix;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button_create: TButton;
    Button_exit: TButton;
    Button_next: TButton;
    CheckBox_desktop: TCheckBox;
    CheckBox_no40: TCheckBox;
    CheckBox_no56: TCheckBox;
    CheckBox_rchap: TCheckBox;
    CheckBox_reap: TCheckBox;
    CheckBox_rmschap: TCheckBox;
    CheckBox_shifr: TCheckBox;
    CheckBox_stateless: TCheckBox;
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
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label_IPS: TLabel;
    Label_gate: TLabel;
    Label_IPS2: TLabel;
    Label_peer1: TLabel;
    Label_route: TLabel;
    Label_user: TLabel;
    Label_pswd: TLabel;
    Label_mtu: TLabel;
    Label_peer: TLabel;
    Label_peername: TLabel;
    Label_ip_up: TLabel;
    Label_ip_down: TLabel;
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
    procedure Button_nextClick(Sender: TObject);
    procedure CheckBox_shifrChange(Sender: TObject);
    procedure Edit_IPSChange(Sender: TObject);
    procedure Edit_passwdChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label_IPSClick(Sender: TObject);
    procedure Label_pswdClick(Sender: TObject);
    procedure Label_userClick(Sender: TObject);
    procedure Memo_gateChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.Button_createClick(Sender: TObject);
var mppe_string:string;
    i:integer;
begin
 TabSheet1.TabVisible:= False;
 TabSheet2.TabVisible:= False;
 TabSheet3.TabVisible:= False;
 TabSheet4.TabVisible:= True;
 Button_create.Visible:=False;

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
 Memo_peer.Lines.Add('maxfail 10');
 Memo_peer.Lines.Add('defaultroute');
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

 //Записываем имя соединения для скрипта поднятия
 Shell('rm -f /opt/vpnpptp/config');
 Shell('printf "'+Edit_peer.Text+' \n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_IPS.Text+' \n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_gate.Text+' \n" >> /opt/vpnpptp/config');
 Shell('printf "'+Edit_eth.Text+' \n" >> /opt/vpnpptp/config');

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
     if DirectoryExists('/home/'+Memo_users.Lines[i]+'/Рабочий стол/') then
      begin
       Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/Рабочий стол/ponoff.desktop');
      end;
      i:=i+1;
    end;
  Shell('cat /etc/passwd | grep 50 | cut -d: -f1 > /tmp/users');   //для старых идентификаторов
  Memo_users.Clear;
  Memo_users.Lines.LoadFromFile('/tmp/users');
  i:=0;
   while Memo_users.Lines.Count > i do
    begin
     if DirectoryExists('/home/'+Memo_users.Lines[i]+'/Рабочий стол/') then
      begin
       Memo_create.Lines.SaveToFile('/home/'+Memo_users.Lines[i]+'/Рабочий стол/ponoff.desktop');
      end;
      i:=i+1;
    end;

  end;

  Memo_create.Clear;
  Memo_create.Lines.LoadFromFile('/opt/vpnpptp/success');
  Shell('rm -f /tmp/users');
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

procedure TForm1.Button_nextClick(Sender: TObject);
begin
  Button_create.Visible:=True;
  TabSheet2.TabVisible:=True;
  PageControl1.ActivePageIndex:=1;
  //Определяем шлюз по умолчанию
  Shell('/sbin/ip r|grep default|awk '+ chr(39)+'{print $3}'+chr(39)+' > /tmp/gate');
  Shell('printf "none" >> /tmp/gate');
  Memo_gate.Clear;
  If FileExists('/tmp/gate') then Memo_gate.Lines.LoadFromFile('/tmp/gate');
  Edit_gate.Text:=Memo_gate.Lines[0];
  If LeftStr(Memo_gate.Lines[0],3)='ppp' then
                                         begin
                                           Edit_gate.Text:='none';
                                           Application.MessageBox('Рекомендуется отключить поднятое VPN PPTP - тогда шлюз локальной сети определится автоматически.','Внимание!', 0);
                                         end;
  Memo_route.Clear;
  //Memo_route.Lines[0]:='';
  //Определяет сетевой интерфейс по умолчанию
  Shell('/sbin/mii-tool > /tmp/eth');
  Shell('printf "none" >> /tmp/eth');
  Memo_eth.Clear;
  If FileExists('/tmp/eth') then
  Memo_eth.Lines.LoadFromFile('/tmp/eth');
  Edit_eth.Text:=LeftStr(Memo_eth.Lines[0],4);
  If Edit_eth.Text='none' then
                           begin
                             Edit_gate.Text:='none';
                             Application.MessageBox('Рекомендуется включить необходимую для конфигурирования VPN PPTP сетевую карту - тогда VPN PPTP автоматически настроится на ней. ','Внимание!', 0);
                           end;
  If RightStr(Memo_eth.Lines[0],7)='no link' then
                           begin
                             Edit_eth.Text:='none';
                             Edit_gate.Text:='none';
                             Application.MessageBox('Сетевой кабель для автоматического определения шлюза локальной сети не подключен.','Внимание!', 0);
                           end;
  If Edit_gate.Text='none' then
                           begin
                             Edit_eth.Text:='none';
                             Application.MessageBox('Не удалось автоматически определить шлюз локальной сети.','Внимание!', 0);
                           end;
  Memo_route.Clear;
  Memo_route.Lines[0]:='';
  Button_next.Visible:=False;
  Shell('rm -f /tmp/gate');
  Shell('rm -f /tmp/eth');
  Shell('rm -f /tmp/users');
  Shell('rm -f /tmp/tmpsetup');
  Shell('rm -f /tmp/tmpnostart');

end;

procedure TForm1.CheckBox_shifrChange(Sender: TObject);
begin
  If CheckBox_shifr.Checked then
   begin
    CheckBox_no40.Checked:=True;
    CheckBox_no56.Checked:=True;
    CheckBox_rchap.Checked:=True;
    CheckBox_reap.Checked:=True;
    CheckBox_rmschap.Checked:=True;
    CheckBox_stateless.Checked:=True;
   end
  else
   begin
    CheckBox_no40.Checked:=False;
    CheckBox_no56.Checked:=False;
    CheckBox_rchap.Checked:=False;
    CheckBox_reap.Checked:=False;
    CheckBox_rmschap.Checked:=False;
    CheckBox_stateless.Checked:=False;
   end;
end;

procedure TForm1.Edit_IPSChange(Sender: TObject);
begin

end;

procedure TForm1.Edit_passwdChange(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
var i,j:integer;
    k:boolean; //запуск под root, под live
    m:boolean; //двойной запуск,
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
   If LeftStr(tmpnostart.Lines[0],7)='vpnpptp' then k:=true;
   If LeftStr(tmpnostart.Lines[0],7)='vpnpptp' then if LeftStr(tmpnostart.Lines[1],7)='vpnpptp' then m:=true;
   If not k then
             begin
               Application.MessageBox('Запуск этой программы возможен только под администратором и live-пользователем. Нажмите <OK> для отказа от запуска.','Внимание!', 0);
               Shell('rm -f /tmp/tmpnostart');
               halt;
             end;
   If m then
             begin
               Application.MessageBox('Другая такая же программа уже пытается сконфигурировать VPN PPTP. Нажмите <OK> для отказа от двойного запуска.','Внимание!', 0);
               Shell('rm -f /tmp/tmpnostart');
               halt;
             end;
  Shell('rm -f /tmp/tmpnostart');
  Application.MessageBox('Запуск конфигуратора VPN PPTP может занять некоторое время, если в системе не установлен пакет pptp-linux.','Внимание!', 0);
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
     If LeftStr(Memo_pptp.Lines[j],i)='Установка не удалась' then
      begin
          Application.MessageBox('Невозможно настроить VPN PPTP в связи с отсутствием пакета pptp-linux и невозможностью его автоматической установки.','Внимание!', 0);
          Shell('rm -f /tmp/tmpsetup');
          halt;
      end;
   end;
  Shell('echo "#Clear config file" > /etc/ppp/options');
  Shell('echo "#Clear config file" > /etc/ppp/options.pptp');
  TabSheet2.TabVisible:= False;
  TabSheet3.TabVisible:= False;
  TabSheet4.TabVisible:= False;
  PageControl1.ActivePageIndex:=0;
  Button_create.Visible:=False;
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

procedure TForm1.PageControl1Change(Sender: TObject);
begin

end;

initialization
  {$I unit1.lrs}

end.
