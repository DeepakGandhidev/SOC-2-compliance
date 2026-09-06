#!/usr/bin/env bash
# Step 0.2 — move the site to a real domain.
# Rewrites every hardcoded occurrence of the old origin, then verifies none survive.
#
#   ./scripts/migrate-domain.sh soc2starter.com
#   ./scripts/migrate-domain.sh soc2starter.com --dry-run
set -euo pipefail

OLD="soc-2-compliance.vercel.app"
NEW="${1:-}"
DRY="${2:-}"

if [ -z "$NEW" ]; then
  echo "usage: $0 <new-domain> [--dry-run]" >&2
  echo "   eg: $0 soc2starter.com" >&2
  exit 1
fi

NEW="${NEW#http://}"; NEW="${NEW#https://}"; NEW="${NEW%/}"

case "$NEW" in
  *.*) : ;;
  *) echo "error: '$NEW' does not look like a domain" >&2; exit 1 ;;
esac

if [ "$NEW" = "$OLD" ]; then
  echo "error: '$NEW' is already the current domain — nothing to migrate." >&2
  echo "       Pass the NEW domain you are moving to, eg:" >&2
  echo "         $0 soc2starter.com" >&2
  exit 1
fi

cd "$(dirname "$0")/.."

FILES=$(grep -rl "$OLD" \
  --include="*.html" --include="*.txt" --include="*.xml" --include="*.json" --include="*.md" \
  . 2>/dev/null | grep -v "/.opencode/" | grep -v "/node_modules/" || true)

if [ -z "$FILES" ]; then
  echo "Nothing to do — no file references $OLD"
  exit 0
fi

echo "Rewriting $OLD -> $NEW"
echo
COUNT=0
while IFS= read -r f; do
  n=$(grep -c "$OLD" "$f" || true)
  printf '  %-46s %3s occurrence(s)\n' "$f" "$n"
  COUNT=$((COUNT + n))
done <<< "$FILES"
echo
echo "  total: $COUNT across $(echo "$FILES" | wc -l | tr -d ' ') file(s)"

if [ "$DRY" = "--dry-run" ]; then
  echo
  echo "Dry run — nothing written."
  exit 0
fi

if [ "$(uname)" = "Darwin" ]; then SEDI=(sed -i ''); else SEDI=(sed -i); fi
while IFS= read -r f; do
  "${SEDI[@]}" "s|${OLD}|${NEW}|g" "$f"
done <<< "$FILES"

echo
LEFT=$(grep -rl "$OLD" --include="*.html" --include="*.txt" --include="*.xml" --include="*.json" --include="*.md" . 2>/dev/null | grep -v "/.opencode/" || true)
if [ -n "$LEFT" ]; then
  echo "WARNING — still referencing the old origin:"
  echo "$LEFT"
  exit 1
fi

echo "Done. No references to $OLD remain."
echo
echo "Still yours to do, in this order:"
echo "  1. Vercel -> Settings -> Domains: add $NEW and set it primary."
echo "     Keep $OLD attached so Vercel 301s it."
echo "  2. Search Console: add $NEW as a Domain property, submit sitemap.xml."
echo "     Keep the old property to watch the 301s process."
echo "  3. Bing Webmaster Tools: import from Search Console, submit the sitemap."
echo "  4. ./scripts/indexnow.sh   (re-announce every URL on the new host)"
echo "  5. Update the canonical row in outreach/directories.md before listing anywhere."
