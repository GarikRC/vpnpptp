program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, Unit1, unitmymessagebox, Unit2;

{$IFDEF WINDOWS}{$R project1.rc}{$ENDIF}

{$R *.res}

begin
  Application.Title:=
    'Управление соединением VPN PPTP/L2TP';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

