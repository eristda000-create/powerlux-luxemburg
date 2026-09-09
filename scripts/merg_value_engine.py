#!/usr/bin/env python3
"""MERG Value Engine v1.

Scans public discovery feeds, scores opportunities for MONEY / KNOWLEDGE value,
routes them to MERG projects, and emits an auditable action queue.

No external action (posting, outreach, spend, contract, production write) is
performed by this script.
"""

from __future__ import annotations

import email.utils
import hashlib
import html
import json
import re
import sys
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "merg_os" / "value_sources.json"
REPORT_JSON = ROOT / "value_engine_report.json"
REPORT_MD = ROOT / "value_engine_report.md"
QUEUE_NDJSON = ROOT / "value_engine_queue.ndjson"

USER_AGENT = "MERG-Value-Engine/1.0 (+https://github.com/eristda000-create/powerlux-luxemburg)"

MONEY_TERMS = {
    "sponsor": 13, "sponsorship": 13, "partner": 9, "partnership": 10,
    "affiliate": 12, "commission": 12, "revenue": 12, "monetization": 12,
    "funding": 12, "grant": 12, "tender": 11, "supplier": 10, "retail": 9,
    "deal": 10, "marketplace": 8, "ticket": 8, "event": 6, "club": 5,
    "gym": 6, "creator": 6, "advertising": 9, "brand": 5, "rights": 7,
    "launch": 5, "startup": 5, "commerce": 9
}
KNOWLEDGE_TERMS = {
    "research": 12, "study": 10, "patent": 13, "technology": 9, "ai": 9,
    "artificial intelligence": 10, "analytics": 8, "computer vision": 10,
    "regulation": 10, "policy": 8, "trend": 7, "innovation": 9, "platform": 5,
    "streaming": 7, "rights": 7, "data": 6, "model": 6, "algorithm": 9,
    "discovery": 6, "market": 5, "launch": 5, "funding": 5
}
FAST_TERMS = {
    "event": 8, "sponsor": 10, "affiliate": 10, "grant": 6, "tender": 8,
    "launch": 7, "creator": 7, "instagram": 8, "club": 6, "partner": 8
}
RISK_TERMS = {
    "gambling": 25, "betting": 25, "medical": 18, "supplement": 10,
    "copyright": 12, "rights": 7, "lawsuit": 18, "illegal": 30
}

PROJECT_TERMS = {
    "PowerLux": ["sport", "athlete", "club", "armwrestling", "powerlifting", "event", "gym", "sponsor"],
    "PowerTV": ["streaming", "media", "rights", "broadcast", "video", "live", "channel"],
    "Cogni": ["ai", "model", "llm", "research", "patent", "analytics", "automation", "agent"],
    "MERG": ["affiliate", "supplier", "retail", "commerce", "creator", "monetization", "deal", "marketplace"]
}

ROUTE_TERMS = [
    ("ip_fto", ["patent", "prior art", "invention", "licensing"]),
    ("funding_sourcing", ["grant", "funding", "tender", "programme", "program"]),
    ("sales_partnership", ["sponsor", "sponsorship", "partner", "partnership", "club", "brand"]),
    ("powertv_editorial", ["streaming", "broadcast", "media rights", "live event"]),
    ("content_revenue", ["instagram", "creator", "content", "affiliate", "social"]),
    ("product_innovation", ["technology", "platform", "startup", "analytics", "computer vision"]),
    ("research_intelligence", ["research", "study", "regulation", "policy", "trend"])
]

@dataclass
class Candidate:
    id: str
    discovered_at: str
    source_id: str
    source_label: str
    title: str
    url: str
    published_at: str | None
    project: str
    route: str
    outcome: str
    money_score: int
    knowledge_score: int
    synergy_score: int
    speed_score: int
    confidence_score: int
    risk_penalty: int
    priority: int
    evidence_status: str
    next_action: str
    monetization_hypothesis: str
    knowledge_hypothesis: str
    social_draft: dict[str, str]
    tags: list[str]

def clean_text(value: str | None) -> str:
    value = html.unescape(value or "")
    value = re.sub(r"<[^>]+>", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()

def term_score(text: str, table: dict[str, int], base: int = 10) -> int:
    lower = text.lower()
    score = base
    for term, weight in table.items():
        if term in lower:
            score += weight
    return max(0, min(100, score))

def parse_date(value: str | None) -> str | None:
    if not value:
        return None
    try:
        dt = email.utils.parsedate_to_datetime(value)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc).isoformat()
    except Exception:
        return None

def fetch_bytes(url: str, timeout: int = 15) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/rss+xml, application/xml, text/xml, */*"})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return response.read()

def parse_rss(payload: bytes, limit: int) -> list[dict[str, Any]]:
    root = ET.fromstring(payload)
    items: list[dict[str, Any]] = []
    for item in root.findall(".//item")[:limit]:
        items.append({
            "title": clean_text(item.findtext("title")),
            "url": clean_text(item.findtext("link")),
            "published_at": parse_date(item.findtext("pubDate")),
            "description": clean_text(item.findtext("description")),
        })
    if items:
        return items
    ns = {"a": "http://www.w3.org/2005/Atom"}
    for entry in root.findall(".//a:entry", ns)[:limit]:
        link = entry.find("a:link", ns)
        items.append({
            "title": clean_text(entry.findtext("a:title", default="", namespaces=ns)),
            "url": clean_text(link.attrib.get("href") if link is not None else ""),
            "published_at": clean_text(entry.findtext("a:updated", default="", namespaces=ns)) or None,
            "description": clean_text(entry.findtext("a:summary", default="", namespaces=ns)),
        })
    return items

def infer_project(text: str, default_project: str) -> tuple[str, int]:
    lower = text.lower()
    scored: list[tuple[int, str]] = []
    for project, terms in PROJECT_TERMS.items():
        hits = sum(1 for term in terms if term in lower)
        scored.append((hits, project))
    hits, project = max(scored)
    if hits == 0:
        project = default_project
    synergy = min(100, 35 + hits * 12 + (12 if project == default_project else 0))
    return project, synergy

def infer_route(text: str, project: str) -> str:
    lower = text.lower()
    for route, terms in ROUTE_TERMS:
        if any(term in lower for term in terms):
            return route
    if project == "PowerTV":
        return "powertv_editorial"
    if project == "Cogni":
        return "cogni_capability"
    if project == "MERG":
        return "merg_trading"
    return "research_intelligence"

def outcome(money: int, knowledge: int) -> str:
    if money >= 58 and knowledge >= 50:
        return "BOTH"
    if money >= knowledge:
        return "MONEY"
    return "KNOWLEDGE"

def next_action_for(route: str, title: str, project: str) -> str:
    actions = {
        "ip_fto": "Verify the original publication/patent source, map claims/prior art, then define a non-infringing build or licensing hypothesis.",
        "funding_sourcing": "Verify eligibility, deadline and award terms from the official source; if fit is real, create a funding qualification brief.",
        "sales_partnership": "Verify the organization and buyer, define a concrete give/get offer, then prepare a human-approved outreach draft.",
        "powertv_editorial": "Verify event/media-rights facts, then create an editorial package and a monetization/partner angle without implying streaming rights.",
        "content_revenue": "Verify the factual hook, create a rights-safe social post with CTA and define the revenue KPI before scheduling.",
        "product_innovation": "Verify the underlying product/technology, extract the mechanism, then define a fast build/test for PowerLux, PowerTV, Cogni or MERG.",
        "research_intelligence": "Open the original source, extract the non-obvious finding, and convert it into one decision or experiment.",
        "cogni_capability": "Translate the finding into a Cogni capability hypothesis and test it against the canonical multi-model architecture.",
        "merg_trading": "Validate buyer/supplier economics and legal feasibility before creating a sourcing or affiliate execution path."
    }
    return actions.get(route, f"Verify the source and convert '{title}' into one measurable {project} action.")

def hypotheses(route: str, project: str, title: str) -> tuple[str, str]:
    money = {
        "funding_sourcing": "Potential non-dilutive funding if eligibility and deadline fit are verified.",
        "sales_partnership": "Potential sponsor/partner lead if there is a real economic buyer and a measurable activation offer.",
        "content_revenue": "Potential audience-to-lead, affiliate or sponsor conversion if a tracked CTA is attached.",
        "powertv_editorial": "Potential audience, sponsor inventory or referral value without assuming media rights.",
        "product_innovation": "Potential product differentiation or paid feature if a fast validation proves user value.",
        "ip_fto": "Potential defensible product/IP value if prior art and FTO constraints leave a viable design space.",
        "merg_trading": "Potential margin or commission if buyer intent, supplier terms and fulfillment economics validate."
    }.get(route, "Potential commercial value if the signal converts into a real buyer, cost saving or product advantage.")
    knowledge = {
        "ip_fto": "May reveal prior art, claim boundaries, whitespace or design-around options.",
        "research_intelligence": "May reveal a market, regulatory, technical or behavioral fact that changes a decision.",
        "product_innovation": "May reveal a reusable mechanism, UX pattern, data source or business-model primitive.",
        "cogni_capability": "May reveal a solver/orchestration/memory capability that improves Cogni.",
        "powertv_editorial": "May reveal rights, format, audience or distribution patterns relevant to PowerTV."
    }.get(route, f"May reveal a useful fact or pattern for {project}.")
    return money, knowledge

def social_draft(title: str, url: str, project: str, route: str) -> dict[str, str]:
    hook = title[:180]
    if route == "content_revenue":
        cta = "CTA: Save/share for reach, then route qualified interest to the relevant PowerLux/MERG offer or tracked affiliate path."
    elif route == "sales_partnership":
        cta = "CTA: Invite clubs/brands/organizers to discuss a measurable activation."
    elif project == "PowerTV":
        cta = "CTA: Drive viewers to the verified event/editorial page or official rights-holder destination."
    elif project == "Cogni":
        cta = "CTA: Turn the finding into a testable Cogni capability or research brief."
    else:
        cta = "CTA: Convert attention into a qualified inquiry, partner conversation or evidence-backed next step."
    caption = f"{hook}\n\nWhy it matters for {project}: this signal may create either commercial leverage or a useful decision advantage. We verify the original source before making a public claim.\n\n{cta}"
    return {
        "channel": "instagram",
        "status": "DRAFT_ONLY_PUBLISHER_NOT_CONNECTED",
        "caption": caption,
        "evidence_url": url,
        "rights_rule": "Use owned/licensed media only; source URL is evidence, not a media license."
    }

def make_candidate(source: dict[str, Any], item: dict[str, Any]) -> Candidate | None:
    title = clean_text(item.get("title"))
    url = clean_text(item.get("url"))
    description = clean_text(item.get("description"))
    if len(title) < 4 or not url.startswith(("http://", "https://")):
        return None
    tags = [str(x).lower() for x in source.get("tags", [])]
    text = " ".join([title, description, " ".join(tags)])
    money = term_score(text, MONEY_TERMS, base=12)
    knowledge = term_score(text, KNOWLEDGE_TERMS, base=14)
    speed = term_score(text, FAST_TERMS, base=35)
    risk = max(0, term_score(text, RISK_TERMS, base=0))
    project, synergy = infer_project(text, source.get("default_project", "MERG"))
    route = infer_route(text, project)
    confidence = 58 + (8 if item.get("published_at") else 0) + (8 if len(description) > 40 else 0)
    confidence = min(90, confidence)
    raw = 0.35 * money + 0.30 * knowledge + 0.15 * synergy + 0.10 * speed + 0.10 * confidence - 0.25 * risk
    priority = max(0, min(100, round(raw)))
    money_h, knowledge_h = hypotheses(route, project, title)
    digest = hashlib.sha256(f"{source.get('id')}|{title.lower()}|{url}".encode()).hexdigest()[:16]
    return Candidate(
        id=f"ve_{digest}",
        discovered_at=datetime.now(timezone.utc).isoformat(),
        source_id=source.get("id", "unknown"),
        source_label=source.get("label", source.get("id", "unknown")),
        title=title,
        url=url,
        published_at=item.get("published_at"),
        project=project,
        route=route,
        outcome=outcome(money, knowledge),
        money_score=money,
        knowledge_score=knowledge,
        synergy_score=synergy,
        speed_score=speed,
        confidence_score=confidence,
        risk_penalty=risk,
        priority=priority,
        evidence_status="DISCOVERY_SIGNAL_NEEDS_ORIGINAL_SOURCE_VERIFICATION",
        next_action=next_action_for(route, title, project),
        monetization_hypothesis=money_h,
        knowledge_hypothesis=knowledge_h,
        social_draft=social_draft(title, url, project, route),
        tags=tags,
    )

def render_markdown(candidates: list[Candidate], source_status: list[dict[str, Any]], threshold: int) -> str:
    now = datetime.now(timezone.utc).isoformat()
    actionable = [c for c in candidates if c.priority >= threshold]
    lines = [
        "# MERG Value Engine — Action Queue",
        "",
        f"Generated: `{now}`",
        f"Actionable threshold: `{threshold}`",
        f"Candidates: `{len(candidates)}` · Actionable: `{len(actionable)}`",
        "",
        "> Discovery signals are not verified commercial facts. Open the original source before public claims, spend, contracts or production changes.",
        "",
        "## Top opportunities",
        ""
    ]
    for index, c in enumerate(actionable[:12], 1):
        lines += [
            f"### {index}. [{c.project}] {c.title}",
            f"- **Outcome:** `{c.outcome}` · **Route:** `{c.route}` · **Priority:** `{c.priority}/100`",
            f"- **Scores:** money {c.money_score} · knowledge {c.knowledge_score} · synergy {c.synergy_score} · speed {c.speed_score} · confidence {c.confidence_score} · risk {c.risk_penalty}",
            f"- **Source:** {c.url}",
            f"- **Money hypothesis:** {c.monetization_hypothesis}",
            f"- **Knowledge hypothesis:** {c.knowledge_hypothesis}",
            f"- **Next action:** {c.next_action}",
            f"- **Instagram draft status:** `{c.social_draft['status']}`",
            "",
        ]
    if not actionable:
        lines += ["No candidate cleared the action threshold in this run.", ""]
    lines += ["## Source health", ""]
    for s in source_status:
        lines.append(f"- `{s['source_id']}` — {s['status']} · items={s.get('items', 0)}" + (f" · {s['error']}" if s.get("error") else ""))
    lines += [
        "",
        "## Engine rule",
        "Every queued item must produce MONEY, KNOWLEDGE or BOTH. External publishing/sending/spend remains gated until the real execution adapter and approval policy are connected.",
        ""
    ]
    return "\n".join(lines)

def main() -> int:
    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    limit = int(config.get("max_items_per_source", 10))
    threshold = int(config.get("minimum_priority", 48))
    candidates_by_id: dict[str, Candidate] = {}
    source_status: list[dict[str, Any]] = []

    for source in config.get("sources", []):
        sid = source.get("id", "unknown")
        try:
            payload = fetch_bytes(source["url"])
            items = parse_rss(payload, limit)
            accepted = 0
            for item in items:
                candidate = make_candidate(source, item)
                if candidate:
                    candidates_by_id[candidate.id] = candidate
                    accepted += 1
            source_status.append({"source_id": sid, "status": "OK", "items": accepted})
        except Exception as exc:
            source_status.append({"source_id": sid, "status": "UNVERIFIED", "items": 0, "error": str(exc)[:180]})

    candidates = sorted(candidates_by_id.values(), key=lambda c: (c.priority, c.money_score + c.knowledge_score), reverse=True)
    actionable = [c for c in candidates if c.priority >= threshold]
    result = {
        "engine": "MERG Value Engine",
        "version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "rule": "Every queued item must produce MONEY, KNOWLEDGE or BOTH.",
        "discovery_only": True,
        "minimum_priority": threshold,
        "candidate_count": len(candidates),
        "actionable_count": len(actionable),
        "source_status": source_status,
        "candidates": [asdict(c) for c in candidates[:50]]
    }

    REPORT_JSON.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    REPORT_MD.write_text(render_markdown(candidates, source_status, threshold), encoding="utf-8")
    with QUEUE_NDJSON.open("w", encoding="utf-8") as handle:
        for candidate in actionable:
            handle.write(json.dumps(asdict(candidate), ensure_ascii=False) + "\n")

    print(json.dumps({
        "candidate_count": len(candidates),
        "actionable_count": len(actionable),
        "sources_ok": sum(1 for s in source_status if s["status"] == "OK"),
        "sources_unverified": sum(1 for s in source_status if s["status"] != "OK"),
        "report": str(REPORT_MD.name)
    }))
    return 2 if source_status and all(s["status"] != "OK" for s in source_status) else 0

if __name__ == "__main__":
    sys.exit(main())
