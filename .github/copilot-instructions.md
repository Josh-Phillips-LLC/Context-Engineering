

# Copilot Instructions — Context-Engineering (Plane B)

You are operating inside **Context-Engineering**, a **private Plane B (Operational Context)** repository.

Your job here is to help **build and maintain the context system itself**, not to write application code.

---

## Authoritative sources (read first)

Treat the following files as **ground truth**:

- `canvas.md` — AI Context & Workspace Operating Model  
- `context-flow.md` — Visual context flow and lifecycle  

If something is unclear, prefer adding a TODO rather than inventing behavior that contradicts these documents.

---

## What this repo is for

You may help with:
- Creating **structure** (folders, files) as instructed
- Writing **templates** (repo starters, prompt templates, checklists)
- Writing **operational documentation** (workflows, guardrails, security rules)
- Adding placeholders with clear TODOs

You should optimize for:
- Durability
- Portability across tools/LLMs
- Clarity for future agents

---

## What this repo is NOT for

You must NOT:
- Write application code
- Introduce secrets, tokens, credentials, keys, or environment-specific data
- Add speculative or “creative” content without instruction
- Change `canvas.md` or `context-flow.md` unless explicitly asked

---

## Context & security rules

- This repo is private, but **assume all content may be copied into public repos later**
- Follow the sensitivity tiers defined in `canvas.md`
- Never include:
  - API keys
  - Internal hostnames
  - Customer data
  - Personal data
- If unsure whether something is safe, leave a TODO

---

## Structure rules

- Do not invent new top-level folders without explicit instruction
- Prefer the existing high-level layout:
  - `00-os/` — operating system & rules
  - `10-templates/` — templates and starters
  - `20-canvases/` — session and publication artifacts
  - `30-vendor-notes/` — tool-specific behaviors
  - `40-private/` — explicitly internal-only material
- Keep files small and focused

---

## Writing style

- Prefer **templates, bullet points, and checklists**
- Avoid long prose unless documenting core concepts
- Use clear headings
- Be explicit about intended use
- Add TODOs where human judgment is required

---

## When asked to scaffold or build structure

- Create folders and files exactly as instructed
- Populate files with **reasonable starter content**, not exhaustive detail
- Include TODO sections for future refinement
- Do not refactor existing content unless asked

---

## Default behavior

If instructions are ambiguous:
1. Re-read `canvas.md` and `context-flow.md`
2. Choose the option that **preserves separation of Plane A vs Plane B**
3. Prefer minimal, reversible changes
4. Add TODOs instead of guessing

---

## Guiding principle

> **Context is infrastructure.**  
> Optimize for stability, clarity, and reuse — not cleverness.