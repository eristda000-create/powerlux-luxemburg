/* PowerLux Playbook integration — real PDF only.
   No invented summary, no Principles CTA, no unrelated sport tabs beside the book.
   Expected public asset: /assets/PowerLux_Playbook_v1.0_PUBLIC.pdf
*/
(() => {
  const PDF = '/assets/PowerLux_Playbook_v1.0_PUBLIC.pdf';
  const home = document.querySelector('#panel-home');
  if (!home || home.querySelector('[data-plx-playbook]')) return;

  // Remove the redundant sport selector from the hero area. Sport navigation remains elsewhere in the product.
  const sportTabs = home.querySelector('.sport-tabs, .sports-tabs, [data-sport-tabs]');
  if (sportTabs) sportTabs.remove();

  const actions = home.querySelector('.hero-actions');
  const section = document.createElement('section');
  section.className = 'plx-playbook-feature';
  section.dataset.plxPlaybook = 'true';
  section.innerHTML = `
    <button class="plx-playbook-cover" type="button" data-playbook-open aria-label="PowerLux Armwrestling Playbook lesen">
      <span class="hud-eyebrow">POWERLUX // FREE PLAYBOOK</span>
      <strong>THE FREE<br><em>ARMWRESTLING</em><br>PLAYBOOK</strong>
      <small>FREE KNOWLEDGE. HONEST SPORT.</small>
    </button>
    <div class="plx-playbook-copy">
      <div class="hud-eyebrow">ARM WRESTLING KNOWLEDGE // PUBLIC EDITION</div>
      <h2>THE FREE <b>ARMWRESTLING PLAYBOOK</b></h2>
      <p>Das echte PowerLux Playbook direkt auf der Website lesen oder als PDF speichern.</p>
      <div class="plx-playbook-actions">
        <button class="action primary" type="button" data-playbook-open>PLAYBOOK LESEN</button>
        <a class="action" href="${PDF}" download="PowerLux_Armwrestling_Playbook.pdf">PDF DOWNLOAD</a>
      </div>
    </div>`;

  if (actions) actions.insertAdjacentElement('afterend', section);
  else home.prepend(section);

  const modal = document.createElement('div');
  modal.className = 'plx-playbook-modal';
  modal.dataset.playbookModal = '';
  modal.setAttribute('aria-hidden', 'true');
  modal.innerHTML = `
    <div class="plx-playbook-modal-shell" role="dialog" aria-modal="true" aria-label="PowerLux Armwrestling Playbook">
      <div class="plx-playbook-modal-head">
        <strong>POWERLUX // ARM WRESTLING PLAYBOOK</strong>
        <div class="plx-playbook-modal-actions">
          <a href="${PDF}" download="PowerLux_Armwrestling_Playbook.pdf">PDF DOWNLOAD</a>
          <button type="button" data-playbook-close aria-label="Playbook schließen">×</button>
        </div>
      </div>
      <div class="plx-playbook-reader">
        <iframe title="PowerLux Armwrestling Playbook" src="${PDF}#view=FitH&toolbar=0" loading="eager"></iframe>
        <div class="plx-playbook-mobile-fallback">
          <a class="action primary" href="${PDF}" target="_blank" rel="noopener">PLAYBOOK VOLLANSICHT</a>
          <a class="action" href="${PDF}" download="PowerLux_Armwrestling_Playbook.pdf">PDF DOWNLOAD</a>
        </div>
      </div>
    </div>`;
  document.body.appendChild(modal);

  const open = () => {
    modal.classList.add('open');
    modal.setAttribute('aria-hidden', 'false');
    document.body.classList.add('plx-playbook-open');
  };
  const close = () => {
    modal.classList.remove('open');
    modal.setAttribute('aria-hidden', 'true');
    document.body.classList.remove('plx-playbook-open');
  };
  document.querySelectorAll('[data-playbook-open]').forEach(el => el.addEventListener('click', open));
  modal.querySelector('[data-playbook-close]').addEventListener('click', close);
  modal.addEventListener('click', e => { if (e.target === modal) close(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape' && modal.classList.contains('open')) close(); });
})();
