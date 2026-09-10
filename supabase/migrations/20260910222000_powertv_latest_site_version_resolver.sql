-- PowerTV latest-site resolver.
-- Fail closed: no frontend target is returned unless the candidate is explicitly verified
-- and contains every required feature marker. Identity/name/old URLs are insufficient.

create table if not exists public.powertv_site_versions (
  id uuid primary key default gen_random_uuid(),
  site_url text not null unique,
  site_label text,
  surface text not null default 'chatgpt_sites',
  status text not null default 'candidate' check (status in ('candidate','latest_canonical','stale','blocked')),
  feature_fingerprint jsonb not null default '{}'::jsonb,
  discovered_at timestamptz not null default now(),
  last_verified_at timestamptz,
  verification_source text,
  source_ref text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.powertv_site_policy (
  policy_key text primary key,
  required_features text[] not null default '{}'::text[],
  selection_rule text not null,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

insert into public.powertv_site_policy(policy_key, required_features, selection_rule, metadata)
values (
  'latest_canonical',
  array['associate_player']::text[],
  'Only a non-stale ChatGPT Sites candidate with every required feature explicitly verified true may become latest_canonical. Prefer newest last_verified_at; never fall back to a stale or feature-incomplete site.',
  jsonb_build_object('version','v1','fail_closed',true,'identity_only_is_insufficient',true)
)
on conflict (policy_key) do update
set required_features=excluded.required_features,
    selection_rule=excluded.selection_rule,
    metadata=excluded.metadata,
    updated_at=now();

create or replace function public.powertv_site_has_required_features(p_features jsonb)
returns boolean
language sql
stable
set search_path=public
as $$
  select not exists (
    select 1
    from unnest(coalesce((select required_features from public.powertv_site_policy where policy_key='latest_canonical'), '{}'::text[])) as f(feature)
    where coalesce((p_features ->> f.feature)::boolean, false) is not true
  );
$$;

create or replace function public.powertv_resolve_latest_site()
returns table(
  site_url text,
  site_label text,
  status text,
  feature_fingerprint jsonb,
  last_verified_at timestamptz,
  verification_source text,
  source_ref text
)
language sql
stable
set search_path=public
as $$
  select v.site_url,v.site_label,v.status,v.feature_fingerprint,v.last_verified_at,v.verification_source,v.source_ref
  from public.powertv_site_versions v
  where v.status not in ('stale','blocked')
    and v.last_verified_at is not null
    and public.powertv_site_has_required_features(v.feature_fingerprint)
  order by (v.status='latest_canonical') desc, v.last_verified_at desc, v.updated_at desc
  limit 1;
$$;

create or replace function public.powertv_promote_latest_site(
  p_site_url text,
  p_site_label text,
  p_feature_fingerprint jsonb,
  p_verification_source text,
  p_source_ref text default null,
  p_verified_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path=public
as $$
declare
  v_id uuid;
begin
  if p_site_url is null or btrim(p_site_url)='' then
    raise exception 'POWERTV_SITE_URL_REQUIRED';
  end if;
  if p_site_url !~ '^https://[^[:space:]]+\.chatgpt\.site/?' then
    raise exception 'POWERTV_SITE_MUST_BE_CHATGPT_SITE';
  end if;
  if not public.powertv_site_has_required_features(coalesce(p_feature_fingerprint,'{}'::jsonb)) then
    raise exception 'POWERTV_REQUIRED_FEATURES_NOT_VERIFIED';
  end if;

  update public.powertv_site_versions
  set status='candidate', updated_at=now()
  where status='latest_canonical' and site_url<>p_site_url;

  insert into public.powertv_site_versions(site_url,site_label,status,feature_fingerprint,last_verified_at,verification_source,source_ref,notes,updated_at)
  values (p_site_url,p_site_label,'latest_canonical',coalesce(p_feature_fingerprint,'{}'::jsonb),p_verified_at,p_verification_source,p_source_ref,'Promoted only after required feature fingerprint passed.',now())
  on conflict(site_url) do update
  set site_label=excluded.site_label,
      status='latest_canonical',
      feature_fingerprint=excluded.feature_fingerprint,
      last_verified_at=excluded.last_verified_at,
      verification_source=excluded.verification_source,
      source_ref=excluded.source_ref,
      notes=excluded.notes,
      updated_at=now()
  returning id into v_id;

  return jsonb_build_object('ok',true,'id',v_id,'site_url',p_site_url,'status','latest_canonical');
end;
$$;

revoke all on function public.powertv_promote_latest_site(text,text,jsonb,text,text,timestamptz) from public, anon, authenticated;
grant execute on function public.powertv_promote_latest_site(text,text,jsonb,text,text,timestamptz) to service_role;

-- User-verified stale version: Associate Player is missing. Never auto-select it.
insert into public.powertv_site_versions(site_url,site_label,status,feature_fingerprint,last_verified_at,verification_source,source_ref,notes)
values (
 'https://powertv-network.lucienne-ruppert.chatgpt.site',
 'PowerTV — Sport jenseits des Mainstreams',
 'stale',
 jsonb_build_object('associate_player',false,'catalog_present',true,'rights_safe_backend_known',true),
 now(),
 'user_verified_feature_mismatch',
 'conversation:2026-09-10',
 'Older PowerTV page: Associate Player is missing. Never auto-select as latest canonical.'
)
on conflict(site_url) do update
set status='stale',
    feature_fingerprint=excluded.feature_fingerprint,
    last_verified_at=excluded.last_verified_at,
    verification_source=excluded.verification_source,
    source_ref=excluded.source_ref,
    notes=excluded.notes,
    updated_at=now();
