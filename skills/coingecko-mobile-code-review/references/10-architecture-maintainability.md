# Architecture & Maintainability Rubric

## Complexity management
Flag for discussion / should-fix:
- Components doing too much (UI + fetching + formatting + navigation + analytics).
- Files that become "mega components" (hard to test, hard to reason about).
- Tangled hooks/effects without separation.

Suggested remedies:
- Extract custom hooks for data/side-effects.
- Split components into container/presentational pieces.
- Move parsing/formatting to utils/services.

## Abstraction sanity
- Avoid unnecessary abstractions that add coupling:
  - generic wrappers that hide behavior
  - indirection with no reuse or clarity win
- Prefer duplication over premature frameworks if it is small and local.

## Boundaries
- Keep network/data logic out of pure UI where possible.
- Keep navigation concerns near screens, not deep children (unless intentional).
- Keep redux action composition in epics/services, not scattered in UI.

## File/folder organization
- Ensure new files land in the correct directory.
- Naming consistent with repo conventions.
- Avoid circular imports and cross-layer reacharounds.
