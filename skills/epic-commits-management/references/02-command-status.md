# Workflow: Diagnose Stack State

Typical command:

```bash
stack status <feature>
```

## Intent

Use this workflow when user asks "what is broken?" or "what branch should this land on?"

- confirm branch visibility
- resolve slice order and lock state
- validate invariants
- preview which branches would move for a target slice

## Inputs

- `<feature>`
- optional target hint (PR, branch, slice number)
- epic spec at `.stack/<feature>/epic.yml`

Derived branch names:

- `base=epic-<feature>`
- `work=<feature>/work`

## Procedure (Read-Only)

1. Refresh refs.

   - `git fetch --all --prune`

2. Verify base and work branch visibility.

   - Check local branch first.
   - If missing locally, check remote branch (`origin/<branch>`).
   - Fail if either branch is missing.

3. Resolve slice order from spec.

   - Preferred: read ordered `slices[].branch_name` from epic spec.
   - Fallback: discover local branches matching `<feature>/*` and sort lexicographically.

4. Resolve tip slice.

   - Tip is last ordered slice.
   - If no slices exist, report that publish will create the stack.

5. Verify invariant `tip == work` when tip exists.

   - `git diff --quiet <tip-slice>..<feature>/work`
   - non-zero means tip drifted from work.

6. Detect merged (locked) slices.

   - For each slice branch that exists, check:
   - `git merge-base --is-ancestor <slice-branch> epic-<feature>`
   - Ancestor slices are considered locked and must not be rewritten.

7. Show work summary against base.

   - `git diff --stat epic-<feature>..<feature>/work`

8. If a target hint exists, resolve target branch.

   - PR hint: resolve head branch from `gh pr view`.
   - Branch/slice hint: match from spec.
   - If unresolved, mark ambiguous (do not guess).

9. Compute likely rewrite scope.

   - target slice `N`
   - descendants `N+1..tip`
   - untouched ancestors `1..N-1`

## Output Template

- Result: `pass` or `fail`
- Base/work: existence + resolved refs
- Slices: ordered list + tip
- Target resolution: explicit mapping or ambiguity
- Rewrite preview: target + descendants only
- Invariants:
  - tip equals work (validation only)
  - merged slices detected (locked by ancestry)
- Diff summary: `epic..<work>` stat
- Next action:
  - `stack publish <feature>` for full rebuild
  - or review-fix workflow when target is known
  - or one recovery command when unhealthy

## Failure Cases

- Base missing -> stop and report branch bootstrap command.
- Work missing -> stop and report branch recreation option.
- Target ambiguous -> ask one direct question before writes.
- Tip mismatch -> recommend restack/publish, but do not use mismatch to pick target.

## Notes

- `status` is always read-only.
- Do not write `.stack/<feature>/state.json`.
- Keep report concise and intent-oriented.
