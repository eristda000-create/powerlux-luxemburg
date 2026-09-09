import importlib.util
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("merg_value_engine", ROOT / "scripts" / "merg_value_engine.py")
ENGINE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
sys.modules[SPEC.name] = ENGINE
SPEC.loader.exec_module(ENGINE)


class ValueEngineTests(unittest.TestCase):
    def test_rss_parsing_and_money_route(self):
        payload = b"""<?xml version='1.0'?><rss><channel>
        <item><title>New sports sponsorship program launches in Benelux</title>
        <link>https://example.com/sponsor</link>
        <pubDate>Wed, 09 Sep 2026 08:00:00 GMT</pubDate>
        <description>Brands partner with clubs and creators on sports events.</description></item>
        </channel></rss>"""
        items = ENGINE.parse_rss(payload, 10)
        self.assertEqual(len(items), 1)
        source = {"id": "test", "label": "test", "default_project": "PowerLux", "tags": ["sport", "revenue"]}
        candidate = ENGINE.make_candidate(source, items[0])
        self.assertIsNotNone(candidate)
        self.assertIn(candidate.outcome, {"MONEY", "KNOWLEDGE", "BOTH"})
        self.assertGreaterEqual(candidate.priority, 0)
        self.assertLessEqual(candidate.priority, 100)
        self.assertTrue(candidate.next_action)
        self.assertEqual(candidate.social_draft["status"], "DRAFT_ONLY_PUBLISHER_NOT_CONNECTED")

    def test_patent_signal_routes_to_ip(self):
        source = {"id": "patent", "label": "patent", "default_project": "Cogni", "tags": ["ai", "research", "patent"]}
        item = {
            "title": "AI patent study for athlete computer vision analytics",
            "url": "https://example.com/patent",
            "published_at": "2026-09-09T07:00:00+00:00",
            "description": "Research into AI models and sports analytics."
        }
        candidate = ENGINE.make_candidate(source, item)
        self.assertEqual(candidate.route, "ip_fto")
        self.assertEqual(candidate.project, "Cogni")
        self.assertIn(candidate.outcome, {"KNOWLEDGE", "BOTH"})

    def test_invalid_url_is_rejected(self):
        source = {"id": "bad", "default_project": "MERG", "tags": []}
        item = {"title": "Affiliate opportunity", "url": "javascript:alert(1)", "description": "revenue"}
        self.assertIsNone(ENGINE.make_candidate(source, item))


if __name__ == "__main__":
    unittest.main()
