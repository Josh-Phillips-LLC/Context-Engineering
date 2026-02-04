# Codex PR Review Checklist (Template)

This file is a checklist + post-review enforcement actions for Codex.

Canonical review brief and required PR Review Report format: `10-templates/codex-pr-review-brief.md` (source of truth: `canvas.md`).

## PR
- Link:
- Issue:
- Scope summary:

## Blockers (REQUEST CHANGES if any fail)
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
- [ ] `canvas.md`, `context-flow.md`, or `00-os/` touched → CEO approval required
- [ ] Plane A/B boundary changes detected → CEO approval required

## Decision
- [ ] Approve
- [ ] Request changes (list blockers)
- [ ] Escalate to CEO

### Required Enforcement Actions (Post-Review)

After issuing a PR review verdict, Codex must enforce PR state via GitHub labels.

**If verdict = REQUEST CHANGES**
- Apply label `agent:codex`
- Apply label `status:changes-requested`
- Remove label `status:needs-review` if present

**If verdict = APPROVE**
- Apply label `agent:codex`
- Apply label `status:approved`
- Remove labels `status:needs-review` and `status:changes-requested` if present

**If PR touches protected paths and an explicit CEO approval comment exists**
- Optionally apply label `role:CEO-approved`

All label changes must be executed using `gh pr edit`.

Codex must request permission before executing shell commands.
Codex must not merge the PR.

## TODO
- Add repo-specific gates (tests, lint, etc.).
