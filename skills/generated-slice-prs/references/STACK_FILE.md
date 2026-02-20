# Stack File: `.feature-stack.md`

This file lives on the canonical `<feature>` branch and is the source of truth for:

- mode (DRAFT/REVIEW)
- stable slice IDs and branch suffixes
- optional PR link + status

## Goals

- Keep YAML frontmatter small (configuration, not history).
- Put frequent-change notes (regen log, reviewer notes) in the Markdown body.
- Never include this file in slice branches/slice PR diffs.

## Required fields

- `base` (default: `main`)
- `mode` (`DRAFT` or `REVIEW`)
- `mode_lock` (recommended boolean)
- `slices[]` ordered list with stable `id` and `branch_suffix`

## Recommended format (YAML frontmatter + Markdown body)

```md
---
version: 1
base: main
mode: DRAFT # DRAFT | REVIEW
mode_lock: true # if true, agent must not auto-switch mode

# Ordered and stable. Agent expands slice branch as: <feature>/<branch_suffix>
slices:
  - id: "01"
    branch_suffix: "01-scaffold"
    title: "Scaffold (types/flags/wiring)"
    pr: "" # optional: PR URL or number
    status: "draft" # optional: draft|review|approved|merged

  - id: "02"
    branch_suffix: "02-domain"
    title: "Domain logic"
    pr: ""
    status: "draft"
---

# Feature Stack: <feature>

## Notes

- Canonical branch: `<feature>`
- Slice branches `<feature>/01-*` are generated for review.
- `.feature-stack.md` is workflow-only and must not appear in slice diffs.

## Regen log (optional; keep short, last ~10)

- 2026-02-20: Updated slices 02 (validation feedback)
```

## Rules

- Never renumber existing `id`s once PRs exist.
- If inserting between `02` and `03`, use `02a`, `02b`, etc.
- Keep this file out of slice PR diffs.
