# Workflows

Use these operation cards with `references/01-core-contract.md`.

## status (read-only)

Use for health checks, target suggestion, and `generate` preview.

Steps:

1. `git fetch origin --prune`.
2. Resolve base/work and ordered slices from `.stack/<feature>/epic.yml`.
   - If spec is missing, discover `<feature>/*` branches and mark output partial.
3. Resolve lock state for every slice and identify the first unlocked slice.
4. Inspect current delta on `<feature>/work`:
   - summarize `git diff --stat epic-<feature>..<feature>/work`
   - note whether the delta looks targeted, mixed across slices, ambiguous, or
     like leftover future work
5. Resolve the current official tip slice from the spec and compare it with `<feature>/work`:
   - expect only work-only metadata after a clean full regenerate
   - treat non-metadata diff as leftover work, stale slices, or a broken invariant
6. If user provides PR/branch/slice hint, resolve target from that context.
   Otherwise suggest likely target slices with evidence and confidence.
7. Preview what `generate` would touch:
   - target slice
   - unlocked descendants that would restack
   - missing slice branches that would be created
   - locked slices that would remain untouched
8. Report ambiguity, leftovers, invariant violations, or missing data that would block a safe write.

Output:

- result (`pass`/`partial`/`fail`)
- base/work refs + ordered slices
- lock state
- current `work` delta summary
- tip-slice vs `work` invariant summary
- likely target suggestion(s) and evidence
- `generate` impact preview
- ambiguity / leftover notes
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

## generate (write)

Use for the main write action:

- create missing slice branches from spec
- place or replace selected `work` changes onto a target slice
- regenerate unlocked descendants when restacking is needed
- continue after earlier slices merge into base
- handle PR feedback, "fix slice X", "rebuild stack", or "regenerate from work"

Steps:

1. Run write preflight.
2. Resolve base, `work`, ordered slices, and lock state.
3. If newly authored commits are sitting on a slice branch instead of `work`, stop treating that slice branch as the source of truth:
   - move the commit(s) onto `<feature>/work` first (for example via cherry-pick)
   - continue `generate` from `work`, not from the accidentally authored slice branch
4. Inspect relevant delta on `<feature>/work` for the selected task:
   - summarize the current patch/hunk mix
   - note locked boundary, missing branches, and candidate descendants
   - ignore non-spec branches as sources of truth, even if they contain newer-looking work
5. Resolve target:
   - explicit branch/slice/PR hint wins
   - otherwise suggest a likely target with evidence from spec intent + changed
     hunks/paths + slice history
6. If target is ambiguous, ask one direct question and stop before any write.
7. Partition the relevant `work` delta conservatively into:
   - target slice
   - descendant slices
   - ambiguous hunks that need user confirmation
   - leftover future work that should stay on `work`
8. Update slices in spec order without touching locked slices:
   - keep ancestors before the target unchanged unless the user explicitly asked
     for a wider unlocked regenerate
   - create missing unlocked slice branches when needed
   - source changes from `work` only
   - update the target slice first
   - regenerate unlocked descendants when their base changed or when their
     partitioned patch changes
   - when descendant restacks are needed, record each descendant's old parent
     and restack with explicit boundaries such as
     `git rebase --onto <new-parent> <old-parent> <descendant>`
   - when continue steps are needed during automation, run them non-interactively
     with `GIT_EDITOR=true`
   - if earlier slices are already locked, continue from the first unlocked slice
     that needs regeneration
9. Validate changed branches:
   - locked slices unchanged
   - `.stack/<feature>/epic.yml` stays off slices
   - selected slice range reflects the generated patch
   - run repo validation gate on changed branches and `work` if moved
10. Push safely:
    - fast-forward when possible
    - use `--force-with-lease` only for rewritten branches
11. Report generated branches, locked untouched branches, and any leftover or
    ambiguous work still on `<feature>/work`.

Notes:

- `generate` is the only user-facing write workflow; internal cases such as
  review fixes, restacks after merges, or full unlocked regenerates all use this
  flow.
- A non-spec branch may be useful during investigation, but it must never override
  `work` as the canonical input to `generate`.
- Do not claim perfect automatic placement. If patch partitioning is weak, stop
  and ask.

Output:

- result (`pass`/`fail`)
- resolved target and evidence
- changed/generated branches (new slices, rewritten descendants,
  locked untouched)
- leftover or ambiguous `work` delta
- invariant + validation summary
- one next step

## clean (write)

Use when epic is complete and disposable branches should be removed.

Preconditions:

- write preflight passes
- branches intended for deletion are merged into `epic-<feature>` or the user
  explicitly accepts deleting only disposable local state
- current `work` delta has no unreported slice-worthy changes, or those changes
  are intentionally abandoned and called out

Steps:

1. Verify completion state and summarize any remaining non-spec delta on
   `<feature>/work`.
2. If unpublished or ambiguous work remains, stop and recommend `generate` or
   manual archival before cleanup.
3. Create backup refs for branches that may be deleted.
4. Delete work branch (remote, then local).
5. Optionally delete slice branches per team policy.
6. Optionally keep or remove `.stack/<feature>/epic.yml`.

Output:

- result (`pass`/`fail`)
- work branch deletion status
- slice cleanup status
- remaining work/spec status
- residual manual actions
