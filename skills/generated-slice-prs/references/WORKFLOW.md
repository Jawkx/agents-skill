# Workflow: Generated Slice PRs

## Terminology

- `<feature>`: canonical working branch (named like the feature)
- `<base>`: PR base branch (default `main`)
- `B`: merge-base commit: `merge-base(<base>, <feature>)`
- Slice branches: `<feature>/<id>-<slug>` (e.g. `<feature>/01-scaffold`)

## Default endgame

- Merge slice PRs into `<base>` (usually in order).
- Do NOT merge `<feature>` unless the user explicitly chooses a different endgame.

## Default execution behavior

- Prepare/regenerate slice branches and `.feature-stack.md` by default.
- Creating/updating PRs is a separate explicit step.

If user chooses alternate endgame:

- Use slice PRs for review only, then merge `<feature>` once at the end.
- (If doing this, ensure `.feature-stack.md` does not land in `<base>`.)

## 0) Always start by reading `.feature-stack.md`

- If missing, create it (use `references/STACK_FILE.md`).
- Treat `slices[]` ordering/IDs as authoritative once established.

## 1) Initial split (first branch generation)

1. Determine `<base>` (default `main`) and compute `B = merge-base(<base>, <feature>)`.
2. Compute diff between `B.. <feature>`.
3. Partition into slices:
   - use `references/SLICING_GUIDE.md`
   - keep slices coherent and reviewable
4. Materialize slice branches:
   - For each slice, create branch from `B` (critical).
   - Apply only that slice's changes.
   - Commit with a stable message prefix: `Slice: <id> - <title>`
5. Update `.feature-stack.md` with:
   - `mode` (often start as DRAFT)
   - `slices[]` list with `branch_suffix` and titles
6. Do not create PRs in this step.

## 1b) Publish slice PRs (explicit, non-default)

1. Ensure slice branches are prepared and pushed.
2. Open one PR per slice branch targeting `<base>`.
3. Use `references/PR_TEMPLATE.md` for title/body formatting.
4. Update `.feature-stack.md` with optional PR links/status.

## 2) Regenerate after changes on `<feature>`

Rule: canonical changes happen on `<feature>`. Slices are derived.

1. Apply changes on `<feature>`.
2. Compute new intended slice snapshots (respect existing `slices[]` boundaries first).
3. Update only impacted slice branches:
   - obey mode rules (REVIEW: append-only; DRAFT: rewriting allowed)
   - prefer one delta commit per impacted slice in REVIEW mode
4. Update `.feature-stack.md` (and optional short regen note in body).

## 3) Apply review feedback (recommended)

Same as regeneration:

- Fix on `<feature>` → regenerate impacted slices → update stack file.
  Avoid direct edits on slice branches unless explicitly requested.

## 4) Optional: absorb direct edits on a slice branch

Only if user explicitly edited slice branch and wants to keep it.

1. Compute the delta between the edited slice branch and the intended slice content.
2. Apply the delta onto `<feature>` in the appropriate place.
3. Regenerate slices to re-sync everything.
