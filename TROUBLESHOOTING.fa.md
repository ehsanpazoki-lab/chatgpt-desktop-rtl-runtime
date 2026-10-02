# رفع اشکال ChatGPT RTL

## فونت دانلود نمی‌شود

ابتدا این تست را اجرا کنید:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Test-Vazirmatn-Download.ps1
```

در پایان باید `PASS` و مسیر `assets\Vazirmatn.woff2` نمایش داده شود.

## پورت 9230 اشغال است

بررسی کنید:

```powershell
Get-NetTCPConnection -LocalPort 9230 -ErrorAction SilentlyContinue
```

اگر برنامه دیگری از آن استفاده می‌کند، آن پردازش را ببندید یا Launcher را با یک Port دیگر اجرا کنید.

## ChatGPT باز می‌شود ولی RTL اعمال نمی‌شود

ابتدا Status را بگیرید:

```powershell
Status-ChatGPT-RTL.cmd
```

موارد مهم:

```text
CDP active      : True
RTL active      : True
Vazirmatn loaded: True
Root found      : True
```

## بعد از Update برنامه RTL خراب شد

DOM داخلی ChatGPT API عمومی نیست. شماره نسخه Package را همراه با خروجی Status و Screenshot بدون اطلاعات خصوصی در Issue ثبت کنید.

## بازگشت کامل به حالت عادی

```text
Disable-ChatGPT-RTL.cmd
```

یا ChatGPT را کامل Quit کنید و سپس به روش معمولی باز کنید.
