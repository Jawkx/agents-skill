# Workflow: Plan Slice Contract

Command:

```bash
stack plan <feature>
```

## Intent

Use when user asks to define or revise slice boundaries/intents.

This workflow never rewrites Git branches.

## Plan Location

- Preferred: `.stack/<feature>/epic.yml`
- Legacy fallback: `.stack/epic.yml` when repo already uses single-feature layout

Versioning policy:

- Keep `epic.yml` committed on `<feature>/work`.
- Do not require an `epic-<feature>` copy for publish.

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
- Keep ordering meaningful for review comments.
- Put broad churn early when practical (renames, lockfiles, large mechanical changes).
- Keep branch names stable to reduce reshuffling across republish runs.

Explicit review-flow guidance:

- If team reviews via stacked PRs, use numbered slices (`01`, `02`, `03`, `04`, `05`).
- Ensure each PR can receive fixes on its own branch without relying on tip-only edits.

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

If user is addressing a PR/review comment, use review-fix workflow instead:

`references/04-workflow-review-fixes.md`
```
