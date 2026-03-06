---
name: epic-commits-management
description: Manage stacked epic slice branches safely by placing changes on the right slice, rebuilding only allowed ranges, and preserving merge locks.
---

# Epic Commits Management

Use for stacked branch workflows:

- `epic-<feature>` (base)
- `<feature>/work` (authoring branch)
- `<feature>/NN-*` (ordered slices from spec)

## Read Order

1. Always read `references/01-core-contract.md`.
2. Read `references/02-workflows.md` and select operation by intent.
3. Read `references/03-recovery.md` only when a write fails or rollback is needed.

## Intent Router

- PR feedback, branch feedback, "fix slice X" -> review fixes
- "publish stack", "regenerate stack", "rebuild stack" -> publish
- "slice merged, move stack forward" -> advance
- "show health" or "what will rewrite" -> status
- "create/update epic.yml" -> plan
- "epic done, remove branches" -> clean

## Non-Negotiables

- Resolve target slice before any write.
- For review fixes: commit on `<feature>/work` first, then place on target slice.
- Default to targeted updates: touch target slice and descendants only.
- Never rewrite locked slices.
- Use `--force-with-lease` for rewritten branches only; never plain `--force`.
- Run `yarn tsc` (or stricter repo gate) on every changed branch before finalizing.

## Runtime Report

Always return:

1. target resolution and evidence,
2. changed branches (target, descendants, untouched/locked),
3. invariant checks,
4. one next action.
