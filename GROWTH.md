# Getting traffic

What is done, what is not, and what only a person can do. Written plainly because the
gap between "the SEO work is finished" and "the site gets traffic" is where most of this
effort is usually wasted.

## What is done (on-site)

| | |
| --- | --- |
| Seven guides at `/blog` | 1,200–1,850 words each, targeting the questions buyers actually search before a first audit |
| Answer-shaped structure | Every guide opens with a **short answer** block that stands alone, so Google's featured snippets and AI answer engines can lift it without the surrounding page |
| `FAQPage` schema on every guide | 5 questions each, 35 total, phrased as people ask them and answered in full sentences |
| `BlogPosting` + `BreadcrumbList` schema | Author, publisher, dates, and the position of each page in the site |
| Internal linking | Every guide links to two or three others and to `/features`; the homepage, `/features` and `/pricing` link into the guides |
| `sitemap.xml`, canonicals, Open Graph | All twelve public URLs, with `lastmod` on the guides |
| Static HTML, no JS | Sub-second render, which is the one ranking factor this site is genuinely excellent at |

### Why these seven topics

They are the queries with buying intent, not the ones with the largest volume. Somebody
searching "what evidence does a SOC 2 auditor ask for" has a problem this product solves.
Somebody searching "what is SOC 2" is two years from caring. The evidence checklist is
also the one page a competitor cannot copy honestly: it is derived from the product's
actual requirement catalogue.

## What is NOT done, and cannot be done from a keyboard here

**Backlinks.** Nothing on this list can be automated, and everything that can be
automated is the kind of link building that gets a domain penalised. Directory spam,
comment links, PBNs and paid link packages are worse than no links at all — they are the
main way small sites get manually actioned by Google.

Ranking for anything commercial needs links from sites that already have authority, and
those come from a person asking. In rough order of return per hour:

1. **Answer the same questions where they are already being asked.** Reddit r/SaaS,
   r/devops, r/cybersecurity, Hacker News, Indie Hackers, and the SOC 2 threads in
   founder Slack and Discord communities. Answer properly in the comment — the full
   answer, not a teaser — and link the guide as the longer version. One genuinely useful
   answer beats fifty drive-by links.
2. **Write the story nobody else can.** "I built a SOC 2 tool and here is what 29
   requirements taught me about what auditors actually want." That is a Hacker News and
   Indie Hackers post, and it earns links because it is a first-hand account rather than
   a listicle.
3. **Get listed.** G2, Capterra, Product Hunt, AlternativeTo, SaaSHub, Startup Stash.
   Real listings on real directories, not link farms. Product Hunt in particular sends a
   burst of traffic and a durable link.
4. **Guest posts on startup and devtool blogs.** Pitch the evidence checklist angle; it
   is concrete enough that editors say yes.
5. **Ask the auditors.** Small CPA firms doing SOC 2 for startups often keep a resources
   page. A tool that gets their clients organised before fieldwork saves them time, which
   makes it a genuinely mutual ask rather than a favour.
6. **HARO / Qwoted / Featured.** Reporters write "SOC 2 for startups" pieces constantly
   and need a quotable founder. This is the cheapest route to a high-authority link.

**Google Search Console.** Verify the domain, submit `sitemap.xml`, and watch which
queries produce impressions. That data is what tells you which guide to write next — it
beats any keyword tool, and it cannot be set up from here because it needs your Google
account. `googlec956327bd906889c.html` in this repo suggests verification was started;
finish it.

**A real domain.** `soc-2-compliance.vercel.app` is a subdomain of vercel.app, and it
will always be weaker than a domain you own. Buy one, move, and 301 the old URLs — the
canonical tags already in place make that unambiguous. Do it before the links start
arriving, not after.

## Honest expectations

A new site with no backlinks ranks for nothing for months. This is not a comment on the
writing; it is how the index works. A realistic curve:

- **Months 1–2:** indexed, ranking for long-tail phrases with tiny volume. Near-zero traffic.
- **Months 3–6:** with steady link-earning work, page two or three for the mid-tail
  phrases. First trickle of qualified visitors.
- **Months 6–12:** page one for specific long-tail queries such as "SOC 2 evidence
  checklist for startups" is achievable. Head terms like "SOC 2 compliance software" are
  contested by companies spending millions and are not a realistic near-term target.

The AI answer engines are the faster path and the reason for the answer blocks and the
FAQ schema. ChatGPT, Perplexity and Google's AI summaries quote pages that answer a
question directly and factually, and they weigh domain authority far less than classic
search does. A new site can be cited by an answer engine in weeks.

**Nobody can promise first-page rankings.** Anyone who does is selling something. What is
controllable is: be the most specific, most honest answer to a question a buyer is
actually asking, and be linkable enough that people cite you.

## What to write next

Ordered by intent, following the same pattern as the existing guides:

- SOC 2 security questionnaire: how to answer the 40 questions enterprises send
- Do you need a penetration test for SOC 2?
- SOC 2 for a company with no dedicated security team
- What auditors look for in an access review (and how to run your first one)
- SOC 2 Trust Services Criteria explained in plain English
- Vanta vs Drata vs doing it yourself — a genuinely fair comparison, which is rare and
  therefore linkable
