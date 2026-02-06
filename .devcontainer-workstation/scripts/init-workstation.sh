#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME_DIR="${CODEX_HOME:-/root/.codex}"
DEFAULT_CONFIG="/etc/codex/config.toml"
TARGET_CONFIG="${CODEX_HOME_DIR}/config.toml"
WORKSPACE_REPO_URL="${WORKSPACE_REPO_URL:-https://github.com/joshphillipssr/Context-Engineering.git}"
WORKSPACE_REPO_DIR="${WORKSPACE_REPO_DIR:-/workspace/Projects/Context-Engineering}"
AUTO_CLONE_WORKSPACE_REPO="${AUTO_CLONE_WORKSPACE_REPO:-true}"

mkdir -p "$CODEX_HOME_DIR"

# Seed CODEX_HOME with repo-defined defaults when no config exists yet.
if [ ! -f "$TARGET_CONFIG" ]; then
  cp "$DEFAULT_CONFIG" "$TARGET_CONFIG"
  chmod 600 "$TARGET_CONFIG"
fi

if [ -n "${GH_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    if printf '%s' "$GH_TOKEN" | env -u GH_TOKEN gh auth login --hostname github.com --git-protocol https --with-token >/dev/null 2>&1; then
      gh auth setup-git >/dev/null 2>&1 || true
      echo "Initialized GitHub auth from GH_TOKEN."
    else
      echo "Warning: failed to initialize GitHub auth from GH_TOKEN." >&2
    fi
  fi
fi

if [ "$AUTO_CLONE_WORKSPACE_REPO" = "true" ]; then
  mkdir -p "$(dirname "$WORKSPACE_REPO_DIR")"
  if [ ! -d "$WORKSPACE_REPO_DIR/.git" ]; then
    if [ -d "$WORKSPACE_REPO_DIR" ] && [ -n "$(ls -A "$WORKSPACE_REPO_DIR" 2>/dev/null || true)" ]; then
      echo "Skipping auto-clone; $WORKSPACE_REPO_DIR exists and is not empty."
    else
      if git clone "$WORKSPACE_REPO_URL" "$WORKSPACE_REPO_DIR" >/dev/null 2>&1; then
        echo "Auto-cloned $WORKSPACE_REPO_URL to $WORKSPACE_REPO_DIR."
      else
        echo "Warning: auto-clone failed for $WORKSPACE_REPO_URL." >&2
      fi
    fi
  fi
fi

exec "$@"
