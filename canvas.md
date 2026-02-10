# AI Context Canvas (Exploratory)

This canvas captures exploratory context, options, and future-looking ideas.

Authoritative, enforceable policy lives in `governance.md`.
Ratified role definitions live in `governance.md` and `00-os/role-charters/`.

---

## Purpose

This document explores a **durable operating model** candidate for how the Executive Sponsor (Josh), AI Governance Manager (ChatGPT), and Implementation Specialists (VS Code Copilot / Codex / Continue / future LLMs) might collaborate.

The goal is to:

- Prevent loss of critical context when chat sessions fail
- Keep context portable across tools and LLMs
- Enable public repositories without constant security sanitization
- Provide a repeatable, auditable workflow for AI-assisted engineering

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

## Role-Scoped Devcontainers (Exploratory)

Proposed direction: the workflow should terminate in **self-contained, role-specific development containers**.

Each container represents a *single role* (as defined by a Role Charter), not a person or a tool.

### Concept

- Each role has a dedicated devcontainer (or container profile)
- Opening the container in VS Code immediately places the user or AI agent *inside that role’s operating context*
- The container becomes the primary delivery mechanism for:
  - explicit role instructions
  - constraints and guardrails
  - allowed tools and extensions
  - environment-level defaults

### What a Role Container Includes

At minimum:

- Role Charter (concise, authoritative job description)
- Explicit instructions for that role (do / do not)
- Pointers to relevant governance sections
- Tooling and extensions appropriate to the role
- Optional: validation or linting rules aligned to role responsibilities

### What a Role Container Does *Not* Do

- It does not define identity (human vs AI)
- It does not assume a specific LLM or vendor
- It does not embed secrets or credentials
- It does not bypass governance or approval rules

### Benefits

- Strong separation of concerns
- Reduced cognitive load when switching roles
- Clear boundary enforcement for AI agents
- Portable across:
  - VS Code + Copilot
  - Codex
  - Continue
  - future agent runtimes

### Open Questions

- One container per role vs shared base + overlays?
- How are approval-only roles represented (read-only containers)?
- Should role containers be mandatory for certain operations?

---

## Next Artifacts to Create

- Repo template: `docs/ai/context.md`
- Repo template: `.github/copilot-instructions.md`

---

## Notes

- This model is intentionally LLM-agnostic
- Tools are replaceable; context structure is not
- Stability comes from files, not sessions

## Role Naming & Responsibility Model (Exploratory)

This section explores replacing tool-centric or person-centric role names (e.g. CEO, Codex, Copilot) with **business-style responsibility roles** that describe *what function is being performed*, not *which tool or model is used*.

### Motivation

Current role names mix:
- tool identities (Copilot, Codex)
- human titles (CEO)
- abstraction levels

This increases cognitive load, couples governance to specific vendors, and makes it harder to reason about accountability as the system scales.

### Direction (Exploratory)

Adopt **business-style role names** that:
- describe responsibility and authority
- are tool-agnostic
- survive model or vendor changes
- help agents reason about *intent*, not implementation

Examples (non-exhaustive, exploratory):

- **Policy Owner / Change Authority**
  - Owns and approves governance changes
  - Final decision-maker for protected or high-impact changes

- **Compliance Officer**
  - Ensures work conforms to governance and rules
  - Identifies violations or drift

- **Governance Analyst / Systems Analyst**
  - Analyzes existing documents and workflows
  - Proposes changes, refactors, or promotions (e.g. canvas → governance)
  - Creates issues or plans but does not implement directly

- **Documentation Technician**
  - Performs mechanical documentation work
  - Moves, edits, and formats content per instructions
  - Optimizes for correctness and consistency, not interpretation

- **Implementation / Tooling Technician**
  - Applies concrete changes to code, configs, Dockerfiles, etc.
  - Follows defined acceptance criteria

### Key Principle

Role names should reflect **responsibility and authority**, not:
- the specific AI tool
- the underlying model
- or whether the actor is human or AI

Tools (Copilot, Codex, future LLMs, humans) are *assigned* to roles; roles are not defined by tools.


### Open Questions / TODO

- What is the minimum canonical set of roles needed?
- Which roles are allowed to approve vs propose vs execute?
- How are roles referenced in issues, prompts, and governance?
- Should roles be formalized in `governance.md` once stable?

### Role-Based Assignment Model (Exploratory)

The Context Repository should define **roles with clear job descriptions**, independent of whether the role is fulfilled by:
- a human
- an AI agent
- or a specific tool (Copilot, Codex, future systems)

Under this model:
- Roles define **responsibilities, authority boundaries, expectations, and escalation rules**
- Humans or AI systems are **assigned to roles**, not the other way around
- Tool choice is an implementation detail, not part of the role definition

A "custom agent" is therefore understood as:

> **An agent operating with a predefined job description (role charter)**

The agent should understand its role *a priori*, without needing to infer identity or authority by reading multiple repository documents.

### Implications

- Role definitions should be:
  - concise
  - durable
  - reusable across repositories
  - stable even as tools or models change

- Repository documents (canvas, governance, instructions) are:
  - reference material
  - constraints to check against
  - not the primary source of agent identity

### Future Direction (Non-Binding)

- Introduce formal **Role Charters** as standalone artifacts
- Each Role Charter may include:
  - role purpose
  - responsibilities
  - explicit non-responsibilities
  - authority and approval boundaries
  - escalation conditions
  - definition of "successful" outcomes

- Once roles stabilize, promote core role definitions into `governance.md`
