# Org Model

## Purpose
- Define roles and responsibilities for the context system.

## Roles
- **Executive Sponsor**
  - Vision, priorities, constraints
  - Approves publishable extracts
- **AI Governance Manager**
  - Designs context system
  - Curates and sanitizes outputs
  - Maintains Plane B assets
- **Compliance Officer**
  - Reviews implementation output for alignment with operating model
  - Uses deterministic checklists (no intuition-only approvals)
  - Flags security leaks, scope creep, Plane A/B violations
  - Recommends approve / request changes
  - Does not merge protected changes without Executive Sponsor sign-off
- **Implementation Specialist**
  - Execute tasks within repo constraints
  - Produce drafts, artifacts, diffs
- **Business Analyst**
  - Performs exploratory analysis and planning
  - Proposes changes and drafts work orders

## RACI (lightweight)
- **Strategy**: Executive Sponsor (A), AI Governance Manager (R)
- **System design**: AI Governance Manager (A/R)
- **Execution**: Implementation Specialist (R), AI Governance Manager (A)
- **Publication**: AI Governance Manager (R), Executive Sponsor (A)

## Escalation
- If ambiguity persists, add TODO and request decision.

## TODO
- Add any additional roles (e.g., Security reviewer).
- Define backup approver for publication.
