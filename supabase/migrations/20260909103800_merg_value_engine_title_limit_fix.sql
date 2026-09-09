-- Fix MERG Value Engine work-item titles to the canonical 180-char constraint.

create or replace function public.merg_value_engine_cycle()
returns jsonb
language plpgsql
set search_path = public, pg_temp
as $$
declare
  r record;
  v_priority integer;
  v_created_money integer := 0;
  v_created_knowledge integer := 0;
  v_seen_money integer := 0;
  v_seen_knowledge integer := 0;
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
      'created_money', 0,
      'created_knowledge', 0
    );
  end if;

  for r in
    select
      o.*,
      least(
        100,
        greatest(
          0,
          round(
              0.35 * coalesce(o.revenue_score, 0)
            + 0.15 * coalesce(o.savings_score, 0)
            + 0.20 * coalesce(o.impact_score, 0)
            + 0.15 * coalesce(o.urgency_score, 0)
            + 0.10 * (coalesce(o.confidence, 0) * 100)
            + 0.05 * coalesce(o.social_impact_score, 0)
            - 0.10 * coalesce(o.effort_score, 0)
          )::integer
        )
      ) as value_priority
    from public.merg_opportunities o
    where o.status in ('new','review','contact','negotiating')
      and (o.valid_until is null or o.valid_until > now())
    order by value_priority desc, o.discovered_at desc
    limit 24
  loop
    v_seen_money := v_seen_money + 1;
    v_priority := r.value_priority;

    if v_priority >= 48
       and not exists (
         select 1
         from public.core_engine_work_items w
         where w.payload ->> 'value_engine_key' = 'opp:' || r.opportunity_key
       )
    then
      insert into public.core_engine_work_items (
        engine,
        item_type,
        title,
        summary,
        status,
        priority,
        payload,
        draft,
        assigned_to
      ) values (
        'money',
        'value_opportunity',
        left('MONEY · ' || r.title, 180),
        left(
          coalesce(nullif(r.summary,''), 'Verify the source, validate economics and execute the next low-risk commercial step.'),
          4000
        ),
        'inbox',
        v_priority,
        jsonb_build_object(
          'value_engine_key', 'opp:' || r.opportunity_key,
          'value_mode', 'MONEY',
          'opportunity_id', r.id,
          'opportunity_key', r.opportunity_key,
          'opportunity_type', r.opportunity_type,
          'source_uri', r.source_uri,
          'evidence', r.evidence,
          'confidence', r.confidence,
          'scores', jsonb_build_object(
            'priority', v_priority,
            'revenue', r.revenue_score,
            'savings', r.savings_score,
            'impact', r.impact_score,
            'social_impact', r.social_impact_score,
            'urgency', r.urgency_score,
            'effort', r.effort_score
          ),
          'requires_human', r.requires_human,
          'next_action', coalesce(r.metadata ->> 'next_action', r.metadata ->> 'owner_action', 'Verify source/economics and prepare the next policy-compliant action.'),
          'monetization_hypothesis', coalesce(r.metadata ->> 'monetization_path', r.metadata ->> 'revenue_route', r.metadata ->> 'commercial_model', 'Convert the verified opportunity into revenue, savings or a qualified lead.'),
          'created_by_cycle', 'merg_value_engine_cycle'
        ),
        jsonb_build_object(
          'external_execution', false,
          'human_gate', r.requires_human,
          'rule', 'No purchase, price acceptance, contract, new outreach or public partner claim is executed by this cycle.'
        ),
        'MERG Value Engine'
      );
      v_created_money := v_created_money + 1;
    end if;
  end loop;

  for r in
    select e.*
    from public.merg_intelligence_events e
    where e.observed_at >= now() - interval '14 days'
    order by e.observed_at desc
    limit 40
  loop
    v_seen_knowledge := v_seen_knowledge + 1;

    v_priority := case
      when r.event_type in ('payment_blocker','policy_correction') then 72
      when r.event_type in ('commercial_reply','partner_outreach') then 55
      else 62
    end;

    if not exists (
      select 1
      from public.core_engine_work_items w
      where w.payload ->> 'value_engine_key' = 'intel:' || r.event_key
    ) then
      insert into public.core_engine_work_items (
        engine,
        item_type,
        title,
        summary,
        status,
        priority,
        payload,
        draft,
        assigned_to
      ) values (
        'intelligence',
        'value_knowledge',
        left('KNOWLEDGE · ' || r.summary, 180),
        left(r.summary, 4000),
        'inbox',
        v_priority,
        jsonb_build_object(
          'value_engine_key', 'intel:' || r.event_key,
          'value_mode', 'KNOWLEDGE',
          'event_id', r.id,
          'event_key', r.event_key,
          'event_type', r.event_type,
          'entity_type', r.entity_type,
          'entity_ref', r.entity_ref,
          'evidence', r.evidence,
          'observed_at', r.observed_at,
          'knowledge_hypothesis', 'Use this evidence to change a decision, avoid repeated failure, identify a new test, or improve a commercial/product system.',
          'falsification_question', 'What new evidence would make this insight no longer actionable?',
          'created_by_cycle', 'merg_value_engine_cycle'
        ),
        jsonb_build_object(
          'external_execution', false,
          'next_step', 'Distill the non-obvious lesson and link it to one measurable decision or experiment.'
        ),
        'MERG Value Engine'
      );
      v_created_knowledge := v_created_knowledge + 1;
    end if;
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
    'value',
    'money_or_knowledge_cycle',
    'success',
    jsonb_build_object(
      'seen_money_candidates', v_seen_money,
      'seen_intelligence_events', v_seen_knowledge
    ),
    jsonb_build_object(
      'created_money', v_created_money,
      'created_knowledge', v_created_knowledge,
      'external_execution', false
    ),
    0,
    now()
  );

  return jsonb_build_object(
    'ok', true,
    'seen_money_candidates', v_seen_money,
    'seen_intelligence_events', v_seen_knowledge,
    'created_money', v_created_money,
    'created_knowledge', v_created_knowledge,
    'external_execution', false
  );
end;
$$;

revoke all on function public.merg_value_engine_cycle() from public;
revoke all on function public.merg_value_engine_cycle() from anon;
revoke all on function public.merg_value_engine_cycle() from authenticated;
