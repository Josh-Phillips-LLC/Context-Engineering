# AI Context & Workspace Operating Model

## Purpose
This document captures the **durable operating model** for how Josh (CEO), ChatGPT (Director of AI Context), and coding agents (VS Code Copilot / Codex / Continue / future LLMs) collaborate.

The goal is to:
- Prevent loss of critical context when chat sessions fail
- Keep context portable across tools and LLMs
- Enable public repositories without constant security sanitization
- Provide a repeatable, auditable workflow for AI-assisted engineering

---

## Organizational Model

### CEO — Josh
- Sets vision, priorities, and constraints
- Decides what becomes public vs private
- Approves publishable artifacts

### Director of AI Context — ChatGPT
- Helps design and maintain the context system
- Produces prompts, reviews agent output, and enforces standards
- Maintains private operational knowledge
- Prepares sanitized artifacts for publication

### Reviewer / Merge Agent — Codex
- Reviews Copilot/agent pull requests for alignment with this operating model
- Checks for security leaks, scope creep, and Plane A vs Plane B violations
- Uses deterministic checklists (not “looks good” intuition)
- Recommends approve / request changes; does not merge protected changes without CEO sign-off

### Agents — Copilot / Codex / Continue / Others
- Execute tasks using provided context
- Operate primarily on repo-local, public-safe context
- Do not retain long-term memory; context must be supplied

---

## Two-Plane Context Model

### Plane A — Public / Portable Context
**Lives with the code. Safe for public repos.**

Includes:
- Repo-specific Copilot instructions
- Architecture and workflow documentation
- Public-safe prompts and runbooks
- Sanitized decision logs
- Agent working agreements

Purpose:
- Make repos self-contained
- Enable tool/LLM portability
- Allow public sharing without redaction anxiety

### Plane B — Private / Operational Context
**Lives in a private Context-Engineering repo.**

Includes:
- CEO/Director/Agent operating system
- Prompt templates with internal assumptions
- Unredacted session canvases
- Tool behavior notes and quirks
- Security and redaction rules

Purpose:
- Act as the durable system of record
- Allow fast, unsanitized thinking
- Feed curated context into Plane A

---

## Canvas Lifecycle

### 1. Session Canvas (Private)
- Created during active ChatGPT sessions
- May include sensitive data, internal URLs, raw ideas
- Updated continuously during a working thread

### 2. Publishable Extract (Curated)
- Subset of the session canvas
- Explicitly marked as safe for repo inclusion
- Reviewed by CEO before publication

### 3. Repo Canvas (Public-Safe)
- Added to the target repo under `docs/ai/`
- Becomes durable context for agents
- Used by Copilot / Codex / Continue going forward

**Rule:** Chat history is ephemeral. Canvases are durable.

---

## Change Management: Issue / PR Process (reviewable edits)

All meaningful changes in this repo should be **reviewable**. The default workflow is **Issue → Branch → Pull Request → Review → Merge**.

### Goals
 - Make edits auditable and reversible
 - Reduce “random walk” documentation
 - Provide a clear contract between agents and reviewers

### Default workflow
 1. **Create an Issue** (CEO, Director, or Agent) defining: objective, scope, constraints, and definition of done
 2. **Implement on a branch** (agent or human) with focused commits and role-attributed commit messages
 3. **Open a Pull Request** using templates and checklists, including machine-readable PR metadata (see Role Attribution)
 4. **Apply PR labels** (agent or human) immediately after PR creation via `gh` to self-identify actor and set initial status
 5. **Review**
    - Codex reviews for compliance (structure, security, scope, Plane A/B boundaries)
    - Reviewer updates PR labels to reflect outcome (approved / changes requested)
    - Director/CEO makes final call for sensitive changes
 6. **Merge** (human merge for protected changes; update status labels)

### Protected changes (require CEO approval)
 - `canvas.md` and `context-flow.md`
 - Anything under `00-os/` (operating system & guardrails)
 - Any change that affects Plane A vs Plane B boundaries

### Low-risk changes (can be fast-tracked)
 - New templates under `10-templates/`
 - Placeholder vendor notes under `30-vendor-notes/`
 - New session canvas instances under `20-canvases/`

### Review gate (minimum)
 - No secrets / tokens / internal hostnames / personal data
 - No new top-level folders without explicit instruction
 - Changes are scoped to the Issue
 - Templates and checklists preferred over long prose
 - TODOs added where human judgment is needed

### PR lifecycle: close / supersede / cleanup
PRs are not deleted; they are merged or closed. Prefer `gh` over manual UI.

**Close a PR** when:
- It is stale/abandoned
- It is out of scope and rescoping is not worth it
- It is superseded by another PR

**Prefer rescoping (rewrite/rebase)** when:
- The PR is fundamentally correct but contains extra commits/files

**Closure hygiene (required):**
1) Leave a final comment stating why it is being closed and (if applicable) what replaces it.
2) Apply exactly one status label:
   - `status:closed` (default)
   - `status:superseded` (use instead of `status:closed` when replaced by another PR)
   - Remove any `status:needs-review`, `status:changes-requested`, `status:approved`
3) Delete the remote branch after closing unless intentionally retained.

**Canonical `gh` commands**
Close with comment:

```bash
gh pr close <PR_NUMBER> --comment "Closing PR: <reason>. Superseded by #<NEW_PR_NUMBER> (if applicable)." --delete-branch
```

Set closed labels:

```bash
gh pr edit <PR_NUMBER> --add-label "status:closed" --remove-label "status:superseded" --remove-label "status:needs-review" --remove-label "status:changes-requested" --remove-label "status:approved"
```

Add superseded label (optional):

```bash
gh pr edit <PR_NUMBER> --add-label "status:superseded" --remove-label "status:closed" --remove-label "status:needs-review" --remove-label "status:changes-requested" --remove-label "status:approved"
```

If the branch should be retained, omit the `--delete-branch` flag.

---

## Role Attribution & Auditability (Humans vs Agents)

Because all GitHub actions are authenticated under the same human identity (`joshphillipssr`), **explicit role attribution is required** to preserve auditability and intent.

The goal is to make it immediately clear:
- Who performed the work (Human vs Copilot vs Codex)
- Who reviewed it
- Who approved protected changes

### Required attribution mechanisms

At least **two** of the following must be used on every Pull Request (and at least one on every Issue). Using more is encouraged for clarity.

**Required for PRs:**
- Machine-readable PR metadata (below)
- GitHub labels (below)

#### 1. Commit message prefixes (preferred)
Use a clear prefix in commit messages:

- `[Copilot]` — work generated or scaffolded by Copilot
- `[Codex]` — review-driven or corrective changes based on Codex analysis
- `[CEO]` — human decisions, approvals, or direct edits by Josh

Example:
```
[Copilot] scaffold Context-Engineering templates
[Codex] fix tier naming inconsistencies
[CEO] approve protected-path changes
```

#### 2. Machine-readable PR metadata (required)
Every PR description must include the following fields (exact keys), so humans and automation can parse intent reliably:

- `Primary-Actor: Copilot|Codex|CEO`
- `Reviewed-By: Codex|CEO|N/A`
- `CEO-Approval: Required|Not-Required|Provided`

These fields do not replace narrative description; they make attribution auditable.

#### 3. GitHub labels (required for PRs)
Labels make role and status visible at a glance and must be applied on every PR.

**Role labels (pick all that apply):**
- `agent:copilot` — work primarily authored/scaffolded by Copilot
- `agent:codex` — work primarily driven by Codex review/fixes
- `role:CEO` — human-authored or human-directed changes by Josh

**Optional:**
- `role:CEO-approved` — use when a protected-path CEO approval comment exists (redundant but sometimes convenient)

**Status labels (pick one current status):**
- `status:needs-review`
- `status:changes-requested`
- `status:approved`
- `status:merged`
- `status:closed`
- `status:superseded`

**Rule:** Labels should be applied/updated by the actor (Copilot/Codex/CEO) via `gh` as part of the workflow — manual labeling is the exception, not the norm.

#### 4. Label application via `gh` (canonical commands)
Agents may have access to a shell with `gh` configured under the CEO identity. When labeling is required, use these canonical commands:

Apply initial labels after PR creation (example PR #3):
```bash
gh pr edit 3 --add-label "agent:copilot" --add-label "status:needs-review"
```

Update labels after Codex review (REQUEST CHANGES):
```bash
gh pr edit 3 --add-label "agent:codex" --add-label "status:changes-requested" --remove-label "status:needs-review"
```

Update labels after Codex review (APPROVE):
```bash
gh pr edit 3 --add-label "agent:codex" --add-label "status:approved" --remove-label "status:needs-review" --remove-label "status:changes-requested"
```

On merge:
```bash
gh pr edit 3 --add-label "status:merged" --remove-label "status:approved" --remove-label "status:needs-review" --remove-label "status:changes-requested"
```

#### 5. Explicit PR comments for protected approval
Protected-path changes **must** include an explicit PR comment from the CEO.

Example:
> **CEO approval:**  
> I approve this pull request, including changes under protected paths (`00-os/`), per the Change Management rules defined in `canvas.md`.

### Non-goals
- GitHub author identity is **not** used to infer role
- Automated bot identities are optional and not required
- Attribution must be human-readable and reviewable in the PR timeline
- Long-term, prefer least-privilege tokens or GitHub automation for agent actions (labeling/commenting) even if they run under the CEO identity today

**Rule:** If an auditor cannot tell *who did what and why* from the PR alone, attribution is insufficient.

---

## Workspace Strategy

- Prefer **small, purpose-based workspaces** (single repo or tightly related repos)
- Avoid mega-workspaces for AI-heavy work
- Optional: maintain a dedicated "AI / Context Engineering" workspace

### VS Code Profiles
- **AI – Clean Profile**
  - Enabled: Copilot + Copilot Chat
  - Disabled: noisy or experimental extensions
  - Used for long-context AI work

---

## Instruction Layering

### Global (Private)
- Stored in Context-Engineering
- Principles, standards, prompt patterns

### Repo-Specific (Public-Safe)
- `.github/copilot-instructions.md`
- Focused, minimal, repo-scoped

### Tool Adapters
- Copilot, Continue, Codex each consume context differently
- Repo context is the shared baseline

---

## Security Model

### Sensitivity Tiers
1. **Public** — safe for public repos
2. **Internal** — private repo only
3. **Secret** — never committed (keys, tokens)

### Practices
- Secrets scanning on public repos
- Publishable Extract section required for promotion
- Assume Plane A is always world-readable

---

## Persistence Strategy

- No critical knowledge lives only in chat history
- Every meaningful session updates a canvas
- Repo canvases are the only inputs agents can rely on long-term

---

## Next Artifacts to Create

- `Context-Engineering/00-os/org-model.md`
- `Context-Engineering/00-os/security.md`
- Repo template: `docs/ai/context.md`
- Repo template: `.github/copilot-instructions.md`

---

## Notes
- This model is intentionally LLM-agnostic
- Tools are replaceable; context structure is not
- Stability comes from files, not sessions