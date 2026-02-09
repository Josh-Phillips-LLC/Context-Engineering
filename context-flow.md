# Context Flow Map

This diagram shows how vision, context, prompts, and artifacts flow between the **Executive Sponsor (Josh)**, **AI Governance Manager (ChatGPT)**, and **Implementation Specialists** (VS Code Copilot / Codex / Continue / future LLMs), with **public vs private context planes** and the **canvas lifecycle**.

```mermaid
flowchart TB
  %% =========================
  %% Actors
  %% =========================
  ES["Executive Sponsor: Josh<br/>Vision - Priorities - Constraints"]:::actor
  AGM["AI Governance Manager: ChatGPT<br/>Context design - Prompting - Review"]:::actor
  AGENTS["Implementation Specialists: Copilot / Codex / Continue<br/>Execution in VS Code"]:::actor

  %% =========================
  %% Context Planes (Stores)
  %% =========================
  subgraph PVT["Plane B — Private Operational Context (Context-Engineering repo, PRIVATE)"]
    PVT_OS["00-os/<br/>Org model - Security model - Workflow"]:::store
    PVT_TPL["10-templates/<br/>Prompt templates - checklists - starters"]:::store
    PVT_SESS["20-canvases/sessions/<br/>Session canvases (unredacted)"]:::store
    PVT_PUBLOG["20-canvases/published/<br/>Publication log"]:::store
    PVT_TOOL["30-vendor-notes/<br/>Tool quirks - Version notes"]:::store
  end

  subgraph PUB["Plane A — Public / Portable Context (Code repos, PUBLIC-safe)"]
    RPO_INSTR[".github/copilot-instructions.md<br/>(repo-specific, minimal)"]:::store
    RPO_CANV["docs/ai/context.md<br/>Repo canvas (sanitized)"]:::store
    RPO_ARCH["docs/ai/architecture.md<br/>Architecture and conventions"]:::store
    RPO_ADR["docs/ai/decisions.md<br/>Sanitized ADRs / decision log"]:::store
    RPO_PROMPTS["docs/ai/prompts/<br/>Public-safe prompts"]:::store
  end

  %% =========================
  %% Main Flow
  %% =========================
  ES -->|Vision / goals / constraints| AGM

  AGM -->|Create / update| PVT_SESS
  AGM -->|Maintain| PVT_OS
  AGM -->|Create templates| PVT_TPL
  AGM -->|Capture tool behavior| PVT_TOOL

  %% Prompting loop
  AGM -->|Agent briefs: task prompts and repo context| AGENTS
  AGENTS -->|Work output: code, PRs, notes| AGM
  AGM -->|Review - refine - report| ES

  %% =========================
  %% Canvas Lifecycle
  %% =========================
  subgraph LIFECYCLE["Canvas Lifecycle (durable memory)"]
    SESS["1) Session Canvas (Private)<br/>raw ideas - sensitive ok"]:::artifact
    EXTR["2) Publishable Extract (Curated)<br/>explicitly public-safe"]:::artifact
    RCANV["3) Repo Canvas (Public-safe)<br/>durable agent context"]:::artifact
  end

  PVT_SESS -->|Written as| SESS
  SESS -->|Curate and sanitize| EXTR
  EXTR -->|Publish into repo| RCANV
  RCANV -->|Stored as| RPO_CANV
  EXTR -->|Record what changed| PVT_PUBLOG

  %% =========================
  %% Agent Consumption
  %% =========================
  AGENTS -->|Consume| RPO_INSTR
  AGENTS -->|Consume| RPO_CANV
  AGENTS -->|Reference| RPO_ARCH
  AGENTS -->|Reference| RPO_ADR
  AGENTS -->|Reuse| RPO_PROMPTS

  %% =========================
  %% Guardrails
  %% =========================
  PVT_OS -->|Defines security tiers + publish rules| EXTR
  PVT_TPL -->|Provides prompt patterns| AGM
  RPO_CANV -->|Limits scope + constraints| AGENTS

  %% =========================
  %% Styling
  %% =========================
  classDef actor fill:#eef,stroke:#55f,stroke-width:1px,color:#000;
  classDef store fill:#efe,stroke:#2a7,stroke-width:1px,color:#000;
  classDef artifact fill:#fff,stroke:#999,stroke-width:1px,color:#000,stroke-dasharray: 3 3;
```

## How to use this map
- **If chat history breaks:** the *Session Canvas* is still the durable record.
- **If you switch tools/LLMs:** the *Repo Canvas + repo docs* are the portable context baseline.
- **If you publish repos:** only Plane A artifacts are allowed; Plane B remains private.
- **Agents should default to Plane A**; Plane B is opt-in and curated via “Publishable Extract”.