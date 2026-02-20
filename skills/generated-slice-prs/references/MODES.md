# Modes: DRAFT vs REVIEW

Mode is set in `.feature-stack.md` and controls how the agent updates slice branches.

## DRAFT mode

Use when the slice plan is still being shaped.

Allowed:

- Move hunks between slices to improve reviewability
- Rename slice slugs / titles
- Rewrite slice branch history (force-push) if needed

Guidance:

- Prefer minimal churn anyway, but correctness/clarity beats stability.
- If PRs exist, make it obvious they are WIP (Draft PR, labels, "do not merge").

Use DRAFT when:

- First split
- Still refactoring heavily
- Expecting to re-cut slice boundaries

## REVIEW mode

Use once reviewers are actively leaving comments you want to preserve.

Rules:

- Append-only updates on slice branches (no force-push)
- Keep slice IDs stable (no renumbering)
- Keep boundaries sticky (minimal churn; avoid moving hunks across slices)

Use REVIEW when:

- Any real review has started
- Preserving comment anchors and "Viewed" state matters

## mode_lock

If `.feature-stack.md` has `mode_lock: true`:

- Do not change mode unless the user explicitly instructs.
