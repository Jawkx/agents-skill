# Core Contract

Load this file first. It defines placement policy, restack scope, and safety rules.

## Mental Model

Operate by user intent, not by convenience branch state.

- Identify where the user expects the fix to land.
- Place the change there first.
- Restack downstream branches as needed.
- Validate invariants after placement.

Do not skip to tip-only placement because it is easier.

## Branch Roles

- base: `epic-<feature>`
- work: `<feature>/work`
- slices: ordered `slices[].branch_name` from `.stack/<feature>/epic.yml`

Shape:

```text
epic-<feature>
  <- <feature>/01-...
  <- <feature>/02-...
  <- <feature>/03-...
  <- <feature>/04-...
  <- <feature>/05-... (tip)
```

## Placement Policy (What Branch Gets the Fix)

Resolve target branch in this order:

1. explicit user reference
   - PR number
   - branch name
   - slice number (`04`, `05`)
2. deterministic mapping from context
   - PR head branch from `gh pr view`
   - unique spec match from `.stack/<feature>/epic.yml`
3. if unresolved, ask one direct question and pause writes

Hard rule:

- if user references PR/branch/slice, place fix on that branch first

Example:

- "Address PR 378" -> resolve PR 378 head -> slice `04` -> commit on `04`

## Restack Policy (What Moves After Fix)

After target slice `N` changes:

1. keep change on `N`
2. rebuild only descendants `N+1..tip`
3. do not rewrite ancestors `1..N-1`
4. do not move fix directly to tip branch unless target is tip

If `N` is tip, descendants set is empty.

## Invariants (Validation, Not Placement)

1. linear slice ancestry follows spec order
2. `tree(tip) == tree(work)` after publish/restack
3. locked slices are immutable
4. force updates use `--force-with-lease`

Important:

- `tip == work` is checked after branch placement and restack
- it does not choose the placement branch

## Epic Spec

Spec file: `.stack/<feature>/epic.yml`

Required fields:

- `feature`
- `base`
- `work`
- `slices[]` with `branch_name` and `intent`

Validation:

- `branch_name` values are unique
- order is explicit by list position
- intent is non-empty and stable

## Mandatory Preflight For Writes

Run before review-fix, publish, advance, and clean:

1. `git fetch --all --prune`
2. clean tree (`git status --porcelain` empty)
3. non-detached HEAD (`git branch --show-current` non-empty)
4. branch visibility for base, work, and target/rewritten slices
5. backup refs for every branch pointer that may move
6. enforce `--force-with-lease`

### Backup Naming

- `backup/<feature>/<timestamp>-<branch-slug>`
- timestamp: `YYYYMMDD-HHMMSS`
- slug: replace `/` with `--`

## Ambiguity Rule

When target cannot be resolved from the prompt, ask exactly one direct question.

Use this pattern:

"I cannot resolve the landing slice from context. Should this fix land on `04` or `05`?"

Do not ask multiple questions. Do not write branches before answer.

## Reporting Contract

Always report:

1. resolved target branch (and how it was resolved)
2. branch updates (target, descendants, untouched)
3. invariant checks (`tip == work`, locked integrity)
4. one next action
