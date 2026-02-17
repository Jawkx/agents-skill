---
name: simplify-code
description: Simplify existing code while staying pragmatic about scope, risk, and delivery speed. Use when refactoring hard-to-read logic, reducing unnecessary abstraction, removing dead code, clarifying names and structure, or making code easier to change without breaking behavior.
---

# Simplify Code

Make code easier to read, reason about, and modify, while preserving behavior and avoiding over-engineering.

## Working Principles

- Preserve behavior first; simplify structure second.
- Prefer clear local code over clever global abstractions.
- Remove accidental complexity before adding new patterns.
- Favor small, reversible refactors over broad rewrites.
- Keep public contracts stable unless the user explicitly requests changes.

## Pragmatism Guardrails

- Do not refactor stable code just to match personal style.
- Do not add abstractions for hypothetical future use.
- Do not optimize unless there is evidence of a bottleneck.
- Accept small duplication when abstraction makes code harder to follow.
- Stop when additional cleanup has low impact on maintainability.

## Simplification Workflow

1. Confirm constraints.
   - Identify behavior that must stay unchanged.
   - Note API, schema, and compatibility boundaries.
2. Identify complexity hotspots.
   - Look for long functions, deep nesting, noisy branching, unclear naming, pass-through layers, and dead paths.
3. Pick the smallest high-impact refactor.
   - Keep edits cohesive and easy to review.
4. Apply changes in this order.
   - Remove dead code.
   - Reduce indirection.
   - Clarify naming and intent.
   - Reshape control flow.
   - Extract only cohesive units.
5. Verify.
   - Run targeted tests for impacted paths first, then broader checks as needed.
6. Explain tradeoffs.
   - State what improved, what was intentionally left alone, and why.

## Preferred Transformations

- Replace nested conditionals with guard clauses when readability improves.
- Replace flag-heavy function signatures with clearer function boundaries.
- Inline one-off wrappers that add no meaning.
- Collapse pass-through helper layers.
- Replace vague names (`manager`, `helper`, `util`) with domain-specific names.
- Isolate unavoidable complexity behind explicit interfaces.

## Avoid These Anti-Patterns

- Mixing behavior changes with broad cleanup in one patch.
- Renaming aggressively without structural improvement.
- Introducing framework-level patterns for local problems.
- Hiding complexity behind generic names.
- Splitting logic into too many tiny functions with unclear flow.

## Decision Rules

If two options are both correct:

- Choose the one with fewer concepts to keep in mind.
- Choose explicitness over cleverness.
- Choose the change that is easier to test and roll back.
- Choose consistency with existing project conventions unless that convention is the source of complexity.

## Done Criteria

Treat simplification as complete when:

- Behavior is preserved or intentional changes are clearly called out.
- Control flow is easier to follow.
- Naming better reflects domain intent.
- The modified area has fewer moving parts.
- Relevant tests and checks pass.

## Response Format

When reporting simplification work, include:

1. What was simplified.
2. Why the result is simpler.
3. What was intentionally unchanged.
4. Verification performed.
5. Optional next simplification steps, ordered by impact.
