# Workflow: Clean Stack

Operation: `clean`

Optional CLI alias: `stack clean <feature>`

Finalize an epic after slices are merged by removing disposable stack branches.

## Preconditions

- write preflight passes (see `01-core-contract.md`)
- intended slices are merged into `epic-<feature>`
- no diff between `epic-<feature>` and `<feature>/work`

## Procedure

1. Verify completion state.
   - confirm work branch exists (local or remote)
   - `git diff --quiet epic-<feature>..<feature>/work`
2. If diff exists, stop and recommend `publish` or `advance` first.
3. Backup refs for branches that may be deleted.
4. Delete work branch (remote then local):
   - `git push origin --delete <feature>/work`
   - `git branch -D <feature>/work`
5. Optional: delete slice branches per team policy (conservative or aggressive).
6. Optional: keep or discard `.stack/<feature>/epic.yml` per team preference.
7. Do not write `.stack/<feature>/state.json`.

## Output

- result (`pass`/`fail`)
- work branch deletion status
- slice cleanup status
- spec cleanup status
- residual manual actions

## Failure Handling

- non-empty epic/work diff -> abort clean with explicit next step
- partial deletion -> report exact branches needing manual follow-up
