# ساخت Windows Installer

Installer با **Inno Setup 6** ساخته می‌شود و برای کاربران نهایی به Administrator نیاز ندارد.

## Build محلی

1. Inno Setup 6 را نصب کنید.
2. در پوشه `installer` اجرا کنید:

```text
Build-Installer.cmd
```

خروجی در:

```text
installer\output
```

قرار می‌گیرد.

## GitHub Actions

Workflow `build-installer.yml` روی Windows runner فایل Setup.exe را می‌سازد، SHA-256 تولید می‌کند و Artifact را ذخیره می‌کند. هنگام push کردن Tag مثل `v0.1.0-beta` همان فایل‌ها می‌توانند به GitHub Release متصل شوند.

**نکته:** Setup.exe فعلاً Code Signing تجاری ندارد؛ بنابراین Windows SmartScreen ممکن است برای یک Publisher جدید هشدار reputation نشان دهد. این موضوع با UAC/Admin متفاوت است.
