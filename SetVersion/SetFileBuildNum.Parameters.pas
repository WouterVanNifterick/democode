unit SetFileBuildNum.Parameters;

interface

uses
  SetFileBuildNum.VersionNumber;

type
  TParameters = record
    InputFile:string;
    OutputFile:string;
    Build:Cardinal;
    VersionNumber:TVersionNumber;
    UpdateFileVersion,
    UpdateProductVersion: Boolean;
    DoSave:Boolean;
    Quiet:Boolean;
    class function Init:TParameters; static;
    procedure ShowUsage;
    procedure ParseFromCommandline;
    procedure Validate;
  end;

implementation

uses
  System.Character,
  System.SysUtils,
  System.StrUtils;

class function TParameters.Init:TParameters;
begin
  Result := default(TParameters);
  Result.DoSave := True;
  Result.Quiet  := False;
end;

procedure TParameters.ParseFromCommandline;
var i:integer;
  par:string;
  val:string;
  function MyStrToBool(const s:string):Boolean;
  begin
    Result := MatchText(s,[' ','','y','yes','t','true']);
  end;
begin
  init;
  if ParamCount < 1 then
  begin
    ShowUsage;
    Halt;
  end;

  for i := 1 to ParamCount do
  begin
    par := ParamStr(i);
    if Length(par) < 2 then  Continue;
    if par[1] <> '-' then Continue;

    val := par.Substring(2)
              .Trim
              .TrimLeft(['=','-',':']);

    case par[2].ToLower of
      'v': VersionNumber := TVersionNumber.CreateFromString(val);
      'b': Build := StrToInt(val);
      'i': InputFile := val;
      'o': OutputFile := val;
      's': DoSave               := MyStrToBool(val);
      'p': UpdateProductVersion := MyStrToBool(val);
      'f': UpdateFileVersion    := MyStrToBool(val);
      'q': Quiet                := MyStrToBool(val);
    end;
  end;

  if OutputFile = '' then
    OutputFile := InputFile;

  if (not UpdateFileVersion) and (not UpdateProductVersion) then
    UpdateFileVersion := True;

  Validate;
end;

procedure TParameters.ShowUsage;
begin
  Writeln('');
  Writeln('Usage: ', ExtractFileName(ParamStr(0)), ' <-i<filename>> [-vX.X.X.X] [-b<buildnum>] [-o<outputfile>]');
  Writeln('');
  Writeln('Example: ', ExtractFileName(ParamStr(0)), ' -ic:\dir\x.dll -b1234');
  Writeln('Example: ', ExtractFileName(ParamStr(0)), ' -ic:\dir\x.dll -v2.3.6.78');
  Writeln('Example: ', ExtractFileName(ParamStr(0)), ' -ic:\dir\x.dll -v2.3.6.78 -oc:\dir\o.dll' );
  Writeln('');
end;

procedure TParameters.Validate;
begin
  if InputFile='' then
    raise EFileNotFoundException.Create('Input file not specified (-i)');

  if not FileExists(InputFile) then
    raise EFileNotFoundException.CreateFmt('Input file "%s" not found.',[InputFile]);

  if not MatchText(ExtractFileExt(InputFile), ['.dll','.exe','.res']) then
    raise ENotSupportedException.CreateFmt('File for "%s" not supported.',[InputFile]);
end;


end.
