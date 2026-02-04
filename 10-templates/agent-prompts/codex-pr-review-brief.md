# Codex PR Review Brief (Template)

## PR
- Link:
- Issue:
- Scope summary:

## Review Gate (Minimum)
- [ ] No secrets, tokens, internal hostnames, or personal data
- [ ] No new top-level folders without explicit instruction
- [ ] Changes are scoped to the Issue
- [ ] Templates/checklists used instead of long prose where applicable
- [ ] TODOs added where human judgment is required

## Role Attribution Verification
- [ ] Commit messages include role prefixes ([Copilot], [Codex], [CEO])
- [ ] PR title or labels identify the primary actor
- [ ] CEO approval comment exists when required (protected paths)

## Protected Changes Logic
- [ ] `canvas.md`, `context-flow.md`, or `00-os/` touched → CEO approval required
- [ ] Plane A/B boundary changes detected → CEO approval required

## Decision
- [ ] Approve
- [ ] Request changes (list blockers)
- [ ] Escalate to CEO

## TODO
- Add repo-specific gates (tests, lint, etc.).
