program SetFileBuildNum;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Windows,
  Classes,
  StrUtils,
  Character,
  unitPEFile in '..\Others\ColinWilson\unitPEFile.pas',
  unitResourceDetails in '..\Others\ColinWilson\unitResourceDetails.pas',
  unitResourceVersionInfo in '..\Others\ColinWilson\unitResourceVersionInfo.pas',
  SetFileBuildNum.VersionNumber in 'SetFileBuildNum.VersionNumber.pas',
  SetFileBuildNum.Parameters in 'SetFileBuildNum.Parameters.pas',
  SetFileBuildNum.App in 'SetFileBuildNum.App.pas';

var
  App:TApp;
begin
  try
    App := TApp.Create;
    try
      App.Run;
    finally
      App.Free;
    end;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
