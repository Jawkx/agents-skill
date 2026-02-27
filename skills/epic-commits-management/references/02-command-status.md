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
- optional state file at `.stack/<feature>/state.json`

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

   - Preferred: read ordered `slices[].branch_name` from plan.
   - Fallback: discover local branches matching `<feature>/*` and sort lexicographically.

4. Resolve tip slice.

   - Tip is last ordered slice.
   - If no slices exist, report that publish will create the stack.

5. Verify invariant `tip == work` when tip exists.

   - `git diff --quiet <tip-slice>..<feature>/work`
   - non-zero means tip drifted from work.

6. Verify locked slice integrity when state exists.

   - Read `locked_branches` and `locked_heads` from state.
   - For each locked branch, compare current head to recorded head.
   - Any mismatch is a hard fail.

7. Show work summary against base.

   - `git diff --stat epic-<feature>..<feature>/work`

8. Compute likely publish scope.
   - Which unlocked slices would be rebuilt.
   - Whether state indicates pending advance.

## Output Template

- Result: `pass` or `fail`
- Base/work: existence + resolved refs
- Slices: ordered list + tip
- Invariants:
  - tip equals work
  - locked heads unchanged
- Diff summary: `epic..<work>` stat
- Next action:
  - `stack publish <feature>` when healthy
  - or one recovery command when unhealthy

## Failure Cases

- Base missing -> stop and report branch bootstrap command.
- Work missing -> stop and report branch recreation option.
- Tip mismatch -> recommend `publish` or explicit work realignment.
- Locked mismatch -> recommend restore from backup or state head.

## Notes

- `status` is always read-only.
- Do not update state in `status`.
- Keep the report concise but explicit enough to drive the next command.
