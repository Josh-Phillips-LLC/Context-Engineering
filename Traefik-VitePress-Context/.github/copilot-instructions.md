# Copilot Instructions — Context Engineering (Traefik Multi-Site Deployment)

## Architecture Overview

This workspace manages a production-grade **Traefik v3** reverse proxy system for hosting multiple containerized sites on a single Linux host. Three repos work together:

- **Traefik-Deployment**: Core infrastructure (Traefik setup, network management, site lifecycle scripts)
- **VitePress-Template**: Example VitePress site (template for new sites)
- **Context-Engineering**: AI session context document in Traefik-VitePress-Context subfolder (project requirements and state)

**Traffic flow**: `Client → Cloudflare → Traefik (Docker) → Site Containers (Docker)`

**Key design principles**: 
- Single host, one Traefik instance, many site containers sharing the `traefik_proxy` Docker network
- All services run in Docker containers except webhook listener (systemd service)
- Every site runs as a separate container managed by Traefik
- No secrets in repos—only in `~deploy/traefik.env`

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
CF_API_TOKEN=          # Cloudflare DNS-01 API token (Zone.DNS:Edit + Zone.Zone:Read only)
EMAIL=                 # ACME registration email (Let's Encrypt notifications)
USE_STAGING=false      # true for Let's Encrypt staging (testing/rate limit avoidance)
WH_SECRET=             # Webhook signature validation secret (must match GitHub webhook)
HOSTNAME=              # Primary Traefik hostname (e.g., traefik.example.com)
DEFAULT_SITE_REPO=     # Optional default site template repo URL
DEFAULT_SITE_TEMPLATE= # Optional template type identifier
```

All scripts must `source ~/traefik.env` or `/home/deploy/traefik.env` before using these variables.

**Security**: This file should have mode `0600` and be readable only by `deploy` user.

## Two-Phase Host Provisioning

**Phase 1 (host_prep_root.sh)**: Run as `root`
- Installs Docker Engine + Compose plugin
- Creates `deploy` user with restricted sudoers
- Creates `/opt/traefik` and `/opt/sites` owned by `deploy`
- Copies `traefik.env.sample` to `~deploy/traefik.env`
- Instructs operator to switch to `deploy` user

**Phase 2 (host_prep_deploy.sh)**: Run as `deploy`
- Sources `~deploy/traefik.env`
- Clones Traefik-Deployment repo into `/opt/traefik`
- Ensures permissions on `/opt/traefik` and `/opt/sites`
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

### System Architecture
- **Webhook listener**: systemd service (NOT containerized) running on host
- **Why systemd?**: Containers lack sudo access, don't have shells, and mounting docker.sock is a security risk
- **Service name**: `webhook.service` (managed by systemd)
- **Listening**: `127.0.0.1:9000` by default (proxied by Traefik)

### Flow
1. GitHub Actions builds Docker image → pushes to GHCR
2. Workflow sends `workflow_run` event to `https://hooks.<domain>/hooks/deploy-<site>`
3. Traefik proxies to systemd `webhook.service` on `127.0.0.1:9000`
4. Service validates signature using `$WH_SECRET` from `~deploy/traefik.env`
5. Calls `sudo -u deploy /opt/traefik/scripts/update_site.sh <SITE_NAME>`

### Provisioning
```bash
sudo /opt/traefik/scripts/hooks_provision.sh
```
Creates:
- `/opt/traefik/hooks/hooks.json` (hook definitions)
- `/etc/systemd/system/webhook.service`
- Sudoers rules at `/etc/sudoers.d/webhook-deploy`

### Validation Rules
Webhook only triggers on:
- Event type: `workflow_run` (ONLY—no other event types supported)
- Action: `completed`
- Conclusion: `success`
- Valid HMAC-SHA256 signature matching `$WH_SECRET`

## GitHub Actions CI/CD Pattern

### Required Workflow (`.github/workflows/build-and-push.yml`)

Site repositories MUST include a workflow that:

1. **Builds the site's Docker image**
   - Multi-stage build (builder + production image)
   - Example: Node.js build → Nginx serve

2. **Pushes to GitHub Container Registry (GHCR)**
   - Uses `ghcr.io/<owner>/<image>:latest` convention
   - Requires `packages: write` permission
   - Authenticates with `${{ secrets.GITHUB_TOKEN }}`

3. **Triggers webhook on completion**
   - GitHub automatically sends `workflow_run` event on success
   - Webhook endpoint: `https://hooks.<domain>/hooks/deploy-<site>`
   - Secret must match `$WH_SECRET` in `~deploy/traefik.env`

### Key Workflow Requirements

```yaml
name: Build and Push Docker Image
on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/site-name:latest
```

### Package Visibility
After first push, set GHCR package to **Public** in GitHub → Settings → Packages for unauthenticated pulls.

### Deployment Flow
1. Push to `main` → Workflow builds image → Pushes to GHCR
2. GitHub sends `workflow_run` event → Webhook validates → Calls `update_site.sh`
3. `update_site.sh` pulls new image → Recreates container with `docker compose up -d`

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

## Site Template Pattern (joshphillipssr.com → VitePress Template)

**Current state**: The `joshphillipssr.com` repository is now renamed 'VitePress-Template' so that it is  **generic VitePress template**.

**Design principle**: Template is completely generic—NOT tied to any specific domain or hostname.

### Creating New Sites from Template

1. Clone/fork the template repository
2. Customize VitePress content:
   - Markdown pages in `docs/`
   - Theme settings in `.vitepress/config.js`
   - Navigation structure
3. Add GitHub Actions workflow (`.github/workflows/build-and-push.yml`)
4. Configure GHCR package visibility (Public)
5. Push to trigger build → GHCR image
6. Bootstrap + deploy on host using environment variables

### Critical Rules for Templates

- **Never hardcode hostnames** in template code or configs
- **Pass domains via `SITE_HOSTS` env var** at deployment time
- **All site-specific config** comes from environment variables or deployment parameters
- **Docker image must be generic** and configurable at runtime

### Example Multi-Site Usage

Same template can serve multiple domains:
```bash
# Site 1
SITE_NAME="docs" SITE_HOSTS="docs.example.com" SITE_IMAGE="ghcr.io/user/vitepress:latest"

# Site 2  
SITE_NAME="blog" SITE_HOSTS="blog.example.com www.blog.example.com" SITE_IMAGE="ghcr.io/user/vitepress:latest"
```

## What This System Does NOT Manage

- **DNS record creation**: A/AAAA/CNAME records must be created manually in Cloudflare
- **Database provisioning**: No stateful service orchestration
- **Docker image building**: That's the responsibility of site repo's GitHub Actions
- **Non-Traefik containers**: Only manages site containers and Traefik itself
- **Multi-host orchestration**: Intentionally a minimal, single-host design (not Kubernetes)

This scope ensures the project stays clear, maintainable, and focused.

## Common Pitfalls

1. **Missing traefik.env**: All scripts fail. Ensure it exists at `~deploy/traefik.env` with required vars.
2. **Wrong script execution order**: Must run `host_prep_root.sh` (as root) before `host_prep_deploy.sh` (as deploy).
3. **Network not created**: `traefik_proxy` must exist before deploying sites. Created by `create_network.sh` in host_prep_deploy.sh.
4. **Cloudflare SSL mode**: Must be set to **Full (strict)**, not Flexible.
5. **Webhook secret mismatch**: `$WH_SECRET` in traefik.env must match GitHub webhook secret exactly.
6. **Docker socket permissions**: User must be in `docker` group or use sudo.
7. **Wrong event type**: Webhooks ONLY support `workflow_run` events, not `push` or `release`.
8. **Package visibility**: GHCR packages default to private—must be set to Public for unauthenticated pulls.
9. **Hardcoded hostnames**: Site templates must never contain hardcoded domains—use env vars.
10. **Running host_prep2.sh as root**: Must run as `deploy` user after switching from root.

## AI Agent Guidelines

- When editing scripts, preserve the `set -euo pipefail`, path resolution, and env sourcing patterns.
- Never suggest embedding secrets—always use `~deploy/traefik.env`.
- Respect the two-phase (root/deploy) privilege separation—root does initial prep, deploy does install and operations.
- Generate Traefik labels following the exact pattern in `deploy_to_host.sh`.
- For webhook changes, validate against `hooks.json` schema and systemd service requirements.
- When troubleshooting, check logs: `journalctl -u webhook -f` or `docker compose logs`.
- Reference the authoritative **Traefik-Project-Context.md** for epic/story understanding.
- All documentation and scripts must align with patterns in Traefik-Project-Context.md.
- Test following Quick-Start.md workflows in both Traefik-Deployment and site repos.
