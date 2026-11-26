#ifndef AppVersion
  #define AppVersion "0.1.0-dev"
#endif

#define AppName "Zip Formula SimHub Dashboard"
#define AppPublisher "Zip Formula"
#define AppId "{{9F6F7A80-82C1-4C8B-9F30-4C4F6C9A2026}"

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={code:GetSimHubPath}
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
OutputDir=..\build\output
OutputBaseFilename=ZipFormula-SimHub-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
Uninstallable=yes
CloseApplications=yes
RestartApplications=no
SetupLogging=yes

[Dirs]
Name: "{code:GetSimHubPath}\JavascriptExtensions"
Name: "{userdocs}\Zip Formula\SimHub Dashboard"

[Files]
Source: "..\build\plugin\PostItNoteRacing.Plugin.dll"; DestDir: "{code:GetSimHubPath}"; Flags: ignoreversion
Source: "..\build\plugin\Post-It-Note-Racing_extensions.js"; DestDir: "{code:GetSimHubPath}\JavascriptExtensions"; Flags: ignoreversion
Source: "..\dashboard\*.simhubdash"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; Flags: ignoreversion
Source: "..\dashboard\*"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; Excludes: "*.simhubdash"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "..\LICENSE"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\Zip Formula Dashboard"; Filename: "{userdocs}\Zip Formula\SimHub Dashboard"

[Code]
var
  SimHubPath: string;

function IsValidSimHub(const Candidate: string): Boolean;
begin
  Result := (Candidate <> '') and FileExists(AddBackslash(Candidate) + 'SimHubWPF.exe');
end;

procedure TryRegistryPath(const RootKey: Integer; const SubKey: string; const ValueName: string);
var
  Candidate: string;
begin
  if (SimHubPath = '') and RegQueryStringValue(RootKey, SubKey, ValueName, Candidate) then
    if IsValidSimHub(Candidate) then
      SimHubPath := RemoveBackslash(Candidate);
end;

function FindSimHub(): string;
var
  Candidate: string;
begin
  SimHubPath := '';
  TryRegistryPath(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SimHub_is1', 'InstallLocation');
  TryRegistryPath(HKLM, 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SimHub_is1', 'InstallLocation');
  TryRegistryPath(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SimHub_is1', 'InstallLocation');
  TryRegistryPath(HKCU, 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SimHub_is1', 'InstallLocation');

  if SimHubPath = '' then
  begin
    Candidate := ExpandConstant('{autopf32}\SimHub');
    if IsValidSimHub(Candidate) then SimHubPath := Candidate;
  end;

  if SimHubPath = '' then
  begin
    Candidate := ExpandConstant('{autopf}\SimHub');
    if IsValidSimHub(Candidate) then SimHubPath := Candidate;
  end;
  Result := SimHubPath;
end;

function GetSimHubPath(Param: string): string;
begin
  Result := SimHubPath;
end;

function InitializeSetup(): Boolean;
begin
  FindSimHub();
  if SimHubPath = '' then
  begin
    MsgBox('SimHubを検出できませんでした。先にSimHubをインストールしてください。', mbError, MB_OK);
    Result := False;
    exit;
  end;
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    MsgBox('Zip Formulaのファイルを配置しました。SimHubを起動し、Dash StudioのImport Dashboardからダッシュボードを登録してください。', mbInformation, MB_OK);
end;
