# Command Reference: stack advance

Command:

```bash
stack advance <feature> --merged <NN>
```

## Goal

After slice `<NN>` is merged into `epic-<feature>`, lock merged slices and rebuild only the remaining slices.

This keeps the review stack aligned with the latest epic head while preserving immutable merged history.

## Inputs

- `<feature>`
- merged ID `<NN>`
- plan and state files under `.stack/<feature>/`

## Detailed Procedure

### 1) Run mandatory preflight

Use the shared preflight from `01-core-contract.md`.

### 2) Resolve merge target slice

1. Find branch for `<NN>` from plan (`<feature>/<NN>-<branch_suffix>`).
2. If multiple branches match the same ID, stop and request cleanup.
3. If branch is missing, fail with explicit restore/bootstrap guidance.

### 3) Verify merged status

Primary check:

- `git merge-base --is-ancestor <feature>/<NN>-* epic-<feature>`

Fallback when squash merges are used:

- confirm merged PR state via `gh` metadata
- if PR proof exists, allow lock progression

If neither ancestry nor PR proof confirms merge, stop.

### 4) Lock merged range

1. Determine locked range: `01..NN`.
2. Union with existing `locked_ids` from state.
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

Recommended after merge of `K`:

- retarget PR(`K+1`) base to `epic-<feature>`
- leave later PRs chained to immediate predecessor

If using `gh`:

- identify PR by head branch
- edit base branch for the next PR only

## Guardrails

- Never unlock previously locked IDs.
- Never rewrite locked slice branches.
- If merged ID is less than current max locked ID, treat as no-op and report.
- If all slices are locked, `advance` should only align work and state.

## Output Format

- Result (`pass` or `fail`)
- Newly locked IDs
- Rebuilt IDs and head changes
- Work branch reset result
- Optional PR retarget actions
- Next recommended command
