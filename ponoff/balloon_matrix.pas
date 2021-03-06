unit balloon_matrix;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TFormBalloonMatrix }
  HintBalloonParams=record
               time_of_show_msec:integer;
               msg_title,msg_text:string;
               font_size:integer
             end;

  TFormBalloonMatrix = class(TForm)
    Image1: TImage;
    ImageBackground: TImage;
    LabelText: TLabel;
    LabelTitle: TLabel;
    Panel1: TPanel;
    TimerClose: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerCloseTimer(Sender: TObject);
    procedure BalloonMessage (time_of_show_msec:integer;msg_title,msg_text:string;font_size:integer);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormBalloonMatrix: TFormBalloonMatrix;
  HintBalloon:THintWindow;
  HintBalloonParamsArray:array [0..100] of HintBalloonParams;
  HintBalloonQueueLength:integer;
  k0,k1:integer; //коэффициенты
  k3:integer; //размер иконки в трее

implementation

{ TFormBalloonMatrix }

uses Unit1,Unitpseudotray;

procedure TFormBalloonMatrix.BalloonMessage (time_of_show_msec:integer;msg_title,msg_text:string;font_size:integer);
var
  max_text_width, max_text_height,i:integer;
  X,Y,A,B:integer;
begin
     k0:=35;
     k1:=12;
     if EnablePseudoTray then k3:=Widget.Width else k3:=Form1.TrayIcon1.Icon.Width;
     FormBalloonMatrix.Visible:=true;
     Application.ProcessMessages;
     if HintBalloon.Visible then
                                begin
                                     HintBalloonParamsArray[HintBalloonQueueLength].font_size:=font_size;
                                     HintBalloonParamsArray[HintBalloonQueueLength].msg_text:=msg_text;
                                     HintBalloonParamsArray[HintBalloonQueueLength].msg_title:=msg_title;
                                     HintBalloonParamsArray[HintBalloonQueueLength].time_of_show_msec:=time_of_show_msec;
                                     inc(HintBalloonQueueLength);
                                     exit;
                                end;
     FormBalloonMatrix.LabelTitle.Caption:=msg_title;
     FormBalloonMatrix.Font.Size:=AFont;
     FormBalloonMatrix.Font.Color:=clBlack;
     FormBalloonMatrix.Align:=alClient;
     FormBalloonMatrix.LabelTitle.Font.Style:=[fsBold];
     FormBalloonMatrix.Panel1.BorderSpacing.Around:=1;
     FormBalloonMatrix.Image1.Height:=AFont*5;
     FormBalloonMatrix.Image1.Width:=AFont*5;
     If FileExists(MyPixmapsDir+'ponoff.png') then FormBalloonMatrix.Image1.Picture.LoadFromFile(MyPixmapsDir+'ponoff.png')
                                                                                           else
                                                                                               begin
                                                                                                    FormBalloonMatrix.Image1.Visible:=false;
                                                                                                    k0:=30;
                                                                                               end;
     LabelText.Caption:=msg_text;
     if EnablePseudoTray then X:=Widget.Left else X:=Form1.TrayIcon1.GetPosition.X;
     if EnablePseudoTray then Y:=Widget.Top else Y:=Form1.TrayIcon1.GetPosition.Y;
     max_text_height:=k1*font_size;
     max_text_width:=k0*font_size;
     If Y>(Screen.Height div 2) then B:=Y-max_text_height;
     If Y<=(Screen.Height div 2) then B:=Y+k3;
     If X>(Screen.Width div 2) then A:=X-max_text_width;
     If X<=(Screen.Width div 2) then A:=X+k3;
     HintBalloon.Repaint;
     FormBalloonMatrix.Repaint;
     HintBalloon.ActivateHint(rect(A,B,A+max_text_width,B+max_text_height),'');
     HintBalloon.Repaint;
     FormBalloonMatrix.Repaint;
     Application.ProcessMessages;
     FormBalloonMatrix.TimerClose.Interval:=time_of_show_msec;
     FormBalloonMatrix.TimerClose.Enabled:=true;
     for i:=0 to FormBalloonMatrix.ComponentCount-2 do
     begin
     if (FormBalloonMatrix.Components[i] is TTimer) then continue;
     (FormBalloonMatrix.Components[i] as TControl).OnClick:=FormBalloonMatrix.OnClick;
     end;
end;

procedure TFormBalloonMatrix.TimerCloseTimer(Sender: TObject);
var
  i:integer;
begin
   HintBalloon.Close;
   TimerClose.Enabled:=false;
   if HintBalloonQueueLength>0 then
   begin
     FormBalloonMatrix.BalloonMessage(HintBalloonParamsArray[0].time_of_show_msec,
                                      HintBalloonParamsArray[0].msg_title,
                                      HintBalloonParamsArray[0].msg_text,
                                      HintBalloonParamsArray[0].font_size);
     for i:=0 to HintBalloonQueueLength-1 do
     begin
       HintBalloonParamsArray[i]:=HintBalloonParamsArray[i+1];
     end;
     dec(HintBalloonQueueLength);
   end;
end;

procedure TFormBalloonMatrix.FormClick(Sender: TObject);
begin
   TimerCloseTimer(FormBalloonMatrix);
end;

procedure TFormBalloonMatrix.FormCreate(Sender: TObject);
var
   i:integer;
begin
    FormBalloonMatrix.Parent:=HintBalloon;
    HintBalloonQueueLength:=0;
    i:=0;
    if EnablePseudoTray then
    begin
      while (Widget.Left=0) do
      begin
        sleep (50);
        inc(i);
        if i>20 then break;
      end;
    end
    else
    begin
      while (Form1.TrayIcon1.GetPosition.X=0) do
      begin
        sleep (50);
        inc(i);
        if i>20 then break;
      end;
    end;
end;


initialization
  {$I balloon_matrix.lrs}

end.

