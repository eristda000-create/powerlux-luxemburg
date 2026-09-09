create or replace function public.merg_value_feedback_cycle()
returns jsonb
language plpgsql
as $$
declare
  v_started timestamptz := clock_timestamp();
  v_checked int := 0;
  v_updated int := 0;
  v_revenue_cents bigint := 0;
  v_conversion_count int := 0;
  v_payment_count int := 0;
  r record;
  v_opp_key text;
  v_value_key text;
  v_rev_cents bigint;
  v_conversions int;
  v_payments int;
begin
  for r in
    select id, payload
    from public.core_engine_work_items
    where engine = 'money'
      and item_type = 'value_opportunity'
      and coalesce(status,'') not in ('cancelled','archived')
  loop
    v_checked := v_checked + 1;
    v_opp_key := nullif(r.payload->>'opportunity_key','');
    v_value_key := nullif(r.payload->>'value_engine_key','');

    select coalesce(sum(x.amount_cents),0), count(*)
      into v_rev_cents, v_payment_count
    from (
      select greatest(coalesce(mre.powerlux_cents, mre.gross_cents, 0),0)::bigint as amount_cents
      from public.money_revenue_events mre
      where lower(coalesce(mre.status,'')) in ('paid','confirmed','succeeded','completed','settled')
        and (
          mre.metadata->>'work_item_id' = r.id::text
          or (v_value_key is not null and mre.metadata->>'value_engine_key' = v_value_key)
          or (v_opp_key is not null and mre.metadata->>'opportunity_key' = v_opp_key)
        )
      union all
      select greatest(coalesce(mp.amount_cents,0),0)::bigint
      from public.money_payments mp
      where lower(coalesce(mp.status,'')) in ('paid','succeeded','completed','settled')
        and (
          mp.metadata->>'work_item_id' = r.id::text
          or (v_value_key is not null and mp.metadata->>'value_engine_key' = v_value_key)
          or (v_opp_key is not null and mp.metadata->>'opportunity_key' = v_opp_key)
        )
    ) x;

    select count(*)
      into v_conversions
    from public.grocery_partner_conversions gpc
    where lower(coalesce(gpc.status,'')) in ('confirmed','paid','approved','completed')
      and (
        gpc.metadata->>'work_item_id' = r.id::text
        or (v_value_key is not null and gpc.metadata->>'value_engine_key' = v_value_key)
        or (v_opp_key is not null and gpc.metadata->>'opportunity_key' = v_opp_key)
      );

    if v_rev_cents > 0 or v_conversions > 0 or v_payment_count > 0 then
      update public.core_engine_work_items
      set payload = jsonb_set(
            payload,
            '{outcome}',
            coalesce(payload->'outcome','{}'::jsonb) || jsonb_build_object(
              'measurement_status','VERIFIED_ACTIVITY',
              'verified_revenue_cents',v_rev_cents,
              'verified_revenue_eur',round(v_rev_cents::numeric / 100,2),
              'verified_conversions',v_conversions,
              'verified_payment_events',v_payment_count,
              'attribution_rule','explicit_link_only',
              'measured_at',clock_timestamp()
            ),
            true
          ),
          updated_at = clock_timestamp()
      where id = r.id;
      v_updated := v_updated + 1;
      v_revenue_cents := v_revenue_cents + v_rev_cents;
      v_conversion_count := v_conversion_count + v_conversions;
    end if;
  end loop;

  insert into public.core_engine_runs(engine, action, status, input, output, duration_ms, started_at, completed_at)
  values (
    'money',
    'value_feedback_cycle',
    'success',
    jsonb_build_object('attribution_rule','explicit_link_only'),
    jsonb_build_object(
      'checked_money_items',v_checked,
      'updated_items',v_updated,
      'verified_revenue_cents',v_revenue_cents,
      'verified_conversions',v_conversion_count,
      'external_execution',false
    ),
    greatest(0, extract(milliseconds from (clock_timestamp()-v_started))::int),
    v_started,
    clock_timestamp()
  );

  return jsonb_build_object(
    'ok',true,
    'checked_money_items',v_checked,
    'updated_items',v_updated,
    'verified_revenue_cents',v_revenue_cents,
    'verified_conversions',v_conversion_count,
    'external_execution',false,
    'attribution_rule','explicit_link_only'
  );
end;
$$;

revoke all on function public.merg_value_feedback_cycle() from public;
revoke all on function public.merg_value_feedback_cycle() from anon;
revoke all on function public.merg_value_feedback_cycle() from authenticated;

do $$
declare j record;
begin
  for j in select jobid from cron.job where jobname='merg-value-feedback-cycle' loop
    perform cron.unschedule(j.jobid);
  end loop;
  perform cron.schedule(
    'merg-value-feedback-cycle',
    '17,47 * * * *',
    'select public.merg_value_feedback_cycle();'
  );
end $$;
