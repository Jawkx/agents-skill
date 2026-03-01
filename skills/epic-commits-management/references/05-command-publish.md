# Workflow: Publish Stack From Work

Command:

```bash
stack publish <feature>
```

Use when user explicitly wants full stack publish/rebuild from `<feature>/work`.
Do not use this as a shortcut for PR-targeted review fixes.

## Inputs

- base: `epic-<feature>`
- work: `<feature>/work`
- spec: `.stack/<feature>/epic.yml`

## Procedure

### 1) Preflight

Run mandatory write preflight from `01-core-contract.md`.

### 2) Resolve slices and lock set

1. Read ordered slices from spec.
2. Mark locked slices merged into base:
   - `git merge-base --is-ancestor <slice-branch> epic-<feature>`
3. Never rewrite locked slices.

### 3) Placement report (implicit generate/regenerate mode only)

Run only when the request is generate/regenerate without explicit PR/branch/slice
target.

Report before writes:

1. commits present on work but not tip
2. mapping evidence
3. chosen landing slice `N`
4. rewrite scope `N+1..tip`

If mapping is ambiguous, ask one direct question and stop.

### 4) Resolve ownership for this run

Spec has no path map, so resolve ownership at runtime from:

- `git diff --name-status --no-renames epic-<feature>..<feature>/work`
- existing slice history
- slice intent text

Fail on unassigned or ambiguous paths with actionable guidance.

### 5) Create backups

Create backup refs for all branch pointers that may move:

- each unlocked slice that will be rewritten
- `<feature>/work` if it will be repointed

### 6) Rebuild on a temp branch

1. Create temp branch from base.
2. Iterate slices in spec order:
   - locked slice: skip
   - unlocked slice:
     - apply owned paths from work
       - existing path: `git checkout <feature>/work -- <path>`
       - deleted path: `git rm --ignore-unmatch -- <path>`
     - `git add -A`
     - commit if staged changes exist
     - `git branch -f <slice-branch> HEAD`

Empty slices are allowed; keep pointer at current HEAD.

### 7) Validate invariants

1. Resolve tip as last spec slice.
2. Verify `tip == work`:
   - `git diff --quiet <tip-slice>..<feature>/work`
3. Stop and report divergence if mismatch.

### 8) Branch validation gate

Before any push, run repo validation command on each rewritten branch (at minimum
the repo's required typecheck/build/lint gate).

If any rewritten branch fails:

- stop immediately
- do not push rewritten branches
- report failing branch and command summary

### 9) Push rewritten branches

Push changed unlocked slice branches only:

- `git push --force-with-lease origin <slice-branch>`

Never force-push locked slices.

### 10) Optional work alignment

If work should track tip:

- `git branch -f <feature>/work <tip-slice>`
- `git push --force-with-lease origin <feature>/work`

### 11) No persistent state file

Do not create or update `.stack/<feature>/state.json`.

## Output

- result (`pass`/`fail`)
- rebuilt branches (old/new heads)
- locked branches left untouched
- ownership issues (if any)
- `tip == work` status
- next command
