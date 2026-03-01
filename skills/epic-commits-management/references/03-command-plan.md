# Workflow: Plan Slice Contract

Command:

```bash
stack plan <feature>
```

Define or revise `.stack/<feature>/epic.yml`. This workflow never rewrites
branches.

## Steps

1. Ensure `.stack/<feature>/` exists.
2. If spec is missing, create it from `assets/epic.template.yml`.
3. Validate required fields:
   - `feature`, `base`, `work`, `slices[]`
4. Validate each slice entry:
   - `branch_name`, `intent`
   - unique `branch_name`
   - `branch_name` starts with `<feature>/`
   - non-empty `intent`
5. Return slice table and concrete problems.

## Design Rules

- Keep slices reviewable and coherent.
- Keep ordering stable for stacked PR review.
- Prefer stable branch names to avoid avoidable restacks.

## Output

- result (`valid`/`invalid`)
- plan path used
- ordered slice table (`branch_name`, `intent`)
- validation issues and suggested patch when invalid

## Handoff

- If valid: `stack publish <feature>`
- If user asked for PR feedback fixes instead: use
  `references/04-workflow-review-fixes.md`
