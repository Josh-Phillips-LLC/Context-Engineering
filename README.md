

# Context-Engineering

This repository is the **private system-of-record** for how AI context is designed, curated, reviewed, and published across Josh’s projects.

It defines **how humans and AI collaborate**, not just what tools are used. Tools are replaceable; **context structure is not**.

---

## What this repo is (and is not)

### This repo **is**
- The authoritative source for:
  - AI operating models (roles, workflows, guardrails)
  - Context design patterns
  - Prompt and review templates
  - Session canvases and publication records
- A **Plane B (Private / Operational Context)** repository
- Designed to be durable across:
  - VS Code Copilot
  - Codex
  - Continue
  - ChatGPT
  - Future LLMs and agents

### This repo **is not**
- A codebase
- A place to store secrets or credentials
- A dumping ground for ad-hoc notes
- A public-facing documentation site

---

## Core documents

These files define the foundation of the system and should change slowly.

- **`governance.md`**  
  The authoritative AI Context & Workspace Operating Model  
  Defines roles, context planes, canvas lifecycle, security model, and persistence strategy.

- **`canvas.md`**  
  Exploratory canvas (ideas, rationale, options, roadmap, experiments).

- **`context-flow.md`**  
  A visual map of how context, prompts, and artifacts flow between:
  - Executive Sponsor (Josh)
  - AI Governance Manager (ChatGPT)
  - Implementation Specialists
  Including how private context becomes public-safe repo context.

---

## Mental model: Context planes

This system is built around **two explicit planes of context**:

### Plane A — Public / Portable Context
- Lives *with code repositories*
- Safe for public repos
- Includes repo canvases, Copilot instructions, architecture docs, and sanitized prompts
- This is what agents consume by default

### Plane B — Private / Operational Context
- Lives in this repository
- May contain sensitive assumptions, internal workflows, and unredacted canvases
- Feeds curated, sanitized artifacts into Plane A
- This repo **is Plane B**

**Rule:** Nothing moves from Plane B to Plane A without intentional curation.

---

## Canvas lifecycle (durable memory)

Chat history is ephemeral. **Canvases are durable.**

1. **Session Canvas (private)**  
   Created during active thinking or ChatGPT sessions. May contain raw ideas and sensitive data.

2. **Publishable Extract (curated)**  
   A clearly marked subset of a session canvas that is safe to share.

3. **Repo Canvas (public-safe)**  
   Published into a code repository (usually under `docs/ai/`) and becomes durable agent context.

---

## Expected repository structure (high level)

This repo is intentionally structured to separate **operating system**, **templates**, **canvases**, and **tool-specific knowledge**.

You will see folders such as:
- `00-os/` — operating model, workflows, security rules
- `10-templates/` — repo starters, prompt templates, review checklists
- `20-canvases/` — session canvases and publication logs
- `30-vendor-notes/` — tool-specific behaviors and quirks
- `40-private/` — explicitly internal-only material

Exact contents may evolve, but the separation of concerns should remain.

---

## Security posture

This repository is private by design, but still follows strict rules:

- **No secrets or credentials** are stored here
- Sensitivity is explicitly tiered: **Public, Internal, Secret**
- Only Public artifacts are allowed to leave this repo
- Secret (credentials, tokens, PII) is never committed
- Assume anything copied into a code repo may become public

---

## How this repo is used in practice

- The Executive Sponsor (Josh) defines goals and constraints
- The AI Governance Manager (ChatGPT) helps:
  - design context
  - generate prompts
  - review agent output
- Implementation Specialists (Copilot / Codex / Continue) execute using **repo-local, public-safe context**
- Durable knowledge always lands in files, not chat logs

---

## Contribution rules (especially for AI agents)

If you are an AI agent operating in this repo:

- Treat `governance.md` and `context-flow.md` as authoritative
- Prefer **templates, checklists, and structure** over long prose
- Do not invent new top-level folders without explicit instruction
- Do not include secrets or environment-specific data
- When in doubt, add TODOs instead of guessing

---

## Guiding principle

> **Stability comes from files, not sessions.**  
> Context is infrastructure.

This repository exists to make that principle real.