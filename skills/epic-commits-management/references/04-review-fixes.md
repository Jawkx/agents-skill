# Workflow: Apply Review Fixes To The Correct Slice

Use this workflow when user asks to address review comments, PR feedback, or "fix slice X".

This is the default write workflow for stacked reviews.

## Inputs

- `feature`
- user intent text (may include PR number, branch, slice id)
- `.stack/<feature>/epic.yml`

## Procedure

### 1) Run write preflight

Use shared preflight from `01-core-contract.md`.

### 2) Resolve target slice branch

Resolve in order:

1. explicit branch or slice in user text
2. explicit PR number -> resolve PR head branch
3. deterministic mapping from spec context
4. if unresolved, ask one direct question and stop

Do not continue with writes until target is known.

### 3) Optional placement report (inferred target only)

If target is inferred (not explicit and not PR-head resolved), print a short
report before writing:

1. why this slice was chosen
2. which commit/change is being placed
3. descendants that will be restacked (`N+1..tip`)

### 4) Apply fix on `<feature>/work` first

1. switch to `<feature>/work`
2. make code change for the review comment
3. run typecheck on work branch (`yarn tsc` unless repo override)
4. commit on work branch

Hard rule:

- even when target is non-tip, author the fix on work first
- target branch determines final landing slice during regeneration

### 5) Regenerate stack and place fix on target `N`

Given target index `N` in ordered slices:

- regenerate from work so the fix lands on slice `N`
- rebuild `N+1..tip`
- do not rewrite `1..N-1`
- keep locked slices immutable
- align `<feature>/work` to regenerated tip plus work-only
  `.stack/<feature>/epic.yml`

Use publish mechanics from `05-publish.md` for regeneration and branch rewrites.

### 6) Validate

1. target branch contains fix after regeneration
2. descendants are rebased/restacked on new target head
3. tip/work diff is metadata-only (`.stack/<feature>/epic.yml`)
4. cross-branch typecheck passes on target + all rewritten descendants (+ work
   when moved/repointed)

### 7) Push safely

- push fast-forward branches normally
- push rewritten branches with `--force-with-lease`
- never plain `--force`
- do not push if any changed branch fails `yarn tsc`

## Ambiguity Handling

If target cannot be resolved, ask exactly one direct question.

Preferred wording:

"I cannot resolve the landing slice from context. Should this fix land on `04` or `05`?"

No writes before answer.

## Output Contract

Return:

1. resolved target and evidence (PR -> branch mapping if used)
2. fix commit on work and final landing slice
3. descendants restacked
4. tip/work metadata-only diff validation result
5. one next step
