# Recovery

Use only when a write workflow fails, placement is wrong, or rollback is needed.

## Immediate Actions

1. Stop further writes.
2. Capture state:
   - `git status -sb`
   - current branch
   - failing command and output
3. Locate backup refs for affected branches.

## Fast Rollback

When branch pointers must be restored:

1. Find backup ref:
   - `backup/<feature>/<timestamp>-<branch-slug>`
2. Restore local pointer:
   - `git branch -f <branch> backup/<feature>/<timestamp>-<branch-slug>`
3. Push with lease:
   - `git push --force-with-lease origin <branch>`
4. Re-run `status` from `references/02-workflows.md`.

## Failure Matrix

Wrong slice placement:

- restore wrongly updated branches if needed
- rerun `review-fixes` with explicit target

Dirty tree blocks preflight:

- commit/stash, or run writes from temporary worktree

Missing base/work branch:

- `git fetch origin --prune`
- recreate local branch from `origin/<branch>` when available
- if missing remotely, stop and request bootstrap

Detached HEAD:

- switch to safe branch (`<feature>/work` or target branch) and rerun

`--force-with-lease` rejected:

- fetch latest refs
- inspect remote updates
- rerun from fresh refs

Locked slice changed unexpectedly:

- restore from backup
- push restored pointer with lease
- rerun `status`

Wrong base used in publish:

- restore rewritten branches from backups
- verify base
- rerun `publish`

Squash merge breaks ancestry check in advance:

- verify merged PR metadata via `gh`
- rerun `advance` with verified merged branch

Tip/work diverged:

- expected steady state is metadata-only diff (`.stack/<feature>/epic.yml` only)
- if non-metadata files differ: rerun `publish`
- if work is missing spec: restore `.stack/<feature>/epic.yml` on work and commit

## Last Resort: Reflog

If backups are missing:

1. `git reflog --date=iso`
2. identify last good SHA
3. restore branch pointer
4. push with `--force-with-lease`

Use hard reset only with explicit user approval.

## Post-Recovery Checks

1. run `status`
2. verify locked slices intact
3. verify or explain tip/work metadata-only diff
4. propose one next step
