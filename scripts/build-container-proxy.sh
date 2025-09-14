#!/usr/bin/env sh

BASE=$(dirname "$0")

cd "$BASE/../packages/flutter_mozilla_components/javascript/container_proxy" || exit

npm ci
npx webpack