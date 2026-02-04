---
name: gwq
description: Guide for using gwq cli, a tool for managing git worktrees. This skill should be used when user ask you to work with git worktree
---

Use `gwq` to manage Git worktrees efficiently from the command line: create isolated workspaces, switch between them, run commands inside them, inspect status, and clean them up safely.


## Creating worktrees

### Create a new worktree with a new branch

Use when starting new work.

```
gwq add -b <branch-name>
```

### Create a worktree from an existing branch

```
gwq add <branch-name>
```

### Interactive selection

Use when unsure of branch name.

```
gwq add -i
```

### Create and immediately switch into it

```
gwq add -s <branch-name>
```

Branch names should be descriptive (e.g. `feature/auth`, `fix/login-bug`).

---

## Discovering existing worktrees

### List worktrees

```
gwq list
```

### Verbose output

```
gwq list -v
```

### Machine-readable output

```
gwq list --json
```

### Show worktrees across all repositories

```
gwq list -g
```

---

## Navigating worktrees

### Get a worktree path (preferred)

```
cd $(gwq get <pattern>)
```

### Global lookup (when outside the repo)

```
cd $(gwq get -g <repo>:<pattern>)
```

### Change directory interactively (spawns a subshell)

```
gwq cd
```

Use `gwq get` over `gwq cd` when scripting or avoiding nested shells.

---

## Running commands inside a worktree

Use this to run tests, builds, or scripts without manually switching directories.

```
gwq exec <pattern> -- <command>
```

Example:

```
gwq exec feature-auth -- npm test
```

### Run and stay inside the worktree

```
gwq exec -s <pattern> -- <command>
```

---

## Monitoring status

Use this to see which worktrees are dirty or recently changed.

### Show status table

```
gwq status
```

### Live-updating view

```
gwq status --watch
```

### Filter or sort results

```
gwq status --filter <value>
```

```
gwq status --sort <value>
```

### Export status

```
gwq status --json
```

```
gwq status --csv
```

---

## Removing worktrees (cleanup)

### Preview removal (recommended first)

```
gwq remove --dry-run <pattern>
```

### Remove a worktree

```
gwq remove <pattern>
```

### Interactive removal

```
gwq remove
```

### Remove worktree and delete its branch

```
gwq remove -b <pattern>
```

### Force delete an unmerged branch (last resort)

```
gwq remove -b --force-delete-branch <pattern>
```

Only use forced deletion when you explicitly intend permanent loss.

---

## Maintenance

### Prune stale worktrees

Use when directories were deleted manually or paths are invalid.

```
gwq prune
```

## Guardrails

* Do not reuse worktrees for unrelated tasks.
* Do not delete branches unless explicitly requested.
* Prefer `--dry-run` before any destructive action.
* If a worktree already exists for a branch, reuse it instead of creating another.
