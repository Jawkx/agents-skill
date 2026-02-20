# Minimal Change Contract

Goal: updates should not invalidate reviewer context or churn diffs unnecessarily.

## Golden rules

1. Never renumber slices once PRs exist.
   - Insert as `02a-*`, `02b-*`, etc.
2. Update only impacted slices.
3. REVIEW mode: append-only (no force-push).
4. Keep boundaries sticky:
   - Do not reshuffle hunks across slices unless unavoidable.

## What "impacted slice" means (without paths)

For each slice branch:

- Compare current slice branch content vs the newly intended slice content.
- If identical → no update.
- If different → update that slice branch.

## REVIEW mode update policy (append-only)

When a slice is impacted:

- Add exactly one "delta" commit on that slice branch to reach the intended content.
- Delta commit message should be explicit, e.g.:
  - `Slice: 02 - delta (address review feedback)`
- Do not rewrite earlier commits.

## DRAFT mode update policy

- You may rewrite slice branch history if it improves clarity.
- Still prefer minimal churn (don't re-cut everything just because you can).

## Inserting new slices

If you discover missing prerequisite work after PRs exist:

- Insert `02a-*` rather than renumbering `03` onward.
- Update `.feature-stack.md` with the inserted slice.

## Overlaps (changes that logically touch multiple slices)

Preferred resolution order:

1. Keep fix in its original slice; update additional slices only if necessary.
2. If the fix reveals missing groundwork, insert a new `0Xa-*` prerequisite slice.
3. Avoid moving lots of hunks across slices in REVIEW mode.

## Human-facing stability expectations (REVIEW)

- PRs should change via small additive commits.
- Avoid "teleporting diffs" that make reviewers re-review everything.
