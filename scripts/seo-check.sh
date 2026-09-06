#!/usr/bin/env bash
# Re-run the on-page audit. Exits non-zero if anything regressed.
# Run after any content change, and after ./scripts/migrate-domain.sh
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0
note() { printf '  %-52s %s\n' "$1" "$2"; }
bad()  { FAIL=1; printf '  %-52s \033[31m%s\033[0m\n' "$1" "$2"; }

HOST=$(grep -o '<loc>https\?://[^/<]*' sitemap.xml | head -1 | sed 's|.*://||')
echo "Auditing on-page SEO for $HOST"
echo

echo "PAGES"
PAGES=$(find . -name '*.html' -not -path './.opencode/*' -not -path './app/*' -not -name 'google*.html' | sort)
for f in $PAGES; do
  base=$(basename "$f")
  robots=$(grep -o 'name="robots" content="[^"]*"' "$f" | head -1 | sed 's/.*content="//;s/"$//')
  case "$robots" in *noindex*) note "${f#./}" "noindex — skipped"; continue ;; esac

  t=$(grep -o '<title>[^<]*</title>' "$f" | head -1 | sed 's/<[^>]*>//g')
  d=$(grep -o 'name="description" content="[^"]*"' "$f" | head -1 | sed 's/.*content="//;s/"$//')
  can=$(grep -c 'rel="canonical"' "$f")
  ld=$(grep -c 'application/ld+json' "$f")
  h1=$(grep -c '<h1' "$f")
  og=$(grep -c 'property="og:' "$f")

  problems=""
  [ ${#t} -lt 30 ] || [ ${#t} -gt 62 ] && problems="$problems title=${#t}"
  [ ${#d} -lt 120 ] || [ ${#d} -gt 165 ] && problems="$problems desc=${#d}"
  [ "$can" -ne 1 ] && problems="$problems canonical=$can"
  [ "$ld" -lt 1 ] && problems="$problems no-jsonld"
  [ "$h1" -ne 1 ] && problems="$problems h1=$h1"
  [ "$og" -lt 4 ] && problems="$problems og=$og"

  if [ -n "$problems" ]; then bad "${f#./}" "$problems"; else note "${f#./}" "ok"; fi
done

echo
echo "SITEMAP"
SM=$(grep -o '<loc>[^<]*</loc>' sitemap.xml | sed -e 's|<loc>||g' -e 's|</loc>||g' | sed "s|https://$HOST||" | sed 's|^$|/|')
for u in $SM; do
  case "$u" in
    /) f="index.html" ;;
    *) f="${u#/}.html" ;;
  esac
  [ "$u" = "/blog" ] && f="blog/index.html"
  if [ ! -f "$f" ]; then bad "$u" "in sitemap, no such file ($f)"; else note "$u" "-> $f"; fi
done

echo
echo "ORPHANS (indexable pages missing from sitemap)"
ORPH=0
for f in $PAGES; do
  robots=$(grep -o 'name="robots" content="[^"]*"' "$f" | head -1 | sed 's/.*content="//;s/"$//')
  case "$robots" in *noindex*) continue ;; esac
  slug="${f#./}"; slug="${slug%.html}"
  [ "$slug" = "index" ] && slug=""
  [ "$slug" = "blog/index" ] && slug="blog"
  if ! grep -q "<loc>https://$HOST/$slug</loc>" sitemap.xml; then bad "${f#./}" "not in sitemap"; ORPH=1; fi
done
[ "$ORPH" = "0" ] && note "none" "ok"

echo
echo "FILES"
[ -f robots.txt ] && note "robots.txt" "present" || bad "robots.txt" "MISSING"
[ -f llms.txt ] && note "llms.txt" "present" || bad "llms.txt" "MISSING"
grep -q "Sitemap: https://$HOST/sitemap.xml" robots.txt \
  && note "robots.txt sitemap line" "matches $HOST" \
  || bad "robots.txt sitemap line" "does not match $HOST"
K=$(ls -1 [0-9a-f]*.txt 2>/dev/null | head -1)
[ -n "$K" ] && note "indexnow key" "$K" || note "indexnow key" "none (optional)"

echo
if [ "$FAIL" = "0" ]; then echo "PASS — no regressions."; else echo "FAIL — see red rows above."; fi
exit $FAIL
