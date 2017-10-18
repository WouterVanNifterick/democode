unit SetFileBuildNum.VersionNumber;

interface

uses Winapi.Windows;

type
  TVersionNumber = record
    Major,
    Minor,
    Release,
    Build: integer;
    constructor CreateFromString(const s:string);
    procedure FromULargeInteger(aULargeInteger: TULargeInteger);
    function  AsULargeInteger: TULargeInteger;
    function IsSet:boolean;
    function ToString:string;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils;

function TVersionNumber.AsULargeInteger: TULargeInteger;
begin
   Result.HighPart := Major   shl 16 or Minor;
   Result.LowPart  := Release shl 16 or Build
end;

constructor TVersionNumber.CreateFromString(const s: string);
var v: TArray<string>;
begin
  v := s.ToLower.Replace('v','').Split(['.']);

  if not (
           (Length(v)=4               ) and
           (TryStrToInt(v[0], Major  )) and
           (TryStrToInt(v[1], Minor  )) and
           (TryStrToInt(v[2], Release)) and
           (TryStrToInt(v[3], Build  ))
         )
  then
    raise EParserError.Create(s + ' is not a valid version number' );
 end;

procedure TVersionNumber.FromULargeInteger(aULargeInteger: TULargeInteger);
begin
   Major   := aULargeInteger.HighPart shr 16;
   Minor   := aULargeInteger.HighPart and ((1 shl 16) - 1);
   Release := aULargeInteger.LowPart  shr 16;
   Build   := aULargeInteger.LowPart  and ((1 shl 16) - 1);
end;

function TVersionNumber.IsSet: boolean;
begin
  Result := Major + Minor + Release + Build <> 0
end;

function TVersionNumber.ToString: string;
begin
  Result := Format('%d.%d.%d.%d', [Major, Minor, Release, Build] )
end;


end.
