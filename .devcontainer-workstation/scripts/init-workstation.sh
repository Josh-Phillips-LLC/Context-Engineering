#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME_DIR="${CODEX_HOME:-/root/.codex}"
DEFAULT_CONFIG="/etc/codex/config.toml"
TARGET_CONFIG="${CODEX_HOME_DIR}/config.toml"
ROLE_PROFILE="${ROLE_PROFILE:-implementation-specialist}"
ROLE_PROFILES_DIR="/etc/codex/role-profiles"
WORKSPACE_REPO_URL="${WORKSPACE_REPO_URL:-https://github.com/Josh-Phillips-LLC/Context-Engineering.git}"
WORKSPACE_REPO_DIR="${WORKSPACE_REPO_DIR:-/workspace/Projects/Context-Engineering}"
AUTO_CLONE_WORKSPACE_REPO="${AUTO_CLONE_WORKSPACE_REPO:-true}"

replace_string_setting() {
  local key="$1"
  local value="$2"
  local escaped_value

  escaped_value="$(printf '%s' "$value" | sed 's/[\/&]/\\&/g')"

  if grep -qE "^${key} = " "$TARGET_CONFIG"; then
    sed -i -E "s|^${key} = .*|${key} = \"${escaped_value}\"|" "$TARGET_CONFIG"
  else
    echo "Warning: key '${key}' not found in ${TARGET_CONFIG}; skipping." >&2
  fi
}

replace_raw_setting() {
  local key="$1"
  local raw_value="$2"
  local escaped_value

  escaped_value="$(printf '%s' "$raw_value" | sed 's/[\/&]/\\&/g')"

  if grep -qE "^${key} = " "$TARGET_CONFIG"; then
    sed -i -E "s|^${key} = .*|${key} = ${escaped_value}|" "$TARGET_CONFIG"
  else
    echo "Warning: key '${key}' not found in ${TARGET_CONFIG}; skipping." >&2
  fi
}

apply_role_profile() {
  local profile_file="${ROLE_PROFILES_DIR}/${ROLE_PROFILE}.env"

  if [ ! -f "$profile_file" ]; then
    echo "Warning: role profile '${ROLE_PROFILE}' not found at ${profile_file}; using existing config values." >&2
    return
  fi

  # shellcheck disable=SC1090
  source "$profile_file"

  if [ -n "${ROLE_APPROVAL_POLICY:-}" ]; then
    replace_string_setting "approval_policy" "$ROLE_APPROVAL_POLICY"
  fi

  if [ -n "${ROLE_MODEL_REASONING_EFFORT:-}" ]; then
    replace_string_setting "model_reasoning_effort" "$ROLE_MODEL_REASONING_EFFORT"
  fi

  if [ -n "${ROLE_MODEL_PERSONALITY:-}" ]; then
    replace_string_setting "model_personality" "$ROLE_MODEL_PERSONALITY"
  fi

  if [ -n "${ROLE_WRITABLE_ROOTS:-}" ]; then
    replace_raw_setting "writable_roots" "$ROLE_WRITABLE_ROOTS"
  fi

  echo "Applied role profile '${ROLE_PROFILE}'."
}

mkdir -p "$CODEX_HOME_DIR"

# Seed CODEX_HOME with repo-defined defaults when no config exists yet.
if [ ! -f "$TARGET_CONFIG" ]; then
  cp "$DEFAULT_CONFIG" "$TARGET_CONFIG"
  chmod 600 "$TARGET_CONFIG"
fi

apply_role_profile

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
