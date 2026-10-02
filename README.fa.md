# ChatGPT Desktop RTL Runtime

[English](README.md) | **فارسی**

> **پروژه غیررسمی جامعه کاربری؛ وابسته به OpenAI نیست و توسط OpenAI تأیید نشده است.**

این پروژه برای نسخه جدید **ChatGPT Desktop در ویندوز** پشتیبانی RTL فارسی/عربی و فونت Vazirmatn را به‌صورت runtime اضافه می‌کند؛ بدون دستکاری `app.asar`، بدون تغییر فایل‌های `WindowsApps`، بدون نصب Certificate و بدون نیاز به Administrator.

نسخه اولیه روی Windows 11 و بسته `OpenAI.Codex 26.924.6891.0` آزمایش شده است.

## قابلیت‌ها

- راست‌به‌چپ کردن هوشمند پاراگراف‌های فارسی و عربی
- نمایش طبیعی متن‌های ترکیبی فارسی/English
- راست‌چین شدن شماره‌ها و bulletهای لیست‌های فارسی
- حفظ جهت LTR برای `code` و `pre`
- تغییر خودکار جهت Composer بر اساس متن فارسی یا انگلیسی
- استفاده از Vazirmatn فقط برای glyphهای فارسی/عربی و حفظ فونت اصلی ChatGPT برای Latin
- تغییرات کاملاً runtime؛ با بستن کامل ChatGPT همه تغییرات از بین می‌روند

## روش پیشنهادی: Installer

برای کاربران عادی، فایل Setup ویندوز روش پیشنهادی است:

```text
ChatGPT-Desktop-RTL-Runtime-Setup-v0.1.1-beta.exe
```

Installer در سطح کاربر نصب می‌شود، UAC لازم ندارد و Shortcutهای لازم را در Start Menu ایجاد می‌کند.

جزئیات: [INSTALL.fa.md](INSTALL.fa.md)

## روش Portable

Release ZIP را Extract کنید و سپس اجرا کنید:

```text
ChatGPT-RTL-Run.cmd
```

در اولین اجرا Vazirmatn نسخه pinشده دانلود می‌شود.

برای تست مستقل دانلود فونت:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Test-Vazirmatn-Download.ps1
```

## غیرفعال‌سازی در همان Session

```text
Disable-ChatGPT-RTL.cmd
```

یا ChatGPT را کامل ببندید.

## بررسی وضعیت

```powershell
Status-ChatGPT-RTL.cmd
```

خروجی وضعیت CDP، نسخه RTL، تعداد عناصر تغییرکرده، وضعیت Vazirmatn و پیدا شدن conversation root را نشان می‌دهد.

## روش کار

Launcher برنامه بسته‌بندی‌شده ChatGPT را با `IApplicationActivationManager` ویندوز اجرا می‌کند و یک Chromium DevTools Protocol محلی روی `127.0.0.1:9230` فعال می‌کند. سپس Injector به renderer اصلی `app://-/index.html` متصل می‌شود و قوانین جهت و فونت را فقط در حافظه اعمال می‌کند.

## امنیت

حتماً [SECURITY.fa.md](SECURITY.fa.md) را بخوانید. نکته اصلی این است که تا وقتی ChatGPT با CDP باز است، پردازش دیگری با دسترسی همان کاربر ویندوز ممکن است بتواند به endpoint محلی DevTools متصل شود. پورت `9230` را روی شبکه، Firewall forwarding یا Proxy منتشر نکنید.

## محدودیت‌های شناخته‌شده

- DOM داخلی ChatGPT API عمومی نیست و ممکن است پس از Update تغییر کند.
- نسخه فعلی برای برنامه unified ویندوز با package `OpenAI.Codex` طراحی شده است.
- این نسخه Beta است و هنوز روی تعداد محدودی سیستم آزمایش شده است.

## رفع اشکال

[TROUBLESHOOTING.fa.md](TROUBLESHOOTING.fa.md)

## مجوز

کد پروژه: MIT — [LICENSE](LICENSE)

Vazirmatn: OFL-1.1 — [THIRD_PARTY_NOTICES.fa.md](THIRD_PARTY_NOTICES.fa.md)


## Shortcut دسکتاپ

- در مرحله نصب می‌توانید با تیک گزینه **Create a desktop shortcut** یک Shortcut برای `ChatGPT RTL` روی Desktop ایجاد کنید؛ این گزینه پیش‌فرض خاموش است.
