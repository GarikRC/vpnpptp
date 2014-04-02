unit Unit2; 

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TFormDop }

  TFormDop = class(TForm)
    ButtonOK: TButton;
    ButtonNO: TButton;
    ButtonClear: TButton;
    MemoDop: TMemo;
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonNOClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    FileRoute:string;
  end; 

var
  FormDop: TFormDop;

implementation

{ TFormDop }

procedure TFormDop.ButtonOKClick(Sender: TObject);
begin
    MemoDop.Lines.SaveToFile(FileRoute);
    Close;
end;

procedure TFormDop.ButtonNOClick(Sender: TObject);
begin
    Close;
end;

procedure TFormDop.ButtonClearClick(Sender: TObject);
begin
  MemoDop.Clear;
end;

procedure TFormDop.FormShow(Sender: TObject);
begin
  Constraints.MaxWidth:=width;
  Constraints.MinWidth:=width;
  Constraints.MaxHeight:=Height;
  Constraints.MinHeight:=Height;
  If FileExists(FileRoute) then MemoDop.Lines.LoadFromFile(FileRoute) else MemoDop.Clear;
end;

initialization
  {$I unit2.lrs}

end.

