# AI Context Canvas (Exploratory)

This canvas captures exploratory context, options, and future-looking ideas.

Authoritative, enforceable policy lives in `governance.md`.

---

## Purpose

This document captures the **durable operating model** for how Josh (CEO), ChatGPT (Director of AI Context), and coding agents (VS Code Copilot / Codex / Continue / future LLMs) collaborate.

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
