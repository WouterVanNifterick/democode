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
    EXITCODE_ERROR = 1;
    EXITCODE_OK = 0;
  var
    Parameters:TParameters;
    procedure UpdateVersionNumber;
    procedure Run;
  private
    procedure SetFileVersion(var VersionInfoResourceDetails: TVersionInfoResourceDetails);
    procedure SetProductVersion(VersionInfoResourceDetails: TVersionInfoResourceDetails);
  end;

implementation

uses System.SysUtils;

procedure TApp.UpdateVersionNumber;

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
      raise Exception.CreateFmt('No VersionInfo found in %s', [Parameters.InputFile])
    else
    begin
      if Parameters.VersionNumber.IsSet or (Parameters.Build > 0) then
      begin
        if Parameters.UpdateFileVersion then
          SetFileVersion(VersionInfoResourceDetails);

        if Parameters.UpdateProductVersion then
          SetProductVersion(VersionInfoResourceDetails);
      end;
      if Parameters.DoSave then
      begin
        if not Parameters.Quiet then
          Writeln(Format('Saving %s ...',[Parameters.OutputFile]));
        Module.SaveToFile(Parameters.OutputFile);
      end
      else
      begin
        LVersion.FromULargeInteger(VersionInfoResourceDetails.FileVersion);
        Writeln(LVersion.ToString);
        if not Parameters.Quiet then
          Writeln('Not saving');
      end;
    end;
  finally
    Module.Free;
  end;
end;

{ TApp }

procedure TApp.Run;
begin
  ExitCode := TApp.EXITCODE_ERROR;
  Parameters := TParameters.Init;
  Parameters.ParseFromCommandline;
  UpdateVersionNumber;
  if not Parameters.Quiet then
    Writeln('Done.');
  ExitCode := TApp.EXITCODE_OK;
end;

procedure TApp.SetFileVersion(var VersionInfoResourceDetails: TVersionInfoResourceDetails);
var
  LVersion: TVersionNumber;
begin
  LVersion.FromULargeInteger(VersionInfoResourceDetails.FileVersion);
  WriteLn('Old file version : ' + LVersion.ToString);
  if Parameters.Build > 0 then
    LVersion.Build := Parameters.Build;
  if Parameters.VersionNumber.IsSet then
    LVersion := Parameters.VersionNumber;

  // set numeric value
  WriteLn('New file version : ' + LVersion.ToString);
  VersionInfoResourceDetails.FileVersion := LVersion.AsULargeInteger;

  // also set the string version
  VersionInfoResourceDetails.SetKeyValue('FileVersion'   , LVersion.ToString);
end;

procedure TApp.SetProductVersion(VersionInfoResourceDetails: TVersionInfoResourceDetails);
var
  LVersion: TVersionNumber;
begin
  LVersion.FromULargeInteger(VersionInfoResourceDetails.ProductVersion);
  WriteLn('Old product version : ' + LVersion.ToString);
  if Parameters.Build > 0 then
    LVersion.Build := Parameters.Build;
  if Parameters.VersionNumber.IsSet then
    LVersion := Parameters.VersionNumber;

  // set numeric value
  WriteLn('New product version : ' + LVersion.ToString);
  VersionInfoResourceDetails.ProductVersion := LVersion.AsULargeInteger;

  // also set the string version
  VersionInfoResourceDetails.SetKeyValue('ProductVersion', LVersion.ToString );
end;

end.
