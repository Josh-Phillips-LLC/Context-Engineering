# Glossary

Canonical terms for this repository. Definitions link to authoritative sources.

## Context-Engineering

The private system-of-record for how AI context is designed, curated, reviewed, and published. See [README.md](README.md).

## Plane A (Public / Portable Context)

Public-safe context that lives with code repositories. See [Two-Plane Context Model](governance.md#two-plane-context-model).

## Plane B (Private / Operational Context)

Private operational context that lives in this repository and feeds curated artifacts into Plane A. See [Two-Plane Context Model](governance.md#two-plane-context-model).

## Session Canvas

A private, continuously updated canvas created during an active session. See [Canvas Lifecycle](governance.md#canvas-lifecycle).

## Publishable Extract

A curated subset of a session canvas marked safe for repo inclusion. See [Canvas Lifecycle](governance.md#canvas-lifecycle).

## Repo Canvas

A public-safe canvas published into a target repo for durable agent context. See [Canvas Lifecycle](governance.md#canvas-lifecycle).

## Executive Sponsor

Role that sets vision, priorities, and constraints and approves publishable artifacts. See [Organizational Model](governance.md#organizational-model).

## AI Governance Manager

Role that designs and maintains the context system and prepares sanitized artifacts. See [Organizational Model](governance.md#organizational-model).

## Compliance Officer

Role that reviews implementation output for alignment and posts the PR Review Report. See [Organizational Model](governance.md#organizational-model).

## Implementation Specialist

Role that executes tasks using repo-local, public-safe context. See [Organizational Model](governance.md#organizational-model).

## Business Analyst

Role that performs exploratory analysis and planning and drafts work orders. See [Organizational Model](governance.md#organizational-model).

## Role Charter

The canonical definition of a role, stored under [00-os/role-charters/](00-os/role-charters/). See [Role assignment principle](governance.md#role-assignment-principle).

## Operating System (00-os)

The operating model and guardrails for this repo, including workflows, security, and tiering. See [00-os/](00-os/) and [Protected changes](governance.md#protected-changes-require-executive-sponsor-approval).

## Sensitivity tiers (Public, Internal, Secret)

Three tiers that classify what can be public, what stays private, and what is never committed. See [Sensitivity Tiers](governance.md#sensitivity-tiers).

## Protected changes

Changes to protected paths or boundaries, including governance, context flow, and operating system docs. See [Protected changes](governance.md#protected-changes-require-executive-sponsor-approval).

## Low-risk changes

Changes that can be fast-tracked, such as new templates, vendor notes, or session canvases. See [Low-risk changes](governance.md#low-risk-changes-can-be-fast-tracked).

## PR Review Report

The required review artifact posted by the Compliance Officer on each PR it reviews. See [Compliance Officer](governance.md#compliance-officer--codex-current-assignment).

## Issue-first workflow

The default change flow: Issue, branch, pull request, review, merge. See [Change Management](governance.md#change-management-issue--pr-process-reviewable-edits).
