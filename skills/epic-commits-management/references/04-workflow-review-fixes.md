# Workflow: Apply Review Fixes To The Correct Slice

Use this workflow when user asks to address review comments, PR feedback, or "fix slice X".

This is the default write workflow for stacked reviews.

## Goal

Land each fix on the intended slice branch first, then restack descendants only.

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

### 3) Apply fix on target branch `N`

1. switch to target branch
2. make code change for the review comment
3. commit on target branch

Hard rule:

- do not place this fix directly on tip when target is non-tip

### 4) Restack descendants only

Given target index `N` in ordered slices:

- rebuild `N+1..tip`
- do not rewrite `1..N-1`
- keep locked slices immutable

Use publish mechanics from `05-command-publish.md` for rebuilt descendants.

### 5) Validate

1. target branch contains fix
2. descendants are rebased/restacked on new target head
3. `tip == work` holds after restack

### 6) Push safely

- push changed branches with `--force-with-lease`
- never plain `--force`

## Ambiguity Handling

If target cannot be resolved, ask exactly one direct question.

Preferred wording:

"I cannot resolve the landing slice from context. Should this fix land on `04` or `05`?"

No writes before answer.

## Concrete Examples (04/05)

### Example A: PR-targeted fix

Context:

- Slices: `01 -> 02 -> 03 -> 04 -> 05`
- User: "Address comments on PR 378"
- PR 378 head branch resolves to slice `04`

Required behavior:

1. commit fix on `04`
2. restack only `05`
3. do not skip `04` and commit directly on `05`

### Example B: Direct slice mention

Context:

- User: "Please fix review note on branch 04"

Required behavior:

1. commit on `04`
2. restack `05` only

### Example C: Tip-targeted fix

Context:

- User: "Fix typo in slice 05"

Required behavior:

1. commit on `05`
2. restack descendants set is empty
3. still validate `tip == work`

### Example D: Ambiguous request

Context:

- User: "Address latest feedback"
- No PR/branch/slice reference and no deterministic mapping

Required behavior:

1. ask one direct question (`04` or `05`)
2. do not write until answer

## Output Contract

Return:

1. resolved target and evidence (PR -> branch mapping if used)
2. fix commit location
3. descendants restacked
4. `tip == work` validation result
5. one next step
