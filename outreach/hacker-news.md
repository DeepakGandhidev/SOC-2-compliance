# Hacker News

Two separate assets. The **essay** is what earns links and gets quoted; the **Show HN**
is a traffic spike and a chance at feedback. Post the essay first — if it does well, the
Show HN a few weeks later lands with people who already know the name.

## Rules for this audience

- HN detects and punishes marketing language faster than any other community. Every
  superlative you remove makes the post better.
- Do not ask for upvotes anywhere. HN detects voting rings and penalises domains, not
  just posts.
- Be in the thread for the first three hours answering everything, including the hostile
  comments. Especially those — a good-faith answer to a sharp criticism is the single
  best thing that can happen to a Show HN.
- Post Tuesday–Thursday, roughly 8–10am US Eastern.
- **Fix the "Trusted by startups like" line on the homepage first.** This crowd will find
  it, and it undercuts the honesty that is otherwise your strongest card.

---

## Asset 1 — the essay

**Title options** (HN titles should be flat and specific; the flatter one usually wins):

- `What 29 SOC 2 requirements taught me about what auditors actually want`
- `SOC 2 for small teams: what the compliance vendors leave out`

**Where:** your own blog at `/blog`, then submit the URL to HN. Also post to Indie
Hackers and r/SaaS. This is the piece that earns links, because it is a first-hand
account rather than a listicle, and nobody else can write it.

**Outline — write this in your own voice, it must sound like a person:**

1. **The situation.** A five-person startup gets told it needs SOC 2 to close a deal.
   They open a compliance platform and are shown two hundred requirements with no
   indication of which matter this week. Concrete, not abstract.
2. **What I actually did.** Built the requirement catalogue down to 29 for a
   Security-only scope at startup size. Say what got cut and why — this is the section
   with real information density, and it is what people quote.
3. **The thing that surprised me.** The auditor's real question is never "do you have a
   policy" — it is "what proves this, and when?" A policy nobody follows is worse than no
   policy, because now there is a documented gap.
4. **The most common failure.** Access reviews that were meant to be quarterly and were
   not. Retroactive evidence does not exist; the observation period is calendar time.
5. **What I would tell a founder starting today.** Three or four blunt points. Pick the
   auditor early. Security-only scope. Start the clock before you feel ready. Type 1 to
   keep the deal alive while Type 2 runs.
6. **One honest paragraph about the product.** One. At the end. Saying plainly that you
   built a tool, what it does, and that it prepares you rather than certifying you.

**What makes it work:** specifics with numbers, and a willingness to say what you got
wrong. If there is nothing in the essay that costs you something to admit, it is a
brochure and it will die on the front page.

---

## Asset 2 — the Show HN

**Title** — HN requires the `Show HN:` prefix and rewards plainness:

> `Show HN: SOC2Starter – SOC 2 readiness and evidence tracking for small teams`

**First comment** (post it immediately after submitting — this is the real pitch):

> I built this after watching small teams get told they need SOC 2 to close a deal, open
> a compliance platform, and get shown two hundred requirements with no indication of
> which ones matter this week. That tooling is built for companies with a compliance
> department. Most companies that need SOC 2 do not have one.
>
> It asks nineteen questions and produces 29 requirements scoped to your actual company,
> a ranked action plan, policy drafts written around the tools you really use, and an
> evidence library. Twelve read-only connectors (GitHub, Google Workspace, AWS, Okta and
> others) file dated snapshots so the quarterly screenshot chore becomes a button. Every
> connector is read-only by construction — none can be granted a scope that changes
> anything in your account.
>
> Things I want to be upfront about:
>
> - **It does not certify you.** An independent CPA firm performs the examination. The
>   product says "readiness estimate" everywhere, including where a bigger number would
>   sell better.
> - **SOC 2 Security only.** Not ISO 27001, not HIPAA, not PCI. Adding frameworks I do
>   not really support would waste your click.
> - **It is one person.** Me, in India. That is a real limitation and you should price it
>   into your decision.
> - **You can leave.** Policies export as Markdown or HTML, the whole position exports as
>   an audit pack, and deleting your account deletes your data from one screen.
>
> $199/month, 14-day trial, no card. Happy to answer anything, including why you might
> reasonably do this with a spreadsheet instead.

**Prepare answers for these — they will come up:**

| Likely comment | Have ready |
| --- | --- |
| "This is just a spreadsheet with extra steps" | Agree partly. Say exactly where a spreadsheet stops working: recurring controls that slip, and evidence dated across an observation period |
| "Why not Vanta/Drata?" | Price and size. Do not attack them; say who you are *not* for — teams that already have a GRC platform and a compliance person |
| "How do I know my evidence is safe with you?" | Tenant isolation enforced at the database, not in application code. Integration credentials stored where the application role cannot read them. Evidence files never public. Point at the privacy policy naming every processor |
| "Solo founder — what if you disappear?" | The honest answer plus the export story. Do not get defensive; this is a fair question |
| "Compliance theatre" | Largely agree. The interesting version of your position: theatre is what you get when the tool rewards ticking a box rather than producing something an examiner can read |
