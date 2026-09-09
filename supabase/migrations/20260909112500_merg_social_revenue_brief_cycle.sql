-- Convert verified MERG Value Engine MONEY work items into fact-bound social revenue briefs.
-- This is an internal drafting layer only. It never publishes content or executes external actions.

create or replace function public.merg_social_revenue_brief_cycle()
returns jsonb
language plpgsql
set search_path = public, pg_temp
as $$
declare
  r record;
  v_created integer := 0;
  v_seen integer := 0;
  v_objective text;
  v_cta text;
  v_audience text;
  v_clean_title text;
  v_caption text;
  v_policy_enabled boolean := false;
begin
  select enabled
    into v_policy_enabled
  from public.merg_ai_policy
  where policy_key = 'value_engine';

  if coalesce(v_policy_enabled, false) is not true then
    return jsonb_build_object(
      'ok', true,
      'skipped', true,
      'reason', 'value_engine_policy_disabled',
      'created_social_briefs', 0
    );
  end if;

  for r in
    select w.*
    from public.core_engine_work_items w
    where w.engine = 'money'
      and w.item_type = 'value_opportunity'
      and w.payload ->> 'created_by_cycle' = 'merg_value_engine_cycle'
      and w.payload ->> 'value_mode' = 'MONEY'
      and not (w.draft ? 'social_revenue_brief')
      and w.status in ('inbox','reviewing','draft','ready_for_decision')
    order by w.priority desc, w.created_at desc
    limit 60
  loop
    v_seen := v_seen + 1;
    v_clean_title := regexp_replace(r.title, '^MONEY\s*[·:-]\s*', '', 'i');

    v_objective := case r.payload ->> 'opportunity_type'
      when 'referral' then 'affiliate_or_referral_conversion'
      when 'sponsorship' then 'sponsor_lead_generation'
      when 'visibility' then 'audience_growth_and_lead_capture'
      when 'supplier_deal' then 'buyer_demand_capture_before_commitment'
      when 'surplus' then 'buyer_demand_capture_before_inventory'
      when 'cross_benefit' then 'cross_project_lead_generation'
      else 'qualified_lead_capture'
    end;

    v_audience := case r.payload ->> 'opportunity_type'
      when 'referral' then 'people or businesses with a real need for the verified offer'
      when 'sponsorship' then 'brands, sponsors and commercial partners'
      when 'supplier_deal' then 'qualified buyers, retailers, resellers or institutional customers'
      when 'surplus' then 'qualified buyers, resellers and price-sensitive customers'
      else 'the audience with the strongest verified problem/need fit'
    end;

    v_cta := case r.payload ->> 'opportunity_type'
      when 'referral' then 'DM "INFO" for the verified conditions; use a tracked link only after partner approval.'
      when 'sponsorship' then 'DM "PARTNER" for a measurable activation proposal.'
      when 'supplier_deal' then 'DM "BUYER" if there is real purchasing interest; no stock commitment is implied.'
      when 'surplus' then 'DM "BUYER" if there is real purchasing interest; source and landed economics are verified before any deal.'
      else 'DM "INFO" if this is relevant; facts and conditions are verified before any recommendation.'
    end;

    v_caption := left(
      'Neue Chance im Blick: ' || v_clean_title || '. ' ||
      'Wir prüfen Quelle, Bedingungen und echten wirtschaftlichen Nutzen, bevor wir daraus eine Empfehlung oder ein Angebot machen. ' ||
      v_cta,
      2000
    );

    update public.core_engine_work_items
    set draft = coalesce(draft, '{}'::jsonb) || jsonb_build_object(
      'social_revenue_brief', jsonb_build_object(
        'status', 'DRAFT_READY_FOR_REVIEW',
        'primary_channel', 'instagram',
        'secondary_channels', jsonb_build_array('linkedin','facebook'),
        'objective', v_objective,
        'target_audience', v_audience,
        'hook', left(v_clean_title, 180),
        'caption_draft', v_caption,
        'cta', v_cta,
        'source_uri', r.payload ->> 'source_uri',
        'monetization_hypothesis', r.payload ->> 'monetization_hypothesis',
        'kpis', jsonb_build_array(
          'qualified_dms',
          'tracked_clicks',
          'qualified_leads',
          'conversions',
          'attributed_revenue_eur'
        ),
        'claims_rule', 'Do not claim partnership, availability, price, savings, results or endorsement unless independently verified.',
        'rights_rule', 'Use only owned, licensed or rights-cleared media.',
        'publish_gate', 'human approval + source verification + real authenticated publisher connection',
        'external_execution', false,
        'generated_by', 'merg_social_revenue_brief_cycle',
        'generated_at', now()
      )
    ),
    updated_at = now()
    where id = r.id;

    v_created := v_created + 1;
  end loop;

  insert into public.core_engine_runs (
    engine,
    action,
    status,
    input,
    output,
    duration_ms,
    completed_at
  ) values (
    'money',
    'social_revenue_brief_cycle',
    'success',
    jsonb_build_object('seen_money_items', v_seen),
    jsonb_build_object(
      'created_social_briefs', v_created,
      'external_execution', false,
      'primary_channel', 'instagram'
    ),
    0,
    now()
  );

  return jsonb_build_object(
    'ok', true,
    'seen_money_items', v_seen,
    'created_social_briefs', v_created,
    'external_execution', false,
    'primary_channel', 'instagram'
  );
end;
$$;

revoke all on function public.merg_social_revenue_brief_cycle() from public;
revoke all on function public.merg_social_revenue_brief_cycle() from anon;
revoke all on function public.merg_social_revenue_brief_cycle() from authenticated;

-- Run shortly after the Value Engine cycle so newly-created MONEY items receive a content brief.
do $$
begin
  if exists (select 1 from cron.job where jobname = 'merg-social-revenue-brief-cycle') then
    perform cron.unschedule('merg-social-revenue-brief-cycle');
  end if;
end;
$$;

select cron.schedule(
  'merg-social-revenue-brief-cycle',
  '12,42 * * * *',
  'select public.merg_social_revenue_brief_cycle();'
);
