# v0.2.0-beta

نسخه یکپارچه UX برای ChatGPT Desktop RTL Runtime.

قابلیت‌های جدید:

- اضافه شدن System Tray Controller سبک برای ویندوز
- منوی Tray شامل `Enable RTL`، `Disable RTL`، `Status` و `Exit Tray Controller`
- دابل‌کلیک روی آیکن Tray برای فعال‌سازی/اجرای ChatGPT RTL
- ایجاد فولدر صریح در Start Menu شامل:
  - ChatGPT RTL
  - Disable ChatGPT RTL
  - ChatGPT RTL Status
  - RTL Tray Controller
  - مستندات فارسی/انگلیسی
  - Uninstall
- Desktop shortcut همچنان اختیاری و پیش‌فرض خاموش است.
- گزینه اختیاری `Start RTL tray controller with Windows` اضافه شده و پیش‌فرض خاموش است.
- در پایان نصب امکان اجرای Tray Controller وجود دارد.
- هنگام Uninstall، Tray Controller قبل از حذف فایل‌ها متوقف می‌شود.
- اصلاحات PowerShell 5.1 نسخه v0.1.1-beta حفظ شده‌اند.

Tray Controller در سطح User اجرا می‌شود و Administrator لازم ندارد.
هیچ تغییری در app.asar یا MSIX ایجاد نمی‌شود.
