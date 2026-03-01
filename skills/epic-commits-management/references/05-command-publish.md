# Workflow: Publish Stack From Work

Command:

```bash
stack publish <feature>
```

## Intent

Use this when user explicitly wants full stack publish/rebuild from `<feature>/work`.

Do not use this workflow as a shortcut for PR-targeted fixes. For review comments, use `04-workflow-review-fixes.md`.

## Inputs

- base: `epic-<feature>`
- work: `<feature>/work`
- epic spec: `.stack/<feature>/epic.yml`

## Detailed Procedure

### 1) Run mandatory preflight

Run the shared preflight from `01-core-contract.md`.

If preflight fails, stop.

### 2) Load epic spec and resolve lock set

1. Parse epic spec slices in listed order (`slices[].branch_name`).
2. For each existing slice branch, detect merged status:
   - `git merge-base --is-ancestor <slice-branch> epic-<feature>`
3. Treat merged slices as locked.
4. Never rewrite locked slices.

### 3) Emit pre-generation placement report (implicit mode only)

Run this only when user did not explicitly specify PR/branch/slice target.

1. Identify commit(s) present on `<feature>/work` but not on tip slice.
2. Infer landing slice candidate(s) from path ownership and epic spec intent.
3. Print a placement report before writes:
   - commit(s) being placed
   - mapping evidence
   - chosen landing slice `N`
   - descendants to rewrite `N+1..tip`
4. If mapping is ambiguous, stop and ask one direct target question.

Skip this report when:

- user explicitly tells where commit should land, or
- request is PR-targeted (place on PR head branch)

### 4) Resolve slice scopes for this publish

Epic spec does not define `paths`, so ownership is runtime-resolved.

1. Get diff entries from `epic..<work>`:
   - `git diff --name-status --no-renames epic-<feature>..<feature>/work`
2. Infer ownership from existing slice history and slice `intent`.
3. Fail on:
   - unassigned path
   - ambiguous path

Include actionable suggestions in the failure report.

### 5) Prepare rewrite backups

Create backup refs for each branch that may move:

- all unlocked slice branches that already exist
- `<feature>/work` if it will be repointed

### 6) Build stack on a temp branch

1. Create temp build branch from base:
   - `git switch -c tmp/epic-commits-management/<feature>/<timestamp> epic-<feature>`
2. Iterate slices in spec order.

For each slice:

- If locked:

  - do not modify branch
  - continue

- If unlocked:
  1. Apply assigned paths from work to current temp HEAD.
     - existing-at-work paths: `git checkout <feature>/work -- <path>`
     - deleted-at-work paths: `git rm --ignore-unmatch -- <path>`
  2. Stage: `git add -A`
  3. If there are staged changes:
     - `git commit -m "<branch_name>: <intent>"`
  4. If no staged changes:
     - keep current HEAD and mark slice as empty in report output
  5. Point slice branch to current HEAD:
     - `git branch -f <branch_name> HEAD`

### 7) Validate final invariants

1. Resolve tip as last spec slice.
2. Verify tip equals work:
   - `git diff --quiet <tip-slice>..<feature>/work`
3. If mismatch, stop and report file-level divergence.

Interpretation rule:

- `tip == work` here is a post-publish validation.
- It does not define where future review fixes should land.

### 8) Run branch validation gate before any push

1. Build list of rewritten branches in this run (target + rewritten descendants).
2. For each rewritten branch, checkout branch ref and run the repo validation
   command (at minimum typecheck/build command defined by repo guidance).
3. If any branch fails validation:
   - stop immediately
   - do not push rewritten branches
   - report failing branch and command output summary

Goal:

- prevent publishing a stack where an intermediate slice compiles only because
  later slices add missing dependencies.

### 9) Do not write persistent state

- Do not create or update `.stack/<feature>/state.json`.
- Report runtime ownership/empty slices directly in command output.

### 10) Push rewritten branches

Push only unlocked slice branches that changed:

- `git push --force-with-lease origin <branch_name>`

Never push locked slices with force updates.

### 11) Optional work realignment

If policy is to keep work pinned to tip:

- `git branch -f <feature>/work <tip-slice>`
- `git push --force-with-lease origin <feature>/work`

## Edge Cases

### Empty slices

- Keep branch at current HEAD.
- Preserve slice order; do not auto-delete slice entries.

### Spec changed after merges

- Locked slices remain immutable regardless of spec edits.
- Apply spec changes only to unlocked slices.

### Publish invoked after a targeted fix on slice `N`

- Keep target fix on `N`.
- Rebuild descendants `N+1..tip`.
- Never relocate fix to tip-only branch.

## Output Format

- Result (`pass` or `fail`)
- Rebuilt slices (with old/new heads)
- Placement note (full publish vs targeted-restack mode)
- Locked slices untouched
- Ownership issues (if any)
- Tip equality status (validation)
- Next recommended command
