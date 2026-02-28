# Workflow: Advance After Merge

Command:

```bash
stack advance <feature> --merged-branch <branch_name>
```

## Intent

Use when a specific slice PR has merged and stack must move forward safely.

This keeps the review stack aligned with the latest epic head while preserving immutable merged history.

## Inputs

- `<feature>`
- merged branch name from epic spec (`--merged-branch`)
- epic spec under `.stack/<feature>/epic.yml`

## Detailed Procedure

### 1) Run mandatory preflight

Use the shared preflight from `01-core-contract.md`.

### 2) Resolve merge target slice

1. Find the target branch in `slices[].branch_name` from epic spec.
2. If target is missing from epic spec, fail with explicit guidance.
3. If target branch ref is missing, fail with explicit restore/bootstrap guidance.

### 3) Verify merged status

Primary check:

- `git merge-base --is-ancestor <merged-branch> epic-<feature>`

Fallback when squash merges are used:

- confirm merged PR state via `gh` metadata
- if PR proof exists, allow lock progression

If neither ancestry nor PR proof confirms merge, stop.

### 4) Lock merged range (ephemeral)

1. Determine lock boundary by spec order up to merged branch.
2. During this run, treat that range as locked.
3. Never rewrite branches in the locked range.

### 5) Rebuild unmerged slices

Run publish logic for unlocked slices only (same algorithm as `stack publish`):

- base remains `epic-<feature>`
- locked slices are immutable
- unmerged slices are rebuilt from `epic..<work>`

Scope rule:

- if merged boundary is slice `N`, only descendants `N+1..tip` can be rewritten
- ancestors `1..N` remain locked/untouched

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

- Never rewrite locked slice branches.
- If merged branch is already in merged ancestry, treat as no-op and report.
- If all slices are locked, `advance` should only align work branch to tip.
- Do not write `.stack/<feature>/state.json`.
- `tip == work` remains a validation check after advance, not a placement decision.

## Output Format

- Result (`pass` or `fail`)
- Newly locked branches (for this run)
- Rebuilt branches and head changes
- Work branch reset result
- Optional PR retarget actions
- Next recommended command
