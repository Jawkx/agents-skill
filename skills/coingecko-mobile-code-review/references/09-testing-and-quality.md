# Testing & Quality Gates

## When tests are required
Strongly expect tests for:
- reducers/selectors/epics
- utils (pure logic)
- services (response parsing, error mapping)
- bug fixes (regression coverage)

## What to look for
- Tests cover:
  - success path
  - failure path
  - edge cases
- Assertions are meaningful (not just snapshot spam).
- Mocks are scoped and realistic; avoid over-mocking internals.

## CI/lint/typecheck readiness
- No unused vars/imports
- No eslint disable comments without justification
- Types pass under repo TS settings
- New code follows existing patterns (do not introduce a second style)

## Review guidance
If tests are missing:
- classify as **Must fix** when change is risky/critical path
- otherwise **Should fix**, with a clear suggested test approach
