# Core Contract

Single source for placement, safety, and reporting rules.

## Branch Model

- base: `epic-<feature>`
- work: `<feature>/work`
- slices: ordered `slices[].branch_name` from repo-root `epic.yml`; the array may be empty before the first generated slice exists
- `work` is the only authoritative source of human-authored changes for the epic. Manual commits belong on `work`.
- `work` is a disposable assembly branch. Its commit history does not need to be the review narrative, and mixed commits are acceptable.
- slice branches are the durable review and merge units. Meaningful review history lives on slices, not on `work`.
- if a new human-authored commit is found on a slice branch, treat that as accidental authoring state: move the commit onto `work` before `generate`, then regenerate slices from `work`.
- only branches named in repo-root `epic.yml` are official slices.
- non-spec branches (for example `staging-*`, scratch, or experiment branches) are never authoritative epic state and must not be used as generate inputs.
- unlocked slices may be rewritten during `generate`; locked slices are immutable.

## Spec Contract

Repo-root `epic.yml` must define:

- `feature`, `base`, `work`
- `slices` as an array; use `slices: []` before the first generated slice exists
- ordered `slices[]` entries with `branch_name`, `intent` when official slices exist
- optional `upstream_base` metadata storing the branch that the epic `base` branch should rebase onto
- optional `generated_from_work_commit` metadata storing the full 40-character SHA from the `<feature>/work` commit used by the most recent successful `generate`

Validation rules:

- `slices` is an array
- `slices` may be empty before the first generated slice exists
- `branch_name` is unique
- `branch_name` starts with `<feature>/`
- `intent` is non-empty
- if `upstream_base` is present, it must be a non-empty branch ref string
- if `generated_from_work_commit` is present, it must be a full 40-character lowercase hex SHA

## Metadata Rules

- `epic.yml` is work-only metadata.
- It must exist at the repository root on `<feature>/work`.
- Create it as soon as the epic branches exist, even if no official slices have been generated yet.
- It must never be committed on slice branches.
- `upstream_base`, when present, is user-managed metadata describing the intended parent for rebasing the epic `base` branch.
- `generated_from_work_commit` is system-managed metadata.
- After each successful `generate`, it must be refreshed to the exact `<feature>/work` commit used as that generate run's source.
- Do not create or update a separate epic state file.

## Generate Truth

- After a `generate` action, the selected changes for the selected slice range must be reflected on the generated slice branches.
- `generate` may only source human-authored changes from `<feature>/work`, never from non-spec branches.
- After a successful `generate`, repo-root `epic.yml` on `<feature>/work` must record that source commit in `generated_from_work_commit`.
- Unrelated, future, or intentionally unassigned work may remain on `<feature>/work`.
- Any leftover or ambiguous non-metadata delta on `<feature>/work` must be reported explicitly.
- After a full regenerate through the tip slice, the tip slice should differ from `<feature>/work` only by work-only metadata.
- After a targeted regenerate, any remaining non-metadata diff between the tip slice and `<feature>/work` must be explained as intentional leftover future work or ambiguity.

## Upstream Base Metadata

- `upstream_base` is optional but recommended when the epic `base` branch is intended to stay rebased on another moving branch.
- When present, treat `upstream_base` as the preferred parent ref for rebasing `base` during epic maintenance.
- `upstream_base` does not make that branch an official slice and must not be treated as a generate input for slice content.

## Target Resolution

Resolve in order:

1. explicit user target (PR/branch/slice)
2. PR head branch (`gh pr view`) when the user points at a PR
3. likely slice suggestion from spec intent + changed hunks/paths + slice history

If explicit target exists, use it.

If the likely target is weak or there are multiple plausible slices, show the evidence, ask one direct question, and stop writes.

Do not silently place ambiguous work.

Question template:

"I think this belongs on `04-market-ui` because the patch matches that slice intent. If not, should it land on `03-market-api` instead?"

## Patch Partitioning

- Classify relevant `work` delta conservatively into:
  - target slice
  - descendant slices
  - ambiguous hunks
  - leftover future work
- Use slice intent, current branch state, and patch context. Do not assume a file belongs to exactly one slice.
- If ambiguous hunks would affect writes, ask before continuing or leave them on `work` and report them.

## Generate Scope Rules

- Default generate scope: target slice `N` plus unlocked descendants `N+1..tip`.
- Keep ancestors `1..N-1` unchanged unless the user explicitly asks to regenerate a wider unlocked range.
- When earlier slices are locked, start from the first unlocked slice in scope and regenerate remaining unlocked descendants in order.
- Never place `epic.yml` on a slice branch.
- Never pull slice content from branches that are not named in the spec.

## Locked Slices

A slice is locked when merged into base:

`git merge-base --is-ancestor <slice-branch> epic-<feature>`

Locked slices are immutable.

## Write Preflight (Required)

Run before `generate` and `clean`:

1. refresh refs (`git fetch origin --prune`; use `--all` only if needed)
2. ensure clean tree (`git status --porcelain` empty)
3. ensure non-detached HEAD
4. ensure base/work and any named or candidate target branches are visible
5. once target and scope are known, create backup refs for every branch pointer
   that may move

Dirty-tree policy:

- never discard user edits
- do not auto-stash, auto-clean, or auto-create a temporary worktree
- if the tree is dirty and safe writes would require switching branches or clearing unrelated edits, ask the user one direct question and stop before any write
- recommend stashing unrelated edits first and restoring them after the epic write; the alternate path is for the user to clean/remove those edits manually before continuing

## Automation Rules

- run git write automation non-interactively; avoid flows that require opening an editor or waiting on prompts
- use `GIT_EDITOR=true` for scripted `git rebase --continue`, `git cherry-pick --continue`, and similar continue steps unless the user explicitly wants to edit the message
- restack descendants with explicit old/new parent boundaries, for example `git rebase --onto <new-parent> <old-parent> <descendant>`
- do not use plain `git rebase <new-parent>` for stacked descendant restacks

Backup naming:

`backup/<feature>/<YYYYMMDD-HHMMSS>-<branch-slug>`

## Push And Validation Rules

- never use plain `--force`
- use `--force-with-lease` only for rewritten branches
- run repo validation gate on every changed branch (`yarn tsc` minimum; stricter
  repo gate wins)
- validation scope: generated target branch, rewritten descendants, newly created
  slices, and work if moved
- any failure blocks push and done state

## Standard Output

Always report:

1. resolved target or suggested target and evidence
2. changed/generated branches (target, descendants, untouched/locked)
3. leftover or ambiguous work still on `work`
4. invariant results (lock integrity, spec placement, validation scope/gate)
5. one next step
