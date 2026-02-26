# Function Reference: generate_stacks

Function:

```text
generate_stacks(feature, merged_id?)
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
- `merged_id` is optional and used when a slice was just merged into epic.

Derived names:

- base: `epic-<feature>`
- work: `<feature>/work`
- spec file: `.stack/<feature>/plan.yml`

## High-Level Flow

### 0) Run preflight and branch checks

Before any writes, run the mandatory preflight from `01-core-contract.md`.

If base branch or work branch is missing, stop and report anomaly with recovery guidance.

### 1) Resolve stack spec state

Check whether `.stack/<feature>/plan.yml` exists.

#### If spec is missing

Ask the user one targeted question:

- "No stack spec exists at `.stack/<feature>/plan.yml`. Generate one now from current `epic..<work>` changes?"

If user approves:

1. bootstrap spec from `assets/plan.template.yml`
2. infer initial slices from changed-path clusters (stable directory ownership first)
3. write `.stack/<feature>/plan.yml`
4. report generated slices and continue to Step 2

If user declines:

- stop and report that stack generation cannot continue without spec

#### If spec exists

- continue to Step 2

### 2) Sync spec against current work branch

Validate and update spec based on `git diff --name-status --no-renames epic-<feature>..<feature>/work`.

Rules:

- every changed path must map to exactly one slice
- preserve slice ID stability whenever possible
- do not mutate locked slice IDs

Behavior:

- if update is deterministic (for example obvious new path under an existing slice), apply spec update directly
- if assignment is ambiguous, stop and report anomaly with concrete suggested edits

### 3) Publish unlocked slices

After spec is valid and synced:

1. rebuild unlocked slices from `epic..<work>`
2. keep locked slices immutable
3. verify tip tree equals work tree
4. push rewritten unlocked slices with `--force-with-lease`

### 4) Optional advance behavior

If `merged_id` is provided:

1. verify merged slice status (ancestry or PR proof)
2. lock `01..merged_id`
3. rebuild remaining unlocked slices
4. reset `<feature>/work` to new tip

If `merged_id` is not provided, skip lock progression.

## Anomaly Contract (must tell user)

Stop and report clearly when any of these occur:

- work branch missing
- base branch missing
- spec file missing and user declined generation
- ambiguous/unassigned file ownership
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
   - generated, synced, unchanged, or blocked
2. Stack updates
   - branches rebuilt/unchanged/locked
3. Validation
   - tip==work and locked integrity
4. Advance state
   - lock progression applied or not applicable
5. Next step
   - one recommended follow-up action
