# Command Reference: stack plan

Command:

```bash
stack plan <feature>
```

## Goal

Create or validate the slicing contract at `.stack/<feature>/plan.yml`.

This command should not rewrite Git branches. It is planning and validation only.

## Plan Location

- Preferred: `.stack/<feature>/plan.yml`
- Legacy fallback: `.stack/plan.yml` when repo already uses single-feature layout

Versioning policy:

- Commit the plan on `epic-<feature>`.
- Sync `<feature>/work` to that committed plan before publishing slices.

## Bootstrap Procedure

1. Ensure feature folder exists.
   - `mkdir -p .stack/<feature>`
2. If plan is missing, create it from `assets/plan.template.yml` and adapt values.
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
- each slice has `id`, `branch_suffix`, `intent`, `paths`

Validate ordering and naming:

- IDs are unique two-digit strings
- IDs are strictly increasing
- `branch_suffix` values are stable and unique

Validate path ownership:

1. Compute changed files from `epic..<work>`.
2. Match each file against slice globs.
3. Fail if any file is:
   - unassigned (zero matches)
   - ambiguous (more than one match)

## Recommended Slice Design

- Keep each slice reviewable (small and coherent).
- Group by intent, then by path.
- Put broad churn early when practical:
  - renames/moves
  - lockfiles
  - formatting-only updates
- Use stable paths to reduce reshuffling across republish runs.

## Output Format

- Result: `valid` or `invalid`
- Plan file path used
- Slice table:
  - `id`
  - branch name
  - intent
  - path coverage hints
- Problems:
  - unassigned files
  - ambiguous matches
  - ordering/ID violations
- Suggested patch to the plan when invalid

## Failure Handling

- If work branch is missing, validate structure only and skip coverage checks.
- If base is missing, fail and request branch bootstrap.
- If coverage fails, do not proceed to publish.

## Handoff

When plan is valid, next command is:

```bash
stack publish <feature>
```
