# v0.1.1-beta

Hotfix beta for Windows PowerShell 5.1 compatibility.

Fixes:

- `Status-ChatGPT-RTL.ps1` could fail with `System.Object[]` → `System.Uri`.
- `Disable-ChatGPT-RTL.ps1` could fail with the same conversion error.
- CDP target discovery is now explicitly flattened before renderer selection.
- WebSocket debugger URLs are normalized to a single scalar URI before connection.

No app.asar/MSIX patching is introduced. The runtime architecture remains unchanged.

- Added `Status-ChatGPT-RTL.cmd` to avoid direct-script ExecutionPolicy friction.
