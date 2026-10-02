# امنیت — ChatGPT Desktop RTL Runtime

[English](SECURITY.md) | **فارسی**

این پروژه عمداً از Patch کردن فایل‌های نصب‌شده ChatGPT اجتناب می‌کند.

- `app.asar` تغییر نمی‌کند.
- مالکیت یا Permission پوشه `WindowsApps` تغییر نمی‌کند.
- Certificate نصب نمی‌شود.
- Administrator لازم نیست.
- ChatGPT با Windows packaged-app activation اجرا می‌شود تا package identity حفظ شود.
- Chromium DevTools Protocol فقط روی `127.0.0.1:9230` فعال می‌شود.

## ریسک CDP محلی

تا وقتی ChatGPT با CDP اجرا شده است، برنامه دیگری که با همان حساب کاربری ویندوز اجرا می‌شود ممکن است بتواند به DevTools endpoint محلی متصل شود. بنابراین:

- پورت `9230` را روی LAN یا Internet منتشر نکنید.
- Port forwarding برای آن نسازید.
- آن را از طریق Proxy/Tunnel در دسترس شبکه قرار ندهید.

با بستن کامل ChatGPT، listener و تزریق runtime از بین می‌روند.

## ارتباط شبکه

خود موتور RTL اطلاعات گفتگو را ارسال نمی‌کند. در نسخه Portable، helper ممکن است در اولین اجرا فایل Vazirmatn pinشده را از jsDelivr دریافت کند. Installer فایل فونت را از قبل داخل بسته دارد.

## گزارش آسیب‌پذیری

در Issue عمومی، Token، Credential، محتوای خصوصی گفتگو یا Screenshot دارای اطلاعات حساس قرار ندهید. در صورت فعال بودن GitHub Private Vulnerability Reporting از آن استفاده کنید.
