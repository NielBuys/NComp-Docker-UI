unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Grids,
  StdCtrls, Buttons, DockerUnit, utilsunit;

type

  { TMainFrm }

  TMainFrm = class(TForm)
    StopContainerBtn: TBitBtn;
    StartContainerBtn: TBitBtn;
    RefreshContainersBtn: TBitBtn;
    MainFrmPageControl: TPageControl;
    ContainerListTabSheet: TTabSheet;
    DockerContainersStrGrid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure RefreshContainersBtnClick(Sender: TObject);
    procedure ShowDockerContainers;
    procedure StartContainerBtnClick(Sender: TObject);
    procedure StopContainerBtnClick(Sender: TObject);
  private

  public

  end;

var
  MainFrm: TMainFrm;

implementation

{ TMainFrm }

procedure TMainFrm.ShowDockerContainers;
var
  DockerData: TStringList;
  Row, Cols: TStringList;
  i, j: Integer;

begin
  if not IsRunningAsRoot then
  begin
    ShowMessage('This application must be run as root.');
    Exit;
  end;
  DockerData := GetDockerContainersAsTable;
  Cols := TStringList.Create;
  try
//    showmessage(InttoStr(DockerData.Count));
    DockerContainersStrGrid.RowCount := DockerData.Count;
    for i := 0 to DockerData.Count - 1 do
    begin
      Cols.CommaText := DockerData[i]; // Split row into columns
      DockerContainersStrGrid.ColCount := Cols.Count;
      for j := 0 to Cols.Count - 1 do
      begin
        DockerContainersStrGrid.Cells[j, i] := Cols[j];
      end;
    end;
    DockerContainersStrGrid.AutoSizeColumns;
    DockerContainersStrGrid.FixedRows := 1;
  finally
    DockerData.Free;
    Cols.Free;
  end;
end;

procedure TMainFrm.StartContainerBtnClick(Sender: TObject);
var
  SelectedRow: Integer;
  NameColumn: Integer;
  ContainerName: String;
begin
  if not IsRunningAsRoot then
  begin
    ShowMessage('This application must be run as root.');
    Exit;
  end;
  SelectedRow := DockerContainersStrGrid.Row;

  NameColumn := DockerContainersStrGrid.ColCount - 1;

  if SelectedRow > 0 then
  begin
    ContainerName := DockerContainersStrGrid.Cells[NameColumn, SelectedRow];
    StartDockerContainer(ContainerName);
    ShowDockerContainers;
  end
  else
    ShowMessage('Please select a container row.');
end;

procedure TMainFrm.StopContainerBtnClick(Sender: TObject);
var
  SelectedRow: Integer;
  NameColumn: Integer;
  ContainerName: String;
begin
  if not IsRunningAsRoot then
  begin
    ShowMessage('This application must be run as root.');
    Exit;
  end;
  SelectedRow := DockerContainersStrGrid.Row;

  NameColumn := DockerContainersStrGrid.ColCount - 1;

  if SelectedRow > 0 then
  begin
    ContainerName := DockerContainersStrGrid.Cells[NameColumn, SelectedRow];
    StopDockerContainer(ContainerName);
    ShowDockerContainers;
  end
  else
    ShowMessage('Please select a container row.');
end;


procedure TMainFrm.RefreshContainersBtnClick(Sender: TObject);
begin
  ShowDockerContainers;
end;

procedure TMainFrm.FormShow(Sender: TObject);
begin
     RefreshContainersBtn.Click;
end;

{$R *.lfm}

end.

