unit hint_matrix;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TFormHintMatrix }

  TFormHintMatrix = class(TForm)
    Image1: TImage;
    LabelConnection: TLabel;
    LabelDNS2: TLabel;
    LabelConnectionInfo: TLabel;
    LabelStatusInfo: TLabel;
    LabelTimeInNetInfo: TLabel;
    LabelDownloadInfo: TLabel;
    LabelUploadInfo: TLabel;
    LabelInterfaceInfo: TLabel;
    LabelIPAddressInfo: TLabel;
    LabelGatewayInfo: TLabel;
    LabelStatus: TLabel;
    LabelDNS1Info: TLabel;
    LabelDNS2Info: TLabel;
    LabelTimeInNet: TLabel;
    LabelDownload: TLabel;
    LabelUpload: TLabel;
    LabelInterface: TLabel;
    LabelIPAddress: TLabel;
    LabelGateway: TLabel;
    LabelDNS1: TLabel;
    TimerClose: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HintMessage (Connection_1,Status_1,TimeInNet_1,Download_1,Upload_1,Interface_1,IPAddress_1,Gateway_1,DNS1_1,DNS2_1,Connection_2,Status_2,TimeInNet_2,Download_2,Upload_2,Interface_2,IPAddress_2,Gateway_2,DNS1_2,DNS2_2:string;font_size:integer);
    procedure HintHide;
    procedure TimerCloseTimer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormHintMatrix: TFormHintMatrix;
  HintSimle:THintWindow;

implementation

uses Unit1;

procedure TFormHintMatrix.HintHide;
begin
    HintSimle.Hide;
end;

procedure TFormHintMatrix.HintMessage (Connection_1,Status_1,TimeInNet_1,Download_1,Upload_1,Interface_1,IPAddress_1,Gateway_1,DNS1_1,DNS2_1,Connection_2,Status_2,TimeInNet_2,Download_2,Upload_2,Interface_2,IPAddress_2,Gateway_2,DNS1_2,DNS2_2:string;font_size:integer);
var
  k3:integer; //размер иконки в трее
  X,Y,A,B:integer;
  max_text_width, max_text_height,i:integer;
begin
  FormHintMatrix.TimerClose.Enabled:=true;

  LabelConnection.Caption:=Connection_1;
  LabelStatus.Caption:=Status_1;
  LabelTimeInNet.Caption:=TimeInNet_1;
  LabelDownload.Caption:=Download_1;
  LabelUpload.Caption:=Upload_1;
  LabelInterface.Caption:=Interface_1;
  LabelIPAddress.Caption:=IPAddress_1;
  LabelGateway.Caption:=Gateway_1;
  LabelDNS1.Caption:=DNS1_1;
  LabelDNS2.Caption:=DNS2_1;

  LabelConnectionInfo.Caption:=Connection_2;
  LabelStatusInfo.Caption:=Status_2;
  LabelTimeInNetInfo.Caption:=TimeInNet_2;
  LabelDownloadInfo.Caption:=Download_2;
  LabelUploadInfo.Caption:=Upload_2;
  LabelInterfaceInfo.Caption:=Interface_2;
  LabelIPAddressInfo.Caption:=IPAddress_2;
  LabelGatewayInfo.Caption:=Gateway_2;
  LabelDNS1Info.Caption:=DNS1_2;
  LabelDNS2Info.Caption:=DNS2_2;

  Visible:=true;
  Font.Size:=AFont;
  Font.Color:=clBlack;
  Align:=alClient;
  max_text_height:=LabelDNS2.Height+LabelDNS2.Top+7;
  max_text_width:=150;

  for i:=0 to FormHintMatrix.ComponentCount-2 do
  begin
   if pos(FormHintMatrix.Components[i].Name,'Timer')<>0 then continue;
   if (FormHintMatrix.Components[i] is TLabel)  then
     if (FormHintMatrix.Components[i] as TLabel).Canvas.TextWidth((FormHintMatrix.Components[i] as TLabel).Caption)+(FormHintMatrix.Components[i] as TLabel).Left>max_text_width then
       max_text_width:=(FormHintMatrix.Components[i] as TLabel).Left+(FormHintMatrix.Components[i] as TLabel).Canvas.TextWidth((FormHintMatrix.Components[i] as TLabel).Caption)+7;
   (FormHintMatrix.Components[i] as TControl).OnClick:=FormHintMatrix.OnClick;
  end;
  X:=Form1.TrayIcon1.GetPosition.X;
  Y:=Form1.TrayIcon1.GetPosition.Y;
  k3:=22;
  If Y>(Screen.Height div 2) then B:=Y-max_text_height;
  If Y<=(Screen.Height div 2) then B:=Y+k3;
  If X>(Screen.Width div 2) then A:=X-max_text_width+max_text_width div 2;
  If X<=(Screen.Width div 2) then A:=X+k3 div 2-max_text_width div 2;
  If A<0 then A:=0;
  If A>Screen.Width then A:=Screen.Width-max_text_width;
  If A+max_text_width>Screen.Width then A:=Screen.Width-max_text_width;
  HintSimle.Repaint;
  FormHintMatrix.Repaint;
  HintSimle.ActivateHint(rect(A,B,A+max_text_width,B+max_text_height),'');
  HintSimle.Repaint;
end;

procedure TFormHintMatrix.TimerCloseTimer(Sender: TObject);
begin
  If Mouse.CursorPos.X>=Form1.TrayIcon1.GetPosition.X then If Mouse.CursorPos.X<=Form1.TrayIcon1.GetPosition.X+22 then
                           If Mouse.CursorPos.Y>=Form1.TrayIcon1.GetPosition.Y then If Mouse.CursorPos.Y<=Form1.TrayIcon1.GetPosition.Y+22 then exit;
   HintHide;
   TimerClose.Enabled:=false;
end;

procedure TFormHintMatrix.FormCreate(Sender: TObject);
begin
    if HintSimle=nil then HintSimle:=THintWindow.Create(nil);
    Parent:=HintSimle;
    FormHintMatrix.BorderSpacing.Around:=1;
    Image1.Visible:=false;
end;

procedure TFormHintMatrix.FormClick(Sender: TObject);
begin
   HintHide;
   TimerClose.Enabled:=false;
end;

initialization
  {$I hint_matrix.lrs}

end.

