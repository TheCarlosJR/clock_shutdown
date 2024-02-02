unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  LCLType,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons;

type

  { TForm2 }

  TForm2 = class(TForm)
    BtnYes: TBitBtn;
    BtnCancel: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnYesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    Res: TModalResult;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Form Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm2.FormShow(Sender: TObject);
begin
  //prepara visual
  Res:= mrCancel;
  Timer1.Tag:= 10;
  Label2.Caption:= '10 s';
  BtnCancel.SetFocus;

  //inicializa timer
  Timer1.OnTimer:= @Timer1Timer;
  Timer1.Enabled:= True;
end;

procedure TForm2.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    BtnCancel.Click;
end;

procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Timer1.Enabled:= False;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Timer Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Timer1.OnTimer:= nil;

  //conta segundos ate zero
  if (Timer1.Tag > 0) then
  begin
    Timer1.Tag:= Timer1.Tag - 1;
    Label2.Caption:= IntToStr(Timer1.Tag) + ' s';
  end
  else
    BtnYes.Click;

  Timer1.OnTimer:= @Timer1Timer;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Button Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm2.BtnYesClick(Sender: TObject);
begin
  Res:= mrYes;
  Self.Close;
end;

procedure TForm2.BtnCancelClick(Sender: TObject);
begin
  Res:= mrCancel;
  Self.Close;
end;

end.

