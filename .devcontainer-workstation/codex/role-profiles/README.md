# Role Profiles

Role profiles are lightweight overlays applied by `init-workstation.sh` at container startup.

Each role profile is an `.env` file named `<role>.env` and may set:

- `ROLE_APPROVAL_POLICY`
- `ROLE_MODEL_REASONING_EFFORT`
- `ROLE_MODEL_PERSONALITY`
- `ROLE_WRITABLE_ROOTS` (JSON array string)
- `ROLE_PROJECT_DOC_FALLBACK_FILENAMES` (JSON array string)

Startup behavior:

- Base config is seeded from `/etc/codex/config.toml` when `/root/.codex/config.toml` does not exist.
- Role overlays then replace supported keys in `/root/.codex/config.toml`.
- Runtime role instructions are generated at `<workspace>/.role.instructions.md` from workspace sources first, then image-baked fallback sources.
- Compliance Officer runtime instructions include `10-templates/compliance-officer-pr-review-brief.md` (or image fallback) as a required protocol include.
- If a role profile is missing, startup falls back to existing config values.
