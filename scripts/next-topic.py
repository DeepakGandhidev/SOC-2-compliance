#!/usr/bin/env python3
"""
Show the guide backlog, and scaffold the next spec.

The writing is the part that cannot be automated — a cron job cannot produce
1,300 words of accurate audit advice, and auto-publishing unreviewed compliance
claims under a named byline is a liability rather than a shortcut. So this
automates everything around the writing: what is next, why it matters, and a
spec skeleton with the headings and FAQ questions already in place.

    ./scripts/next-topic.py                 # backlog status
    ./scripts/next-topic.py --next          # scaffold the next unwritten topic
    ./scripts/next-topic.py --slug <slug>   # scaffold a specific one
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOPICS = ROOT / "scripts" / "topics.json"
GUIDES = ROOT / "scripts" / "guides"


def load():
    d = json.loads(TOPICS.read_text())
    return d["topics"]


def written(slug):
    return (ROOT / "blog" / f"{slug}.html").exists()


def spec_exists(slug):
    return any(
        json.loads(p.read_text()).get("slug") == slug
        for p in GUIDES.glob("*.json")
    )


def status(topics):
    pending = [t for t in topics if not written(t["slug"])]
    ready = [t for t in pending if "defer" not in t]
    live = len(list((ROOT / "blog").glob("*.html"))) - 1

    print(f"Live guides: {live}")
    print(f"Backlog:     {len(ready)} ready, "
          f"{len(pending) - len(ready)} deferred, "
          f"{len(topics) - len(pending)} already written")
    print()

    for i, t in enumerate(topics, 1):
        if written(t["slug"]):
            mark, note = "done   ", ""
        elif "defer" in t:
            mark, note = "DEFER  ", "  <- " + t["defer"].split(":", 1)[-1].strip()[:70]
        else:
            mark, note = "pending", ""
        print(f"  {mark} {i:2}. {t['title']}{note}")

    print()
    if not ready:
        print("Backlog is empty. That is a signal, not a problem:")
        print("  - pull the next topics from Search Console impressions, not from a list")
        print("  - publishing past the end of a real backlog means publishing filler,")
        print("    which is what Google's scaled content abuse policy exists to catch")
        return
    nxt = ready[0]
    print(f"Next up: {nxt['title']}")
    print(f"  why:   {nxt['intent']}")
    print(f"  angle: {nxt['angle']}")
    print()
    print("Scaffold it with:  ./scripts/next-topic.py --next")


def scaffold(t):
    slug = t["slug"]
    if written(slug):
        print(f"error: blog/{slug}.html already exists", file=sys.stderr)
        return 1
    out = GUIDES / (slug.replace("soc-2-", "").replace("soc-1-", "") + ".json")
    if out.exists():
        print(f"error: {out} already exists", file=sys.stderr)
        return 1

    spec = {
        "_brief": {
            "intent": t["intent"],
            "angle": t["angle"],
            "house_style": [
                "1,200-1,850 words of body text, which seo-check enforces loosely",
                "title 30-62 chars, description 120-165 — new-guide.py refuses otherwise",
                "open with a short answer that stands alone, so it can be quoted",
                "take a position; the pages that work say what the standard does NOT require",
                "no claim you would not defend to a real auditor",
            ],
        },
        "slug": slug,
        "title": t["title"],
        "h1": "TODO — sentence case, can differ from title",
        "description": "TODO — 120-165 characters",
        "section": "TODO — Readiness | Evidence | Policies | Audit | Fundamentals",
        "crumb": "TODO — two or three words",
        "cardBlurb": "TODO — one sentence for the /blog card",
        "readingTime": 8,
        "shortAnswer": "<p>TODO — the whole answer, standing alone, no preamble.</p>",
        "sections": [
            {"h2": h, "html": "<p>TODO</p>"} for h in t.get("sections", [])
        ],
        "faq": [
            {"q": q, "a": "TODO — full sentences, answered completely"}
            for q in t.get("faq", [])
        ],
        "readNext": [
            ["/blog/soc-2-evidence-checklist", "What evidence a SOC 2 auditor actually asks for"],
            ["/blog/soc-2-readiness-checklist", "A SOC 2 readiness checklist for a 10-person startup"],
        ],
    }
    out.write_text(json.dumps(spec, indent=2, ensure_ascii=False) + "\n")

    print(f"Scaffolded {out.relative_to(ROOT)}")
    print()
    print(f"  {len(spec['sections'])} section headings, {len(spec['faq'])} FAQ questions")
    print(f"  intent: {t['intent']}")
    print(f"  angle:  {t['angle']}")
    print()
    print("Fill in every TODO, then:")
    print(f"  ./scripts/new-guide.py {out.relative_to(ROOT)} --dry-run")
    print(f"  ./scripts/new-guide.py {out.relative_to(ROOT)}")
    print("  ./scripts/bust-cache.sh && ./scripts/seo-check.sh")
    print(f"  git add -A && git commit && git push")
    print(f"  ./scripts/indexnow.sh /blog/{slug}")
    return 0


def main():
    topics = load()
    args = sys.argv[1:]

    if "--slug" in args:
        slug = args[args.index("--slug") + 1]
        t = next((x for x in topics if x["slug"] == slug), None)
        if not t:
            print(f"error: no topic with slug '{slug}'", file=sys.stderr)
            return 1
        return scaffold(t)

    if "--next" in args:
        # One guide in flight at a time. A queue of twenty half-written specs is
        # not a cadence, and the point of the cadence is that each guide gets
        # read before it goes live.
        inprogress = [t for t in topics
                      if not written(t["slug"]) and spec_exists(t["slug"])]
        if inprogress:
            print("Already scaffolded and waiting to be written:")
            for t in inprogress:
                print(f"  {t['title']}  ({t['slug']})")
            print()
            print("Finish that one first, or --slug to override.")
            return 1

        ready = [t for t in topics if not written(t["slug"]) and "defer" not in t]
        if not ready:
            print("Backlog is empty — nothing to scaffold.")
            print("Pull the next topic from Search Console impressions instead.")
            return 1
        return scaffold(ready[0])

    status(topics)
    return 0


if __name__ == "__main__":
    sys.exit(main())
