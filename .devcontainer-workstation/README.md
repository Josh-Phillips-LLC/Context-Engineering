# Devcontainer Workstation Setup

This workflow builds the container from scratch outside VS Code, then attaches VS Code to the running container.

## 1) Build and start from host

Run these from your host machine terminal (not inside a container):

```bash
cd /path/to/Context-Engineering/.devcontainer-workstation

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  COMPOSE_CMD="docker-compose"
fi

# Optional: set this only when your Docker runtime can bind-mount host
# sockets (for signed commits via SSH agent forwarding).
# export HOST_SSH_AGENT_SOCK="/Users/<you>/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

$COMPOSE_CMD down
$COMPOSE_CMD up -d --build
```

Use this only if you want a full reset of persisted container data:

```bash
$COMPOSE_CMD down -v
$COMPOSE_CMD up -d --build
```

`down -v` removes all named volumes (including `gh_config`), so GitHub auth, cloned repos, and other persisted container state are reset.

Confirm container is running:

```bash
$COMPOSE_CMD ps
docker ps --filter name=agent-workstation
```

If `agent-workstation` is not `Up`, inspect logs:

```bash
$COMPOSE_CMD logs --tail=200 agent-workstation
```

## 2) Create/clone repos in container-owned storage

The repo root inside the container is `/workspace/Projects` (Docker volume-backed).

```bash
docker exec -it agent-workstation bash

# One-time GitHub auth inside container (HTTPS + PAT)
read -s -p "GitHub PAT: " GH_PAT; echo
printf '%s' "$GH_PAT" | env -u GH_TOKEN gh auth login --hostname github.com --git-protocol https --with-token
gh auth setup-git
gh auth status
unset GH_PAT

cd /workspace/Projects
git clone https://github.com/joshphillipssr/Context-Engineering.git
exit
```

`gh` auth is persisted in the `gh_config` volume, so this PAT login should not be required every time.

## 3) Optional: verify SSH agent forwarding (for signed commits)

Run this only if you exported `HOST_SSH_AGENT_SOCK` before `up`:

```bash
docker exec -it agent-workstation bash -lc 'echo $SSH_AUTH_SOCK && ssh-add -l'
```

Expected: `SSH_AUTH_SOCK` is set and `ssh-add -l` lists identities.

## 4) Attach VS Code to running container

In local (non-containerized) VS Code:

1. Open Command Palette
2. Run `Dev Containers: Attach to Running Container...`
3. Select `agent-workstation`
4. Open folder `/workspace/Projects/Context-Engineering`

## 5) Set up SSH commit signing (runtime-compatible)

Use this approach when host SSH agent forwarding is unavailable.

Inside the attached container terminal:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
./.devcontainer-workstation/scripts/setup-ssh-signing.sh
```

The script prints your public signing key. Add it in GitHub:

1. Open GitHub Settings
2. Open `SSH and GPG keys`
3. Select `New SSH key`
4. Set key type to `Signing Key`
5. Paste the printed key

The private key persists across container recreates because `/root/.ssh` is volume-backed.

## 6) Optional signing test inside attached terminal

```bash
git commit -S --allow-empty -m "signing test"
git log --show-signature -1
```
