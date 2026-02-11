# Repo Canvas (Exploratory)

This canvas captures exploratory context, options, and future-looking ideas that are not yet ratified.

Authoritative, enforceable policy lives in `governance.md`.
Ratified role definitions live in `governance.md` and `00-os/role-charters/`.

---

## How to Use This File

- Keep only proposals and open questions here
- Promote stable decisions into `governance.md` (and supporting artifacts), then remove them from this file
- Avoid restating ratified policy in this canvas

---

## Active Exploratory Themes

### Workspace Strategy

- Prefer **small, purpose-based workspaces** (single repo or tightly related repos)
- Avoid mega-workspaces for AI-heavy work
- Optional: maintain a dedicated "AI / Context Engineering" workspace profile

Open questions:

- Should workspace size limits be made explicit in governance?
- Should we standardize a default workspace layout for multi-repo tasks?

### VS Code Profiles

Candidate profile:

- **AI - Clean Profile**
  - Enabled: Copilot + Copilot Chat
  - Disabled: noisy or experimental extensions
  - Intended use: long-context AI work

Open questions:

- Should profile expectations become a documented baseline?
- Which extensions should be explicitly allowed vs disallowed?

### Role-Scoped Devcontainers

Proposed direction: the workflow should terminate in **self-contained, role-specific development containers**.

Each container represents a *single role* (as defined by a Role Charter), not a person or a tool.

Potential structure:

- Dedicated container per role, or shared base image with role overlays
- Role-specific instruction packs and defaults
- Role-appropriate tooling and extension sets
- Optional role-aligned validation rules

Constraints:

- It does not define identity (human vs AI)
- It does not assume a specific LLM or vendor
- It does not embed secrets or credentials
- It does not bypass governance or approval rules

Open questions:

- One container per role vs shared base + overlays?
- How should approval-only roles be represented (read-only container patterns)?
- Should role-scoped containers be mandatory for certain operations?
- What is the minimum viable rollout plan (pilot role, success criteria, fallback path)?

#### Role-Based Repo Distribution Plan (Proposed)

This is a candidate extension of role-scoped containers, not ratified policy.

Proposed target model:

- `Context-Engineering` remains the private governance/control-plane repo
- Create one public role repo per canonical role (initially `Implementation Specialist` and `Compliance Officer`)
- Each role repo is self-contained for IDE agents and includes:
  - `AGENTS.md` with role-compiled instructions
  - `.github/copilot-instructions.md` aligned to the same role instruction set
  - `.vscode/settings.json` defaults that keep instruction files in scope
  - Minimal role-specific bootstrap/config files only

Candidate build/publish flow:

1. Governance changes are merged in `Context-Engineering`
2. A role-instruction compiler pipeline generates role-specific outputs
3. CI opens/updates PRs in each public role repo with regenerated artifacts
4. Role repos produce release tags (or equivalent release signal)
5. GHCR role images are built/published from role repos
6. Workstation runtime clones role repo content and minimizes runtime instruction assembly logic

Candidate workstream breakdown:

1. Define architecture conventions (naming, ownership, visibility, versioning)
2. Scaffold role repo for `Implementation Specialist`
3. Scaffold role repo for `Compliance Officer`
4. Add sync automation from control-plane repo to role repos
5. Add GHCR build/publish automation from role repos
6. Update workstation runtime to consume role repos by role

Open questions:

- What are final repo names and org ownership conventions?
- Should role repos release from `main` only or versioned tags?
- Should sync automation direct-push changes or always open bot PRs?
- Which minimum file set must exist in each role repo to be considered production-ready?

### Role Model Extensions (Optional)

Canonical roles are already defined in governance. This section tracks only potential additions or refinements.

Open questions:

- Are additional specialist roles needed (for example, dedicated Security Reviewer)?
- If new roles are introduced, what approval boundaries change?

---

## Graduation Criteria

A canvas idea should graduate only when:

- Scope and language are stable
- Governance impact is clear
- Ownership and approval boundaries are explicit
- Required supporting artifacts (templates, charters, checklists) are identified

After graduation, remove the idea from this file and place the final policy in governance and related artifacts.
