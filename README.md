# SOC2Starter — website

The marketing and legal site for SOC2Starter. Plain HTML and one stylesheet: no build
step, no dependencies, nothing to keep patched.

## Company details

Every page is filled in and ready to deploy. The values live at the top of
`configure.sh`; change them there and re-run it rather than editing seven HTML files.

```bash
./configure.sh
```

| Value | Currently |
| --- | --- |
| `LEGAL_NAME` | Deepak Gandhi (trading as SOC2Starter) — **change this the moment a company is registered**; the terms name the party to the contract |
| `CONTACT_EMAIL` | deepakgandhi2007@gmail.com |
| `COUNTRY` / `JURISDICTION` | India — the governing-law clause |
| `AI_PROVIDER` | Google Gemini — **must match what the backend actually uses** |
| `DATA_REGION` | ap-northeast-1 (Tokyo) — where Supabase actually stores the data |

No postal address and no domain appear anywhere on the site, by choice. Note that Google
Play separately requires a public developer address on the store listing itself — that is a
Play Console field, not a website one.

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
robots.txt
configure.sh            fills in the company details
```

Header and footer are duplicated in each page rather than templated. With seven pages and
no build step that is the cheaper trade — but if you add many more pages, move to a static
site generator rather than keeping them in sync by hand.
