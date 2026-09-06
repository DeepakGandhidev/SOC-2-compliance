# Reddit and community answers

The highest-return off-site activity available to a new domain, and the easiest to do
badly. The difference is entirely whether you are answering a question or placing a link.

## How to not get banned

- **Build history first.** Four to six weeks of commenting with no links at all. Most
  relevant subreddits auto-remove links from low-karma accounts, so early link posts are
  invisible anyway — you burn the account for nothing.
- **Disclose every time.** "Disclosure: I build a tool in this space" on any comment
  where the product comes up. Non-negotiable, and it is why the honest answers land.
- **Ratio.** Nine helpful comments with no mention for every one where the product comes
  up. If that ratio feels expensive, the ratio is doing its job.
- **Never post the same text twice.** Cross-posted identical comments are the single
  clearest spam signal on the platform.
- **Answer completely in the comment.** The link is the longer version, never the
  payoff. A comment that withholds the answer to farm a click gets downvoted by exactly
  the people you want.

## Where the questions are

- **r/SaaS** — founders hitting the "enterprise customer asked for SOC 2" wall. Best fit.
- **r/devops**, **r/sysadmin** — the person who actually has to collect the evidence
- **r/cybersecurity** — knowledgeable, hostile to marketing, will fact-check you. Good.
- **r/startups**, **r/ycombinator** — cost and timeline questions
- **Hacker News** — see [hacker-news.md](hacker-news.md)
- **Indie Hackers**, founder Slacks and Discords — lower volume, warmer

Search each for `soc 2` sorted by new. These questions recur weekly.

## Drafted answers

Use these as the substance, not the wording — rewrite in your own voice each time, and
cut anything that does not apply to the specific question asked. Every one of them
answers fully without needing the link.

---

### "A customer is asking for SOC 2. Where do I even start?"

> Before spending money: find out which report they actually want. "SOC 2" from a
> procurement team usually means Type 2, but plenty of deals unblock with a Type 1 plus a
> commitment to Type 2 within the year. Ask. It is the difference between three months
> and nine.
>
> Then, roughly in order:
>
> 1. **Pick your scope.** SOC 2 has five Trust Services Criteria. Almost every startup
>    does Security only. Adding Availability or Confidentiality because it sounds better
>    multiplies the work and nobody asked for it.
> 2. **Pick the auditor early, not last.** A small CPA firm doing startup SOC 2 will tell
>    you what they expect to see, and that list is worth more than any generic checklist.
>    Prices vary enormously for the same report — get three quotes.
> 3. **Write the policies.** Ten-ish documents. They must be approved, dated, and
>    actually followed, because the auditor will check whether the thing the policy
>    describes really happens.
> 4. **Start the evidence clock.** For Type 2 the observation period is typically 3–12
>    months and it starts when your controls start operating, not when you decide to do
>    SOC 2. This is the part people discover too late.
>
> The mistake I see most: treating it as a document exercise. The audit tests whether
> controls operated over time. You cannot retroactively produce three months of access
> reviews you never ran.
>
> *Disclosure: I build a SOC 2 readiness tool, so I have an angle here. Happy to answer
> follow-ups either way.*

---

### "How much does SOC 2 actually cost?"

> Depends heavily on size and how organised you are, but for a startup under 50 people,
> realistic ranges:
>
> - **Audit fee:** the unavoidable one. An independent CPA firm has to do it. Type 1 is
>   cheaper than Type 2; quotes for the same scope vary by multiples, so get three.
> - **Penetration test:** not strictly required by the standard, but a lot of auditors
>   expect one and a lot of enterprise customers ask separately.
> - **Compliance tooling:** anywhere from nothing to a five-figure annual contract. The
>   big platforms price for companies with a compliance team.
> - **Your own time:** the largest line item and the one nobody budgets. Expect
>   meaningful engineering time over the readiness period.
>
> Two things that actually move the number: how much you have already (SSO, MFA, code
> review, offboarding process — if those exist, you are most of the way there), and
> whether you go Type 1 first. The recurring cost is also real — SOC 2 is annual, not
> once.
>
> *Disclosure: I build a tool in this space.*

---

### "Type 1 or Type 2?"

> Type 1 says your controls were designed properly, at one point in time. Type 2 says
> they actually operated, over a period — typically 3 to 12 months.
>
> Enterprise buyers generally want Type 2. Type 1 is worth doing when you need something
> in a procurement team's hands soon, because you can get one relatively quickly and then
> run the observation period for Type 2 afterwards.
>
> The trap: the observation period is calendar time you cannot compress. If a deal needs
> Type 2 in eight weeks, no amount of money fixes that. Start the clock as early as you
> can and treat Type 1 as the thing that keeps the deal alive meanwhile.
>
> Also worth knowing: reports cover a period and go stale. Customers usually want one
> less than a year old, and a bridge letter covers the gap between your last report and
> today.

---

### "Do I need Vanta/Drata or can I just do it myself?"

> You can absolutely do it yourself. Plenty of small companies have. What the platforms
> sell is not compliance, it is not having to think about what is missing.
>
> Doing it manually works when: you are small, one person owns it properly, and you are
> disciplined about actually running the recurring things — access reviews, policy
> reviews, offboarding checks. A spreadsheet and a folder is genuinely a valid system at
> ten people.
>
> It stops working when the recurring stuff slips, because the audit tests operation over
> time. Missing a quarterly access review is a finding, and no tool retroactively fixes
> it.
>
> Whatever you pick, watch for two things. First, no software makes you SOC 2 compliant —
> a CPA firm performs the examination, and any vendor implying otherwise is a bad sign.
> Second, check you can export. Your policies and evidence should leave in a format you
> can hand an auditor without the vendor.
>
> *Disclosure: I build one of the cheaper tools in this category, so weigh accordingly.
> The manual route is a real answer and I will not pretend otherwise.*

---

### "What evidence will the auditor actually ask for?"

> Roughly, for Security-only scope: your approved policies with dates and approvers;
> access reviews showing who had access to what and that somebody checked; onboarding and
> offboarding records proving access was actually revoked; MFA enforcement; change
> management showing code was reviewed before it shipped; vulnerability management;
> backup and restore evidence, including a restore that was actually tested; vendor
> reviews for your subprocessors; security awareness training records; and incident
> response — including that the plan was tested even if nothing happened.
>
> The pattern behind all of it: the auditor is asking "what proves this, and when?"
> Screenshots are fine, but they need to be dated and they need to cover the observation
> period. A screenshot taken the week before fieldwork proves nothing about the previous
> six months.
>
> Most common finding for startups, by a distance: access reviews that were supposed to
> happen quarterly and did not.
