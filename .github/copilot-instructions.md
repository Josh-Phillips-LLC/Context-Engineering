

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

---

## Execution environment

- You are operating inside the Dev Container named `agent-workstation`.
- All commands must be run in the VS Code integrated terminal (container terminal), not on the host.
- Assume you have root inside the container and may install missing tools with `apt-get`.

### Workspace layout

- All repos are mounted at `/workspace`.
- The current repo is typically `/workspace/Context-Engineering` unless stated otherwise.

### Tools

#### When you need a tool

- If a tool is missing, install it in the container (Ubuntu) using apt:
  - `apt-get update && apt-get install -y <package>`
- Prefer CLI tools over GUI tools.

#### Persisting Tools

- Installing via `apt-get` inside a running container is acceptable, but survive container recreation for future agent sessions.
- Whenever you install anything with `apt-get`, you MUST also record it so a human can decide whether to bake it into the image later.
-- Whenever a tool is installed via `apt-get` also add it in `.devcontainer-workstation/Dockerfile` under an `# TODO: Candidate packages discovered by agents` block with the exact `apt-get install` line you used.

## PDF handling

- To inspect PDFs, prefer:
  - `pdftotext` (package: `poppler-utils`)
  - `pdfinfo` (also in `poppler-utils`)
  - `mutool` (package: `mupdf-tools`) if needed for rendering/extraction
- If the PDF is scanned, use OCR as a fallback:
  - `tesseract-ocr` + `imagemagick` (last resort)