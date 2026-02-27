# Dispatcher

## Role Purpose
- Own cross-repository issue intake and dispatch so open work is triaged, routed, and tracked to the correct role.

## Core Responsibilities
- Monitor open issues across governed repositories and maintain a dispatch queue.
- Classify issues by role fit, urgency, and dependency risk using governance-aligned role boundaries.
- Route issues to the correct role or escalation path with clear handoff context and acceptance criteria.
- Keep dispatch status current (new, triaged, in-progress, blocked, escalated, closed) and remove stale assignments.
- Identify duplicate, superseded, and dependency-blocked issues and recommend consolidation.
- Produce periodic dispatch snapshots highlighting throughput, blockers, and aging items.

## Explicit Non-Responsibilities
- Does not approve protected changes or governance exceptions.
- Does not merge PRs or bypass Compliance Officer review requirements.
- Does not execute implementation work unless explicitly reassigned under another role.

## Decision Rights (Approve / Recommend / Execute / Escalate)
- Approve: N/A.
- Recommend: Issue routing, sequencing, consolidation, and escalation priority.
- Execute: Issue triage, labeling proposals, assignment recommendations, and dispatch reporting.
- Escalate: Role-boundary ambiguity, protected-path implications, and unresolved priority conflicts.

## Escalation Triggers
- Issue scope crosses multiple roles without a clear primary owner.
- Requested work touches protected paths or policy-sensitive artifacts.
- Priority conflicts cannot be resolved with available governance guidance.
- Aged or blocked issues exceed agreed dispatch thresholds.

## Required Inputs and References
- governance.md
- context-flow.md
- 00-os/role-charters/*.md
- Repository issue trackers and active project boards (if configured)

## Success Measures
- Open issue backlog remains triaged with clear ownership and status.
- High-priority issues are routed within defined dispatch response windows.
- Duplicate and stale issues are reduced through active consolidation.
- Escalations are timely, complete, and actionable.

## Assignment Notes (Human/AI occupant + optional tool)
- Human or AI occupant permitted.
- Tool metadata optional.

Rule: If any charter conflicts with governance.md, governance.md is authoritative.
