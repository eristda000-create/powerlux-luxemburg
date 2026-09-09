-- Canonicalize the MERG Value Engine policy and cross-project watch sources already verified in production.

insert into public.merg_ai_policy (policy_key, enabled, policy, updated_at)
values (
  'value_engine',
  true,
  jsonb_build_object(
    'north_star', 'Every autonomous work item must create MONEY, KNOWLEDGE or BOTH.',
    'money_threshold', 48,
    'external_execution_default', false,
    'auto_allowed', jsonb_build_array(
      'scan_sources',
      'deduplicate',
      'score_opportunity',
      'create_internal_work_item',
      'prepare_draft',
      'distill_knowledge',
      'update_measurement'
    ),
    'human_required', jsonb_build_array(
      'send_new_outreach',
      'publish_social',
      'accept_price',
      'make_purchase',
      'sign_contract',
      'public_partner_claim',
      'file_legal_or_ip_action',
      'activate_paid_campaign'
    )
  ),
  now()
)
on conflict (policy_key) do update
set enabled = excluded.enabled,
    policy = excluded.policy,
    updated_at = now();

insert into public.merg_opportunity_watch_sources
  (source_key, display_name, source_uri, watch_type, region_key, active, priority, metadata, updated_at)
values
  (
    'powerlux_benelux_sponsorship',
    'PowerLux Benelux Sponsorship',
    'https://www.google.com/search?q=Benelux+sports+sponsorship+clubs+brands',
    'cross_platform',
    'BENELUX',
    true,
    92,
    '{"projects":["PowerLux"],"watch_for":["sponsors","brands","club_partnerships","activation_models"],"value_mode":"money"}'::jsonb,
    now()
  ),
  (
    'powerlux_global_strength_sport',
    'Global Strength Sport Signals',
    'https://www.google.com/search?q=strength+sports+events+athletes+sponsorship+media',
    'cross_platform',
    'GLOBAL',
    true,
    90,
    '{"projects":["PowerLux","PowerTV"],"watch_for":["events","athletes","clubs","sponsorship","media","commercial_activation"],"value_mode":"money_or_knowledge"}'::jsonb,
    now()
  ),
  (
    'merg_creator_monetization',
    'Creator Monetization Signals',
    'https://www.google.com/search?q=creator+monetization+affiliate+sponsorship+social+commerce',
    'cross_platform',
    'GLOBAL',
    true,
    89,
    '{"projects":["MERG","PowerLux","PowerTV"],"watch_for":["instagram","creator","affiliate","sponsor","distribution","conversion"],"value_mode":"money"}'::jsonb,
    now()
  ),
  (
    'powertv_sports_media_rights',
    'Sports Media and Rights Signals',
    'https://www.google.com/search?q=niche+sports+streaming+rights+FAST+AVOD+distribution',
    'cross_platform',
    'GLOBAL',
    true,
    88,
    '{"projects":["PowerTV","PowerLux"],"watch_for":["rights","streaming","distribution","free_ad_supported","niche_sports"],"value_mode":"money_or_knowledge"}'::jsonb,
    now()
  ),
  (
    'eu_sport_funding_programmes',
    'EU Sport Funding Programmes',
    'https://sport.ec.europa.eu/funding',
    'public_program',
    'EU',
    true,
    87,
    '{"projects":["PowerLux"],"watch_for":["grant","erasmus_sport","funding","deadline","eligibility"],"value_mode":"money","verification_rule":"Verify every programme against the official EU source before application or public claim"}'::jsonb,
    now()
  ),
  (
    'cogni_ai_sports_technology',
    'AI Sports Technology Research',
    'https://www.google.com/search?q=AI+sports+technology+computer+vision+analytics+agents+research',
    'cross_platform',
    'GLOBAL',
    true,
    86,
    '{"projects":["Cogni","PowerLux"],"watch_for":["research","analytics","computer_vision","agents","data_products"],"value_mode":"knowledge"}'::jsonb,
    now()
  ),
  (
    'cogni_ai_patent_prior_art',
    'AI Patent and Prior-Art Signals',
    'https://patents.google.com/',
    'cross_platform',
    'GLOBAL',
    true,
    84,
    '{"projects":["Cogni","PowerLux"],"watch_for":["patent","prior_art","licensing","design_around","technical_whitespace"],"value_mode":"knowledge","legal_note":"FTO conclusions remain preliminary until qualified counsel review"}'::jsonb,
    now()
  )
on conflict (source_key) do update
set display_name = excluded.display_name,
    source_uri = excluded.source_uri,
    watch_type = excluded.watch_type,
    region_key = excluded.region_key,
    active = excluded.active,
    priority = excluded.priority,
    metadata = excluded.metadata,
    updated_at = now();
