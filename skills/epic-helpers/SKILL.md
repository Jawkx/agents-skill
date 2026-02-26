---
name: epic-helpers
description: Build and maintain clean, reviewable slice stacks from a messy feature work branch. Use when managing branches like epic-<feature>, <feature>/work, and <feature>/<NN>-<details>, including status checks, publish/restack, post-merge advance, and cleanup.
---

# Epic Helpers

This skill keeps day-to-day development fast on `<feature>/work`, while generating and maintaining a clean review stack of slice branches.

## Progressive Disclosure

Always read:
- [references/00-core-contract.md](references/00-core-contract.md)

Then read only the command reference needed for the user request:
- `stack status <feature>` -> [references/10-command-status.md](references/10-command-status.md)
- `stack plan <feature>` -> [references/20-command-plan.md](references/20-command-plan.md)
- `stack publish <feature>` -> [references/30-command-publish.md](references/30-command-publish.md)
- `stack advance <feature> --merged <NN>` -> [references/40-command-advance.md](references/40-command-advance.md)
- `stack clean <feature>` -> [references/50-command-clean.md](references/50-command-clean.md)

Read [references/90-recovery.md](references/90-recovery.md) only when checks fail, pushes are rejected, or rollback is needed.

Do not load every reference file by default.

## Command Surface

- `stack status <feature>`: read-only health and invariant checks
- `stack plan <feature>`: create or validate `.stack/<feature>/plan.yml`
- `stack publish <feature>`: rebuild/update unmerged slice branches from `epic..<work>`
- `stack advance <feature> --merged <NN>`: lock merged slices and restack remaining slices
- `stack clean <feature>`: delete disposable work branch and optional slice branches after completion

## Non-Negotiable Rules

- Run preflight before any write command.
- Use `--force-with-lease`, never plain `--force`.
- Never rewrite locked slices.
- Treat `<feature>/work` as the only human-edit branch.
- Keep deterministic behavior: same plan and same trees should produce the same slice trees.

## Default Mode

- Use rebuild mode for MVP behavior.
- Prefer tree-based checks over commit ancestry assumptions.
- Keep reports short, explicit, and command-oriented.

## Skill Assets

- Plan template: `assets/plan.template.yml`
