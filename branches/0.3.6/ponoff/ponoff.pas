program ponoff;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, Unit1, unitmymessagebox, balloon_matrix,
  types, sysutils, hint_matrix, Unitpseudotray;

{$IFDEF WINDOWS}{$R project1.rc}{$ENDIF}

{$R *.res}

begin
  Application.Title:=
    'Управление соединением VPN PPTP/L2TP';
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  if HintBalloon=nil then HintBalloon:=THintWindow.Create(nil);
  if HintSimle=nil then HintSimle:=THintWindow.Create(nil);
  Application.CreateForm(TWidget, Widget);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

