# Function Reference: generate_stacks

Function:

```text
generate_stacks(feature, merged_branch?)
```

## Purpose

Use one entrypoint to coordinate the three connected write operations:

1. spec generation or spec sync
2. publish/rebuild of unlocked slices
3. optional post-merge lock + restack

This function replaces running separate planning/publish/advance flows in most cases.

## What To Load With This File

- Always load: `01-core-contract.md`
- Load internals only when needed:
  - spec details: `03-command-plan.md`
  - publish details: `05-command-publish.md`
  - advance details: `06-command-advance.md`
- On failure: `10-recovery.md`

## Input Contract

- `feature` is required.
- `merged_branch` is optional and used when a slice branch was just merged into epic.

Derived names:

- base: `epic-<feature>`
- work: `<feature>/work`
- spec file: `.stack/<feature>/epic.yml`

Spec ownership policy:

- Epic spec is authored and committed on `<feature>/work`.
- Publish uses the `epic.yml` from `<feature>/work`.

## High-Level Flow

### 0) Run preflight and branch checks

Before any writes, run the mandatory preflight from `01-core-contract.md`.

If base branch or work branch is missing, stop and report anomaly with recovery guidance.

### 1) Resolve stack spec state

Check whether `.stack/<feature>/epic.yml` exists.

#### If spec is missing

Ask the user one targeted question:

- "No stack spec exists at `.stack/<feature>/epic.yml`. Generate one now from current `epic..<work>` changes?"

If user approves:

1. bootstrap spec from `assets/epic.template.yml`
2. infer initial ordered slices from commit and directory clusters
3. write `.stack/<feature>/epic.yml` on `<feature>/work`
4. commit the new spec on `<feature>/work`
5. report generated slice order and continue to Step 2

If user declines:

- stop and report that stack generation cannot continue without spec

#### If spec exists

- continue to Step 2

### 2) Sync spec against current work branch

Validate and update only spec metadata (order, branch names, intents).

Rules:

- each slice has `branch_name` and `intent`
- branch names remain stable whenever possible
- do not rename locked slice branches

Behavior:

- if update is deterministic, apply spec update directly
- if update is ambiguous, stop and report anomaly with concrete suggested edits

When spec changes are applied:

1. apply spec edits on `<feature>/work`
2. commit spec updates on `<feature>/work`
3. continue publish from the updated work branch

Do not leave spec changes only in a detached workspace.

### 3) Publish unlocked slices

After spec is valid and ready:

1. rebuild unlocked slices from `epic..<work>`
2. keep locked slices immutable
3. verify tip tree equals work tree
4. push rewritten unlocked slices with `--force-with-lease`

### 4) Optional advance behavior

If `merged_branch` is provided:

1. verify merged slice status (ancestry or PR proof)
2. lock all plan-ordered slices up to merged branch
3. rebuild remaining unlocked slices
4. reset `<feature>/work` to new tip

If `merged_branch` is not provided, skip lock progression.

## Anomaly Contract (must tell user)

Stop and report clearly when any of these occur:

- work branch missing
- base branch missing
- spec file missing and user declined generation
- spec commit on `<feature>/work` failed
- slice ownership inference is ambiguous or incomplete
- locked slice would be rewritten
- tip tree does not equal work tree after publish
- push rejected even with `--force-with-lease`

For each anomaly include:

1. what failed
2. where it failed
3. one concrete recovery action

## Output Contract

Return a concise summary:

1. Spec state
   - generated/updated/unchanged/blocked and whether committed on work
2. Stack updates
   - branches rebuilt/unchanged/locked
3. Validation
   - tip==work and locked integrity
4. Advance state
   - lock progression applied or not applicable
5. Next step
   - one recommended follow-up action
