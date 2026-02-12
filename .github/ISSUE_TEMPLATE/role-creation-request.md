---
name: Role Creation Request
about: Create a new governed role from charter through role repo and container publication
labels: ["change-request"]
---

## Objective
-

## Required Inputs
- Role title:
- Role slug (kebab-case):
- Role repo owner (organization/user):
- Role repo name override (optional, default `context-engineering-role-<role-slug>`):

## Scope (Allowed Changes)
- In scope:
- Out of scope:

## Implementation Requirements
- [ ] Create role charter at `00-os/role-charters/<role-slug>.md`
- [ ] Create role instruction source at `10-templates/agent-instructions/roles/<role-slug>.md`
- [ ] Create role job-description spec at `10-templates/job-description-spec/roles/<role-slug>.json`
- [ ] Add role profile env at `.devcontainer-workstation/codex/role-profiles/<role-slug>.env`
- [ ] Wire role in `.devcontainer-workstation/docker-compose.yml`
- [ ] Wire role in `.devcontainer-workstation/docker-compose.ghcr.yml`
- [ ] Add role to `.github/workflows/sync-role-repos.yml` matrix
- [ ] Add role to `.github/workflows/publish-role-workstation-images.yml` matrix
- [ ] Create public role repo scaffold via `create-public-role-repo.sh`
- [ ] Verify sync workflow success for the new role
- [ ] Verify publish workflow success for the new role
- [ ] Capture workflow/container verification evidence in PR

## Definition of Done
-

## Role Attribution
- **Proposed Implementer:** Implementation Specialist
- **Expected Reviewer:** Compliance Officer
- **Executive Sponsor Approval:** (Required / Not-Required)

## Notes
-

## Reference Template
Use: `10-templates/agent-work-orders/role-creation-work-order.md`
