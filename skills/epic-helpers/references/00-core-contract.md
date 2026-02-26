# Core Contract

Use this file as the shared baseline for every command.

## Contents

- Branch model and naming
- Invariants
- Repo files and state model
- Mandatory preflight for write commands
- Plan schema and validation rules
- File assignment rules
- Reporting expectations

## Branch Model

- Base branch: `epic-<feature>`
- Work branch: `<feature>/work` (disposable, human-edited)
- Slice branches: `<feature>/<NN>-<details>` where `NN` is `01..99`

Desired shape:

```
epic-<feature>
  <- <feature>/01-...
  <- <feature>/02-...
  <- ...
  <- <feature>/NN-...   (tip)
```

## Invariants

1. Slice ancestry is linear from `epic-<feature>` to the tip slice.
2. Tree equality holds at the tip: `tree(tip-slice) == tree(<feature>/work)`.
3. Humans and automation edit only `<feature>/work` directly.
4. Locked slices are immutable once merged into `epic-<feature>`.

## Repo Files

Prefer per-feature state to avoid collisions:

- Plan: `.stack/<feature>/plan.yml`
- State: `.stack/<feature>/state.json`

Allow `.stack/plan.yml` only as a legacy fallback when the repo already uses it.

### Recommended `state.json` shape

```json
{
  "feature": "add-market-screen",
  "base": "epic-add-market-screen",
  "work": "add-market-screen/work",
  "locked_ids": ["01"],
  "locked_heads": {
    "add-market-screen/01-add-redux-store": "a1b2c3d4"
  },
  "slices": [
    {
      "id": "01",
      "branch": "add-market-screen/01-add-redux-store",
      "head": "a1b2c3d4",
      "locked": true
    },
    {
      "id": "02",
      "branch": "add-market-screen/02-market-api",
      "head": "e5f6a7b8",
      "locked": false,
      "empty": false
    }
  ],
  "last_publish": {
    "mode": "rebuild",
    "epic_head": "1111111",
    "work_head": "2222222",
    "tip_head": "3333333",
    "timestamp": "2026-02-26T10:00:00Z"
  },
  "prs": [
    {
      "id": "02",
      "number": 123,
      "url": "https://github.com/org/repo/pull/123",
      "base": "add-market-screen/01-add-redux-store",
      "head": "add-market-screen/02-market-api"
    }
  ]
}
```

## Mandatory Preflight (write commands only)

Run before `publish`, `advance`, and `clean`.

1. Refresh refs:
   - `git fetch --all --prune`
2. Ensure clean tree:
   - `git status --porcelain` must be empty
3. Ensure non-detached HEAD:
   - `git branch --show-current` must be non-empty
4. Verify branch existence (local or remote):
   - always: `epic-<feature>`
   - publish/advance: `<feature>/work`
5. Create backup refs for every branch that may be rewritten.
6. Use `--force-with-lease` for all force updates.

### Backup naming

- Pattern: `backup/<feature>/<timestamp>-<branch-slug>`
- Timestamp format: `YYYYMMDD-HHMMSS`
- Slug rule: replace `/` with `--`

Example:

```bash
feature="add-market-screen"
branch="add-market-screen/02-market-api"
ts="$(date +"%Y%m%d-%H%M%S")"
slug="${branch//\//--}"
git branch "backup/$feature/$ts-$slug" "$branch"
```

If any preflight check fails, stop immediately and report:

- failed check
- observed output
- one concrete recovery command

## Plan Schema

Plan file: `.stack/<feature>/plan.yml`

Required fields:

- `feature`: must match command argument
- `base`: must equal `epic-<feature>`
- `work`: must equal `<feature>/work`
- `slices`: ordered list of slice definitions

Each slice requires:

- `id`: two digits (`"01"` to `"99"`)
- `branch_suffix`: short stable slug
- `intent`: short purpose statement
- `paths`: non-empty glob list

Validation rules:

- IDs are unique and sorted ascending
- No duplicate `branch_suffix`
- Every changed file must map to exactly one slice
- Renames should resolve to a single slice ownership decision

## File Assignment Rules

Compute changed paths from tree diff:

- `git diff --name-status --no-renames epic-<feature>..<feature>/work`

Assign each path against `paths` globs:

- zero matching slices -> `unassigned` (fail)
- multiple matching slices -> `ambiguous` (fail)
- one matching slice -> assigned

Renames and moves:

- Prefer dedicated early slice for rename-heavy changes.
- If old and new paths map to different slices, fail and request plan adjustment.

## Locked Slice Policy

- Lock slices only after merge into `epic-<feature>` is confirmed.
- Never rewrite locked slice branches.
- If a new fix touches locked-owned paths, place it in earliest unlocked slice or append a tail fix slice (`<feature>/<NN>-fix-<topic>`).

## Reporting Contract

Every command should return:

1. Result (`pass` or `fail`)
2. Checks (what passed or failed)
3. Branch effects (created, rewritten, untouched, deleted)
4. Risks or follow-up actions
5. Single recommended next command
