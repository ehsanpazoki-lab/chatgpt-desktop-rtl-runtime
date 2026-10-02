#define MyAppName "ChatGPT Desktop RTL Runtime"
#ifndef MyAppVersion
#define MyAppVersion "0.2.1-beta"
#endif
#define MyAppPublisher "Ehsan Pazoki (ehsanpazoki-lab)"
#define MyAppPublisherURL "https://github.com/ehsanpazoki-lab"
#define MyAppURL "https://github.com/ehsanpazoki-lab/chatgpt-desktop-rtl-runtime"
#define MyAppSupportURL "https://github.com/ehsanpazoki-lab/chatgpt-desktop-rtl-runtime/issues"
#define MyAppUpdatesURL "https://github.com/ehsanpazoki-lab/chatgpt-desktop-rtl-runtime/releases"
#define StartMenuFolder "{userprograms}\ChatGPT Desktop RTL Runtime"

[Setup]
AppId={{A85D133C-2C91-4C89-AD2E-FE0CE0310C51}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppPublisherURL}\nAppSupportURL={#MyAppSupportURL}\nAppUpdatesURL={#MyAppUpdatesURL}
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
SetupIconFile=..\assets\icons\ChatGPT-RTL.ico
UninstallDisplayIcon={app}\assets\icons\ChatGPT-RTL.ico
UninstallDisplayName={#MyAppName}
CloseApplications=no
SetupLogging=yes
VersionInfoCompany=Ehsan Pazoki / ehsanpazoki-lab
VersionInfoDescription={#MyAppName} - community RTL runtime
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "tray"; Description: "Show RTL controller in the system tray after installation"; GroupDescription: "System tray:"; Flags: checkedonce
Name: "tray\autostart"; Description: "Start RTL tray controller with Windows"; Flags: unchecked

[Files]
Source: "..\assets\icons\ChatGPT-RTL.ico"; DestDir: "{app}\assets\icons"; Flags: ignoreversion
Source: "..\assets\icons\ChatGPT-RTL-Inactive.ico"; DestDir: "{app}\assets\icons"; Flags: ignoreversion
Source: "..\assets\icons\ChatGPT-RTL.png"; DestDir: "{app}\assets\icons"; Flags: ignoreversion
Source: "..\assets\icons\ChatGPT-RTL-Inactive.png"; DestDir: "{app}\assets\icons"; Flags: ignoreversion
Source: "..\assets\icons\README.md"; DestDir: "{app}\assets\icons"; Flags: ignoreversion
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
Name: "{userdesktop}\ChatGPT RTL"; Filename: "{app}\ChatGPT-RTL-Run.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\ChatGPT-RTL.ico"; Tasks: desktopicon

Name: "{#StartMenuFolder}\ChatGPT RTL"; Filename: "{app}\ChatGPT-RTL-Run.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\ChatGPT-RTL.ico"
Name: "{#StartMenuFolder}\Disable ChatGPT RTL"; Filename: "{app}\Disable-ChatGPT-RTL.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\ChatGPT-RTL-Inactive.ico"
Name: "{#StartMenuFolder}\ChatGPT RTL Status"; Filename: "{app}\Status-ChatGPT-RTL.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\ChatGPT-RTL.ico"
Name: "{#StartMenuFolder}\RTL Tray Controller"; Filename: "{app}\ChatGPT-RTL-Tray.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\ChatGPT-RTL.ico"
Name: "{#StartMenuFolder}\Documentation (English)"; Filename: "{app}\README.md"
Name: "{#StartMenuFolder}\مستندات فارسی"; Filename: "{app}\README.fa.md"
Name: "{#StartMenuFolder}\Uninstall ChatGPT Desktop RTL Runtime"; Filename: "{uninstallexe}"

Name: "{userstartup}\ChatGPT RTL Tray Controller"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\ChatGPT-RTL-Tray.ps1"""; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\ChatGPT-RTL.ico"; Tasks: tray\autostart

[InstallDelete]
Type: files; Name: "{userstartup}\ChatGPT RTL Tray Controller.lnk"

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\ChatGPT-RTL-Tray.ps1"""; Description: "Start ChatGPT RTL tray controller"; Flags: postinstall nowait skipifsilent; Tasks: tray

[UninstallRun]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\Stop-ChatGPT-RTL-Tray.ps1"""; Flags: runhidden waituntilterminated
