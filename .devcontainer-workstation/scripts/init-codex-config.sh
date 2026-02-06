#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME_DIR="${CODEX_HOME:-/root/.codex}"
DEFAULT_CONFIG="/etc/codex/config.toml"
TARGET_CONFIG="${CODEX_HOME_DIR}/config.toml"

mkdir -p "$CODEX_HOME_DIR"

# Seed CODEX_HOME with repo-defined defaults when no config exists yet.
if [ ! -f "$TARGET_CONFIG" ]; then
  cp "$DEFAULT_CONFIG" "$TARGET_CONFIG"
  chmod 600 "$TARGET_CONFIG"
fi

exec "$@"
