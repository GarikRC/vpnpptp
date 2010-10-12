unit UnitMyMessageBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Kod: TEdit; //возвращает 0 - не нажата никакая клавиша, но нажата кнопка закрытия окна,
                //возвращает 1 - нажата 1-ая кнопка, возвращает 2 - нажата 2-ая кнопка,
                //возвращает 3 - нажата 3-ая кнопка,
    Image1: TImage;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MyMessageBox (mess0,mess1,mess2,mess3,mess4,filepic:string;a,b,c:boolean;FontSize:integer;Icon0:TIcon);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form3: TForm3;

implementation


{ TForm3 }

Procedure TForm3.MyMessageBox (mess0,mess1,mess2,mess3,mess4,filepic:string;a,b,c:boolean;FontSize:integer;Icon0:TIcon);
//заголовок, текст сообщения, текст 1-ой кнопки, текст 2-ой кнопки, текст 3-ей кнопки,
//файл изображения, видимость 1-ой кнопки, видимость 2-ой кнопки, видимость 3-ей кнопки, шрифт, иконка в заголовке
begin
   Form3.Icon:=Icon0;
   Form3.Kod.Text:='0';
   Form3.Caption:=mess0;
   Form3.Label1.Caption:=mess1;
   If FileExists (filepic) then Image1.Picture.LoadFromFile(filepic);
   Form3.BorderStyle:=bsSingle;
   Button1.Caption:=mess2;
   Button2.Caption:=mess3;
   Button3.Caption:=mess4;
   If not a then Button1.Visible:=false else Button1.Visible:=true;
   If not b then Button2.Visible:=false else Button2.Visible:=true;
   If not c then Button3.Visible:=false else Button3.Visible:=true;
   Form3.Height:=152;
   Form3.Width:=670;
   Form3.Font.Size:=FontSize;
   Form3.ShowModal;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
   Form3.Kod.Text:='0';
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
   Form3.Kod.Text:='1';
   Form3.Close;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
   Form3.Kod.Text:='2';
   Form3.Close;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
   Form3.Kod.Text:='3';
   Form3.Close;
end;


initialization
  {$I unitmymessagebox.lrs}

end.

