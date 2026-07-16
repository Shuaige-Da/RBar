#ifndef AppVersion
#define AppVersion "1.0.0"
#endif

#ifndef SourceDir
#define SourceDir "..\..\artifacts\release\RBar-v1.0.0-win-x64-framework-dependent\publish"
#endif

#ifndef OutputDir
#define OutputDir "..\..\artifacts\release\RBar-v1.0.0-win-x64-framework-dependent\installer"
#endif

#ifndef DependencyLabel
#define DependencyLabel "framework-dependent"
#endif

[Setup]
AppId={{7E60BB32-46B6-46D2-84E5-6C8D0E8F1E40}
AppName=RBar
AppVersion={#AppVersion}
AppPublisher=rainwave
AppPublisherURL=https://github.com/Shuaige-Da/RBar
AppSupportURL=https://github.com/Shuaige-Da/RBar/issues
AppUpdatesURL=https://github.com/Shuaige-Da/RBar/releases
LicenseFile={#SourceDir}\LICENSE
DefaultDirName={localappdata}\Programs\RBar
DefaultGroupName=RBar
DisableProgramGroupPage=yes
OutputDir={#OutputDir}
OutputBaseFilename=RBar-Setup-v{#AppVersion}-win-x64-{#DependencyLabel}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\RBar.exe
SetupLogging=yes
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "chinesesimp"; MessagesFile: "Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "startup"; Description: "开机自动启动 RBar"; GroupDescription: "启动选项"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\RBar"; Filename: "{app}\RBar.exe"
Name: "{group}\卸载 RBar"; Filename: "{uninstallexe}"
Name: "{autodesktop}\RBar"; Filename: "{app}\RBar.exe"; Tasks: desktopicon

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: none; ValueName: "DynamicIslandBar"; Flags: deletevalue
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "RBar"; ValueData: """{app}\RBar.exe"""; Flags: uninsdeletevalue; Tasks: startup

[Run]
Filename: "{app}\RBar.exe"; Description: "启动 RBar"; Flags: nowait postinstall skipifsilent

[InstallDelete]
Type: files; Name: "{app}\DynamicIslandBar.exe"
Type: files; Name: "{autodesktop}\DynamicIslandBar.lnk"
Type: filesandordirs; Name: "{userprograms}\DynamicIslandBar"

[UninstallRun]
Filename: "{cmd}"; Parameters: "/C taskkill /IM RBar.exe /F 2>NUL & taskkill /IM DynamicIslandBar.exe /F 2>NUL & exit /B 0"; Flags: runhidden; RunOnceId: "StopRBar"
Filename: "{app}\RBar.exe"; Parameters: "--restore-taskbar"; Flags: runhidden waituntilterminated; RunOnceId: "RestoreTaskbar"

[UninstallDelete]
; Preserve capsule-config.json and its backup so reinstalling keeps personalization.
Type: files; Name: "{localappdata}\RBar\permissions.json"
Type: filesandordirs; Name: "{localappdata}\RBar\Logs"
Type: dirifempty; Name: "{localappdata}\RBar"
; Clean transient legacy data as well, but keep legacy capsule-config files.
Type: files; Name: "{localappdata}\DynamicIslandBar\permissions.json"
Type: filesandordirs; Name: "{localappdata}\DynamicIslandBar\Logs"
Type: dirifempty; Name: "{localappdata}\DynamicIslandBar"
