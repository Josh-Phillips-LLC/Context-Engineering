# Copilot Instructions — Context Engineering (Traefik Multi-Site Deployment)

## Architecture Overview

This workspace manages a production-grade **Traefik v3** reverse proxy system for hosting multiple containerized sites on a single Linux host. Three repos work together:

- **Traefik-Deployment**: Core infrastructure (Traefik setup, network management, site lifecycle scripts)
- **joshphillipssr.com**: Example VitePress site (template for new sites)
- **Traefik-VitePress Context**: AI session context document (project requirements and state)

**Traffic flow**: `Client → Cloudflare → Traefik (Docker) → Site Containers (Docker)`

**Key design principle**: Single host, one Traefik instance, many site containers sharing the `traefik_proxy` Docker network.

## Critical Folder Structure (On Deploy Host)

```
/opt/
  traefik/
    docker/docker-compose.yml    # Traefik static config
    scripts/                     # All lifecycle scripts
    hooks/hooks.json            # Webhook definitions
  sites/
    <SITE_NAME>/
      docker-compose.yml        # Generated per-site
      scripts/                  # Site-specific scripts
```

`~deploy/traefik.env` is the **single source of truth** for all configuration. Never embed secrets in scripts or compose files.

## Required Environment Variables (traefik.env)

```bash
CF_API_TOKEN=          # Cloudflare DNS-01 API token
EMAIL=                 # ACME registration email
USE_STAGING=false      # true for Let's Encrypt staging
WH_SECRET=             # Webhook signature validation
HOSTNAME=              # Primary Traefik hostname
DEFAULT_SITE_REPO=     # Optional site template repo
```

All scripts must `source ~/traefik.env` or `/home/deploy/traefik.env` before using these variables.

## Two-Phase Host Provisioning

**Phase 1 (host_prep_root.sh)**: Run as `root`
- Installs Docker Engine + Compose plugin
- Creates `deploy` user with restricted sudoers
- Creates `/opt/traefik` and `/opt/sites` owned by `deploy`
- Copies `traefik.env.sample` to `~deploy/traefik.env`

**Phase 2 (host_prep_deploy.sh)**: Run as `deploy`
- Sources `~deploy/traefik.env`
- Clones Traefik-Deployment into `/opt/traefik`
- Creates `traefik_proxy` network via `create_network.sh`
- Starts Traefik via `traefik_up.sh`

This split ensures root does only privileged setup, `deploy` handles operations.

## Script Patterns & Conventions

### Path Resolution
All scripts use `SCRIPT_DIR` to resolve paths relative to their location:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
```

### Environment Sourcing
```bash
ENV_FILE="${TRAEFIK_ENV_FILE:-/home/deploy/traefik.env}"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
fi
```

### Sudo Re-exec Pattern
Scripts that need root automatically re-exec with sudo:
```bash
need_root() {
  if [[ $EUID -ne 0 ]]; then
    exec sudo --preserve-env=VAR1,VAR2 "${BASH_SOURCE[0]}" "$@"
  fi
}
```

### Error Handling
Always use `set -euo pipefail` at script top. Validate required vars:
```bash
: "${SITE_NAME:?SITE_NAME required}"
```

## Site Deployment Workflow

1. **Bootstrap** (once per site, as sudo-capable user):
   ```bash
   sudo SITE_REPO="..." SITE_DIR="/opt/<site>" bootstrap_site_on_host.sh
   ```
   Clones site repo, sets permissions. Does NOT deploy container.

2. **Deploy** (first deployment, as sudo-capable user):
   ```bash
   sudo SITE_NAME="..." SITE_HOSTS="..." SITE_IMAGE="..." deploy_to_host.sh
   ```
   Generates `docker-compose.yml` with Traefik labels, starts container.

3. **Update** (subsequent deploys, automated or manual):
   ```bash
   sudo -u deploy /opt/traefik/scripts/update_site.sh <SITE_NAME>
   ```
   Pulls latest image, recreates container.

## Traefik Configuration

### Port Mapping
- Traefik listens on container ports **8080** (HTTP) and **8443** (HTTPS)
- Published to host as **80** and **443**
- Site containers listen on port **80** internally

### Dynamic Routing via Labels
Generated in `deploy_to_host.sh`:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<site>.entrypoints=websecure"
  - "traefik.http.routers.<site>.tls=true"
  - "traefik.http.routers.<site>.tls.certresolver=cf"
  - "traefik.http.routers.<site>.rule=Host(`example.com`) || Host(`www.example.com`)"
  - "traefik.http.services.<site>.loadbalancer.server.port=80"
```

### Certificate Storage
ACME certificates stored in Docker volume `traefik_acme`. Never needs manual management.

## Webhook Automation

### Flow
1. GitHub Actions builds Docker image → pushes to GHCR
2. GitHub sends `workflow_run` event to `https://hooks.<domain>/hooks/deploy-<site>`
3. Systemd service (`traefik-webhook.service`) validates signature using `WH_SECRET`
4. Calls `sudo -u deploy /opt/traefik/scripts/update_site.sh <SITE_NAME>`

### Provisioning
```bash
sudo /opt/traefik/scripts/hooks_provision.sh
```
Creates:
- `/opt/traefik/hooks/hooks.json` (hook definitions)
- `/etc/systemd/system/traefik-webhook.service`
- Sudoers rules for webhook→deploy interactions

### Validation Rules
Webhook only triggers on:
- Event type: `workflow_run`
- Action: `completed`
- Conclusion: `success`
- Valid HMAC signature matching `WH_SECRET`

## Common Operations

### Viewing Traefik logs
```bash
cd /opt/traefik/docker
docker compose logs -f
```

### Manually updating a site
```bash
sudo SITE_NAME="jpsr" /opt/traefik/scripts/update_site.sh
```

### Removing a site
```bash
sudo SITE_NAME="jpsr" /opt/traefik/scripts/remove_site.sh
```

### Nuclear cleanup (removes everything)
```bash
sudo /opt/traefik/scripts/cleanup.sh  # Traefik + webhook
sudo /opt/sites/<site>/scripts/cleanup.sh  # Per-site
```

## Security Model

- **Docker daemon**: Runs as root (standard)
- **Deploy user**: Member of `docker` group, limited sudo via `/etc/sudoers.d/`
- **Traefik container**: Runs as UID 65532 (non-root), read-only filesystem with tmpfs
- **Cloudflare API token**: Minimal scope (Zone.DNS:Edit, Zone.Zone:Read only)
- **Secrets**: Never in repos—only in `~deploy/traefik.env` (mode 0600)

## Site Template Pattern (joshphillipssr.com)

This is a **generic VitePress template**, not tied to specific domain. To create new sites:

1. Clone template repo
2. Customize VitePress content (Markdown, theme)
3. Add GitHub Actions workflow (`.github/workflows/build-and-push.yml`)
4. Push to trigger build → GHCR image
5. Bootstrap + deploy on host

**Never hardcode site-specific hostnames in template**. Pass via `SITE_HOSTS` env var.

## What This System Does NOT Manage

- Cloudflare DNS record creation (manual A/AAAA setup required)
- Database provisioning or stateful services
- Docker image building (handled by site's GitHub Actions)
- Multi-host orchestration (intentionally single-host design)

## Common Pitfalls

1. **Missing traefik.env**: All scripts fail. Ensure it exists with required vars.
2. **Wrong script execution order**: Must run `host_prep_root.sh` before `host_prep_deploy.sh`.
3. **Network not created**: `traefik_proxy` must exist before deploying sites. Created by `create_network.sh`.
4. **Cloudflare SSL mode**: Must be set to **Full (strict)**, not Flexible.
5. **Webhook secret mismatch**: `WH_SECRET` in traefik.env must match GitHub webhook secret exactly.
6. **Docker socket permissions**: User must be in `docker` group or use sudo.

## AI Agent Guidelines

- When editing scripts, preserve the `set -euo pipefail`, path resolution, and env sourcing patterns.
- Never suggest embedding secrets—always use `~deploy/traefik.env`.
- Respect the two-phase (root/deploy) privilege separation.
- Generate Traefik labels following the exact pattern in `deploy_to_host.sh`.
- For webhook changes, validate against `hooks.json` schema and systemd service requirements.
- When troubleshooting, check logs: `journalctl -u traefik-webhook -f` or `docker compose logs`.
