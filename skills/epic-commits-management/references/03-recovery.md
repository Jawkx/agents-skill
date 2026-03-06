# Recovery

Use only when `generate` or `clean` fails, placement is wrong, or rollback is needed.

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

Wrong target chosen:

- restore wrongly updated branches if needed
- rerun `generate` with explicit target

Dirty tree blocks preflight:

- commit/stash, or run writes from temporary worktree

Missing base/work branch:

- `git fetch origin --prune`
- recreate local branch from `origin/<branch>` when available
- if missing remotely, stop and request bootstrap

Detached HEAD:

- switch to safe branch (`<feature>/work` or intended slice branch) and rerun

`--force-with-lease` rejected:

- fetch latest refs
- inspect remote updates
- rerun from fresh refs

Locked slice changed unexpectedly:

- restore from backup
- push restored pointer with lease
- rerun `status`

Wrong generate result:

- restore rewritten branches from backups
- verify base and target
- rerun `status` to inspect target suggestion and leftover work
- rerun `generate` with explicit target or narrower scope

Squash merge makes lock boundary unclear:

- verify merged PR metadata via `gh`
- rerun `generate` after confirming the first unlocked slice

Unexpected leftover work on `work`:

- classify remaining delta with `status`
- rerun `generate` with explicit target if it should land on slices
- otherwise leave it on `work` and report it as future work

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
3. verify changed branches match the intended slice range
4. verify any leftover or unassigned work on `work` is explained
5. propose one next step
