create table if not exists public.powerlux_content_queue (
  id uuid primary key default gen_random_uuid(),
  content_type text not null default 'event_story',
  source_type text not null default 'event',
  source_id text, source_url text,
  event_title text not null, organization_name text, sport text, city text, event_date timestamptz,
  channels text[] not null default '{}', hook text not null default '',
  caption_de text not null default '', caption_fr text not null default '', caption_en text not null default '',
  shot_list jsonb not null default '[]'::jsonb, media_urls jsonb not null default '[]'::jsonb,
  media_status text not null default 'awaiting_media', rights_status text not null default 'pending',
  approval_status text not null default 'pending_review', status text not null default 'draft',
  scheduled_at timestamptz, published_at timestamptz, work_item_id uuid, created_by uuid, reviewed_by uuid,
  metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint powerlux_content_queue_media_status_chk check (media_status in ('awaiting_media','ready','missing','rejected')),
  constraint powerlux_content_queue_rights_status_chk check (rights_status in ('pending','confirmed','restricted','rejected')),
  constraint powerlux_content_queue_approval_status_chk check (approval_status in ('pending_review','approved','rejected','published')),
  constraint powerlux_content_queue_status_chk check (status in ('draft','queued','scheduled','published','archived'))
);
alter table public.powerlux_content_queue enable row level security;
revoke all on table public.powerlux_content_queue from anon, authenticated;
create index if not exists powerlux_content_queue_status_idx on public.powerlux_content_queue (approval_status,status,scheduled_at);
create index if not exists powerlux_content_queue_source_idx on public.powerlux_content_queue (source_type,source_id);