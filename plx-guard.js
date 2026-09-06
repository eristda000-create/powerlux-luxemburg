(() => {
  "use strict";
  const URL = "https://fgkowgpauqexcwwtrxyd.supabase.co/functions/v1/powerlux-guard";
  const KEY = "sb_publishable_EsHCY_P-NxhOMNHRQCZqnw_nPPoCjqr";
  const recent = new Map();
  window.PowerLuxGuard = async function (action, route) {
    const key = action + ":" + route;
    const cached = recent.get(key);
    if (cached && Date.now() - cached.at < 900 && cached.result.allowed)
      return cached.result;
    try {
      let token = "";
      if (window.PLX_SB) {
        const session = await window.PLX_SB.auth.getSession();
        token = session.data?.session?.access_token || "";
      }
      const response = await fetch(URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          apikey: KEY,
          ...(token ? { Authorization: "Bearer " + token } : {}),
        },
        body: JSON.stringify({ action, route }),
      });
      const result = await response.json().catch(() => ({ allowed: response.ok }));
      recent.set(key, { at: Date.now(), result });
      return result;
    } catch (_) {
      return { allowed: true, state: "client_fail_open" };
    }
  };

  document.addEventListener(
    "submit",
    async (event) => {
      const form = event.target;
      if (!form.matches?.('[data-plx-form="signup"]')) return;
      if (form.dataset.plxGuardOk === "true") {
        delete form.dataset.plxGuardOk;
        return;
      }
      event.preventDefault();
      event.stopImmediatePropagation();
      const submit = form.querySelector('button[type="submit"]');
      if (submit) submit.disabled = true;
      const result = await window.PowerLuxGuard("signup_check", "/myplx/signup");
      if (submit) submit.disabled = false;
      if (result.allowed !== false) {
        form.dataset.plxGuardOk = "true";
        form.requestSubmit();
        return;
      }
      const box = document.getElementById("plxAuthMsg");
      if (box)
        box.innerHTML =
          '<div class="plx-msg">Zu viele Versuche. Bitte kurz warten und erneut versuchen.</div>';
    },
    true,
  );
})();
