program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, Unit1, unitmymessagebox, LResources;

{$IFDEF WINDOWS}{$R project1.rc}{$ENDIF}

begin
  Application.Title:=
    'Управление соединением VPN PPTP/L2TP';
  {$I project1.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

