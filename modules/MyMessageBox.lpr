program MyMessageBox;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, UnitMyMessageBox, LResources;

{$IFDEF WINDOWS}{$R MyMessageBox.rc}{$ENDIF}

begin
  Application.Title:='Модуль работы с MyMessageBox';
  {$I MyMessageBox.lrs}
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

