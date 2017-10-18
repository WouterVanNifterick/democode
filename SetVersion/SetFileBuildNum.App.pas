unit SetFileBuildNum.App;

interface

uses
  unitPEFile,
  unitResourceDetails,
  unitResourceVersionInfo,
  SetFileBuildNum.Parameters,
  SetFileBuildNum.VersionNumber;

type
  TApp=class
  const
    EXITCODE_OK    = 0;
    EXITCODE_ERROR = 1;
  var
    Parameters:TParameters;
    procedure UpdateVersionNumber;
    procedure Run;
  private
    procedure SetFileVersion(var VersionInfoResourceDetails: TVersionInfoResourceDetails);
    procedure SetProductVersion(VersionInfoResourceDetails: TVersionInfoResourceDetails);
    procedure AppLog(const s:string);
    procedure DebugLog(const s:string);
  end;

implementation

uses
  System.Classes,
  System.SysUtils;

function GetVersionInfoResourceDetails(aResModule: TResourceModule): TVersionInfoResourceDetails;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to aResModule.ResourceCount - 1 do
  begin
    aResModule.ResourceDetails[i];
    if aResModule.ResourceDetails[i] is TVersionInfoResourceDetails then
    begin
      Result := (aResModule.ResourceDetails[i]) as TVersionInfoResourceDetails;
      Break; // I believe there should only ever be one Version resource.
    end;
  end;
end;

procedure TApp.UpdateVersionNumber;
var
  VersionInfoResourceDetails: TVersionInfoResourceDetails;
  Module:TResourceModule;
  LVersion :  TVersionNumber;
begin
  Module := TPEResourceModule.Create;
  try
    Module.LoadFromFile(Parameters.InputFile);
    VersionInfoResourceDetails := GetVersionInfoResourceDetails(Module);

    if not Assigned(VersionInfoResourceDetails) then
      raise Exception.CreateFmt('No VersionInfo found in %s', [Parameters.InputFile]);

    if Parameters.VersionNumber.IsSet or (Parameters.Build > 0) then
    begin
      if Parameters.UpdateFileVersion then
        SetFileVersion(VersionInfoResourceDetails);

      if Parameters.UpdateProductVersion then
        SetProductVersion(VersionInfoResourceDetails);
    end;
    if Parameters.DoSave then
    begin
      DebugLog(Format('Saving %s ...',[Parameters.OutputFile]));
      Module.SaveToFile(Parameters.OutputFile, Parameters.DoCreateBackup);
    end
    else
    begin
      LVersion.FromULargeInteger(VersionInfoResourceDetails.FileVersion);
      AppLog('File version   : '+LVersion.ToString);
      LVersion.FromULargeInteger(VersionInfoResourceDetails.ProductVersion);
      AppLog('Product version: '+LVersion.ToString);
      DebugLog('Not saving');
    end;
  finally
    Module.Free;
  end;
end;

{ TApp }

procedure TApp.AppLog(const s: string);
begin
  if IsConsole then
    Writeln(s);
end;

procedure TApp.DebugLog(const s: string);
begin
  if Parameters.Quiet then
    Exit;

  AppLog(s);
end;

procedure TApp.Run;
begin
  ExitCode := TApp.EXITCODE_ERROR;
  Parameters := TParameters.Init;
  try
    Parameters.ParseFromCommandline;
    UpdateVersionNumber;
    DebugLog('Done (OK).');
    ExitCode := TApp.EXITCODE_OK;
  except
    on e:EArgumentException do
      AppLog(Parameters.GetUsageStr)
    else
    raise;
  end;
end;

procedure TApp.SetFileVersion(var VersionInfoResourceDetails: TVersionInfoResourceDetails);
var
  LVersion: TVersionNumber;
begin
  LVersion.FromULargeInteger(VersionInfoResourceDetails.FileVersion);
  AppLog('Old file version : ' + LVersion.ToString);
  if Parameters.Build > 0 then
    LVersion.Build := Parameters.Build;
  if Parameters.VersionNumber.IsSet then
    LVersion := Parameters.VersionNumber;

  // set numeric value
  AppLog('New file version : ' + LVersion.ToString);
  VersionInfoResourceDetails.FileVersion := LVersion.AsULargeInteger;

  // also set the string version
  VersionInfoResourceDetails.SetKeyValue('FileVersion'   , LVersion.ToString);
end;

procedure TApp.SetProductVersion(VersionInfoResourceDetails: TVersionInfoResourceDetails);
var
  LVersion: TVersionNumber;
begin
  LVersion.FromULargeInteger(VersionInfoResourceDetails.ProductVersion);
  AppLog('Old product version : ' + LVersion.ToString);
  if Parameters.Build > 0 then
    LVersion.Build := Parameters.Build;
  if Parameters.VersionNumber.IsSet then
    LVersion := Parameters.VersionNumber;

  // set numeric value
  AppLog('New product version : ' + LVersion.ToString);
  VersionInfoResourceDetails.ProductVersion := LVersion.AsULargeInteger;

  // also set the string version
  VersionInfoResourceDetails.SetKeyValue('ProductVersion', LVersion.ToString );
end;

end.
