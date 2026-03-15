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
- `work` is the only source of truth for human-authored changes in the epic. Make manual commits on `work`, not on slice branches or ad hoc branches.
- `work` is disposable assembly state; mixed commits are acceptable and may be split across slices during `generate`.
- Every epic must have a repo-root `epic.yml`, even before the first generated slice exists. When there are no official slices yet, record that with `slices: []` so base/work metadata is still tracked.
- If the current worktree is dirty and safe epic writes would require stashing or cleaning unrelated edits, ask the user what to do before continuing. Do not auto-stash, auto-discard edits, or auto-create a temporary worktree.
- Only branches listed in repo-root `epic.yml` are official slices. Treat non-spec branches such as `staging-*`, scratch, or experiment branches as disposable context only, never as generate inputs or authoritative evidence of intended slice content.
- Default to targeted generation: touch the target slice and unlocked descendants only, unless the user explicitly asks for a wider unlocked regenerate.
- Generate syncs from `work` into official slices. After a full regenerate to tip with no reported leftovers, the tip slice should differ from `work` only by work-only metadata.
- After every successful `generate`, refresh `epic.yml.generated_from_work_commit` to the full SHA of the `<feature>/work` commit used for that run.
- Never rewrite locked slices.
- Restack descendants with explicit old/new parent boundaries such as `git rebase --onto <new-parent> <old-parent> <branch>`, not plain `git rebase <new-parent>`.
- Run rebase/cherry-pick continue steps non-interactively (`GIT_EDITOR=true`) unless the user explicitly wants to edit the commit message.
- Use `--force-with-lease` for rewritten branches only; never plain `--force`.
- Run validation on every changed branch, or a clearly defined narrower validation scope when the repo specifies one.

## Runtime Report

Always return:

1. target suggestion/resolution and evidence,
2. changed slices, rewritten descendants, and locked untouched branches,
3. leftover or ambiguous work still on `work`,
4. invariant and validation summary,
5. one next action.
