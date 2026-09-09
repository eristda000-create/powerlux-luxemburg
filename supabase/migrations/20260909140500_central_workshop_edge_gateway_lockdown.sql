-- Lock the Workshop RPCs back to server-side callers only.
-- Client authentication/authorization is handled by the central-workshop-bridge Edge Function.

alter function public.merg_workshop_heartbeat(text,jsonb) security invoker;
alter function public.merg_workshop_self_test(text,jsonb) security invoker;
alter function public.merg_workshop_claim_next(text) security invoker;
alter function public.merg_workshop_complete(uuid,text,jsonb,boolean) security invoker;

revoke execute on function public.merg_workshop_heartbeat(text,jsonb) from public, anon, authenticated;
revoke execute on function public.merg_workshop_self_test(text,jsonb) from public, anon, authenticated;
revoke execute on function public.merg_workshop_claim_next(text) from public, anon, authenticated;
revoke execute on function public.merg_workshop_complete(uuid,text,jsonb,boolean) from public, anon, authenticated;
grant execute on function public.merg_workshop_heartbeat(text,jsonb) to service_role;
grant execute on function public.merg_workshop_self_test(text,jsonb) to service_role;
grant execute on function public.merg_workshop_claim_next(text) to service_role;
grant execute on function public.merg_workshop_complete(uuid,text,jsonb,boolean) to service_role;

revoke execute on function public.merg_workshop_authorized_owner() from public, anon, authenticated;

update public.merg_group_channels
set metadata = coalesce(metadata,'{}'::jsonb) || jsonb_build_object(
      'auth_gateway','supabase-edge:central-workshop-bridge',
      'direct_authenticated_rpc',false,
      'server_rpc_service_role_only',true
    ),
    updated_at=now()
where channel_key='central_workshop_local_bridge';
