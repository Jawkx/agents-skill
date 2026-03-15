# Workflows

Use these operation cards with `references/01-core-contract.md`.

## status (read-only)

Use for health checks, target suggestion, and `generate` preview.

Steps:

1. `git fetch origin --prune`.
2. Resolve base/work, optional `upstream_base`, ordered branches, and any `generated_from_work_commit` value from repo-root `epic.yml`.
   - If spec is missing, discover `<feature>/*` branches and mark output partial.
3. Resolve lock state for every official branch and identify the first unlocked branch.
4. Inspect current delta on `<feature>/work`:
   - summarize `git diff --stat epic-<feature>..<feature>/work`
   - note whether the delta looks targeted, mixed across branches, ambiguous, or
     like leftover future work
5. Resolve the current official tip branch from the spec and compare it with `<feature>/work`:
   - expect only work-only metadata after a clean full regenerate
   - treat non-metadata diff as leftover work, stale branches, or a broken invariant
6. Compare `generated_from_work_commit` with the current full SHA of `<feature>/work` HEAD:
   - report whether the metadata is missing, current, or stale
   - a matching SHA proves the latest successful `generate` used the current `work` HEAD, but targeted generates may still leave intentional future work on `work`
7. If user provides PR/branch hint, resolve target from that context.
   Otherwise suggest likely target branches with evidence and confidence.
8. Preview what `generate` would touch:
   - target branch
   - unlocked descendants that would restack
   - missing review branches that would be created
   - locked branches that would remain untouched
9. Report ambiguity, leftovers, invariant violations, or missing data that would block a safe write.

Output:

- result (`pass`/`partial`/`fail`)
- base/work refs + optional `upstream_base` + ordered branches
- lock state
- current `work` delta summary
- tip-branch vs `work` invariant summary
- `generated_from_work_commit` status (`missing`/`current`/`stale`) and recorded SHA when present
- likely target suggestion(s) and evidence
- `generate` impact preview
- ambiguity / leftover notes
- one next step

## plan (read-only)

Use to create or update repo-root `epic.yml`.

Steps:

1. Use repo-root `epic.yml` as the spec path.
2. If spec is missing, create from `assets/epic.template.yml`.
3. Validate required fields: `feature`, `base`, `work`, `branches`.
   - `branches` must be an array and may be empty before the first generated branch exists
   - if `upstream_base` is present, validate it as a non-empty branch ref string
   - treat `generated_from_work_commit` as optional system-managed metadata
4. Validate each branch entry when `branches` is non-empty:
   - has `branch_name` and `intent`
   - `branch_name` is unique
   - `branch_name` starts with `<feature>/`
   - `intent` is non-empty
5. If `generated_from_work_commit` is present, validate it as a full 40-character lowercase hex SHA.

Output:

- result (`valid`/`invalid`)
- plan path used
- base/work refs + optional `upstream_base`
- ordered branch table (`branch_name`, `intent`)
- validation issues and suggested patch when invalid

## generate (write)

Use for the main write action:

- create missing review branches from spec
- place or replace selected `work` changes onto a target branch
- regenerate unlocked descendants when restacking is needed
- continue after earlier branches merge into base
- handle PR feedback, "fix branch X", "rebuild stack", or "regenerate from work"

Steps:

1. Run write preflight.
2. Resolve base, `work`, optional `upstream_base`, ordered branches, and lock state.
   - If `branches` is empty, stop and report that the epic metadata exists but no official branches have been defined yet.
3. If newly authored commits are sitting on a review branch instead of `work`, stop treating that review branch as the source of truth:
   - move the commit(s) onto `<feature>/work` first (for example via cherry-pick)
   - continue `generate` from `work`, not from the accidentally authored review branch
4. Capture the exact full SHA of `<feature>/work` HEAD that will act as the source commit for this generate run.
5. Inspect relevant delta on `<feature>/work` for the selected task:
   - summarize the current patch/hunk mix
   - note locked boundary, missing branches, and candidate descendants
   - ignore non-spec branches as sources of truth, even if they contain newer-looking work
6. Resolve target:
   - explicit branch/PR hint wins
   - otherwise suggest a likely target with evidence from spec intent + changed
     hunks/paths + branch history
7. If target is ambiguous, ask one direct question and stop before any write.
8. Partition the relevant `work` delta conservatively into:
   - target branch
   - descendant branches
   - ambiguous hunks that need user confirmation
   - leftover future work that should stay on `work`
9. Update branches in spec order without touching locked branches:
   - keep ancestors before the target unchanged unless the user explicitly asked
     for a wider unlocked regenerate
   - create missing unlocked review branches when needed
   - source changes from `work` only
   - update the target branch first
   - regenerate unlocked descendants when their base changed or when their
     partitioned patch changes
   - when descendant restacks are needed, record each descendant's old parent
     and restack with explicit boundaries such as
     `git rebase --onto <new-parent> <old-parent> <descendant>`
   - when continue steps are needed during automation, run them non-interactively
     with `GIT_EDITOR=true`
   - if earlier branches are already locked, continue from the first unlocked branch
     that needs regeneration
10. Refresh repo-root `epic.yml` on `<feature>/work`:
   - set `generated_from_work_commit` to the full 40-character SHA of the exact `<feature>/work` commit used as the source for this generate run
   - keep that metadata on `work` only and off review branches

11. Validate changed branches:
   - locked branches unchanged
   - `epic.yml` stays off review branches
   - `generated_from_work_commit` matches the source `work` SHA from this generate run
   - selected branch range reflects the generated patch
   - run repo validation gate on changed branches and `work` if moved

12. Push safely:
   - fast-forward when possible
   - use `--force-with-lease` only for rewritten branches

13. Report generated branches, locked untouched branches, and any leftover or
   ambiguous work still on `<feature>/work`.

Notes:

- `generate` is the only user-facing write workflow; internal cases such as
  review fixes, restacks after merges, or full unlocked regenerates all use this
  flow.
- If the operation includes rebasing the epic `base` branch itself and `upstream_base` is present, prefer that recorded parent ref over guesswork.
- A non-spec branch may be useful during investigation, but it must never override
  `work` as the canonical input to `generate`.
- `generated_from_work_commit` is refreshed after every successful `generate`, including targeted runs.
- Do not claim perfect automatic placement. If patch partitioning is weak, stop
  and ask.

Output:

- result (`pass`/`fail`)
- resolved target and evidence
- changed/generated branches (new branches, rewritten descendants,
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
- current `work` delta has no unreported branch-worthy changes, or those changes
  are intentionally abandoned and called out

Steps:

1. Verify completion state and summarize any remaining non-spec delta on
   `<feature>/work`.
2. If unpublished or ambiguous work remains, stop and recommend `generate` or
   manual archival before cleanup.
3. Create backup refs for branches that may be deleted.
4. Delete work branch (remote, then local).
5. Optionally delete review branches per team policy.
6. Optionally keep or remove repo-root `epic.yml`.

Output:

- result (`pass`/`fail`)
- work branch deletion status
- branch cleanup status
- remaining work/spec status
- residual manual actions
