# Core Contract

Use this file as the shared baseline for every command.

## Contents

- Branch model and naming
- Invariants
- Repo files
- Mandatory preflight for write commands
- Epic spec schema and validation rules
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

Recommended branch naming for slices is `<feature>/<NN>-<details>`, but this is a convention only. The source of truth is `branch_name` values in `epic.yml`.

## Invariants

1. Slice ancestry is linear from `epic-<feature>` to the tip slice following spec order.
2. Tree equality holds at the tip: `tree(tip-slice) == tree(<feature>/work)`.
3. Humans and automation edit only `<feature>/work` directly.
4. Locked slices are immutable once merged into `epic-<feature>`.

## Repo Files

- Stack spec (epic spec): `.stack/<feature>/epic.yml`

Source-of-truth policy:

- Keep `.stack/<feature>/epic.yml` on `<feature>/work`.
- Treat `<feature>/work` as the canonical spec branch.
- If a temporary copy exists on `epic-<feature>`, treat it as informational only.

Allow `.stack/epic.yml` only as a legacy fallback when the repo already uses it.

No persistent runtime state file is required. Commands should not write `.stack/<feature>/state.json`.

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

Epic spec files intentionally avoid per-path ownership.

Runtime behavior:

- `publish` computes changed paths from `epic-<feature>..<feature>/work`
- it infers per-slice path ownership during the run using existing slice history and slice intents
- ambiguous or unassigned ownership is a hard fail and must be resolved before rewrite
- ownership mapping is ephemeral (reported in output), not written to disk

This keeps `epic.yml` minimal while still allowing deterministic rebuilds when branch history is stable.

## Locked Slice Policy

- Lock slices only after merge into `epic-<feature>` is confirmed.
- Never rewrite locked slice branches.
- If a new fix touches locked-owned paths, place it in the earliest unlocked slice or append a tail fix slice branch in `epic.yml`.

## Reporting Contract

Every command should return:

1. Result (`pass` or `fail`)
2. Checks (what passed or failed)
3. Branch effects (created, rewritten, untouched, deleted)
4. Risks or follow-up actions
5. Single recommended next command
