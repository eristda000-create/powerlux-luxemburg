(() => {
  'use strict';

  const CONFIG = {
    eventName: 'East vs West 26',
    eventStart: '2026-09-12T11:45:00Z',
    eventLocation: 'Jiaxing, China',
    officialChannelId: 'UC3Dw8OYsWmZqrM1qBBZUMhQ',
    officialChannel: 'https://www.youtube.com/channel/UC3Dw8OYsWmZqrM1qBBZUMhQ',
    officialStreams: 'https://www.youtube.com/channel/UC3Dw8OYsWmZqrM1qBBZUMhQ/streams',
    officialVideos: 'https://www.youtube.com/channel/UC3Dw8OYsWmZqrM1qBBZUMhQ/videos',
    ppv: 'https://live.evwsports.com/',
    evwSite: 'https://evwsports.com/',
    ryan: {
      name: 'Ryan Bowen',
      channelId: 'UCIEjGMfXbN4LFYSnV8qSgAQ',
      url: 'https://www.youtube.com/channel/UCIEjGMfXbN4LFYSnV8qSgAQ'
    },
    voice: {
      name: 'Voice of Armwrestling',
      channelId: 'UCAH2krcji9uc3gYSqa33Zyw',
      url: 'https://www.youtube.com/channel/UCAH2krcji9uc3gYSqa33Zyw'
    }
  };

  const escapeHtml = (value) => String(value).replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
  const liveEmbed = channelId => `https://www.youtube-nocookie.com/embed/live_stream?channel=${encodeURIComponent(channelId)}&autoplay=0&rel=0&modestbranding=1`;

  function localStartText() {
    try {
      return new Intl.DateTimeFormat(undefined, {
        weekday: 'short', day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit', timeZoneName: 'short'
      }).format(new Date(CONFIG.eventStart));
    } catch (_) {
      return '12 Sep 2026 · 11:45 UTC';
    }
  }

  function commentaryCard(person, label) {
    return `
      <article class="evw-commentary-card">
        <div class="evw-frame">
          <iframe loading="lazy" title="${escapeHtml(person.name)} YouTube live" src="${liveEmbed(person.channelId)}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
        </div>
        <div class="evw-card-body">
          <div class="evw-card-title"><span class="evw-badge evw-badge-commentary">${escapeHtml(label)}</span>${escapeHtml(person.name)}</div>
          <p>Unabhängige Analyse / Watchalong. Wenn der Kanal gerade live ist, erscheint der öffentliche YouTube-Stream hier automatisch.</p>
          <div class="evw-mini-actions"><a href="${person.url}/live" target="_blank" rel="noopener noreferrer">Auf YouTube öffnen</a><a href="${person.url}/streams" target="_blank" rel="noopener noreferrer">Alle Streams</a></div>
        </div>
      </article>`;
  }

  function buildHub() {
    const section = document.createElement('section');
    section.id = 'evw-growth-hub';
    section.setAttribute('aria-label', 'East vs West Armwrestling Live Hub');
    section.innerHTML = `
      <div class="evw-shell">
        <div class="evw-livebar"><span class="evw-live-dot" aria-hidden="true"></span><span class="evw-kicker">PowerTV · East vs West Live Hub</span><span class="evw-local-time">EVW26 · ${escapeHtml(localStartText())}</span></div>
        <div class="evw-hero-grid">
          <div class="evw-copy">
            <div class="evw-eyebrow">Armwrestling · Official links + free YouTube coverage</div>
            <h2>EAST vs WEST <span>26</span></h2>
            <p>Alles an einem Ort: offizieller East-vs-West-YouTube-Livefeed, öffentliche Streams und Replays, unabhängige Commentary-/Watchalong-Kanäle sowie der offizielle PPV-Zugang zur Main Card. PowerTV hostet keinen fremden PPV-Feed.</p>
            <div class="evw-chips"><span class="evw-chip"><strong>12 Sep 2026</strong></span><span class="evw-chip">Jiaxing, China</span><span class="evw-chip">PPV coverage: <strong>11:45 UTC</strong></span><span class="evw-chip">YouTube: <strong>free public content</strong></span></div>
            <div class="evw-actions"><a class="evw-btn evw-btn-primary" href="#evw-official-live">Official YouTube Live</a><a class="evw-btn evw-btn-ppv" href="${CONFIG.ppv}" target="_blank" rel="noopener noreferrer sponsored">Official PPV</a><a class="evw-btn evw-btn-secondary" href="/east-vs-west/">EVW Watch Page</a></div>
          </div>
          <aside class="evw-side">
            <div class="evw-count-label">Starts in</div>
            <div class="evw-countdown" data-evw-countdown><div class="evw-unit"><b data-d>--</b><span>Days</span></div><div class="evw-unit"><b data-h>--</b><span>Hours</span></div><div class="evw-unit"><b data-m>--</b><span>Min</span></div><div class="evw-unit"><b data-s>--</b><span>Sec</span></div></div>
            <div class="evw-side-note">Die Zeit wird automatisch in deiner lokalen Zeitzone angezeigt. Öffentliche YouTube-Streams können Press Conference, Interviews, Prelims oder andere frei veröffentlichte EVW-Inhalte sein. Die Main Card bleibt beim offiziellen PPV-Anbieter.</div>
          </aside>
        </div>

        <div class="evw-section" id="evw-official-live">
          <div class="evw-section-head"><h3>Official East vs West YouTube</h3><p>Live, falls der offizielle Kanal gerade sendet.</p></div>
          <div class="evw-stream-grid">
            <article class="evw-player-card">
              <div class="evw-frame"><iframe loading="eager" title="East vs West Armwrestling official YouTube live" src="${liveEmbed(CONFIG.officialChannelId)}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></div>
              <div class="evw-card-body"><div class="evw-card-title"><span class="evw-badge">Official YouTube</span>East vs West Armwrestling</div><p>Direkt vom offiziellen EVW-Kanal. Wenn aktuell kein öffentlicher Livestream läuft, nutze „Alle Streams“ für frühere Lives, Replays und angekündigte Sendungen.</p><div class="evw-mini-actions"><a href="${CONFIG.officialChannel}/live" target="_blank" rel="noopener noreferrer">Live auf YouTube</a><a href="${CONFIG.officialStreams}" target="_blank" rel="noopener noreferrer">Alle Streams</a><a href="${CONFIG.officialVideos}" target="_blank" rel="noopener noreferrer">Alle Videos</a></div></div>
            </article>
            <article class="evw-player-card">
              <div class="evw-card-body">
                <div class="evw-card-title"><span class="evw-badge">Main Card</span>Official EVW26 PPV</div>
                <p>Die EVW26 Main Card wird über den offiziellen East vs West PPV angeboten. PowerTV bündelt die Wege zum Event, übernimmt aber keinen geschützten Broadcast.</p>
                <div class="evw-mini-actions"><a href="${CONFIG.ppv}" target="_blank" rel="noopener noreferrer sponsored">Get official PPV</a><a href="${CONFIG.evwSite}" target="_blank" rel="noopener noreferrer">EVW26 event info</a></div>
              </div>
              <div class="evw-source-note"><strong>Rights-safe:</strong> Nur frei zugängliche YouTube-Inhalte werden eingebettet. PPV bleibt beim Rechteinhaber. Commentary-Kanäle sind unabhängig und werden klar gekennzeichnet.</div>
            </article>
          </div>
        </div>

        <div class="evw-section">
          <div class="evw-section-head"><h3>Live commentary & watchalongs</h3><p>Alternative Stimmen rund um East vs West.</p></div>
          <div class="evw-commentary-grid">${commentaryCard(CONFIG.ryan, 'Commentary')}${commentaryCard(CONFIG.voice, 'Analysis')}</div>
        </div>

        <div class="evw-section">
          <div class="evw-section-head"><h3>Find exactly what you want</h3><p>Direkte Einstiege für Google- und YouTube-Suchintentionen.</p></div>
          <div class="evw-search-links"><a class="evw-search-link" href="/east-vs-west/"><b>East vs West live</b><span>Official streams, PPV and commentary in one page.</span></a><a class="evw-search-link" href="${CONFIG.officialStreams}" target="_blank" rel="noopener noreferrer"><b>East vs West YouTube streams</b><span>All public live archives from the official channel.</span></a><a class="evw-search-link" href="${CONFIG.ppv}" target="_blank" rel="noopener noreferrer sponsored"><b>Watch EVW26 main card</b><span>Official pay-per-view route.</span></a></div>
        </div>
      </div>`;
    return section;
  }

  function tick() {
    const root = document.querySelector('[data-evw-countdown]');
    if (!root) return;
    let diff = new Date(CONFIG.eventStart).getTime() - Date.now();
    if (diff <= 0) {
      root.querySelector('[data-d]').textContent = 'LIVE';
      root.querySelector('[data-h]').textContent = 'NOW';
      root.querySelector('[data-m]').textContent = '•';
      root.querySelector('[data-s]').textContent = '•';
      return;
    }
    const total = Math.floor(diff / 1000);
    root.querySelector('[data-d]').textContent = Math.floor(total / 86400);
    root.querySelector('[data-h]').textContent = String(Math.floor((total % 86400) / 3600)).padStart(2,'0');
    root.querySelector('[data-m]').textContent = String(Math.floor((total % 3600) / 60)).padStart(2,'0');
    root.querySelector('[data-s]').textContent = String(total % 60).padStart(2,'0');
  }

  function mount() {
    if (document.getElementById('evw-growth-hub')) return true;
    const main = document.querySelector('main');
    if (!main) return false;
    const hub = buildHub();
    main.insertBefore(hub, main.firstChild);
    const sticky = document.createElement('a');
    sticky.className = 'evw-sticky-link';
    sticky.href = '#evw-growth-hub';
    sticky.textContent = 'EVW26 Live Hub';
    sticky.setAttribute('aria-label','Open East vs West 26 Live Hub');
    document.body.appendChild(sticky);
    tick();
    setInterval(tick, 1000);
    return true;
  }

  if (!mount()) {
    const observer = new MutationObserver(() => { if (mount()) observer.disconnect(); });
    observer.observe(document.documentElement, {childList:true, subtree:true});
    setTimeout(() => observer.disconnect(), 15000);
  }
})();