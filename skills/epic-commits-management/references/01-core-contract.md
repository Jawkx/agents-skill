# Core Contract

Single source for placement, safety, and reporting rules.

## Branch Model

- base: `epic-<feature>`
- work: `<feature>/work`
- slices: ordered `slices[].branch_name` from `.stack/<feature>/epic.yml`
- `work` is the only authoritative source of human-authored changes for the epic. Manual commits belong on `work`.
- `work` is a disposable assembly branch. Its commit history does not need to be the review narrative, and mixed commits are acceptable.
- slice branches are the durable review and merge units. Meaningful review history lives on slices, not on `work`.
- only branches named in `.stack/<feature>/epic.yml` are official slices.
- non-spec branches (for example `staging-*`, scratch, or experiment branches) are never authoritative epic state and must not be used as generate inputs.
- unlocked slices may be rewritten during `generate`; locked slices are immutable.

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

## Generate Truth

- After a `generate` action, the selected changes for the selected slice range must be reflected on the generated slice branches.
- `generate` may only source human-authored changes from `<feature>/work`, never from non-spec branches.
- Unrelated, future, or intentionally unassigned work may remain on `<feature>/work`.
- Any leftover or ambiguous non-metadata delta on `<feature>/work` must be reported explicitly.
- After a full regenerate through the tip slice, the tip slice should differ from `<feature>/work` only by work-only metadata.
- After a targeted regenerate, any remaining non-metadata diff between the tip slice and `<feature>/work` must be explained as intentional leftover future work or ambiguity.

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
- Never place `.stack/<feature>/epic.yml` on a slice branch.
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
