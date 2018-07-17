unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, RouterOSAPI;

type

  { TApiTester }

  TApiTester = class(TForm)
    Hakkinda: TSpeedButton;
    KomutGonder: TSpeedButton;
    IPAdres: TEdit;
    Port: TEdit;
    Baglan: TSpeedButton;
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
    Sonuc: TMemo;
    procedure baglanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure KomutGonderClick(Sender: TObject);
    procedure HakkindaClick(Sender: TObject);
  private

  public

  end;

var
  ApiTester: TApiTester;
  //----------------------------------------------------------------------------
  // RouterOS Tanımlamaları
  //----------------------------------------------------------------------------
  ROS        : TRosApiClient;
  ResListen  : TRosApiResult;
  Res        : TRosApiResult;
  ROSBaglanti: Boolean = false;
  //----------------------------------------------------------------------------
implementation

{$R *.lfm}

{ TApiTester }

procedure TApiTester.baglanClick(Sender: TObject);
begin

  if Baglan.Tag = 0 then
   Begin
     ROSBaglanti := ROS.Connect(IPAdres.Text, Username.Text, Password.Text, port.text);
      if ROSBaglanti Then
       begin  // Bağlandı
         Sonuc.Lines.Clear;
         Sonuc.lines.add('Bağlantı Başarılı!');
         Baglan.Caption := 'Bağlantıyı Kes';
         Baglan.tag := 1;
         Res := ROS.Query(['/system/resource/print'], True);


         if Res.Trap then Sonuc.Lines.Add('Bilgi : ' + ROS.LastError)
          else
            begin
            Sonuc.Lines.Add('Cihaz      : ' + Res['board-name']);
            Sonuc.Lines.Add('Versiyon : ' + Res['version']);
            end;

       end else
        begin  // Bağlanamadı
         Sonuc.lines.add('Bağlantı Başarısız - Hata: '+ ROS.LastError);
         Baglan.Caption := 'Bağlan';
         Baglan.tag := 0;
         ROSBaglanti := false;
        end;
    end else
    Begin  // Aktif Bağlantı kapatıldı.
     ROS.Disconnect;
     Sonuc.lines.add('Bağlantı Kapatıldı!');
     Baglan.Caption := 'Bağlan';
     Baglan.tag := 0;
     ROSBaglanti := false;
    end;
end;

procedure TApiTester.FormCreate(Sender: TObject);
begin
  //----------------------------------------------------------------------------
  // RouterOS Nesneler Oluşturuluyor.
  //----------------------------------------------------------------------------
  ROS := TRosApiClient.Create;
  ResListen := nil;
  //----------------------------------------------------------------------------
  Sonuc.Lines.Clear;
  Sonuc.Lines.Add('Mikrotik API Tester v1 - Powered By Lazarus:FPC');;
end;

procedure TApiTester.FormDestroy(Sender: TObject);
begin
  //----------------------------------------------------------------------------
  // RouterOS Hafızadan Silinsin
  //----------------------------------------------------------------------------
  ROS.Disconnect ;
  ROS.Free;
  Res.Free;
  //----------------------------------------------------------------------------
end;

procedure TApiTester.KomutGonderClick(Sender: TObject);
var
  pa: array of AnsiString;
  i: Integer;
  s: String;
begin
Sonuc.Lines.Clear;
if ROSBaglanti then
   begin
  // Komutları Diziye Aktarır.
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
  // Eğer Komut Girildi İse Çalıştır.
  if High(pa) >= 0 then
    Res := ROS.Query(pa, True)
  else
  begin
    ShowMessage('Komut Girin!!');
    Komut.SetFocus;
    Exit;
  end;
  // Geri Hata Dönerse Göstersin.
  if ROS.LastError <> '' then
  begin
    Sonuc.Lines.Add('HATA: ' + ROS.LastError);
  end;

  // Gelen Datayı s değişkenine aktar.
  s := '';
  while not Res.Eof do
  begin
    for i := 0 to High(Res.Values) do
      s := s + Res.Values[i].Name + '=' + Res.Values[i].Value + #13#10;
    s := s + '----------------'#13#10;
    Res.Next;
  end;

  // Data varsa Memo'ya aktar
  if length(s) > 0 then
  begin
    Sonuc.Lines.Add(s);
    Sonuc.SelStart:=0;
  end;

end
else
  Sonuc.Lines.Add('Önce Cihaza Bağlan!!');
end;

procedure TApiTester.HakkindaClick(Sender: TObject);
begin

  with Sonuc.Lines do
  begin
  Add('-------------------------------------------------------------------');
  Add('Bu Uygulama ve Yapımında kullanılan kütüphaneler ücretsizdir.');
  Add('www.sercanca.com');
  Add('By Sercan TEK 2018');
  Add('Derleme : Windows 10 Pro 64 Bit');
  Add('');
  Add('Lazarus IDE v 1.8.4 vs FPC Sürümü 3.0.4');
  Add('https://www.lazarus-ide.org/');
  Add('');
  Add('Mikrotik Delphi-RouterOS-API');
  Add('By Pavel Skuratovich (Chupaka)');
  Add('https://github.com/Chupaka/Delphi-RouterOS-API/releases');
  Add('');
  Add('Synapse TCP/IP and serial library');
  Add('http://synapse.ararat.cz/doku.php/download');
  Add('-------------------------------------------------------------------');
  end;
end;

end.

