
import { createClient } from 'npm:@supabase/supabase-js@^2.95.0'

const PROJECT_ID = 'fgkowgpauqexcwwtrxyd'
const ALLOWED_CHANNELS = new Set(['instagram','tiktok','facebook','linkedin','newsletter','powertv'])
const OFFER_ASSUMPTIONS: Record<string, { min: number; max: number; label: string }> = {
  community_activation: { min: 3000, max: 8000, label: 'Community Sport Activation' },
  content_sponsor: { min: 750, max: 3000, label: 'Content & Sponsor Activation' },
  workshop: { min: 1500, max: 6000, label: 'Partner Workshop / Course' },
  athlete_day: { min: 2500, max: 9000, label: 'Athlete & Talent Day' },
}

function responseHeaders(req: Request) {
  const origin = req.headers.get('origin') || ''
  const allowed =
    origin === 'https://powerlux-luxembourg.vercel.app' ||
    /^https:\/\/powerlux-luxembourg-[a-z0-9-]+\.vercel\.app$/i.test(origin) ||
    /^https:\/\/[a-z0-9-]+\.supabase\.co$/i.test(origin) ||
    /^http:\/\/localhost(?::\d+)?$/i.test(origin)
  return {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    'Vary': 'Origin',
    'Access-Control-Allow-Origin': allowed ? origin : 'https://powerlux-luxembourg.vercel.app',
    'Access-Control-Allow-Headers': 'authorization, content-type, apikey',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  }
}

function serviceKey() {
  const raw = Deno.env.get('SUPABASE_SECRET_KEYS')
  if (raw) {
    try {
      const parsed = JSON.parse(raw)
      if (typeof parsed?.default === 'string') return parsed.default
      const first = Object.values(parsed || {}).find((v) => typeof v === 'string')
      if (typeof first === 'string') return first
    } catch {}
  }
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (key) return key
  throw new Error('server_credential_unavailable')
}

function str(value: unknown, max = 500) {
  return typeof value === 'string' ? value.trim().slice(0, max) : ''
}

function nullable(value: unknown, max = 500) {
  const result = str(value, max)
  return result || null
}

function safeUrl(value: unknown) {
  const result = str(value, 500)
  return !result || /^https?:\/\/\S+$/i.test(result) ? result || null : null
}

function clamp(value: unknown, min: number, max: number, fallback: number) {
  const number = Number(value)
  return Number.isFinite(number) ? Math.max(min, Math.min(max, Math.round(number))) : fallback
}

function channels(value: unknown) {
  const requested = Array.isArray(value) ? value : ['instagram', 'tiktok', 'linkedin', 'powertv']
  return [...new Set(requested.map((x) => str(x, 30).toLowerCase()).filter((x) => ALLOWED_CHANNELS.has(x)))].slice(0, 8)
}

async function requireAdmin(req: Request, admin: any) {
  const token = (req.headers.get('authorization') || '').replace(/^Bearer\s+/i, '').trim()
  if (!token) return null
  const userResult = await admin.auth.getUser(token)
  const user = userResult.data?.user
  const email = String(user?.email || '').toLowerCase()
  if (!user || !email) return null
  const adminResult = await admin.from('core_admin_users').select('email,role,enabled').eq('email', email).eq('enabled', true).maybeSingle()
  return adminResult.data ? { id: user.id, email, role: adminResult.data.role || 'owner' } : null
}

function shotList(event: { title: string; organization: string; sport: string }) {
  return [
    'Wide: Venue, club or event environment with location proof',
    'Action: 3 vertical 9:16 moments with athlete/participant consent',
    'Human: Coach, club or organizer quote with name and role',
    'Partner: One clean sponsor/brand integration without false claims',
    'Close: PowerLux CTA and next action, not a fabricated result',
  ]
}

function captions(event: { title: string; organization: string; sport: string; city: string }) {
  const place = event.city || 'Luxemburg'
  const club = event.organization ? ' · ' + event.organization : ''
  return {
    de: 'PowerLux bei ' + event.title + ' in ' + place + club + '. ' + event.sport + ' sichtbar machen, Clubs verbinden und den nächsten Schritt öffnen. Fakten und Medien werden vor Veröffentlichung geprüft.',
    fr: 'PowerLux à ' + event.title + ' à ' + place + club + '. Mettre le sport en lumière, connecter les clubs et ouvrir la prochaine étape. Les faits et les médias sont vérifiés avant publication.',
    en: 'PowerLux at ' + event.title + ' in ' + place + club + '. Make the sport visible, connect clubs and open the next step. Facts and media are checked before publishing.',
  }
}

function json(data: unknown, status: number, headers: Record<string, string>) {
  return new Response(JSON.stringify(data), { status, headers })
}

Deno.serve(async (req: Request) => {
  const headers = responseHeaders(req)
  if (req.method === 'OPTIONS') return new Response('ok', { headers })
  if (req.method !== 'POST' && req.method !== 'GET') return json({ error: 'method_not_allowed' }, 405, headers)

  try {
    const url = Deno.env.get('SUPABASE_URL')
    if (!url) throw new Error('project_url_unavailable')
    const admin = createClient(url, serviceKey(), { auth: { persistSession: false, autoRefreshToken: false } })
    const actor = await requireAdmin(req, admin)
    if (!actor) return json({ error: 'admin_auth_required' }, 401, headers)

    const body = req.method === 'GET' ? {} : await req.json().catch(() => ({}))
    const action = str(body?.action || 'list', 40).toLowerCase()

    if (action === 'list') {
      const limit = clamp(body?.limit, 1, 100, 30)
      let query = admin.from('powerlux_content_queue').select('*').order('created_at', { ascending: false }).limit(limit)
      if (str(body?.status, 40)) query = query.eq('status', str(body.status, 40))
      if (str(body?.approval_status, 40)) query = query.eq('approval_status', str(body.approval_status, 40))
      const result = await query
      if (result.error) throw result.error
      return json({ ok: true, items: result.data || [], actor: { email: actor.email, role: actor.role } }, 200, headers)
    }

    if (action === 'metrics') {
      const result = await admin.from('powerlux_content_queue').select('id,status,approval_status,rights_status,media_status', { count: 'exact' })
      if (result.error) throw result.error
      const items = result.data || []
      const count = (field: string, value: string) => items.filter((x: any) => x[field] === value).length
      return json({
        ok: true,
        total: items.length,
        pending_review: count('approval_status', 'pending_review'),
        approved: count('approval_status', 'approved'),
        awaiting_media: count('media_status', 'awaiting_media'),
        rights_pending: count('rights_status', 'pending'),
        published: count('status', 'published'),
      }, 200, headers)
    }

    if (action === 'create_from_event') {
      const event = body?.event || body
      const title = str(event?.event_title || event?.title, 180)
      const organization = str(event?.organization_name || event?.club_name || event?.club, 160)
      const sport = str(event?.sport, 80) || 'Strength sport'
      const city = str(event?.city || event?.location, 120)
      const sourceUrl = safeUrl(event?.source_url || event?.website_url)
      const eventDateRaw = str(event?.event_date || event?.date, 60)
      const parsedDate = eventDateRaw ? new Date(eventDateRaw) : null
      const eventDate = parsedDate && !Number.isNaN(parsedDate.getTime()) ? parsedDate.toISOString() : null
      if (title.length < 3) return json({ error: 'event_title_required' }, 400, headers)
      if (eventDateRaw && !eventDate) return json({ error: 'event_date_invalid' }, 400, headers)
      const hasRights = event?.rights_confirmed === true
      const mediaUrls = Array.isArray(event?.media_urls) ? event.media_urls.map((x: unknown) => safeUrl(x)).filter(Boolean).slice(0, 10) : []
      const channelsRequested = channels(event?.channels)
      const eventShape = { title, organization, sport, city }
      const copy = captions(eventShape)
      const shot = shotList(eventShape)
      const baseMetadata = {
        claims_policy: 'Only publish verified event facts and rights-cleared media.',
        evidence_status: sourceUrl ? 'source_attached' : 'source_missing',
        source_url: sourceUrl,
        created_by: actor.email,
        requires_human_approval: true,
      }
      const rows = [
        {
          content_type: 'event_story',
          hook: 'Event proof + next action',
          channels: channelsRequested,
          caption_de: copy.de,
          caption_fr: copy.fr,
          caption_en: copy.en,
        },
        {
          content_type: 'short_video',
          hook: '15–45 sec vertical highlight built from supplied footage',
          channels: channelsRequested.filter((x) => ['instagram', 'tiktok', 'facebook', 'powertv'].includes(x)),
          caption_de: copy.de,
          caption_fr: copy.fr,
          caption_en: copy.en,
        },
        {
          content_type: 'club_feature',
          hook: 'Club story, coach quote and local entry point',
          channels: ['instagram', 'linkedin', 'powertv'],
          caption_de: copy.de,
          caption_fr: copy.fr,
          caption_en: copy.en,
        },
        {
          content_type: 'sponsor_slot',
          hook: 'Measured partner placement with disclosure',
          channels: ['instagram', 'linkedin', 'newsletter'],
          caption_de: copy.de + ' Partnerplatzierungen werden nur mit Freigabe und Disclosure veröffentlicht.',
          caption_fr: copy.fr,
          caption_en: copy.en,
        },
      ].map((item) => ({
        ...item,
        source_type: 'event',
        source_id: nullable(event?.source_id || event?.event_id, 120),
        source_url: sourceUrl,
        event_title: title,
        organization_name: organization || null,
        sport,
        city: city || null,
        event_date: eventDate,
        shot_list: shot,
        media_urls: mediaUrls,
        media_status: mediaUrls.length ? 'ready' : 'awaiting_media',
        rights_status: hasRights ? 'confirmed' : 'pending',
        approval_status: 'pending_review',
        status: 'draft',
        metadata: { ...baseMetadata, media_count: mediaUrls.length, rights_confirmed: hasRights },
        created_by: actor.id,
      }))
      const inserted = await admin.from('powerlux_content_queue').insert(rows).select('id,content_type')
      if (inserted.error) throw inserted.error
      const ids = (inserted.data || []).map((x: any) => x.id)
      const work = await admin.from('core_engine_work_items').insert({
        engine: 'money',
        item_type: 'content_opportunity',
        title: 'Content + revenue opportunity: ' + title,
        summary: 'Review event evidence, clear media rights, approve the content pack, then offer a measurable club/sponsor activation.',
        status: 'inbox',
        priority: 76,
        payload: {
          event: { title, organization, sport, city, event_date: eventDate, source_url: sourceUrl },
          content_queue_ids: ids,
          offers: Object.values(OFFER_ASSUMPTIONS),
          next_action: 'human_review_required',
          no_auto_publish: true,
        },
        draft: {
          outreach_subject: 'PowerLux x ' + (organization || title),
          outreach_angle: 'Event recap + club visibility + sponsor-ready content pack',
          approval_required: true,
        },
        assigned_to: 'Money Engine',
        created_by: actor.id,
        updated_by: actor.id,
      }).select('id').single()
      if (work.error) {
        return json({ ok: true, warning: 'content_created_work_item_failed', content_ids: ids, work_item_error: work.error.message }, 207, headers)
      }
      await admin.from('powerlux_content_queue').update({ work_item_id: work.data.id, updated_at: new Date().toISOString() }).in('id', ids)
      await admin.from('core_engine_runs').insert({
        engine: 'money',
        action: 'content_opportunity',
        status: 'success',
        input: { title, organization, source_url: sourceUrl },
        output: { work_item_id: work.data.id, content_ids: ids },
        completed_at: new Date().toISOString(),
        duration_ms: 0,
      })
      return json({ ok: true, event: eventShape, content_ids: ids, work_item_id: work.data.id, rights_required: !hasRights, media_required: mediaUrls.length === 0 }, 201, headers)
    }

    if (action === 'create_opportunity') {
      const organization = str(body?.organization_name || body?.club_name, 160)
      const offerKey = str(body?.offer_key, 60) || 'community_activation'
      if (organization.length < 2) return json({ error: 'organization_required' }, 400, headers)
      const offer = OFFER_ASSUMPTIONS[offerKey] || OFFER_ASSUMPTIONS.community_activation
      const sourceUrl = safeUrl(body?.source_url)
      const work = await admin.from('core_engine_work_items').insert({
        engine: 'money',
        item_type: 'club_content_opportunity',
        title: offer.label + ': ' + organization,
        summary: 'Qualified opportunity requiring a human-approved outreach draft and commercial fit check.',
        status: 'inbox',
        priority: clamp(body?.priority, 50, 95, 74),
        payload: {
          organization_name: organization,
          city: str(body?.city, 120) || null,
          sport: str(body?.sport, 80) || null,
          source_url: sourceUrl,
          offer,
          contact_value: str(body?.contact_value, 255) || null,
          consent_basis: str(body?.consent_basis, 160) || 'not_set',
          next_action: 'draft_outreach_then_human_approval',
          no_auto_send: true,
        },
        draft: {
          subject: 'PowerLux x ' + organization,
          body_angle: 'one local event, one club story, one measurable partner package',
          price_floor_eur: offer.min,
          price_ceiling_eur: offer.max,
          requires_human_approval: true,
        },
        assigned_to: 'Money Engine',
        created_by: actor.id,
        updated_by: actor.id,
      }).select('id,title,priority,status').single()
      if (work.error) throw work.error
      await admin.from('core_engine_runs').insert({
        engine: 'money',
        action: 'club_content_opportunity',
        status: 'success',
        input: { organization, offer_key: offerKey, source_url: sourceUrl },
        output: { work_item_id: work.data.id },
        completed_at: new Date().toISOString(),
        duration_ms: 0,
      })
      return json({ ok: true, opportunity: work.data }, 201, headers)
    }

    if (action === 'attach_media') {
      const ids = Array.isArray(body?.content_ids) ? body.content_ids.map((x: unknown) => str(x, 80)).filter(Boolean).slice(0, 20) : []
      const mediaUrls = Array.isArray(body?.media_urls) ? body.media_urls.map((x: unknown) => safeUrl(x)).filter(Boolean).slice(0, 10) : []
      if (!ids.length || !mediaUrls.length) return json({ error: 'content_ids_and_media_urls_required' }, 400, headers)
      const rightsConfirmed = body?.rights_confirmed === true
      if (!rightsConfirmed) return json({ error: 'rights_confirmation_required' }, 400, headers)
      const result = await admin.from('powerlux_content_queue').update({
        media_urls: mediaUrls,
        media_status: 'ready',
        rights_status: 'confirmed',
        updated_at: new Date().toISOString(),
        metadata: { attached_by: actor.email, attached_at: new Date().toISOString() },
      }).in('id', ids).select('id,media_status,rights_status')
      if (result.error) throw result.error
      return json({ ok: true, items: result.data || [] }, 200, headers)
    }

    if (action === 'approve') {
      const ids = Array.isArray(body?.content_ids) ? body.content_ids.map((x: unknown) => str(x, 80)).filter(Boolean).slice(0, 20) : []
      if (!ids.length) return json({ error: 'content_ids_required' }, 400, headers)
      const check = await admin.from('powerlux_content_queue').select('id,media_status,rights_status').in('id', ids)
      if (check.error) throw check.error
      const blocked = (check.data || []).filter((x: any) => x.media_status !== 'ready' || x.rights_status !== 'confirmed')
      if (blocked.length) return json({ error: 'media_and_rights_gate_not_met', blocked_ids: blocked.map((x: any) => x.id) }, 409, headers)
      const result = await admin.from('powerlux_content_queue').update({
        approval_status: 'approved',
        status: 'queued',
        reviewed_by: actor.id,
        updated_at: new Date().toISOString(),
      }).in('id', ids).select('id,approval_status,status')
      if (result.error) throw result.error
      return json({ ok: true, items: result.data || [], publisher: 'not_connected' }, 200, headers)
    }

    return json({ error: 'unknown_action', allowed_actions: ['list','metrics','create_from_event','create_opportunity','attach_media','approve'] }, 400, headers)
  } catch (error) {
    return json({ error: 'content_engine_failed', detail: String((error as any)?.message || error).slice(0, 180) }, 500, headers)
  }
})
