# Slice PR Template

Use this when creating/updating slice PR titles/bodies.

## Title format

`[Slice <id>/<N>] <short title>`

Example:
`[Slice 02/04] Domain logic for chart periods`

## Body template

### What this slice does

- ...
- ...

### What this slice does NOT do

- ...
- ...

### Dependencies / context

- Depends on: Slice 01 (if applicable)
- Follow-ups: Slice 03 covers UI wiring (if applicable)

### How to validate

- Tests: `...`
- Manual: `...`

### Reviewer notes

- This PR is part of a generated slice stack for `<feature>`.
- Mode: REVIEW → updates are additive delta commits (append-only); no force-push expected.
- Stack metadata lives on `<feature>`: `.feature-stack.md`
