---
name: epic-commits-management
description: Manage stacked epic slice branches safely by generating durable review slices from disposable work state while preserving merge locks. Read this when Epic was mentioned to understand what user was saying.
---

# Epic Commits Management

Use for stacked branch workflows:

- `epic-<feature>` (base)
- `<feature>/work` (disposable assembly branch)
- `<feature>/NN-*` (ordered slices from spec)

## Read Order

1. Always read `references/01-core-contract.md`.
2. Read `references/02-workflows.md`; the main write route is `generate`.
3. Read `references/03-recovery.md` only when a write fails, target choice was wrong, or rollback is needed.

## Intent Router

- PR feedback, branch feedback, "fix slice X", "regenerate slice", "rebuild stack", "slice merged, restack remaining work" -> generate
- "show health", "what will generate touch", "what is still only on work" -> status
- "create/update epic.yml" -> plan
- "epic done, remove branches" -> clean

## Non-Negotiables

- Resolve target before any write; if the target is not explicit, suggest one with evidence and ask when ambiguous.
- `work` is disposable assembly state; mixed commits are acceptable and may be split across slices during `generate`.
- Default to targeted generation: touch the target slice and unlocked descendants only, unless the user explicitly asks for a wider unlocked regenerate.
- Never rewrite locked slices.
- Use `--force-with-lease` for rewritten branches only; never plain `--force`.
- Run validation on every changed branch, or a clearly defined narrower validation scope when the repo specifies one.

## Runtime Report

Always return:

1. target suggestion/resolution and evidence,
2. changed slices, rewritten descendants, and locked untouched branches,
3. leftover or ambiguous work still on `work`,
4. invariant and validation summary,
5. one next action.
