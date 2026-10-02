# Security

**English** | [فارسی](SECURITY.fa.md)

This project intentionally avoids binary patching.

- It does **not** modify `app.asar`.
- It does **not** take ownership of `WindowsApps`.
- It does **not** install certificates.
- It does **not** require Administrator rights.
- It starts ChatGPT using Windows packaged-app activation so MSIX package identity is retained.
- It enables Chromium DevTools Protocol only on `127.0.0.1:9230` for that ChatGPT session.

## Local CDP risk

While ChatGPT is running with CDP enabled, another process running as the same
Windows user may be able to connect to the local DevTools endpoint. Do not
expose port 9230 through a firewall rule, proxy, port-forward, or LAN binding.
Closing ChatGPT removes the runtime injection and the CDP listener.

## Network activity

The RTL engine itself does not make network requests. On first use, the
Vazirmatn helper may download the pinned v33.003 WOFF2 file from jsDelivr,
which mirrors the official GitHub repository.

## Reporting

Do not paste credentials, tokens, or private conversation content into a
public issue. Use GitHub private vulnerability reporting if it is enabled.
