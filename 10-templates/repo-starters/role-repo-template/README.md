# Role Repo Template (Proposed)

This starter defines a reusable template for generating public, role-specific repositories from repository-governed role definitions.

It is intended for the role-repo migration program and is not yet ratified governance policy.

## Purpose

- Provide a single scaffold source for role repositories.
- Keep role-repo instruction files deterministic and regenerable.
- Avoid hand-edit drift across role repos.

## Output Shape

The renderer writes this minimum file set to a target role repo:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.vscode/settings.json`
- `README.md`

Both instruction files include the same compiled role instruction set so either instruction consumer has complete role context.

## Source Inputs

Role instructions are compiled from:

- `10-templates/agent-instructions/base.md`
- `10-templates/agent-instructions/roles/<role-slug>.md`

For `compliance-officer`, the renderer also embeds:

- `10-templates/compliance-officer-pr-review-brief.md`

## Renderer

Script:

- `scripts/render-role-repo-template.sh`

Required args:

- `--role-slug`
- `--repo-name`
- `--output-dir`

Optional args:

- `--role-name`
- `--source-ref` (defaults to current `git rev-parse --short HEAD`)
- `--force` (allow writing into non-empty output directories)

## Example

```bash
10-templates/repo-starters/role-repo-template/scripts/render-role-repo-template.sh \
  --role-slug implementation-specialist \
  --repo-name context-engineering-role-implementation-specialist \
  --output-dir /tmp/context-engineering-role-implementation-specialist
```
