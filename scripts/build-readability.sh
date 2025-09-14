#!/usr/bin/env sh

BASE=$(dirname "$0")

cd "$BASE/../packages/flutter_mozilla_components/javascript/readability" || exit

npm ci
npx webpack