# Project Summary for Initial AI Session Context Window

You are ChatGPT assisting with a complex DevOps-oriented project involving **Traefik**, **Docker**, **Cloudflare**, **GitHub Actions**, **webhooks**, and **automated container deployment**.

This document serves to create AI Session Context and provide the epic and stories for the project. It will not be made available as documentation for the project.

Below is the complete state of the project and all requirements as of now:

---

## 🏗 High-Level Architecture

We are implementing a reusable, production-grade deployment model:

Client → Cloudflare → Traefik → Site Containers (Docker)

Everything runs on a single Linux host.  
All services run in Docker containers except the webhook listener (systemd service).  
Every site runs as a **separate container** managed by Traefik.

---

## 📂 Repository Structure (Two Repos)

### **1. Traefik-Deployment Repository**

Purpose: install & manage Traefik + helper scripts + automation.

**Repository**: <https://github.com/joshphillipssr/Traefik-Deployment>

Cloned into `/opt/traefik`.  
Scripts live at `/opt/traefik/scripts`:

- host_prep1.sh
- host_prep2.sh
- create_network.sh
- traefik_up.sh
- deploy_site.sh
- update_site.sh
- remove_site.sh
- hooks_provision.sh
- cleanup.sh

### **2. joshphillipssr.com Repository**

Purpose: the actual site (VitePress), its Dockerfile, GitHub actions, and its own scripts:

- `.github/workflows/build-and-push.yml` → builds/pushes Docker image to GHCR
- `/scripts/deploy_to_host.sh`
- `/scripts/bootstrap_site_on_host.sh`
- `/scripts/cleanup.sh`
- Dockerfile
- All VitePress content

Future plan is to make this competely generic (change repo name from joshphillipssr.com to VitaPress Template). This is a public repo template on GitHub, so the name change will reflect the function.

---

## 📁 Host Folder Structure (Authoritative Layout)

```text
/opt/
  traefik/
    scripts/
      host_prep1.sh
      host_prep2.sh
      create_network.sh
      traefik_up.sh
      deploy_site.sh
      update_site.sh
      remove_site.sh
      hooks_provision.sh
      cleanup.sh
    docker-compose.yml              # Traefik static configuration
    hooks/
      hooks.json                    # Webhook config
    volumes/
      acme/                         # Docker volume storing ACME certificates

  sites/
    <SITE_NAME>/
      docker-compose.yml            # Generated per-site compose file
      data/                         # persistent content
      logs/                         # Site-level logs
      scripts/
         bootstrap_site_on_host.sh
         cleanup.sh
         deploy_to_host.sh
         update_site.sh
      docs/                         # VitePress home
      docker-compose.yml
      package.json
      yarn.lock 
```

This folder layout defines the authoritative structure the rest of the system expects.

---

## 🔐 Environment Variables Handling

All environment variables live **ONLY** in:

```text
~deploy/traefik.env
```

This file contains (this list is ever growing as env variables are moved from the scripts to traefik.env):

```text
CF_API_TOKEN=your_cloudflare_api_token
EMAIL=you@example.com
USE_STAGING=false
WH_SECRET=ChangeThisSecretNow
```

The environment file is also used to define host-specific configuration such as local hostname and any future site-independent settings.

Every script sources `~deploy/traefik.env`.

If the file is missing or incomplete, scripts **should fail with helpful error messages**.

---

## 📜 Required Environment Variables

These **must** exist in `~deploy/traefik.env`:

```text
CF_API_TOKEN=your_cloudflare_api_token     # Cloudflare API token for DNS-01
EMAIL=you@example.com                      # Email for ACME registration
USE_STAGING=false                          # true = Let’s Encrypt staging (testing)
WH_SECRET=ChangeThisSecretNow              # Webhook signature validation secret
```

### Host-specific Environment Variables

```text
HOSTNAME=<your-hostname>
DEFAULT_SITE_REPO=<URL-of-your-site-template>
DEFAULT_SITE_TEMPLATE=<template-type-or-path>
```

Additional variables may be added over time, but all configuration MUST live inside this file—not in scripts or compose files.

---

## 🧰 Host Prep Flow (Two Scripts)

### **host_prep1.sh** (run as root)

- installs Docker Engine + Compose
- creates deploy user + sudoers restrictions
- creates /opt/treafik and /opt/sites
- gives deploy user full rights to /opt/treafik and /opt/sites
- copies traefik.env.sample from online GitHub repo to ~deploy/traefik.env
- instructs operator to switch to deploy

### **host_prep2.sh** (run as deploy)

- sources ~/traefik.env
- clones Traefik-Deployment repo into /opt/traefik
- ensures permission layout
- runs create_network.sh
- runs traefik_up.sh
- completes Traefik provisioning

This two-step split ensures:

- root does only what root must do
- deploy does everything else

---

## 🌐 Traefik Behavior

Traefik listens on:

- host port **80** → container entrypoint `web` on :8080 (optional HTTP, typically only used for redirects to HTTPS)
- host port **443** → container entrypoint `websecure` on :8443 (primary HTTPS entrypoint)

ACME DNS-01 validations through Cloudflare happen automatically.

Traefik inspects the incoming `Host` header and routes to the correct site container attached to the shared Docker network. All site containers listen on port 80; per-site labels tell Traefik which internal port to use:

```text
traefik.http.routers.<site>.rule=Host(`domain.com`) || Host(`www.domain.com`)
traefik.http.routers.<site>.tls=true
traefik.http.routers.<site>.tls.certresolver=cf
traefik.http.services.<site>.loadbalancer.server.port=80
```

These labels are generated automatically by **/opt/traefik/deploy_site.sh**.

---

## 🛠 Traefik Static Configuration Overview

Traefik is configured using the `docker-compose.yml` stored in `/opt/traefik/`.

Key characteristics:

- **Traefik v3** is used.
- All configuration is done through:
  - Docker labels (dynamic routing)
  - Environment variables loaded from `~deploy/traefik.env`
  - A static configuration block inside `docker-compose.yml`.
- ACME TLS certificates are stored inside the Docker volume:

  ```text
  traefik_acme
  ```

- No plaintext secrets appear in the compose file; all secrets come from environment variables.
- Traefik exposes:
  - port **8080** internally (mapped to host port **80**)
  - port **8443** internally (mapped to host port **443**)
- Enable Treafik dashboard using secure hostname-based routing and basic authentication.

This standardizes Traefik across all deployments and keeps configuration centralized.

### 🔐 Traefik Dashboard

This project uses a simple pattern:

- Reuse the existing `websecure` entrypoint on port **443**
- Route a dedicated hostname (for example, `traefik.example.com`) to the internal service `api@internal`
- Protect access with a basic-auth middleware

Example labels on the Traefik container:

```yaml
labels:
  - "traefik.http.routers.traefik-dashboard.rule=Host(`traefik.example.com`)"
  - "traefik.http.routers.traefik-dashboard.entrypoints=websecure"
  - "traefik.http.routers.traefik-dashboard.tls.certresolver=cf"
  - "traefik.http.routers.traefik-dashboard.service=api@internal"
  - "traefik.http.routers.traefik-dashboard.middlewares=dashboard-auth"
  - "traefik.http.middlewares.dashboard-auth.basicauth.users=admin:$$2y$$10$$REPLACE_WITH_YOUR_BCRYPT_HASH"
```

Generate the bcrypt hash on the host using:

```bash
htpasswd -nbB admin 'SuperSecretPassword'
```

The resulting string (starting with `admin:$2y$...`) is inserted into the `basicauth.users` value. Be sure to escape `$` characters as `$$` inside YAML labels.

In this pattern, the dashboard is only reachable via:

```text
https://traefik.example.com
```

---

## 🚀 Deploying a Site (Manual Flow)

**Repository**: <https://github.com/joshphillipssr/VitePress-Template>

### bootstrap_site_on_host.sh (run as deploy — requires limited sudo privileges granted during host_prep1.sh)

- Clones the site repo into `/opt/sites/<your-site>` using deploy’s allowed sudo actions
- Ensures folder structure and permissions under /opt/sites are correct (via deploy’s restricted sudo rights)

### deploy_to_host.sh (run as deploy — requires limited sudo privileges granted during host_prep1.sh)

Responsible for (all performed by deploy using its restricted sudoers permissions):

- Generating the correct docker-compose.yml for the site
- Attaching it to traefik_proxy
- Setting Traefik labels
- Starting the site container

The generated compose file is stored at:

```text
/opt/sites/<SITE_NAME>/docker-compose.yml
```

These operations require no direct root login; deploy has all necessary narrowly scoped sudo permissions.

Example environment variables:

```bash
SITE_NAME="<your-site>"
SITE_HOSTS="example.com www.example.com"
SITE_IMAGE="ghcr.io/youruser/yourimage:latest"
```

This project no longer embeds site‑specific assumptions. joshphillipssr.com is simply an example VitePress site and the template is intended to work for any number of similar containerized sites.

---

## 🧩 Site Template Workflow (Generic)

The site repository is intended to function as a **fully generic VitePress template**, not tied to any specific domain or hostname.

Workflow to create a new site:

1. **Clone the Site Template Repo**

   ```text
   git clone <site-template-repo-url> my-new-site
   ```

2. **Customize VitePress content**
   - Add Markdown pages
   - Adjust theme settings
   - Update navigation

3. **Push to GitHub**
   - Repository must include a GitHub Actions workflow that builds and pushes a Docker image to GHCR.

4. **Wait for GitHub Actions build**
   - Once the image is built and pushed, the Traefik webhook will automatically deploy it to your Traefik host.

5. **Use deploy_to_host.sh on first deploy**
   - Required only once per new site.

After the first deployment, all future updates occur automatically via webhook-triggered redeployments.

---

## 🔄 Updating a Site Manually

```bash
sudo /opt/traefik/update_site.sh <SITE_NAME>
```

- Pulls latest GHCR image
- Restarts container cleanly

---

## 🔔 Automatic Deployments (webhooks)

We chose a **systemd-based webhook**, not a container-based one, because:

- containers typically lack sudo access
- webhook containers don’t have shells
- mounting docker.sock inside automation containers is a security risk
- systemd is stable, secure, and simplest

### Webhook Flow

1. GitHub Action finishes building Docker image
2. GitHub sends a **workflow_run** event to:

   ```text
   https://hooks.<your-domain>/hooks/deploy-<site>
   ```

3. A systemd service (`webhook.service`) receives the event
4. Signature is validated using `$WH_SECRET`
5. The webhook calls:

   ```bash
   sudo -u deploy /opt/traefik/update_site.sh <SITE_NAME>
   ```

The webhook is the ONLY supported automation path; SSH-based automation is deprecated/removed.

Everything is tied together through:

- `/opt/traefik/hooks/hooks.json`
- `/etc/systemd/system/webhook.service`
- `/etc/sudoers.d/webhook-deploy`

---

## 🧬 CI/CD Requirements

Site repositories must include:

- A GitHub Actions workflow that:
  - Builds the site’s Docker image
  - Pushes it to GitHub Container Registry (GHCR)
- Permissions:
  - `GITHUB_TOKEN` must have the `packages: write` scope
- GitHub must send **workflow_run** events to the Traefik webhook endpoint:

  ```text
  https://hooks.<your-domain>/hooks/deploy-<site>
  ```

The webhook supports ONLY **workflow_run**; other event types must not be used.

---

## 🚫 What Traefik-Deployment Does NOT Manage

To avoid incorrect assumptions:

- It does **not** create DNS records in Cloudflare  
  (A/AAAA/CNAME records must be created manually)
- It does **not** manage databases or stateful services
- It does **not** build Docker images for sites  
  (That is the responsibility of the site repo’s GitHub Actions pipeline)
- It does **not** orchestrate non-Traefik containers  
  (Only site containers and Traefik itself)
- It is **not** a Kubernetes replacement  
  (This is intentionally a minimal, single-host design)

This ensures the project scope stays clear and maintainable.

---

## 🧹 Cleanup Scripts

### Traefik cleanup.sh

- Stops webhook service
- Removes webhook user
- Removes /opt/traefik
- Removes traefik_proxy network
- Kills containers using traefik_proxy
- Cleans up systemd files

### Site cleanup.sh

- Removes /opt/sites/<SITE_NAME>
- Stops and removes container <SITE_NAME>
- Does NOT touch traefik or webhook

The two scripts combined perform a full nuclear wipe.

---

## 🪜 Current Development Tasks Outstanding

1. **Finalize host_prep1.sh and host_prep2.sh** (include new env strategy)  
2. **Ensure all scripts source `~deploy/traefik.env`**  
3. **Rewrite hooks_provision.sh** to use the new env file exclusively  
4. **Update both READMEs** to reflect:
   - two-step host prep
   - new env handling
   - new folder structure  
5. **Retest the entire environment from scratch**  
6. **Consider additional site-specific environment variable structuring**  
7. **Ensure all sudoers rules are minimal and correct**

---

## 🧠 What ChatGPT Should Do Next

After receiving this summary in a new chat session, ChatGPT should:

- Re-load context from this entire summary
- Help refine and edit scripts via `oboe.edit_file`
- Ensure host prep flow is correct
- Help correct README.md with precise instructions
- Help validate webhook behavior
- Help test everything systematically
- Ensure minimal-privilege security is maintained

---

## Future Repo Renaming

The joshphillipssr.com repository is evolving into a generic VitePress site template.  
No documentation or scripts should depend on its name or hostname. All site‑specific  
configuration (e.g., local hostnames) belongs only in environment variables or per‑site  
deployment parameters.
