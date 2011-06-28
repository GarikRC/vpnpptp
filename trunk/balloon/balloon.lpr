program balloon;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,unitballoon,Classes;

{$R *.res}

begin
  Application.Initialize;
  if h<>nil then h.ReleaseHandle else h:=THintWindow.Create(Form1);
  Application.CreateForm(TForm1, Form1);
  Form1.Parent:=h;
  Form1.ShowMyBalloonHint (ParamStr(1),ParamStr(2),ParamStr(3),ParamStr(4),ParamStr(5),ParamStr(6),ParamStr(7),ParamStr(8));
  Application.Run;
end.

