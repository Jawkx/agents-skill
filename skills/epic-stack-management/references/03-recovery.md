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

- ask the user how to clear the dirty state before any write
- recommend stashing unrelated edits first and restoring them later
- alternate path: the user cleans/removes the unrelated edits manually
- do not auto-stash, auto-discard edits, or auto-create a temporary worktree

Interactive editor blocks `--continue`:

- rerun with `GIT_EDITOR=true git rebase --continue` or
  `GIT_EDITOR=true git cherry-pick --continue`
- only open an editor if the user explicitly wants to edit the message

Wrong-branch authored commit:

- identify the newly authored commit(s) on the review branch
- cherry-pick them onto `<feature>/work`
- restore the wrongly-authored branch from backup if needed, or rerun `generate`
  so branches are rebuilt from `work`
- continue from `work`, not from the accidentally-authored review branch

Missing base/work branch:

- `git fetch origin --prune`
- recreate local branch from `origin/<branch>` when available
- if missing remotely, stop and request bootstrap

Detached HEAD:

- switch to safe branch (`<feature>/work` or intended review branch) and rerun

`--force-with-lease` rejected:

- fetch latest refs
- inspect remote updates
- rerun from fresh refs

Locked branch changed unexpectedly:

- restore from backup
- push restored pointer with lease
- rerun `status`

Wrong generate result:

- restore rewritten branches from backups
- verify base and target
- rerun `status` to inspect target suggestion and leftover work
- rerun `generate` with explicit target or narrower scope

Descendant restack replays old parent commits:

- inspect the stopped commit and decide whether it belongs to the replaced parent
  branch or the descendant's unique work
- if it is a duplicate ancestor commit, `git rebase --skip`
- if restarting the restack, prefer
  `git rebase --onto <new-parent> <old-parent> <descendant>` over plain
  `git rebase <new-parent>`

Squash merge makes lock boundary unclear:

- verify merged PR metadata via `gh`
- rerun `generate` after confirming the first unlocked branch

Unexpected leftover work on `work`:

- classify remaining delta with `status`
- rerun `generate` with explicit target if it should land on branches
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
2. verify locked branches intact
3. verify changed branches match the intended branch range
4. verify any leftover or unassigned work on `work` is explained
5. propose one next step
