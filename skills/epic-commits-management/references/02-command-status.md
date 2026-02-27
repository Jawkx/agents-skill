# Command Reference: stack status

Command:

```bash
stack status <feature>
```

## Goal

Produce a read-only health report for one feature stack.

- confirm required branches exist
- discover current slice stack
- verify key invariants
- show what `publish` would change

## Inputs

- `<feature>` name (for example `add-market-screen`)
- optional epic spec at `.stack/<feature>/epic.yml`

Derived branch names:

- `base=epic-<feature>`
- `work=<feature>/work`

## Procedure

1. Refresh refs.

   - `git fetch --all --prune`

2. Verify base and work branch visibility.

   - Check local branch first.
   - If missing locally, check remote branch (`origin/<branch>`).
   - Fail if either branch is missing.

3. Resolve slice order.

   - Preferred: read ordered `slices[].branch_name` from epic spec.
   - Fallback: discover local branches matching `<feature>/*` and sort lexicographically.

4. Resolve tip slice.

   - Tip is last ordered slice.
   - If no slices exist, report that publish will create the stack.

5. Verify invariant `tip == work` when tip exists.

   - `git diff --quiet <tip-slice>..<feature>/work`
   - non-zero means tip drifted from work.

6. Detect merged (effectively locked) slices.

   - For each slice branch that exists, check:
   - `git merge-base --is-ancestor <slice-branch> epic-<feature>`
   - Ancestor slices are considered locked and must not be rewritten.

7. Show work summary against base.

   - `git diff --stat epic-<feature>..<feature>/work`

8. Compute likely publish scope.
   - Which non-merged slice branches would be rebuilt.
   - Whether publish will create missing slice branches.

## Output Template

- Result: `pass` or `fail`
- Base/work: existence + resolved refs
- Slices: ordered list + tip
- Invariants:
  - tip equals work
  - merged slices detected (locked by ancestry)
- Diff summary: `epic..<work>` stat
- Next action:
  - `stack publish <feature>` when healthy
  - or one recovery command when unhealthy

## Failure Cases

- Base missing -> stop and report branch bootstrap command.
- Work missing -> stop and report branch recreation option.
- Tip mismatch -> recommend `publish` or explicit work realignment.

## Notes

- `status` is always read-only.
- Do not write `.stack/<feature>/state.json`.
- Keep the report concise but explicit enough to drive the next command.
