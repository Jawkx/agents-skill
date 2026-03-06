# Core Contract

Single source for placement, safety, and reporting rules.

## Branch Model

- base: `epic-<feature>`
- work: `<feature>/work`
- slices: ordered `slices[].branch_name` from `.stack/<feature>/epic.yml`

## Spec Contract

`.stack/<feature>/epic.yml` must define:

- `feature`, `base`, `work`
- ordered `slices[]` entries with `branch_name`, `intent`

Validation rules:

- `branch_name` is unique
- `branch_name` starts with `<feature>/`
- `intent` is non-empty

## Metadata Rules

- `.stack/<feature>/epic.yml` is work-only metadata.
- It must exist on `<feature>/work`.
- It must never be committed on slice branches.
- Do not create or update `.stack/<feature>/state.json`.
- Post-write check: `git diff --name-only <tip-slice>..<feature>/work` must be
  exactly `.stack/<feature>/epic.yml` (except `clean`, where work may be
  removed).

## Target Resolution

Resolve in order:

1. explicit user target (PR/branch/slice)
2. PR head branch (`gh pr view`)
3. best-effort mapping from spec intent + changed paths + slice history

If unresolved, ask one direct question and stop writes.

Question template:

"I cannot resolve the landing slice from context. Should this fix land on `04` or `05`?"

## Scope Rules

Default targeted mode (`review-fixes`, `advance` follow-up):

- update target slice `N`
- restack descendants `N+1..tip`
- keep ancestors `1..N-1` unchanged

Full publish mode (explicit rebuild request):

- unlocked slices may all be rewritten in spec order

## Locked Slices

A slice is locked when merged into base:

`git merge-base --is-ancestor <slice-branch> epic-<feature>`

Locked slices are immutable.

## Write Preflight (Required)

Run before `review-fixes`, `publish`, `advance`, and `clean`:

1. refresh refs (`git fetch origin --prune`; use `--all` only if needed)
2. ensure clean tree (`git status --porcelain` empty)
3. ensure non-detached HEAD
4. ensure base/work/target visibility
5. create backup refs for every branch pointer that may move

Dirty-tree policy:

- never discard user edits
- if edits must be preserved, run writes from a temporary worktree under repo
  parent
- avoid `/tmp` unless user explicitly asks

Backup naming:

`backup/<feature>/<YYYYMMDD-HHMMSS>-<branch-slug>` (`/` becomes `--`)

## Push And Validation Rules

- never use plain `--force`
- use `--force-with-lease` only for rewritten branches
- run repo validation gate on every changed branch (`yarn tsc` minimum; stricter
  repo gate wins)
- validation scope: target branch, rewritten descendants, and work if moved
- any failure blocks push and done state

## Standard Output

Always report:

1. resolved target and evidence
2. changed branches (target, descendants, untouched/locked)
3. invariant results (metadata diff, lock integrity, validation gate)
4. one next step
