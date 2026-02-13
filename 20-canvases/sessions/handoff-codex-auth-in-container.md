# Handoff: Codex Auth in Role Container

Date: February 13, 2026
Role tested: Systems Architect (`systems-architect-workstation`)

## Goal

Capture the current state of Codex authentication in a role-scoped devcontainer and define the next implementation steps for semi-automated auth setup.

## Verified Facts

1. Container-side Codex auth is valid.
2. VS Code chat UI can still show `Sign in with ChatGPT` even when container auth is valid.
3. In this case, a VS Code window reload resolved the chat sign-in state mismatch.

## Evidence (Commands + Outcomes)

### Container is running

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
```

Observed: `systems-architect-workstation` up and healthy.

### Codex CLI auth status inside container

```bash
docker exec systems-architect-workstation sh -lc 'codex login status; echo EXIT:$?'
```

Observed:
- `Logged in using ChatGPT`
- `EXIT:0`

### Bundled Codex binary used by VS Code extension is also authenticated

```bash
docker exec systems-architect-workstation sh -lc '/root/.vscode-server/extensions/openai.chatgpt-0.4.74-linux-arm64/bin/linux-aarch64/codex login status; echo EXIT:$?'
```

Observed:
- `Logged in using ChatGPT`
- `EXIT:0`

### Token usability check (not just cached auth)

```bash
docker exec systems-architect-workstation sh -lc 'codex exec --skip-git-repo-check --sandbox workspace-write "Respond with exactly: AUTH_OK"'
```

Observed: returns `AUTH_OK`.

### Extension-host warning observed during activation

Path:

```text
/root/.vscode-server/data/logs/20260213T061940/exthost2/remoteexthost.log
```

Observed warning:
- `PendingMigrationError: navigator is now a global in nodejs...`
- stack includes `openai.chatgpt` (and also `github.copilot-chat` in same session)

Reference:
- https://aka.ms/vscode-extensions/navigator

## Interpretation

- Authentication itself was successful in-container.
- The VS Code Codex chat panel showing `Sign in with ChatGPT` was a UI/extension state mismatch.
- Reloading the VS Code window re-synced extension state with the authenticated container CLI state.

## Practical Workaround (Current)

When Codex chat shows `Sign in with ChatGPT` after successful container auth:

1. Run `codex login status` in the container terminal to confirm actual auth state.
2. If authenticated, run `Developer: Reload Window` in VS Code.
3. Re-open Codex chat.
4. If still stale, restart and reattach container.

## Semi-Automation Plan (Next Implementation)

Implement in workstation launcher/preflight:

1. Preflight check:
   - `codex login status`
2. If not authenticated:
   - run `codex login --device-auth` (or prompted fallback)
3. Post-auth verify:
   - `codex login status`
4. Optional smoke test:
   - `codex exec --skip-git-repo-check --sandbox workspace-write "Respond with exactly: AUTH_OK"`
5. Print explicit operator guidance:
   - if chat still says sign-in, run `Developer: Reload Window`.

Optional compatibility guard (until extension ecosystem settles):

- Set VS Code setting:
  - `extensions.supportNodeGlobalNavigator = false`

## Files/Areas to Touch for Automation

- `.devcontainer-workstation/scripts/start-role-workstation.sh`
- `.devcontainer-workstation/scripts/init-workstation.sh`
- `.devcontainer-workstation/README.md`

## Definition of Done for Auth Automation

1. Launch script prompts/authenticates reliably for role container usage.
2. `codex login status` succeeds after startup.
3. Operator instructions include VS Code reload fallback.
4. README documents exact flow and troubleshooting.
