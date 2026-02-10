# Implementation Specialist Work Order (Template)

Use this template in the **body of a GitHub Issue** when the Issue is intended to be executed directly by Copilot (i.e., “tell Copilot the Issue number and get to work”).

**Rule:** Section headings in this template are **normative**. Do not rename them.

---

## Implementation Specialist Work Order (Authoritative)

## Objective
Describe the single outcome this work order must achieve (1–3 sentences). Keep it measurable.

## Scope (Allowed Changes)
List the **only** files/folders Copilot may modify.

- Copilot may ONLY modify:
  - `path/to/file.md`
  - `path/to/folder/**`

State whether new files may be created (default: **No**).

Copilot must not infer additional scope beyond what is explicitly listed here.

## Out of Scope
List explicit exclusions so Copilot does not “helpfully” expand scope.

- Any files not listed in Scope
- Protected artifacts unless explicitly included:
  - `governance.md`
  - `context-flow.md`
  - `00-os/**`
- Automation that merges PRs
- Unrelated refactors / formatting-only changes

Copilot must not modify any file or path not explicitly listed in Scope.

## Implementation Requirements
Provide deterministic, step-by-step edits. Prefer “insert this block verbatim” and “replace this exact text with…” over prose.

### 1) Change <X>
- File: `path/to/file`
- Location: “Find the heading …” / “After the paragraph that begins …”
- Action: Insert/replace the following **verbatim**:

```md
PASTE CONTENT HERE
```

### 2) Change <Y> (optional)
Repeat as needed.

Do not modify any other content beyond what’s required to satisfy the Acceptance Criteria.

## Acceptance Criteria
Use checkboxes. Make these **binary** (pass/fail).

- [ ] Only files listed in Scope were modified
- [ ] All required content was added/updated exactly as specified
- [ ] No secrets, tokens, internal hostnames, IPs, or personal data introduced
- [ ] Commit message starts with `[Implementation Specialist]`
- [ ] PR description includes:
  - `Primary-Role: Implementation Specialist`
  - `Reviewed-By-Role: N/A` (or a canonical role if specified)
  - `Executive-Sponsor-Approval: Not-Required` (or `Required` / `Provided` if protected paths are touched)
- [ ] PR labels applied using GitHub UI, API/automation, or `gh`:
  - `role:implementation-specialist`
  - exactly one `status:*` label (`status:needs-review`)

## PR Instructions
State the exact PR title and any required PR-body summary.

- Open a PR titled: `Copilot: <short title>`
- Include a short summary mapping changes to Acceptance Criteria
- Link and close the Issue in the PR description (example: `Closes #<ISSUE_NUMBER>`)
- Apply labels (canonical `gh` commands in `governance.md` are optional examples)
- Do not merge the PR

### Branching (Required)
Copilot must create a fresh branch for each Issue using GitHub CLI default naming. Do not reuse existing branches.
Manual `git checkout -b` is not allowed for Issue-driven work.

Required commands (example):
```bash
gh issue develop <ISSUE_NUMBER> --checkout
```

Before committing, Copilot must verify it is on the correct branch:
```bash
git branch --show-current
```

Stop Condition:
- If Copilot is not on a fresh Issue branch, it must stop and request human input before proceeding.

## Stop Conditions
Copilot must stop execution immediately and request human input if:
- Required sections already exist but conflict with these instructions
- The change would require modifying files outside Scope
- Repo policy conflicts prevent deterministic execution
- Any instruction is ambiguous (Copilot must ask, not guess)

---

## Context (Non-executable) (Optional)
Add rationale, background, links, or discussion here. This section is not used for execution and must not expand scope.
