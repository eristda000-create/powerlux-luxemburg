/* PowerLux Playbook homepage integration - staged for the existing PowerLux Hub.
   Placement: directly inside #panel-home, after .lead and before .hero-actions.
   Public asset expected at: /assets/PowerLux_Playbook_v1.0_PUBLIC.pdf
*/
(() => {
  const PDF = '/assets/PowerLux_Playbook_v1.0_PUBLIC.pdf';
  const home = document.querySelector('#panel-home');
  if (!home || home.querySelector('[data-plx-playbook]')) return;

  const lead = home.querySelector('.lead');
  const actions = home.querySelector('.hero-actions');
  const section = document.createElement('section');
  section.className = 'plx-playbook-feature';
  section.dataset.plxPlaybook = 'true';
  section.innerHTML = `
    <div class="plx-playbook-copy">
      <div class="hud-eyebrow">FREE KNOWLEDGE // ARMWRESTLING</div>
      <span class="plx-playbook-badge">NEW // PUBLIC EDITION 1.0</span>
      <h2>The Free<br><b>Armwrestling Playbook.</b></h2>
      <p>PowerLux komprimiert komplexe Armwrestling-Mechanik in klare Entscheidungen: Inside vs Outside, Structure First, Rise Before Pronation und Cut or Climb.</p>
      <div class="plx-playbook-actions">
        <button class="action primary" type="button" data-playbook-open>Playbook lesen</button>
        <a class="action" href="${PDF}" download>PDF herunterladen</a>
        <a class="action plx-instagram-cta" href="https://www.instagram.com/" target="_blank" rel="noopener">PowerLux auf Instagram</a>
      </div>
    </div>
    <button class="plx-playbook-cover" type="button" data-playbook-open aria-label="PowerLux Armwrestling Playbook öffnen">
      <span class="plx-playbook-cover-kicker">POWERLUX // FREE PLAYBOOK</span>
      <strong>THE FREE<br><em>ARMWRESTLING</em><br>PLAYBOOK</strong>
      <small>ATHLETES FIRST. FREE KNOWLEDGE. HONEST SPORT.</small>
    </button>`;

  if (actions) home.insertBefore(section, actions);
  else if (lead) lead.insertAdjacentElement('afterend', section);
  else home.prepend(section);

  const modal = document.createElement('div');
  modal.className = 'plx-playbook-modal';
  modal.dataset.playbookModal = '';
  modal.setAttribute('aria-hidden', 'true');
  modal.innerHTML = `
    <div class="plx-playbook-modal-shell" role="dialog" aria-modal="true" aria-label="PowerLux Armwrestling Playbook">
      <div class="plx-playbook-modal-head">
        <div><small>POWERLUX // PUBLIC EDITION 1.0</small><strong>Armwrestling Playbook</strong></div>
        <div class="plx-playbook-modal-actions">
          <a href="${PDF}" download>Download PDF</a>
          <button type="button" data-playbook-close aria-label="Playbook schließen">×</button>
        </div>
      </div>
      <div class="plx-playbook-reader">
        <iframe title="PowerLux Armwrestling Playbook" src="${PDF}#view=FitH" loading="lazy"></iframe>
        <div class="plx-playbook-mobile-fallback">
          <strong>Auf dem Handy direkt lesbar.</strong>
          <p>Mobile Browser behandeln eingebettete PDFs unterschiedlich. Öffne deshalb die optimierte Vollansicht oder lade die Datei herunter.</p>
          <a class="action primary" href="${PDF}" target="_blank" rel="noopener">Vollansicht öffnen</a>
          <a class="action" href="${PDF}" download>PDF herunterladen</a>
        </div>
      </div>
    </div>`;
  document.body.appendChild(modal);

  const open = () => { modal.classList.add('open'); modal.setAttribute('aria-hidden','false'); document.body.classList.add('plx-playbook-open'); };
  const close = () => { modal.classList.remove('open'); modal.setAttribute('aria-hidden','true'); document.body.classList.remove('plx-playbook-open'); };
  document.querySelectorAll('[data-playbook-open]').forEach(el => el.addEventListener('click', open));
  modal.querySelector('[data-playbook-close]').addEventListener('click', close);
  modal.addEventListener('click', e => { if (e.target === modal) close(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape' && modal.classList.contains('open')) close(); });
})();
