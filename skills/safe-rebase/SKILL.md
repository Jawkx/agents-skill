---
name: safe-rebase
description: Safe git rebasing with backups and recovery. Use when Codex needs to rebase a branch, rewrite history, resolve rebase conflicts, or force-push after a rebase while preserving a rollback path (backup branch/tag or reflog).
---

# Safe Rebase

## Workflow

- Confirm the target branch and base to rebase onto (e.g., `feature/foo` onto `origin/main`).
- Ensure a clean working tree; commit or stash any local changes.
- Fetch latest refs from remotes.
- Verify the branch and upstream (avoid rebasing the wrong branch).
- Create a backup reference before rebasing.
- Rebase (standard or `--rebase-merges` depending on merge commits).
- Resolve conflicts and continue or abort.
- Run the project’s relevant tests or checks.
- Push safely with `--force-with-lease` if the branch exists on a remote.

## Preflight Checks

- Run `git status -sb` and confirm the current branch.
- Run `git fetch --all --prune` before rebasing onto remote bases.
- Identify merge commits (if any) to decide on `--rebase-merges`.

## Backup Before Rebase

- Create a backup branch at current HEAD:
  - `git branch backup/<branch>-<timestamp>`
- Optionally add a backup tag for extra safety:
  - `git tag backup/<branch>-<timestamp>`
- Use a timestamp like `YYYYMMDD-HHMM` to keep backups unique.

## Rebase Execution

- Standard rebase:
  - `git rebase <base>`
- Preserve merge commits if needed:
  - `git rebase --rebase-merges <base>`
- Use interactive rebase only when history edits are required:
  - `git rebase -i <base>`

## Conflict Handling

- Use `git status` to see conflicted files.
- Edit, then `git add <files>` and `git rebase --continue`.
- If needed, abort safely:
  - `git rebase --abort`
- If stuck mid-rebase, check current patch:
  - `git rebase --show-current-patch`

## Push Safety

- If the branch is on a remote, force-push only with lease:
  - `git push --force-with-lease`
- If the branch is shared, confirm with the user before rewriting history.

## Recovery

- To restore the pre-rebase state:
  - `git switch <branch>`
  - `git reset --hard backup/<branch>-<timestamp>`
  - `git push --force-with-lease` (only if the remote was updated)
- If backups are missing, use reflog to find the previous HEAD.

## Notes

- Prefer rebasing onto `origin/main` (or the authoritative remote base) rather than a possibly stale local branch.
- Keep backup refs until the rebase is validated and merged.
