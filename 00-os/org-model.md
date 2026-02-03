# Org Model

## Purpose
- Define roles and responsibilities for the context system.

## Roles
- **CEO**
  - Vision, priorities, constraints
  - Approves publishable extracts
- **Director of AI Context**
  - Designs context system
  - Curates and sanitizes outputs
  - Maintains Plane B assets
- **Reviewer / Merge Agent — Codex (optional)**
  - Reviews agent PRs for alignment with operating model
  - Uses deterministic checklists (no intuition-only approvals)
  - Flags security leaks, scope creep, Plane A/B violations
  - Recommends approve / request changes
  - Does not merge protected changes without CEO sign-off
- **Agents (Copilot/Codex/Continue)**
  - Execute tasks within repo constraints
  - Produce drafts, artifacts, diffs

## RACI (lightweight)
- **Strategy**: CEO (A), Director (R)
- **System design**: Director (A/R)
- **Execution**: Agents (R), Director (A)
- **Publication**: Director (R), CEO (A)

## Escalation
- If ambiguity persists, add TODO and request decision.

## TODO
- Add any additional roles (e.g., Security reviewer).
- Define backup approver for publication.
