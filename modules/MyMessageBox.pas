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
  {$I MyMessageBox.lrs}
  Application.Title:='Модуль работы с MyMessageBox';
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

