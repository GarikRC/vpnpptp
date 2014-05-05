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
    Button4: TButton;
    ComboBoxProfile: TComboBox;
                //возвращает 1 - нажата 1-ая кнопка, возвращает 2 - нажата 2-ая кнопка,
                //возвращает 3 - нажата 3-ая кнопка,
    Image1: TImage;
    Label1: TLabel;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBoxProfileKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure MyMessageBox (mess0,mess1,mess2,mess3,mess4,filepic:string;a,b,c:boolean;FontSize:integer;Icon0:TIcon;ComboBoxProfileVisible:boolean;MyLibDir0:string);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form3: TForm3;

implementation


{ TForm3 }

Procedure TForm3.MyMessageBox (mess0,mess1,mess2,mess3,mess4,filepic:string;a,b,c:boolean;FontSize:integer;Icon0:TIcon;ComboBoxProfileVisible:boolean;MyLibDir0:string);
//заголовок, текст сообщения, текст 1-ой кнопки, текст 2-ой кнопки, текст 3-ей кнопки,
//файл изображения, видимость 1-ой кнопки, видимость 2-ой кнопки, видимость 3-ей кнопки, шрифт, иконка в заголовке
//видимость ComboBoxProfile, директория библиотек, номер кнопки дефолтной (1,2,3)
var
   FileProfiles:textfile;
   str0:string;
   i:integer;
begin
   If Form3.Visible then Form3.Hide;
   ComboBoxProfile.Visible:=ComboBoxProfileVisible;
   ComboBoxProfile.Text:='';
   ComboBoxProfile.Items.Clear;
   If ComboBoxProfileVisible then
                If FileExists(MyLibDir0+'profiles') then
                                 begin
                                      str0:='';
                                      i:=0;
                                      AssignFile(FileProfiles,MyLibDir0+'profiles');
                                      reset(FileProfiles);
                                      while not eof(FileProfiles) do
                                              begin
                                                  readln(FileProfiles,str0);
                                                  If str0<>'' then
                                                                  begin
                                                                       i:=i+1;
                                                                       ComboBoxProfile.Items.Add(str0);
                                                                  end;
                                               end;
                                      closefile(FileProfiles);
                                      if i>0 then
                                                   begin
                                                      ComboBoxProfile.Text:=str0;
                                                      ComboBoxProfile.Enabled:=true;
                                                   end;
                                      If i=1 then ComboBoxProfile.Enabled:=false;
                                      If i=0 then
                                                   begin
                                                      ComboBoxProfile.Enabled:=false;
                                                      Button2.Enabled:=false;
                                                   end;
                                 end;
   Form3.Icon:=Icon0;
   Form3.Tag:=0;
   Form3.Caption:=mess0;
   Form3.Label1.Caption:=mess1;
   If filepic<>'' then If FileExists (filepic) then
                                                   begin
                                                        Image1.Visible:=true;
                                                        Image1.Picture.LoadFromFile(filepic);
                                                   end;
   If filepic='' then Image1.Visible:=false;
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
   Application.ProcessMessages;
   Form3.ShowModal;
   ComboBoxProfile.Visible:=false;
   ComboBoxProfile.Items.Clear;
   Button1.Visible:=false;
   Button2.Visible:=false;
   Button3.Visible:=false;
   Application.ProcessMessages;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
   Form3.Tag:=0;
   Form3.Constraints.MaxHeight:=Form3.Height;
   Form3.Constraints.MinHeight:=Form3.Height;
   Form3.Constraints.MaxWidth:=Form3.Width;
   Form3.Constraints.MinWidth:=Form3.Width;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
   Form3.Tag:=1;
   Form3.Close;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
   Form3.Tag:=2;
   Form3.Close;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
   Form3.Tag:=3;
   Form3.Close;
end;

procedure TForm3.Button4Click(Sender: TObject);
begin
   Form3.Close;
end;

procedure TForm3.ComboBoxProfileKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=16 then If Button3.Visible then Button3.SetFocus;
   if Key=16 then If not Button3.Visible then If Button2.Visible then Button2.SetFocus;
   if Key=9 then If Button2.Visible then Button2.SetFocus;
   if Key=9 then If not Button2.Visible then If Button3.Visible then Button3.SetFocus;
   Key:=0;
end;

initialization
  {$I unitmymessagebox.lrs}

end.

