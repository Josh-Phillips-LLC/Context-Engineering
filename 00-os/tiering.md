# Sensitivity Tiering

**Note:** Named tiers are authoritative. Numeric labels are intentionally not used to avoid ambiguity.

## Tiers
- **Public**: Safe for public repositories.
- **Internal**: Private repo only. Non-sensitive operational context.
- **Secret**: Never committed (keys, tokens, credentials, PII, customer data).

## Rules
- Plane A: Public only.
- Plane B: Public and Internal allowed in private systems; Secret prohibited (never store anywhere here).
- This repository stays Public-only; store Internal material outside this repo.
- If classification is unclear, default to higher tier and add TODO.

## TODO
- Add concrete examples per tier.
- Define redaction checklist for publication.
