# Workflow: Advance After Merge

Operation: `advance`

Optional CLI alias: `stack advance <feature> --merged-branch <branch_name>`

Use after a slice PR merges and the stack must progress without rewriting merged
history.

## Inputs

- `<feature>`
- merged slice branch (`--merged-branch`)
- `.stack/<feature>/epic.yml`

## Procedure

### 1) Preflight

Run mandatory write preflight from `01-core-contract.md`.

### 2) Resolve merged boundary

1. Find merged branch in spec order.
2. Fail if branch is not in spec or ref is missing.

### 3) Verify merge

Primary proof:

- `git merge-base --is-ancestor <merged-branch> epic-<feature>`

Fallback for squash merges:

- verify merged PR state via `gh`

If neither proof exists, stop.

### 4) Lock merged range

For this run, lock slices `1..N` where `N` is merged boundary. Locked slices are
immutable.

### 5) Rebuild unlocked descendants

Run publish algorithm for unlocked slices only (see
`references/05-publish.md`).

Rewrite scope is exactly `N+1..tip`.

### 6) Validation gate

Run repo validation command on each rewritten branch before push. Any failure
blocks all pushes.

Minimum requirement for this skill:

- run `yarn tsc` on each rewritten branch (and on work if moved)

### 7) Reset work to tip

After successful rebuild:

- `git branch -f <feature>/work <tip-slice>`
- `git push --force-with-lease origin <feature>/work`

### 8) Optional PR retarget

Optionally retarget the immediate next PR base to `epic-<feature>`.

## Guardrails

- never rewrite locked slices
- if all slices are locked, only align work to tip
- do not write `.stack/<feature>/state.json`

## Output

- result (`pass`/`fail`)
- newly locked slices for this run
- rebuilt branches and head changes
- work reset status
- optional PR retarget actions
- next step
