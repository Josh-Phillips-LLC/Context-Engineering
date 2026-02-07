# Workflow

## Default Workflow (Reviewable Changes)
1. **Issue**: Objective, scope, constraints, definition of done
2. **Branch**: Focused edits with minimal scope
3. **Pull Request**: Use templates + checklists
4. **Review**: Codex review + human decision where required
5. **Merge**: Human merge for protected changes

## Protected Changes (Require CEO Approval)
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
