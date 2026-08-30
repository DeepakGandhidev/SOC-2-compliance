#!/usr/bin/env bash
#
# Fills in the details that cannot be guessed: your legal entity, contact address, domain.
#
# Edit the values below, run it once, commit the result. Running it again is harmless —
# it only replaces tokens that are still present.
#
#   ./configure.sh
#
set -euo pipefail
cd "$(dirname "$0")"

# ---------------------------------------------------------------- edit these
# A legal name has to be an entity that exists — a registered company, or the individual
# trading under the brand. "SOC2Starter" alone is a trading name, not a party to a contract.
LEGAL_NAME="Deepak Gandhi (trading as SOC2Starter)"
CONTACT_EMAIL="deepakgandhi2007@gmail.com"
COUNTRY="India"
JURISDICTION="the courts of India"

# Every canonical tag, Open Graph URL, sitemap entry and JSON-LD id is built from this.
# Move to a real domain and this is the ONLY line that changes — then 301 the old host.
SITE_URL="https://soc-2-compliance.vercel.app"

# Paddle. The CLIENT token is public — it authorises nothing on its own, and is meant to
# ship in a web page. The API key that can create charges lives only in Supabase secrets.
# Paddle → Developer tools → Authentication → Client-side tokens.
PADDLE_CLIENT_TOKEN="live_9ea4953bdc1df9ff839bd57a98f"
PADDLE_ENVIRONMENT="production"       # "sandbox" while testing, "production" when live

# These match how the product is deployed today. Change them if that changes.
AI_PROVIDER="Google Gemini"
DATA_REGION="ap-northeast-1 (Tokyo)"
EFFECTIVE_DATE="$(date '+%d %B %Y')"
# ----------------------------------------------------------------

replace() {
  local token="$1" value="$2"
  # macOS and GNU sed disagree about -i, so write through a temp file instead.
  for f in *.html *.txt *.xml; do
    [ -f "$f" ] || continue
    awk -v t="$token" -v v="$value" '{gsub(t, v); print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done
}

replace "__LEGAL_NAME__"     "$LEGAL_NAME"
replace "__CONTACT_EMAIL__"  "$CONTACT_EMAIL"
replace "__COUNTRY__"        "$COUNTRY"
replace "__SITE_URL__"       "$SITE_URL"
replace "__JURISDICTION__"   "$JURISDICTION"
replace "__AI_PROVIDER__"    "$AI_PROVIDER"
replace "__DATA_REGION__"    "$DATA_REGION"
replace "__EFFECTIVE_DATE__" "$EFFECTIVE_DATE"

if [ "$PADDLE_CLIENT_TOKEN" != "__PADDLE_CLIENT_TOKEN__" ]; then
  replace "__PADDLE_CLIENT_TOKEN__" "$PADDLE_CLIENT_TOKEN"
  awk -v e="$PADDLE_ENVIRONMENT" \
      '{gsub(/var PADDLE_ENVIRONMENT = "[a-z]*"/, "var PADDLE_ENVIRONMENT = \"" e "\""); print}' \
      checkout.html > checkout.html.tmp && mv checkout.html.tmp checkout.html
else
  echo "note: PADDLE_CLIENT_TOKEN is not set yet, so /checkout will say so rather than fail silently."
fi

# The Paddle token is the one placeholder that is allowed to remain: the rest of the site
# is publishable without it, and /checkout says so plainly rather than failing silently.
left=$(grep -oh '__[A-Z_]*__' ./*.html ./*.txt ./*.xml 2>/dev/null | sort -u | grep -v '__PADDLE_CLIENT_TOKEN__' || true)
if [ -n "$left" ]; then
  echo "Still contains placeholders:"
  echo "$left" | sed 's/^/  /'
  exit 1
fi
echo "Done. Every required placeholder is filled."
