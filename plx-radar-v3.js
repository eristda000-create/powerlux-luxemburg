(() => {
  "use strict";
  const STYLE = `
.plx2-radar-home{background:#02090d!important}.plx-realmap{position:absolute;inset:0;z-index:0;overflow:hidden;background:#02090d}.plx-realmap.home{opacity:.36;pointer-events:none;filter:saturate(.48) contrast(1.12) brightness(.72)}.plx2-radar-home:before{z-index:2!important;pointer-events:none}.plx2-radar-home:after{z-index:3!important;pointer-events:none}.plx2-radar-home .plx2-center,.plx2-radar-home .plx2-signal,.plx2-radar-home .plx2-empty{z-index:6}.plx-powermap-main .plx2-signal{display:block}.plx-powermap-main .plx2-signal .plx2-signal-label{display:none!important}.plx2-map-tag{position:absolute;left:14px;bottom:11px;z-index:5;padding:5px 7px;border:1px solid rgba(24,199,255,.20);background:rgba(2,8,11,.74);color:#7ca4b1;font:800 8px/1 var(--fontD);letter-spacing:.12em;text-transform:uppercase;pointer-events:none}.plx2-map-credit{position:absolute;right:9px;bottom:8px;z-index:5;color:rgba(190,218,225,.56);font:700 7px/1 var(--fontD);letter-spacing:.04em;pointer-events:none}.plx-map-shell.explore{margin-top:18px}.plx-map-shell.explore .plx-realmap{position:relative;inset:auto;height:430px;z-index:0;opacity:.94;filter:saturate(.58) contrast(1.08) brightness(.78)}.plx-map-shell.explore .plx-map-head{position:relative;z-index:4}.plx-map-credit-detail{padding:7px 12px;border-top:1px solid rgba(24,199,255,.10);color:#587985;font:700 8px/1 var(--fontD);letter-spacing:.07em;text-transform:uppercase}.plx-map-pin{position:relative;width:15px;height:15px;border-radius:50%;background:#35e3a8;box-shadow:0 0 8px #35e3a8,0 0 20px rgba(53,227,168,.42);cursor:pointer}.plx-map-pin.event{background:#d67b30;border-radius:2px;transform:rotate(45deg);box-shadow:0 0 8px #d67b30}.plx-map-pin.challenge{background:#f3c85d;border-radius:2px;transform:rotate(45deg);box-shadow:0 0 8px #f3c85d}.plx-map-pin.talent{background:#19b6f1;box-shadow:0 0 8px #19b6f1}.plx-map-pin.selected{outline:2px solid #fff;outline-offset:5px}.plx-map-pin-label{position:absolute;left:50%;bottom:22px;transform:translateX(-50%);width:max-content;max-width:180px;padding:4px 7px;border:1px solid rgba(24,199,255,.28);background:rgba(2,8,11,.90);color:#e8fbff;font:800 9px/1.2 var(--fontD);letter-spacing:.05em;text-transform:uppercase;white-space:nowrap}.plx-map-pin-label small{display:block;color:#35e3a8;font-size:7px;margin-bottom:2px}.maplibregl-canvas{outline:none}.maplibregl-ctrl-bottom-left,.maplibregl-ctrl-bottom-right{display:none!important}@media(max-width:700px){.plx-realmap.home{opacity:.33}.plx-map-shell.explore .plx-realmap{height:360px}.plx-map-pin-label{font-size:8px;max-width:130px}}

.plx-powermap-main .plx2-signal.associate .plx2-signal-label{display:block!important;border-color:rgba(53,227,168,.7);z-index:14}
.plx2-signal.associate{z-index:12!important}.plx2-signal.associate:before,.plx2-signal.associate:after{content:"";position:absolute;left:50%;top:50%;width:30px;height:30px;border:1px solid rgba(53,227,168,.88);border-radius:50%;transform:translate(-50%,-50%);pointer-events:none;animation:plxAssociateLoop 2.2s ease-out infinite}.plx2-signal.associate:after{width:46px;height:46px;animation-delay:1.1s}
.plx-map-pin{width:17px!important;height:17px!important;border:2px solid rgba(225,255,247,.78);box-sizing:border-box}
.plx-map-pin:after{content:"";position:absolute;inset:-12px;border-radius:50%;cursor:pointer}
.plx-map-pin.associate{width:21px!important;height:21px!important;border:2px solid #dffff4;box-shadow:0 0 10px #35e3a8,0 0 30px rgba(53,227,168,.7)!important;z-index:12}
.plx-map-pin.associate:before,.plx-map-pin.associate:after{content:"";position:absolute;left:50%;top:50%;border:1px solid rgba(53,227,168,.88);border-radius:50%;transform:translate(-50%,-50%);pointer-events:none;animation:plxAssociateLoop 2.2s ease-out infinite}
.plx-map-pin.associate:before{width:34px;height:34px}.plx-map-pin.associate:after{width:52px;height:52px;animation-delay:1.1s}
.plx-map-pin.associate .plx-map-pin-label{display:block!important;border-color:rgba(53,227,168,.7);box-shadow:0 0 22px rgba(53,227,168,.15);z-index:14}
@keyframes plxAssociateLoop{0%{opacity:.95;transform:translate(-50%,-50%) scale(.72)}78%,100%{opacity:0;transform:translate(-50%,-50%) scale(1.18)}}
.plx2-shell{margin-top:26px;max-width:900px;border:1px solid rgba(24,199,255,.36);background:linear-gradient(180deg,rgba(4,20,28,.92),rgba(2,8,11,.94));clip-path:polygon(14px 0,100% 0,100% calc(100% - 14px),calc(100% - 14px) 100%,0 100%,0 14px);overflow:hidden;box-shadow:inset 0 0 45px rgba(25,182,241,.025)}
.plx2-head{display:flex;justify-content:space-between;gap:18px;align-items:flex-start;padding:19px 21px;border-bottom:1px solid rgba(24,199,255,.17)}.plx2-head small{display:block;color:#628493;font:800 10px/1 var(--fontD);letter-spacing:.17em;text-transform:uppercase}.plx2-head h3{margin:5px 0 0;font:900 34px/1 var(--fontD);text-transform:uppercase}.plx2-mode{display:flex;gap:7px;flex-wrap:wrap;justify-content:flex-end}.plx2-pill{padding:7px 9px;border:1px solid rgba(24,199,255,.25);background:rgba(2,12,17,.76);color:#8caab7;font:800 9px/1 var(--fontD);letter-spacing:.11em;text-transform:uppercase}.plx2-pill.live{color:#dbfff6;border-color:rgba(53,227,168,.38)}
.plx2-layers{display:flex;gap:0;overflow:auto;border-bottom:1px solid rgba(24,199,255,.13);scrollbar-width:none}.plx2-layer{flex:0 0 auto;min-width:118px;padding:12px 13px;border:0;border-bottom:2px solid transparent;background:rgba(2,9,13,.46);color:#688693;font:800 11px/1 var(--fontD);letter-spacing:.08em;text-transform:uppercase}.plx2-layer.active{color:#fff;border-bottom-color:var(--cyan);background:linear-gradient(180deg,rgba(25,182,241,.09),transparent)}.plx2-layer.locked:after{content:'  LOCK';font-size:8px;color:#708995}
.plx2-radar{position:relative;height:360px;overflow:hidden;background:radial-gradient(circle at 50% 50%,rgba(0,135,184,.14),transparent 61%),repeating-radial-gradient(circle at 50% 50%,rgba(24,199,255,.18) 0 1px,transparent 1px 57px);isolation:isolate}.plx2-radar:before{content:'';position:absolute;inset:-50%;background:conic-gradient(from 0deg,transparent 0 320deg,rgba(25,182,241,.03) 327deg,rgba(25,182,241,.25) 357deg,transparent 360deg);animation:plx2Sweep 5.2s linear infinite;transform-origin:center}.plx2-radar:after{content:'';position:absolute;left:50%;top:0;bottom:0;width:1px;background:rgba(24,199,255,.10);box-shadow:-180px 0 rgba(24,199,255,.05),180px 0 rgba(24,199,255,.05)}@keyframes plx2Sweep{to{transform:rotate(360deg)}}.plx2-center{position:absolute;left:50%;top:50%;width:10px;height:10px;border-radius:50%;transform:translate(-50%,-50%);background:#efffff;box-shadow:0 0 16px var(--cyan);z-index:5}
.plx2-signal{position:absolute;width:13px;height:13px;border:0;border-radius:50%;transform:translate(-50%,-50%);z-index:6;cursor:pointer}.plx2-signal.talent{background:#19b6f1;box-shadow:0 0 9px #19b6f1,0 0 25px rgba(25,182,241,.55)}.plx2-signal.place{background:#35e3a8;box-shadow:0 0 9px #35e3a8,0 0 23px rgba(53,227,168,.45)}.plx2-signal.challenge{background:#f3c85d;box-shadow:0 0 10px #f3c85d,0 0 25px rgba(243,200,93,.45);border-radius:2px;transform:translate(-50%,-50%) rotate(45deg)}.plx2-signal.event{background:#d67b30;box-shadow:0 0 10px #d67b30,0 0 24px rgba(214,123,48,.45);clip-path:polygon(50% 0,100% 50%,50% 100%,0 50%)}.plx2-signal:focus-visible{outline:1px solid #fff;outline-offset:5px}
.plx2-empty{position:absolute;left:50%;top:54%;transform:translate(-50%,-50%);z-index:4;width:min(520px,82%);text-align:center;color:#7895a1;font:800 11px/1.55 var(--fontD);letter-spacing:.08em;text-transform:uppercase}.plx2-empty b{display:block;color:#d8f7ff;font-size:16px;margin-bottom:7px}
.plx2-detail{min-height:64px;padding:13px 18px;border-top:1px solid rgba(24,199,255,.12);background:rgba(3,15,20,.67)}.plx2-detail strong{font:900 18px/1 var(--fontD);text-transform:uppercase}.plx2-detail span{display:block;margin-top:5px;color:#7996a1;font-size:11px;line-height:1.45}.plx2-detail a{color:var(--cyan);text-decoration:none}
.plx2-controls{display:flex;gap:7px;align-items:center;flex-wrap:wrap;padding:14px 18px;border-top:1px solid rgba(24,199,255,.13)}.plx2-radius,.plx2-sound{padding:9px 10px;border:1px solid rgba(24,199,255,.22);background:rgba(3,14,18,.75);color:#718d99;font:800 10px/1 var(--fontD);letter-spacing:.07em;text-transform:uppercase}.plx2-radius.active,.plx2-sound.active{color:#fff;border-color:var(--cyan);box-shadow:inset 3px 0 0 var(--cyan)}.plx2-scan{margin-left:auto}.plx2-actions{display:grid;grid-template-columns:1fr 1fr;gap:8px;padding:0 18px 15px}.plx2-actions .action{width:100%;min-width:0}.plx2-note{padding:0 18px 17px;color:#607f8c;font-size:11px;line-height:1.5}.plx2-legend{display:flex;gap:13px;flex-wrap:wrap;padding:10px 18px;border-top:1px solid rgba(24,199,255,.11);color:#6d8a96;font:800 9px/1 var(--fontD);letter-spacing:.08em;text-transform:uppercase}.plx2-legend i{display:inline-block;width:7px;height:7px;border-radius:50%;margin-right:5px}.plx2-legend .t{background:#19b6f1}.plx2-legend .p{background:#35e3a8}.plx2-legend .c{background:#f3c85d;border-radius:1px}.plx2-legend .e{background:#d67b30;border-radius:1px}
.plx2-modal{position:fixed;inset:0;z-index:1300;display:grid;place-items:start center;overflow-y:auto;overscroll-behavior:contain;padding:max(12px,env(safe-area-inset-top)) 12px max(12px,env(safe-area-inset-bottom));background:rgba(0,4,6,.86);backdrop-filter:blur(7px)}.plx2-modal-box{width:min(680px,100%);max-height:none;overflow:visible;margin:auto;border:1px solid rgba(24,199,255,.45);background:#041017;padding:22px}.plx2-modal-top{display:flex;justify-content:space-between;gap:16px;align-items:start}.plx2-modal-top h3{margin:7px 0 0;font:900 32px/1 var(--fontD);text-transform:uppercase}.plx2-close{width:42px;height:42px;border:1px solid rgba(24,199,255,.28);background:transparent;color:#fff;font-size:22px}.plx2-form{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:18px}.plx2-field{display:grid;gap:6px;color:#72909c;font:800 10px/1 var(--fontD);letter-spacing:.09em;text-transform:uppercase}.plx2-field.full{grid-column:1/-1}.plx2-field input,.plx2-field select,.plx2-field textarea{width:100%;padding:12px;border:1px solid rgba(24,199,255,.22);background:#02090c;color:#fff}.plx2-field textarea{min-height:96px;resize:vertical}.plx2-check{display:flex;gap:9px;align-items:flex-start;color:#8ba5af;font-size:11px;line-height:1.45}.plx2-check input{margin-top:2px}.plx2-location{padding:12px;border:1px dashed rgba(24,199,255,.28);color:#7895a1;font-size:11px;line-height:1.5}.plx2-location b{color:#d7f7ff}.plx2-toast{position:fixed;z-index:1400;left:50%;bottom:88px;transform:translateX(-50%);width:min(560px,calc(100vw - 28px));padding:13px 15px;border:1px solid rgba(24,199,255,.35);background:#041017;color:#d9f6ff;font-size:12px;line-height:1.45;box-shadow:0 12px 35px rgba(0,0,0,.35)}

.plx2-radar-home{background:radial-gradient(circle at 50% 50%,rgba(0,135,184,.12),transparent 61%),repeating-radial-gradient(circle at 50% 50%,rgba(24,199,255,.17) 0 1px,transparent 1px 57px),#02090d}.plx2-softmap{position:absolute;inset:0;width:100%;height:100%;z-index:0;opacity:.34;pointer-events:none;filter:drop-shadow(0 0 4px rgba(25,182,241,.16))}.plx2-softmap .road{fill:none;stroke:rgba(220,244,249,.26);stroke-width:1.4}.plx2-softmap .road.main{stroke:rgba(220,244,249,.42);stroke-width:2}.plx2-softmap .block{fill:rgba(25,182,241,.022);stroke:rgba(150,205,219,.12);stroke-width:1}.plx2-softmap .water{fill:none;stroke:rgba(25,182,241,.20);stroke-width:3}.plx2-softmap-label{position:absolute;left:14px;bottom:12px;z-index:3;padding:5px 7px;border:1px solid rgba(24,199,255,.18);background:rgba(2,8,11,.62);color:#6f95a2;font:800 8px/1 var(--fontD);letter-spacing:.12em;text-transform:uppercase;pointer-events:none}.plx-map-shell.explore{margin-top:18px}.plx-map-shell.explore .plx-map{max-height:430px}.plx-map-shell.explore .plx-map-head strong:after{content:' // EXPLORE';color:#19b6f1;font-size:10px;margin-left:7px}.plx-map-shell.explore .plx-map-head span{color:#9edbe8}@media(max-width:700px){.plx2-softmap{opacity:.29}.plx-map-shell.explore .plx-map{max-height:360px}}
@media(max-width:700px){.plx2-radar{height:295px}.plx2-head{padding:15px}.plx2-head h3{font-size:29px}.plx2-mode{justify-content:flex-start}.plx2-head{flex-direction:column}.plx2-controls{display:grid;grid-template-columns:repeat(4,1fr)}.plx2-scan,.plx2-sound{grid-column:1/-1;margin:0}.plx2-actions{grid-template-columns:1fr}.plx2-form{grid-template-columns:1fr}.plx2-field.full{grid-column:auto}}
`;
  const D = {
    de: {
      eyebrow: "POWERMAP® // SPORT NETWORK",
      title: "POWERMAP®",
      guest: "GUEST MODE",
      member: "PLX MEMBER",
      public: "PUBLIC NETWORK",
      people: "ATHLETES",
      places: "CLUBS & GYMS",
      challenges: "CHALLENGES",
      events: "EVENTS",
      all: "ALL SIGNALS",
      scanPublic: "SPORT IN MEINER NÄHE",
      scanMember: "SCAN NETWORK",
      locating: "LOCATING…",
      scanning: "SCANNING…",
      sound: "SONAR",
      report: "TALENT + RESULTAT MELDEN",
      post: "CHALLENGE POSTEN",
      guestEmpty:
        "Öffentliche Clubs, Trainingsorte, Challenges und Events bleiben sichtbar. Für Talent-Signale brauchst du einen kostenlosen PLX Account.",
      noSignals: "Keine Signale in diesem Filter.",
      noChallenges: "Noch keine von PowerLux freigegebene Challenge live.",
      private:
        "Talent-Signale zeigen keine exakte Position. Challenges werden erst nach PowerLux Review veröffentlicht.",
      loginNeeded: "Für diese Funktion brauchst du einen PLX Account.",
      adultNeeded:
        "Challenges können in dieser Version nur von 18+ PLX Accounts eingereicht werden.",
      locationOptional:
        "Standort freiwillig · ohne Freigabe siehst du trotzdem das öffentliche Netzwerk.",
      locationOn:
        "Standort aktiv · Distanzen werden lokal auf deinem Gerät berechnet.",
      talentLocked: "TALENT SIGNALS // LOGIN REQUIRED",
      detailPublic: "Öffentlich verifizierter Club-/Trainingsort-Eintrag",
      detailChallenge: "POWERLUX REVIEWED CHALLENGE",
      detailEvent: "VERIFIED EVENT SOURCE",
      detailTalent: "ANONYMOUS PLX TALENT SIGNAL",
      reportTitle: "Talent + Resultat melden",
      reportSub:
        "Resultate gehen zuerst an PowerLux Review. Erst bestätigte Angaben können später in Results, Rankings oder Talent-Profilen erscheinen.",
      self: "Ich melde mich selbst",
      other: "Ich melde einen Athleten",
      athlete: "Name des Athleten",
      sport: "Sportart",
      result: "Resultat / Leistung",
      eventName: "Event / Wettkampf",
      date: "Datum",
      source: "Quelle / Link",
      instagram: "Instagram (optional)",
      consent:
        "Ich bestätige, dass die Angaben korrekt sind und bei einer anderen Person aus öffentlich belegbaren Sportresultaten stammen.",
      submitReport: "ZUM REVIEW EINREICHEN",
      reportOk: "Eingereicht. Status: PENDING POWERLUX REVIEW.",
      challengeTitle: "Challenge posten",
      challengeSub:
        "PLX Challenges sind Community-Aktivitäten. Sie werden vor Veröffentlichung geprüft.",
      challengeName: "Challenge Titel",
      description: "Beschreibung / Regeln",
      location: "Ort / Treffpunkt",
      start: "Startdatum & Uhrzeit",
      visibility: "Sichtbarkeit",
      publicVis: "Öffentlich",
      plxVis: "Nur PLX Members",
      max: "Teilnehmerlimit (optional)",
      useLocation: "RADAR-POSITION VOM GERÄT ÜBERNEHMEN",
      locationReady: "Ungefähre Radar-Position gespeichert",
      locationNeed:
        "Für eine Radar-Challenge brauchen wir eine ungefähre Position. Verwende nur einen öffentlichen Treffpunkt / Trainingsort.",
      safety:
        "Ich bestätige: öffentlicher/sicherer Treffpunkt, klare Regeln und keine gefährliche oder illegale Challenge.",
      submitChallenge: "CHALLENGE ZUM REVIEW EINREICHEN",
      challengeOk:
        "Challenge eingereicht. Sie erscheint erst nach PowerLux Review.",
      close: "Schließen",
      km: "km",
      sourceLink: "Quelle öffnen",
      loginCta: "ANMELDEN / KOSTENLOSER ACCOUNT",
      activate: "PEOPLE RADAR AKTIVIEREN",
      foundOne: "1 PLX MEMBER IN DER NÄHE // ALLE SPORTARTEN",
      foundMany: "PLX MEMBERS IN DER NÄHE // ALLE SPORTARTEN",
      nonePeople:
        "Keine PLX Member im aktuellen Radius. Standort wurde aktualisiert.",
    },
    fr: {
      eyebrow: "POWERMAP® // RÉSEAU SPORTIF",
      title: "POWERMAP®",
      guest: "MODE INVITÉ",
      member: "MEMBRE PLX",
      public: "RÉSEAU PUBLIC",
      people: "ATHLÈTES",
      places: "CLUBS & SALLES",
      challenges: "CHALLENGES",
      events: "ÉVÉNEMENTS",
      all: "TOUS LES SIGNAUX",
      scanPublic: "SPORT AUTOUR DE MOI",
      scanMember: "SCANNER LE RÉSEAU",
      locating: "LOCALISATION…",
      scanning: "SCAN…",
      sound: "SONAR",
      report: "SIGNALER TALENT + RÉSULTAT",
      post: "PUBLIER UN CHALLENGE",
      guestEmpty:
        "Les clubs, lieux d’entraînement, challenges et événements publics restent visibles. Un compte PLX gratuit est requis pour les signaux talent.",
      noSignals: "Aucun signal pour ce filtre.",
      noChallenges:
        "Aucun challenge validé par PowerLux n’est encore en ligne.",
      private:
        "Les signaux talent ne montrent jamais la position exacte. Les challenges sont publiés uniquement après validation PowerLux.",
      loginNeeded: "Un compte PLX est requis pour cette fonction.",
      adultNeeded:
        "Dans cette version, les challenges peuvent être soumis uniquement par des comptes PLX 18+.",
      locationOptional:
        "Localisation facultative · le réseau public reste visible sans autorisation.",
      locationOn:
        "Localisation active · les distances sont calculées localement sur votre appareil.",
      talentLocked: "SIGNAUX TALENT // CONNEXION REQUISE",
      detailPublic: "Entrée club / lieu d’entraînement publique vérifiée",
      detailChallenge: "CHALLENGE VALIDÉ PAR POWERLUX",
      detailEvent: "SOURCE ÉVÉNEMENT VÉRIFIÉE",
      detailTalent: "SIGNAL TALENT PLX ANONYME",
      reportTitle: "Signaler talent + résultat",
      reportSub:
        "Les résultats passent d’abord par la validation PowerLux. Seules les informations confirmées pourront apparaître dans Results, Rankings ou les profils talent.",
      self: "Je me signale moi-même",
      other: "Je signale un athlète",
      athlete: "Nom de l’athlète",
      sport: "Sport",
      result: "Résultat / performance",
      eventName: "Événement / compétition",
      date: "Date",
      source: "Source / lien",
      instagram: "Instagram (optionnel)",
      consent:
        "Je confirme que les informations sont correctes et, si je signale une autre personne, qu’elles proviennent de résultats sportifs publiquement vérifiables.",
      submitReport: "ENVOYER POUR VALIDATION",
      reportOk: "Envoyé. Statut : PENDING POWERLUX REVIEW.",
      challengeTitle: "Publier un challenge",
      challengeSub:
        "Les PLX Challenges sont des activités communautaires. Ils sont vérifiés avant publication.",
      challengeName: "Titre du challenge",
      description: "Description / règles",
      location: "Lieu / point de rendez-vous",
      start: "Date et heure de début",
      visibility: "Visibilité",
      publicVis: "Public",
      plxVis: "Membres PLX uniquement",
      max: "Limite de participants (optionnel)",
      useLocation: "UTILISER LA POSITION RADAR DE L’APPAREIL",
      locationReady: "Position radar approximative enregistrée",
      locationNeed:
        "Une position approximative est nécessaire pour le radar. Utilisez uniquement un lieu public / d’entraînement.",
      safety:
        "Je confirme : lieu public/sûr, règles claires et aucun challenge dangereux ou illégal.",
      submitChallenge: "ENVOYER LE CHALLENGE POUR VALIDATION",
      challengeOk:
        "Challenge envoyé. Il apparaîtra uniquement après validation PowerLux.",
      close: "Fermer",
      km: "km",
      sourceLink: "Ouvrir la source",
      loginCta: "CONNEXION / COMPTE GRATUIT",
      activate: "ACTIVER LE PEOPLE RADAR",
      foundOne: "1 MEMBRE PLX À PROXIMITÉ // TOUS LES SPORTS",
      foundMany: "MEMBRES PLX À PROXIMITÉ // TOUS LES SPORTS",
      nonePeople:
        "Aucun membre PLX dans le rayon actuel. Position mise à jour.",
    },
    en: {
      eyebrow: "POWERMAP® // SPORT NETWORK",
      title: "POWERMAP®",
      guest: "GUEST MODE",
      member: "PLX MEMBER",
      public: "PUBLIC NETWORK",
      people: "ATHLETES",
      places: "CLUBS & GYMS",
      challenges: "CHALLENGES",
      events: "EVENTS",
      all: "ALL SIGNALS",
      scanPublic: "SPORT NEAR ME",
      scanMember: "SCAN NETWORK",
      locating: "LOCATING…",
      scanning: "SCANNING…",
      sound: "SONAR",
      report: "REPORT TALENT + RESULT",
      post: "POST CHALLENGE",
      guestEmpty:
        "Public clubs, training places, challenges and events remain visible. A free PLX account is required for talent signals.",
      noSignals: "No signals in this filter.",
      noChallenges: "No PowerLux-approved challenge is live yet.",
      private:
        "Talent signals never reveal an exact position. Challenges are published only after PowerLux review.",
      loginNeeded: "You need a PLX account for this function.",
      adultNeeded:
        "In this version, challenges can only be submitted by 18+ PLX accounts.",
      locationOptional:
        "Location optional · the public network remains visible without permission.",
      locationOn:
        "Location active · distances are calculated locally on your device.",
      talentLocked: "TALENT SIGNALS // LOGIN REQUIRED",
      detailPublic: "Verified public club / training place entry",
      detailChallenge: "POWERLUX REVIEWED CHALLENGE",
      detailEvent: "VERIFIED EVENT SOURCE",
      detailTalent: "ANONYMOUS PLX TALENT SIGNAL",
      reportTitle: "Report talent + result",
      reportSub:
        "Results go to PowerLux review first. Only confirmed information may later appear in Results, Rankings or talent profiles.",
      self: "I am reporting myself",
      other: "I am reporting an athlete",
      athlete: "Athlete name",
      sport: "Sport",
      result: "Result / performance",
      eventName: "Event / competition",
      date: "Date",
      source: "Source / link",
      instagram: "Instagram (optional)",
      consent:
        "I confirm the information is accurate and, when reporting another person, comes from publicly verifiable sports results.",
      submitReport: "SUBMIT FOR REVIEW",
      reportOk: "Submitted. Status: PENDING POWERLUX REVIEW.",
      challengeTitle: "Post a challenge",
      challengeSub:
        "PLX Challenges are community activities. They are reviewed before publication.",
      challengeName: "Challenge title",
      description: "Description / rules",
      location: "Location / meeting point",
      start: "Start date & time",
      visibility: "Visibility",
      publicVis: "Public",
      plxVis: "PLX Members only",
      max: "Participant limit (optional)",
      useLocation: "USE DEVICE RADAR POSITION",
      locationReady: "Approximate radar position saved",
      locationNeed:
        "An approximate position is required for a radar challenge. Use only a public venue / training location.",
      safety:
        "I confirm: public/safe meeting point, clear rules and no dangerous or illegal challenge.",
      submitChallenge: "SUBMIT CHALLENGE FOR REVIEW",
      challengeOk:
        "Challenge submitted. It will appear only after PowerLux review.",
      close: "Close",
      km: "km",
      sourceLink: "Open source",
      loginCta: "LOGIN / FREE ACCOUNT",
      activate: "ENABLE PEOPLE RADAR",
      foundOne: "1 PLX MEMBER NEARBY // ALL SPORTS",
      foundMany: "PLX MEMBERS NEARBY // ALL SPORTS",
      nonePeople: "No PLX member in the current radius. Location updated.",
    },
  };
  const STATIC_PLACES = [
    {
      id: "red-lion-massen",
      type: "place",
      name: "Red Lion Sportsclub",
      sport: "Fitness · Powerlifting · Strength",
      label: "Massen Shopping Center · Wemperhardt",
      lat: 50.149,
      lng: 6.057,
      url: "https://www.red-lion.lu/en",
    },
    {
      id: "ladies-first-marnach",
      type: "place",
      name: "Ladies First Sportsclub",
      sport: "Fitness · Functional Training",
      label: "Nordstrooss Shopping Mile · Marnach",
      lat: 50.051,
      lng: 6.0727,
      url: "https://www.ladiesfirst.lu/",
    },
    {
      id: "luxfit-marnach",
      type: "place",
      name: "Luxfit Marnach",
      sport: "Fitness · Personal Training",
      label: "Marnach",
      lat: 50.0525,
      lng: 6.071,
      url: "https://luxfit.com/en",
    },
    {
      id: "cad",
      type: "place",
      name: "CAD Power asbl",
      sport: "Powerlifting · Weightlifting",
      label: "Dudelange",
      lat: 49.4806,
      lng: 6.0875,
      url: "https://pwf.lu/pwfl/clubs-membres/",
    },
    {
      id: "hamm",
      type: "place",
      name: "SC Hamm 1970 asbl",
      sport: "Powerlifting · Weightlifting",
      label: "Luxembourg-Hamm",
      lat: 49.5986,
      lng: 6.161,
      url: "https://pwf.lu/pwfl/clubs-membres/",
    },
    {
      id: "silverbacks",
      type: "place",
      name: "Silverbacks asbl",
      sport: "Powerlifting",
      label: "Koerich",
      lat: 49.67,
      lng: 5.95,
      url: "https://pwf.lu/pwfl/clubs-membres/",
    },
    {
      id: "acs",
      type: "place",
      featured: true,
      name: "Armwrestling Club Strassen",
      sport: "Armwrestling",
      label: "Strassen",
      lat: 49.62,
      lng: 6.073,
      url: "https://armwrestlingclubstrassen.com/",
    },
    {
      id: "grizzly",
      type: "place",
      featured: true,
      name: "Grizzly of Luxembourg",
      sport: "Armwrestling",
      label: "Munsbach",
      lat: 49.633,
      lng: 6.267,
      url: "https://armwrestlingclubstrassen.com/",
    },
    {
      id: "bcd",
      type: "place",
      name: "Boxing Club Differdange",
      sport: "Boxing",
      label: "Differdange",
      lat: 49.523,
      lng: 5.891,
      url: "https://www.boxe.lu/fr/clubs.html",
    },
    {
      id: "atc-gym",
      type: "place",
      name: "ATC Sports Gym",
      sport: "Fitness · Powerlifting · Strongman",
      label: "Windhof · public gym",
      lat: 49.65,
      lng: 5.96,
      url: "https://www.atcsports.lu/",
    },
    {
      id: "force-fitness",
      type: "place",
      name: "Force Fitness Luxembourg",
      sport: "Fitness · Personal Training",
      label: "Schouweiler · public gym",
      lat: 49.58,
      lng: 5.96,
      url: "https://www.forcefitness-luxembourg.lu/",
    },
    {
      id: "fitness-expert",
      type: "place",
      name: "Fitness Expert Luxembourg",
      sport: "Fitness · Personal Training",
      label: "Luxembourg-Ville · public gym",
      lat: 49.61,
      lng: 6.13,
      url: "https://www.fitness-expert-luxembourg.com/",
    },
  ];

  let nearbyPlaces = [],
    nearbyFetch = { at: 0, lat: null, lng: null, radius: 0 },
    nearbyStatus = "";
  const OVERPASS_ENDPOINTS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
  ];
  function normName(s) {
    return String(s || "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9]+/g, " ")
      .trim();
  }
  function placeKey(x) {
    const lat = Number(x?.lat),
      lng = Number(x?.lng);
    return [
      normName(x?.name) || String(x?.id || ""),
      Number.isFinite(lat) ? lat.toFixed(3) : "",
      Number.isFinite(lng) ? lng.toFixed(3) : "",
    ].join("|");
  }
  function allPlaces() {
    const seen = new Set(),
      accepted = [];
    return [...STATIC_PLACES, ...nearbyPlaces].filter((x) => {
      const k = placeKey(x),
        name = normName(x?.name),
        lat = Number(x?.lat),
        lng = Number(x?.lng);
      const duplicate = accepted.some((old) => {
        if (
          !Number.isFinite(lat) ||
          !Number.isFinite(lng) ||
          !Number.isFinite(Number(old?.lat)) ||
          !Number.isFinite(Number(old?.lng))
        )
          return false;
        const distance = km(
          { lat, lng },
          { lat: Number(old.lat), lng: Number(old.lng) },
        );
        return (
          (name && name === normName(old?.name) && distance <= 0.35) ||
          (distance <= 0.12 && sportFamily(x) === sportFamily(old))
        );
      });
      if (
        seen.has(k) ||
        duplicate
      )
        return false;
      seen.add(k);
      accepted.push(x);
      return true;
    });
  }
  function nearbyText(n) {
    const l = language();
    return l === "fr"
      ? n + " LIEUX SPORTIFS À PROXIMITÉ"
      : l === "en"
        ? n + " SPORT PLACES NEARBY"
        : n + " SPORTORTE IN DER NÄHE";
  }
  function geoErrorText(e) {
    const l = language(),
      denied = e && e.code === 1;
    if (l === "fr")
      return denied
        ? "LOCALISATION BLOQUÉE // autorise la localisation dans le navigateur puis relance le scan."
        : "LOCALISATION INDISPONIBLE // réessaie.";
    if (l === "en")
      return denied
        ? "LOCATION BLOCKED // allow location in your browser and scan again."
        : "LOCATION UNAVAILABLE // please try again.";
    return denied
      ? "STANDORT BLOCKIERT // Standort im Browser erlauben und erneut scannen."
      : "STANDORT NICHT VERFÜGBAR // Bitte erneut versuchen.";
  }
  function prettySport(v) {
    return String(v || "")
      .split(";")
      .map((x) => x.trim())
      .filter(Boolean)
      .map((x) =>
        x.replaceAll("_", " ").replace(/\b\w/g, (c) => c.toUpperCase()),
      )
      .join(" · ");
  }
  function osmLabel(tags) {
    const martial = tags.martial_art ? prettySport(tags.martial_art) : "",
      sport = prettySport(tags.sport);
    if (martial) return "Martial Arts · " + martial;
    if (sport) return sport;
    if (tags.leisure === "fitness_centre") return "Fitness · Gym";
    if (tags.leisure === "fitness_station")
      return "Outdoor Fitness · Calisthenics";
    if (tags.leisure === "sports_centre" || tags.leisure === "sports_hall")
      return "Sports Centre";
    if (tags.leisure === "track") return "Athletics · Running";
    if (tags.leisure === "swimming_pool") return "Swimming";
    if (tags.leisure === "bowling_alley") return "Bowling · Darts";
    if (tags.leisure === "dance") return "Dance · Movement";
    if (tags.amenity === "dojo") return "Martial Arts · Dojo";
    return "Sport · Training";
  }
  function blockedFootball(tags, name) {
    const sports = String(tags.sport || "")
        .toLowerCase()
        .split(";")
        .map((x) => x.trim())
        .filter(Boolean),
      blocked = new Set(["soccer", "football", "futsal", "american_football"]);
    if (sports.length && sports.every((x) => blocked.has(x))) return true;
    return (
      /(^|\b)(football|soccer|futsal|fußball|fussball)(\b|$)/i.test(
        name || "",
      ) &&
      !/fitness|gym|boxing|martial|yoga|darts|athlet|climb|boulder|weight|powerlift|crossfit|krav|karate|judo|taekwondo|mma|wrestl/i.test(
        name || "",
      )
    );
  }
  function cacheKey(origin, r) {
    return (
      "plxSportPlacesV4:" +
      Math.round(origin.lat * 50) / 50 +
      ":" +
      Math.round(origin.lng * 50) / 50 +
      ":" +
      r
    );
  }
  function readPlaceCache(origin, r) {
    try {
      const raw = localStorage.getItem(cacheKey(origin, r));
      if (!raw) return null;
      const c = JSON.parse(raw);
      if (
        !c ||
        !Array.isArray(c.items) ||
        Date.now() - Number(c.at || 0) > 1800000
      )
        return null;
      return c;
    } catch {
      return null;
    }
  }
  function writePlaceCache(origin, r, items) {
    try {
      localStorage.setItem(
        cacheKey(origin, r),
        JSON.stringify({ at: Date.now(), items: items.slice(0, 140) }),
      );
    } catch {}
  }
  function buildSportQuery(lat, lng, R) {
    const sports =
        "martial_arts|boxing|kickboxing|karate|judo|taekwondo|aikido|muay_thai|jiu-jitsu|jiu_jitsu|wrestling|fencing|darts|athletics|running|yoga|fitness|calisthenics|weightlifting|powerlifting|climbing|gymnastics|bodybuilding|crossfit|arm_wrestling|archery|swimming|handball|volleyball|basketball|tennis|badminton|table_tennis|squash|cycling|skateboard|roller_skating|dance",
      names =
        "Basic[- ]?Fit|Fitness|Yoga|Pilates|CrossFit|Boxing|Boxclub|Kickbox|Muay|MMA|Karate|Judo|Taekwondo|Krav|Martial|Jiu|BJJ|Wrestl|Armwrest|Powerlift|Weightlift|Bodybuild|Boulder|Climb|Darts|Athlet|Running|Run Club|Laufclub|Calisthen";
    return (
      "[out:json][timeout:18];(" +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["leisure"~"^(fitness_centre|sports_centre|sports_hall|fitness_station|track|swimming_pool|bowling_alley|dance)$"];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["amenity"="dojo"];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["club"="sport"];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["association"="sport"];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["martial_art"];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["sport"~"^(' +
      sports +
      ')(;|$)",i];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["sport"]["sport"!~"(^|;)(soccer|football|futsal|american_football)(;|$)",i]["name"];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["brand"~"Basic[- ]?Fit",i];' +
      "nwr(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["name"~"' +
      names +
      '",i];' +
      "relation(around:" +
      R +
      "," +
      lat +
      "," +
      lng +
      ')["route"="fitness_trail"];' +
      ");out center tags;"
    );
  }
  async function fetchOverpass(q) {
    let last = null;
    try {
      const m = String(q).match(
        /around:(\d+),(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/,
      );
      if (m) {
        const rr = Math.max(1, Math.min(25, (Number(m[1]) - 350) / 1000));
        const guard = window.PowerLuxGuard
          ? await window.PowerLuxGuard("discovery_scan", "/powermap/discovery")
          : { allowed: true };
        if (!guard.allowed) throw new Error("PowerMap scan temporarily paused");
        const r = await fetch(
          "https://fgkowgpauqexcwwtrxyd.supabase.co/functions/v1/powerlux-discovery",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              apikey: "sb_publishable_EsHCY_P-NxhOMNHRQCZqnw_nPPoCjqr",
            },
            body: JSON.stringify({ lat: Number(m[2]), lng: Number(m[3]), radius: rr }),
          },
        );
        if (r.ok) {
          const j = await r.json();
          if (j && Array.isArray(j.places))
            return {
              elements: j.places.map((place, index) => {
                const ref = String(place.sourceRef || place.id || "powerlux-" + index),
                  parts = ref.split("/"),
                  kind = parts[0].toLowerCase(),
                  osmType = kind === "way" || kind === "w" ? "way" : kind === "relation" || kind === "r" ? "relation" : "node",
                  osmId = parts.length > 1 ? parts[parts.length - 1] : ref;
                return ({
                type: osmType,
                id: osmId,
                lat: place.lat,
                lon: place.lng,
                tags: {
                  name: place.name,
                  sport: Array.isArray(place.sports) ? place.sports.join(";") : place.category || "sport",
                  leisure: place.category === "fitness" ? "fitness_centre" : "sports_centre",
                  "addr:city": place.label || "",
                  website: place.websiteUrl || "",
                  "powerlux:associate": place.associate ? "yes" : "no",
                },
              });}),
              powerluxDiscovery: true,
              sources: j.sources || {},
            };
        }
        last = new Error("PowerLux sport API " + r.status);
      }
    } catch (e) {
      last = e;
    }
    for (const endpoint of OVERPASS_ENDPOINTS) {
      const ctrl = new AbortController(),
        timer = setTimeout(() => ctrl.abort(), 12000);
      try {
        const r = await fetch(endpoint, {
          method: "POST",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
          },
          body: "data=" + encodeURIComponent(q),
          signal: ctrl.signal,
        });
        if (!r.ok) throw new Error("Overpass " + r.status);
        const j = await r.json();
        if (j && Array.isArray(j.elements)) return j;
        throw new Error("Invalid Overpass response");
      } catch (err) {
        last = err;
      } finally {
        clearTimeout(timer);
      }
    }
    throw last || new Error("Sport data unavailable");
  }
  async function loadNearbyPlaces(p, force = false) {
    if (!p || !p.coords) return;
    const origin = { lat: p.coords.latitude, lng: p.coords.longitude },
      age = Date.now() - nearbyFetch.at,
      moved =
        nearbyFetch.lat == null
          ? 999
          : km(origin, { lat: nearbyFetch.lat, lng: nearbyFetch.lng });
    if (!force && age < 180000 && moved < 0.6 && nearbyFetch.radius >= radius)
      return;
    const cached = readPlaceCache(origin, radius);
    if (cached && (!nearbyPlaces.length || moved > 0.6)) {
      nearbyPlaces = cached.items || [];
      nearbyStatus =
        nearbyText(nearbyPlaces.filter(inRadius).length) + " · CACHE";
      nearbyFetch = {
        at: Number(cached.at || Date.now()),
        lat: origin.lat,
        lng: origin.lng,
        radius,
      };
      if (!force && Date.now() - Number(cached.at || 0) < 300000) return;
    }
    const lat = Math.round(origin.lat * 1000) / 1000,
      lng = Math.round(origin.lng * 1000) / 1000,
      R = Math.min(25300, Math.max(1400, radius * 1000 + 350)),
      query = buildSportQuery(lat, lng, R);
    try {
      const j = await fetchOverpass(query),
        list = [];
      for (const e of j.elements || []) {
        const tags = e.tags || {},
          c = e.type === "node" ? { lat: e.lat, lng: e.lon } : e.center;
        if (!c || !Number.isFinite(c.lat) || !Number.isFinite(c.lon)) continue;
        const rawName = tags.name || tags.brand || tags.operator || "",
          generic =
            tags.leisure === "fitness_station"
              ? "Outdoor Fitness"
              : tags.leisure === "track"
                ? "Athletics Track"
                : "";
        if (blockedFootball(tags, rawName)) continue;
        const name = rawName || generic;
        if (!name) continue;
        const d = km(origin, { lat: Number(c.lat), lng: Number(c.lon) });
        if (d > radius + 0.45) continue;
        list.push({
          id: "osm-" + e.type + "-" + e.id,
          type: "place",
          name,
          sport: osmLabel(tags),
          label:
            tags["addr:city"] ||
            tags["addr:place"] ||
            tags["addr:suburb"] ||
            tags["addr:town"] ||
            tags["addr:village"] ||
            tags.leisure ||
            tags.sport ||
            "Nearby",
          lat: Number(c.lat),
          lng: Number(c.lon),
          url: "https://www.openstreetmap.org/" + e.type + "/" + e.id,
          osm: true,
          featured: tags["powerlux:associate"] === "yes",
          _d: d,
        });
      }
      const seen = new Set(),
        dedup = list
          .sort((a, b) => a._d - b._d)
          .filter((x) => {
            const k = placeKey(x);
            if (seen.has(k)) return false;
            seen.add(k);
            return true;
          })
          .slice(0, 140);
      nearbyPlaces = dedup.map(({ _d, ...x }) => x);
      nearbyFetch = {
        at: Date.now(),
        lat: origin.lat,
        lng: origin.lng,
        radius,
      };
      nearbyStatus = nearbyText(nearbyPlaces.length);
      writePlaceCache(origin, radius, nearbyPlaces);
    } catch (err) {
      nearbyStatus = nearbyPlaces.length
        ? nearbyText(nearbyPlaces.filter(inRadius).length) + " · OFFLINE CACHE"
        : language() === "de"
          ? "SPORTORTE KONNTEN GERADE NICHT GELADEN WERDEN"
          : language() === "fr"
            ? "LIEUX SPORTIFS TEMPORAIREMENT INDISPONIBLES"
            : "SPORT PLACES TEMPORARILY UNAVAILABLE";
      console.warn("PLX nearby places", err);
    }
  }
  const EVENTS = [
    {
      id: "wec26",
      type: "event",
      name: "Western European Championships",
      sport: "Powerlifting",
      label: "Hall Omnisports Hamm · 16–20 Sep 2026",
      lat: 49.5986,
      lng: 6.161,
      url: "https://pwf.lu/event/western-european-championships/",
    },
  ];
  let sb = null,
    session = null,
    profile = null,
    settings = null,
    people = [],
    challenges = [],
    viewer = null,
    layer = "all",
    radius = 10,
    selected = null,
    sonar = localStorage.getItem("plxRadarV2Sound") !== "false",
    knownPeople = new Set(),
    coordsDraft = null,
    lastLang = "",
    scanNote = "",
    moveWatch = null;
  const qs = (s, r = document) => r.querySelector(s),
    qsa = (s, r = document) => [...r.querySelectorAll(s)];
  function language() {
    const v = (
      localStorage.getItem("plxLang") ||
      document.documentElement.lang ||
      "de"
    ).toLowerCase();
    return v.startsWith("fr") ? "fr" : v.startsWith("en") ? "en" : "de";
  }
  function t(k) {
    return D[language()][k] || D.de[k] || k;
  }
  function esc(s) {
    return String(s ?? "").replace(
      /[&<>"']/g,
      (c) =>
        ({
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          '"': "&quot;",
          "'": "&#39;",
        })[c],
    );
  }
  function hash(s) {
    let h = 2166136261;
    for (let i = 0; i < s.length; i++) {
      h ^= s.charCodeAt(i);
      h = Math.imul(h, 16777619);
    }
    return h >>> 0;
  }
  function rad(d) {
    return (d * Math.PI) / 180;
  }
  function km(a, b) {
    const R = 6371,
      dLat = rad(b.lat - a.lat),
      dLng = rad(b.lng - a.lng),
      x =
        Math.sin(dLat / 2) ** 2 +
        Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
    return 2 * R * Math.asin(Math.sqrt(x));
  }
  function bearing(a, b) {
    const y = Math.sin(rad(b.lng - a.lng)) * Math.cos(rad(b.lat)),
      x =
        Math.cos(rad(a.lat)) * Math.sin(rad(b.lat)) -
        Math.sin(rad(a.lat)) *
          Math.cos(rad(b.lat)) *
          Math.cos(rad(b.lng - a.lng));
    return ((Math.atan2(y, x) * 180) / Math.PI + 360) % 360;
  }
  function publicPlot(item) {
    if (viewer && Number.isFinite(item.lat) && Number.isFinite(item.lng)) {
      const d = km(viewer, item),
        ang = bearing(viewer, item),
        rr = Math.min(0.9, 0.14 + (Math.min(d, radius) / radius) * 0.76);
      return { angle: ang, rr, d };
    }
    const h = hash(item.id || item.name),
      ang = h % 360,
      rr = 0.22 + ((h >>> 8) % 65) / 100;
    return { angle: ang, rr: Math.min(0.86, rr), d: null };
  }
  function pos(angle, rr) {
    const a = ((angle - 90) * Math.PI) / 180,
      r = rr * 44;
    return { x: 50 + Math.cos(a) * r, y: 50 + Math.sin(a) * r };
  }
  async function waitClient() {
    for (let i = 0; i < 40; i++) {
      if (window.PLX_SB) return window.PLX_SB;
      await new Promise((r) => setTimeout(r, 100));
    }
    return null;
  }
  async function refreshIdentity() {
    if (!sb) return;
    const g = await sb.auth.getSession();
    session = g.data.session;
    profile = settings = null;
    if (session) {
      const [p, s] = await Promise.all([
        sb
          .from("profiles")
          .select("full_name,favorite_sport,age_group")
          .eq("id", session.user.id)
          .maybeSingle(),
        sb
          .from("radar_settings")
          .select("discoverable,radius_km")
          .eq("user_id", session.user.id)
          .maybeSingle(),
      ]);
      profile = p.data;
      settings = s.data;
      if ([1, 5, 10, 25].includes(Number(settings?.radius_km)))
        radius = Number(settings.radius_km);
    }
    await loadChallenges();
    renderAll();
  }
  async function loadChallenges() {
    if (!sb) return;
    const r = await sb
      .from("challenge_submissions")
      .select(
        "id,title,sport,description,location_label,approx_lat,approx_lng,starts_at,ends_at,max_participants,visibility,status,points_reward,challenge_kind,event_ref,created_by_kind",
      )
      .eq("status", "approved")
      .gte("starts_at", new Date(Date.now() - 86400000).toISOString())
      .order("starts_at", { ascending: true })
      .limit(30);
    challenges = r.error
      ? []
      : (r.data || []).map((x) => ({
          ...x,
          type: "challenge",
          name: x.title,
          label: x.location_label,
          lat: x.approx_lat,
          lng: x.approx_lng,
        }));
  }
  function inRadius(item) {
    if (!viewer || !Number.isFinite(item?.lat) || !Number.isFinite(item?.lng))
      return true;
    return km(viewer, item) <= radius;
  }
  function chosenSport() {
    const saved = localStorage.getItem("powerluxSelectedSport");
    if (saved) return saved.toLowerCase();
    const active = qs("[data-rank-sport].active");
    return String(active?.dataset.rankSport || profile?.favorite_sport || "armwrestling").toLowerCase();
  }
  function sportFamily(item) {
    const value = (String(item?.sport || "") + " " + String(item?.name || "")).toLowerCase();
    if (/armwrest|bras de fer/.test(value)) return "armwrestling";
    if (/powerlift|weightlift|strongman|strength|fitness|gym|crossfit/.test(value)) return "powerlifting";
    if (/climb|boulder|escalad/.test(value)) return "climbing";
    if (/box|combat|martial|judo|karate|mma|wrestl|kickbox/.test(value)) return "combat";
    if (/swim|piscine|natation/.test(value)) return "swimming";
    if (/tennis|padel|squash/.test(value)) return "racket";
    if (/athletic|track|running/.test(value)) return "athletics";
    return "other";
  }
  function curatePlaces(source, max = 12) {
    const wanted = chosenSport(), seen = new Set();
    const ranked = source.map((item, index) => ({ item, index, family: sportFamily(item), distance: viewer && Number.isFinite(item.lat) && Number.isFinite(item.lng) ? km(viewer, item) : index })).sort((a, b) => Number(!!b.item.featured) - Number(!!a.item.featured) || a.distance - b.distance);
    const take = (rows, count) => rows.filter((x) => !seen.has(x.item.id)).slice(0, count).map((x) => { seen.add(x.item.id); return x.item; });
    const matching = ranked.filter((x) => x.family === wanted);
    const otherFamilies = ranked.filter((x) => x.family !== wanted);
    const diverse = [];
    for (const row of otherFamilies) if (!diverse.some((x) => x.family === row.family)) diverse.push(row);
    return [...take(matching, Math.min(8, max - 3)), ...take(diverse, Math.min(3, max)), ...take(ranked, max)].slice(0, max);
  }
  function dataItems() {
    const items = [];
    if (layer === "all" || layer === "places")
      items.push(...curatePlaces(allPlaces().filter(inRadius), layer === "places" ? 14 : 10));
    if (layer === "all" || layer === "events")
      items.push(...EVENTS.filter(inRadius));
    if (layer === "all" || layer === "challenges")
      items.push(...challenges.filter(inRadius));
    if (
      (layer === "all" || layer === "talent") &&
      session &&
      profile?.age_group === "18plus"
    )
      items.push(
        ...people.map((x) => ({
          ...x,
          id: "talent-" + x.signal_key,
          type: "talent",
          name: x.display_name || x.sport || "PLX Member",
          label: x.distance_band,
        })),
      );
    return items.slice(0, layer === "all" ? 14 : 16);
  }
  function signalHtml(item) {
    let p;
    if (item.type === "talent")
      p = pos(
        Number(item.plot_angle || 0),
        Math.min(0.9, Number(item.plot_radius || 0.5)),
      );
    else {
      const pp = publicPlot(item);
      p = pos(pp.angle, pp.rr);
    }
    const id = item.id || "";
    const isSelected = id === selected;
    const label =
      item.type === "talent"
        ? item.display_name || item.name || ""
        : item.type === "place" && item.featured
          ? item.name
          : "";
    const partner =
      item.type === "place" && item.featured
        ? "<small>PowerLux® Associate</small>"
        : "";
    const talentBadge =
      item.type === "talent"
        ? "<small>" +
          (item.talent_tier
            ? esc(item.talent_tier) +
              " · " +
              Number(item.talent_points || 0) +
              " PTS"
            : "PLX MEMBER") +
          "</small>"
        : "";
    return (
      '<button class="plx2-signal ' +
      item.type +
      (item.type === "place" && item.featured ? " associate" : "") +
      (isSelected ? " selected" : "") +
      '" style="left:' +
      p.x +
      "%;top:" +
      p.y +
      '%" data-plx2-select="' +
      esc(id) +
      '" data-plx-tier="' +
      esc(item.talent_tier || "") +
      '" data-plx-points="' +
      Number(item.talent_points || 0) +
      '" aria-pressed="' +
      (isSelected ? "true" : "false") +
      '" aria-label="' +
      esc(item.name || item.sport || item.type) +
      '"><i class="plx2-dot"></i>' +
      (label
        ? '<span class="plx2-signal-label">' +
          partner +
          talentBadge +
          esc(label) +
          "</span>"
        : "") +
      "</button>"
    );
  }
  function detailHtml() {
    if (!selected) {
      const visiblePlaces = dataItems().filter((item) => item.type === "place").length;
      const locationState = scanNote && !/^\d+\s/.test(scanNote)
        ? ` · ${esc(scanNote)}`
        : "";
      return `<span><b>${esc(nearbyText(visiblePlaces))}</b>${locationState}</span>`;
    }
    const item = dataItems().find((x) => (x.id || "") === selected);
    if (!item)
      return `<span>${viewer ? t("locationOn") : t("locationOptional")}</span>`;
    let meta = "",
      kind = "";
    if (item.type === "talent") {
      kind = "PLX MEMBER / PERFORMANCE SIGNAL";
      const perf = item.talent_tier
        ? " · " +
          esc(item.talent_tier) +
          " · " +
          Number(item.talent_points || 0) +
          " PTS"
        : "";
      meta = `${esc(item.sport || "PLX")} · ${esc(item.distance_band || "")}${perf}`;
    } else {
      const pp = publicPlot(item);
      const dist =
        pp.d != null ? ` · ~${pp.d.toFixed(pp.d < 10 ? 1 : 0)} ${t("km")}` : "";
      kind =
        item.type === "place" && item.featured
          ? "PowerLux® Associate"
          : item.type === "place"
            ? t("detailPublic")
            : item.type === "challenge"
              ? t("detailChallenge")
              : t("detailEvent");
      const pts =
        item.type === "challenge" && Number(item.points_reward) > 0
          ? " · +" + Number(item.points_reward) + " PTS"
          : "";
      meta = `${esc(item.sport || "")} · ${esc(item.label || "")}${dist}${pts}`;
    }
    const link = item.url
      ? ` · <a href="${esc(item.url)}" target="_blank" rel="noopener">${t("sourceLink")} ↗</a>`
      : "";
    return `<strong>${esc(item.name || item.sport || "PLX Signal")}</strong><span>${kind}<br>${meta}${link}</span>`;
  }
  function emptyText() {
    if (layer === "talent" && !session)
      return `<b>${t("talentLocked")}</b>${t("guestEmpty")}`;
    if (layer === "challenges" && !challenges.length)
      return `<b>PLX CHALLENGES</b>${t("noChallenges")}`;
    return `<b>PLX RADAR</b>${t("noSignals")}`;
  }
  function mapPoint(item) {
    const W = 1000,
      H = 560,
      CX = 500,
      CY = 300,
      px = 220 / Math.max(1, radius);
    if (item.type === "talent") {
      const a = ((Number(item.plot_angle || 0) - 90) * Math.PI) / 180,
        rr = Math.min(0.9, Number(item.plot_radius || 0.5)) * 220;
      return {
        x: CX + Math.cos(a) * rr,
        y: CY + Math.sin(a) * rr,
        approx: true,
      };
    }
    const center = viewer || { lat: 49.6116, lng: 6.1319 };
    const east =
        (Number(item.lng) - center.lng) * 111.32 * Math.cos(rad(center.lat)),
      north = (Number(item.lat) - center.lat) * 111.32;
    return { x: CX + east * px, y: CY - north * px, approx: false };
  }
  function mapMarker(item) {
    const p = mapPoint(item);
    if (
      !Number.isFinite(p.x) ||
      !Number.isFinite(p.y) ||
      p.x < -40 ||
      p.x > 1040 ||
      p.y < -40 ||
      p.y > 600
    )
      return "";
    const id = item.id || "",
      sel = id === selected,
      klass = "plx-map-marker " + item.type + (sel ? " selected" : "");
    const label =
      item.type === "talent"
        ? item.display_name || item.name || ""
        : item.type === "place" && item.featured
          ? item.name
          : sel
            ? item.name
            : "";
    const sub =
      item.type === "place" && item.featured ? "PowerLux® Associate · " : "";
    return (
      '<g class="' +
      klass +
      '" data-plx2-select="' +
      esc(id) +
      '" role="button" tabindex="0" aria-label="' +
      esc(item.name || item.sport || item.type) +
      '"><circle cx="' +
      p.x +
      '" cy="' +
      p.y +
      '" r="18" class="hit"></circle><circle cx="' +
      p.x +
      '" cy="' +
      p.y +
      '" r="6" class="dot"></circle>' +
      (sel
        ? '<circle cx="' +
          p.x +
          '" cy="' +
          p.y +
          '" r="14" class="select-ring"></circle>'
        : "") +
      (label
        ? '<text x="' +
          (p.x + 12) +
          '" y="' +
          (p.y - 12) +
          '"><tspan>' +
          esc(sub + label) +
          "</tspan></text>"
        : "") +
      "</g>"
    );
  }
  function mapDataItems() {
    const out = [
      ...allPlaces().filter(inRadius),
      ...EVENTS.filter(inRadius),
      ...challenges.filter(inRadius),
    ];
    if (session && profile?.age_group === "18plus")
      out.push(
        ...people.map((x) => ({
          ...x,
          id: "talent-" + x.signal_key,
          type: "talent",
          name: x.display_name || x.sport || "PLX Member",
          label: x.distance_band,
        })),
      );
    return out;
  }
  function mapTemplate() {
    const gps = !!viewer;
    return (
      '<div class="plx-map-shell explore"><div class="plx-map-head"><div><small>POWERMAP® // ' +
      (gps ? "LIVE GPS" : "PUBLIC NETWORK") +
      "</small><strong>" +
      radius +
      " KM EXPLORE MAP</strong></div><span>" +
      (gps ? "● FOLLOWING POSITION" : "○ SCAN TO LOCK GPS") +
      '</span></div><div class="plx-realmap" data-plx-maplibre="explore"></div><div class="plx-map-credit-detail">REAL STREET + ADMIN BOUNDARIES · © OPENSTREETMAP CONTRIBUTORS · OPENFREEMAP</div></div>'
    );
  }
  function zoomForRadius() {
    return radius <= 1 ? 14.5 : radius <= 5 ? 12.6 : radius <= 10 ? 11.6 : 10.4;
  }
  function mapCenter() {
    return viewer ? [viewer.lng, viewer.lat] : [6.1319, 49.6116];
  }
  function destPoint(origin, distKm, bearingDeg) {
    const R = 6371,
      d = distKm / R,
      b = rad(bearingDeg),
      lat1 = rad(origin.lat),
      lon1 = rad(origin.lng);
    const lat2 = Math.asin(
      Math.sin(lat1) * Math.cos(d) + Math.cos(lat1) * Math.sin(d) * Math.cos(b),
    );
    const lon2 =
      lon1 +
      Math.atan2(
        Math.sin(b) * Math.sin(d) * Math.cos(lat1),
        Math.cos(d) - Math.sin(lat1) * Math.sin(lat2),
      );
    return { lng: (lon2 * 180) / Math.PI, lat: (lat2 * 180) / Math.PI };
  }
  function mapCoord(item) {
    if (item.type === "talent") {
      if (!viewer) return null;
      const rr = Math.max(
        0.08,
        Math.min(0.86, Number(item.plot_radius || 0.5)),
      );
      return destPoint(
        viewer,
        Math.max(0.12, radius * rr * 0.82),
        Number(item.plot_angle || 0),
      );
    }
    if (Number.isFinite(Number(item.lat)) && Number.isFinite(Number(item.lng)))
      return { lng: Number(item.lng), lat: Number(item.lat) };
    return null;
  }
  function tuneBaseMap(map, detailed) {
    const st = map.getStyle();
    (st.layers || []).forEach((l) => {
      const id = (l.id || "").toLowerCase();
      try {
        if (l.type === "background") {
          map.setPaintProperty(l.id, "background-color", "#02090d");
        } else if (l.type === "fill") {
          const building = /building/.test(id);
          map.setPaintProperty(
            l.id,
            "fill-color",
            building ? "#7895a1" : "#071016",
          );
          map.setPaintProperty(
            l.id,
            "fill-opacity",
            building ? (detailed ? 0.13 : 0.06) : 0.1,
          );
        } else if (l.type === "line") {
          let c = "#6c8790",
            o = detailed ? 0.26 : 0.16,
            w = detailed ? 0.8 : 0.55;
          if (
            /road|street|highway|transport|motorway|trunk|primary|secondary|tertiary/.test(
              id,
            )
          ) {
            c = "#d7e9ed";
            o = detailed ? 0.46 : 0.27;
            w = detailed ? 1.15 : 0.75;
          }
          if (/boundary|admin/.test(id)) {
            c = "#19b6f1";
            o = detailed ? 0.58 : 0.34;
            w = detailed ? 1.25 : 0.9;
          }
          if (/water|river|stream/.test(id)) {
            c = "#0ca7d3";
            o = detailed ? 0.4 : 0.23;
            w = detailed ? 1.05 : 0.7;
          }
          map.setPaintProperty(l.id, "line-color", c);
          map.setPaintProperty(l.id, "line-opacity", o);
          map.setPaintProperty(l.id, "line-width", w);
        } else if (l.type === "symbol") {
          const keep =
            detailed && /place|city|town|village|suburb|settlement/.test(id);
          if (!keep) {
            map.setLayoutProperty(l.id, "visibility", "none");
          } else {
            try {
              map.setPaintProperty(l.id, "text-color", "#b9d5dc");
              map.setPaintProperty(l.id, "text-opacity", 0.66);
              map.setPaintProperty(l.id, "text-halo-color", "#02090d");
              map.setPaintProperty(l.id, "text-halo-width", 1.2);
              map.setPaintProperty(l.id, "icon-opacity", 0);
            } catch (_) {}
          }
        } else if (l.type === "circle") {
          map.setPaintProperty(l.id, "circle-opacity", 0);
        }
      } catch (_) {}
    });
  }
  function addExploreMarkers(map) {
    (map._plxMarkers || []).forEach((x) => {
      try {
        x.remove();
      } catch (_) {}
    });
    map._plxMarkers = [];
    /* The canonical signals are projected by signalHtml/publicPlot. Keeping
       MapLibre as the basemap only prevents a second marker layer from racing
       the radar layer on slow mobile browsers. */
  }
  function lockPowerMap(map) {
    [
      "scrollZoom",
      "boxZoom",
      "dragRotate",
      "dragPan",
      "keyboard",
      "doubleClickZoom",
      "touchZoomRotate",
    ].forEach((k) => {
      try {
        map[k].disable();
      } catch (_) {}
    });
  }
  function legacyInitMapLibre() {
    if (!window.maplibregl) return;
    qsa('[data-plx-maplibre="explore"]').forEach((el) => {
      if (
        el._plxMap ||
        el.getBoundingClientRect().width < 10 ||
        el.getBoundingClientRect().height < 10
      )
        return;
      try {
        const map = new maplibregl.Map({
          container: el,
          style: "https://tiles.openfreemap.org/styles/dark",
          center: mapCenter(),
          zoom: zoomForRadius(),
          interactive: false,
          attributionControl: false,
          fadeDuration: 0,
          renderWorldCopies: false,
          refreshExpiredTiles: false,
          cancelPendingTileRequestsWhileZooming: true,
        });
        el._plxMap = map;
        lockPowerMap(map);
        map.on("load", () => {
          el.dataset.plxMapState = "ready";
          el.dataset.plxMapRetries = "0";
          tuneBaseMap(map, true);
          addExploreMarkers(map);
          try {
            map.resize();
          } catch (_) {}
        });
        map.on("error", () => {
          el.dataset.plxMapState = map.isStyleLoaded() ? "ready" : "loading";
        });
        setTimeout(() => {
          if (!el.isConnected || el._plxMap !== map || map.isStyleLoaded())
            return;
          const retries = Number(el.dataset.plxMapRetries || 0);
          if (retries >= 1) {
            el.dataset.plxMapState = "fallback";
            return;
          }
          el.dataset.plxMapRetries = String(retries + 1);
          try {
            map.remove();
          } catch (_) {}
          el._plxMap = null;
          legacyInitMapLibre();
        }, 8000);
      } catch (_) {
        el.dataset.plxMapState = "fallback";
      }
    });
  }
  function legacyUpdateMapCenters() {
    qsa("[data-plx-maplibre]").forEach((el) => {
      try {
        if (el._plxMap)
          el._plxMap.easeTo({
            center: mapCenter(),
            zoom: zoomForRadius(),
            duration: 700,
          });
      } catch (_) {}
    });
  }
  function radarTemplate() {
    const items = dataItems(),
      member = !!session,
      memberTalent = !!(
        session &&
        profile?.age_group === "18plus" &&
        settings?.discoverable
      );
    return `<div class="plx2-shell"><div class="plx2-head"><div><small>${t("eyebrow")}</small><h3>${t("title")}</h3></div><div class="plx2-mode"><span class="plx2-pill ${member ? "live" : ""}">${member ? t("member") : t("guest")}</span><span class="plx2-pill live">${t("public")}</span>${session && profile?.age_group === "18plus" ? `<span class="plx2-pill ${memberTalent ? "live" : ""}">${memberTalent ? "MEMBER LIVE" : "MEMBER PRIVATE"}</span>` : ""}</div></div><div class="plx2-layers">${[
      ["all", "all"],
      ["talent", "people"],
      ["places", "places"],
      ["challenges", "challenges"],
      ["events", "events"],
    ]
      .map(
        ([v, k]) =>
          `<button class="plx2-layer ${layer === v ? "active" : ""} " data-plx2-layer="${v}">${t(k)}</button>`,
      )
      .join(
        "",
      )}</div><div class="plx2-radar"><div class="plx2-center"></div>${items.map(signalHtml).join("")}${!items.length ? `<div class="plx2-empty">${emptyText()}</div>` : ""}</div><div class="plx2-detail">${detailHtml()}</div><div class="plx2-legend"><span><i class="t"></i>${t("people")}</span><span><i class="p"></i>${t("places")}</span><span><i class="c"></i>${t("challenges")}</span><span><i class="e"></i>${t("events")}</span></div><div class="plx2-controls">${[1, 5, 10, 25].map((n) => `<button class="plx2-radius ${radius === n ? "active" : ""}" data-plx2-radius="${n}">${n} KM</button>`).join("")}<button class="plx2-sound ${sonar ? "active" : ""}" data-plx2-action="sound">${t("sound")} // ${sonar ? "ON" : "OFF"}</button><button class="action primary plx2-scan" data-plx2-action="scan">${session && memberTalent ? t("scanMember") : t("scanPublic")}</button></div><div class="plx2-actions">${!session ? `<button class=\"action primary\" data-plx2-action=\"login\">${t("loginCta")}</button>` : profile?.age_group === "18plus" && !settings?.discoverable ? `<button class=\"action primary\" data-plx2-action=\"activate\">${t("activate")}</button>` : ""}<button class="action" data-plx2-action="report">${t("report")}</button><button class="action" data-plx2-action="challenge">${t("post")}</button></div><div class="plx2-note">${t("private")}</div></div>`;
  }
  function legacyRenderAll() {
    destroyMaps();
    const ids = new Set(dataItems().map((x) => x.id || ""));
    if (selected && !ids.has(selected)) selected = null;
    qsa("[data-plx-radar-v2]").forEach((m) => {
      const context = m.dataset.plxRadarV2 || "radar";
      let radar = radarTemplate();
      if (context === "home") {
        radar = radar.replace(
          '<div class="plx2-radar">',
          '<div class="plx2-radar plx2-radar-home"><div class="plx-realmap home" data-plx-maplibre="home"></div><span class="plx2-map-tag">REAL MAP // STREET + COMMUNE LAYER</span><span class="plx2-map-credit">© OSM · OPENFREEMAP</span>',
        );
        m.innerHTML = radar;
      } else {
        m.innerHTML = radar + mapTemplate();
      }
    });
    requestAnimationFrame(legacyInitMapLibre);
  }
  function plxTileZoom() {
    return radius <= 1 ? 14 : radius <= 5 ? 12 : radius <= 10 ? 11 : 10;
  }
  function plxWorldPixel(center, z) {
    const scale = 256 * Math.pow(2, z),
      lat = Math.max(-85.0511, Math.min(85.0511, center[1])),
      sin = Math.sin((lat * Math.PI) / 180);
    return {
      x: ((center[0] + 180) / 360) * scale,
      y: (0.5 - Math.log((1 + sin) / (1 - sin)) / (4 * Math.PI)) * scale,
      scale,
    };
  }
  function renderPowerLuxTiles(el) {
    const r = el.getBoundingClientRect();
    if (r.width < 10 || r.height < 10) return;
    if (window.maplibregl) {
      if (el._plxMap) {
        try {
          el._plxMap.jumpTo({ center: mapCenter(), zoom: zoomForRadius() });
          el._plxMap.resize();
        } catch (_) {}
        return;
      }
      if (el.dataset.plxMapState === "loading") return;
      el.dataset.plxMapState = "loading";
      try {
        const map = new maplibregl.Map({
          container: el,
          style: "https://tiles.openfreemap.org/styles/dark",
          center: mapCenter(),
          zoom: zoomForRadius(),
          interactive: false,
          attributionControl: false,
          fadeDuration: 0,
          renderWorldCopies: true,
        });
        el._plxMap = map;
        lockPowerMap(map);
        map.on("load", () => {
          el.dataset.plxMapState = "ready";
          tuneBaseMap(map, true);
          addExploreMarkers(map);
          try { map.resize(); } catch (_) {}
        });
        map.on("error", () => {
          if (!map.isStyleLoaded()) el.dataset.plxMapState = "fallback";
        });
        return;
      } catch (_) {
        el._plxMap = null;
        el.dataset.plxMapState = "fallback";
      }
    }
    const z = plxTileZoom(),
      c = plxWorldPixel(mapCenter(), z),
      left = c.x - r.width / 2,
      top = c.y - r.height / 2,
      x0 = Math.floor(left / 256),
      x1 = Math.floor((left + r.width) / 256),
      y0 = Math.floor(top / 256),
      y1 = Math.floor((top + r.height) / 256),
      n = Math.pow(2, z),
      key = [
        z,
        Math.round(c.x),
        Math.round(c.y),
        Math.round(r.width),
        Math.round(r.height),
      ].join(":");
    if (el._plxTileKey === key) return;
    el._plxTileKey = key;
    const requestId = (el._plxTileRequest || 0) + 1;
    el._plxTileRequest = requestId;
    const grid = document.createElement("div");
    grid.className = "plx-tile-grid";
    grid.style.cssText =
      "position:absolute;inset:0;overflow:hidden;background:#02090d;filter:grayscale(1) invert(.91) sepia(.12) saturate(.55) hue-rotate(142deg) brightness(.72) contrast(1.32)";
    const pending = [];
    for (let x = x0; x <= x1; x++)
      for (let y = y0; y <= y1; y++) {
        if (y < 0 || y >= n) continue;
        const img = document.createElement("img");
        img.alt = "";
        img.decoding = "async";
        img.loading = "eager";
        img.referrerPolicy = "origin";
        img.src =
          "https://tile.openstreetmap.org/" +
          z +
          "/" +
          (((x % n) + n) % n) +
          "/" +
          y +
          ".png";
        img.style.cssText =
          "position:absolute;width:256px;height:256px;max-width:none;left:" +
          (x * 256 - left) +
          "px;top:" +
          (y * 256 - top) +
          "px";
        pending.push(
          new Promise((resolve) => {
            img.addEventListener("load", resolve, { once: true });
            img.addEventListener("error", resolve, { once: true });
            if (img.complete) resolve();
          }),
        );
        grid.appendChild(img);
      }
    Promise.race([
      Promise.all(pending),
      new Promise((resolve) => setTimeout(resolve, 1200)),
    ]).then(() => {
      if (el._plxTileRequest !== requestId) return;
      el.replaceChildren(grid);
      el.dataset.plxMapState = "ready";
    });
  }
  function initMapLibre() {
    qsa('[data-plx-maplibre="explore"]').forEach(renderPowerLuxTiles);
  }
  function updateMapCenters() {
    qsa('[data-plx-maplibre="explore"]').forEach((el) => {
      if (el._plxMap) {
        try {
          el._plxMap.easeTo({ center: mapCenter(), zoom: zoomForRadius(), duration: 420 });
        } catch (_) {}
        return;
      }
      el._plxTileKey = "";
      renderPowerLuxTiles(el);
    });
  }
  function renderAll() {
    const ids = new Set(dataItems().map((x) => x.id || ""));
    if (selected && !ids.has(selected)) selected = null;
    qsa("[data-plx-radar-v2]").forEach((m) => {
      const context = m.dataset.plxRadarV2 || "radar",
        old =
          context === "radar" ? qs('[data-plx-maplibre="explore"]', m) : null;
      if (old) old.remove();
      let radar = radarTemplate();
      if (context === "radar")
        radar = radar.replace(
          '<div class="plx2-radar">',
          '<div class="plx2-radar plx-powermap-main"><div class="plx-realmap" data-plx-maplibre="explore"></div><span class="plx2-map-tag">POWERMAP® · STREET + RADAR</span><span class="plx2-map-credit">© OPENSTREETMAP CONTRIBUTORS</span>',
        );
      m.innerHTML = radar;
      if (old) {
        const fresh = qs('[data-plx-maplibre="explore"]', m);
        fresh?.replaceWith(old);
        if (old._plxMap) {
          lockPowerMap(old._plxMap);
          try {
            old._plxMap.resize();
            old._plxMap.jumpTo({ center: mapCenter(), zoom: zoomForRadius() });
            if (old._plxMap.isStyleLoaded()) addExploreMarkers(old._plxMap);
          } catch (_) {}
        } else renderPowerLuxTiles(old);
      }
    });
    requestAnimationFrame(initMapLibre);
    setTimeout(initMapLibre, 120);
    setTimeout(initMapLibre, 500);
  }
  function toast(text) {
    let e = qs(".plx2-toast");
    if (e) e.remove();
    e = document.createElement("div");
    e.className = "plx2-toast";
    e.textContent = text;
    document.body.appendChild(e);
    setTimeout(() => e.remove(), 4200);
  }
  function openMyPlx() {
    if (typeof window.openPanel === "function") window.openPanel("myplx");
    else document.querySelector('[data-panel="myplx"]')?.click();
  }
  function locate(btn) {
    return new Promise((resolve, reject) => {
      if (!navigator.geolocation)
        return reject(new Error("Geolocation unavailable"));
      const old = btn?.textContent;
      if (btn) {
        btn.disabled = true;
        btn.textContent = t("locating");
      }
      navigator.geolocation.getCurrentPosition(
        (p) => {
          viewer = { lat: p.coords.latitude, lng: p.coords.longitude };
          updateMapCenters();
          if (btn) {
            btn.disabled = false;
            btn.textContent = old || t("scanPublic");
          }
          resolve(p);
        },
        (e) => {
          if (btn) {
            btn.disabled = false;
            btn.textContent = old || t("scanPublic");
          }
          reject(e);
        },
        { enableHighAccuracy: true, timeout: 12000, maximumAge: 5000 },
      );
    });
  }
  function geoScanNote() {
    return nearbyStatus || (viewer ? t("locationOn") : t("locationOptional"));
  }
  async function scan(btn, provided) {
    try {
      const guard = window.PowerLuxGuard
        ? await window.PowerLuxGuard("radar_scan", "/powermap/scan")
        : { allowed: true };
      if (!guard.allowed)
        throw new Error("Scan vorübergehend pausiert. Bitte später erneut versuchen.");
      const p = provided || (await locate(btn));
      updateMapCenters();
      scanNote = viewer ? t("locationOn") : t("locationOptional");
      renderAll();
      await loadNearbyPlaces(p);
      if (session && profile?.age_group === "18plus") {
        const s = await sb
          .from("radar_settings")
          .select("discoverable,radius_km")
          .eq("user_id", session.user.id)
          .maybeSingle();
        settings = s.data;
        if (settings?.discoverable) {
          const old = btn?.textContent;
          if (btn) {
            btn.disabled = true;
            btn.textContent = t("scanning");
          }
          const r = await sb.rpc("scan_radar", {
            p_lat: p.coords.latitude,
            p_lng: p.coords.longitude,
            p_accuracy_m: p.coords.accuracy,
          });
          if (r.error) throw r.error;
          people = r.data || [];
          const fresh = people.some((x) => !knownPeople.has(x.signal_key));
          knownPeople = new Set(people.map((x) => x.signal_key));
          if (fresh && sonar) ping();
          if (people.length) {
            layer = "talent";
            selected = "talent-" + people[0].signal_key;
            scanNote =
              (people.length === 1
                ? t("foundOne")
                : people.length + " " + t("foundMany")) +
              (nearbyStatus ? " · " + nearbyStatus : "");
          } else {
            selected = null;
            scanNote =
              t("nonePeople") + (nearbyStatus ? " · " + nearbyStatus : "");
          }
          if (btn && btn.isConnected) {
            btn.disabled = false;
            btn.textContent = old || t("scanMember");
          }
        } else scanNote = geoScanNote();
      } else scanNote = geoScanNote();
      renderAll();
    } catch (e) {
      scanNote = geoErrorText(e);
      toast(scanNote);
      renderAll();
    }
  }
  function ping() {
    try {
      const A = window.AudioContext || window.webkitAudioContext;
      if (!A) return;
      const c = new A(),
        o = c.createOscillator(),
        g = c.createGain();
      o.type = "sine";
      o.frequency.setValueAtTime(760, c.currentTime);
      o.frequency.exponentialRampToValueAtTime(450, c.currentTime + 0.34);
      g.gain.setValueAtTime(0.0001, c.currentTime);
      g.gain.exponentialRampToValueAtTime(0.05, c.currentTime + 0.02);
      g.gain.exponentialRampToValueAtTime(0.0001, c.currentTime + 0.52);
      o.connect(g);
      g.connect(c.destination);
      o.start();
      o.stop(c.currentTime + 0.54);
      setTimeout(() => c.close(), 700);
    } catch {}
  }
  function modalBase(title, sub, body) {
    const d = document.createElement("div");
    d.className = "plx2-modal";
    d.innerHTML = `<div class="plx2-modal-box"><div class="plx2-modal-top"><div><div class="hud-eyebrow">PLX // SUBMISSION</div><h3>${title}</h3></div><button class="plx2-close" data-plx2-close aria-label="${t("close")}">×</button></div><p class="section-sub">${sub}</p>${body}</div>`;
    document.body.appendChild(d);
    return d;
  }
  function openReport() {
    if (!session) {
      toast(t("loginNeeded"));
      openMyPlx();
      return;
    }
    modalBase(
      t("reportTitle"),
      t("reportSub"),
      `<form class="plx2-form" data-plx2-form="report"><label class="plx2-field full">TYPE<select name="report_type"><option value="self">${t("self")}</option><option value="other">${t("other")}</option></select></label><label class="plx2-field">${t("athlete")}<input name="athlete_name" required maxlength="100" value="${esc(profile?.full_name || "")}"></label><label class="plx2-field">${t("sport")}<input name="sport" required maxlength="80" value="${esc(profile?.favorite_sport || "")}"></label><label class="plx2-field full">${t("result")}<input name="result_text" required maxlength="300"></label><label class="plx2-field">${t("eventName")}<input name="event_name" maxlength="160"></label><label class="plx2-field">${t("date")}<input name="result_date" type="date"></label><label class="plx2-field">${t("source")}<input name="source_url" type="url" placeholder="https://"></label><label class="plx2-field">${t("instagram")}<input name="instagram" maxlength="100"></label><label class="plx2-field full plx2-check"><input name="consent" type="checkbox" required><span>${t("consent")}</span></label><button class="action primary full" type="submit">${t("submitReport")}</button></form>`,
    );
  }
  function openChallenge() {
    if (!session) {
      toast(t("loginNeeded"));
      openMyPlx();
      return;
    }
    if (profile?.age_group !== "18plus") {
      toast(t("adultNeeded"));
      return;
    }
    coordsDraft = null;
    modalBase(
      t("challengeTitle"),
      t("challengeSub"),
      `<form class="plx2-form" data-plx2-form="challenge"><label class="plx2-field">${t("challengeName")}<input name="title" required maxlength="100"></label><label class="plx2-field">${t("sport")}<input name="sport" required maxlength="80" value="${esc(profile?.favorite_sport || "")}"></label><label class="plx2-field full">${t("description")}<textarea name="description" required maxlength="600"></textarea></label><label class="plx2-field">${t("location")}<input name="location_label" required maxlength="120"></label><label class="plx2-field">${t("start")}<input name="starts_at" type="datetime-local" required></label><label class="plx2-field">${t("visibility")}<select name="visibility"><option value="public">${t("publicVis")}</option><option value="plx">${t("plxVis")}</option></select></label><label class="plx2-field">${t("max")}<input name="max_participants" type="number" min="2" max="500"></label><div class="plx2-field full"><button class="action" type="button" data-plx2-action="challenge-location">${t("useLocation")}</button><div class="plx2-location" id="plx2LocationState">${t("locationNeed")}</div></div><label class="plx2-field full plx2-check"><input name="safety" type="checkbox" required><span>${t("safety")}</span></label><button class="action primary full" type="submit">${t("submitChallenge")}</button></form>`,
    );
  }
  async function submitForm(e) {
    const f = e.target;
    if (!f.matches("[data-plx2-form]")) return;
    e.preventDefault();
    const d = new FormData(f),
      btn = f.querySelector('button[type="submit"]');
    btn.disabled = true;
    try {
      if (f.dataset.plx2Form === "report") {
        const row = {
          reporter_user_id: session.user.id,
          report_type: d.get("report_type"),
          athlete_name: String(d.get("athlete_name")).trim(),
          sport: String(d.get("sport")).trim(),
          result_text: String(d.get("result_text")).trim(),
          event_name: String(d.get("event_name") || "").trim() || null,
          result_date: d.get("result_date") || null,
          source_url: String(d.get("source_url") || "").trim() || null,
          instagram: String(d.get("instagram") || "").trim() || null,
          consent_confirmed: true,
          status: "pending",
        };
        const r = await sb.from("talent_reports").insert(row);
        if (r.error) throw r.error;
        document.querySelector(".plx2-modal")?.remove();
        toast(t("reportOk"));
      } else {
        if (!coordsDraft) throw new Error(t("locationNeed"));
        const start = new Date(String(d.get("starts_at")));
        if (Number.isNaN(start.getTime())) throw new Error("Invalid date");
        const max = String(d.get("max_participants") || "").trim();
        const row = {
          creator_user_id: session.user.id,
          title: String(d.get("title")).trim(),
          sport: String(d.get("sport")).trim(),
          description: String(d.get("description")).trim(),
          location_label: String(d.get("location_label")).trim(),
          approx_lat: coordsDraft.lat,
          approx_lng: coordsDraft.lng,
          starts_at: start.toISOString(),
          max_participants: max ? Number(max) : null,
          visibility: d.get("visibility"),
          safety_confirmed: true,
          status: "pending",
        };
        const r = await sb.from("challenge_submissions").insert(row);
        if (r.error) throw r.error;
        document.querySelector(".plx2-modal")?.remove();
        toast(t("challengeOk"));
      }
    } catch (err) {
      toast(err?.message || "Submission failed");
    } finally {
      if (btn && btn.isConnected) btn.disabled = false;
    }
  }
  async function click(e) {
    if (e.target.closest("[data-plx2-close]")) {
      e.target.closest(".plx2-modal")?.remove();
      return;
    }
    const b = e.target.closest(
      "[data-plx2-layer],[data-plx2-radius],[data-plx2-action],[data-plx2-select]",
    );
    if (!b) return;
    if (b.dataset.plx2Layer) {
      const v = b.dataset.plx2Layer;
      if (v === "talent" && !session) {
        layer = v;
        selected = null;
        renderAll();
        return;
      }
      layer = v;
      selected = null;
      renderAll();
      return;
    }
    if (b.dataset.plx2Radius) {
      const next = Number(b.dataset.plx2Radius);
      radius = next;
      selected = null;
      scanNote = "";
      updateMapCenters();
      renderAll();
      if (session && profile?.age_group === "18plus" && settings) {
        sb.rpc("set_radar_preferences", {
          p_discoverable: !!settings.discoverable,
          p_radius_km: next,
        }).then((q) => {
          if (!q.error) settings = q.data;
        });
      }
      const refreshRadius = (p) => {
        if (
          session &&
          profile?.age_group === "18plus" &&
          settings?.discoverable
        ) {
          scan(null, p);
          return;
        }
        loadNearbyPlaces(p)
          .then(() => {
            scanNote = geoScanNote();
            renderAll();
          })
          .catch((err) => {
            scanNote = geoErrorText(err);
            toast(scanNote);
            renderAll();
          });
      };
      if (viewer) {
        refreshRadius({
          coords: {
            latitude: viewer.lat,
            longitude: viewer.lng,
            accuracy: null,
          },
        });
      } else {
        locate()
          .then(refreshRadius)
          .catch((err) => {
            scanNote = geoErrorText(err);
            toast(scanNote);
            renderAll();
          });
      }
      return;
    }
    if (b.dataset.plx2Select) {
      selected = b.dataset.plx2Select;
      renderAll();
      return;
    }
    const a = b.dataset.plx2Action;
    if (a === "login") {
      openMyPlx();
    } else if (a === "activate") {
      try {
        const p = await locate(b);
        const q = await sb.rpc("set_radar_preferences", {
          p_discoverable: true,
          p_radius_km: radius,
        });
        if (q.error) toast(q.error.message);
        else {
          settings = q.data;
          scanNote = "";
          await scan(b, p);
        }
      } catch (err) {
        scanNote = geoErrorText(err);
        toast(scanNote);
        renderAll();
      }
    } else if (a === "sound") {
      sonar = !sonar;
      localStorage.setItem("plxRadarV2Sound", sonar);
      if (sonar) ping();
      renderAll();
    } else if (a === "scan") {
      scan(b);
    } else if (a === "report") {
      openReport();
    } else if (a === "challenge") {
      openChallenge();
    } else if (a === "challenge-location") {
      try {
        const p = await locate(b);
        coordsDraft = {
          lat: Math.round(p.coords.latitude * 100) / 100,
          lng: Math.round(p.coords.longitude * 100) / 100,
        };
        const s = qs("#plx2LocationState");
        if (s)
          s.innerHTML =
            "<b>✓ " +
            t("locationReady") +
            "</b><br>" +
            coordsDraft.lat.toFixed(2) +
            ", " +
            coordsDraft.lng.toFixed(2);
      } catch (err) {
        toast(err?.message || "Location unavailable");
      }
    }
  }
  document.addEventListener("click", (event) => {
    const sport = event.target.closest?.("[data-rank-sport]")?.dataset.rankSport;
    if (!sport) return;
    localStorage.setItem("powerluxSelectedSport", sport);
    selected = null;
    renderAll();
  }, true);
  function syncMoveWatch() {
    const active = !!(
      viewer &&
      document.visibilityState === "visible" &&
      document.querySelector("#panel-radar.active, #panel-home.active")
    );
    if (active && moveWatch === null && navigator.geolocation) {
      moveWatch = navigator.geolocation.watchPosition(
        (p) => {
          const next = { lat: p.coords.latitude, lng: p.coords.longitude },
            moved = viewer ? km(viewer, next) : 999;
          viewer = next;
          updateMapCenters();
          const now = Date.now();
          if (
            moved > 0.3 &&
            now - Number(syncMoveWatch.lastNearbyAt || 0) > 20000
          ) {
            syncMoveWatch.lastNearbyAt = now;
            loadNearbyPlaces(p).then(() => {
              scanNote = geoScanNote();
              renderAll();
            });
          }
        },
        () => {},
        { enableHighAccuracy: true, maximumAge: 2000, timeout: 10000 },
      );
    } else if (!active && moveWatch !== null && navigator.geolocation) {
      navigator.geolocation.clearWatch(moveWatch);
      moveWatch = null;
    }
  }
  async function tryAutoNearby() {
    try {
      if (!navigator.permissions || !navigator.geolocation) return;
      const q = await navigator.permissions.query({ name: "geolocation" });
      if (q.state !== "granted") return;
      const p = await locate();
      if (session && profile?.age_group === "18plus" && settings?.discoverable)
        await scan(null, p);
      else {
        await loadNearbyPlaces(p);
        scanNote = geoScanNote();
        renderAll();
      }
    } catch (_) {}
  }
  async function init() {
    if (!document.getElementById("plx2-style")) {
      const st = document.createElement("style");
      st.id = "plx2-style";
      st.textContent = STYLE;
      document.head.appendChild(st);
    }
    const firstPosition = navigator.geolocation
      ? new Promise((resolve) => {
          navigator.geolocation.getCurrentPosition(
            (p) => {
              viewer = { lat: p.coords.latitude, lng: p.coords.longitude };
              scanNote = t("locationOn");
              updateMapCenters();
              renderAll();
              resolve(p);
            },
            () => resolve(null),
            {
              enableHighAccuracy: true,
              timeout: 12000,
              maximumAge: 30000,
            },
          );
        })
      : Promise.resolve(null);
    sb = await waitClient();
    if (!sb) {
      console.error("PLX Radar V2: shared Supabase client unavailable");
      return;
    }
    document.addEventListener("click", click, true);
    document.addEventListener("submit", submitForm);
    sb.auth.onAuthStateChange(() => setTimeout(refreshIdentity, 80));
    await refreshIdentity();
    firstPosition.then((p) => {
      if (!p) {
        tryAutoNearby();
        return;
      }
      updateMapCenters();
      renderAll();
      loadNearbyPlaces(p).then(() => {
        scanNote = geoScanNote();
        renderAll();
      });
    });
    document.addEventListener("powerlux:powermap-open", () => {
      if (viewer) {
        updateMapCenters();
        return;
      }
      scan();
    });
    lastLang = language();
    setInterval(() => {
      const l = language();
      if (l !== lastLang) {
        lastLang = l;
        renderAll();
      }
    }, 400);
    setInterval(() => {
      if (
        session &&
        profile?.age_group === "18plus" &&
        settings?.discoverable &&
        document.visibilityState === "visible" &&
        document.querySelector(
          "#panel-home.active,#panel-radar.active,#panel-talents.active",
        )
      )
        scan();
    }, 30000);
    setInterval(syncMoveWatch, 600);
    syncMoveWatch();
    document.addEventListener("visibilitychange", syncMoveWatch);
    document.addEventListener(
      "click",
      (e) => {
        if (
          e.target.closest(
            '[data-panel="radar"],[data-panel="talents"],[data-panel="home"],[data-go="radar"],[data-go="talents"],[data-go="home"]',
          )
        ) {
          setTimeout(refreshIdentity, 120);
          if (viewer) {
            updateMapCenters();
            renderAll();
          } else {
            tryAutoNearby();
          }
        }
      },
      true,
    );
  }
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", init);
  else init();
})();
