# Devcontainer Workstation Setup

This workflow builds the container from scratch outside VS Code, then attaches VS Code to the running container.
It supports role-scoped startup for:

- `agent-workstation` (default `Implementation Specialist` profile)
- `compliance-workstation` (`Compliance Officer` profile)

## 1) Build and start from host

Run these from your host machine terminal (not inside a container):

```bash
cd /path/to/Context-Engineering/.devcontainer-workstation

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  COMPOSE_CMD="docker-compose"
fi

# Optional: set this before startup when the workspace repo is private
# and you want non-interactive auth/auto-clone on first boot.

export GH_TOKEN="<your_pat>"

# Default role-scoped startup (Implementation Specialist)
$COMPOSE_CMD down
$COMPOSE_CMD up -d --build agent-workstation

# Optional: Compliance Officer role-scoped container
$COMPOSE_CMD --profile compliance-officer up -d --build compliance-workstation
```

If you exported `GH_TOKEN` for startup bootstrap, clear it after the container is running:

```bash
unset GH_TOKEN
```

Use this only if you want a full reset of persisted container data:

```bash
$COMPOSE_CMD down -v
$COMPOSE_CMD up -d --build
```

`down -v` removes all named volumes (including `gh_config`), so GitHub auth, cloned repos, and other persisted container state are reset.
Codex config is re-seeded from `.devcontainer-workstation/codex/config.toml` when `/root/.codex` is recreated.

Confirm container is running:

```bash
$COMPOSE_CMD ps
docker ps --filter name=agent-workstation
docker ps --filter name=compliance-workstation
```

If a role container is not `Up`, inspect logs:

```bash
$COMPOSE_CMD logs --tail=200 agent-workstation
$COMPOSE_CMD logs --tail=200 compliance-workstation
```

## 2) Create/clone repos in container-owned storage

The repo root inside the container is `/workspace/Projects` (Docker volume-backed).
On container startup, the entrypoint tries to clone:

- URL: `https://github.com/joshphillipssr/Context-Engineering.git`
- Path: `/workspace/Projects/Context-Engineering`

Verify clone status:

```bash
docker exec -it agent-workstation bash -lc 'ls -la /workspace/Projects/Context-Engineering'
```

If auto-clone failed, run manual PAT auth and clone inside the container:

```bash
docker exec -it agent-workstation bash

# One-time fallback auth inside container (HTTPS + PAT)
read -s -p "GitHub PAT: " GH_PAT; echo
printf '%s' "$GH_PAT" | env -u GH_TOKEN gh auth login --hostname github.com --git-protocol https --with-token
gh auth setup-git
gh auth status
unset GH_PAT

cd /workspace/Projects
git clone https://github.com/Josh-Phillips-LLC/Context-Engineering.git
exit
```

`gh` auth is persisted in the `gh_config` volume, so this login should not be required every time.

## 3) Attach VS Code to running container

In local (non-containerized) VS Code:

1. Open Command Palette
2. Run `Dev Containers: Attach to Running Container...`
3. Select `agent-workstation` or `compliance-workstation`
4. Open folder `/workspace/Projects/Context-Engineering`

## 4) Codex config defaults

The container seeds `/root/.codex/config.toml` from `.devcontainer-workstation/codex/config.toml` when the target file is missing.
Then `init-workstation.sh` applies role overlays from `.devcontainer-workstation/codex/role-profiles/` based on `ROLE_PROFILE`.
It also generates a runtime instruction file at `/workspace/Projects/Context-Engineering/.role.instructions.md` using centralized sources in `10-templates/agent-instructions/`.

## 5) Centralized role instructions (multi-agent)

Canonical role-based instruction sources live in:

- `10-templates/agent-instructions/base.md`
- `10-templates/agent-instructions/roles/implementation-specialist.md`
- `10-templates/agent-instructions/roles/compliance-officer.md`

These files are tool-agnostic and should be reused by non-Codex runtimes (for example, Copilot or Ollama adapters) rather than duplicating role logic in vendor-specific locations.

To update the default Codex settings for this workstation config:

1. Edit `.devcontainer-workstation/codex/config.toml` (base defaults) and/or `.devcontainer-workstation/codex/role-profiles/*.env` (role overlay values)
2. Rebuild/restart:

```bash
$COMPOSE_CMD up -d --build agent-workstation
```
