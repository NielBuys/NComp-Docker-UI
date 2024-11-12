unit utilsunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, BaseUnix;

function IsRunningAsRoot: Boolean;

implementation

function IsRunningAsRoot: Boolean;
begin
  {$IFDEF UNIX}
  Result := (FpGetEUid = 0); // 0 for root
  {$ELSE}
  Result := True; // Windows does not have this concept in the same way
  {$ENDIF}
end;


end.

