unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, RouterOSAPI;

type

  { TDemoAPI }

  TDemoAPI = class(TForm)
    Panel1: TPanel;
    TLS: TCheckBox;
    infoButton: TSpeedButton;
    CommandRun: TSpeedButton;
    IPAdres: TEdit;
    Port: TEdit;
    ConnectButton: TSpeedButton;
    Username: TEdit;
    Password: TEdit;
    GroupBox1: TGroupBox;
    KomutPencere: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Komut: TMemo;
    Result: TMemo;
    procedure baglanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CommandRunClick(Sender: TObject);
    procedure infoButtonClick(Sender: TObject);
    procedure TLSChange(Sender: TObject);
  private

  public

  end;

const
  ProgramName = 'Demonstration of Mikrotik RouterOS APIv1.3 Lazarus:FPC Client';

var
  DemoAPI: TDemoAPI;
  //----------------------------------------------------------------------------
  // RouterOS Tanımlamaları
  //----------------------------------------------------------------------------
  ROS        : TRosApiClient;
  ResListen  : TRosApiResult;
  Res        : TRosApiResult;
  ROSFlag    : Boolean = false;
  //----------------------------------------------------------------------------
implementation

{$R *.lfm}

{ TDemoAPI }

procedure TDemoAPI.baglanClick(Sender: TObject);
begin

  if ConnectButton.Tag = 0 then
   Begin

     if TLS.Checked then
      ROSFlag := ROS.SSLConnect(IPAdres.Text, Username.Text, Password.Text, port.text)
     else
      ROSFlag := ROS.Connect(IPAdres.Text, Username.Text, Password.Text, port.text);

      if ROSFlag Then
       begin  // Connection OK!!
         Result.Lines.Clear;
         Result.lines.add('Connected!');
         ConnectButton.Caption := 'Disconnect';
         ConnectButton.tag := 1;
         Res := ROS.Query(['/system/resource/print'], True);


         if Res.Trap then Result.Lines.Add('İnfo : ' + ROS.LastError)
          else
            begin
            Result.Lines.Add('Device     : ' + Res['board-name']);
            Result.Lines.Add('Version    : ' + Res['version']);
            end;

       end else
        begin  // Connection Error
         Result.lines.add('Connection Error: '+ ROS.LastError);
         ConnectButton.Caption := 'Connect !!';
         ConnectButton.tag := 0;
         ROSFlag := false;
        end;
    end else
    Begin  // Disconnect
     ROS.Disconnect;
     Result.lines.add('Connection Close!!');
     ConnectButton.Caption := 'Connect !!';
     ConnectButton.tag := 0;
     ROSFlag := false;
    end;
end;

procedure TDemoAPI.FormCreate(Sender: TObject);
begin
  //----------------------------------------------------------------------------
  // RouterOS Create
  //----------------------------------------------------------------------------
  ROS := TRosApiClient.Create;
  ResListen := nil;
  //----------------------------------------------------------------------------
  Result.Lines.Clear;
  Result.Lines.Add(ProgramName);
  Caption := ProgramName;
end;

procedure TDemoAPI.FormDestroy(Sender: TObject);
begin
  //----------------------------------------------------------------------------
  // RouterOS Free
  //----------------------------------------------------------------------------
  ROS.Disconnect ;
  ROS.Free;
  Res.Free;
  //----------------------------------------------------------------------------
end;

procedure TDemoAPI.CommandRunClick(Sender: TObject);
var
  pa: array of AnsiString;
  i: Integer;
  s: String;
begin
Result.Lines.Clear;
if ROSFlag then
   begin

  SetLength(pa, 0);
  for i := 0 to Komut.Lines.Count - 1 do
  begin
    s := Trim(Komut.Lines[i]);
    if s <> '' then
    begin
      SetLength(pa, High(pa) + 2);
      pa[High(pa)] := s;
    end;
  end;

  if High(pa) >= 0 then
    Res := ROS.Query(pa, True)
  else
  begin
    ShowMessage('Enter Command!!');
    Komut.SetFocus;
    Exit;
  end;

  if ROS.LastError <> '' then
  begin
    Result.Lines.Add('Error: ' + ROS.LastError);
  end;


  s := '';
  while not Res.Eof do
  begin
    for i := 0 to High(Res.Values) do
      s := s + Res.Values[i].Name + '=' + Res.Values[i].Value + #13#10;
    s := s + '----------------'#13#10;
    Res.Next;
  end;

  if length(s) > 0 then
  begin
    Result.Lines.Add(s);
    Result.SelStart:=0;
  end;

end
else
  Result.Lines.Add('Connect to Device first!!');
end;

procedure TDemoAPI.infoButtonClick(Sender: TObject);
begin

  with Result.Lines do
  begin
  Add('-------------------------------------------------------------------');
  Add('The libraries used in this Application and Build are free.');
  Add('www.sercanca.com');
  Add('By Sercan TEK 2018');
  Add('OS : Windows 10 Pro 64 Bit');
  Add('');
  Add('Lazarus IDE v 1.8.4 vs FPC Sürümü 3.0.4');
  Add('https://www.lazarus-ide.org/');
  Add('');
  Add('Mikrotik Delphi-RouterOS-API v1.3');
  Add('By Pavel Skuratovich (Chupaka)');
  Add('https://github.com/Chupaka/Delphi-RouterOS-API/releases');
  Add('');
  Add('Synapse TCP/IP and serial library');
  Add('http://synapse.ararat.cz/doku.php/download');
  Add('-------------------------------------------------------------------');
  end;
end;

procedure TDemoAPI.TLSChange(Sender: TObject);
begin
  if TLS.Checked then Port.Text:='8729' else Port.text:='8728';
end;

end.

