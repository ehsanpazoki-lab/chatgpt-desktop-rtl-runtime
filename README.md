# ChatGPT Desktop RTL Runtime

**English** | [فارسی](README.fa.md)

> **Unofficial community project. Not affiliated with or endorsed by OpenAI.**

Runtime RTL support for the **new unified ChatGPT Desktop app on Windows**
(the package currently exposed as `OpenAI.Codex`) without modifying
`app.asar`, breaking MSIX signatures, or installing certificates.

Tested initially on Windows 11 with `OpenAI.Codex 26.924.6891.0`.

## What it does

- Smart RTL for Persian/Arabic paragraphs
- Natural mixed Persian/English bidi flow
- RTL list numbering and bullets
- LTR code blocks and inline code
- Composer direction switching
- Vazirmatn for Persian/Arabic glyphs while preserving ChatGPT's Latin fallback
- Runtime-only changes: fully closing ChatGPT removes them

## Windows installer

For most users, the recommended distribution is the per-user Windows installer:

```text
ChatGPT-Desktop-RTL-Runtime-Setup-v0.1.1-beta.exe
```

It requires no Administrator privileges and bundles the pinned Vazirmatn font.
Installer source and GitHub Actions build automation live under `installer/`.

## Install

Download the release ZIP and extract it anywhere, for example:

```text
C:\Tools\chatgpt-desktop-rtl-runtime
```

Optional preflight test for the first-run font download:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Test-Vazirmatn-Download.ps1
```

Then double-click:

```text
ChatGPT-RTL-Run.cmd
```

If ChatGPT is already running normally, the launcher asks before restarting it.

On first run, the helper downloads Vazirmatn 33.0.3 from the official
project through jsDelivr and stores it under `assets/`.

## Disable in the current session

Run:

```text
Disable-ChatGPT-RTL.cmd
```

Or simply close ChatGPT completely.

## Status

```powershell
Status-ChatGPT-RTL.cmd
```

## How it works

The launcher starts the packaged ChatGPT app through Windows
`IApplicationActivationManager` while passing a loopback-only Chromium
remote-debugging port. The injector connects to the main `app://-/index.html`
renderer through CDP and applies direction/font rules in memory.

## Security

Read [SECURITY.md](SECURITY.md). In particular, CDP is available on
`127.0.0.1:9230` while the patched session is running, so do not expose that
port to a network.

## Known limitations

- The ChatGPT Desktop internal DOM is not a public API and may change after app updates.
- Currently targets the new unified Windows app (`OpenAI.Codex` package).
- The first public release is beta-quality and has been tested on a limited number of machines.

## Persian / فارسی

این ابزار بدون دستکاری `app.asar` و بدون نیاز به Administrator، پشتیبانی
RTL و فونت Vazirmatn را به‌صورت موقت در همان Session به ChatGPT Desktop
ویندوز اضافه می‌کند. با بستن کامل ChatGPT همه تغییرات runtime از بین می‌روند.

## License

MIT. See [LICENSE](LICENSE).

Vazirmatn is licensed separately under OFL-1.1. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).


## Desktop shortcut

- The installer offers an optional **Create a desktop shortcut** task for `ChatGPT RTL`; it is unchecked by default.
