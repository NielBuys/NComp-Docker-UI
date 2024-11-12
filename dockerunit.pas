unit DockerUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Process, Dialogs, RegExpr;

function GetDockerContainersAsTable: TStringList;
function StartDockerContainer(const ContainerName: String): Boolean;
function StopDockerContainer(const ContainerName: String): Boolean;

implementation


function GetDockerContainersAsTable: TStringList;
var
  AProcess: TProcess;
  OutputLines, Row: TStringList;
  Regex: TRegExpr;
  i: Integer;
  Line: String;

begin
  OutputLines := TStringList.Create;
  Row := TStringList.Create;
  Result := TStringList.Create;

  try
    AProcess := TProcess.Create(nil);
    try
      AProcess.Executable := 'docker';
      AProcess.Parameters.Add('ps');
      AProcess.Parameters.Add('-a');
      AProcess.Options := AProcess.Options + [poUsePipes, poWaitOnExit];

      AProcess.Execute;
      if AProcess.ExitStatus <> 0 then
      begin
        OutputLines.LoadFromStream(AProcess.Stderr);
        ShowMessage('Error: ' + OutputLines.Text);
        Result.Add('Docker command failed: ' + OutputLines.Text);
        exit;
      end;
      OutputLines.LoadFromStream(AProcess.Output);
    finally
      AProcess.Free;
    end;

        // Add header line to Result
    Row.Clear;
    Row.Add('CONTAINER ID');
    Row.Add('IMAGE');
    Row.Add('COMMAND');
    Row.Add('CREATED');
    Row.Add('STATUS');
    Row.Add('PORTS');
    Row.Add('NAMES');
    Result.Add(Row.CommaText);

    // Regular expression to match columns dynamically, with NAMES capturing to end of line
    Regex := TRegExpr.Create;
    try
      Regex.Expression := '^(\S+)\s+(\S+)\s+(.+?)\s+(\d+.+?\s+ago)\s+(.+?)\s{2,}(.+?)\s{2,}(.+)$';
      // Regex pattern breakdown:
      // ^(\S+)          - Match first non-space (CONTAINER ID)
      // \s+(\S+)        - Match second non-space (IMAGE)
      // \s+(.+?)        - Match COMMAND (anything up to the next column)
      // \s+(\d+.+?\s+ago) - Match CREATED, ending with "ago"
      // \s+(.+?)\s{2,}  - Match STATUS up to double spaces before PORTS
      // (.+?)\s{2,}     - Match PORTS up to double spaces before NAMES
      // (.+)$           - Match NAMES to the end of the line

      // Process each line, skipping the first header line
      for i := 1 to OutputLines.Count - 1 do
      begin
        Line := OutputLines[i];
        if Regex.Exec(Line) then
        begin
          Row.Clear;
          Row.Add(Regex.Match[1]); // CONTAINER ID
          Row.Add(Regex.Match[2]); // IMAGE
          Row.Add(Regex.Match[3]); // COMMAND
          Row.Add(Regex.Match[4]); // CREATED
          Row.Add(Regex.Match[5]); // STATUS
          Row.Add(Regex.Match[6]); // PORTS (if present)
          Row.Add(Regex.Match[7]); // NAMES (up to end of line)

          Result.Add(Row.CommaText);  // Add as comma-separated row
        end;
      end;

    finally
      Regex.Free;
    end;

  finally
    OutputLines.Free;
    Row.Free;
  end;
end;

function StartDockerContainer(const ContainerName: String): Boolean;
var
  AProcess: TProcess;
begin
  Result := False; // Default to failure

  if ContainerName = '' then
  begin
    ShowMessage('No container name provided.');
    Exit;
  end;

  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := 'docker';
    AProcess.Parameters.Add('start');
    AProcess.Parameters.Add(ContainerName);
    AProcess.Options := [poWaitOnExit, poUsePipes];

    // Execute the process
    AProcess.Execute;

    // Check if the command succeeded
    Result := AProcess.ExitStatus = 0;
    if Result then
      ShowMessage('Container "' + ContainerName + '" started successfully.')
    else
      ShowMessage('Failed to start container "' + ContainerName + '".');

  finally
    AProcess.Free;
  end;
end;

function StopDockerContainer(const ContainerName: String): Boolean;
var
  AProcess: TProcess;
begin
  Result := False; // Default to failure

  if ContainerName = '' then
  begin
    ShowMessage('No container name provided.');
    Exit;
  end;

  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := 'docker';
    AProcess.Parameters.Add('stop');
    AProcess.Parameters.Add(ContainerName);
    AProcess.Options := [poWaitOnExit, poUsePipes];

    // Execute the process
    AProcess.Execute;

    // Check if the command succeeded
    Result := AProcess.ExitStatus = 0;
    if Result then
      ShowMessage('Container "' + ContainerName + '" stopped successfully.')
    else
      ShowMessage('Failed to stop container "' + ContainerName + '".');

  finally
    AProcess.Free;
  end;
end;

end.

