# v0.2.0-beta

Unified UX release for ChatGPT Desktop RTL Runtime.

Highlights:

- Adds a lightweight Windows system-tray controller.
- Tray menu provides **Enable RTL**, **Disable RTL**, **Status**, and **Exit Tray Controller**.
- Double-clicking the tray icon enables/opens ChatGPT RTL.
- Installer creates an explicit Start Menu folder containing:
  - ChatGPT RTL
  - Disable ChatGPT RTL
  - ChatGPT RTL Status
  - RTL Tray Controller
  - English/Persian documentation
  - Uninstall shortcut
- Optional Desktop shortcut remains unchecked by default.
- Adds an optional **Start RTL tray controller with Windows** task, unchecked by default.
- Installer offers to start the tray controller after installation.
- Uninstall stops the tray controller before files are removed.
- Retains the Windows PowerShell 5.1 CDP fixes from v0.1.1-beta.

The tray controller is user-mode only and does not require Administrator privileges.
No app.asar/MSIX patching is introduced.
