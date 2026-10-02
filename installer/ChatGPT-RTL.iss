#define MyAppName "ChatGPT Desktop RTL Runtime"
#ifndef MyAppVersion
#define MyAppVersion "0.2.0-beta"
#endif
#define MyAppPublisher "Community project"
#define MyAppURL "https://github.com/ehsanpazoki-lab/chatgpt-desktop-rtl-runtime"
#define StartMenuFolder "{userprograms}\ChatGPT Desktop RTL Runtime"

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
Name: "traystartup"; Description: "Start RTL tray controller with Windows"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\ChatGPT-RTL-Run.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\ChatGPT-RTL-Run.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Inject-ChatGPT-RTL.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Disable-ChatGPT-RTL.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Disable-ChatGPT-RTL.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Status-ChatGPT-RTL.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Status-ChatGPT-RTL.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\ChatGPT-RTL-Tray.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\ChatGPT-RTL-Tray.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Stop-ChatGPT-RTL-Tray.ps1"; DestDir: "{app}"; Flags: ignoreversion
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

Name: "{#StartMenuFolder}\ChatGPT RTL"; Filename: "{app}\ChatGPT-RTL-Run.cmd"; WorkingDir: "{app}"
Name: "{#StartMenuFolder}\Disable ChatGPT RTL"; Filename: "{app}\Disable-ChatGPT-RTL.cmd"; WorkingDir: "{app}"
Name: "{#StartMenuFolder}\ChatGPT RTL Status"; Filename: "{app}\Status-ChatGPT-RTL.cmd"; WorkingDir: "{app}"
Name: "{#StartMenuFolder}\RTL Tray Controller"; Filename: "{app}\ChatGPT-RTL-Tray.cmd"; WorkingDir: "{app}"
Name: "{#StartMenuFolder}\Documentation (English)"; Filename: "{app}\README.md"
Name: "{#StartMenuFolder}\مستندات فارسی"; Filename: "{app}\README.fa.md"
Name: "{#StartMenuFolder}\Uninstall ChatGPT Desktop RTL Runtime"; Filename: "{uninstallexe}"

Name: "{userstartup}\ChatGPT RTL Tray Controller"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\ChatGPT-RTL-Tray.ps1"""; WorkingDir: "{app}"; Tasks: traystartup

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\ChatGPT-RTL-Tray.ps1"""; Description: "Start ChatGPT RTL tray controller"; Flags: postinstall nowait skipifsilent

[UninstallRun]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\Stop-ChatGPT-RTL-Tray.ps1"""; Flags: runhidden waituntilterminated
