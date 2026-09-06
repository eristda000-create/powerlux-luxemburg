(()=>{
'use strict';
const TXT={
 de:{title:'RADAR NAME / NICKNAME',desc:'Dieser Name erscheint über deinem blauen Radar-Punkt. Du musst keinen echten Namen verwenden.',empty:'Noch kein eigener Nickname – aktuell erscheint ein neutraler PLX-Alias.',ph:'z. B. SeanG, IronFox, LuxPuller',save:'RADAR-NAMEN SPEICHERN',saved:'✓ Radar-Name gespeichert'},
 fr:{title:'NOM RADAR / PSEUDO',desc:'Ce nom apparaît au-dessus de ton point bleu. Tu n’es pas obligé d’utiliser ton vrai nom.',empty:'Aucun pseudo personnel – un alias PLX neutre est affiché.',ph:'ex. IronFox, LuxPuller',save:'ENREGISTRER LE NOM RADAR',saved:'✓ Nom Radar enregistré'},
 en:{title:'RADAR NAME / NICKNAME',desc:'This name appears above your blue radar signal. You do not have to use your real name.',empty:'No custom nickname yet – a neutral PLX alias is shown.',ph:'e.g. IronFox, LuxPuller',save:'SAVE RADAR NAME',saved:'✓ Radar name saved'}
};
let lastUid='',current='',busy=false;
function lang(){const v=(localStorage.getItem('plxLang')||document.documentElement.lang||'de').toLowerCase();return v.startsWith('fr')?'fr':v.startsWith('en')?'en':'de'}
function x(k){return TXT[lang()][k]||TXT.de[k]||k}
function esc(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
async function getState(){const sb=window.PLX_SB;if(!sb)return null;const g=await sb.auth.getSession();const s=g.data.session;if(!s)return null;if(s.user.id!==lastUid){lastUid=s.user.id;const p=await sb.from('profiles').select('age_group,radar_name').eq('id',s.user.id).maybeSingle();if(p.data?.age_group!=='18plus')return null;current=p.data?.radar_name||'';}return {sb,s};}
async function mount(){if(busy)return;busy=true;try{const st=await getState(),m=document.getElementById('plxAccountMount');if(!m||!st)return;let box=m.querySelector('[data-plx-radar-name]');if(!box){box=document.createElement('div');box.dataset.plxRadarName='1';box.className='plx-radar-name-card';m.appendChild(box);}if(document.activeElement?.closest?.('[data-plx-radar-name]'))return;box.innerHTML='<div class="hud-eyebrow">MY PLX // IDENTITY</div><h4>'+x('title')+'</h4><p>'+x('desc')+'</p>'+(current?'':'<small>'+x('empty')+'</small>')+'<form data-plx-radar-name-form><input name="radar_name" minlength="2" maxlength="24" required placeholder="'+esc(x('ph'))+'" value="'+esc(current)+'"><button class="action" type="submit">'+x('save')+'</button></form><div class="plx-radar-name-msg" aria-live="polite"></div>';}finally{busy=false;}}
document.addEventListener('submit',async e=>{const f=e.target.closest?.('[data-plx-radar-name-form]');if(!f)return;e.preventDefault();const st=await getState();if(!st)return;const v=String(new FormData(f).get('radar_name')||'').trim(),b=f.querySelector('button');b.disabled=true;const r=await st.sb.rpc('set_radar_name',{p_radar_name:v});b.disabled=false;const msg=f.parentElement.querySelector('.plx-radar-name-msg');if(r.error){msg.textContent=r.error.message;return}current=r.data||v;msg.textContent=x('saved');setTimeout(mount,250);});
setInterval(mount,700);document.addEventListener('visibilitychange',()=>{if(!document.hidden)mount()});
})();

