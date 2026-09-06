(() => {
  'use strict';
  const URL = 'https://fgkowgpauqexcwwtrxyd.supabase.co';
  const KEY = 'sb_publishable_EsHCY_P-NxhOMNHRQCZqnw_nPPoCjqr';
  if (!window.supabase?.createClient) return;
  window.PLX_SB = window.supabase.createClient(URL, KEY, {
    auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
  });
  window.POWERLUX_RUNTIME = {
    supabaseUrl: URL,
    discoveryUrl: URL + '/functions/v1/powerlux-discovery',
    intakeUrl: URL + '/functions/v1/powerlux-revenue-intake',
    contentEngineUrl: URL + '/functions/v1/powerlux-content-engine',
    version: 'canonical-git-2026-09-06'
  };
})();