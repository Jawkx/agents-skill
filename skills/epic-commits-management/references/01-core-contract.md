# Core Contract

Use this file as the shared baseline for every command.

## Contents

- Branch model and naming
- Invariants
- Repo files and state model
- Mandatory preflight for write commands
- Plan schema and validation rules
- Slice scope resolution model
- Reporting expectations

## Branch Model

- Base branch: `epic-<feature>`
- Work branch: `<feature>/work` (disposable, human-edited)
- Slice branches: ordered list from `.stack/<feature>/epic.yml`

Plan-first shape:

```text
epic-<feature>
  <- <slice-1 branch_name>
  <- <slice-2 branch_name>
  <- ...
  <- <slice-N branch_name>   (tip)
```

Recommended branch naming for slices is `<feature>/<NN>-<details>`, but this is a convention only. The source of truth is `branch_name` values in the plan file.

## Invariants

1. Slice ancestry is linear from `epic-<feature>` to the tip slice following plan order.
2. Tree equality holds at the tip: `tree(tip-slice) == tree(<feature>/work)`.
3. Humans and automation edit only `<feature>/work` directly.
4. Locked slices are immutable once merged into `epic-<feature>`.

## Repo Files

Prefer per-feature state to avoid collisions:

- Stack spec (epic spec): `.stack/<feature>/epic.yml`
- State: `.stack/<feature>/state.json`

Source-of-truth policy:

- Commit `.stack/<feature>/epic.yml` on `epic-<feature>`.
- Treat `epic-<feature>` as the canonical plan branch.
- Keep `<feature>/work` synced with epic's plan version before stack generation.
- Keep `state.json` as runtime metadata (often local-only unless repo policy says otherwise).

Allow `.stack/epic.yml` only as a legacy fallback when the repo already uses it.

### Recommended `state.json` shape

```json
{
  "feature": "add-market-screen",
  "base": "epic-add-market-screen",
  "work": "add-market-screen/work",
  "locked_branches": ["add-market-screen/01-redux-store"],
  "locked_heads": {
    "add-market-screen/01-redux-store": "a1b2c3d4"
  },
  "slices": [
    {
      "branch_name": "add-market-screen/01-redux-store",
      "head": "a1b2c3d4",
      "locked": true
    },
    {
      "branch_name": "add-market-screen/02-market-api",
      "head": "e5f6a7b8",
      "locked": false,
      "empty": false
    }
  ],
  "resolved_paths": {
    "add-market-screen/01-redux-store": ["src/store/**", "src/types/**"],
    "add-market-screen/02-market-api": ["src/api/market/**"]
  },
  "last_publish": {
    "mode": "rebuild",
    "epic_head": "1111111",
    "work_head": "2222222",
    "tip_head": "3333333",
    "timestamp": "2026-02-26T10:00:00Z"
  }
}
```

`resolved_paths` is runtime metadata generated or updated during publish. It is not part of the plan schema.

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

## Epic Spec Schema

Epic spec file: `.stack/<feature>/epic.yml`

Required fields:

- `feature`: must match command argument
- `base`: must equal `epic-<feature>`
- `work`: must equal `<feature>/work`
- `slices`: ordered list of slice definitions

Each slice requires:

- `branch_name`: full branch name for that slice
- `intent`: short purpose statement

Validation rules:

- `branch_name` values are unique
- `branch_name` should start with `<feature>/`
- slice order is explicit by list position
- intent is non-empty and stable enough to guide restacks

## Slice Scope Resolution Model

Plan files intentionally avoid per-path ownership.

Runtime behavior:

- `publish` computes changed paths from `epic-<feature>..<feature>/work`
- it resolves per-slice path ownership using state (`resolved_paths`) when available
- if missing, it infers ownership from existing slice history and intent-guided clustering
- ambiguous or unassigned ownership is a hard fail and must be resolved before rewrite

This keeps `epic.yml` minimal while preserving deterministic rebuilds via `state.json`.

## Locked Slice Policy

- Lock slices only after merge into `epic-<feature>` is confirmed.
- Never rewrite locked slice branches.
- If a new fix touches locked-owned paths, place it in the earliest unlocked slice or append a tail fix slice branch in the plan.

## Reporting Contract

Every command should return:

1. Result (`pass` or `fail`)
2. Checks (what passed or failed)
3. Branch effects (created, rewritten, untouched, deleted)
4. Risks or follow-up actions
5. Single recommended next command
