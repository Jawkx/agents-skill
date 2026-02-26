# Command Reference: stack publish

Command:

```bash
stack publish <feature>
```

## Goal

Generate or update slice branches so the tip slice tree equals `<feature>/work`, without rewriting locked slices.

MVP default is `rebuild` mode.

## Inputs

- base: `epic-<feature>`
- work: `<feature>/work`
- plan: `.stack/<feature>/plan.yml`
- state: `.stack/<feature>/state.json` (if present)

## Detailed Procedure

### 1) Run mandatory preflight

Run the shared preflight from `01-core-contract.md`.

If preflight fails, stop.

### 2) Load plan and state

1. Parse plan slices in ascending `id` order.
2. Read locked IDs from state (default empty).
3. Validate that each locked slice appears merged into `epic-<feature>`.
   - `git merge-base --is-ancestor <locked-branch> epic-<feature>`
4. If a locked slice is not merged, stop and require manual recovery.

### 3) Compute changed paths and ownership

1. Get diff entries from `epic..<work>`:
   - `git diff --name-status --no-renames epic-<feature>..<feature>/work`
2. Assign every path to exactly one slice using plan globs.
3. Fail on:
   - unassigned path
   - ambiguous path

Include actionable suggestions in the failure report.

### 4) Prepare rewrite backups

Create backup refs for each branch that may move:

- all unlocked slice branches that already exist
- `<feature>/work` if it will be repointed

### 5) Build stack on a temp branch

1. Create temp build branch from base:
   - `git switch -c .tmp/epic-helpers/<feature>/<timestamp> epic-<feature>`
2. Iterate slices in `id` order.

For each slice:

- If locked:
  - do not modify branch
  - continue

- If unlocked:
  1. Apply assigned paths from work to current temp HEAD.
     - existing-at-work paths: `git checkout <feature>/work -- <path>`
     - deleted-at-work paths: `git rm --ignore-unmatch -- <path>`
  2. Stage: `git add -A`
  3. If there are staged changes:
     - `git commit -m "<NN>: <intent>"`
  4. If no staged changes:
     - keep current HEAD and mark slice as `empty=true`
  5. Point slice branch to current HEAD:
     - `git branch -f <feature>/<NN>-<branch_suffix> HEAD`

### 6) Validate final invariants

1. Resolve tip as highest slice ID from plan.
2. Verify tip equals work:
   - `git diff --quiet <tip-slice>..<feature>/work`
3. If mismatch, stop and report file-level divergence.

### 7) Update state

Write/update `.stack/<feature>/state.json` with:

- locked IDs and locked heads
- current slice branch heads and empty flags
- `last_publish` metadata (`mode`, `epic_head`, `work_head`, `tip_head`, `timestamp`)

### 8) Push rewritten branches

Push only unlocked slice branches that changed:

- `git push --force-with-lease origin <feature>/<NN>-<branch_suffix>`

Never push locked slices with force updates.

### 9) Optional work realignment

If policy is to keep work pinned to tip:

- `git branch -f <feature>/work <tip-slice>`
- `git push --force-with-lease origin <feature>/work`

## Edge Cases

### Empty slices

- Keep branch at current HEAD.
- Mark `empty=true` in state.
- Preserve numbering; do not auto-delete slice IDs.

### Renames and moves

- Prefer dedicated early slice for rename-heavy changes.
- If ownership cannot be resolved cleanly, fail and request plan update.

### Plan changed after merges

- Locked slice IDs remain immutable regardless of plan edits.
- Apply plan changes only to unlocked slices.

## Output Format

- Result (`pass` or `fail`)
- Rebuilt slices (with old/new heads)
- Locked slices untouched
- Assignment issues (if any)
- Tip equality status
- Next recommended command
