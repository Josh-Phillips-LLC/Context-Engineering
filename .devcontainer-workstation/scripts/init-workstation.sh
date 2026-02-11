#!/usr/bin/env bash
set -euo pipefail

WORKSTATION_DEBUG="${WORKSTATION_DEBUG:-false}"

if [ "$WORKSTATION_DEBUG" = "true" ]; then
  set -x
  echo "Debug mode enabled for init-workstation.sh"
fi

CODEX_HOME_DIR="${CODEX_HOME:-/root/.codex}"
DEFAULT_CONFIG="/etc/codex/config.toml"
TARGET_CONFIG="${CODEX_HOME_DIR}/config.toml"
ROLE_PROFILE="${ROLE_PROFILE:-${IMAGE_ROLE_PROFILE:-implementation-specialist}}"
ROLE_PROFILES_DIR="/etc/codex/role-profiles"
ROLE_INSTRUCTIONS_DIR_REL="${ROLE_INSTRUCTIONS_DIR_REL:-10-templates/agent-instructions}"
BAKED_ROLE_INSTRUCTIONS_DIR="${BAKED_ROLE_INSTRUCTIONS_DIR:-/etc/codex/agent-instructions}"
BAKED_COMPILED_ROLE_INSTRUCTIONS_DIR="${BAKED_COMPILED_ROLE_INSTRUCTIONS_DIR:-/etc/codex/runtime-role-instructions}"
COMPLIANCE_REVIEW_BRIEF_WORKSPACE_REL="${COMPLIANCE_REVIEW_BRIEF_WORKSPACE_REL:-10-templates/compliance-officer-pr-review-brief.md}"
COMPLIANCE_REVIEW_BRIEF_BAKED="${COMPLIANCE_REVIEW_BRIEF_BAKED:-/etc/codex/agent-instructions/references/compliance-officer-pr-review-brief.md}"
RUNTIME_ROLE_INSTRUCTIONS_FILE="${RUNTIME_ROLE_INSTRUCTIONS_FILE:-/workstation/instructions/role-instructions.md}"
RUNTIME_AGENTS_ADAPTER_FILE="${RUNTIME_AGENTS_ADAPTER_FILE:-/workstation/instructions/AGENTS.md}"
RUNTIME_COPILOT_INSTRUCTIONS_FILE="${RUNTIME_COPILOT_INSTRUCTIONS_FILE:-/workstation/instructions/copilot-instructions.md}"
RUNTIME_VSCODE_SETTINGS_FILE="${RUNTIME_VSCODE_SETTINGS_FILE:-/workstation/settings/vscode/settings.json}"
WORKSPACE_ROLE_INSTRUCTIONS_SHIM_REL=".role.instructions.md"
WORKSPACE_AGENTS_ADAPTER_SHIM_REL="AGENTS.md"
WORKSPACE_COPILOT_INSTRUCTIONS_SHIM_REL=".github/copilot-instructions.md"
WORKSPACE_VSCODE_SETTINGS_SHIM_REL=".vscode/settings.json"
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

  if [ -n "${ROLE_PROJECT_DOC_FALLBACK_FILENAMES:-}" ]; then
    replace_raw_setting "project_doc_fallback_filenames" "$ROLE_PROJECT_DOC_FALLBACK_FILENAMES"
  fi

  echo "Applied role profile '${ROLE_PROFILE}'."
}

render_runtime_role_instructions() {
  local workspace_source_dir="${WORKSPACE_REPO_DIR}/${ROLE_INSTRUCTIONS_DIR_REL}"
  local source_dir="$workspace_source_dir"
  local source_label="workspace:${ROLE_INSTRUCTIONS_DIR_REL}"
  local base_file="${source_dir}/base.md"
  local role_file="${source_dir}/roles/${ROLE_PROFILE}.md"
  local compliance_brief_file="${WORKSPACE_REPO_DIR}/${COMPLIANCE_REVIEW_BRIEF_WORKSPACE_REL}"
  local compiled_role_file="${BAKED_COMPILED_ROLE_INSTRUCTIONS_DIR}/${ROLE_PROFILE}.md"
  local target_file="${RUNTIME_ROLE_INSTRUCTIONS_FILE}"

  mkdir -p "$(dirname "$target_file")"

  if [ ! -f "$base_file" ] || [ ! -f "$role_file" ]; then
    if [ -f "$compiled_role_file" ]; then
      cp "$compiled_role_file" "$target_file"
      chmod 444 "$target_file"
      echo "Generated runtime role instructions at ${target_file} from baked compiled source ${compiled_role_file}."
      return
    fi

    source_dir="$BAKED_ROLE_INSTRUCTIONS_DIR"
    source_label="image:${BAKED_ROLE_INSTRUCTIONS_DIR}"
    base_file="${source_dir}/base.md"
    role_file="${source_dir}/roles/${ROLE_PROFILE}.md"
    compliance_brief_file="${COMPLIANCE_REVIEW_BRIEF_BAKED}"

    if [ ! -f "$base_file" ] || [ ! -f "$role_file" ]; then
      rm -f "$target_file"
      echo "Warning: missing centralized role instruction sources for '${ROLE_PROFILE}' in both workspace and image fallback; runtime role instructions not generated." >&2
      return
    fi
  fi

  {
    echo "# Runtime Role Instructions"
    echo
    echo "Generated by .devcontainer-workstation/scripts/init-workstation.sh"
    echo "Role profile: ${ROLE_PROFILE}"
    echo "Source: ${source_label}"
    echo
    cat "$base_file"
    echo
    cat "$role_file"

    if [ "$ROLE_PROFILE" = "compliance-officer" ]; then
      if [ ! -f "$compliance_brief_file" ] && [ -f "$COMPLIANCE_REVIEW_BRIEF_BAKED" ]; then
        compliance_brief_file="$COMPLIANCE_REVIEW_BRIEF_BAKED"
      fi

      if [ -f "$compliance_brief_file" ]; then
        echo
        echo "# Embedded Compliance Review Brief"
        echo
        cat "$compliance_brief_file"
      else
        echo
        echo "Warning: compliance review brief source not found; role instructions are missing the embedded PR review brief." >&2
      fi
    fi
  } > "$target_file"

  chmod 444 "$target_file"
  echo "Generated runtime role instructions at ${target_file}."
}

render_instruction_adapter_files() {
  local target_file="${RUNTIME_ROLE_INSTRUCTIONS_FILE}"
  local agents_file="${RUNTIME_AGENTS_ADAPTER_FILE}"
  local copilot_file="${RUNTIME_COPILOT_INSTRUCTIONS_FILE}"

  mkdir -p "$(dirname "$agents_file")"
  mkdir -p "$(dirname "$copilot_file")"

  {
    echo "# Runtime Agent Instructions Adapter"
    echo
    echo "Generated by .devcontainer-workstation/scripts/init-workstation.sh"
    echo
    echo "Use the canonical runtime role instructions in \`${RUNTIME_ROLE_INSTRUCTIONS_FILE}\`."
    echo
    echo "- Role profile: ${ROLE_PROFILE}"
    echo "- Canonical instructions file: \`${RUNTIME_ROLE_INSTRUCTIONS_FILE}\`"
    echo
    echo "If \`${RUNTIME_ROLE_INSTRUCTIONS_FILE}\` is missing or unreadable, escalate."
  } > "$agents_file"

  {
    echo "# Runtime Copilot Instructions Adapter"
    echo
    echo "Generated by .devcontainer-workstation/scripts/init-workstation.sh"
    echo
    echo "Use the canonical runtime role instructions at:"
    echo
    echo "- \`${RUNTIME_ROLE_INSTRUCTIONS_FILE}\`"
    echo "- Role profile: ${ROLE_PROFILE}"
    echo
    echo "Do not reinterpret or override role authority boundaries defined there."
  } > "$copilot_file"

  chmod 444 "$agents_file" "$copilot_file"

  if [ ! -f "$target_file" ]; then
    echo "Warning: canonical runtime role instructions file '${target_file}' was not found when generating adapter files." >&2
  fi

  echo "Generated instruction adapter files at ${agents_file} and ${copilot_file}."
}

ensure_workspace_vscode_settings() {
  local settings_file="${RUNTIME_VSCODE_SETTINGS_FILE}"
  local settings_dir
  local defaults_json

  settings_dir="$(dirname "$settings_file")"
  mkdir -p "$settings_dir"

  defaults_json='{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "chat.useAgentsMdFile": true,
  "chat.includeApplyingInstructions": true,
  "chat.includeReferencedInstructions": true
}'

  if command -v jq >/dev/null 2>&1; then
    local tmp_file
    tmp_file="$(mktemp)"

    if [ -f "$settings_file" ] && jq -e . "$settings_file" >/dev/null 2>&1; then
      jq -S -s '.[0] * .[1]' "$settings_file" <(printf '%s\n' "$defaults_json") > "$tmp_file"
    else
      printf '%s\n' "$defaults_json" | jq -S . > "$tmp_file"
    fi

    mv "$tmp_file" "$settings_file"
  else
    printf '%s\n' "$defaults_json" > "$settings_file"
  fi

  chmod 444 "$settings_file"
  echo "Ensured workstation VS Code chat settings at ${settings_file}."
}

ensure_git_exclude_line() {
  local exclude_file="$1"
  local entry="$2"

  if ! grep -qxF "$entry" "$exclude_file"; then
    echo "$entry" >> "$exclude_file"
  fi
}

ensure_workspace_git_excludes() {
  local exclude_file="${WORKSPACE_REPO_DIR}/.git/info/exclude"

  if [ ! -f "$exclude_file" ]; then
    return
  fi

  ensure_git_exclude_line "$exclude_file" "$WORKSPACE_ROLE_INSTRUCTIONS_SHIM_REL"
  ensure_git_exclude_line "$exclude_file" "$WORKSPACE_AGENTS_ADAPTER_SHIM_REL"
  ensure_git_exclude_line "$exclude_file" "$WORKSPACE_COPILOT_INSTRUCTIONS_SHIM_REL"
  ensure_git_exclude_line "$exclude_file" "$WORKSPACE_VSCODE_SETTINGS_SHIM_REL"
}

ensure_workspace_symlink() {
  local workspace_path="$1"
  local target_path="$2"
  local link_target

  mkdir -p "$(dirname "$workspace_path")"

  if [ -e "$workspace_path" ] || [ -L "$workspace_path" ]; then
    if [ -L "$workspace_path" ]; then
      link_target="$(readlink "$workspace_path")"
      if [ "$link_target" = "$target_path" ]; then
        return
      fi

      echo "Warning: workspace shim ${workspace_path} exists but does not point to ${target_path}. Remove it to allow shim creation." >&2
      exit 1
    fi

    echo "Warning: workspace shim path ${workspace_path} exists and is not a symlink. Remove it to allow shim creation." >&2
    exit 1
  fi

  ln -s "$target_path" "$workspace_path"
  echo "Created workspace shim ${workspace_path} -> ${target_path}."
}

ensure_workspace_shims() {
  ensure_workspace_symlink "${WORKSPACE_REPO_DIR}/${WORKSPACE_ROLE_INSTRUCTIONS_SHIM_REL}" "$RUNTIME_ROLE_INSTRUCTIONS_FILE"
  ensure_workspace_symlink "${WORKSPACE_REPO_DIR}/${WORKSPACE_AGENTS_ADAPTER_SHIM_REL}" "$RUNTIME_AGENTS_ADAPTER_FILE"
  ensure_workspace_symlink "${WORKSPACE_REPO_DIR}/${WORKSPACE_COPILOT_INSTRUCTIONS_SHIM_REL}" "$RUNTIME_COPILOT_INSTRUCTIONS_FILE"
  ensure_workspace_symlink "${WORKSPACE_REPO_DIR}/${WORKSPACE_VSCODE_SETTINGS_SHIM_REL}" "$RUNTIME_VSCODE_SETTINGS_FILE"
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

if [ ! -d "$WORKSPACE_REPO_DIR" ]; then
  mkdir -p "$WORKSPACE_REPO_DIR"
  echo "Created workspace repo directory '${WORKSPACE_REPO_DIR}' for runtime role instruction generation."
fi

ensure_workspace_git_excludes

render_runtime_role_instructions
render_instruction_adapter_files
ensure_workspace_vscode_settings
ensure_workspace_shims

exec "$@"
