# Copilot Instructions — Context-Engineering

## Project Overview

**Context-Engineering** is a structured documentation repository for managing AI session context, project requirements, and architectural decisions across multiple related projects.

**Purpose**: Provide comprehensive, authoritative context for AI coding agents working on complex multi-repository systems.

## Repository Structure

```
Context-Engineering/
  General/
    Initial Context.md           # Project inception and goals
  Traefik-VitePress-Context/
    .github/copilot-instructions.md  # AI agent instructions for Traefik ecosystem
    Traefik-Project-Context.md       # Complete architecture and requirements
    Documentation-Review-Summary.md  # Executive summary of doc review
    Documentation-Gap-Analysis.md    # Detailed discrepancy catalog
    Environment-Variables-Migration-Tracker.md  # Variable migration tracking
    Recommendations.md               # Prioritized improvement roadmap
    README.md                        # Navigation guide
```

## Document Hierarchy & Purpose

### 1. Traefik-Project-Context.md — The Authoritative Source
**Status**: ✅ Complete and authoritative  
**Use when**: You need complete project scope, architecture, requirements, workflows

**Contains**:
- Repository structure and purpose (Traefik-Deployment, VitePress-Template)
- Host folder layout (authoritative filesystem structure)
- Complete environment variable definitions
- Two-phase host provisioning workflow
- Site deployment processes
- Webhook automation architecture
- Outstanding development tasks

### 2. Documentation-Review-Summary.md — Start Here for Reviews
**Status**: ✅ Complete  
**Use when**: Quick overview of documentation review findings

**Contains**:
- Summary of November 2025 review
- Key issues identified with priority levels
- What's complete vs. what needs repository access
- Timeline and next actions

### 3. Documentation-Gap-Analysis.md — Detailed Discrepancies
**Status**: ✅ Complete  
**Use when**: Investigating specific inconsistencies across documentation

**Key findings**:
- Script naming: `host_prep1.sh` vs `host_prep_root.sh` discrepancies
- Missing script clarity: `deploy_site.sh` vs `deploy_to_host.sh`
- Folder structure verification needs
- Legacy references to `joshphillipssr.com`

### 4. Environment-Variables-Migration-Tracker.md — Migration Framework
**Status**: ✅ Framework created, awaiting full audit  
**Use when**: Working on eliminating hardcoded values

**Tracks**:
- 7 host-level variables (in `~deploy/traefik.env`)
- 5 site-level variables (deployment parameters)
- Script review checklist (12 scripts)
- Configuration file checklist
- Known legacy references

### 5. Recommendations.md — Action Items
**Status**: ✅ Complete  
**Use when**: Ready to implement improvements

**Contains**:
- 10 prioritized recommendations (High/Medium/Low)
- Detailed action items and success criteria
- Testing and verification plans
- Resource estimates (20-40 hours)
- Risk assessment

## Multi-Repository Context

This repository provides context for three primary repositories:

### Traefik-Deployment
Production-grade Traefik v3 infrastructure for multi-site container hosting.

**Key files**: `host_prep_root.sh`, `host_prep_deploy.sh`, `update_site.sh`  
**Critical pattern**: Two-phase provisioning (root → deploy user)

### VitePress-Template
Generic VitePress documentation/portfolio template for deployment behind Traefik.

**Key principle**: Domain-agnostic—all config via environment variables  
**Critical pattern**: Multi-stage Docker build (Node.js → Nginx)

### Context-Engineering (this repo)
Living documentation and architectural decision records.

**Update cycle**: As architecture evolves or gaps are discovered

## Document Maintenance Patterns

### When to Update Context Documents

1. **Architecture changes**: Update `Traefik-Project-Context.md` when system design changes
2. **Gap discoveries**: Add to `Documentation-Gap-Analysis.md` when finding discrepancies
3. **Migration progress**: Update `Environment-Variables-Migration-Tracker.md` as variables are externalized
4. **New recommendations**: Add to `Recommendations.md` with priority classification

### Version Control Headers

Policy documents should include:
```markdown
**Version:** X.X
**Last Updated:** YYYY-MM-DD
**Author(s):** Name/Role
```

### Cross-Reference Pattern

Use clear references to related documents:
```markdown
See **Traefik-Project-Context.md** Section 4.2 for deployment workflows.
Refer to **Documentation-Gap-Analysis.md** Issue #3 for script naming discrepancies.
```

## AI Agent Guidelines

### When Working Across Repositories

1. **Read Context-Engineering first**: Understand complete architecture before editing individual repos
2. **Validate against authoritative docs**: Check `Traefik-Project-Context.md` for ground truth
3. **Document new gaps**: If you find discrepancies, note them for future gap analysis updates
4. **Preserve established patterns**: Script headers, env sourcing, sudo re-exec patterns are standardized
5. **Test cross-repository workflows**: Changes to one repo may affect deployment flows in others

### When Updating Context Documents

1. **Maintain document hierarchy**: `Traefik-Project-Context.md` is authoritative
2. **Update related docs together**: Changing workflows? Update Context, Recommendations, Gap Analysis
3. **Preserve formatting**: Numbered sections, consistent Markdown patterns
4. **Date your updates**: Add "Last Updated" timestamps to major changes
5. **Link to evidence**: Reference specific files/line numbers when documenting issues

### Content Restrictions

- **Never embed secrets**: No API tokens, passwords, or private keys
- **Use placeholders**: `example.com`, `yourdomain.com`, `<SITE_NAME>` for examples
- **Generic patterns only**: Document reusable approaches, not one-off solutions
- **No hardcoded values**: All examples should show environment variable patterns

## Common Patterns in This Repository

### Markdown Structure
```markdown
# Document Title

**Status**: ✅ Complete / 🚧 In Progress / ⏸ Awaiting Input

## Section Hierarchy
### Subsections
- Bulleted lists for non-sequential items
1. Numbered lists for sequential procedures
```

### Status Indicators
- ✅ Complete and verified
- 🚧 Work in progress
- ⏸ Blocked or awaiting input
- 📝 Draft/placeholder

### Priority Levels
- **High**: Critical for production readiness
- **Medium**: Important for maintainability
- **Low**: Nice-to-have improvements

## Integration with Other Projects

### Workflow: Using Context for Development

1. Review `Context-Engineering/Traefik-VitePress-Context/README.md` for navigation
2. Read `Traefik-Project-Context.md` for complete architecture
3. Check `.github/copilot-instructions.md` in target repository
4. Cross-reference environment variables, script patterns, deployment flows
5. Validate changes against documented workflows

### Feedback Loop

When working in Traefik-Deployment or VitePress-Template:
- **Found a gap?** Document in `Documentation-Gap-Analysis.md`
- **New pattern?** Update `Traefik-Project-Context.md`
- **Migration complete?** Update `Environment-Variables-Migration-Tracker.md`
- **Recommendation implemented?** Mark complete in `Recommendations.md`

## Known Documentation Issues

Tracked in `Documentation-Gap-Analysis.md`:

1. Script naming inconsistencies (`host_prep1.sh` vs `host_prep_root.sh`)
2. Folder structure discrepancies (`docker/` vs `traefik/docker/`)
3. Legacy domain references (`joshphillipssr.com` → `VitePress-Template`)
4. Missing script documentation (`deploy_site.sh` vs `deploy_to_host.sh`)

See `Recommendations.md` for prioritized action items to resolve.

## Future Enhancements

As documented in `Recommendations.md`:

- Complete environment variable migration audit
- Standardize script naming across all documentation
- Verify production filesystem layout against documented structure
- Create comprehensive testing checklist
- Develop Quick-Start validation suite

## Navigation Quick Reference

- **Need complete context?** → `Traefik-Project-Context.md`
- **Found an issue?** → `Documentation-Gap-Analysis.md`
- **Want to contribute?** → `Recommendations.md`
- **Review summary?** → `Documentation-Review-Summary.md`
- **Variable tracking?** → `Environment-Variables-Migration-Tracker.md`
