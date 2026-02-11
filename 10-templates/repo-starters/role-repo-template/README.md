# Role Repo Template (Proposed)

This starter defines a reusable template for generating public, role-specific repositories from repository-governed role definitions.

It is intended for the role-repo migration program and is not yet ratified governance policy.

## Purpose

- Provide a single scaffold source for role repositories.
- Keep role-repo instruction files deterministic and regenerable.
- Avoid hand-edit drift across role repos.

## Output Shape

The renderer writes this minimum file set to a target role repo:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.vscode/settings.json`
- `README.md`

Instruction model:

- `AGENTS.md` is the canonical compiled role instruction set.
- `.github/copilot-instructions.md` is a lightweight adapter that points to `AGENTS.md`.

## Source Inputs

Role `AGENTS.md` job descriptions are assembled from structured spec inputs:

- `10-templates/job-description-spec/global.json`
- `10-templates/job-description-spec/roles/<role-slug>.json`

Canonical governance artifacts are also required as source-of-truth anchors:

- `governance.md`
- `00-os/role-charters/<role-slug>.md`
- `10-templates/agent-instructions/base.md`
- `10-templates/agent-instructions/roles/<role-slug>.md`

For `compliance-officer`, required protocol includes are embedded from:

- `10-templates/compliance-officer-pr-review-brief.md`

## Builder

Script:

- `scripts/build-agent-job-description.py`

This script merges global + role spec, validates required contract sections, and emits deterministic `AGENTS.md` job description content.

## Renderer

Script:

- `scripts/render-role-repo-template.sh`

This script calls the builder and renders final repository files from templates.

Required args:

- `--role-slug`
- `--repo-name`
- `--output-dir`

Optional args:

- `--role-name`
- `--source-ref` (defaults to current `git rev-parse --short HEAD`)
- `--force` (allow writing into non-empty output directories)

## Example

```bash
10-templates/repo-starters/role-repo-template/scripts/render-role-repo-template.sh \
  --role-slug implementation-specialist \
  --repo-name context-engineering-role-implementation-specialist \
  --output-dir /tmp/context-engineering-role-implementation-specialist
```

## Public Repo Creation Workflow

Script:

- `scripts/create-public-role-repo.sh`

This script composes the renderer and creates a **public** GitHub repository with an initial commit and push.

Required args:

- `--role-slug`
- `--owner` (organization or user)

Optional args:

- `--repo-name` (defaults to `context-engineering-role-<role-slug>`)
- `--role-name`
- `--description`
- `--output-dir`
- `--source-ref`
- `--force`
- `--dry-run`

Example:

```bash
10-templates/repo-starters/role-repo-template/scripts/create-public-role-repo.sh \
  --role-slug implementation-specialist \
  --owner Josh-Phillips-LLC
```

Dry-run example:

```bash
10-templates/repo-starters/role-repo-template/scripts/create-public-role-repo.sh \
  --role-slug compliance-officer \
  --owner Josh-Phillips-LLC \
  --dry-run
```

## Role Repo Sync Workflow

Script:

- `scripts/sync-role-repo.sh`

This script syncs managed role-repo artifacts from Context-Engineering source into an existing public role repository and opens or updates a sync PR.

Required args:

- `--role-slug`
- `--owner`

Optional args:

- `--repo-name` (defaults to `context-engineering-role-<role-slug>`)
- `--role-name`
- `--base-branch` (defaults to `main`)
- `--source-ref`
- `--sync-branch` (defaults to `sync/role-repo/<role-slug>`)
- `--pr-title`
- `--work-dir`
- `--no-pr`
- `--dry-run`

Example:

```bash
10-templates/repo-starters/role-repo-template/scripts/sync-role-repo.sh \
  --role-slug implementation-specialist \
  --owner Josh-Phillips-LLC
```

Dry-run example:

```bash
10-templates/repo-starters/role-repo-template/scripts/sync-role-repo.sh \
  --role-slug compliance-officer \
  --owner Josh-Phillips-LLC \
  --dry-run
```

## GitHub Actions Sync Automation

Workflow:

- `.github/workflows/sync-role-repos.yml`

Behavior:

- Runs on `main` pushes that touch role instruction source inputs.
- Supports manual runs via `workflow_dispatch`.
- Syncs matrix roles:
  - `implementation-specialist`
  - `compliance-officer`

Required secret:

- `ROLE_REPO_SYNC_TOKEN`

`ROLE_REPO_SYNC_TOKEN` should be a token with access to target role repositories and permissions to push branches and open/edit pull requests.

Optional variable:

- `ROLE_REPO_OWNER`

If `ROLE_REPO_OWNER` is unset, workflow defaults to `github.repository_owner`.
