---
name: epic-helpers
description: Agent workflow for turning a messy feature work branch into a stable review stack and maintaining it through sequential merges. Use when reasoning about epic-<feature>, <feature>/work, and <feature>/<NN>-<details>, including health checks, planning, publish/restack, post-merge advance, and cleanup.
---

# Epic Helpers

This is an agent reasoning skill, not a standalone CLI product. Treat it as a playbook for deciding what to do, what to validate, and which Git operations to run.

The goal is to keep day-to-day development fast on `<feature>/work` while maintaining a clean, deterministic review stack of slice branches.

## How This Skill Is Structured

Use progressive disclosure and load only what you need:

1. Core contract (always load first)
   - [references/00-core-contract.md](references/00-core-contract.md)
2. Function playbook (load one or more based on intent)
   - [references/10-command-status.md](references/10-command-status.md)
   - [references/20-command-plan.md](references/20-command-plan.md)
   - [references/30-command-publish.md](references/30-command-publish.md)
   - [references/40-command-advance.md](references/40-command-advance.md)
   - [references/50-command-clean.md](references/50-command-clean.md)
3. Recovery (load only when something fails)
   - [references/90-recovery.md](references/90-recovery.md)
4. Template asset
   - `assets/plan.template.yml`

## Progressive Disclosure

Do not read every reference file up front. Start with the core contract, then load only the function playbook that matches the user goal.

## Normal Agent Functions

These are conceptual functions you execute while reasoning. The reference files contain the full operational detail.

- `assess_stack(feature)`
  - Purpose: evaluate branch health and invariant status without writes.
  - Reference: [references/10-command-status.md](references/10-command-status.md)
  - Typical outcome: pass/fail report and the next recommended action.

- `shape_plan(feature)`
  - Purpose: create or validate `.stack/<feature>/plan.yml` so slicing is stable.
  - Reference: [references/20-command-plan.md](references/20-command-plan.md)
  - Typical outcome: valid plan or actionable assignment fixes.

- `publish_stack(feature)`
  - Purpose: regenerate unmerged slices from `epic..<work>` while keeping locked slices immutable.
  - Reference: [references/30-command-publish.md](references/30-command-publish.md)
  - Typical outcome: rewritten unlocked slice branches with tip tree equal to work tree.

- `advance_stack(feature, merged_id)`
  - Purpose: after slice merge, lock merged range and restack remaining slices.
  - Reference: [references/40-command-advance.md](references/40-command-advance.md)
  - Typical outcome: updated locked set, rebuilt unmerged slices, work reset to new tip.

- `finalize_stack(feature)`
  - Purpose: clean disposable branches once epic integration is complete.
  - Reference: [references/50-command-clean.md](references/50-command-clean.md)
  - Typical outcome: work branch removed and optional slice cleanup done.

If any function fails at checks or push time, load [references/90-recovery.md](references/90-recovery.md) and run the smallest safe recovery.

## Function Selection Guide

- User asks "what is broken / where are we?" -> run `assess_stack`.
- User asks to define or fix slicing boundaries -> run `shape_plan`.
- User asks to generate or refresh review branches -> run `publish_stack`.
- User says slice K merged into epic -> run `advance_stack`.
- User says epic is fully merged and wants cleanup -> run `finalize_stack`.

## Non-Negotiable Rules

- Run preflight before any write command.
- Use `--force-with-lease`, never plain `--force`.
- Never rewrite locked slices.
- Treat `<feature>/work` as the only human-edit branch.
- Keep deterministic behavior: same plan and same trees should produce the same slice trees.

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

- Plan template: `assets/plan.template.yml`
