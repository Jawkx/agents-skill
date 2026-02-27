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
- epic spec: `.stack/<feature>/epic.yml`
- state: `.stack/<feature>/state.json` (if present)

## Detailed Procedure

### 1) Run mandatory preflight

Run the shared preflight from `01-core-contract.md`.

If preflight fails, stop.

### 2) Load plan and state

1. Parse plan slices in listed order (`slices[].branch_name`).
2. Read locked branches from state (default empty).
3. Validate that each locked branch appears merged into `epic-<feature>`.
   - `git merge-base --is-ancestor <locked-branch> epic-<feature>`
4. If a locked branch is not merged, stop and require manual recovery.

### 3) Resolve slice scopes for this publish

Plan does not define `paths`, so ownership is runtime-resolved.

1. Get diff entries from `epic..<work>`:
   - `git diff --name-status --no-renames epic-<feature>..<feature>/work`
2. Reuse `state.resolved_paths` when present and still valid.
3. For missing coverage, infer ownership from prior slice history and slice `intent`.
4. Fail on:
   - unassigned path
   - ambiguous path

Include actionable suggestions in the failure report.

### 4) Prepare rewrite backups

Create backup refs for each branch that may move:

- all unlocked slice branches that already exist
- `<feature>/work` if it will be repointed

### 5) Build stack on a temp branch

1. Create temp build branch from base:
   - `git switch -c .tmp/epic-commits-management/<feature>/<timestamp> epic-<feature>`
2. Iterate slices in plan order.

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
     - `git commit -m "<branch_name>: <intent>"`
  4. If no staged changes:
     - keep current HEAD and mark slice as `empty=true`
  5. Point slice branch to current HEAD:
     - `git branch -f <branch_name> HEAD`

### 6) Validate final invariants

1. Resolve tip as last plan slice.
2. Verify tip equals work:
   - `git diff --quiet <tip-slice>..<feature>/work`
3. If mismatch, stop and report file-level divergence.

### 7) Update state

Write/update `.stack/<feature>/state.json` with:

- locked branches and locked heads
- current slice branch heads and empty flags
- resolved runtime ownership (`resolved_paths`)
- `last_publish` metadata (`mode`, `epic_head`, `work_head`, `tip_head`, `timestamp`)

### 8) Push rewritten branches

Push only unlocked slice branches that changed:

- `git push --force-with-lease origin <branch_name>`

Never push locked slices with force updates.

### 9) Optional work realignment

If policy is to keep work pinned to tip:

- `git branch -f <feature>/work <tip-slice>`
- `git push --force-with-lease origin <feature>/work`

## Edge Cases

### Empty slices

- Keep branch at current HEAD.
- Mark `empty=true` in state.
- Preserve slice order; do not auto-delete slice entries.

### Plan changed after merges

- Locked slices remain immutable regardless of plan edits.
- Apply plan changes only to unlocked slices.

## Output Format

- Result (`pass` or `fail`)
- Rebuilt slices (with old/new heads)
- Locked slices untouched
- Ownership issues (if any)
- Tip equality status
- Next recommended command
