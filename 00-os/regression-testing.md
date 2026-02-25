# Regression Testing Baseline (v1)

## Purpose

Define a lightweight, deterministic baseline for regression testing in governed repositories.

This baseline is intended to:
- reduce behavior regressions
- keep review expectations clear
- avoid over-burdening low-risk documentation or template changes

## Scope

Apply this baseline to PRs in repositories operating under Context-Engineering governance.

## Core Rules

1. Behavior-changing PRs must include regression evidence.
2. If a behavior change does not include a regression test, the PR must include explicit justification and a follow-up issue.
3. PRs must declare a risk tier (`Low`, `Medium`, or `High`) and satisfy the corresponding expectations.
4. Flaky checks must be handled before merge using the flake policy below.
5. Incident-driven fixes must add a regression backfill test in the same PR or a linked follow-up issue.

## Risk Tiers

- `Low`
  - Documentation, metadata, formatting, or template-only updates with no behavior change.
- `Medium`
  - Behavior changes in scripts, logic, or workflows without elevated auth/security blast radius.
- `High`
  - Changes affecting auth, security controls, governance gates, CI policy enforcement, or other high-impact workflow controls.

## Minimum Expectations by Tier

- `Low`
  - Confirm no behavior change.
  - Required repository checks pass.
- `Medium`
  - Add or update targeted regression tests for changed behavior.
  - Required repository checks pass.
- `High`
  - Add or update regression tests that cover expected behavior and at least one failure path.
  - Required repository checks pass.
  - Compliance Officer review required; escalate when protected-path or policy boundaries are affected.

## Flake Policy

1. Retry a flaky check at most once.
2. If flake persists, treat as a blocker unless an explicit exception is approved.
3. Link a flake-tracking issue before merge when unresolved at PR time.

## Incident Regression Backfill

For fixes prompted by regressions/incidents:
- add a regression test in the fixing PR when feasible, or
- link a follow-up issue with owner and clear definition of done.

## PR Evidence Format

PR descriptions should include:
- declared risk tier
- tests/checks run
- behavior-change determination
- no-test justification (if applicable)
- linked flake/follow-up issue (if applicable)

