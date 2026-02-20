# Slicing Guide (Heuristics)

Goal: slices should be small, coherent, and stable over time.

## Preferred slice ordering

1. Scaffold / types / feature flags / wiring
2. Pure refactors (no behavior change)
3. Core behavior / domain logic
4. UI / integration
5. Tests

## Slice shapes that review well

- "Introduce types + flag + wiring (no behavior change)"
- "Refactor module to accept new dependency / interface"
- "Implement behavior behind a flag"
- "Wire UI into behavior"
- "Add tests for behavior"

## Avoid these anti-patterns

- One slice mixing refactor + behavior + UI + tests
- Two slices repeatedly touching the same lines
- "Refactor touches everything" spread across many slices

## Handling big refactors

Prefer:

- One early slice: pure mechanical refactor (rename/move/types) with no behavior change
- Later slices: behavior and UI

## If you must insert after review begins

- Insert `02a-*` / `02b-*` slices rather than renumbering.
