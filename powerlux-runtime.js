(() => {
  'use strict';

  const URL = 'https://fgkowgpauqexcwwtrxyd.supabase.co';
  const KEY = 'sb_publishable_EsHCY_P-NxhOMNHRQCZqnw_nPPoCjqr';

  if (!window.supabase?.createClient) return;

  window.PLX_SB = window.supabase.createClient(URL, KEY, {
    auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
  });

  const runtime = window.POWERLUX_RUNTIME = {
    supabaseUrl: URL,
    discoveryUrl: URL + '/functions/v1/powerlux-discovery',
    intakeUrl: URL + '/functions/v1/powerlux-revenue-intake',
    contentEngineUrl: URL + '/functions/v1/powerlux-content-engine',
    version: 'canonical-git-2026-09-10-runtime-guard-v1',
    discoveryState: 'unknown',
    discoveryDegradedHandling: 'explicit-notice-plus-osm-fallback-v1',
    geolocationGuard: 'granted-or-explicit-scan-v1',
    contactCtaNormalized: 'server-intake-v1'
  };

  function contactLabel() {
    const lang = String(document.documentElement.lang || 'de').toLowerCase();
    if (lang.startsWith('fr')) return 'Envoyer la demande';
    if (lang.startsWith('en')) return 'Send request';
    return 'Anfrage senden';
  }

  function normalizeContactCta() {
    const button = document.querySelector('#contactForm button[type="submit"]');
    if (!button) return;
    button.textContent = contactLabel();
    button.dataset.plxRuntimeNormalized = 'server-intake-v1';
  }

  normalizeContactCta();
  new MutationObserver(normalizeContactCta).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['lang']
  });

  let explicitLocationUntil = 0;
  document.addEventListener('click', (event) => {
    const target = event.target instanceof Element
      ? event.target.closest('[data-plx2-action="scan"]')
      : null;
    if (target) explicitLocationUntil = Date.now() + 8000;
  }, true);

  if (navigator.geolocation?.getCurrentPosition) {
    const nativeGetCurrentPosition = navigator.geolocation.getCurrentPosition.bind(navigator.geolocation);
    navigator.geolocation.getCurrentPosition = function guardedGetCurrentPosition(success, error, options) {
      if (Date.now() <= explicitLocationUntil) {
        return nativeGetCurrentPosition(success, error, options);
      }

      const denyStartupPrompt = () => {
        if (typeof error === 'function') {
          error({
            code: 1,
            message: 'Location prompt requires an explicit PowerMap scan action.'
          });
        }
      };

      if (!navigator.permissions?.query) {
        denyStartupPrompt();
        return undefined;
      }

      navigator.permissions.query({ name: 'geolocation' }).then((permission) => {
        if (permission.state === 'granted') {
          nativeGetCurrentPosition(success, error, options);
        } else {
          denyStartupPrompt();
        }
      }).catch(denyStartupPrompt);
      return undefined;
    };
  }

  function removeDiscoveryNotice() {
    document.querySelector('[data-plx-discovery-degraded]')?.remove();
  }

  function showDiscoveryNotice() {
    runtime.discoveryState = 'degraded_osm_fallback';
    let notice = document.querySelector('[data-plx-discovery-degraded]');
    if (!notice) {
      notice = document.createElement('div');
      notice.dataset.plxDiscoveryDegraded = '1';
      notice.setAttribute('role', 'status');
      notice.setAttribute('aria-live', 'polite');
      Object.assign(notice.style, {
        position: 'fixed',
        left: '50%',
        bottom: '72px',
        transform: 'translateX(-50%)',
        zIndex: '1600',
        width: 'min(620px, calc(100vw - 28px))',
        padding: '11px 14px',
        border: '1px solid rgba(243,200,93,.55)',
        background: 'rgba(4,16,23,.97)',
        color: '#f7e4a5',
        font: "800 11px/1.45 'Inter',Arial,sans-serif",
        letterSpacing: '.04em',
        textAlign: 'center'
      });
      document.body.appendChild(notice);
    }

    const lang = String(document.documentElement.lang || 'de').toLowerCase();
    notice.textContent = lang.startsWith('fr')
      ? 'PowerLux Discovery est temporairement dégradé · données OpenStreetMap de secours actives.'
      : lang.startsWith('en')
        ? 'PowerLux Discovery is temporarily degraded · OpenStreetMap fallback data is active.'
        : 'PowerLux Discovery ist vorübergehend eingeschränkt · OpenStreetMap-Fallback ist aktiv.';
  }

  const nativeFetch = window.fetch.bind(window);
  window.fetch = async function powerluxRuntimeFetch(input, init) {
    const response = await nativeFetch(input, init);
    const requestUrl = typeof input === 'string'
      ? input
      : input instanceof URL
        ? input.toString()
        : input?.url || '';

    if (requestUrl === runtime.discoveryUrl && response.ok) {
      try {
        const payload = await response.clone().json();
        if (payload?.error === 'discovery_temporarily_unavailable') {
          showDiscoveryNotice();
          const headers = new Headers(response.headers);
          headers.set('X-PowerLux-Discovery-State', 'degraded');
          return new Response(JSON.stringify(payload), {
            status: 503,
            statusText: 'PowerLux Discovery Degraded',
            headers
          });
        }
        runtime.discoveryState = 'healthy';
        removeDiscoveryNotice();
      } catch {
        runtime.discoveryState = 'invalid_response';
      }
    }

    return response;
  };
})();