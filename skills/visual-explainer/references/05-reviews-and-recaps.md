# Reviews And Recaps

Use these workflows for evidence-heavy pages where the reader needs both a headline and traceable supporting detail.

## Diff Review

Before writing HTML:

- inspect the full diff scope, not just one file
- read changed files and relevant neighbors
- verify counts, behaviors, new APIs, tests, and docs impact
- collect anything that should be called out as uncertain

Common sections:

1. Executive summary
2. Scope and KPI strip
3. Architecture or flow changes
4. Major before and after comparisons
5. File map or affected areas
6. Test and docs coverage
7. Good, bad, ugly, and open questions
8. Re-entry notes or hidden gotchas

## Plan Or RFC Review

Compare what the plan claims against the actual codebase.

Gather:

- the plan's problem statement and proposed changes
- current files and behavior the plan depends on
- missing ripple effects, hidden dependencies, and untested assumptions

Common sections:

1. Plan summary
2. Current vs planned architecture
3. Change-by-change review
4. Dependency and ripple analysis
5. Risks and unanswered questions
6. Recommendation or readiness assessment

## Project Recap

Use this to restore a working mental model after time away.

Gather:

- project identity from README and manifest files
- recent git activity and hot spots
- current branch or workspace state
- major modules, decisions, and unresolved debt

Common sections:

1. What this project is and where it stands
2. Architecture snapshot
3. Recent activity by theme
4. Decision log
5. State of things: working, in progress, broken, blocked
6. Mental model essentials
7. Cognitive debt hot spots
8. Likely next steps

## Fact Check Against Code

Turn the document into a claims matrix.

- Break claims into rows.
- Mark each one `confirmed`, `partial`, `unsupported`, or `contradicted`.
- Cite file paths, lines, or command output for each verdict.
- Lead with the highest-risk discrepancies, then show the full table.

If the document is mostly accurate, still call out the most important stale or ambiguous claims so the page earns its keep.
