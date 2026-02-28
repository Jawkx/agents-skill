---
name: epic-commits-management
description: Intent-driven workflow prompts for managing epic slice branches during review and merge cycles. Use when users mention epic stacks, stacked PRs, slice branches, or review comments that must land on a specific branch and restack descendants safely.
---

# Epic Commits Management

This skill is a decision playbook for stacked branch maintenance.

Use intent first:

- identify which slice the user actually wants to change
- apply the fix on that slice branch
- restack only descendants
- validate invariants after placement

Do not treat `tip == work` as a branch selection rule.

## Load Order

1. Always load the core model:
   - [references/01-core-contract.md](references/01-core-contract.md)
2. Then load the workflow that matches user intent:
   - read-only diagnosis: [references/02-command-status.md](references/02-command-status.md)
   - plan/spec updates: [references/03-command-plan.md](references/03-command-plan.md)
   - PR/review fix placement: [references/04-workflow-review-fixes.md](references/04-workflow-review-fixes.md)
   - full publish from work: [references/05-command-publish.md](references/05-command-publish.md)
   - post-merge lock progression: [references/06-command-advance.md](references/06-command-advance.md)
   - cleanup: [references/07-command-clean.md](references/07-command-clean.md)
3. If anything fails, load:
   - [references/10-recovery.md](references/10-recovery.md)
4. Behavior checks and examples:
   - [references/09-acceptance-criteria.md](references/09-acceptance-criteria.md)

## Routing Rules (Intent -> Workflow)

- User references a PR, branch, or slice number -> run review-fix workflow first.
- User asks to republish or regenerate whole stack -> run publish workflow.
- User says a slice has merged into epic -> run advance workflow.
- User asks for current health only -> run status workflow.
- User says stack is done -> run clean workflow.

Default write path for review comments is `04-workflow-review-fixes`.

## Branch Targeting Policy (Explicit)

If user references a PR/branch/slice, that is the landing target.

- Example mapping in this skill: PR `#378` maps to slice branch `04`.
- Therefore fixes for PR `#378` land on slice `04` first, not on tip `05`.

If target cannot be resolved from context, ask exactly one direct question and block writes until answered.

## Restack Policy (Explicit)

After changing target slice `N`:

1. keep the fix commit(s) on `N`
2. rebuild/restack only descendants `N+1..tip`
3. do not rewrite ancestors `1..N-1`
4. do not drop fix directly onto tip-only branch

## Invariants (Reframed)

- `tip == work` is a validation outcome after publish/restack.
- `tip == work` is never used to decide where a fix should be placed.
- locked slices remain immutable.

## Safety Rules

- run preflight before writes
- create backups before rewriting branch refs
- use `--force-with-lease` only
- never rewrite locked slices

## Output Contract

For any workflow execution, report:

1. resolved user intent and target slice
2. branches changed (target vs descendants)
3. invariant validation results (`tip == work`, lock integrity)
4. one recommended next step

## Skill Assets

- template: `assets/epic.template.yml`
- acceptance examples: `references/09-acceptance-criteria.md`
