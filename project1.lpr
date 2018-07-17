program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='Mikrotik - Pascal API Tester';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TApiTester, ApiTester);
  Application.Run;
end.

