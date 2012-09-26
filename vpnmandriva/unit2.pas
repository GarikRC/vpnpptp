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
    MemoDop: TMemo;
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

procedure TFormDop.FormShow(Sender: TObject);
begin
  If FileExists(FileRoute) then MemoDop.Lines.LoadFromFile(FileRoute) else MemoDop.Clear;
end;

initialization
  {$I unit2.lrs}

end.

