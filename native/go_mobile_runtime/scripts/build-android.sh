#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
RUNTIME_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
REPO_ROOT="$(cd "$RUNTIME_DIR/../.." && pwd -P)"

# shellcheck source=../pins.env
source "$RUNTIME_DIR/pins.env"

DEFAULT_SING_BOX_SOURCE="$(cd "$REPO_ROOT/.." && pwd -P)/sing-box"
DEFAULT_IPTPROXY_SOURCE="$(cd "$REPO_ROOT/.." && pwd -P)/IPtProxy"

SING_BOX_SOURCE="${SING_BOX_SOURCE:-$DEFAULT_SING_BOX_SOURCE}"
IPTPROXY_SOURCE="${IPTPROXY_SOURCE:-$DEFAULT_IPTPROXY_SOURCE}"
DNSTT_SOURCE="${DNSTT_SOURCE:-$IPTPROXY_SOURCE/dnstt}"
OUTPUT_AAR="${OUTPUT_AAR:-$RUNTIME_DIR/build/weblibre-go.aar}"
TARGET="${TARGET:-android}"
ANDROID_API="${ANDROID_API:-24}"
INSTALL_GOMOBILE=1
ALLOW_DIRTY=0
DEBUG=0

DEFAULT_TAGS="with_conntrack,with_gvisor,with_quic,with_wireguard,with_utls,with_naive_outbound,with_clash_api,badlinkname,tfogo_checklinkname0,netcgo"
GO_MOBILE_TAGS="${GO_MOBILE_TAGS:-$DEFAULT_TAGS}"

usage() {
  cat <<'EOF'
Usage: build-android.sh [options]

Build the combined WebLibre gomobile Android AAR containing sing-box libbox and IPtProxy.

Options:
  --sing-box-source PATH      sing-box checkout (default: ../sing-box)
  --iptproxy-source PATH      IPtProxy checkout (default: ../IPtProxy)
  --dnstt-source PATH         dnstt checkout (default: <IPtProxy>/dnstt)
  --output PATH               destination AAR (default: native/go_mobile_runtime/build/weblibre-go.aar)
  --target TARGET             gomobile target, e.g. android/arm64 (default: android)
  --android-api API           Android API level for gomobile bind (default: 24)
  --tags TAGS                 comma-separated Go build tags
  --debug                     keep debug symbols
  --allow-dirty               allow dirty sing-box/IPtProxy source trees
  --skip-install-gomobile     require gomobile/gobind in GOPATH/bin
  -h, --help                  show this help

Environment:
  SING_BOX_SOURCE, IPTPROXY_SOURCE, DNSTT_SOURCE, OUTPUT_AAR, TARGET,
  ANDROID_API, GO_MOBILE_TAGS, JAVA_HOME, ANDROID_HOME, ANDROID_NDK_HOME
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sing-box-source)
      SING_BOX_SOURCE="$2"
      shift 2
      ;;
    --iptproxy-source)
      IPTPROXY_SOURCE="$2"
      shift 2
      ;;
    --dnstt-source)
      DNSTT_SOURCE="$2"
      shift 2
      ;;
    --output)
      OUTPUT_AAR="$2"
      shift 2
      ;;
    --target)
      TARGET="$2"
      shift 2
      ;;
    --android-api)
      ANDROID_API="$2"
      shift 2
      ;;
    --tags)
      GO_MOBILE_TAGS="$2"
      shift 2
      ;;
    --debug)
      DEBUG=1
      shift
      ;;
    --allow-dirty)
      ALLOW_DIRTY=1
      shift
      ;;
    --skip-install-gomobile)
      INSTALL_GOMOBILE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_dir() {
  local path="$1"
  local description="$2"
  if [[ ! -d "$path" ]]; then
    echo "$description not found at: $path" >&2
    exit 1
  fi
}

require_file() {
  local path="$1"
  local description="$2"
  if [[ ! -f "$path" ]]; then
    echo "$description not found at: $path" >&2
    exit 1
  fi
}

verify_git_pin() {
  local repo="$1"
  local name="$2"
  local tag="$3"
  local expected_commit="$4"

  local tag_commit
  tag_commit="$(git -C "$repo" rev-parse --verify "refs/tags/$tag^{commit}")"
  if [[ "$tag_commit" != "$expected_commit" ]]; then
    echo "$name tag $tag resolves to $tag_commit, expected $expected_commit" >&2
    exit 1
  fi

  local head_commit
  head_commit="$(git -C "$repo" rev-parse HEAD)"
  if [[ "$head_commit" != "$expected_commit" ]]; then
    echo "$name checkout is at $head_commit, expected $tag ($expected_commit)." >&2
    echo "Check out the pinned tag first: git -C '$repo' checkout '$tag'" >&2
    exit 1
  fi

  if [[ $ALLOW_DIRTY -eq 0 && -n "$(git -C "$repo" status --porcelain)" ]]; then
    echo "$name checkout has uncommitted changes. Re-run with --allow-dirty to build anyway." >&2
    exit 1
  fi
}

require_dir "$SING_BOX_SOURCE" "sing-box source"
require_file "$SING_BOX_SOURCE/go.mod" "sing-box go.mod"
require_dir "$SING_BOX_SOURCE/experimental/libbox" "sing-box libbox package"

require_dir "$IPTPROXY_SOURCE" "IPtProxy source"
require_file "$IPTPROXY_SOURCE/IPtProxy.go/go.mod" "IPtProxy go.mod"
require_dir "$DNSTT_SOURCE" "dnstt source"
require_file "$DNSTT_SOURCE/go.mod" "dnstt go.mod"

verify_git_pin "$SING_BOX_SOURCE" "sing-box" "$SING_BOX_TAG" "$SING_BOX_COMMIT"
verify_git_pin "$IPTPROXY_SOURCE" "IPtProxy" "$IPTPROXY_TAG" "$IPTPROXY_COMMIT"

read -r _ _ iptproxy_dnstt_commit _ <<< "$(git -C "$IPTPROXY_SOURCE" ls-tree "$IPTPROXY_TAG" dnstt)"
if [[ "$iptproxy_dnstt_commit" != "$DNSTT_COMMIT" ]]; then
  echo "IPtProxy tag $IPTPROXY_TAG points dnstt to $iptproxy_dnstt_commit, expected $DNSTT_COMMIT" >&2
  exit 1
fi

if [[ -d "$DNSTT_SOURCE/.git" ]]; then
  dnstt_head="$(git -C "$DNSTT_SOURCE" rev-parse HEAD)"
  if [[ "$dnstt_head" != "$DNSTT_COMMIT" ]]; then
    echo "dnstt checkout is at $dnstt_head, expected $DNSTT_COMMIT." >&2
    exit 1
  fi
fi

if [[ -z "${JAVA_HOME:-}" && -x /usr/lib/jvm/java-17-openjdk/bin/java ]]; then
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
fi

JAVA_BIN="${JAVA_HOME:+$JAVA_HOME/bin/}java"
if ! "$JAVA_BIN" --version 2>/dev/null | grep -q 'openjdk 17'; then
  echo "gomobile Android runtime build requires OpenJDK 17." >&2
  "$JAVA_BIN" --version >&2 || true
  exit 1
fi

if ! command -v go >/dev/null 2>&1; then
  echo "go is required to build the gomobile runtime." >&2
  exit 1
fi

GOPATH="${GOPATH:-$(go env GOPATH)}"
if [[ $INSTALL_GOMOBILE -eq 1 ]]; then
  needs_gomobile_install=0
  if [[ ! -x "$GOPATH/bin/gomobile" || ! -x "$GOPATH/bin/gobind" ]]; then
    needs_gomobile_install=1
  elif ! "$GOPATH/bin/gomobile" bind -h 2>&1 | grep -q -- '-libname'; then
    needs_gomobile_install=1
  fi

  if [[ $needs_gomobile_install -eq 1 ]]; then
    go install -v "$GOMOBILE_MODULE/cmd/gomobile@$GOMOBILE_VERSION"
    go install -v "$GOMOBILE_MODULE/cmd/gobind@$GOMOBILE_VERSION"
  fi
fi

"$GOPATH/bin/gomobile" init

WORK_DIR="$RUNTIME_DIR/.work/android"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR" "$(dirname "$OUTPUT_AAR")"

cat > "$WORK_DIR/go.mod" <<EOF
module eu.weblibre.go_mobile_runtime

go 1.25.0

require (
	github.com/sagernet/gomobile $GOMOBILE_VERSION
	github.com/sagernet/sing-box v1.13.12
	github.com/tladesignz/IPtProxy.git v0.0.0
)

replace github.com/sagernet/sing-box => $SING_BOX_SOURCE
replace github.com/tladesignz/IPtProxy.git => $IPTPROXY_SOURCE/IPtProxy.go
replace www.bamsoftware.com/git/dnstt.git => $DNSTT_SOURCE
EOF

cat > "$WORK_DIR/tools.go" <<'EOF'
package tools

import (
	_ "github.com/sagernet/gomobile"
	_ "github.com/sagernet/gomobile/bind"
	_ "github.com/sagernet/sing-box/experimental/libbox"
	_ "github.com/tladesignz/IPtProxy.git"
)
EOF

pushd "$WORK_DIR" >/dev/null
go get "$GOMOBILE_MODULE/bind@$GOMOBILE_VERSION"
go mod tidy

args=(
  bind
  -v
  -target "$TARGET"
  -androidapi "$ANDROID_API"
  -javapkg=io.nekohasekai
  -libname=box
  -o "$OUTPUT_AAR"
  -trimpath
  -tags "$GO_MOBILE_TAGS"
)

if [[ $DEBUG -eq 0 ]]; then
  args+=(-ldflags "-s -w -checklinkname=0")
else
  args+=(-ldflags "-checklinkname=0")
fi

args+=(
  github.com/sagernet/sing-box/experimental/libbox
  github.com/tladesignz/IPtProxy.git
)

"$GOPATH/bin/gomobile" "${args[@]}"
popd >/dev/null

echo "Installed $OUTPUT_AAR"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$OUTPUT_AAR"
fi
