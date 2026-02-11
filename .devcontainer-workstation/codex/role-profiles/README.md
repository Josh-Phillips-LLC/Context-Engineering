# Role Profiles

This directory is **Codex-specific**.
These `.env` files only control Codex runtime configuration overlays in workstation containers (via `/root/.codex/config.toml`).
They do not define tool-agnostic role responsibilities or governance policy.

Canonical role responsibilities and instruction content live in repository-governed sources (for example, `10-templates/agent-instructions/**`).

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
- `ROLE_PROFILE` defaults to image-baked `IMAGE_ROLE_PROFILE` when not explicitly set at runtime.
- Runtime role instructions are generated at `/workspace/instructions/role-instructions.md` from role-repo `AGENTS.md` first, then image-baked compiled role instructions, then image-baked fallback sources.
- Default runtime clone targets are role repos by role:
  - `context-engineering-role-implementation-specialist`
  - `context-engineering-role-compliance-officer`
- Runtime adapter instruction files are generated at `/workspace/instructions/AGENTS.md` and `/workspace/instructions/copilot-instructions.md`.
- VS Code chat defaults are ensured at `/workspace/settings/vscode/settings.json`.
- Compliance Officer runtime instructions include `10-templates/compliance-officer-pr-review-brief.md` (or image fallback) as a required protocol include.
- If a role profile is missing, startup falls back to existing config values.
