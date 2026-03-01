# Recovery Reference

Use this only when a write command fails, placement is wrong, or rollback is
required.

## Immediate Actions

1. Stop further writes.
2. Capture state:
   - `git status -sb`
   - current branch
   - failing command + output
3. Find backup refs.

## Fast Rollback

When branch pointers must be restored:

1. Locate backup ref:
   - `backup/<feature>/<timestamp>-<branch-slug>`
2. Restore local pointer:
   - `git branch -f <branch> backup/<feature>/<timestamp>-<branch-slug>`
3. Push safely:
   - `git push --force-with-lease origin <branch>`
4. Re-run diagnosis:
   - `stack status <feature>`

## Failure Matrix

### Wrong slice placement

- restore wrongly updated branch if needed
- apply fix on correct slice
- restack descendants only

### Dirty tree blocks preflight

- commit/stash, or run writes from temporary worktree

### Missing base/work branch

- `git fetch origin --prune`
- recreate local branch from `origin/<branch>` when available
- if missing remotely, stop and request bootstrap

### Detached HEAD

- switch to safe branch (`<feature>/work` or target branch) and rerun

### `--force-with-lease` rejected

- fetch latest refs
- inspect remote updates
- rerun command from fresh refs

### Locked slice changed unexpectedly

- restore from backup
- push restored pointer with lease
- re-run `stack status`

### Wrong base used in publish

- restore rewritten branches from backups
- verify base
- rerun `stack publish <feature>`

### Squash merge breaks ancestry check in advance

- verify merged PR metadata via `gh`
- rerun advance with verified merged branch

### Tip/work diverged

- if work is source of truth: rerun publish
- if tip is source of truth: reset work to tip and push with lease

## Last Resort: Reflog

If backups are missing:

1. `git reflog --date=iso`
2. identify last good SHA
3. restore branch pointer
4. push with `--force-with-lease`

Use hard reset only with explicit user approval.

## Post-Recovery Checks

1. run `stack status <feature>`
2. verify locked slices remain intact
3. verify or explicitly explain `tip == work`
4. propose one next command
