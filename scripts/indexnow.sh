#!/usr/bin/env bash
# Step 0.4 (the automatable half) — announce every public URL via IndexNow.
#
# IndexNow is a documented, keyless-auth push API. Bing, Yandex, Seznam and
# Naver consume it; Google does not (Google only reads the sitemap, so keep
# submitting that in Search Console).
#
# Ownership is proved by a key file served from the site root, so the site
# must be DEPLOYED with that file before this will work.
#
#   ./scripts/indexnow.sh              submit every URL in sitemap.xml
#   ./scripts/indexnow.sh --check      verify the key file is reachable, submit nothing
#   ./scripts/indexnow.sh /pricing     submit one path only
set -euo pipefail
cd "$(dirname "$0")/.."

KEYFILE=$(ls -1 [0-9a-f]*.txt 2>/dev/null | head -1 || true)
if [ -z "$KEYFILE" ]; then
  echo "error: no IndexNow key file found in the site root." >&2
  echo "create one:  KEY=\$(od -An -tx1 -N32 /dev/urandom | tr -d ' \\n'); echo -n \"\$KEY\" > \"\$KEY.txt\"" >&2
  exit 1
fi
KEY="${KEYFILE%.txt}"

HOST=$(grep -o '<loc>https\?://[^/<]*' sitemap.xml | head -1 | sed 's|.*://||')
if [ -z "$HOST" ]; then echo "error: could not read host from sitemap.xml" >&2; exit 1; fi

KEYURL="https://${HOST}/${KEYFILE}"

echo "host          $HOST"
echo "key           $KEY"
echo "key location  $KEYURL"
echo

echo -n "Checking the key file is live... "
REMOTE=$(curl -fsS --max-time 15 "$KEYURL" 2>/dev/null || true)
if [ "$REMOTE" != "$KEY" ]; then
  echo "NOT REACHABLE"
  echo
  echo "  $KEYURL must return exactly the key text before search engines will" >&2
  echo "  accept a submission. Commit ${KEYFILE} and deploy, then run this again." >&2
  exit 1
fi
echo "ok"

if [ "${1:-}" = "--check" ]; then echo; echo "Key verified. Nothing submitted (--check)."; exit 0; fi

if [ -n "${1:-}" ]; then
  URLS="https://${HOST}${1}"
else
  URLS=$(grep -o '<loc>[^<]*</loc>' sitemap.xml | sed -e 's|<loc>||g' -e 's|</loc>||g')
fi

N=$(echo "$URLS" | wc -l | tr -d ' ')

# Never announce a URL that is not actually live. Submitting a 404 wastes the
# crawl, burns IndexNow quota, and usually means the change was not deployed.
echo
echo "Checking $N URL(s) are live:"
DEAD=0
while IFS= read -r u; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$u" || echo 000)
  if [ "$code" = "200" ]; then
    printf '  %-3s %s\n' "$code" "$u"
  else
    printf '  \033[31m%-3s %s\033[0m\n' "$code" "$u"
    DEAD=$((DEAD + 1))
  fi
done <<< "$URLS"

if [ "$DEAD" -gt 0 ]; then
  echo
  echo "$DEAD URL(s) are not live. Nothing submitted." >&2
  echo "Deploy first, then run this again:" >&2
  echo "  git add -A && git commit -m '...' && git push" >&2
  echo "Use --force to submit anyway." >&2
  case "${*}" in *--force*) echo "(--force given, continuing)" ;; *) exit 1 ;; esac
fi

LIST=$(echo "$URLS" | sed 's|.*|"&"|' | paste -sd, -)
BODY="{\"host\":\"${HOST}\",\"key\":\"${KEY}\",\"keyLocation\":\"${KEYURL}\",\"urlList\":[${LIST}]}"

echo
CODE=$(curl -sS -o /tmp/indexnow.out -w '%{http_code}' --max-time 30 \
  -X POST "https://api.indexnow.org/indexnow" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$BODY")

case "$CODE" in
  200) echo "200 OK — accepted. Bing, Yandex, Seznam and Naver have the list." ;;
  202) echo "202 Accepted — received; key validation pending on their side." ;;
  400) echo "400 Bad request — malformed submission." ; cat /tmp/indexnow.out ;;
  403) echo "403 Forbidden — key file not valid for this host." ; cat /tmp/indexnow.out ;;
  422) echo "422 — a URL does not belong to $HOST, or the key does not match." ; cat /tmp/indexnow.out ;;
  429) echo "429 — too many requests. Wait and retry; do not loop." ;;
  *)   echo "HTTP $CODE" ; cat /tmp/indexnow.out ;;
esac
echo
echo "Google ignores IndexNow — keep submitting sitemap.xml in Search Console."
