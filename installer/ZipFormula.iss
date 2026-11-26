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
DefaultDirName={autopf}\Zip Formula SimHub Dashboard
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

[Registry]
Root: HKLM; Subkey: "Software\ZipFormula\SimHubDashboard"; ValueType: string; ValueName: "SimHubPath"; ValueData: "{code:GetSimHubPath}"; Flags: uninsdeletekey

[Files]
Source: "..\build\plugin\PostItNoteRacing.Plugin.dll"; DestDir: "{code:GetSimHubPath}"; Flags: ignoreversion
Source: "..\build\plugin\Post-It-Note-Racing_extensions.js"; DestDir: "{code:GetSimHubPath}\JavascriptExtensions"; Flags: ignoreversion
Source: "..\build\plugin\LICENSE-PostItNoteRacing.txt"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; DestName: "LICENSE-PostItNoteRacing.txt"; Flags: ignoreversion uninsneveruninstall
Source: "..\LICENSE"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; DestName: "LICENSE-ZipFormula.txt"; Flags: ignoreversion uninsneveruninstall
Source: "..\dashboard\*.simhubdash"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; Flags: ignoreversion uninsneveruninstall
Source: "..\dashboard\Preview.png"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; Flags: ignoreversion skipifsourcedoesntexist uninsneveruninstall
Source: "..\docs\README_JP.txt"; DestDir: "{userdocs}\Zip Formula\SimHub Dashboard"; Flags: ignoreversion uninsneveruninstall

[Icons]
Name: "{autoprograms}\Zip Formula Dashboard"; Filename: "{sys}\explorer.exe"; Parameters: """{userdocs}\Zip Formula\SimHub Dashboard"""

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


function TryFindSimHubInUninstallRegistry(const RootKey: Integer; const BaseKey: string): Boolean;
var
  Names: TArrayOfString;
  I: Integer;
  EntryKey, DisplayName, Candidate: string;
begin
  Result := False;
  if not RegGetSubkeyNames(RootKey, BaseKey, Names) then exit;

  for I := 0 to GetArrayLength(Names) - 1 do
  begin
    EntryKey := BaseKey + '\' + Names[I];
    if RegQueryStringValue(RootKey, EntryKey, 'DisplayName', DisplayName) and
       (Pos('SimHub', DisplayName) > 0) and
       RegQueryStringValue(RootKey, EntryKey, 'InstallLocation', Candidate) and
       IsValidSimHub(Candidate) then
    begin
      SimHubPath := RemoveBackslash(Candidate);
      Result := True;
      exit;
    end;
  end;
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
    TryFindSimHubInUninstallRegistry(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall');
  if SimHubPath = '' then
    TryFindSimHubInUninstallRegistry(HKLM, 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall');
  if SimHubPath = '' then
    TryFindSimHubInUninstallRegistry(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Uninstall');

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

function BackupFileIfNeeded(const OriginalPath, BackupPath: string): Boolean;
begin
  Result := True;
  if FileExists(OriginalPath) and (not FileExists(BackupPath)) then
  begin
    if not ForceDirectories(ExtractFileDir(BackupPath)) then
    begin
      Result := False;
      exit;
    end;
    Result := FileCopy(OriginalPath, BackupPath, False);
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  BackupRoot: string;
begin
  Result := '';
  BackupRoot := ExpandConstant('{commonappdata}\ZipFormula\PluginBackup');

  if not BackupFileIfNeeded(
    AddBackslash(SimHubPath) + 'PostItNoteRacing.Plugin.dll',
    AddBackslash(BackupRoot) + 'PostItNoteRacing.Plugin.dll'
  ) then
  begin
    Result := '既存のPostItNoteRacing.Plugin.dllをバックアップできませんでした。';
    exit;
  end;

  if not BackupFileIfNeeded(
    AddBackslash(SimHubPath) + 'JavascriptExtensions\Post-It-Note-Racing_extensions.js',
    AddBackslash(BackupRoot) + 'Post-It-Note-Racing_extensions.js'
  ) then
    Result := '既存のPost-It-Note-Racing_extensions.jsをバックアップできませんでした。';
end;

procedure RestoreBackup(const BackupName, Destination: string);
var
  BackupPath: string;
begin
  BackupPath := ExpandConstant('{commonappdata}\ZipFormula\PluginBackup\' + BackupName);
  if FileExists(BackupPath) then
  begin
    ForceDirectories(ExtractFileDir(Destination));
    FileCopy(BackupPath, Destination, False);
    DeleteFile(BackupPath);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  BackupRoot: string;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if IsValidSimHub(SimHubPath) then
    begin
      RestoreBackup(
        'PostItNoteRacing.Plugin.dll',
        AddBackslash(SimHubPath) + 'PostItNoteRacing.Plugin.dll'
      );
      RestoreBackup(
        'Post-It-Note-Racing_extensions.js',
        AddBackslash(SimHubPath) + 'JavascriptExtensions\Post-It-Note-Racing_extensions.js'
      );

      BackupRoot := ExpandConstant('{commonappdata}\ZipFormula\PluginBackup');
      RemoveDir(BackupRoot);
      RemoveDir(ExpandConstant('{commonappdata}\ZipFormula'));
    end
    else
      MsgBox(
        'SimHubの保存先を確認できないため、元のプラグインのバックアップを復元できませんでした。' +
        Chr(13) + Chr(10) + 'バックアップは C:\ProgramData\ZipFormula\PluginBackup に残しています.',
        mbError, MB_OK
      );
  end;
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

function InitializeUninstall(): Boolean;
begin
  if not RegQueryStringValue(
    HKLM, 'Software\ZipFormula\SimHubDashboard', 'SimHubPath', SimHubPath
  ) then
    FindSimHub();
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    MsgBox(
      'Zip Formulaのプラグインとファイルを配置しました。' + #13#10 + #13#10 +
      'SimHubを起動し、Dash StudioのImport Dashboardから、次のフォルダにある .simhubdash を登録してください。' + #13#10 +
      ExpandConstant('{userdocs}\Zip Formula\SimHub Dashboard'),
      mbInformation, MB_OK
    );
end;
