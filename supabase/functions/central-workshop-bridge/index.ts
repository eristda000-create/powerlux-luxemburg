import { withSupabase } from 'npm:@supabase/server';

type WorkshopRequest = {
  action?: 'heartbeat' | 'self_test' | 'claim_next' | 'complete';
  payload?: Record<string, unknown>;
};

const json = (body: unknown, status = 200) =>
  Response.json(body, {
    status,
    headers: {
      'Cache-Control': 'no-store',
      'X-Central-Bridge': 'v1',
    },
  });

export default {
  fetch: withSupabase({ auth: 'user' }, async (req, ctx) => {
    if (req.method !== 'POST') return json({ ok: false, error: 'method_not_allowed' }, 405);

    const email = ctx.userClaims?.email?.toLowerCase();
    if (!email) return json({ ok: false, error: 'authenticated_email_required' }, 403);

    const { data: owner, error: ownerError } = await ctx.supabaseAdmin
      .from('core_admin_users')
      .select('email,role,enabled')
      .eq('email', email)
      .eq('role', 'owner')
      .eq('enabled', true)
      .maybeSingle();

    if (ownerError) {
      console.error('owner lookup failed', ownerError.message);
      return json({ ok: false, error: 'owner_authorization_check_failed' }, 500);
    }
    if (!owner) return json({ ok: false, error: 'owner_authorization_required' }, 403);

    let body: WorkshopRequest;
    try {
      body = await req.json();
    } catch {
      return json({ ok: false, error: 'invalid_json' }, 400);
    }

    const action = body.action;
    const payload = body.payload ?? {};
    const nodeId = typeof payload.node_id === 'string' ? payload.node_id.trim() : '';

    if (!action) return json({ ok: false, error: 'action_required' }, 400);
    if (action !== 'complete' && !nodeId) return json({ ok: false, error: 'node_id_required' }, 400);

    let rpcName: string;
    let rpcArgs: Record<string, unknown>;

    switch (action) {
      case 'heartbeat':
        rpcName = 'merg_workshop_heartbeat';
        rpcArgs = {
          p_node_id: nodeId,
          p_runtime: typeof payload.runtime === 'object' && payload.runtime !== null ? payload.runtime : {},
        };
        break;
      case 'self_test':
        rpcName = 'merg_workshop_self_test';
        rpcArgs = {
          p_node_id: nodeId,
          p_tests: typeof payload.tests === 'object' && payload.tests !== null ? payload.tests : {},
        };
        break;
      case 'claim_next':
        rpcName = 'merg_workshop_claim_next';
        rpcArgs = { p_node_id: nodeId };
        break;
      case 'complete': {
        const workItemId = typeof payload.work_item_id === 'string' ? payload.work_item_id : '';
        if (!nodeId || !workItemId) return json({ ok: false, error: 'node_id_and_work_item_id_required' }, 400);
        rpcName = 'merg_workshop_complete';
        rpcArgs = {
          p_work_item_id: workItemId,
          p_node_id: nodeId,
          p_result: typeof payload.result === 'object' && payload.result !== null ? payload.result : {},
          p_verified: payload.verified === true,
        };
        break;
      }
      default:
        return json({ ok: false, error: 'unsupported_action' }, 400);
    }

    const { data, error } = await ctx.supabaseAdmin.rpc(rpcName, rpcArgs);
    if (error) {
      console.error('workshop rpc failed', rpcName, error.message);
      return json({ ok: false, error: 'bridge_operation_failed', action }, 400);
    }

    return json({ ok: true, action, data });
  }),
};
