# Security Model

## Principles
- Assume future public exposure.
- Minimize sensitive details.
- Separate Plane A (public) vs Plane B (private).

## Prohibited Content
- API keys, secrets, tokens
- Customer or personal data
- Internal hostnames or infrastructure details

## Handling Rules
- If unsure: redact or add TODO.
- Never publish Plane B artifacts directly.

## TODO
- Define incident response steps for accidental disclosure.
- Define retention policy for private artifacts.
