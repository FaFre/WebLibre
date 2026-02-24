#!/usr/bin/env sh

set -eu

BASE=$(dirname "$0")

cd "$BASE/../app/assets/preferences" || exit

TARGET="url-shortener-list.json"
TMP_FILE="${TARGET}.tmp"

if wget -O "$TMP_FILE" https://raw.githubusercontent.com/MISP/misp-warninglists/refs/heads/main/lists/url-shortener/list.json; then
  mv "$TMP_FILE" "$TARGET"
  echo "Updated $TARGET"
else
  rm -f "$TMP_FILE"
  echo "Failed to fetch $TARGET, keeping existing file" >&2
fi
