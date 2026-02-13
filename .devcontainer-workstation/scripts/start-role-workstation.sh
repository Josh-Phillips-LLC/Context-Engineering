#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSTATION_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  start-role-workstation.sh [options]

Options:
  --role <implementation|compliance|systems-architect>
  --auth-mode <app|user>
  --pem-path <host_path_to_pem>
  --source <ghcr|local>
  --help

Notes:
  - If options are omitted, the script prompts interactively.
  - In app mode, --pem-path is required (or prompted).
  - The PEM is mounted as a compose secret at:
    /run/secrets/role_github_app_private_key
EOF
}

prompt_if_empty() {
  local var_name="$1"
  local prompt_label="$2"
  local default_value="${3:-}"
  local value="${!var_name:-}"

  if [ -n "$value" ]; then
    return
  fi

  if [ -n "$default_value" ]; then
    read -r -p "${prompt_label} [${default_value}]: " value
    value="${value:-$default_value}"
  else
    read -r -p "${prompt_label}: " value
  fi

  printf -v "$var_name" '%s' "$value"
}

normalize_role() {
  case "$1" in
    implementation|implementation-specialist) echo "implementation" ;;
    compliance|compliance-officer) echo "compliance" ;;
    systems-architect|systems|architect) echo "systems-architect" ;;
    *) return 1 ;;
  esac
}

normalize_auth_mode() {
  case "$1" in
    app|user) echo "$1" ;;
    *) return 1 ;;
  esac
}

normalize_source() {
  case "$1" in
    ghcr|local) echo "$1" ;;
    *) return 1 ;;
  esac
}

ROLE=""
AUTH_MODE=""
PEM_PATH=""
SOURCE=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --role)
      ROLE="${2:-}"
      shift 2
      ;;
    --auth-mode)
      AUTH_MODE="${2:-}"
      shift 2
      ;;
    --pem-path)
      PEM_PATH="${2:-}"
      shift 2
      ;;
    --source)
      SOURCE="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -n "$ROLE" ]; then
  ROLE="$(normalize_role "$ROLE")" || {
    echo "Invalid --role value: $ROLE" >&2
    exit 1
  }
fi

if [ -n "$AUTH_MODE" ]; then
  AUTH_MODE="$(normalize_auth_mode "$AUTH_MODE")" || {
    echo "Invalid --auth-mode value: $AUTH_MODE" >&2
    exit 1
  }
fi

if [ -n "$SOURCE" ]; then
  SOURCE="$(normalize_source "$SOURCE")" || {
    echo "Invalid --source value: $SOURCE" >&2
    exit 1
  }
fi

if [ -z "$SOURCE" ]; then
  echo "Select image source:"
  echo "  1) ghcr (published images)"
  echo "  2) local (build from local Dockerfile)"
  read -r -p "Choice [1]: " source_choice
  case "${source_choice:-1}" in
    1) SOURCE="ghcr" ;;
    2) SOURCE="local" ;;
    *)
      echo "Invalid source choice." >&2
      exit 1
      ;;
  esac
fi

if [ -z "$ROLE" ]; then
  echo "Select role:"
  echo "  1) implementation"
  echo "  2) compliance"
  echo "  3) systems-architect"
  read -r -p "Choice [2]: " role_choice
  case "${role_choice:-2}" in
    1) ROLE="implementation" ;;
    2) ROLE="compliance" ;;
    3) ROLE="systems-architect" ;;
    *)
      echo "Invalid role choice." >&2
      exit 1
      ;;
  esac
fi

prompt_if_empty AUTH_MODE "Auth mode (app|user)" "app"
AUTH_MODE="$(normalize_auth_mode "$AUTH_MODE")" || {
  echo "Invalid auth mode: $AUTH_MODE" >&2
  exit 1
}

case "$ROLE" in
  implementation)
    ROLE_PROFILE="implementation-specialist"
    SERVICE_NAME="implementation-workstation"
    PROFILE_NAME=""
    ROLE_ENV_PREFIX="IMPLEMENTATION"
    ;;
  compliance)
    ROLE_PROFILE="compliance-officer"
    SERVICE_NAME="compliance-workstation"
    PROFILE_NAME="compliance-officer"
    ROLE_ENV_PREFIX="COMPLIANCE"
    ;;
  systems-architect)
    ROLE_PROFILE="systems-architect"
    SERVICE_NAME="systems-architect-workstation"
    PROFILE_NAME="systems-architect"
    ROLE_ENV_PREFIX="SYSTEMS_ARCHITECT"
    ;;
esac

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
else
  COMPOSE_CMD=(docker-compose)
fi

case "$SOURCE" in
  ghcr) COMPOSE_FILE="${WORKSTATION_DIR}/docker-compose.ghcr.yml" ;;
  local) COMPOSE_FILE="${WORKSTATION_DIR}/docker-compose.yml" ;;
esac

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
ENV_ARGS=("${ROLE_ENV_PREFIX}_ROLE_GITHUB_AUTH_MODE=${AUTH_MODE}")

TMP_OVERRIDE_FILE=""
cleanup() {
  if [ -n "${TMP_OVERRIDE_FILE:-}" ] && [ -f "$TMP_OVERRIDE_FILE" ]; then
    rm -f "$TMP_OVERRIDE_FILE"
  fi
}
trap cleanup EXIT

if [ "$AUTH_MODE" = "app" ]; then
  if [ -z "$PEM_PATH" ]; then
    read -r -p "PEM path on host filesystem: " PEM_PATH
  fi

  if [ -z "$PEM_PATH" ]; then
    echo "PEM path is required in app mode." >&2
    exit 1
  fi

  if [ ! -r "$PEM_PATH" ]; then
    echo "PEM file is not readable: $PEM_PATH" >&2
    exit 1
  fi

  ENV_ARGS+=("${ROLE_ENV_PREFIX}_ROLE_GITHUB_APP_PRIVATE_KEY_PATH=/run/secrets/role_github_app_private_key")
  ENV_ARGS+=(GH_TOKEN= GITHUB_TOKEN=)

  TMP_OVERRIDE_FILE="$(mktemp "/tmp/${SERVICE_NAME}.app-secret.XXXXXX.yml")"
  cat > "$TMP_OVERRIDE_FILE" <<EOF
services:
  ${SERVICE_NAME}:
    secrets:
      - source: role_github_app_private_key
        target: role_github_app_private_key
secrets:
  role_github_app_private_key:
    file: "${PEM_PATH}"
EOF
  COMPOSE_ARGS+=(-f "$TMP_OVERRIDE_FILE")
fi

if [ -n "$PROFILE_NAME" ]; then
  COMPOSE_ARGS+=(--profile "$PROFILE_NAME")
fi

UP_ARGS=(up -d)
if [ "$SOURCE" = "local" ]; then
  UP_ARGS+=(--build)
fi
UP_ARGS+=("$SERVICE_NAME")

echo "Starting ${SERVICE_NAME} (${ROLE_PROFILE}) using ${SOURCE}..."
env "${ENV_ARGS[@]}" "${COMPOSE_CMD[@]}" "${COMPOSE_ARGS[@]}" "${UP_ARGS[@]}"

if docker ps --filter "name=^/${SERVICE_NAME}$" --filter "status=running" --format '{{.Names}}' | grep -qx "$SERVICE_NAME"; then
  echo "Container is running: ${SERVICE_NAME}"
  echo "VS Code attach target: ${SERVICE_NAME}"
else
  echo "Container failed to stay running: ${SERVICE_NAME}" >&2
  echo "Inspect logs with:" >&2
  echo "  ${COMPOSE_CMD[*]} ${COMPOSE_ARGS[*]} logs --tail=200 ${SERVICE_NAME}" >&2
  exit 1
fi
