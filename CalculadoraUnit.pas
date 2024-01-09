unit CalculadoraUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ComObj, MMSystem, IniFiles,
  Vcl.ExtCtrls;

const
  xlValues = -4163;
  xlWhole = 1;
  xlByRows = 1;
  xlPrevious = 2;
  ArquivoConfiguracao = 'config.ini';

type
  TForm1 = class(TForm)
    Label1: TLabel;
    horaEntrada: TEdit;
    Label2: TLabel;
    horaSaida: TEdit;
    CalcularB: TButton;
    Memo1: TMemo;
    SaidaB: TButton;
    EntradaB: TButton;
    GerarExcel: TButton;
    Memo2: TMemo;
    AtualizarExcel: TButton;
    Status: TLabel;
    Memo3: TMemo;
    Memo4: TMemo;
    Apagar: TButton;
    CheckBoxSom: TCheckBox;
    procedure CalcularBClick(Sender: TObject);
    procedure EntradaBClick(Sender: TObject);
    procedure SaidaBClick(Sender: TObject);
    procedure GerarExcelClick(Sender: TObject);
    procedure AtualizarExcelClick(Sender: TObject);
    procedure ApagarClick(Sender: TObject);
    procedure CheckBoxSomClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  SomDesabilitado: Boolean = False;


implementation

{$R *.dfm}



procedure SalvarConfiguracao;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ArquivoConfiguracao);
  try
    IniFile.WriteBool('Configuracao', 'SomDesabilitado', SomDesabilitado);
  finally
    IniFile.Free;
  end;
end;



procedure CarregarConfiguracao;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ArquivoConfiguracao);
  try
    SomDesabilitado := IniFile.ReadBool('Configuracao', 'SomDesabilitado', True);
  finally
    IniFile.Free;
  end;
end;




procedure TForm1.CalcularBClick(Sender: TObject);
var
  Entrada, Saida, Trabalhadas: TDateTime;
begin
  // Converter os valores das caixas de entrada para DateTime
  Entrada := StrToTime(horaEntrada.Text);
  Saida := StrToTime(horaSaida.Text);

  // Calcular a diferen�a entre a hora de sa�da e a hora de entrada
  Trabalhadas := Saida - Entrada;

  // Exibir o resultado no Memo1
  Memo1.Lines.Add(FormatDateTime('hh:nn:ss', Trabalhadas));
  Memo2.Lines.Add(FormatDateTime('dd/mm/yyyy', Now));
  Memo3.Lines.Add(horaEntrada.Text);
  Memo4.Lines.Add(horaSaida.Text);

  //Habilitar para editar caixas de novo
  EntradaB.Enabled := True;
  CalcularB.Enabled := False;

  //Habilitar para gerar o Excel
  GerarExcel.Enabled := True;

  //Habilitar para atualizar uma planilha
  AtualizarExcel.Enabled := True;

  //Efeito sonoro
  if not SomDesabilitado then
     PlaySound('C:\Users\User\Documents\Embarcadero\Studio\Projects\Calculadora de Horas Trabalhadas\Sounds\mouseclick.wav', 0, SND_ASYNC);
end;



procedure TForm1.CheckBoxSomClick(Sender: TObject);
begin
   SomDesabilitado := CheckBoxSom.Checked;
   SalvarConfiguracao;
end;



procedure TForm1.EntradaBClick(Sender: TObject); // Bot�o de Entrada
begin
  SaidaB.Enabled := True;
  EntradaB.Enabled := False;
  horaEntrada.Text := FormatDateTime('hh:nn:ss', Now);
  Status.Enabled := True;
  Status.Font.Color := clGreen;
  Status.Caption := 'Trabalhando...';
  if not SomDesabilitado then
     PlaySound('C:\Users\User\Documents\Embarcadero\Studio\Projects\Calculadora de Horas Trabalhadas\Sounds\mouseclick.wav', 0, SND_ASYNC);
end;



procedure TForm1.SaidaBClick(Sender: TObject); // Bot�o de Sa�da
begin
  SaidaB.Enabled := False;
  CalcularB.Enabled := True;
  horaSaida.Text := FormatDateTime('hh:nn:ss', Now);
  Status.Font.Color := clMaroon;
  Status.Caption := 'Finalizado';
  if not SomDesabilitado then
     PlaySound('C:\Users\User\Documents\Embarcadero\Studio\Projects\Calculadora de Horas Trabalhadas\Sounds\mouseclick.wav', 0, SND_ASYNC);
end;




procedure TForm1.GerarExcelClick(Sender: TObject);  //Bot�o de Gerar Excel
 var
   ExcelApp, Planilha, PlanilhaAtiva: Variant;
   horaString: string;
   dateString: string;
   entradaString: string;
   saidaString: string;
   horaExcel: TDateTime;
   dateExcel: TDate;
   entradaExcel: TDateTime;
   saidaExcel: TDateTime;
   linha: integer;
   maxLinhas: integer;
   openFileDialog: TOpenDialog;

   begin
      ExcelApp := CreateOleObject('Excel.Application');
      ExcelApp.Visible := True;
      Planilha := ExcelApp.Workbooks.Add;
      PlanilhaAtiva := Planilha.ActiveSheet;

      // Adicionar cabe�alho
      Planilha.Sheets[1].Cells[1, 1] := 'Data';
      Planilha.Sheets[1].Cells[1, 2] := 'Horas Trabalhadas';
      Planilha.Sheets[1].Cells[1, 3] := 'Entrada';
      Planilha.Sheets[1].Cells[1, 4] := 'Sa�da';

      // Determinar o n�mero m�ximo de linhas entre Memo1 e Memo2
        if Memo1.Lines.Count > Memo2.Lines.Count then
        maxLinhas := Memo1.Lines.Count
      else
        maxLinhas := Memo2.Lines.Count;

      // Loop para cada linha do Memo1 e Memo2
      for linha := 1 to maxLinhas do
      begin
        // Obt�m a string de hora do Memo1
        if linha <= Memo1.Lines.Count then
        begin
          horaString := Memo1.Lines[linha - 1];
          horaExcel := StrToTime(horaString);
          PlanilhaAtiva.Cells[linha + 1, 2] := FormatDateTime('hh:nn:ss', horaExcel);
        end;

        // Obt�m a string da data do Memo2
        if linha <= Memo2.Lines.Count then
        begin
          dateString := Memo2.Lines[linha - 1];
          dateExcel := StrToDate(dateString);
          PlanilhaAtiva.Cells[linha + 1, 1] := FormatDateTime('dd/mm/yyyy', dateExcel);
        end;

        // Obt�m a string da entrada do Memo3
        if linha <= Memo3.Lines.Count then
        begin
          entradaString := Memo3.Lines[linha - 1];
          entradaExcel := StrToTime(entradaString);
          PlanilhaAtiva.Cells[linha + 1, 3] := FormatDateTime('hh:nn:ss', entradaExcel);
        end;

        // Obt�m a string da saida do Memo4
        if linha <= Memo4.Lines.Count then
        begin
          saidaString := Memo4.Lines[linha - 1];
          saidaExcel := StrToTime(saidaString);
          PlanilhaAtiva.Cells[linha + 1, 4] := FormatDateTime('hh:nn:ss', saidaExcel);
        end;

      end;
   if not SomDesabilitado then
     PlaySound('C:\Users\User\Documents\Embarcadero\Studio\Projects\Calculadora de Horas Trabalhadas\Sounds\mouseclick.wav', 0, SND_ASYNC);
   // Salvar o arquivo
   Planilha.SaveAs('C:\Users\User\Desktop\horastrabalhadas.xlsx');
   ExcelApp.Quit;
   end;




procedure TForm1.ApagarClick(Sender: TObject);
  var
    maxLinhas, linhaSelecionada: integer;
    Entrada, Saida, Trabalhadas: TDateTime;
  begin
    if Memo1.Lines.Count > Memo2.Lines.Count then
      maxLinhas := Memo1.Lines.Count
    else
      maxLinhas := Memo2.Lines.Count;

  // Verificar se h� pelo menos uma linha no Memo1
    if maxLinhas > 0 then
    begin
      // Selecionar a �ltima linha do Memo1
      linhaSelecionada := maxLinhas - 1;

      // Deletar a �ltima linha do Memo1
      Memo1.Lines.Delete(linhaSelecionada);
      Memo2.Lines.Delete(linhaSelecionada);
      Memo3.Lines.Delete(linhaSelecionada);
      Memo4.Lines.Delete(linhaSelecionada);
    end;
    if not SomDesabilitado then
     PlaySound('C:\Users\User\Documents\Embarcadero\Studio\Projects\Calculadora de Horas Trabalhadas\Sounds\mouseclick.wav', 0, SND_ASYNC);
  end;




procedure TForm1.AtualizarExcelClick(Sender: TObject);
var
  ExcelApp, Planilha, PlanilhaAtiva: Variant;
  horaString: string;
  dateString: string;
  entradaString: string;
  saidaString: string;
  horaExcel: TDateTime;
  dateExcel: TDate;
  entradaExcel: TDateTime;
  saidaExcel: TDateTime;
  linha: Integer;
  maxLinhas: Integer;
  openFileDialog: TOpenDialog;
  ultimaLinha: Integer;
begin
  if not SomDesabilitado then
     PlaySound('C:\Users\User\Documents\Embarcadero\Studio\Projects\Calculadora de Horas Trabalhadas\Sounds\mouseclick.wav', 0, SND_ASYNC);
  openFileDialog := TOpenDialog.Create(Self);
  openFileDialog.Filter := 'Arquivos Excel (*.xlsx)|*.xlsx';
  openFileDialog.Title := 'Selecione um arquivo Excel existente';

  if openFileDialog.Execute then
  begin
    ExcelApp := CreateOleObject('Excel.Application');
    ExcelApp.Visible := True;
    Planilha := ExcelApp.Workbooks.Open(openFileDialog.FileName);
    PlanilhaAtiva := Planilha.ActiveSheet;

    // Encontrar a �ltima linha ocupada na coluna A (Data)
    ultimaLinha := PlanilhaAtiva.UsedRange.Rows.Count + 1;

    // Determinar o n�mero m�ximo de linhas entre Memo1 e Memo2
    if Memo1.Lines.Count > Memo2.Lines.Count then
      maxLinhas := Memo1.Lines.Count
    else
      maxLinhas := Memo2.Lines.Count;

    // Loop para cada linha do Memo1 e Memo2
    for linha := ultimaLinha to ultimaLinha + maxLinhas - 1 do
    begin

      // Obt�m a string de hora do Memo1
      if linha - ultimaLinha + 1 <= Memo1.Lines.Count then
      begin
        horaString := Memo1.Lines[linha - ultimaLinha];
        horaExcel := StrToTime(horaString);
        PlanilhaAtiva.Cells[linha, 2] := FormatDateTime('hh:nn:ss', horaExcel);
      end;

      // Obt�m a string da data do Memo2
      if linha - ultimaLinha + 1 <= Memo2.Lines.Count then
      begin
        dateString := Memo2.Lines[linha - ultimaLinha];
        dateExcel := StrToDate(dateString);
        PlanilhaAtiva.Cells[linha, 1] := FormatDateTime('dd/mm/yyyy', dateExcel);
      end;

      // Obt�m a string da entrada do Memo3
      if linha - ultimaLinha + 1 <= Memo3.Lines.Count then
      begin
        entradaString := Memo3.Lines[linha - ultimaLinha];
        entradaExcel := StrToTime(entradaString);
        PlanilhaAtiva.Cells[linha, 3] := FormatDateTime('hh:nn:ss', entradaExcel);
      end;

      // Obt�m a string da saida do Memo4
      if linha - ultimaLinha + 1 <= Memo4.Lines.Count then
      begin
        saidaString := Memo4.Lines[linha - ultimaLinha];
        saidaExcel := StrToTime(saidaString);
        PlanilhaAtiva.Cells[linha, 4] := FormatDateTime('hh:nn:ss', saidaExcel);
      end;

    end;

    // Salvar as altera��es no arquivo Excel
    Planilha.Save;
    ExcelApp.Quit;
  end
  else
  begin
    ShowMessage('Nenhum arquivo Excel selecionado.');
  end;

   openFileDialog.Free;
   end;



end.
