#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
DEFAULT_SING_BOX_SOURCE="$(cd "$PACKAGE_DIR/../../.." && pwd -P)/sing-box"

SING_BOX_SOURCE="${SING_BOX_SOURCE:-$DEFAULT_SING_BOX_SOURCE}"
OUTPUT_DIR="$PACKAGE_DIR/android/libs"
BUILD_DEBUG=0
PLATFORM=""
INSTALL_GOMOBILE=1

usage() {
  cat <<'EOF'
Usage: build-libbox-android.sh [options]

Build official sing-box libbox Android AARs and copy them into this plugin.

Options:
  --source PATH              sing-box source checkout (default: ../../../sing-box)
  --output-dir PATH          destination for libbox.aar (default: android/libs)
  --platform TARGET          gomobile target, e.g. android/arm64 for faster local builds
  --debug                    build sing-box debug variant
  --skip-install-gomobile    require gomobile/gobind to already exist in GOPATH/bin
  -h, --help                 show this help

Environment:
  SING_BOX_SOURCE            same as --source
  JAVA_HOME                  should point to OpenJDK 17; auto-detected locally when unset
  ANDROID_HOME               Android SDK path, required by sing-box build tooling
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SING_BOX_SOURCE="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --debug)
      BUILD_DEBUG=1
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

if [[ ! -f "$SING_BOX_SOURCE/Makefile" || ! -d "$SING_BOX_SOURCE/experimental/libbox" ]]; then
  echo "sing-box source not found at: $SING_BOX_SOURCE" >&2
  echo "Pass --source PATH or set SING_BOX_SOURCE." >&2
  exit 1
fi

if [[ -z "${JAVA_HOME:-}" && -x /usr/lib/jvm/java-17-openjdk/bin/java ]]; then
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
fi

JAVA_BIN="${JAVA_HOME:+$JAVA_HOME/bin/}java"
if ! "$JAVA_BIN" --version 2>/dev/null | grep -q 'openjdk 17'; then
  echo "sing-box Android libbox build requires OpenJDK 17." >&2
  echo "Current java:" >&2
  "$JAVA_BIN" --version >&2 || true
  exit 1
fi

if ! command -v go >/dev/null 2>&1; then
  echo "go is required to build sing-box libbox." >&2
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
    go install -v github.com/sagernet/gomobile/cmd/gomobile@v0.1.12
    go install -v github.com/sagernet/gomobile/cmd/gobind@v0.1.12
  fi
fi

mkdir -p "$OUTPUT_DIR"

pushd "$SING_BOX_SOURCE" >/dev/null
args=(go run ./cmd/internal/build_libbox -target android)
if [[ $BUILD_DEBUG -eq 1 ]]; then
  args+=(-debug)
fi
if [[ -n "$PLATFORM" ]]; then
  args+=(-platform "$PLATFORM")
fi

"${args[@]}"

cp -f libbox.aar "$OUTPUT_DIR/libbox.aar"
if [[ -f libbox-legacy.aar ]]; then
  cp -f libbox-legacy.aar "$OUTPUT_DIR/libbox-legacy.aar"
fi
popd >/dev/null

echo "Installed $OUTPUT_DIR/libbox.aar"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$OUTPUT_DIR"/libbox*.aar
fi
