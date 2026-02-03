

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

### Reviewer / Merge Agent — Codex (optional)
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
 1. **Create an Issue** (CEO or Director) defining: objective, scope, constraints, and definition of done
 2. **Implement on a branch** (agent or human) with focused commits
 3. **Open a Pull Request** using templates and checklists
 4. **Review**
    - Codex reviews for compliance (structure, security, scope, Plane A/B boundaries)
    - Director/CEO makes final call for sensitive changes
 5. **Merge** (human merge for protected changes)

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