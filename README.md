# SOC2Starter — website

The marketing and legal site for SOC2Starter. Plain HTML and one stylesheet: no build
step, no dependencies, nothing to keep patched.

## Before it goes live

The legal pages contain placeholders that cannot be guessed. **Fill them in before you
point a domain at this** — a privacy policy with the wrong entity name is worse than no
privacy policy, and Google Play will read this page as part of your app review.

```bash
./configure.sh        # edit the values at the top of the file first
```

| Placeholder | What it needs |
| --- | --- |
| `__LEGAL_NAME__` | Your **registered** entity name, not the trading name |
| `__CONTACT_EMAIL__` | A mailbox you actually read — it is the contact of record for privacy requests |
| `__ADDRESS__` | Registered address, one line |
| `__DOMAIN__` | The domain, no scheme, no trailing slash |
| `__COUNTRY__` | Governing law country |
| `__JURISDICTION__` | Courts named in the terms, e.g. "the courts of Bengaluru, India" |
| `__AI_PROVIDER__` | The model provider actually configured on the backend |
| `__DATA_REGION__` | The Supabase region the data actually sits in |

`configure.sh` exits non-zero if any placeholder is still unfilled, so it is safe to wire
into CI as a pre-deploy check.

## Deploying

Vercel, as a static site — no framework, no build command, no output directory. Import the
repository and deploy; `vercel.json` handles clean URLs (`/pricing`, not `/pricing.html`)
and sets the security headers.

## Pages

| Path | File |
| --- | --- |
| `/` | `index.html` |
| `/pricing` | `pricing.html` |
| `/about` | `about.html` |
| `/contact` | `contact.html` |
| `/terms` | `terms.html` |
| `/privacy` | `privacy.html` |
| `/refund` | `refund.html` |

## Keeping it honest

Two things in here are load-bearing and easy to break by accident:

1. **Never claim certification.** "SOC 2 readiness", "audit preparation", "evidence
   management" — never "SOC 2 certified" or "guarantees compliance". The disclaimer in the
   footer appears on every page for this reason, and Google Play reviews store listings
   for exactly this kind of claim.
2. **The privacy policy names real subprocessors.** If the backend switches model provider,
   storage region or payment processor, update the table in `privacy.html` and the date at
   the top of the page. It is the page a prospect's security reviewer will read first.

## Structure

```
index.html pricing.html about.html contact.html
terms.html privacy.html refund.html
assets/style.css        one stylesheet, same palette as the app
assets/favicon.svg
vercel.json             clean URLs + security headers
robots.txt sitemap.xml
configure.sh            fills the placeholders
```

Header and footer are duplicated in each page rather than templated. With seven pages and
no build step that is the cheaper trade — but if you add many more pages, move to a static
site generator rather than keeping them in sync by hand.
