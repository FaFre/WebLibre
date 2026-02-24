#!/usr/bin/env sh

set -eu

BASE=$(dirname "$0")

cd "$BASE/../app/assets/preferences" || exit

TARGET="url_cleaner_data.minify.json"
TMP_FILE="${TARGET}.tmp"

if wget -O "$TMP_FILE" "https://rules2.clearurls.xyz/data.minify.json"; then
  mv "$TMP_FILE" "$TARGET"
  echo "Updated $TARGET"
else
  rm -f "$TMP_FILE"
  echo "Failed to fetch $TARGET, keeping existing file" >&2
fi
