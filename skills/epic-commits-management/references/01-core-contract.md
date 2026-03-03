# Core Contract

Single policy source for placement, restacking, safety, and reporting.

## Branch Model

- base: `epic-<feature>`
- work: `<feature>/work`
- slices: ordered `slices[].branch_name` in `.stack/<feature>/epic.yml`

## Epic Spec Requirements

The spec file must contain:

- `feature`, `base`, `work`
- ordered `slices[]` entries with `branch_name`, `intent`

Validation rules:

- `branch_name` is unique
- `branch_name` starts with `<feature>/`
- `intent` is non-empty

## Target Resolution

Resolve landing branch in this order:

1. explicit user target (PR/branch/slice)
2. PR head branch (`gh pr view`)
3. deterministic mapping from spec + changed paths

If unresolved, ask one direct question and stop writes.

Question template:

"I cannot resolve the landing slice from context. Should this fix land on `04` or `05`?"

## Review-Fix Placement Mode (Work-First)

For `review-fixes` workflows:

1. resolve target slice `N` first (using Target Resolution above)
2. make the code change and commit on `<feature>/work`
3. regenerate/restack so that commit lands on slice `N`
4. rewrite only descendants `N+1..tip`
5. align `<feature>/work` to tip after regeneration

Direct commits to non-work slices are allowed only when user explicitly asks for
that override.

## Generate/Regenerate Placement Report

For `generate`/`regenerate` without an explicit target, emit a placement report
before any write:

1. commits being placed
2. mapping evidence
3. chosen landing slice `N`
4. rewrite scope `N+1..tip`

If placement is ambiguous, ask once and stop writes.

## Restack Scope

After placing/changing slice `N`:

- keep the fix on `N`
- rewrite only descendants `N+1..tip`
- never rewrite ancestors `1..N-1`

If `N` is tip, descendants are empty.

## Locked Slices

A slice is locked if merged into base:

`git merge-base --is-ancestor <slice-branch> epic-<feature>`

Locked slices are immutable.

## Mandatory Write Preflight

Run before `review-fixes`, `publish`, `advance`, and `clean`:

1. refresh refs (`git fetch origin --prune`; use `--all` only when needed)
2. ensure clean tree (`git status --porcelain` empty)
3. ensure non-detached HEAD
4. ensure base/work/target branch visibility
5. create backup refs for every branch pointer that may move

Dirty-tree policy:

- never discard user edits
- if edits must be preserved, run writes from a temporary worktree under repo
  parent
- avoid `/tmp` unless user explicitly requests it

Backup naming:

`backup/<feature>/<YYYYMMDD-HHMMSS>-<branch-slug>` (`/` becomes `--`)

## Push Safety

- never use plain `--force`
- use `--force-with-lease` for rewritten branches only

## Cross-Branch Typecheck Gate (Required)

When a workflow creates or rewrites commits (`review-fixes`, `publish`,
`advance`), run typecheck on every changed branch before finalizing.

- default command: `yarn tsc`
- if repo defines a stricter required command, run that instead

Scope:

1. target branch with new commit(s)
2. every rewritten descendant branch (`N+1..tip`)
3. `<feature>/work` if repointed/rebased

Failure policy:

- any failure blocks push and blocks "done" state
- place the fix on the earliest failing slice, then restack descendants again
- rerun typecheck gate until all changed branches pass

## Post-Write Invariants

1. slice ancestry follows spec order
2. `tree(tip) == tree(work)` after publish/restack
3. locked slices are unchanged
4. every rewritten branch passes repo validation gate
5. cross-branch typecheck gate passed for all changed branches

`tip == work` is validation only, never placement policy.

## Standard Output

Always report:

1. resolved target and evidence
2. changed branches (target, descendants, untouched)
3. invariant results
4. one next step
