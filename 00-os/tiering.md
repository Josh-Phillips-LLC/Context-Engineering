# Sensitivity Tiering

## Tiers
- **Tier 0 (Public)**: Safe for public repositories.
- **Tier 1 (Internal)**: Non-sensitive but private context.
- **Tier 2 (Sensitive)**: Operational details, strategy, or internal process.
- **Tier 3 (Restricted)**: Credentials, PII, customer data (never store here).

## Rules
- Plane A: Tier 0 only.
- Plane B: Tier 0–2 allowed; Tier 3 prohibited.
- If classification is unclear, default to higher tier and add TODO.

## TODO
- Add concrete examples per tier.
- Define redaction checklist for publication.
