program vpnpptp;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, Unit1, LResources, Unit2, UnitMyMessageBox;

{$IFDEF WINDOWS}{$R project1.rc}{$ENDIF}

{$R *.res}

begin
  Application.Title:='Настройка подключения к '
    +'VPN через PPTP/L2TP/OpenL2TP';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

