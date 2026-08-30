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

# These match how the product is deployed today. Change them if that changes.
AI_PROVIDER="Google Gemini"
DATA_REGION="ap-northeast-1 (Tokyo)"
EFFECTIVE_DATE="$(date '+%d %B %Y')"
# ----------------------------------------------------------------

replace() {
  local token="$1" value="$2"
  # macOS and GNU sed disagree about -i, so write through a temp file instead.
  for f in *.html *.txt; do
    [ -f "$f" ] || continue
    awk -v t="$token" -v v="$value" '{gsub(t, v); print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done
}

replace "__LEGAL_NAME__"     "$LEGAL_NAME"
replace "__CONTACT_EMAIL__"  "$CONTACT_EMAIL"
replace "__COUNTRY__"        "$COUNTRY"
replace "__JURISDICTION__"   "$JURISDICTION"
replace "__AI_PROVIDER__"    "$AI_PROVIDER"
replace "__DATA_REGION__"    "$DATA_REGION"
replace "__EFFECTIVE_DATE__" "$EFFECTIVE_DATE"

remaining=$(grep -l '__[A-Z_]*__' ./*.html ./*.txt 2>/dev/null || true)
if [ -n "$remaining" ]; then
  echo "Still contains placeholders:"
  grep -oh '__[A-Z_]*__' ./*.html ./*.txt 2>/dev/null | sort -u | sed 's/^/  /'
  exit 1
fi
echo "Done. Every placeholder is filled."
