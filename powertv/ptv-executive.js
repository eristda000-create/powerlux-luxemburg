(() => {
  'use strict';

  const EVENT_START = '2026-09-12T11:45:00Z';
  const OFFICIAL_CHANNEL = 'UC3Dw8OYsWmZqrM1qBBZUMhQ';
  const RYAN_CHANNEL = 'UCIEjGMfXbN4LFYSnV8qSgAQ';
  const VOA_CHANNEL = 'UCAH2krcji9uc3gYSqa33Zyw';
  const LEGACY_ASSET_CDN = 'https://cdn.jsdelivr.net/gh/eristda000-create/powerlux-luxemburg@8ca1846d78ea697c17b5f9d5f04ef13085c7a288/powertv/';
  const LEGACY_MEDIA = /^(?:\/?)(associate-[^/?#]+\.(?:png|jpe?g)|powertv-logo\.jpg)$/i;

  function patchLegacyAssets() {
    document.querySelectorAll('img[src]').forEach((img) => {
      const raw = (img.getAttribute('src') || '').trim();
      const match = raw.match(LEGACY_MEDIA);
      if (match) img.setAttribute('src', LEGACY_ASSET_CDN + match[1]);
    });
    document.querySelectorAll('source[srcset],img[srcset]').forEach((node) => {
      const raw = (node.getAttribute('srcset') || '').trim();
      if (!raw) return;
      const rewritten = raw.split(',').map((candidate) => {
        const parts = candidate.trim().split(/\s+/);
        const match = (parts[0] || '').match(LEGACY_MEDIA);
        if (match) parts[0] = LEGACY_ASSET_CDN + match[1];
        return parts.join(' ');
      }).join(', ');
      if (rewritten !== raw) node.setAttribute('srcset', rewritten);
    });
  }

  function localStart() {
    try {
      return new Intl.DateTimeFormat(undefined, {
        day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit'
      }).format(new Date(EVENT_START));
    } catch (_) {
      return '12 Sep · 11:45 UTC';
    }
  }

  function liveEmbed(channel) {
    return `https://www.youtube-nocookie.com/embed/live_stream?channel=${channel}&autoplay=0&rel=0&modestbranding=1`;
  }

  function countdownLabel() {
    const diff = new Date(EVENT_START).getTime() - Date.now();
    if (diff <= 0) return 'LIVE';
    const totalMinutes = Math.floor(diff / 60000);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    return hours > 24 ? `${Math.floor(hours / 24)}d ${hours % 24}h` : `${hours}h ${minutes}m`;
  }

  function build() {
    const root = document.createElement('section');
    root.id = 'ptv-command-center';
    root.setAttribute('aria-label', 'PowerTV East vs West 26 live');
    root.innerHTML = `
      <div class="ptv-shell">
        <div class="ptv-utility">
          <span class="ptv-live-status"><i></i> EVW26 · POWER TV</span>
          <span class="ptv-local-time">${localStart()} · Jiaxing</span>
        </div>

        <section class="ptv-hero">
          <div class="ptv-hero-copy">
            <div class="ptv-eyebrow">Armwrestling · Today</div>
            <div class="ptv-title-row">
              <h1>EAST vs WEST <span>26</span></h1>
              <b class="ptv-countdown" data-ptv-countdown>${countdownLabel()}</b>
            </div>
            <div class="ptv-actions">
              <a class="ptv-button primary" href="https://www.youtube.com/channel/${OFFICIAL_CHANNEL}/live" target="_blank" rel="noopener noreferrer">YouTube Live</a>
              <a class="ptv-button ppv" href="https://live.evwsports.com/" target="_blank" rel="noopener noreferrer sponsored">Official PPV</a>
            </div>
          </div>

          <div class="ptv-hero-media">
            <div class="ptv-media-frame"><iframe title="East vs West official public YouTube live" src="${liveEmbed(OFFICIAL_CHANNEL)}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></div>
            <div class="ptv-media-caption"><strong>Official feed</strong><span>Public YouTube stream</span></div>
          </div>
        </section>

        <section class="ptv-section" id="ptv-live-next">
          <div class="ptv-section-head">
            <div><div class="ptv-section-kicker">Live & next</div><h2 class="ptv-section-title">Watch now</h2></div>
          </div>
          <div class="ptv-rail">
            <a class="ptv-card live" href="https://www.youtube.com/channel/${OFFICIAL_CHANNEL}/live" target="_blank" rel="noopener noreferrer"><span class="ptv-card-label">Official</span><h3>EVW Live</h3><span class="ptv-card-cta">Open →</span></a>
            <a class="ptv-card official" href="https://live.evwsports.com/" target="_blank" rel="noopener noreferrer sponsored"><span class="ptv-card-label">Main card</span><h3>EVW26 PPV</h3><span class="ptv-card-cta">Watch →</span></a>
            <a class="ptv-card" href="https://www.youtube.com/channel/${RYAN_CHANNEL}/live" target="_blank" rel="noopener noreferrer"><span class="ptv-card-label">Commentary</span><h3>Ryan Bowen</h3><span class="ptv-card-cta">Open →</span></a>
            <a class="ptv-card" href="https://www.youtube.com/channel/${VOA_CHANNEL}/live" target="_blank" rel="noopener noreferrer"><span class="ptv-card-label">Analysis</span><h3>Voice of AW</h3><span class="ptv-card-cta">Open →</span></a>
          </div>
        </section>
      </div>`;
    return root;
  }

  function findNavAnchor() {
    const candidates = Array.from(document.querySelectorAll('nav,header,div'));
    for (const el of candidates) {
      const text = (el.textContent || '').replace(/\s+/g, ' ').trim();
      if (text.includes('Entdecken') && text.includes('Live & Events') && text.includes('Sportarten')) return el.closest('nav') || el;
    }
    const logo = Array.from(document.images).find(img => (img.alt || '').toLowerCase().includes('powertv'));
    return logo ? (logo.closest('header') || logo.parentElement?.parentElement) : null;
  }

  function findLegacyReplaySection() {
    const nodes = Array.from(document.querySelectorAll('h1,h2,h3,div,span'));
    const heading = nodes.find(el => (el.textContent || '').trim() === 'Sportvideos & Wettkämpfe');
    if (!heading) return null;
    const semanticSection = heading.closest('section');
    if (semanticSection) return semanticSection;
    let node = heading;
    while (node.parentElement && node.parentElement !== document.body) {
      if (node.parentElement.tagName === 'MAIN') return node;
      node = node.parentElement;
    }
    return heading.parentElement?.parentElement?.parentElement || heading.parentElement;
  }

  function ensureMounted() {
    document.querySelectorAll('.evw-sticky-link').forEach(el => el.remove());
    patchLegacyAssets();

    const replaySection = findLegacyReplaySection();
    if (replaySection) replaySection.classList.add('ptv-legacy-replay');

    let root = document.getElementById('ptv-command-center');
    if (!root) root = build();

    if (replaySection && replaySection.parentElement) {
      if (replaySection.previousElementSibling !== root) {
        try { replaySection.insertAdjacentElement('beforebegin', root); } catch (_) {}
      }
    } else {
      const anchor = findNavAnchor();
      if (!anchor || !anchor.parentElement) return;
      if (anchor.nextElementSibling !== root) {
        try { anchor.insertAdjacentElement('afterend', root); } catch (_) {}
      }
    }
    patchLegacyAssets();
  }

  function tick() {
    document.querySelectorAll('[data-ptv-countdown]').forEach(el => { el.textContent = countdownLabel(); });
  }

  let scheduled = false;
  const schedule = () => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => { scheduled = false; ensureMounted(); tick(); });
  };

  schedule();
  const observer = new MutationObserver(schedule);
  observer.observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['src','srcset'] });
  setInterval(() => { ensureMounted(); tick(); }, 1200);
})();