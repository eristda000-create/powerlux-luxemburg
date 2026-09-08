/* PowerLux ↔ PowerTV integration layer
 * Real cross-product navigation only. No mock content, no fake stream state.
 * PowerTV canonical runtime remains the existing ChatGPT Sites product until its original source is recovered.
 */
(() => {
  'use strict';

  const POWERTV_URL = 'https://powertv-network.lucienne-ruppert.chatgpt.site';
  const CAMPAIGN = 'powerlux-powertv-network';
  const link = (surface) => {
    const u = new URL(POWERTV_URL);
    u.searchParams.set('utm_source', 'powerlux');
    u.searchParams.set('utm_medium', surface);
    u.searchParams.set('utm_campaign', CAMPAIGN);
    return u.toString();
  };

  function track(action, metadata = {}) {
    try {
      const body = JSON.stringify({
        action,
        visitorId: localStorage.getItem('plx_visitor_id') || undefined,
        sessionId: sessionStorage.getItem('plx_session_id') || undefined,
        source: localStorage.getItem('plx_source') || 'powerlux',
        campaign: CAMPAIGN,
        path: location.pathname,
        metadata
      });
      if (navigator.sendBeacon) {
        navigator.sendBeacon('/api/track', new Blob([body], { type: 'application/json' }));
        return;
      }
      fetch('/api/track', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body,
        keepalive: true
      }).catch(() => {});
    } catch {}
  }

  function bind(el, surface) {
    if (!el || el.dataset.ptvBound === '1') return;
    el.dataset.ptvBound = '1';
    el.addEventListener('click', () => track('powertv_open', { surface }));
  }

  function addHeaderLink() {
    const header = document.querySelector('.hub-header');
    if (!header || header.querySelector('[data-ptv-header]')) return;
    const account = header.querySelector('.plx-header-account');
    const a = document.createElement('a');
    a.className = 'plx-network-link plx-network-link--tv';
    a.dataset.ptvHeader = 'true';
    a.href = link('header');
    a.target = '_blank';
    a.rel = 'noopener';
    a.innerHTML = '<span class="plx-network-link__power">POWER</span><span class="plx-network-link__tv">TV</span><small>WATCH</small>';
    if (account) account.insertAdjacentElement('beforebegin', a);
    else header.appendChild(a);
    bind(a, 'header');
  }

  function addSideLink() {
    const menu = document.querySelector('#sideMenu');
    if (!menu || menu.querySelector('[data-ptv-side]')) return;
    const foot = menu.querySelector('.side-foot');
    const a = document.createElement('a');
    a.className = 'nav-btn plx-ptv-side';
    a.dataset.ptvSide = 'true';
    a.href = link('side-nav');
    a.target = '_blank';
    a.rel = 'noopener';
    a.innerHTML = '<span class="nav-index">15</span>PowerTV <span aria-hidden="true">↗</span>';
    if (foot) foot.insertAdjacentElement('beforebegin', a);
    else menu.appendChild(a);
    bind(a, 'side-nav');
  }

  function addHeroLink() {
    const actions = document.querySelector('#panel-home .hero-actions');
    if (!actions || actions.querySelector('[data-ptv-hero]')) return;
    const a = document.createElement('a');
    a.className = 'action plx-ptv-hero';
    a.dataset.ptvHero = 'true';
    a.href = link('home-hero');
    a.target = '_blank';
    a.rel = 'noopener';
    a.innerHTML = '<span class="plx-ptv-wordmark">POWER<b>TV</b></span><small> WATCH SPORT ↗</small>';
    actions.appendChild(a);
    bind(a, 'home-hero');
  }

  function addMobileLink() {
    const nav = document.querySelector('.mobile-nav');
    if (!nav || nav.querySelector('[data-ptv-mobile]')) return;
    const more = nav.querySelector('#mobileMore');
    if (!more) return;
    const a = document.createElement('a');
    a.className = 'mnav plx-ptv-mobile';
    a.dataset.ptvMobile = 'true';
    a.href = link('mobile-nav');
    a.target = '_blank';
    a.rel = 'noopener';
    a.textContent = 'PowerTV';
    more.insertAdjacentElement('beforebegin', a);
    bind(a, 'mobile-nav');
  }

  function markSharedAccount() {
    const account = document.querySelector('.plx-header-account');
    if (!account || account.querySelector('.plx-network-account-note')) return;
    const note = document.createElement('span');
    note.className = 'plx-network-account-note';
    note.textContent = 'NETWORK ID';
    note.title = 'MY PLX is the shared PowerLux network identity. PowerTV account sync is enabled only after its canonical source is recovered and tested.';
    account.appendChild(note);
  }

  function mount() {
    addHeaderLink();
    addSideLink();
    addHeroLink();
    addMobileLink();
    markSharedAccount();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', mount, { once: true });
  else mount();

  let attempts = 0;
  const timer = setInterval(() => {
    mount();
    if (++attempts > 100) clearInterval(timer);
  }, 100);

  new MutationObserver(mount).observe(document.documentElement, { childList: true, subtree: true });
})();
