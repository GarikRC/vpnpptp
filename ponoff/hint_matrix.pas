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

uses Unit1,Unitpseudotray;

procedure TFormHintMatrix.HintHide;
begin
    HintSimle.Hide;
end;

procedure TFormHintMatrix.HintMessage (Connection_1,Status_1,TimeInNet_1,Download_1,Upload_1,Interface_1,IPAddress_1,Gateway_1,DNS1_1,DNS2_1,Connection_2,Status_2,TimeInNet_2,Download_2,Upload_2,Interface_2,IPAddress_2,Gateway_2,DNS1_2,DNS2_2:string;font_size:integer);
var
  k4:integer; //размер иконки в трее
  X,Y,A,B:integer;
  max_text_width, max_text_height,i:integer;
begin
  FormHintMatrix.TimerClose.Enabled:=true;

  LabelConnection.Caption:=Trim(Connection_1);
  LabelStatus.Caption:=Trim(Status_1);
  LabelTimeInNet.Caption:=Trim(TimeInNet_1);
  LabelDownload.Caption:=Trim(Download_1);
  LabelUpload.Caption:=Trim(Upload_1);
  LabelInterface.Caption:=Trim(Interface_1);
  LabelIPAddress.Caption:=Trim(IPAddress_1);
  LabelGateway.Caption:=Trim(Gateway_1);
  LabelDNS1.Caption:=Trim(DNS1_1);
  LabelDNS2.Caption:=Trim(DNS2_1);

  LabelConnectionInfo.Caption:=Trim(Connection_2);
  LabelStatusInfo.Caption:=Trim(Status_2);
  LabelTimeInNetInfo.Caption:=Trim(TimeInNet_2);
  LabelDownloadInfo.Caption:=Trim(Download_2);
  LabelUploadInfo.Caption:=Trim(Upload_2);
  LabelInterfaceInfo.Caption:=Trim(Interface_2);
  LabelIPAddressInfo.Caption:=Trim(IPAddress_2);
  LabelGatewayInfo.Caption:=Trim(Gateway_2);
  LabelDNS1Info.Caption:=Trim(DNS1_2);
  LabelDNS2Info.Caption:=Trim(DNS2_2);

  Visible:=true;
  Align:=alClient;

  max_text_width:=0;
  if EnablePseudoTray then X:=Widget.Left else X:=Form1.TrayIcon1.GetPosition.X;
  if EnablePseudoTray then Y:=Widget.Top else Y:=Form1.TrayIcon1.GetPosition.Y;

  for i:=0 to FormHintMatrix.ComponentCount-2 do
    begin
     if pos(FormHintMatrix.Components[i].Name,'Timer')<>0 then continue;
     (FormHintMatrix.Components[i] as TControl).Font.Size:=font_size;
    end;

  if not HintSimle.Visible then  HintSimle.ActivateHint(rect(X,Y,X,Y),''); // заставляем элементы принято свои размеры  для правильных рассчетов

  for i:=0 to FormHintMatrix.ComponentCount-2 do
  begin
   if (FormHintMatrix.Components[i] is TTimer) then continue;
   if (FormHintMatrix.Components[i] is TLabel)  then
     if (FormHintMatrix.Components[i] as TLabel).Canvas.TextWidth((FormHintMatrix.Components[i] as TLabel).Caption)+(FormHintMatrix.Components[i] as TLabel).Left>max_text_width then
       max_text_width:=(FormHintMatrix.Components[i] as TLabel).Left+(FormHintMatrix.Components[i] as TLabel).Canvas.TextWidth((FormHintMatrix.Components[i] as TLabel).Caption);
   (FormHintMatrix.Components[i] as TControl).OnClick:=FormHintMatrix.OnClick;
  end;

  max_text_height:=LabelDNS2.Height+LabelDNS2.Top+3;
  max_text_width:=max_text_width+6;
  FormHintMatrix.Height:=max_text_height;
  FormHintMatrix.Width:=max_text_width;


  if EnablePseudoTray then X:=Widget.Left else X:=Form1.TrayIcon1.GetPosition.X;
  if EnablePseudoTray then Y:=Widget.Top else Y:=Form1.TrayIcon1.GetPosition.Y;
  if EnablePseudoTray then k4:=Widget.Width else k4:=Form1.TrayIcon1.Icon.Width;

  If Y>(Screen.Height div 2) then B:=Y-max_text_height;
  If Y<=(Screen.Height div 2) then B:=Y+k4;
  If X>(Screen.Width div 2) then A:=X-max_text_width+max_text_width div 2;
  If X<=(Screen.Width div 2) then A:=X+k4 div 2-max_text_width div 2;
  If A<0 then A:=0;
  If A>Screen.Width then A:=Screen.Width-max_text_width;
  If A+max_text_width>Screen.Width then A:=Screen.Width-max_text_width;
  HintSimle.Repaint;
  FormHintMatrix.Repaint;
  HintSimle.ActivateHint(rect(A,B,A+max_text_width,B+max_text_height),'');
  FormHintMatrix.Repaint;
  HintSimle.Repaint;
end;

procedure TFormHintMatrix.TimerCloseTimer(Sender: TObject);
begin
   if EnablePseudoTray then
   begin
   If Mouse.CursorPos.X>=Widget.Left then If Mouse.CursorPos.X<=Widget.Left+Widget.Width then
                            If Mouse.CursorPos.Y>=Widget.Top then If Mouse.CursorPos.Y<=Widget.Top+Widget.Height then exit;
   end
   else
   begin
     If Mouse.CursorPos.X>=Form1.TrayIcon1.GetPosition.X then If Mouse.CursorPos.X<=Form1.TrayIcon1.GetPosition.X+Form1.TrayIcon1.Icon.Width then
                            If Mouse.CursorPos.Y>=Form1.TrayIcon1.GetPosition.Y then If Mouse.CursorPos.Y<=Form1.TrayIcon1.GetPosition.Y+Form1.TrayIcon1.Icon.Height then exit;
   end;
   HintHide;
   TimerClose.Enabled:=false;
end;

procedure TFormHintMatrix.FormCreate(Sender: TObject);
begin
    Parent:=HintSimle;
    FormHintMatrix.BorderSpacing.Around:=1;
    Image1.Visible:=false;
    FormHintMatrix.Color:=$0092FFF8;
    TimerClose.Interval:=1000;
end;

procedure TFormHintMatrix.FormClick(Sender: TObject);
begin
   HintHide;
   TimerClose.Enabled:=false;
end;

initialization
  {$I hint_matrix.lrs}

end.

