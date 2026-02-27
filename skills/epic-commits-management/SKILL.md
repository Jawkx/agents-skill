---
name: epic-commits-management
description: Agent workflow for turning a messy feature work branch into a stable review stack and maintaining it through sequential merges. Use when reasoning about epic-<feature>, <feature>/work, and ordered slice branches defined in epic.yml, including health checks, planning, publish/restack, post-merge advance, and cleanup.
---

# Epic Commits Management

This is an agent reasoning skill, not a standalone CLI product. Treat it as a playbook for deciding what to do, what to validate, and which Git operations to run.

The goal is to keep day-to-day development fast on `<feature>/work` while maintaining a clean, deterministic review stack of slice branches.

## How This Skill Is Structured

Use progressive disclosure and load only what you need:

1. Core contract (always load first)
   - [references/01-core-contract.md](references/01-core-contract.md)
2. Function playbook (load one or more based on intent)
   - [references/02-command-status.md](references/02-command-status.md)
   - [references/04-function-generate-stacks.md](references/04-function-generate-stacks.md)
   - [references/07-command-clean.md](references/07-command-clean.md)
3. Recovery (load only when something fails)
   - [references/10-recovery.md](references/10-recovery.md)
4. Template asset
   - `assets/epic.template.yml`

## Progressive Disclosure

Do not read every reference file up front. Start with the core contract, then load only the function playbook that matches the user goal.

## Normal Agent Functions

These are conceptual functions you execute while reasoning. The reference files contain the full operational detail.

- `assess_stack(feature)`

  - Purpose: evaluate branch health and invariant status without writes.
  - Reference: [references/02-command-status.md](references/02-command-status.md)
  - Typical outcome: pass/fail report and the next recommended action.

- `generate_stacks(feature, merged_branch?)`

  - Purpose: single orchestrator for spec generation/sync, stack publish, and optional post-merge advance.
  - Reference: [references/04-function-generate-stacks.md](references/04-function-generate-stacks.md)
  - Typical outcome: spec exists and is up to date, unlocked slices are rebuilt, and merged range is locked when requested.

- `finalize_stack(feature)`
  - Purpose: clean disposable branches once epic integration is complete.
  - Reference: [references/07-command-clean.md](references/07-command-clean.md)
  - Typical outcome: work branch removed and optional slice cleanup done.

If any function fails at checks or push time, load [references/10-recovery.md](references/10-recovery.md) and run the smallest safe recovery.

## Function Selection Guide

- User asks "what is broken / where are we?" -> run `assess_stack`.
- User asks to define/fix specs, publish stack, or restack after merge -> run `generate_stacks`.
- User says epic is fully merged and wants cleanup -> run `finalize_stack`.

`generate_stacks` is the default write path for this skill.

## Non-Negotiable Rules

- Run preflight before any write command.
- Use `--force-with-lease`, never plain `--force`.
- Never rewrite locked slices.
- Treat `<feature>/work` as the only human-edit branch.
- Keep stack spec in `.stack/<feature>/epic.yml` on `<feature>/work` as source of truth.
- Keep deterministic behavior: same epic spec and same trees should produce the same slice trees.

## Default Reasoning Mode

- Use rebuild mode for MVP behavior.
- Prefer tree-based checks over commit ancestry assumptions.
- Keep reports short, explicit, and action-oriented.

## Output Expectations

For any function execution, return:

1. what was checked
2. what changed (or why nothing changed)
3. invariant status
4. one best next step

## Skill Assets

- Epic template: `assets/epic.template.yml`
