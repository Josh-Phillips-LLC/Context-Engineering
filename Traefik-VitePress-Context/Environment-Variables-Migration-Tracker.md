# Environment Variables Migration Tracker

**Purpose:** Track the migration of hardcoded configuration values to environment variables across both repositories (Traefik-Deployment and VitePress-Template).

**Goal:** Ensure that both repositories can be cloned and used without editing scripts or configuration files. All site-specific and host-specific configuration should be provided via environment variables.

---

## Migration Principles

1. **Host-level configuration** → `~deploy/traefik.env`
   - Configuration that applies to the entire Traefik host
   - Must be set once during host provisioning
   - Examples: Cloudflare token, email, webhook secret, primary hostname

2. **Site-level configuration** → Environment variables passed to deployment scripts
   - Configuration specific to each site being deployed
   - Passed as arguments or environment variables during site deployment
   - Examples: site name, hostnames, Docker image URL

3. **No hardcoded values** → All scripts must be generic
   - Scripts should work for any deployment without modification
   - All site-specific or host-specific data must come from env vars or script arguments
   - Legacy references (e.g., "joshphillipssr.com", specific domains) must be removed

---

## Required Environment Variables

### Host-Level (in ~deploy/traefik.env)

| Variable | Purpose | Status | Notes |
|----------|---------|--------|-------|
| `CF_API_TOKEN` | Cloudflare API token for DNS-01 ACME validation | ✅ Documented | Must have Zone.DNS:Edit + Zone.Zone:Read permissions |
| `EMAIL` | ACME registration email for Let's Encrypt | ✅ Documented | Used for certificate expiration notifications |
| `USE_STAGING` | Whether to use Let's Encrypt staging environment | ✅ Documented | Set to `true` for testing, `false` for production |
| `WH_SECRET` | Webhook signature validation secret | ✅ Documented | Must match secret configured in GitHub webhook |
| `HOSTNAME` | Primary Traefik hostname (e.g., traefik.example.com) | ✅ Documented | Used for Traefik dashboard access |
| `DEFAULT_SITE_REPO` | Optional default site template repository URL | ✅ Documented | Used if no repo specified during site bootstrap |
| `DEFAULT_SITE_TEMPLATE` | Optional default template type identifier | ✅ Documented | Future use for multiple template types |

### Site-Level (passed during deployment)

| Variable | Purpose | Status | Notes |
|----------|---------|--------|-------|
| `SITE_NAME` | Unique identifier for the site container | ✅ Documented | Used as container name and in paths |
| `SITE_HOSTS` | Space-separated list of hostnames | ✅ Documented | Example: "example.com www.example.com" |
| `SITE_IMAGE` | Full Docker image URL | ✅ Documented | Example: "ghcr.io/user/site:latest" |
| `SITE_REPO` | Git repository URL for site content | ✅ Documented | Used during bootstrap |
| `SITE_DIR` | Target directory for site files | ✅ Documented | Default: /opt/sites/<SITE_NAME> |

---

## Scripts Review Status

### Traefik-Deployment Repository Scripts

| Script | Review Status | Hardcoded Values Found | Migration Status | Notes |
|--------|--------------|------------------------|------------------|-------|
| `host_prep1.sh` (or `host_prep_root.sh`) | ⏳ Pending | TBD | ⏳ Pending | Needs review for hardcoded paths/values |
| `host_prep2.sh` (or `host_prep_deploy.sh`) | ⏳ Pending | TBD | ⏳ Pending | Needs review for hardcoded paths/values |
| `create_network.sh` | ⏳ Pending | TBD | ⏳ Pending | Network name should be verified |
| `traefik_up.sh` | ⏳ Pending | TBD | ⏳ Pending | Check for hardcoded compose file paths |
| `deploy_site.sh` | ⏳ Pending | TBD | ⏳ Pending | Critical: verify all site config from env vars |
| `update_site.sh` | ⏳ Pending | TBD | ⏳ Pending | Should only need SITE_NAME as input |
| `remove_site.sh` | ⏳ Pending | TBD | ⏳ Pending | Should only need SITE_NAME as input |
| `hooks_provision.sh` | ⏳ Pending | TBD | ⏳ Pending | Must source traefik.env for WH_SECRET |
| `cleanup.sh` | ⏳ Pending | TBD | ⏳ Pending | Should work generically |

### VitePress-Template Repository Scripts

| Script | Review Status | Hardcoded Values Found | Migration Status | Notes |
|--------|--------------|------------------------|------------------|-------|
| `bootstrap_site_on_host.sh` | ⏳ Pending | TBD | ⏳ Pending | Check for hardcoded site names/domains |
| `deploy_to_host.sh` | ⏳ Pending | TBD | ⏳ Pending | Critical: ensure no hardcoded hostnames |
| `cleanup.sh` | ⏳ Pending | TBD | ⏳ Pending | Should use SITE_NAME from env |

### Configuration Files

| File | Review Status | Hardcoded Values Found | Migration Status | Notes |
|------|--------------|------------------------|------------------|-------|
| `docker-compose.yml` (Traefik) | ⏳ Pending | TBD | ⏳ Pending | Should reference env vars only |
| `docker-compose.yml` (Site template) | ⏳ Pending | TBD | ⏳ Pending | Generated files should be generic |
| `hooks.json` | ⏳ Pending | TBD | ⏳ Pending | Should be generated from env vars |
| `.github/workflows/build-and-push.yml` | ⏳ Pending | TBD | ⏳ Pending | Check for hardcoded image names |

---

## Known Legacy References to Remove

### Repository Names
- ❌ References to "joshphillipssr.com" as repo name
  - **Status:** ✅ Updated in documentation (Traefik-Project-Context.md)
  - **Action Required:** Verify scripts don't reference old repo name
  
### Hostnames
- ❌ Any hardcoded domain names in scripts or configs
  - **Status:** ⏳ Pending script review
  - **Action Required:** Audit all scripts for domain names

### Paths
- ❌ Any paths not based on `/opt/traefik` or `/opt/sites/<SITE_NAME>`
  - **Status:** ⏳ Pending verification
  - **Action Required:** Ensure all scripts use standard path structure

---

## Testing Checklist

To verify environment variable migration is complete:

- [ ] Clone Traefik-Deployment to new system
- [ ] Run host_prep scripts without editing them
- [ ] All required env vars can be set in traefik.env
- [ ] Clone VitePress-Template to create new site
- [ ] Deploy new site without editing any scripts
- [ ] Only env vars and command-line args needed
- [ ] Site works with custom domain names
- [ ] Multiple sites can be deployed using same template
- [ ] No references to joshphillipssr.com in deployed config

---

## Next Steps

1. **Access Traefik-Deployment repository** to review actual script contents
2. **Access VitePress-Template repository** to review actual script contents
3. **Update this tracker** with findings from script review
4. **Create issues** for each hardcoded value that needs migration
5. **Implement migrations** script by script
6. **Test end-to-end** with clean deployment
7. **Update documentation** to reflect any new env vars discovered

---

## Notes

- This tracker should be updated as scripts are reviewed and migrated
- Use git blame/history to understand why certain values were hardcoded
- Consider backwards compatibility when changing env var behavior
- Document any breaking changes clearly

**Last Updated:** 2025-11-17  
**Status:** Initial draft - awaiting repository access for detailed review
