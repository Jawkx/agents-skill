# Troubleshooting

## PR shows "everything" / diff is wrong

Likely cause:

- Slice branch was created from `<feature>` tip, not merge-base `B`.

Fix:

- Recreate slice branches from `B = merge-base(<base>, <feature>)`.
- Ensure PR base is `<base>` (usually `main`).

## Review comments got detached / context lost

Likely cause:

- Force-push rewriting slice history during active review.

Fix:

- Set mode to REVIEW in `.feature-stack.md`.
- Use append-only delta commits.

## Regeneration churn updates many slices repeatedly

Likely cause:

- Slice boundaries aren't sticky or slices overlap heavily.

Fix:

- Stop re-cutting in REVIEW mode.
- Insert `02a-*` prerequisites instead of reshuffling.
- Isolate big refactors into a single early slice.

## Someone edited a slice branch directly

Fix (if user wants to keep changes):

- Absorb delta into `<feature>`.
- Regenerate slices so slice branches match canonical again.
- Re-state that `<feature>` is canonical source of truth.

## Need to insert missing prerequisite after PRs exist

Fix:

- Add `0Xa-*` slice; do not renumber.
- Update `.feature-stack.md` and tell reviewers to read the new slice first.
