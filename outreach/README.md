# Off-site plan

On-site SEO is finished (see [GROWTH.md](../GROWTH.md)). This directory is the other
half: the assets for everything that has to happen off the domain, written out so the
only work left is posting them as yourself.

## Read this before doing anything

**The order matters more than the content.** Most of these assets are single-use. A
Product Hunt launch happens once. A Show HN that flops cannot be reposted. Doing them in
the wrong order wastes them.

### Phase 0 — before a single link exists (do this week)

1. **Buy the real domain and move.** `soc-2-compliance.vercel.app` is a subdomain of
   `vercel.app`. Every link earned while on it is a link you partly throw away at the
   move, and a vercel.app URL reads as a side project in a Product Hunt listing or a
   journalist's inbox. `soc2starter.com` or similar. 301 the old URLs — the canonical
   tags are already in place, so the move is unambiguous.
2. **Finish Google Search Console verification.** `googlec956327bd906889c.html` is in the
   repo, so this was started. Verify, submit `sitemap.xml`.
3. **Bing Webmaster Tools.** Separate submission. ChatGPT's search grounding runs on
   Bing's index — skipping this makes the site invisible to a large share of AI answers,
   which is the channel most likely to work first for a new domain.

Nothing below should happen before step 1 is done.

### Phase 1 — permanent, zero-risk links (week 1–2)

Directory listings. See [directories.md](directories.md). These are safe, they are real
links, they never get you penalised, and they take an afternoon. Do them all in one
sitting with the copy already written.

### Phase 2 — build standing before spending it (weeks 2–6)

Reddit and Hacker News. See [reddit.md](reddit.md).

You cannot show up on r/SaaS with a launch post on day one — new accounts posting links
get removed by automod and the subreddit remembers. Spend a month answering SOC 2
questions properly, with no link at all in most of them. Then a launch post is from
somebody the subreddit recognises.

### Phase 3 — the set pieces (week 6+)

- **Show HN + the essay.** See [hacker-news.md](hacker-news.md). The essay is the
  link-earning asset; the Show HN is the traffic spike.
- **Product Hunt.** See [product-hunt.md](product-hunt.md). Launch once, on a Tuesday or
  Wednesday, with people already lined up to look.

### Ongoing, forever

- **HARO / Qwoted / Featured** — see [pitches.md](pitches.md). Cheapest route to a
  high-authority link that exists. 15 minutes a day.
- **Auditor outreach** — also in [pitches.md](pitches.md). Small CPA firms keep resource
  pages, and a tool that gets their clients organised before fieldwork saves them money.
  This is a mutual ask, not a favour, which is why it works.

## Rules that keep the domain clean

- **Never buy links.** Paid link packages, PBNs, "500 directory submissions for $20",
  guest post networks that charge. These are the main way small sites get manually
  actioned. One manual action costs more than every link it bought.
- **Always disclose.** Every Reddit comment, every HN reply, every forum answer where you
  mention the product says you built it. It is required by the FTC and by the subreddits,
  and it is also the thing that makes the answer land rather than read as astroturf.
- **Answer fully in the comment.** Never post a teaser that makes someone click to get
  the answer. Give the whole answer where it was asked, and link the guide as the longer
  version. One genuinely useful answer beats fifty drive-by links.
- **No fake reviews, ever.** Not on G2, not on Capterra, not from friends who never used
  it. It is illegal in several jurisdictions, platforms detect it, and a fabricated review
  is the one mistake that cannot be walked back.

## One thing on the site to fix first

[index.html](../index.html) says **"Trusted by startups like"** above three audience
descriptions rather than three customers. Nobody reading it is fooled, and it is the one
line on an otherwise scrupulously honest site that a Hacker News comment will pick apart
— the same crowd that will otherwise praise the "readiness is not certification" stance.
Change it to something true like "Built for" before the Show HN post goes up.
