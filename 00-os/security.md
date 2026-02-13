# Security Model

## Principles
- Assume future public exposure.
- Minimize sensitive details.
- Separate Plane A (public) vs Plane B (private).
- Keep this repo public-safe; store truly private material outside it.

## Prohibited Content
- API keys, secrets, tokens
- Customer or personal data
- Internal hostnames or infrastructure details

## Handling Rules
- If unsure: redact or add TODO.
- Never publish Plane B artifacts directly.

## Least-Privilege GitHub Token Strategy (Agents)

Use separate tokens for Implementation Specialist automation vs admin actions.
Implementation Specialist tokens should be scoped to the minimum required repo and permissions.

### Fine-grained PAT permissions (minimum)

Repository access:
- Only the specific repo(s) the agent must act on.

Permissions:
- Issues: write (create issues, add comments, apply labels)
- Pull requests: write (update PR metadata when labeling via PR endpoints)
- Metadata: read (required by GitHub for most API access)

If a task only needs comments and labels, avoid broader permissions.
Do not use admin-scoped tokens for routine agent work.

### Token separation

- Implementation Specialist token: least-privilege scopes, repo-limited.
- Admin token: reserved for elevated actions (repo settings, branch protections, org config).
- Never reuse the admin token for routine automation.

### Rotation and storage

- Store tokens using GitHub CLI credential storage (keychain), not in repo files.
- Rotate tokens on a regular cadence and immediately on suspected exposure.
- Revoke old tokens after rotation and re-authenticate with `gh auth login`.
- Avoid long-lived environment variables; prefer CLI-managed auth.

## TODO
- Define incident response steps for accidental disclosure.
- Define retention policy for private artifacts.
