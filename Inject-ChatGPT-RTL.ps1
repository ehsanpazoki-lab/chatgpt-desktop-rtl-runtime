param(
    [int]$Port = 9230,
    [int]$TargetWaitSeconds = 60
)

$ErrorActionPreference = 'Stop'
$FontHelper = Join-Path $PSScriptRoot 'scripts\Ensure-Vazirmatn.ps1'
if (-not (Test-Path -LiteralPath $FontHelper)) {
    throw "Font helper not found: $FontHelper"
}
$FontPath = (& $FontHelper | Select-Object -Last 1)
if (-not $FontPath -or -not (Test-Path -LiteralPath $FontPath)) {
    throw "Could not resolve Vazirmatn font path."
}

function Info($m) { Write-Host "[chatgpt-rtl] $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[chatgpt-rtl] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[chatgpt-rtl] $m" -ForegroundColor Yellow }

if (-not (Test-Path -LiteralPath $FontPath)) {
    throw "Vazirmatn font not found: $FontPath"
}

$fontBase64 = [Convert]::ToBase64String(
    [System.IO.File]::ReadAllBytes($FontPath)
)

function Get-Targets {
    try {
        @(Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json/list" -TimeoutSec 3)
    } catch {
        @()
    }
}

function Invoke-TargetExpression {
    param(
        [Parameter(Mandatory=$true)]$Target,
        [Parameter(Mandatory=$true)][string]$Expression,
        [switch]$AwaitPromise
    )

    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $cts = New-Object System.Threading.CancellationTokenSource

    try {
        $null = $ws.ConnectAsync(
            [Uri]$Target.webSocketDebuggerUrl,
            $cts.Token
        ).GetAwaiter().GetResult()

        $params = @{
            expression = $Expression
            returnByValue = $true
            allowUnsafeEvalBlockedByCSP = $true
        }
        if ($AwaitPromise) { $params.awaitPromise = $true }

        $msg = @{
            id = 1
            method = 'Runtime.evaluate'
            params = $params
        } | ConvertTo-Json -Depth 20 -Compress

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($msg)
        $seg = New-Object System.ArraySegment[byte] -ArgumentList @(,$bytes)

        $null = $ws.SendAsync(
            $seg,
            [System.Net.WebSockets.WebSocketMessageType]::Text,
            $true,
            $cts.Token
        ).GetAwaiter().GetResult()

        while ($true) {
            $sb = New-Object System.Text.StringBuilder
            do {
                $buf = New-Object byte[] 65536
                $rseg = New-Object System.ArraySegment[byte] -ArgumentList @(,$buf)
                $res = $ws.ReceiveAsync($rseg, $cts.Token).GetAwaiter().GetResult()

                if ($res.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
                    throw "CDP WebSocket closed unexpectedly."
                }

                [void]$sb.Append(
                    [System.Text.Encoding]::UTF8.GetString($buf, 0, $res.Count)
                )
            } while (-not $res.EndOfMessage)

            $obj = $sb.ToString() | ConvertFrom-Json
            if ($obj.id -eq 1) {
                if ($obj.error) {
                    throw "CDP error: $($obj.error.message)"
                }
                if ($obj.result.exceptionDetails) {
                    $d = $obj.result.exceptionDetails.exception.description
                    if (-not $d) { $d = $obj.result.exceptionDetails.text }
                    throw "JavaScript exception: $d"
                }
                return $obj.result.result.value
            }
        }
    }
    finally {
        try {
            if ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
                $null = $ws.CloseAsync(
                    [System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure,
                    'done',
                    $cts.Token
                ).GetAwaiter().GetResult()
            }
        } catch {}
        $ws.Dispose()
        $cts.Dispose()
    }
}

Info "Waiting for main ChatGPT renderer..."
$deadline = (Get-Date).AddSeconds($TargetWaitSeconds)
$target = $null

while ((Get-Date) -lt $deadline) {
    $target = Get-Targets | Where-Object {
        $_.type -eq 'page' -and $_.url -eq 'app://-/index.html'
    } | Select-Object -First 1

    if ($target) {
        try {
            $ready = Invoke-TargetExpression -Target $target -Expression `
                "document.readyState + '|' + !!document.body"
            if ($ready -match '\|True$') { break }
        } catch {
            $target = $null
        }
    }

    Start-Sleep -Milliseconds 500
}

if (-not $target) {
    throw "Main ChatGPT renderer did not become ready."
}

Ok "Main ChatGPT renderer is ready."

$jsTemplate = @'
(async () => {
  'use strict';

  const VERSION = 'chatgpt-rtl-final-v3.1';
  const FAMILY = 'ChatGPT Vazirmatn';
  const MARK = 'data-chatgpt-rtl-final';
  const FONT_KEY = '__chatgptVazirmatnFinal';
  const STATE_KEY = '__chatgptRtlFinal';

  const RTL_RE = /[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]/;
  const LATIN_RE = /[A-Za-z]/;

  function detectDir(text) {
    const t = (text || '').trim();
    if (!t) return null;
    if (RTL_RE.test(t)) return 'rtl';
    if (LATIN_RE.test(t)) return 'ltr';
    return null;
  }

  // Precise snapshot of only the inline properties/attribute we modify.
  const snapshots = new Map();

  function remember(el) {
    if (!el || snapshots.has(el)) return;
    const props = {};
    for (const p of ['direction', 'text-align', 'unicode-bidi', 'font-family']) {
      props[p] = {
        value: el.style.getPropertyValue(p),
        priority: el.style.getPropertyPriority(p)
      };
    }
    snapshots.set(el, {
      hadDir: el.hasAttribute('dir'),
      dir: el.getAttribute('dir'),
      props
    });
  }

  function restoreSnapshots() {
    for (const [el, snap] of snapshots.entries()) {
      try {
        if (snap.hadDir) el.setAttribute('dir', snap.dir ?? '');
        else el.removeAttribute('dir');

        for (const [p, v] of Object.entries(snap.props)) {
          if (v.value) el.style.setProperty(p, v.value, v.priority || '');
          else el.style.removeProperty(p);
        }

        el.removeAttribute(MARK);
      } catch (_) {}
    }
    snapshots.clear();
  }

  function cleanupOlderEngines() {
    for (const key of ['__chatgptRtlCustom','__chatgptRtlCustomV3','__chatgptRtlFinal']) {
      const old = window[key];
      if (!old) continue;
      try {
        if (typeof old.remove === 'function') old.remove();
        else {
          old.observer?.disconnect?.();
          if (old.inputHandler) {
            document.removeEventListener('input', old.inputHandler, true);
          }
        }
      } catch (_) {}
      try { delete window[key]; } catch (_) {}
    }

    // Disable/remove remnants from the older third-party payload.
    try {
      const label = document.getElementById('rtl-toggle-label');
      const btn = document.getElementById('rtl-toggle-btn');
      if (btn && label && /enabled/i.test(label.textContent || '')) btn.click();
    } catch (_) {}

    ['codex-rtl-baseline','codex-rtl-style','rtl-widget-style'].forEach((id) => {
      document.getElementById(id)?.remove();
    });
    document.querySelectorAll('.rtl-widget-container').forEach((el) => el.remove());
  }

  cleanupOlderEngines();

  // Load Vazirmatn directly from the user's local WOFF2 bytes.
  const b64 = '__FONT_BASE64__';
  const raw = atob(b64);
  const bytes = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);

  const face = new FontFace(FAMILY, bytes.buffer, {
    style: 'normal',
    weight: '100 900',
    unicodeRange:
      'U+0600-06FF,U+0750-077F,U+0870-089F,U+08A0-08FF,U+FB50-FDFF,U+FE70-FEFF'
  });

  document.fonts.add(face);
  await face.load();
  window[FONT_KEY] = face;

  function findConversationRoot() {
    const known = document.querySelector('.thread-scroll-container');
    if (known) return known;

    const els = Array.from(document.querySelectorAll('main,section,div'));
    let best = null;
    let bestScore = -1;

    for (const el of els) {
      if (el.closest('aside,nav,header,[role="navigation"],[role="menubar"],[role="toolbar"]')) {
        continue;
      }

      const r = el.getBoundingClientRect();
      if (r.width < 420 || r.height < 220) continue;

      const style = getComputedStyle(el);
      const textLen = (el.innerText || '').length;
      if (textLen < 150) continue;

      const scrollable =
        /auto|scroll/.test(style.overflowY) &&
        el.scrollHeight > el.clientHeight + 40;

      const mainBonus = el.tagName === 'MAIN' ? 500000 : 0;
      const scrollBonus = scrollable ? 1000000 : 0;
      const score =
        scrollBonus +
        mainBonus +
        (textLen * 30) +
        Math.min(el.scrollHeight, 20000) +
        Math.round(r.width * r.height / 20);

      if (score > bestScore) {
        bestScore = score;
        best = el;
      }
    }

    return best;
  }

  function isInChrome(el) {
    return !!el.closest(
      'aside,nav,header,[role="navigation"],[role="menubar"],[role="toolbar"]'
    );
  }

  function setFont(el, fontStack) {
    if (!el || el.closest?.('pre,code,.code-block__code,.xterm')) return;
    remember(el);
    el.style.setProperty('font-family', fontStack, 'important');
  }

  function setBlockDir(el, dir, kind, fontStack) {
    if (!el || !dir) return;
    if (el.closest?.('pre,code,.code-block__code,.xterm')) return;

    remember(el);
    el.setAttribute('dir', dir);
    el.style.setProperty('direction', dir, 'important');
    el.style.setProperty(
      'text-align',
      dir === 'rtl' ? 'right' : 'left',
      'important'
    );

    // Fixed base direction for mixed Persian/English paragraphs.
    el.style.setProperty('unicode-bidi', 'isolate', 'important');

    setFont(el, fontStack);
    el.setAttribute(MARK, kind || dir);
  }

  function forceCodeLTR(root) {
    if (!root?.querySelectorAll) return;

    const nodes = [];
    if (root.matches?.('pre,code,.code-block__code')) nodes.push(root);
    root.querySelectorAll('pre,code,.code-block__code').forEach((el) => nodes.push(el));

    nodes.forEach((el) => {
      remember(el);
      el.setAttribute('dir', 'ltr');
      el.style.setProperty('direction', 'ltr', 'important');
      el.style.setProperty('text-align', 'left', 'important');
      el.style.setProperty('unicode-bidi', 'isolate', 'important');
      el.setAttribute(MARK, 'code-ltr');
    });
  }

  const semanticSelector =
    'p,li,h1,h2,h3,h4,h5,h6,blockquote,td,th,summary,dt,dd';

  function processLists(root, fontStack) {
    root.querySelectorAll('ol,ul').forEach((list) => {
      if (isInChrome(list)) return;

      const items = Array.from(list.children).filter(
        (el) => el.tagName === 'LI'
      );
      if (!items.length) return;

      let rtl = 0;
      let ltr = 0;

      for (const li of items) {
        const dir = detectDir(li.textContent || '');
        if (dir === 'rtl') rtl++;
        else if (dir === 'ltr') ltr++;
      }

      if (rtl > ltr) setBlockDir(list, 'rtl', 'list-rtl', fontStack);
      else if (ltr > rtl) setBlockDir(list, 'ltr', 'list-ltr', fontStack);
    });
  }

  function processRoot(root) {
    if (!root) return null;

    const fallbackFont =
      getComputedStyle(root).fontFamily ||
      'ui-sans-serif,system-ui,sans-serif';
    const fontStack = '"' + FAMILY + '",' + fallbackFont;

    setFont(root, fontStack);

    root.querySelectorAll(semanticSelector).forEach((el) => {
      if (isInChrome(el)) return;
      if (el.closest('pre,code,.code-block__code,.xterm')) return;

      const dir = detectDir(el.textContent || '');
      if (dir) setBlockDir(el, dir, dir, fontStack);
      else setFont(el, fontStack);
    });

    // Fallback for text bodies that use leaf DIVs instead of paragraphs.
    root.querySelectorAll('div').forEach((el) => {
      if (isInChrome(el)) return;
      if (el.closest('pre,code,.code-block__code,.xterm')) return;

      if (el.querySelector(
        'p,li,h1,h2,h3,h4,h5,h6,blockquote,pre,ul,ol,table,div'
      )) return;

      const text = (el.textContent || '').trim();
      if (!text || text.length > 15000) return;

      const dir = detectDir(text);
      if (dir) setBlockDir(el, dir, 'leaf-' + dir, fontStack);
      else setFont(el, fontStack);
    });

    processLists(root, fontStack);
    forceCodeLTR(root);

    return { root, fontStack };
  }

  function processComposer(fontStackFromRoot) {
    const editors = document.querySelectorAll(
      '[contenteditable="true"],[data-lexical-editor="true"],textarea,.ProseMirror,[role="textbox"]'
    );

    editors.forEach((el) => {
      if (isInChrome(el)) return;

      const fallback =
        fontStackFromRoot ||
        ('"' + FAMILY + '",' + getComputedStyle(el).fontFamily);

      const text = el.textContent || el.innerText || el.value || '';
      const dir = detectDir(text) || 'ltr';

      setBlockDir(el, dir, 'composer-' + dir, fallback);
    });
  }

  function processAll() {
    const root = findConversationRoot();
    const result = processRoot(root);
    processComposer(result?.fontStack || null);
    return root;
  }

  let timer = null;
  const schedule = () => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      timer = null;
      processAll();
    }, 100);
  };

  const observer = new MutationObserver(() => schedule());
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    characterData: true
  });

  const inputHandler = () => processComposer(null);
  document.addEventListener('input', inputHandler, true);

  function remove() {
    try { observer.disconnect(); } catch (_) {}
    try { document.removeEventListener('input', inputHandler, true); } catch (_) {}
    try { if (timer) clearTimeout(timer); } catch (_) {}
    restoreSnapshots();
    try { document.fonts.delete(face); } catch (_) {}
    try { delete window[FONT_KEY]; } catch (_) {}
    try { delete window[STATE_KEY]; } catch (_) {}
    return 'ChatGPT RTL + Vazirmatn removed from this session';
  }

  window[STATE_KEY] = {
    version: VERSION,
    observer,
    inputHandler,
    processAll,
    findConversationRoot,
    remove
  };

  const root = processAll();
  await new Promise((resolve) => setTimeout(resolve, 500));
  const root2 = processAll() || root;

  const rtlEls = Array.from(document.querySelectorAll(
    '[' + MARK + '="rtl"],[' + MARK + '="leaf-rtl"],[' + MARK + '="list-rtl"],[' + MARK + '="composer-rtl"]'
  ));

  const ltrEls = Array.from(document.querySelectorAll(
    '[' + MARK + '="ltr"],[' + MARK + '="leaf-ltr"],[' + MARK + '="list-ltr"],[' + MARK + '="composer-ltr"]'
  ));

  const sample =
    rtlEls.find((el) =>
      el.textContent &&
      el.textContent.trim().length > 20 &&
      !el.matches('ol,ul')
    ) || null;

  return {
    version: VERSION,
    rootFound: !!root2,
    rootTag: root2?.tagName || null,
    rootClass: typeof root2?.className === 'string'
      ? root2.className.slice(0, 180)
      : '',
    rtlTagged: rtlEls.length,
    ltrTagged: ltrEls.length,
    composerCount: document.querySelectorAll(
      '[contenteditable="true"],.ProseMirror,[role="textbox"]'
    ).length,
    fontStatus: face.status,
    fontCheck: document.fonts.check('16px "' + FAMILY + '"', 'سلام'),
    sampleDirection: sample ? getComputedStyle(sample).direction : null,
    sampleAlign: sample ? getComputedStyle(sample).textAlign : null,
    sampleBidi: sample ? getComputedStyle(sample).unicodeBidi : null,
    sampleFont: sample ? getComputedStyle(sample).fontFamily : null
  };
})()
'@

$js = $jsTemplate.Replace('__FONT_BASE64__', $fontBase64)

Info "Injecting ChatGPT RTL Final v3.1..."
$status = Invoke-TargetExpression -Target $target -Expression $js -AwaitPromise

Write-Host ""
Write-Host "=== ChatGPT RTL Final v3.1 ===" -ForegroundColor Green
Write-Host "Version          : $($status.version)"
Write-Host "Root found       : $($status.rootFound)"
Write-Host "Root tag         : $($status.rootTag)"
Write-Host "RTL tagged       : $($status.rtlTagged)"
Write-Host "LTR tagged       : $($status.ltrTagged)"
Write-Host "Composer count   : $($status.composerCount)"
Write-Host "Font status      : $($status.fontStatus)"
Write-Host "Font check       : $($status.fontCheck)"
Write-Host "Sample direction : $($status.sampleDirection)"
Write-Host "Sample align     : $($status.sampleAlign)"
Write-Host "Sample bidi      : $($status.sampleBidi)"
Write-Host "Sample font      : $($status.sampleFont)"

if ($status.fontStatus -ne 'loaded' -or -not $status.fontCheck) {
    throw "Vazirmatn did not load successfully."
}

if (-not $status.rootFound) {
    Warn "Conversation root is not mounted yet. The observer remains active."
}

if ($status.rtlTagged -gt 0) {
    if ($status.sampleDirection -ne 'rtl') {
        throw "RTL text was tagged but computed direction is not RTL."
    }
    Ok "RTL direction is active."
} else {
    Warn "No RTL text block is currently available to verify."
}

Ok "Vazirmatn is loaded for Persian/Arabic glyphs."
