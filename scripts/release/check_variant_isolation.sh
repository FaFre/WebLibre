#!/usr/bin/env bash
# Fails if a release variant keeps any of the given classes (plan 9.3).
#
# Usage: check_variant_isolation.sh <variant> <class name or prefix>...
#
# R8 renames what it keeps, so the dex alone proves nothing: the variant's
# mapping lists the original name of every class left in it.
set -euo pipefail

variant="$1"
shift
mapping="apps/weblibre/build/app/outputs/mapping/${variant}Release/mapping.txt"
if [[ ! -s "$mapping" ]]; then
  echo "No R8 mapping for $variant at $mapping" >&2
  exit 1
fi
for name in "$@"; do
  if grep -q -F -e "$name" "$mapping"; then
    echo "$variant keeps $name (R8 mapping)" >&2
    exit 1
  fi
done
