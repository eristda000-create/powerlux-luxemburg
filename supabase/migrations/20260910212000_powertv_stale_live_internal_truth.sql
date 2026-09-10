-- PowerTV stale-live internal truth guard
-- Ended live rows must be marked ended even when they were already unpublished.

create or replace function public.powertv_expire_stale_live()
returns integer
language plpgsql
set search_path to 'public'
as $function$
declare
  v_count integer := 0;
begin
  update public.powertv_content
     set is_published = false,
         badge = 'EVENT ENDED',
         metadata = coalesce(metadata, '{}'::jsonb) || jsonb_build_object(
           'live_verified', false,
           'lifecycle_status', 'ended',
           'expired_at', now()
         ),
         updated_at = now()
   where content_type = 'live'
     and ends_at is not null
     and ends_at < now()
     and (
       is_published = true
       or badge is distinct from 'EVENT ENDED'
       or coalesce(metadata->>'lifecycle_status','') <> 'ended'
       or coalesce(metadata->>'live_verified','false') <> 'false'
     );

  get diagnostics v_count = row_count;
  return v_count;
end;
$function$;
