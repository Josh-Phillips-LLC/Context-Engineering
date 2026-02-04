# PR Review Checklist (Deterministic)

## Blockers (Must Pass)
- [ ] PR description includes all three exact metadata keys (Primary-Actor:, Reviewed-By:, CEO-Approval:)
- [ ] At least one role label exists (agent:copilot / agent:codex / role:CEO)
- [ ] Exactly one status:* label exists

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
- [ ] If `canvas.md`, `context-flow.md`, or `00-os/` changed → CEO approval required
- [ ] If Plane A/B boundary changes detected → CEO approval required

## Low-Risk Fast-Track
- [ ] Only low-risk paths changed (10-templates/, 30-vendor-notes/, new 20-canvases/)
- [ ] Review gate passed → eligible for fast-track

## Outcome
- [ ] Approve
- [ ] Request changes (list blockers)
- [ ] Escalate to CEO

## TODO
- Add repo-specific gates (tests, lint, etc.).
