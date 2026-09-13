#!/usr/bin/env bash
# Stamp the stylesheet's content hash into every <link> so a CSS change
# reaches browsers immediately.
#
# /assets/* is cached for a week (deliberately — fast repeat visits). With a
# stable filename that means a redesign can take up to 7 days to appear for
# anyone who visited recently. A hash in the query string changes the URL
# whenever the file changes, so the cache is bypassed exactly when it should be.
#
# Run after any edit to assets/style.css, before committing.
set -euo pipefail
cd "$(dirname "$0")/.."

CSS="assets/style.css"
[ -f "$CSS" ] || { echo "error: $CSS not found" >&2; exit 1; }

if command -v md5 >/dev/null 2>&1; then HASH=$(md5 -q "$CSS"); else HASH=$(md5sum "$CSS" | cut -d' ' -f1); fi
HASH="${HASH:0:8}"

if [ "$(uname)" = "Darwin" ]; then SEDI=(sed -i ''); else SEDI=(sed -i); fi

FILES=$(find . -name '*.html' -not -path './.opencode/*' -not -path './app/*' | sort)
N=0
while IFS= read -r f; do
  before=$(md5 -q "$f" 2>/dev/null || md5sum "$f" | cut -d' ' -f1)
  "${SEDI[@]}" -E "s|href=\"/assets/style\.css(\?v=[a-f0-9]+)?\"|href=\"/assets/style.css?v=${HASH}\"|g" "$f"
  after=$(md5 -q "$f" 2>/dev/null || md5sum "$f" | cut -d' ' -f1)
  [ "$before" != "$after" ] && { printf '  %s\n' "${f#./}"; N=$((N+1)); }
done <<< "$FILES"

echo
echo "stylesheet hash: $HASH"
echo "updated $N file(s)"
MISSING=$(grep -rL "style.css?v=${HASH}" --include="*.html" . 2>/dev/null | grep -v "/.opencode/" | grep -v "/app/" || true)
if [ -n "$MISSING" ]; then
  echo
  echo "note: these HTML files do not reference the stylesheet at all:"
  echo "$MISSING" | sed 's|^|  |'
fi
