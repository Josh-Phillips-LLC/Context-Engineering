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
- Runtime role instructions are generated at `/workstation/instructions/role-instructions.md` from workspace sources first, then image-baked compiled role instructions, then image-baked fallback sources; a workspace shim at `<workspace>/.role.instructions.md` links to the canonical file.
- Runtime adapter instruction files are generated at `/workstation/instructions/AGENTS.md` and `/workstation/instructions/copilot-instructions.md`, with workspace shims at `<workspace>/AGENTS.md` and `<workspace>/.github/copilot-instructions.md` linking to the canonical adapters.
- VS Code chat defaults are ensured at `/workstation/settings/vscode/settings.json`, with a workspace shim at `<workspace>/.vscode/settings.json`.
- Compliance Officer runtime instructions include `10-templates/compliance-officer-pr-review-brief.md` (or image fallback) as a required protocol include.
- If a role profile is missing, startup falls back to existing config values.
