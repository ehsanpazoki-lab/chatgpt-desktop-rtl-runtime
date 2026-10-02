# نصب ChatGPT Desktop RTL Runtime

[بازگشت به README فارسی](README.fa.md)

## نصب با Setup.exe — روش پیشنهادی

فایل زیر را از بخش Releases دریافت کنید:

```text
ChatGPT-Desktop-RTL-Runtime-Setup-v0.1.1-beta.exe
```

Installer به‌صورت **per-user** نصب می‌شود و Administrator/UAC لازم ندارد. مسیر پیش‌فرض:

```text
%LOCALAPPDATA%\Programs\ChatGPT Desktop RTL Runtime
```

پس از نصب، در Start Menu این میانبرها ایجاد می‌شوند:

- **ChatGPT RTL** — اجرای ChatGPT با RTL و Vazirmatn
- **Disable ChatGPT RTL** — حذف RTL از Session فعلی
- **ChatGPT RTL Status** — نمایش وضعیت runtime
- Uninstall

Installer نسخه pinشده Vazirmatn را همراه خود دارد؛ بنابراین برای فونت به دانلود first-run نیاز ندارد.

## نصب Portable از ZIP

ZIP را در یک پوشه دلخواه Extract کنید؛ برای مثال:

```text
C:\Tools\chatgpt-desktop-rtl-runtime
```

سپس:

```text
ChatGPT-RTL-Run.cmd
```

در روش Portable، Vazirmatn در اولین اجرا دانلود و در `assets\Vazirmatn.woff2` ذخیره می‌شود.

## Uninstall

در نسخه Installer از **Settings → Apps → Installed apps** یا Shortcut مربوط به Uninstall استفاده کنید.

Uninstall فقط فایل‌های این ابزار را حذف می‌کند و خود ChatGPT Desktop را تغییر نمی‌دهد. اگر ChatGPT در همان لحظه با RTL باز است، با بستن کامل ChatGPT تغییرات runtime نیز از بین می‌روند.

## نکته امنیتی

این ابزار `app.asar`، MSIX، Certificate یا `WindowsApps` را تغییر نمی‌دهد. با این حال هنگام اجرای ChatGPT RTL، CDP روی `127.0.0.1:9230` فعال است. جزئیات در [SECURITY.fa.md](SECURITY.fa.md).


## Shortcut دسکتاپ

- در مرحله نصب می‌توانید با تیک گزینه **Create a desktop shortcut** یک Shortcut برای `ChatGPT RTL` روی Desktop ایجاد کنید؛ این گزینه پیش‌فرض خاموش است.

## Start Menu و System Tray در v0.2.0-beta

Installer یک فولدر مشخص در Start Menu ایجاد می‌کند و Run، Disable، Status،
Tray Controller، مستندات و Uninstall را داخل همان فولدر قرار می‌دهد.

در صفحه Additional Tasks دو گزینه اختیاری دارید:

```text
☐ Create a desktop shortcut
☐ Start RTL tray controller with Windows
```

هر دو پیش‌فرض خاموش هستند. در پایان Setup نیز می‌توانید Tray Controller را همان
لحظه اجرا کنید.

Tray Controller از منوی کنار ساعت امکان Enable/Disable/Status را می‌دهد و هنگام
Uninstall به‌صورت خودکار متوقف می‌شود.
