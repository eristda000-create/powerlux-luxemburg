(() => {
  'use strict';

  const RELEASE = '2026.09.08.4';
  const nativeFetch = window.fetch.bind(window);
  const PUBLIC_RADAR = 'https://fgkowgpauqexcwwtrxyd.supabase.co/functions/v1/powerlux-public-radar';

  function patchClient(sb) {
    if (!sb || sb.__powerluxPublicRadarPatched) return sb;
    const rpc = sb.rpc.bind(sb);
    sb.rpc = async (fn, args, opts) => {
      if (fn === 'scan_public_radar') {
        try {
          const r = await nativeFetch(PUBLIC_RADAR, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(args || {})
          });
          const j = await r.json().catch(() => ({ data: null, error: { message: 'invalid_response' } }));
          if (!r.ok || j?.error) return { data: null, error: { message: j?.error?.message || 'Public Radar unavailable' } };
          return { data: Array.isArray(j.data) ? j.data : [], error: null };
        } catch {
          return { data: null, error: { message: 'Public Radar unavailable' } };
        }
      }
      return rpc(fn, args, opts);
    };
    try {
      Object.defineProperty(sb, '__powerluxPublicRadarPatched', { value: true });
    } catch {
      sb.__powerluxPublicRadarPatched = true;
    }
    return sb;
  }

  try {
    if (window.PLX_SB) patchClient(window.PLX_SB);
    else {
      let holder;
      Object.defineProperty(window, 'PLX_SB', {
        configurable: true,
        enumerable: true,
        get() { return holder; },
        set(v) { holder = patchClient(v); }
      });
    }
  } catch {
    const timer = setInterval(() => {
      if (window.PLX_SB) {
        patchClient(window.PLX_SB);
        clearInterval(timer);
      }
    }, 50);
    setTimeout(() => clearInterval(timer), 10000);
  }

  /*
   * IMPORTANT RELEASE FIX:
   * Do not override window.fetch for powerlux-discovery.
   *
   * The deployed plx-radar-v3.js already calls the verified Supabase
   * powerlux-discovery Edge Function directly and has its own fallback to
   * Overpass. The previous release layer intercepted that request and routed
   * it to /api/sports. That route does not exist in the production project;
   * on failure the old override returned a synthetic empty places array,
   * making a healthy discovery backend appear to have zero results.
   *
   * Keeping native fetch ownership here restores the canonical discovery
   * path without changing the PowerMap UI or inventing replacement data.
   */

  const replacements = [
    [/\bMY PLX\b/gi, 'POWERLUX ACCOUNT'],
    [/\bPLX MEMBERS\b/gi, 'POWERLUX MEMBERS'],
    [/\bPLX MEMBER\b/gi, 'POWERLUX MEMBER'],
    [/\bPLX SIGNALS\b/gi, 'POWERLUX SIGNALS'],
    [/\bPLX SIGNAL\b/gi, 'POWERLUX SIGNAL'],
    [/\bPLX CHALLENGES\b/gi, 'POWERLUX CHALLENGES'],
    [/\bPLX SCORE\b/gi, 'POWERLUX SCORE'],
    [/\bPLX PERFORMANCE\b/gi, 'POWERLUX PERFORMANCE'],
    [/\bPLX NETWORK\b/gi, 'POWERLUX NETWORK'],
    [/\bPLX ACCOUNT\b/gi, 'POWERLUX ACCOUNT'],
    [/\bPLX\b/g, 'POWERLUX']
  ];

  function clean(s) {
    let x = String(s || '');
    for (const [r, v] of replacements) x = x.replace(r, v);
    return x.replace(/\s*\/\/\s*/g, ' · ').replace(/\s+·\s+·\s+/g, ' · ');
  }

  function skip(n) {
    const p = n.parentElement;
    return !p || /^(SCRIPT|STYLE|NOSCRIPT|TEXTAREA|INPUT|OPTION)$/.test(p.tagName) || !!p.closest('[data-plx-no-brand-clean]');
  }

  function sweep() {
    if (!document.body) return;
    const w = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
    const nodes = [];
    while (w.nextNode()) nodes.push(w.currentNode);
    for (const n of nodes) {
      if (skip(n)) continue;
      const c = clean(n.nodeValue);
      if (c !== n.nodeValue) n.nodeValue = c;
    }
    document.title = 'PowerLux | Sport Network';
    document.querySelectorAll('[aria-label]').forEach((el) => {
      const v = clean(el.getAttribute('aria-label'));
      if (v) el.setAttribute('aria-label', v);
    });
  }

  let queued = false;
  const queue = () => {
    if (queued) return;
    queued = true;
    requestAnimationFrame(() => {
      queued = false;
      sweep();
    });
  };

  new MutationObserver(queue).observe(document.documentElement, {
    subtree: true,
    childList: true,
    characterData: true
  });

  document.documentElement.dataset.powerluxRelease = RELEASE;
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', sweep, { once: true });
  else sweep();

  document.addEventListener('submit', async (e) => {
    const f = e.target;
    if (!f.matches?.('[data-plx2-form="report"],[data-plx2-form="challenge"]')) return;
    if (f.dataset.powerluxReleaseGuard === 'ok') {
      delete f.dataset.powerluxReleaseGuard;
      return;
    }
    e.preventDefault();
    e.stopImmediatePropagation();
    const route = f.dataset.plx2Form === 'report' ? '/talent/report' : '/challenge/submit';
    try {
      const g = window.PowerLuxGuard ? await window.PowerLuxGuard('generic_request', route) : { allowed: true };
      if (g.allowed === false) throw new Error('Zu viele Anfragen. Bitte später erneut versuchen.');
      f.dataset.powerluxReleaseGuard = 'ok';
      f.requestSubmit();
    } catch (err) {
      alert(err?.message || 'Anfrage vorübergehend pausiert.');
    }
  }, true);

  document.addEventListener('click', (e) => {
    const b = e.target.closest?.('.action,.nav-btn,.mnav,.plx2-layer,.plx2-radius');
    if (b) b.animate?.(
      [{ transform: 'scale(1)' }, { transform: 'scale(.985)' }, { transform: 'scale(1)' }],
      { duration: 160, easing: 'ease-out' }
    );
  }, true);
})();
