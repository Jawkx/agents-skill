# Recovery Reference

Use this file only when a command fails, a branch was rewritten incorrectly, or rollback is required.

## Quick Triage

1. Stop further writes.
2. Capture current state:
   - `git status -sb`
   - current branch
   - failing command and output
3. Identify whether backup refs exist.
4. Pick the smallest recovery action that restores invariants.

## Standard Rollback

Use when publish/advance partially succeeded and branch pointers must be restored.

1. Find backup refs:
   - `backup/<feature>/<timestamp>-<branch-slug>`
2. Reset affected local branch pointers:
   - `git branch -f <branch> backup/<feature>/<timestamp>-<branch-slug>`
3. Push repaired pointers:
   - `git push --force-with-lease origin <branch>`
4. Re-run:
   - `stack status <feature>`

## Failure Scenarios

## 0) Fix landed on wrong slice (tip-only mistake)

Symptoms:

- user requested PR/branch `04` fix
- change was committed on `05` instead

Recovery:

1. restore `05` from backup ref if needed
2. move/apply fix onto `04`
3. restack descendants `05..tip` only
4. validate `tip == work`

Prevention:

- resolve target before writing
- treat `tip == work` as validation only

## 1) Dirty tree blocks preflight

Symptoms:

- `git status --porcelain` has entries.

Recovery:

- commit intended changes, or
- stash temporary changes, then rerun command.

## 2) Missing base/work branch

Symptoms:

- `epic-<feature>` or `<feature>/work` cannot be resolved.

Recovery:

1. `git fetch --all --prune`
2. Recreate local branch from remote if available:
   - `git branch <branch> origin/<branch>`
3. If missing remotely, stop and request branch bootstrap.

## 3) Detached HEAD

Symptoms:

- `git branch --show-current` empty.

Recovery:

- `git switch <feature>/work` (or another safe branch), then rerun.

## 4) `--force-with-lease` push rejected

Symptoms:

- push fails due to remote updates.

Recovery:

1. `git fetch --all --prune`
2. inspect who changed the branch
3. rerun publish/advance from fresh refs
4. if branch ownership conflict persists, coordinate with team before retry

## 5) Locked slice changed unexpectedly

Symptoms:

- a branch already merged into `epic-<feature>` moved unexpectedly.

Recovery:

1. restore the branch pointer from backup ref
2. push restored pointer with lease
3. rerun `stack status`

## 6) Wrong base used during publish

Symptoms:

- PR diffs include unrelated commits
- ancestry shape is incorrect

Recovery:

1. restore rewritten branches from backup refs
2. verify correct base head
3. rerun `stack publish <feature>`

## 7) Squash merge breaks ancestry check in advance

Symptoms:

- `merge-base --is-ancestor` fails for merged slice

Recovery:

1. verify merged state via PR metadata (`gh`)
2. use `--merged-branch` with verified branch
3. rebuild unlocked slices from `epic..<work>`

## 8) Tip and work trees diverged

Symptoms:

- `git diff <tip>..<feature>/work` is non-empty.

Recovery:

- if work is source of truth: rerun publish
- if tip is source of truth: reset work to tip and push with lease

Reminder:

- divergence does not imply future fixes should be placed on tip

## Last Resort: Reflog Recovery

If backup refs are missing:

1. inspect reflog:
   - `git reflog --date=iso`
2. identify last known good SHA
3. restore branch pointer to that SHA
4. push with `--force-with-lease`

Use hard reset only when rollback target is explicit and approved.

## Post-Recovery Validation

Always finish with:

1. `stack status <feature>`
2. verify merged slices remain intact on epic
3. verify tip equals work (or intentionally explain mismatch)
4. proceed with one next command only
