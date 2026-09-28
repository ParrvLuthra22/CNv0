#!/usr/bin/env bash
# Task F — Cache-Control / ETag / 304 demo.
# Run from Mac 2 once nginx + both backends are up.
set -euo pipefail

HOST="${1:-app.team1.test}"
URL="https://${HOST}/api/cached"

echo "=== 1) Full request (200, body + headers) ==="
curl -sD - "$URL" -o /tmp/cache-demo-body.json
echo "--- body ---"
cat /tmp/cache-demo-body.json
echo ""

ETAG=$(curl -sI "$URL" | grep -i '^etag:' | sed 's/[Ee][Tt]ag: //I' | tr -d '\r')
echo "=== 2) Conditional request with If-None-Match: $ETAG (expect 304, no body) ==="
curl -sD - -o /dev/null "$URL" -H "If-None-Match: $ETAG"

echo ""
echo "=== 3) Fresh cache hit ==="
echo "Not something curl demonstrates (curl has no cache)."
echo "Explain live: Cache-Control: public, max-age=60 tells a BROWSER it can reuse"
echo "the response for 60s with zero network requests. Show this in Chrome DevTools"
echo "Network tab: reload within 60s -> status shown as (memory cache) / (disk cache),"
echo "no request even sent. After 60s, the browser sends the conditional request from"
echo "step 2 automatically."
