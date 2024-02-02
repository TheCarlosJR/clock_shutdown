unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
    ShellApi,
  {$ENDIF}
  {$IFDEF UNIX}
    Unix,
  {$ENDIF}
  Unit2,
  uGifViewer,
  LCLType, LCLIntF, DateUtils,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, IniPropStorage, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnClear: TBitBtn;
    BtnCalc: TBitBtn;
    Edit1: TEdit;
    GIFViewer1: TGIFViewer;
    GIFViewer2: TGIFViewer;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    LblHour: TLabel;
    LblMin: TLabel;
    LblSec: TLabel;
    Lbl1: TLabel;
    Lbl2: TLabel;
    PanelClock: TPanel;
    TaskDialog1: TTaskDialog;
    Timer1: TTimer;
    TgHour: TToggleBox;
    TgMin: TToggleBox;
    TgSec: TToggleBox;
    procedure BtnCalcClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label1MouseEnter(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure LblHourDblClick(Sender: TObject);
    procedure PanelClockClick(Sender: TObject);
    procedure TgHourClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure ChangeToggles(const aState: Boolean);
    procedure ChangeMode();
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  _COLOR_FRM_IDLE_  = $00ADE3ED;
  _COLOR_FRM_TIMER_ = $004899F2;
  _STR_CHECKCALC_1_ = 'Absolute time';
  _STR_CHECKCALC_2_ = 'Calculate from relative time';

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Run Shell Execute
// https://wiki.lazarus.freepascal.org/Executing_External_Programs#MS_Windows_:_CreateProcess.2C_ShellExecute_and_WinExec
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{$IFDEF WINDOWS}
procedure RunShellExecute(const prog, params: String);
begin
  //  ( Handle, nil/'open'/'edit'/'find'/'explore'/'print',   // 'open' isn't always needed
  //      path+prog, params, working folder,
  //        0=hide / 1=SW_SHOWNORMAL / 3=max / 7=min)   // for SW_ constants : uses ... Windows ...
  if (ShellExecute(0, 'open', PChar(prog),PChar(params),PChar(extractfilepath(prog)),1) > 32) then; //success
  // return values 0..32 are errors
end;
{$ENDIF}

{ TForm1 }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Form Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm1.FormResize(Sender: TObject);
begin
  PanelClock.Left:= (Form1.Width - PanelClock.Width) div 2;
  PanelClock.Top:= (Form1.Height - PanelClock.Height) div 2;
  PanelClock.Invalidate;
end;

procedure TForm1.FormClick(Sender: TObject);
begin
  Edit1Exit(Edit1);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Timer Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm1.Timer1Timer(Sender: TObject);
var
  aTime, sTime: TDateTime;
  vH, vM, vS,
  tmpWa, tmpWs: Word;
  tmpI: Int64;
  tmpS: String;
  boolH,
  boolM,
  boolS: Boolean;
begin
  //desabilita evento timer
  Timer1.OnTimer:= nil;

  //inicializa variaveis
  tmpS:= '';
  boolH:= False;
  boolM:= False;
  boolS:= False;

  //comuta labels de pontos
  Lbl1.Visible:= not Lbl1.Visible;
  Lbl2.Visible:= not Lbl2.Visible;

  //obtem hora atual
  aTime:= Now;

  //obtem hora especifica (para testes)
  //aTime:= ComposeDateTime(Now, EncodeTime(23,00,0,0));

  //obtem hora agendada
   if (TgHour.Checked = True) then
     vH:= StrToInt(LblHour.Caption)
   else
     vH:= HourOf(aTime);

   //obtem minuto agendado
   if (TgMin.Checked = True) then
     vM:= StrToInt(LblMin.Caption)
   else
     vM:= MinuteOf(aTime);

   //obtem segundo agendado
   if (TgSec.Checked = True) then
     vS:= StrToInt(LblSec.Caption)
   else
     vS:= SecondOf(aTime);

   //agrega hora e data em tempo definido
  sTime:= ComposeDateTime(aTime, EncodeTime(vH, vM, vS, 0));

  //se hora habilitada
  if (TgHour.Checked = True) then
  begin
    //pega somente a hora
    tmpWa:= HourOf(aTime);
    tmpWs:= HourOf(sTime);

    //se hora atual for maior que setada
    if (tmpWa > tmpWs) then
    begin
      //pega hora como se fosse proximo dia
      sTime:= IncDay(sTime, 1);
    end;

    //pega horas entre duas datas
    tmpI:= HoursBetween(aTime, sTime);

    //se houver horas restantes
    if (tmpI > 0) then
    begin
      sTime:= IncMinute(sTime, tmpI * (-60));
      tmpS:= tmpS + ' ' + IntToStr(tmpI) + 'h';
    end
    else
      boolH:= True;
  end
  else
    boolH:= True;

  //se minuto habilitado
  if (TgMin.Checked = True) then
  begin
    //pega minutos entre duas datas
    tmpI:= MinutesBetween(aTime, sTime);

     //se houver minutos restantes
    if (tmpI > 0) then
    begin
      sTime:= IncSecond(sTime, tmpI * (-60));
      tmpS:= tmpS + ' ' + IntToStr(tmpI) + 'm';
    end
    else
      boolM:= True;
  end
  else
    boolM:= True;

  //se segundo habilitado
  if (TgSec.Checked = True) then
  begin
    //pega segundos entre duas datas
    tmpI:= SecondsBetween(aTime, sTime);

     //se houver segundos restantes
    if (tmpI > 0) then
    begin
      tmpS:= tmpS + ' ' + IntToStr(tmpI) + 's';
    end
    else
      boolS:= True;
  end
  else
    boolS:= True;

  //se ja deu o tempo de desligar
  if ((boolH = True) and (boolM = True) and (boolS = True)) then
  begin
    //desabilita timer
    Timer1.Enabled:= False;

    //mostra janela
    Form2.ShowModal();

    //se cancelou operacao
    if (Form2.Res = mrCancel) then
    begin
      //forca limpar e parar processo
      Timer1.Enabled:= True;
      BtnClear.Click;
    end
    //se confirmou operacao
    else begin
      {$IFOPT D+}
         ShowMessage('SHUTDOWN');
         Self.Close;
      {$ELSE}
        {$IFDEF WINDOWS}
           RunShellExecute('shutdown.exe', ' -s -t 0');
        {$ENDIF}
        {$IFDEF UNIX}
           fpSystem('sudo /sbin/shutdown -P now');
        {$ENDIF}
      {$ENDIF}

      Exit;
    end;
  end;

  //mostra tempo restante
  Self.Caption:= 'Clock Turnoff - Time left:' + tmpS;

  //habilita evento timer
  Timer1.OnTimer:= @Timer1Timer;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Label Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm1.LblHourDblClick(Sender: TObject);
begin
  //interrompe processos
  Timer1.Enabled:= False;
  TgHour.Checked:= False;
  TgMin.Checked:= False;
  TgSec.Checked:= False;

  //altera visual
  ChangeMode();

  //mostra edit com dados do label clicado
  Edit1.Text:= TLabel(Sender).Caption;
  Edit1.Tag:= TLabel(Sender).Tag;
  Edit1.Visible:= True;
  Edit1.Top:=  TLabel(Sender).Top  + PanelClock.Top  - ((Edit1.Height - TLabel(Sender).Height) div 2);
  Edit1.Left:= TLabel(Sender).Left + PanelClock.Left - ((Edit1.Width  - TLabel(Sender).Width)  div 2);
  Edit1.SetFocus;
end;

procedure TForm1.Label1MouseEnter(Sender: TObject);
begin
  Label1.Font.Style:= Label1.Font.Style + [fsUnderline];
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  OpenURL('https://lordicon.com/');
end;

procedure TForm1.Label1MouseLeave(Sender: TObject);
begin
  Label1.Font.Style:= Label1.Font.Style - [fsUnderline];
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Panel Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
procedure TForm1.PanelClockClick(Sender: TObject);
begin
  Edit1Exit(Edit1);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ToggleBox Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm1.TgHourClick(Sender: TObject);
var
  TmrON: Boolean;
  tmpC: Byte;
begin
  //backup
  TmrON:= Timer1.Enabled;

  //conta desligados
  tmpC:= 0;
  if (TgHour.Checked = False) then
    inc(tmpC);
  if (TgMin.Checked = False) then
    inc(tmpC);
  if (TgSec.Checked = False) then
    inc(tmpC);

  //se este botao esta habilitado
  if (TToggleBox(Sender).Checked = True) then
  begin
    //se eh a primeira vez
    if (tmpC = 2) then
    begin
      //desabilita timer
      Timer1.Enabled:= False;

      //desabilita botao
      TToggleBox(Sender).OnClick:= nil;
      TToggleBox(Sender).Checked:= False;
      TToggleBox(Sender).OnClick:= @TgHourClick;

      //mostra dialogo
      if (TaskDialog1.Execute() = True) then
      begin
        //resposta positiva permite verificacoes
        if (TaskDialog1.ModalResult = mrYes) then
        begin
          //altera todos os botoes
          ChangeToggles(True);

          //habilita timer
          Timer1.Enabled:= True;
        end;
      end;
    end;
  end

  //se este botao esta desabilitado
  else begin
    //se nenhum habilitado
    if (tmpC = 3) then
    begin
      Timer1.Enabled:= False;
      Form1.Caption:= 'Clock Turnoff - Undefined';
    end;
  end;

  //se houve alteracao no timer
  if (Timer1.Enabled <> TmrON) then
  begin
    //altera visual do form
    ChangeMode();
  end;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Button Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm1.BtnCalcClick(Sender: TObject);
var
  aTime, cTime: TDateTime;
begin
  //interrompe processos
  Timer1.Enabled:= False;

  //altera todos os botoes
  ChangeToggles(False);

  //altera visual do form
  ChangeMode();

  //pega hora atual
  aTime:= Now;
  cTime:= aTime;

  //avanca no tempo conforme determinado
  cTime:= IncHour(cTime,   StrToInt(LblHour.Caption));
  cTime:= IncMinute(cTime, StrToInt(LblMin.Caption));
  cTime:= IncSecond(cTime, StrToInt(LblSec.Caption));

  //coloca novo valor na label
  LblHour.Caption:= Format('%.2d', [HourOf(cTime)]);
  LblMin.Caption:=  Format('%.2d', [MinuteOf(cTime)]);
  LblSec.Caption:=  Format('%.2d', [SecondOf(cTime)]);
end;

procedure TForm1.BtnClearClick(Sender: TObject);
begin
  if (Timer1.Enabled = False) then
    Exit;

  //interrompe processos
  Timer1.Enabled:= False;

  //altera todos os botoes
  ChangeToggles(False);

  //altera visual do form
  ChangeMode();
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Edit Events
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure TForm1.Edit1EditingDone(Sender: TObject);
var
  tmpW: Integer;
begin
  //coloca zero a esquerda
  if (Length(Edit1.Text) = 1) then
    Edit1.Text:= '0' + Edit1.Text;

  //verifica se eh numero valido
  if (TryStrToInt(Edit1.Text, tmpW) = True) then
  begin
    case (Edit1.Tag) of
      1:
      begin
        if ((tmpW >= 24) or (tmpW < 0)) then
          LblHour.Caption:= '00'
        else
          LblHour.Caption:= Edit1.Text;
      end;

      2:
      begin
        if ((tmpW >= 60) or (tmpW < 0)) then
          LblMin.Caption:= '00'
        else
          LblMin.Caption:= Edit1.Text;
      end;

      3:
      begin
        if ((tmpW >= 60) or (tmpW < 0)) then
          LblSec.Caption:= '00'
        else
          LblSec.Caption:= Edit1.Text;
      end;
    end;
  end;

  //oculta este controle
  Edit1.Visible:= False;
end;

procedure TForm1.Edit1Exit(Sender: TObject);
begin
  //forca edit done mas sem aplicar
  Edit1.Text:= '';
  Edit1.Visible:= False;
end;

procedure TForm1.Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //se cancelou
  if (Key = VK_ESCAPE) then
    Edit1Exit(Edit1);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ChangeToggles - Altera todos os botoes sem acionar evento
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
procedure TForm1.ChangeToggles(const aState: Boolean);
begin
  TgHour.OnClick:= nil;
  TgMin.OnClick:=  nil;
  TgSec.OnClick:=  nil;
  TgHour.Checked:= aState;
  TgMin.Checked:=  aState;
  TgSec.Checked:=  aState;
  TgHour.OnClick:= @TgHourClick;
  TgMin.OnClick:=  @TgHourClick;
  TgSec.OnClick:=  @TgHourClick;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ChangeMode - Muda visual conforme operacao
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
procedure TForm1.ChangeMode();
begin
  //altera controles do form
  if (Timer1.Enabled = True) then
  begin
    Form1.Color:= _COLOR_FRM_TIMER_;
    GIFViewer1.Visible:= False;
    GIFViewer2.Visible:= True;
    BtnClear.Enabled:= True;
  end
  else begin
    Form1.Color:= _COLOR_FRM_IDLE_;
    GIFViewer1.Visible:= True;
    GIFViewer2.Visible:= False;
    BtnClear.Enabled:= False;

    Lbl1.Visible:= True;
    Lbl2.Visible:= True;
  end;

  //ANTIBUG - atualiza fundo do panel
  PanelClock.ParentColor:= False;
  PanelClock.ParentColor:= True;
end;

end.

