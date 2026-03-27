#!/usr/bin/env bash
#
# Unified asset updater — downloads all external data files used by the app.
# Usage: ./scripts/update-assets.sh [--group bangs|bridges|url-cleaner|url-shorteners] ...
#   Without --group flags, all groups are updated.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAX_RETRIES=3
RETRY_DELAY=5
CURL_TIMEOUT=30

# ── helpers ──────────────────────────────────────────────────────────────────

log()  { printf '[INFO]  %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*" >&2; }

# Fetch a URL to a local path with retries and atomic write.
# Uses a temp file so a failed download never clobbers an existing asset.
fetch() {
  local url="$1" dest="$2"
  local tmp="${dest}.tmp.$$"

  mkdir -p "$(dirname "$dest")"

  for attempt in $(seq 1 "$MAX_RETRIES"); do
    log "Attempt $attempt/$MAX_RETRIES: $url"
    if curl --proto '=https' --tlsv1.2 -fsSL \
         --max-time "$CURL_TIMEOUT" \
         --retry 0 \
         -o "$tmp" "$url"; then

      # Basic sanity: reject empty files
      if [ ! -s "$tmp" ]; then
        err "Downloaded file is empty: $url"
        rm -f "$tmp"
        return 1
      fi

      mv "$tmp" "$dest"
      log "OK: $dest"
      return 0
    fi

    err "Failed (attempt $attempt/$MAX_RETRIES): $url"
    rm -f "$tmp"
    [ "$attempt" -lt "$MAX_RETRIES" ] && sleep "$RETRY_DELAY"
  done

  err "Giving up after $MAX_RETRIES attempts: $url"
  return 1
}

# ── asset groups ─────────────────────────────────────────────────────────────

update_bangs() {
  local dir="$REPO_ROOT/app/assets/bangs"
  log "Updating bangs..."

  fetch "https://raw.githubusercontent.com/FaFre/bangs/main/data/bangs.json" \
        "$dir/bangs.json"
  fetch "https://raw.githubusercontent.com/FaFre/bangs/main/data/kagi_bangs.json" \
        "$dir/kagi_bangs.json"
  fetch "https://raw.githubusercontent.com/FaFre/bangs/refs/heads/custom/data/custom.json" \
        "$dir/custom.json"

  date -u --iso-8601=seconds > "$dir/last_sync.txt"
  log "Bangs sync completed at $(cat "$dir/last_sync.txt")"
}

update_bridges() {
  local dir="$REPO_ROOT/app/assets/preferences"
  log "Updating Tor bridges..."

  fetch "https://bridges.torproject.org/moat/circumvention/builtin" \
        "$dir/builtin-bridges.json"
}

update_url_cleaner() {
  local dir="$REPO_ROOT/app/assets/preferences"
  log "Updating URL cleaner catalog..."

  fetch "https://rules2.clearurls.xyz/data.minify.json" \
        "$dir/url_cleaner_data.minify.json"
}

update_url_shorteners() {
  local dir="$REPO_ROOT/app/assets/preferences"
  log "Updating URL shortener list..."

  fetch "https://raw.githubusercontent.com/MISP/misp-warninglists/refs/heads/main/lists/url-shortener/list.json" \
        "$dir/url-shortener-list.json"
}

# ── main ─────────────────────────────────────────────────────────────────────

ALL_GROUPS=(bangs bridges url-cleaner url-shorteners)
SELECTED_GROUPS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --group) SELECTED_GROUPS+=("$2"); shift 2 ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

if [ ${#SELECTED_GROUPS[@]} -eq 0 ]; then
  SELECTED_GROUPS=("${ALL_GROUPS[@]}")
fi

FAILURES=0

for group in "${SELECTED_GROUPS[@]}"; do
  case "$group" in
    bangs)          update_bangs          || ((FAILURES++)) ;;
    bridges)        update_bridges        || ((FAILURES++)) ;;
    url-cleaner)    update_url_cleaner    || ((FAILURES++)) ;;
    url-shorteners) update_url_shorteners || ((FAILURES++)) ;;
    *) err "Unknown group: $group"; ((FAILURES++)) ;;
  esac
done

if [ "$FAILURES" -gt 0 ]; then
  err "$FAILURES group(s) failed"
  exit 1
fi

log "All assets updated successfully."
