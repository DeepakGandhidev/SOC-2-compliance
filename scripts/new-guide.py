#!/usr/bin/env python3
"""
Step 4.4 — scaffold a new /blog guide, fully wired.

Writing a guide by hand means reproducing ~40 domain references, a nine-node
JSON-LD graph, breadcrumbs, FAQ markup mirrored in FAQPage schema, a sitemap
entry, a card on /blog and two more JSON-LD lists. Getting any of it wrong is
invisible until a rich result silently stops appearing.

This generates all of it from a short spec file, taking the site chrome
(header, footer, callout, styles) from an existing guide so it can never
drift from the real site.

    ./scripts/new-guide.py scripts/guides/security-questionnaire.json
    ./scripts/new-guide.py <spec> --dry-run

Then:
    ./scripts/seo-check.sh
    ./scripts/indexnow.sh /blog/<slug>
"""

import json
import re
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "blog" / "soc-2-timeline.html"

# The audit thresholds in scripts/seo-check.sh — kept identical on purpose.
TITLE_MIN, TITLE_MAX = 30, 62
DESC_MIN, DESC_MAX = 120, 165


def die(msg):
    print("error: " + msg, file=sys.stderr)
    sys.exit(1)


def host():
    sm = (ROOT / "sitemap.xml").read_text()
    m = re.search(r"<loc>https?://([^/<]+)", sm)
    if not m:
        die("could not read the host from sitemap.xml")
    return m.group(1)


def slugify(text):
    s = re.sub(r"<[^>]+>", "", text).lower()
    s = s.replace("&amp;", "and").replace("&mdash;", " ").replace("&rsquo;", "")
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s


def validate(spec):
    problems = []
    required = ["slug", "title", "h1", "description", "section", "crumb",
                "shortAnswer", "sections", "faq", "readNext"]
    for k in required:
        if not spec.get(k):
            problems.append("missing field: " + k)
    if problems:
        return problems

    if not re.fullmatch(r"[a-z0-9-]+", spec["slug"]):
        problems.append("slug must be lowercase letters, digits and hyphens")

    n = len(spec["title"])
    if not TITLE_MIN <= n <= TITLE_MAX:
        problems.append(f"title is {n} chars, needs {TITLE_MIN}-{TITLE_MAX}")

    n = len(spec["description"])
    if not DESC_MIN <= n <= DESC_MAX:
        problems.append(f"description is {n} chars, needs {DESC_MIN}-{DESC_MAX}")

    if len(spec["faq"]) < 3:
        problems.append("give at least 3 FAQ entries; the existing guides carry 5")
    for i, f in enumerate(spec["faq"], 1):
        if not f.get("q") or not f.get("a"):
            problems.append(f"faq[{i}] needs both q and a")

    if len(spec["sections"]) < 3:
        problems.append("give at least 3 body sections")
    for i, s in enumerate(spec["sections"], 1):
        if not s.get("h2") or not s.get("html"):
            problems.append(f"sections[{i}] needs both h2 and html")

    if (ROOT / "blog" / (spec["slug"] + ".html")).exists():
        problems.append(f"blog/{spec['slug']}.html already exists")

    return problems


def chrome(ref_html):
    """Lift the parts that are identical across every guide."""
    def between(start, end):
        i = ref_html.index(start)
        j = ref_html.index(end, i)
        return ref_html[i:j + len(end)]

    return {
        "header": between('<header class="site">', "</header>"),
        "callout": between('<div class="callout">', "</div>\n    </div>").rsplit("</div>", 1)[0] + "</div>",
        "footer": between('<footer class="site">', "</footer>"),
    }


def build_page(spec, h, ch, today):
    base = f"https://{h}"
    url = f"{base}/blog/{spec['slug']}"
    title = spec["title"]
    desc = spec["description"]
    reading = spec.get("readingTime", max(4, sum(
        len(re.sub(r"<[^>]+>", " ", s["html"]).split()) for s in spec["sections"]) // 200))

    head = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="theme-color" content="#ffffff">
<title>{title}</title>
<meta name="description" content="{desc}">
<link rel="stylesheet" href="/assets/style.css">
<link rel="icon" href="/assets/favicon.png" type="image/png">
<link rel="apple-touch-icon" href="/assets/favicon.png">
<link rel="canonical" href="{url}">
<meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1">
<link rel="alternate" hreflang="en" href="{url}">
<link rel="alternate" hreflang="x-default" href="{url}">
<meta name="author" content="Deepak Gandhi">
<meta property="og:title" content="{title}">
<meta property="og:description" content="{desc}">
<meta property="og:type" content="article">
<meta property="og:url" content="{url}">
<meta property="og:site_name" content="SOC2Starter">
<meta property="article:published_time" content="{today}T00:00:00+00:00">
<meta property="article:modified_time" content="{today}T00:00:00+00:00">
<meta property="article:author" content="Deepak Gandhi">
<meta property="article:section" content="{spec['section']}">
<meta property="article:tag" content="SOC 2">
<meta property="og:image" content="{base}/assets/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="{base}/assets/og-image.png">
</head>
<body>
"""

    body = [f'''<article class="article">
  <div class="wrap">
    <p class="crumbs"><a href="/">Home</a> &rsaquo; <a href="/blog">Guides</a> &rsaquo; {spec['crumb']}</p>
    <h1>{spec['h1']}</h1>
    <p class="post-meta">Updated {today} &middot; {reading} min read &middot; by Deepak Gandhi, who builds
    <a href="/features">SOC2Starter</a></p>

    <div class="answer">
      <span class="label">The short answer</span>
      {spec['shortAnswer']}
    </div>
''']

    for s in spec["sections"]:
        anchor = s.get("id") or slugify(s["h2"])
        body.append(f'\n    <h2 id="{anchor}">{s["h2"]}</h2>\n    {s["html"]}\n')

    body.append('\n<h2 id="questions-people-ask">Questions people ask</h2>\n')
    for f in spec["faq"]:
        body.append(f'<h3 id="{slugify(f["q"])}">{f["q"]}</h3>\n<p>{f["a"]}</p>\n')

    body.append("\n    " + ch["callout"] + "\n")

    body.append('\n    <div class="next-up">\n      <h2 id="read-next">Read next</h2>\n      <ul>\n')
    for href, label in spec["readNext"]:
        body.append(f'      <li><a href="{href}">{label}</a></li>\n')
    body.append("      </ul>\n    </div>\n  </div>\n</article>\n\n")

    graph = [
        {"@id": f"{base}/#organization"},
        {"@id": f"{base}/#logo"},
        {"@id": f"{base}/#deepak"},
        {"@id": f"{base}/#website"},
    ]
    # The first four nodes are shared entities — copy them verbatim from the
    # reference guide so a change to the org details propagates on rebuild.
    ref_graph = json.loads(re.search(
        r'<script type="application/ld\+json">(.*?)</script>',
        REFERENCE.read_text(), re.S).group(1))["@graph"]
    shared = [n for n in ref_graph
              if n.get("@type") in ("Organization", "ImageObject", "Person", "WebSite")]

    graph = list(shared) + [
        {
            "@type": "WebPage",
            "@id": f"{url}#webpage",
            "url": url,
            "name": title,
            "description": desc,
            "isPartOf": {"@id": f"{base}/#website"},
            "inLanguage": "en",
            "datePublished": today,
            "dateModified": today,
            "primaryImageOfPage": {"@id": f"{base}/#logo"},
            "breadcrumb": {"@id": f"{url}#breadcrumb"},
        },
        {
            "@type": "BreadcrumbList",
            "@id": f"{url}#breadcrumb",
            "itemListElement": [
                {"@type": "ListItem", "position": 1, "name": "Home", "item": f"{base}/"},
                {"@type": "ListItem", "position": 2, "name": "Guides", "item": f"{base}/blog"},
                {"@type": "ListItem", "position": 3, "name": spec["crumb"], "item": url},
            ],
        },
        {
            "@type": "BlogPosting",
            "@id": f"{url}#post",
            "headline": title,
            "description": desc,
            "url": url,
            "datePublished": today,
            "dateModified": today,
            "author": {"@id": f"{base}/#deepak"},
            "publisher": {"@id": f"{base}/#organization"},
            "mainEntityOfPage": {"@id": f"{url}#webpage"},
            "image": f"{base}/assets/og-image.png",
            "inLanguage": "en",
            "articleSection": spec["section"],
            "wordCount": sum(len(re.sub(r"<[^>]+>", " ", s["html"]).split())
                             for s in spec["sections"]),
            "timeRequired": f"PT{reading}M",
        },
        {
            "@type": "FAQPage",
            "@id": f"{url}#faq",
            "mainEntity": [
                {"@type": "Question", "name": f["q"],
                 "acceptedAnswer": {"@type": "Answer", "text": f["a"]}}
                for f in spec["faq"]
            ],
        },
    ]

    ld = json.dumps({"@context": "https://schema.org", "@graph": graph},
                    indent=2, ensure_ascii=False)

    return (head + ch["header"] + "\n\n" + "".join(body) + ch["footer"]
            + '\n<script type="application/ld+json">\n' + ld
            + "\n</script>\n</body>\n</html>\n")


def update_sitemap(spec, h, today, dry):
    p = ROOT / "sitemap.xml"
    s = p.read_text()
    url = f"https://{h}/blog/{spec['slug']}"
    if url in s:
        return "already listed"
    entry = (f"  <url>\n    <loc>{url}</loc>\n"
             f"    <lastmod>{today}</lastmod>\n"
             f"    <changefreq>monthly</changefreq>\n"
             f"    <priority>0.8</priority>\n  </url>\n")
    s = s.replace("</urlset>", entry + "</urlset>")
    if not dry:
        p.write_text(s)
    return "added"


def update_blog_index(spec, h, dry):
    p = ROOT / "blog" / "index.html"
    s = p.read_text()
    url = f"https://{h}/blog/{spec['slug']}"
    notes = []

    if f'href="/blog/{spec["slug"]}"' not in s:
        card = (f'      <article class="post-card">\n'
                f'        <p class="kicker">{spec["section"]}</p>\n'
                f'        <h2><a href="/blog/{spec["slug"]}">{spec["h1"]}</a></h2>\n'
                f'        <p>{spec.get("cardBlurb", spec["description"])}</p>\n'
                f'        <p><small>{spec.get("readingTime", 6)} min read</small></p>\n'
                f'      </article>\n')
        anchor = "    </div>\n  </div>\n</section>"
        if anchor not in s:
            die("could not find the card grid in blog/index.html")
        s = s.replace(anchor, card + anchor, 1)
        notes.append("card added")
    else:
        notes.append("card already present")

    m = re.search(r'<script type="application/ld\+json">(.*?)</script>', s, re.S)
    d = json.loads(m.group(1))
    changed = False
    for node in d["@graph"]:
        if node.get("@type") == "Blog":
            if not any(b.get("url") == url for b in node.get("blogPost", [])):
                node["blogPost"].append({
                    "@type": "BlogPosting", "headline": spec["title"], "url": url,
                    "author": {"@id": f"https://{h}/#deepak"}})
                changed = True
        if node.get("@type") == "ItemList":
            items = node.get("itemListElement", [])
            if not any(i.get("url") == url for i in items):
                items.append({"@type": "ListItem", "position": len(items) + 1,
                              "name": spec["h1"], "url": url})
                changed = True
    if changed:
        s = s[:m.start(1)] + json.dumps(d, indent=2, ensure_ascii=False) + s[m.end(1):]
        notes.append("schema lists updated")

    if not dry:
        p.write_text(s)
    return ", ".join(notes)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry-run" in sys.argv
    if not args:
        die("usage: new-guide.py <spec.json> [--dry-run]")

    spec_path = Path(args[0])
    if not spec_path.exists():
        die(f"no such spec file: {spec_path}")
    try:
        spec = json.loads(spec_path.read_text())
    except json.JSONDecodeError as e:
        die(f"{spec_path} is not valid JSON: {e}")

    problems = validate(spec)
    if problems:
        print("Spec is not publishable yet:\n", file=sys.stderr)
        for p in problems:
            print("  - " + p, file=sys.stderr)
        sys.exit(1)

    h = host()
    today = date.today().isoformat()
    ch = chrome(REFERENCE.read_text())
    page = build_page(spec, h, ch, today)

    out = ROOT / "blog" / (spec["slug"] + ".html")
    words = sum(len(re.sub(r"<[^>]+>", " ", s["html"]).split()) for s in spec["sections"])

    print(f"guide        {spec['slug']}")
    print(f"title        {len(spec['title'])} chars")
    print(f"description  {len(spec['description'])} chars")
    print(f"body         {words} words, {len(spec['sections'])} sections")
    print(f"faq          {len(spec['faq'])} questions")
    if words < 1200:
        print(f"\n  note: the existing guides run 1,200-1,850 words. This is {words}.")

    if not dry:
        out.write_text(page)
    print(f"\nblog/{spec['slug']}.html    {'(dry run)' if dry else 'written'}")
    print(f"sitemap.xml               {update_sitemap(spec, h, today, dry)}")
    print(f"blog/index.html           {update_blog_index(spec, h, dry)}")

    if dry:
        print("\nDry run — nothing written.")
        return
    print("\nNext:")
    print("  ./scripts/seo-check.sh")
    print("  git add -A && git commit && git push")
    print(f"  ./scripts/indexnow.sh /blog/{spec['slug']}")


if __name__ == "__main__":
    main()
