# Workflow

## Default Workflow (Reviewable Changes)
1. **Issue**: Objective, scope, constraints, definition of done
2. **Branch**: Focused edits with minimal scope and role-attributed commit messages
3. **Pull Request**: Use templates + include machine-readable PR metadata (`Primary-Role` / `Reviewed-By-Role` / `Executive-Sponsor-Approval`)
4. **Labels**: Apply required PR labels (at least one `role:*` label + exactly one `status:*` label) via `gh` immediately after PR creation
5. **Review**: Compliance Officer review + human decision where required; Compliance Officer posts PR Review Report comment; reviewer updates status labels after verdict; AI Governance Manager / Executive Sponsor makes final call for sensitive changes
6. **Merge**: Human merge for protected changes; update status labels

## Protected Changes (Require Executive Sponsor Approval)
- `governance.md` and `context-flow.md`
- Anything under `00-os/`
- Any change that affects Plane A vs Plane B boundaries

## Low-Risk Fast-Track (If Review Gate Passes)
- New templates under `10-templates/`
- Placeholder vendor notes under `30-vendor-notes/`
- New session canvas instances under `20-canvases/`

## Default Behaviors
- Prefer templates and checklists over prose.
- Add TODOs when judgment is required.
- Keep Plane A/Plane B separation intact.

## Artifact Flow
- Session Canvas → Publishable Extract → Repo Canvas

## TODO
- Add release cadence (weekly/monthly) if needed.
- Define acceptance criteria for each artifact type.
