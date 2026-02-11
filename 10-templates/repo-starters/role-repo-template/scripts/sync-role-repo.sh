#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  sync-role-repo.sh \
    --role-slug <role-slug> \
    --owner <github-owner> \
    [--repo-name <repo-name>] \
    [--role-name <role-name>] \
    [--base-branch <base-branch>] \
    [--source-ref <source-ref>] \
    [--work-dir <work-dir>] \
    [--sync-branch <sync-branch>] \
    [--pr-title <pr-title>] \
    [--no-pr] \
    [--dry-run]

Required:
  --role-slug     Role slug (for example: implementation-specialist)
  --owner         GitHub owner (organization or user)

Optional:
  --repo-name     Defaults to: context-engineering-role-<role-slug>
  --role-name     Optional display name override
  --base-branch   Defaults to: main
  --source-ref    Defaults to current git short SHA in source repo
  --work-dir      Temporary workspace root
  --sync-branch   Defaults to: sync/role-repo/<role-slug>
  --pr-title      Defaults to role sync title
  --no-pr         Sync branch only, do not create/update PR
  --dry-run       Do everything except git push / PR write

Notes:
  - Requires gh + git + python3
  - Requires authenticated gh session with write access to target role repo
  - Managed files synced into target role repo root:
    - AGENTS.md
    - README.md
    - .github/copilot-instructions.md
    - .vscode/settings.json
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENDER_SCRIPT="${SCRIPT_DIR}/render-role-repo-template.sh"

ROLE_SLUG=""
ROLE_NAME=""
OWNER=""
REPO_NAME=""
BASE_BRANCH="main"
SOURCE_REF=""
WORK_DIR=""
SYNC_BRANCH=""
PR_TITLE=""
CREATE_PR="true"
DRY_RUN="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --role-slug)
      ROLE_SLUG="$2"
      shift 2
      ;;
    --role-name)
      ROLE_NAME="$2"
      shift 2
      ;;
    --owner)
      OWNER="$2"
      shift 2
      ;;
    --repo-name)
      REPO_NAME="$2"
      shift 2
      ;;
    --base-branch)
      BASE_BRANCH="$2"
      shift 2
      ;;
    --source-ref)
      SOURCE_REF="$2"
      shift 2
      ;;
    --work-dir)
      WORK_DIR="$2"
      shift 2
      ;;
    --sync-branch)
      SYNC_BRANCH="$2"
      shift 2
      ;;
    --pr-title)
      PR_TITLE="$2"
      shift 2
      ;;
    --no-pr)
      CREATE_PR="false"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$ROLE_SLUG" ] || [ -z "$OWNER" ]; then
  echo "Missing required args: --role-slug and --owner" >&2
  usage
  exit 1
fi

if [ ! -x "$RENDER_SCRIPT" ]; then
  echo "Renderer script not found or not executable: $RENDER_SCRIPT" >&2
  exit 1
fi

for cmd in gh git python3; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

if [ -z "${GH_TOKEN:-}" ] && [ -z "${GITHUB_TOKEN:-}" ]; then
  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    echo "GitHub CLI not authenticated. Run: gh auth login" >&2
    exit 1
  fi
fi

if [ -z "$REPO_NAME" ]; then
  REPO_NAME="context-engineering-role-${ROLE_SLUG}"
fi

if [ -z "$SYNC_BRANCH" ]; then
  SYNC_BRANCH="sync/role-repo/${ROLE_SLUG}"
fi

if [ -z "$PR_TITLE" ]; then
  PR_TITLE="Implementation Specialist: Sync role repo job description for ${ROLE_SLUG}"
fi

FULL_REPO="${OWNER}/${REPO_NAME}"

if [ -z "$SOURCE_REF" ]; then
  if git -C "${SCRIPT_DIR}/../../../.." rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    SOURCE_REF="$(git -C "${SCRIPT_DIR}/../../../.." rev-parse --short HEAD)"
  else
    SOURCE_REF="unknown"
  fi
fi

if ! gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  echo "Target repo does not exist or is inaccessible: $FULL_REPO" >&2
  exit 1
fi

if [ -z "$WORK_DIR" ]; then
  WORK_DIR="$(mktemp -d "/tmp/${REPO_NAME}-sync-XXXXXX")"
fi

RENDER_DIR="${WORK_DIR}/rendered"
TARGET_DIR="${WORK_DIR}/target"

mkdir -p "$RENDER_DIR" "$TARGET_DIR"

render_args=(
  --role-slug "$ROLE_SLUG"
  --repo-name "$REPO_NAME"
  --output-dir "$RENDER_DIR"
  --source-ref "$SOURCE_REF"
)

if [ -n "$ROLE_NAME" ]; then
  render_args+=(--role-name "$ROLE_NAME")
fi

"$RENDER_SCRIPT" "${render_args[@]}" >/dev/null

git clone "https://github.com/${FULL_REPO}.git" "$TARGET_DIR" --branch "$BASE_BRANCH" --single-branch >/dev/null

mkdir -p "$TARGET_DIR/.github" "$TARGET_DIR/.vscode"
cp "$RENDER_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
cp "$RENDER_DIR/README.md" "$TARGET_DIR/README.md"
cp "$RENDER_DIR/.github/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
cp "$RENDER_DIR/.vscode/settings.json" "$TARGET_DIR/.vscode/settings.json"

if git -C "$TARGET_DIR" diff --quiet -- AGENTS.md README.md .github/copilot-instructions.md .vscode/settings.json; then
  echo "No role-repo sync changes detected for ${FULL_REPO} (${ROLE_SLUG})."
  exit 0
fi

git -C "$TARGET_DIR" checkout -B "$SYNC_BRANCH" >/dev/null

git -C "$TARGET_DIR" config user.name "context-engineering-sync[bot]"
git -C "$TARGET_DIR" config user.email "context-engineering-sync@users.noreply.github.com"

git -C "$TARGET_DIR" add AGENTS.md README.md .github/copilot-instructions.md .vscode/settings.json

if git -C "$TARGET_DIR" diff --cached --quiet; then
  echo "No staged changes after sync for ${FULL_REPO}."
  exit 0
fi

commit_message="Sync role job description artifacts for ${ROLE_SLUG} (${SOURCE_REF})"
git -C "$TARGET_DIR" commit -m "$commit_message" >/dev/null

if [ "$DRY_RUN" = "true" ]; then
  echo "Dry run enabled. Prepared sync commit for ${FULL_REPO} on branch ${SYNC_BRANCH}."
  git -C "$TARGET_DIR" --no-pager log --oneline -n 1
  git -C "$TARGET_DIR" --no-pager diff --stat "${BASE_BRANCH}...${SYNC_BRANCH}"
  exit 0
fi

git -C "$TARGET_DIR" push origin "$SYNC_BRANCH" --force-with-lease >/dev/null

if [ "$CREATE_PR" = "false" ]; then
  echo "Pushed sync branch without PR creation: ${FULL_REPO}:${SYNC_BRANCH}"
  exit 0
fi

PR_BODY_FILE="${WORK_DIR}/pr-body.md"
cat > "$PR_BODY_FILE" <<PRBODY
Primary-Role: Implementation Specialist
Reviewed-By-Role: Compliance Officer
Executive-Sponsor-Approval: Not-Required

## Summary
Automated sync of role-repo managed artifacts from Context-Engineering source `${SOURCE_REF}` for role `${ROLE_SLUG}`.

## Managed Files Updated
- \`AGENTS.md\`
- \`.github/copilot-instructions.md\`
- \`.vscode/settings.json\`
- \`README.md\`

Generated via:
- \`10-templates/repo-starters/role-repo-template/scripts/render-role-repo-template.sh\`
- \`10-templates/repo-starters/role-repo-template/scripts/build-agent-job-description.py\`
PRBODY

existing_pr="$(gh pr list --repo "$FULL_REPO" --state open --head "${OWNER}:${SYNC_BRANCH}" --json number -q '.[0].number')"

if [ -n "$existing_pr" ] && [ "$existing_pr" != "null" ]; then
  gh pr edit --repo "$FULL_REPO" "$existing_pr" --title "$PR_TITLE" --body-file "$PR_BODY_FILE" >/dev/null
  pr_number="$existing_pr"
else
  pr_url="$(gh pr create --repo "$FULL_REPO" --base "$BASE_BRANCH" --head "$SYNC_BRANCH" --title "$PR_TITLE" --body-file "$PR_BODY_FILE")"
  pr_number="$(printf '%s' "$pr_url" | awk -F'/' '{print $NF}')"
fi

# Best-effort labeling. If labels are missing in target repos, do not fail sync.
gh pr edit --repo "$FULL_REPO" "$pr_number" --add-label "role:implementation-specialist" --add-label "status:needs-review" >/dev/null 2>&1 || true

echo "Synced role repo and opened/updated PR: https://github.com/${FULL_REPO}/pull/${pr_number}"
