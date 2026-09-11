(() => {
  'use strict';

  const EVENT_START = '2026-09-12T11:45:00Z';
  const OFFICIAL_CHANNEL = 'UC3Dw8OYsWmZqrM1qBBZUMhQ';
  const RYAN_CHANNEL = 'UCIEjGMfXbN4LFYSnV8qSgAQ';
  const VOA_CHANNEL = 'UCAH2krcji9uc3gYSqa33Zyw';

  function localStart() {
    try {
      return new Intl.DateTimeFormat(undefined, {
        weekday: 'short', day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit', timeZoneName: 'short'
      }).format(new Date(EVENT_START));
    } catch (_) {
      return '12 Sep 2026 · 11:45 UTC';
    }
  }

  function liveEmbed(channel) {
    return `https://www.youtube-nocookie.com/embed/live_stream?channel=${channel}&autoplay=0&rel=0&modestbranding=1`;
  }

  function countdownLabel() {
    const diff = new Date(EVENT_START).getTime() - Date.now();
    if (diff <= 0) return 'LIVE / EVENT WINDOW';
    const totalMinutes = Math.floor(diff / 60000);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    return hours > 24 ? `${Math.floor(hours / 24)}d ${hours % 24}h` : `${hours}h ${minutes}m`;
  }

  function build() {
    const root = document.createElement('section');
    root.id = 'ptv-command-center';
    root.setAttribute('aria-label', 'PowerTV East vs West 26 command center');
    root.innerHTML = `
      <div class="ptv-shell">
        <div class="ptv-utility">
          <div class="ptv-live-status"><i></i><span><strong>POWER TV TODAY</strong> · EVW26 COMMAND CENTER</span></div>
          <div class="ptv-local-time">${localStart()} · Jiaxing, China</div>
        </div>

        <section class="ptv-hero">
          <div class="ptv-hero-copy">
            <div class="ptv-eyebrow">Armwrestling · Today · PowerTV priority event</div>
            <h1>EAST vs WEST <span>26</span></h1>
            <p class="ptv-deck">Der schnellste Weg zum Event: offizieller YouTube-Livefeed, PPV, freie Streams und unabhängige Commentary-Kanäle – kuratiert in einer einzigen PowerTV-Oberfläche.</p>
            <div class="ptv-metrics">
              <div class="ptv-metric"><b data-ptv-countdown>${countdownLabel()}</b><span>until event</span></div>
              <div class="ptv-metric"><b>4 watch routes</b><span>official + commentary</span></div>
              <div class="ptv-metric"><b>Rights-safe</b><span>public embeds only</span></div>
            </div>
            <div class="ptv-actions">
              <a class="ptv-button primary" href="https://www.youtube.com/channel/${OFFICIAL_CHANNEL}/live" target="_blank" rel="noopener noreferrer">Official YouTube Live</a>
              <a class="ptv-button ppv" href="https://live.evwsports.com/" target="_blank" rel="noopener noreferrer sponsored">Official PPV</a>
              <a class="ptv-button" href="#ptv-live-next">Live & next</a>
            </div>
          </div>
          <div class="ptv-hero-media">
            <div class="ptv-media-head"><strong>Official EVW live window</strong><span>Public YouTube feed</span></div>
            <div class="ptv-media-frame"><iframe title="East vs West official public YouTube live" src="${liveEmbed(OFFICIAL_CHANNEL)}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></div>
            <div class="ptv-media-caption"><h2>Watch the official feed first.</h2><p>Wenn EVW öffentlich live auf YouTube sendet, erscheint der Stream hier. Die Main Card bleibt beim offiziellen PPV.</p></div>
          </div>
        </section>

        <section class="ptv-section" id="ptv-live-next">
          <div class="ptv-section-head"><div><div class="ptv-section-kicker">Live & next</div><h2 class="ptv-section-title">Choose your feed</h2></div><p class="ptv-section-note">Wie bei einer Streaming-Plattform: sofort sehen, was jetzt relevant ist.</p></div>
          <div class="ptv-rail">
            <a class="ptv-card live" href="https://www.youtube.com/channel/${OFFICIAL_CHANNEL}/live" target="_blank" rel="noopener noreferrer"><div><div class="ptv-card-label">Official · YouTube</div><h3>East vs West live</h3><p>Öffentlicher EVW-Livestream, sobald der offizielle Kanal sendet.</p></div><div class="ptv-card-cta">Open official live →</div></a>
            <a class="ptv-card official" href="https://live.evwsports.com/" target="_blank" rel="noopener noreferrer sponsored"><div><div class="ptv-card-label">Official · Main card</div><h3>EVW26 PPV</h3><p>Direkter Weg zum offiziellen Rechteinhaber für die Main Card.</p></div><div class="ptv-card-cta">Open official PPV →</div></a>
            <a class="ptv-card" href="https://www.youtube.com/channel/${RYAN_CHANNEL}/live" target="_blank" rel="noopener noreferrer"><div><div class="ptv-card-label">Independent commentary</div><h3>Ryan Bowen</h3><p>Öffentliche Analyse oder Watchalong, wenn sein Kanal live ist.</p></div><div class="ptv-card-cta">Open Ryan Bowen →</div></a>
            <a class="ptv-card" href="https://www.youtube.com/channel/${VOA_CHANNEL}/live" target="_blank" rel="noopener noreferrer"><div><div class="ptv-card-label">Independent analysis</div><h3>Voice of Armwrestling</h3><p>Zusätzliche Live-Perspektive und Armwrestling-Analyse.</p></div><div class="ptv-card-cta">Open channel →</div></a>
          </div>
        </section>

        <section class="ptv-section">
          <div class="ptv-section-head"><div><div class="ptv-section-kicker">PowerTV briefing</div><h2 class="ptv-section-title">What matters now</h2></div><p class="ptv-section-note">Weniger Oberfläche, mehr Entscheidungsklarheit.</p></div>
          <div class="ptv-intel-grid">
            <article class="ptv-intel primary"><div class="num">01 · Event intelligence</div><h3>One event. Multiple legitimate ways to follow it.</h3><p>PowerTV trennt klar zwischen offiziellem Broadcast, frei veröffentlichtem YouTube-Content und unabhängigen Kommentatoren. So bleibt die Nutzerführung schnell und der Rechteweg sauber.</p><div class="ptv-intent"><a href="https://www.youtube.com/channel/${OFFICIAL_CHANNEL}/streams" target="_blank" rel="noopener noreferrer">All EVW streams</a><a href="https://www.youtube.com/channel/${OFFICIAL_CHANNEL}/videos" target="_blank" rel="noopener noreferrer">EVW videos</a></div></article>
            <article class="ptv-intel"><div class="num">02 · Featured matchups</div><div class="ptv-match-list"><div class="ptv-match"><b>Devon Larratt vs Ivan Matyushenko</b>Left arm</div><div class="ptv-match"><b>John Brzenk vs Zhao Zi Rui</b>Featured match</div><div class="ptv-match"><b>Matt Mask vs Leonidas Arkona</b>Right arm</div><div class="ptv-match"><b>Bogdan Stoica vs Irakli Zirakashvili</b>Middleweight title</div></div></article>
            <article class="ptv-intel"><div class="num">03 · PowerTV standard</div><h3>Discovery before clutter.</h3><p>Live first, then context, then the broader catalog. Existing PowerTV replays and Associates remain part of the page – but no longer dominate the opening screen on an EVW event day.</p></article>
          </div>
        </section>
      </div>`;
    return root;
  }

  function findNavAnchor() {
    const candidates = Array.from(document.querySelectorAll('nav,header,div'));
    for (const el of candidates) {
      const text = (el.textContent || '').replace(/\s+/g, ' ').trim();
      if (text.includes('Entdecken') && text.includes('Live & Events') && text.includes('Sportarten')) {
        const nav = el.closest('nav') || el;
        return nav;
      }
    }
    const logo = Array.from(document.images).find(img => (img.alt || '').toLowerCase().includes('powertv'));
    return logo ? (logo.closest('header') || logo.parentElement?.parentElement) : null;
  }

  function tagLegacyReplay() {
    const nodes = Array.from(document.querySelectorAll('h1,h2,h3,div,span'));
    const heading = nodes.find(el => (el.textContent || '').trim() === 'Sportvideos & Wettkämpfe');
    if (!heading) return;
    const section = heading.closest('section') || heading.parentElement?.parentElement?.parentElement;
    if (section) section.classList.add('ptv-legacy-replay');
  }

  function ensureMounted() {
    document.querySelectorAll('.evw-sticky-link').forEach(el => el.remove());
    tagLegacyReplay();

    let root = document.getElementById('ptv-command-center');
    const anchor = findNavAnchor();
    if (!anchor || !anchor.parentElement) return;

    if (!root) root = build();
    const expectedNext = anchor.nextElementSibling;
    if (expectedNext !== root) {
      try { anchor.insertAdjacentElement('afterend', root); } catch (_) {}
    }
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
  observer.observe(document.documentElement, { childList: true, subtree: true });
  setInterval(() => { ensureMounted(); tick(); }, 1200);
})();