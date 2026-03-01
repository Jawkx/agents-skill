# Behavior Summary And Acceptance Criteria

## Before vs After (Short)

Before:

- workflow language centered on pseudo-function orchestration
- branch placement for review fixes could be inferred indirectly from tip/work state
- descendant restack expectations were not explicit in review-comment scenarios

After:

- workflow language is intent-first and review-comment driven
- PR/branch/slice references resolve to explicit landing branch first
- after slice `N` changes, only `N+1..tip` are restacked
- `tip == work` is validation output, not placement policy

## Acceptance Criteria

### 1) PR-targeted fixes land on the PR branch

Given:

- stack order includes slices `04` and `05`
- PR `378` head resolves to slice `04`
- user asks to address PR `378` comments

Must be true:

1. fix commit is created on slice `04`
2. slice `05` is restacked after `04` update
3. fix is not committed directly to `05` unless user explicitly targeted `05`

### 2) Descendant restack behavior is explicit

Given:

- target slice is `N`

Must be true:

1. rewritten branches are exactly `N+1..tip`
2. branches `1..N-1` are untouched
3. locked slices are never rewritten

### 3) `tip == work` is validation, not placement

Given:

- any review-fix workflow invocation

Must be true:

1. target placement is resolved before invariant checks
2. invariant check runs after restack/publish
3. docs never instruct selecting landing branch from `tip == work`

### 4) Ambiguity handling is direct and bounded

Given:

- no resolvable PR/branch/slice signal in user request

Must be true:

1. assistant asks one direct question
2. no branch writes occur before answer
3. question asks for concrete target choice (example: `04` vs `05`)

### 5) Publish/advance validates rewritten slices before push

Given:

- a run rewrites one or more slice branches

Must be true:

1. each rewritten branch runs repo validation gate before push
2. failure in any branch blocks all pushes for that run
3. report identifies failing branch and failing command

### 6) Dirty-tree handling preserves user edits

Given:

- preflight detects non-clean tree with unrelated local edits

Must be true:

1. workflow does not reset or discard user edits
2. writes run from a dedicated temporary worktree under repo parent by default
3. `/tmp` is used only when user explicitly requests it

### 7) Regenerate requests publish placement decision before restack

Given:

- user asks to `generate`/`regenerate` stack
- request does not explicitly name PR/branch/slice target

Must be true:

1. assistant reports chosen landing slice before any rebase/restack writes
2. report includes evidence used for placement decision
3. report includes planned descendant rewrite scope (`N+1..tip`)

Exception behavior:

- explicit user target: place exactly where instructed
- PR-targeted request: place on PR head branch
