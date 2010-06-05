unit Unit2; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, SynExportHTML, unix;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    CheckBoxnodefaultroute: TCheckBox;
    CheckBoxpersist: TCheckBox;
    CheckBoxpassive: TCheckBox;
    CheckBoxauth: TCheckBox;
    CheckBoxreplacedefaultroute: TCheckBox;
    CheckBoxnodetach: TCheckBox;
    CheckBoxreceiveall: TCheckBox;
    CheckBoxnoipv6: TCheckBox;
    CheckBoxnoaccomp: TCheckBox;
    CheckBoxnovjccomp: TCheckBox;
    CheckBoxnovj: TCheckBox;
    CheckBoxnoccp: TCheckBox;
    CheckBoxnopcomp: TCheckBox;
    CheckBoxdefaultroute: TCheckBox;
    CheckBoxnomppc: TCheckBox;
    CheckBoxnomppe: TCheckBox;
    CheckBoxnoipdefault: TCheckBox;
    CheckBoxnoauth: TCheckBox;
    CheckBoxnobsdcomp: TCheckBox;
    CheckBoxnodeflate: TCheckBox;
    CheckBoxusepeerdns: TCheckBox;
    CheckBoxlock: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Obrabotka (str_peer:string; more:boolean);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form2: TForm2; 

implementation

procedure TForm2.Obrabotka (str_peer:string; more:boolean);
//восстанавливает сохраненные значения или устанавливает значения по-умолчанию
var
File_peer:textfile;
str:string;
begin
if not FileExists ('/etc/ppp/peers/'+str_peer) then if not more then
                                        begin
                                             CheckBoxlock.Checked:=true;
                                             CheckBoxusepeerdns.Checked:=true;
                                             CheckBoxnodeflate.Checked:=true;
                                             CheckBoxnobsdcomp.Checked:=true;
                                             CheckBoxnoauth.Checked:=true;
                                             CheckBoxpersist.Checked:=true;
                                        end;
If FileExists ('/opt/vpnpptp/config') then if FileExists ('/etc/ppp/peers/'+str_peer) then if not more then
                                        begin
                                           AssignFile (File_peer,'/etc/ppp/peers/'+str_peer);
                                           reset (File_peer);
                                           While not eof (File_peer) do
                                            begin
                                              readln(File_peer, str);
                                              If str='lock' then CheckBoxlock.Checked:=true;
                                              If str='usepeerdns' then CheckBoxusepeerdns.Checked:=true;
                                              If str='nodeflate' then CheckBoxnodeflate.Checked:=true;
                                              If str='nobsdcomp' then CheckBoxnobsdcomp.Checked:=true;
                                              If str='noauth' then CheckBoxnoauth.Checked:=true;
                                              If str='persist' then CheckBoxpersist.Checked:=true;
                                              If str='noipdefault' then CheckBoxnoipdefault.Checked:=true;
                                              If str='nomppe' then CheckBoxnomppe.Checked:=true;
                                              If str='nomppc' then CheckBoxnomppc.Checked:=true;
                                              If str='defaultroute' then CheckBoxdefaultroute.Checked:=true;
                                              If str='nopcomp' then CheckBoxnopcomp.Checked:=true;
                                              If str='noccp' then CheckBoxnoccp.Checked:=true;
                                              If str='novj' then CheckBoxnovj.Checked:=true;
                                              If str='novjccomp' then CheckBoxnovjccomp.Checked:=true;
                                              If str='noaccomp' then CheckBoxnoaccomp.Checked:=true;
                                              If str='noipv6' then CheckBoxnoipv6.Checked:=true;
                                              If str='receive-all' then CheckBoxreceiveall.Checked:=true;
                                              If str='nodetach' then CheckBoxnodetach.Checked:=true;
                                              If str='replacedefaultroute' then CheckBoxreplacedefaultroute.Checked:=true;
                                              If str='auth' then CheckBoxauth.Checked:=true;
                                              If str='passive' then CheckBoxpassive.Checked:=true;
                                              If str='nodefaultroute' then CheckBoxnodefaultroute.Checked:=true;
                                            end;
                                            closefile(File_peer);
                                        end;
end;

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
var str:string;
begin
   Form2.Hide;
//масштабирование формы в зависимости от разрешения экрана
   Form2.Height:=300;
   Form2.Width:=397;
   If Screen.Height<440 then
                            begin
                             Form2.Height:=(Screen.Height div 3)*2;
                             Form2.Width:=(Screen.Width div 3)*2;
                             Form2.Constraints.MaxHeight:=(Screen.Height div 3)*2;
                             Form2.Constraints.MinHeight:=(Screen.Height div 3)*2;
                             Label2.Caption:=Label2.Caption+'_____';
                            end;
   If Screen.Height<=480 then
                        begin
                             Form2.Font.Size:=6;
                             Form2.Height:=(Screen.Height div 3)*2;
                             Form2.Width:=(Screen.Width div 3)*2;
                             Form2.Constraints.MaxHeight:=(Screen.Height div 3)*2;
                             Form2.Constraints.MinHeight:=(Screen.Height div 3)*2;
                             Label2.Caption:=Label2.Caption+'_____';
                        end;
   If Screen.Height<550 then If not (Screen.Height<=480) then
                         begin
                             Form2.Constraints.MaxHeight:=Screen.Height div 2;
                             Form2.Constraints.MinHeight:=Screen.Height div 2;
                         end;
   If Screen.Height>550 then   //разрешение в основном нетбуков
                        begin
                             Form2.Font.Size:=8;
                             Form2.Height:=275;
                             Form2.Width:=397;
                             Form2.Constraints.MaxHeight:=275;
                             Form2.Constraints.MinHeight:=275;
                             Form2.Constraints.MaxWidth:=397;
                             Form2.Constraints.MinWidth:=397;
                             Label2.Caption:=Label2.Caption+'_______';
                        end;
   If Screen.Height>1000 then
                        begin
                             Form2.Font.Size:=10;
                             Form2.Height:=325;
                             Form2.Width:=442;
                             Form2.Constraints.MaxHeight:=325;
                             Form2.Constraints.MinHeight:=325;
                             Form2.Constraints.MaxWidth:=442;
                             Form2.Constraints.MinWidth:=442;
                         end;
end;

procedure TForm2.Label1Click(Sender: TObject);
begin
  Shell ('firefox www.opennet.ru/man.shtml?topic=pppd&category=8');
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
   Form2.Close;
end;


initialization
  {$I unit2.lrs}

end.

