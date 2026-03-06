# Workflows

Use these operation cards with `references/01-core-contract.md`.

## status (read-only)

Use for health checks and rewrite preview.

Steps:

1. `git fetch origin --prune`.
2. Resolve base/work and ordered slices from `.stack/<feature>/epic.yml`.
   - If spec is missing, discover `<feature>/*` branches and mark output partial.
3. Resolve tip slice and lock state.
4. If user provides PR/branch/slice hint, resolve target branch.
5. Build impact preview: target `N`, changed range `N..tip`, untouched `1..N-1`.
6. Report tip/work diff classification (empty, metadata-only, divergent) and
   `git diff --stat epic-<feature>..<feature>/work`.

Output:

- result (`pass`/`fail`)
- base/work refs + ordered slices + tip
- lock state
- target resolution (or ambiguity)
- impact preview
- invariant summary
- one next step

## plan (read-only)

Use to create or update `.stack/<feature>/epic.yml`.

Steps:

1. Ensure `.stack/<feature>/` exists.
2. If spec is missing, create from `assets/epic.template.yml`.
3. Validate required fields: `feature`, `base`, `work`, `slices[]`.
4. Validate each slice entry:
   - has `branch_name` and `intent`
   - `branch_name` is unique
   - `branch_name` starts with `<feature>/`
   - `intent` is non-empty

Output:

- result (`valid`/`invalid`)
- plan path used
- ordered slice table (`branch_name`, `intent`)
- validation issues and suggested patch when invalid

## review-fixes (write; default for PR feedback)

Use for review comments, PR feedback, or "fix slice X".

Steps:

1. Run write preflight.
2. Resolve target `N` in order:
   - explicit branch/slice in user text
   - explicit PR number -> PR head branch
   - best-effort mapping from spec intent + changed paths + history
   - if unresolved, ask one direct question and stop
3. If `N` is inferred, emit placement preview.
4. Switch to `<feature>/work`, implement fix, run validation gate, commit.
5. Run `publish` in `targeted` mode for range `N..tip`.
6. Validate invariants and validation gate on all changed branches.
7. Push safely (ff when possible, `--force-with-lease` only for rewrites).

Output:

- resolved target and evidence
- work commit and final landing slice
- changed branches (target + descendants)
- invariant + validation gate status
- one next step

## publish (write)

Use to rebuild stack from `<feature>/work`.

Modes:

- `full`: explicit user request to rebuild all unlocked slices
- `targeted`: update only `N..tip` (called by `review-fixes` and `advance`)

Steps:

1. Run write preflight.
2. Read ordered slices and mark locks.
3. Resolve run range:
   - `full` -> all unlocked slices
   - `targeted` -> `N..tip`
   - if `N` is inferred, emit placement report; if ambiguous, ask once and stop
4. Resolve path ownership from work diff + slice history + slice intent.
   - never assign `.stack/<feature>/epic.yml` to slices
   - fail on ambiguous or unassigned paths
5. Create backup refs for every branch pointer that may move.
6. Rebuild selected slices in spec order on temp branch:
   - skip slices outside run range
   - fail if locked slice is inside run range
   - for each writable slice: apply owned paths, remove deleted paths, commit if
     changes exist, move slice branch pointer
7. Validate invariants:
   - tip/work diff is metadata-only (`.stack/<feature>/epic.yml`)
   - locked slices unchanged
8. Run validation gate on every changed branch (`yarn tsc` minimum; include
   work if moved).
9. Push changed branches safely.
10. Optionally align `<feature>/work` to tip and restore work-only spec.

Output:

- result (`pass`/`fail`)
- mode + run range
- changed branches (old/new heads)
- locked branches untouched
- ownership issues (if any)
- invariant + validation gate status
- one next step

Placement report format (inferred `N` only):

1. change being placed
2. mapping evidence
3. chosen target `N`
4. restack scope `N+1..tip`

## advance (write)

Use after a slice merges into base and descendants must move forward.

Steps:

1. Run write preflight.
2. Resolve merged boundary `N` in spec order.
3. Verify merge proof:
   - ancestry check: `git merge-base --is-ancestor <merged-branch> epic-<feature>`
   - fallback for squash: verify merged PR state via `gh`
4. Lock range `1..N`.
5. Run `publish` in `targeted` mode for range `N+1..tip`.
6. Align work to tip + work-only spec if needed.
7. Optionally retarget immediate next PR base.

Output:

- result (`pass`/`fail`)
- newly locked slices
- changed descendant branches
- work alignment status
- optional PR retarget actions
- one next step

## clean (write)

Use when epic is complete and disposable branches should be removed.

Preconditions:

- write preflight passes
- intended slices are merged into `epic-<feature>`
- `git diff --name-only epic-<feature>..<feature>/work` is empty or metadata-only

Steps:

1. Verify completion state and diff class.
2. If non-metadata files differ, stop and recommend `publish` or `advance`.
3. Create backup refs for branches that may be deleted.
4. Delete work branch (remote, then local).
5. Optionally delete slice branches per team policy.
6. Optionally keep or remove `.stack/<feature>/epic.yml`.

Output:

- result (`pass`/`fail`)
- work branch deletion status
- slice cleanup status
- spec cleanup status
- residual manual actions
