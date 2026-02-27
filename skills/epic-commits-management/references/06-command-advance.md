# Command Reference: stack advance

Command:

```bash
stack advance <feature> --merged-branch <branch_name>
```

## Goal

After a slice branch is merged into `epic-<feature>`, lock merged slices and rebuild only the remaining slices.

This keeps the review stack aligned with the latest epic head while preserving immutable merged history.

## Inputs

- `<feature>`
- merged branch name from plan (`--merged-branch`)
- epic spec and state files under `.stack/<feature>/`

## Detailed Procedure

### 1) Run mandatory preflight

Use the shared preflight from `01-core-contract.md`.

### 2) Resolve merge target slice

1. Find the target branch in `slices[].branch_name` from plan.
2. If target is missing from plan, fail with explicit guidance.
3. If target branch ref is missing, fail with explicit restore/bootstrap guidance.

### 3) Verify merged status

Primary check:

- `git merge-base --is-ancestor <merged-branch> epic-<feature>`

Fallback when squash merges are used:

- confirm merged PR state via `gh` metadata
- if PR proof exists, allow lock progression

If neither ancestry nor PR proof confirms merge, stop.

### 4) Lock merged range

1. Determine lock boundary by plan order up to merged branch.
2. Union with existing `locked_branches` from state.
3. Record current heads for locked branches into `locked_heads`.
4. Fail if any locked branch cannot be resolved.

### 5) Rebuild unmerged slices

Run publish logic for unlocked slices only (same algorithm as `stack publish`):

- base remains `epic-<feature>`
- locked slices are immutable
- unmerged slices are rebuilt from `epic..<work>`

### 6) Recreate disposable work branch at new tip

After rebuild:

- `git branch -f <feature>/work <tip-slice>`
- `git push --force-with-lease origin <feature>/work`

### 7) Optional PR retargeting (Option A)

Recommended after merge of branch `K`:

- retarget next branch PR base to `epic-<feature>`
- leave later PRs chained to immediate predecessor

If using `gh`:

- identify PR by head branch
- edit base branch for the next PR only

## Guardrails

- Never unlock previously locked branches.
- Never rewrite locked slice branches.
- If merged branch is already locked, treat as no-op and report.
- If all slices are locked, `advance` should only align work and state.

## Output Format

- Result (`pass` or `fail`)
- Newly locked branches
- Rebuilt branches and head changes
- Work branch reset result
- Optional PR retarget actions
- Next recommended command
