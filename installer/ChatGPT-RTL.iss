#define MyAppName "ChatGPT Desktop RTL Runtime"
#ifndef MyAppVersion
#define MyAppVersion "0.1.1-beta"
#endif
#define MyAppPublisher "Community project"
#define MyAppURL "https://github.com/"

[Setup]
AppId={{A85D133C-2C91-4C89-AD2E-FE0CE0310C51}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\ChatGPT Desktop RTL Runtime
DefaultGroupName=ChatGPT Desktop RTL Runtime
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=output
OutputBaseFilename=ChatGPT-Desktop-RTL-Runtime-Setup-v{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
LicenseFile=..\LICENSE
UninstallDisplayName={#MyAppName}
CloseApplications=no
SetupLogging=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\ChatGPT-RTL-Run.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\ChatGPT-RTL-Run.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Inject-ChatGPT-RTL.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Disable-ChatGPT-RTL.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Disable-ChatGPT-RTL.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Status-ChatGPT-RTL.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Status-ChatGPT-RTL.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Test-Vazirmatn-Download.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\Ensure-Vazirmatn.ps1"; DestDir: "{app}\scripts"; Flags: ignoreversion
Source: "staging\assets\Vazirmatn.woff2"; DestDir: "{app}\assets"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.fa.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\INSTALL.fa.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\SECURITY.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\SECURITY.fa.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\TROUBLESHOOTING.fa.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\THIRD_PARTY_NOTICES.fa.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{userdesktop}\ChatGPT RTL"; Filename: "{app}\ChatGPT-RTL-Run.cmd"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{group}\ChatGPT RTL"; Filename: "{app}\ChatGPT-RTL-Run.cmd"; WorkingDir: "{app}"
Name: "{group}\Disable ChatGPT RTL"; Filename: "{app}\Disable-ChatGPT-RTL.cmd"; WorkingDir: "{app}"
Name: "{group}\ChatGPT RTL Status"; Filename: "{app}\Status-ChatGPT-RTL.cmd"; WorkingDir: "{app}"
Name: "{group}\Documentation (English)"; Filename: "{app}\README.md"
Name: "{group}\مستندات فارسی"; Filename: "{app}\README.fa.md"

[Run]
Filename: "{app}\ChatGPT-RTL-Run.cmd"; Description: "Launch ChatGPT with RTL + Vazirmatn"; Flags: postinstall skipifsilent nowait
