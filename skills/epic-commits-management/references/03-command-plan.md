# Command Reference: stack plan

Command:

```bash
stack plan <feature>
```

## Goal

Create or validate the slicing contract at `.stack/<feature>/epic.yml`.

This command should not rewrite Git branches. It is planning and validation only.

## Plan Location

- Preferred: `.stack/<feature>/epic.yml`
- Legacy fallback: `.stack/epic.yml` when repo already uses single-feature layout

Versioning policy:

- Commit the plan on `epic-<feature>`.
- Sync `<feature>/work` to that committed plan before publishing slices.

## Bootstrap Procedure

1. Ensure feature folder exists.
   - `mkdir -p .stack/<feature>`
2. If epic spec is missing, create it from `assets/epic.template.yml` and adapt values.
3. Fill required fields:
   - `feature`
   - `base`
   - `work`
   - `slices[]`

## Validation Checklist

Validate structure:

- `feature` equals command argument
- `base` is `epic-<feature>`
- `work` is `<feature>/work`
- each slice has `branch_name`, `intent`

Validate ordering and naming:

- `branch_name` values are unique
- each `branch_name` starts with `<feature>/`
- order is intentional and stable

Validate intent quality:

- each `intent` is non-empty
- intent differentiates one slice from another

## Recommended Slice Design

- Keep each slice reviewable (small and coherent).
- Group by intent and review narrative.
- Put broad churn early when practical (renames, lockfiles, large mechanical changes).
- Keep branch names stable to reduce reshuffling across republish runs.

## Output Format

- Result: `valid` or `invalid`
- Plan file path used
- Slice table:
  - `branch_name`
  - `intent`
- Problems:
  - missing required fields
  - duplicate branch names
  - weak or empty intent statements
- Suggested patch to the plan when invalid

## Failure Handling

- If work branch is missing, validate structure only.
- If base is missing, fail and request branch bootstrap.
- If plan is structurally invalid, do not proceed to publish.

## Handoff

When plan is valid, next command is:

```bash
stack publish <feature>
```
