unit Unitpseudotray;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, InterfaceBase, IniPropStorage;

type

  { TWidget }

  TWidget = class(TForm)
    Image1: TImage;
    IniPropStorage1: TIniPropStorage;
    procedure FormWindowStateChange(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure WidgetMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Widget: TWidget;
  Moving: Boolean; OldLeft, OldTop: Integer;

const
  false_str='false';
  true_str='true' ;

implementation
uses unit1, hint_matrix;

{ TWidget }
procedure TWidget.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then
  begin
    Moving:=False;
    if (Widget.Left=0) and (Widget.Top=0) then
                       begin
                            Widget.Left:=1;
                            Widget.Top:=1;
                       end;
    IniPropStorage1.Save;
  end;
end;

procedure TWidget.FormWindowStateChange(Sender: TObject);
begin
  If widget.windowstate=wsMinimized then widget.windowstate:=wsnormal;
end;

procedure TWidget.WidgetMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then
  begin
    // нас интересует только левая кнопка
    OldLeft:=X;
    // сохраняем текущую позицию
    OldTop:=Y;
    Moving:=True;
    FormHintMatrix.HintHide;
  end;
end;

procedure TWidget.FormCreate(Sender: TObject);
begin
  Moving:=false;
  with Widget.IniPropStorage1 do
  begin
    IniFileName:=MyLibDir+'ponoff.conf.ini';
    Save;
  end;
end;

procedure TWidget.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Moving then Self.SetBounds(Self.Left+X - OldLeft, Self.Top+Y - OldTop, Self.width, Self.height) else  Form1.TrayIcon1MouseMove(Sender);
end;

initialization
  {$I unitpseudotray.lrs}

end.

