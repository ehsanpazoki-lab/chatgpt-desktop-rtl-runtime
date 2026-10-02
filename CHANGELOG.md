# Changelog

## 0.2.0-beta

- Add a lightweight Windows system-tray controller with Enable/Disable/Status.
- Create explicit Start Menu folder shortcuts for Run, Disable, Status, Tray, docs, and Uninstall.
- Add optional tray auto-start with Windows.
- Stop the tray controller automatically during uninstall.


## 0.1.1-beta

- Add an optional Desktop shortcut task to the Windows installer (unchecked by default).

- Fix Windows PowerShell 5.1 CDP target-array handling in Status and Disable.
- Normalize `webSocketDebuggerUrl` to one validated scalar URI before connecting.
- Apply the same compatibility fix to the runtime injector.
- Add `Status-ChatGPT-RTL.cmd` so status checks work under restrictive PowerShell execution policies.


## 0.1.0-beta

- First public beta.
- Runtime/CDP injection for the unified ChatGPT Desktop Windows app.
- Smart Persian/Arabic RTL and mixed-direction handling.
- Vazirmatn runtime font loading.
- Session disable/restore and status commands.
- No app.asar/MSIX patching.
