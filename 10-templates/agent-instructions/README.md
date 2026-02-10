# Agent Instructions (Centralized, Tool-Agnostic)

## Purpose

This directory is the canonical source for role-based agent instructions used across runtimes.

Use it for:

- Codex runtime instruction generation
- Copilot role framing references
- Other agent adapters (for example, Ollama-based runtimes)

## Structure

- `base.md`: shared instructions that apply to every role
- `roles/<role>.md`: role-specific overlays

## Consumption Pattern

- Runtime adapters should compose instructions as:
  - `base.md`
  - plus one `roles/<role>.md`

Codex devcontainer startup currently materializes this composition into:

- `<workspace>/.role.instructions.md`

Other runtimes should consume the same source files directly or generate equivalent runtime artifacts.
