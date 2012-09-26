program vpnmandriva;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, Unit1, Unit2;

{$IFDEF WINDOWS}{$R project1.rc}{$ENDIF}

{$R *.res}

begin
  Application.Title:='Настройка подключения к '
    +'VPN через PPTP';
  Application.Initialize;
  Application.CreateForm(TMyForm, MyForm);
  Application.CreateForm(TFormDop, FormDop);
  Application.Run;
end.

