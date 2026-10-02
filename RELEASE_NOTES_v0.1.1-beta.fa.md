# v0.1.1-beta

Hotfix سازگاری با Windows PowerShell 5.1.

اصلاح‌ها:

- رفع خطای `System.Object[]` → `System.Uri` در `Status-ChatGPT-RTL.ps1`
- رفع همان خطا در `Disable-ChatGPT-RTL.ps1`
- Flatten صریح فهرست CDP targetها قبل از انتخاب renderer
- تبدیل امن `webSocketDebuggerUrl` به یک URI واحد پیش از اتصال

معماری runtime تغییر نکرده و همچنان هیچ تغییری در `app.asar` یا MSIX ایجاد نمی‌شود.

- فایل `Status-ChatGPT-RTL.cmd` اضافه شد تا محدودیت Execution Policy در اجرای مستقیم `.ps1` مزاحم کاربر نشود.
