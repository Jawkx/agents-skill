# Command Reference: stack clean

Command:

```bash
stack clean <feature>
```

## Goal

Finalize an epic workflow after slices are merged: remove disposable work artifacts and optionally remove generated slice branches.

## Preconditions

- write preflight passes
- all intended slices are merged into `epic-<feature>`
- no remaining diff from work to epic

## Detailed Procedure

### 1) Run mandatory preflight

Use shared preflight from `01-core-contract.md`.

### 2) Verify completion state

1. Confirm work branch exists (local or remote).
2. Confirm no pending diff:
   - `git diff --quiet epic-<feature>..<feature>/work`
3. If diff exists, stop and recommend `publish` or `advance` first.

### 3) Backup branch refs before deletion

Create backups for:

- `<feature>/work`
- slice branches from epic spec that may be deleted

### 4) Delete work branch

Remote first, then local:

- `git push origin --delete <feature>/work`
- `git branch -D <feature>/work`

If remote delete fails because branch is absent, continue and report as already removed.

### 5) Optional slice branch cleanup

Respect repo policy:

- conservative: keep slice branches for audit window
- aggressive: delete all slice branches once epic is merged

Deletion commands:

- `git push origin --delete <slice branch_name>`
- `git branch -D <slice branch_name>`

### 6) Spec cleanup

`epic.yml` is disposable with `<feature>/work`.

- keep it if your team wants a reusable spec template
- otherwise let it disappear with work branch cleanup

Do not write or maintain `.stack/<feature>/state.json` during clean.

## Output Format

- Result (`pass` or `fail`)
- Work branch deletion status
- Slice cleanup status (deleted/kept)
- Epic spec cleanup status
- Any residual manual tasks

## Failure Handling

- If epic/work diff is non-empty, abort clean and send explicit next command.
- If branch deletion is partially successful, report exact branches requiring manual follow-up.
