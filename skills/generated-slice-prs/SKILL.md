---
name: generated-slice-prs
description: Generate and maintain review slice branches <feature>/01-* from a canonical feature branch <feature>, with mode + slice list stored in .feature-stack.md. Use to avoid stacked-rebase pain while reviewing a large feature in multiple PRs.
---

# Generated Slice PRs (Router)

## Core idea (always in scope)

- Canonical working branch is named `<feature>` (example: `coin-chart-redesign`).
- Slice branches are generated as `<feature>/01-*`, `<feature>/02-*`, …
- Source of truth is `.feature-stack.md` committed on `<feature>`.
- Slice PRs are the review units.
- Default operation is branch preparation/regeneration only; PR creation is a separate explicit step.
- Default endgame: merge slice PRs into `<base>` and do NOT merge `<feature>` (unless user explicitly chooses otherwise).

## Absolute invariants (never violate)

1. Correct diff base:
   - Every slice branch MUST be created from `B = merge-base(<base>, <feature>)` (not from `<feature>` tip).
2. Stable slice IDs:
   - Never renumber existing slices after PRs exist.
   - Insert new slices as `02a-*`, `02b-*`, etc.
3. Mode behavior:
   - REVIEW mode: append-only updates on slice branches (no force-push).
   - DRAFT mode: rewriting is allowed, but prefer minimal churn anyway.
4. Stack file is the truth:
   - If `.feature-stack.md` exists, its `slices[]` order/IDs are authoritative.
5. Stack file is workflow-only:
   - `.feature-stack.md` must NOT appear in slice branch diffs / slice PRs.

## Minimal context rule (IMPORTANT)

Do NOT load all references.
Only load the specific reference docs needed for the operation you are performing (routing below).
Always read `.feature-stack.md` first (or create it if missing).

## Routing: operation → what to read

### 0) Determine current state (always do this first)

- Read `.feature-stack.md` on `<feature>` to get:
  - `<base>` (default `main`)
  - `mode` + `mode_lock`
  - ordered `slices[]` list
    If missing: create it using `references/STACK_FILE.md` template.

Read:

- `references/STACK_FILE.md` (only if missing or needs migration)

---

### A) Initial split (first time preparing slices)

Goal: create slice branches + record slice list into `.feature-stack.md`.

Read:

- `references/WORKFLOW.md` (Initial split)
- `references/SLICING_GUIDE.md` (how to cut slices)

---

### A2) Publish slice PRs (explicit, non-default step)

Goal: create/open PRs for already-prepared slice branches and record PR links/status.

Read:

- `references/WORKFLOW.md` (Publish slice PRs)
- `references/PR_TEMPLATE.md` (titles/bodies)

---

### B) Apply review feedback (recommended flow)

Goal: user changed `<feature>`; update only impacted slices with minimal churn.

Read:

- `references/MINIMAL_CHANGE.md`
- `references/WORKFLOW.md` (Feedback → regenerate)

(Do NOT load slicing guide unless you are changing the slice plan.)

---

### C) Regenerate slices after new commits on `<feature>` (no review context)

Goal: refresh slices, keep IDs stable, churn low.

Read:

- `references/MINIMAL_CHANGE.md`
- `references/WORKFLOW.md` (Regenerate)

---

### D) Change mode (DRAFT ↔ REVIEW)

Goal: update `.feature-stack.md` mode safely (respect `mode_lock`).

Read:

- `references/MODES.md`

---

### E) Insert a new slice between existing ones

Goal: add `02a-*` etc without renumbering; update `.feature-stack.md`.

Read:

- `references/MINIMAL_CHANGE.md` (insertion rules)
- `references/SLICING_GUIDE.md` (only if you need heuristics)

---

### F) Something looks wrong (diffs wrong / churn / comments lost)

Goal: diagnose and recover.

Read:

- `references/TROUBLESHOOTING.md`

## What must be updated on every run

- `.feature-stack.md` YAML frontmatter:
  - `base`, `mode`, `mode_lock` (if used)
  - `slices[]` list (ids, branch_suffix, titles; optional PR/status)
- `.feature-stack.md` Markdown body:
  - optional short regen note (keep brief; do not bloat YAML)

## Defaults

- `<base>` defaults to `main` if not specified.
- By default, only prepare/update slice branches and `.feature-stack.md`.
- Do not create or update PRs unless the user explicitly requests PR publication.
- If `mode_lock: true`, do not change mode unless user explicitly instructs.
