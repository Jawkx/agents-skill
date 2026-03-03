# Workflow: Diagnose Stack State

Operation: `status`

Optional CLI alias: `stack status <feature>`

Read-only health and placement preview.

## Steps

1. Refresh refs (`git fetch origin --prune`).
2. Resolve base/work and fail if either is missing.
3. Resolve ordered slices from `.stack/<feature>/epic.yml`.
   - Fallback only if spec is missing: discover `<feature>/*` branches.
4. Resolve tip slice (last slice).
5. Check `tip == work` when tip exists.
6. Detect locked slices via merge ancestry into base.
7. Show `git diff --stat epic-<feature>..<feature>/work`.
8. If user gives PR/branch/slice hint, resolve target branch.
9. Compute rewrite preview: target `N`, descendants `N+1..tip`, untouched
   `1..N-1`.

## Fail Fast

- missing base/work -> stop with restore/bootstrap guidance
- target unresolved -> mark ambiguous (no writes in status mode)

## Output

- result (`pass`/`fail`)
- base/work refs
- ordered slices + tip
- lock state
- target resolution (or ambiguity)
- rewrite preview
- invariant summary (`tip == work`, lock integrity)
- next step (`publish`, `review-fixes`, or recovery)
