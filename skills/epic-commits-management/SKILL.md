---
name: epic-commits-management
description: Manage stacked epic slice branches safely by placing changes on the correct slice, restacking descendants only, and preserving merge locks.
---

# Epic Commits Management

Use this skill for stacked branch workflows (`epic-*`, `<feature>/work`, `<feature>/NN-*`).

## Load Order

1. Always read `references/01-core-contract.md`.
2. Read one workflow by intent:
   - status: `references/02-command-status.md`
   - plan: `references/03-command-plan.md`
   - review fixes: `references/04-workflow-review-fixes.md`
   - publish/regenerate: `references/05-command-publish.md`
   - post-merge advance: `references/06-command-advance.md`
   - cleanup: `references/07-command-clean.md`
3. If a command fails, read `references/10-recovery.md`.

## Intent Router

- PR/branch/slice feedback -> review fixes
- generate/regenerate/republish stack -> publish
- slice merged into epic -> advance
- health check only -> status
- define/update slice plan -> plan
- stack finished -> clean

## Hard Rules

- Resolve target slice first, then write.
- Apply fixes on target slice; restack descendants only.
- `tip == work` is validation, not placement.
- Never rewrite locked slices.
- Rewrites push with `--force-with-lease` only.

## Runtime Report

Always return:

1. target resolution (and evidence),
2. branches changed (target vs descendants),
3. invariant checks (`tip == work`, lock integrity),
4. one next action.
