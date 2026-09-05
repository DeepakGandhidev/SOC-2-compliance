# SOC2Starter — website

The marketing and legal site for SOC2Starter, plus the product itself at `/app`.

The pages are plain HTML and one stylesheet: no build step, no dependencies, nothing to
keep patched. `/app` is the compiled Expo web build of the mobile app — the same
codebase, the same Supabase backend, the same row-level security. It is committed here
rather than built here, because Vercel runs no build command for this repo.

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
| `PADDLE_CLIENT_TOKEN` | Paddle → Developer tools → Authentication → **Client-side tokens**. Public by design; it authorises nothing on its own |
| `PADDLE_ENVIRONMENT` | `sandbox` while testing, `production` when live |
| `SITE_URL` | Drives every canonical tag, Open Graph URL, sitemap entry and JSON-LD id. **Moving to a real domain is this one line**, then a 301 from the old host |

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
| `/checkout` | `checkout.html` — Paddle's default payment link points here |
| `/thanks` | `thanks.html` — where Paddle sends the browser after payment |
| `/app/*` | The product. A compiled single-page bundle, not editable here — see below |

## The app at `/app`

Everything the mobile app does, in a browser: the assessment, requirements, the action
plan, policies, evidence, tasks, integrations, the inbox and the exports. Same account,
same data — someone can start on their laptop and finish on their phone.

It is built from the Expo project, not from this repo:

```bash
cd ../soc2starter
npm run build:web          # exports, then replaces ../soc2starter-site/app
cd ../soc2starter-site
git add app && git commit && git push
```

The whole `app/` directory is replaced on every build, never merged — a stale chunk from
a previous export is served perfectly happily by Vercel and is a horrible thing to debug.

Three pieces of configuration make it work, and all three break silently if changed:

| | |
| --- | --- |
| `experiments.baseUrl: "/app"` in the Expo `app.json` | Makes the bundle ask for `/app/_expo/…` rather than `/_expo/…`. Without it every script tag 404s and the page is blank |
| The `/app/:path*` rewrite in `vercel.json` | It is a single-page app: a deep link like `/app/policies/123` must serve `app/index.html` and let the router sort it out. Vercel checks the filesystem first, so real asset files still win |
| `connect-src` in the CSP includes `https://*.supabase.co` | The pages need no network access at all; the app needs Supabase. Omit it and the app renders and then cannot log anybody in |

`Disallow: /app/` is in `robots.txt`. It is behind a login and renders client-side, so
there is nothing there for a crawler.

### What differs from the native app

| | |
| --- | --- |
| Push notifications | Not available. The in-app inbox is the source of truth on every platform; on web it is the only channel. `src/lib/notifications.web.ts` says so honestly rather than pretending to register |
| Dialogs | react-native-web ships `Alert.alert` as a no-op, which made every confirmation a dead button. `src/lib/alert.web.ts` draws a real one |
| Layout | The screens are phone-first. On a desktop browser the column is capped and centred (`webPage` in `src/theme`) instead of stretching a button across 1440px |
| The camera | Uses the browser's file picker and webcam rather than the native camera |

## How checkout works

The app never renders a payment form. It asks the server for a checkout URL, and opens
**this site** in the system browser:

```
app → billing-checkout function → Paddle API creates a transaction
                                → returns  https://<site>/checkout?_ptxn=txn_…
app opens that in the SYSTEM BROWSER (never a WebView)
/checkout loads Paddle.js and opens Paddle's own checkout
card details are entered inside Paddle's iframe — never on this origin
Paddle → /thanks, and separately → billing-webhook, which is what actually
         moves the subscription state
```

In Paddle, set **Checkout → Checkout settings → Default payment link** to
`https://<your-site>/checkout`. Without it Paddle returns no checkout URL at all, and the
server function will tell you so in as many words.

`/thanks` changes no billing state. Only a signature-verified webhook, or the app reading
Paddle's API directly, can do that — so landing on it without paying grants nothing.

## SEO

What is in place, and why each piece is here rather than being cargo-culted:

| | Why |
| --- | --- |
| `<title>` + `description` per page | The two lines a search result actually shows |
| **Canonical tags** | Names the real URL. Do this *before* moving domains — it makes the later 301 unambiguous and stops the vercel.app and the real domain competing |
| Open Graph + Twitter card + `og-image.png` | A link pasted into Slack or LinkedIn renders as a card instead of a bare URL |
| **JSON-LD**: Organization, SoftwareApplication, FAQPage | Only claims that are visibly on the page. The FAQ schema is generated *from* the pricing page's real Q&A, so the two can never drift |
| `sitemap.xml`, `robots.txt` | Checkout/thanks/confirmed are disallowed — they are per-visitor, not content |
| Static HTML, no JS bundle | The one ranking factor this site is genuinely excellent at |

**What none of this does is bring traffic.** Seven pages and zero backlinks rank for
nothing. The things that would actually move it: writing what the audience searches for
("what evidence does a SOC 2 auditor ask for", "SOC 2 cost for a startup", "SOC 2 vs ISO
27001 for a 12-person company"), and getting cited from somewhere real. Meta tags decide
how you appear once you rank; they do not get you there.

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
