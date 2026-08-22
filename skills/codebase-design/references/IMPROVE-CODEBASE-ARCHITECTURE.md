# Improve codebase architecture

Read this reference only when the user explicitly requests an architecture improvement, audit, assessment, or search for deepening opportunities across a codebase or subsystem.

The review finds architectural friction and proposes ways to turn shallow modules into deeper ones. It does not begin by inventing new interfaces.

## 1. Set the scope

Avoid scanning the entire repository without a reason.

- If the user named a module, subsystem, repeated pain point, or change direction, use that scope.
- Otherwise inspect a useful stretch of history with `git log --oneline` and `git log --stat` to identify files and areas that change repeatedly.
- If history has no clear hot spot, widen the scan gradually.
- Read repository instructions and relevant technical documentation before judging the code.

Tell the user which paths you will inspect and why.

## 2. Explore the code

Use one or more sub-agents for a large repository when available. Give each a bounded area and require file evidence.

Explore organically rather than forcing every finding through a rigid heuristic. Look for:

- Understanding one behavior requires jumping among many small modules.
- A module's interface is nearly as complicated as its implementation.
- Callers repeat the same ordering, validation, mapping, retry, or error handling.
- Closely coupled modules leak implementation knowledge across seams.
- Tests target private helpers while integration mistakes remain uncovered.
- A behavior is difficult to test through its current interface.
- Recently changed code repeatedly touches the same cluster of files.

Apply the deletion test to each suspected shallow module. If deletion merely moves its complexity into callers, it was providing value. If deletion removes indirection without spreading meaningful behavior, it is a stronger deepening candidate.

## 3. Build evidence-backed candidates

Do not force a fixed number. Keep only candidates supported by code evidence.

For each candidate, record:

- Files and modules involved
- Current callers and call flow
- The interface callers must understand today
- The behavior or knowledge spread among callers
- Dependency category from [`DEEPENING.md`](DEEPENING.md)
- Existing tests and what they can observe
- The likely deepening direction, without proposing a final interface
- Expected deletions and migration risks
- Recommendation strength: `Strong`, `Worth exploring`, or `Speculative`

Reject candidates that only rename files, add an interface with one unchanged adapter, or place another pass-through module over existing code.

## 4. Present a visual report

Read [`HTML-REPORT.md`](HTML-REPORT.md), then write a self-contained HTML report outside the repository.

Resolve the temporary directory from `$TMPDIR`, then `/tmp` on Unix-like systems, or `%TEMP%` on Windows. Use a fresh path:

```text
<tempdir>/architecture-review-<timestamp>.html
```

Open it with the platform command when possible:

- Linux: `xdg-open <path>`
- macOS: `open <path>`
- Windows: `start <path>`

Tell the user the absolute path.

Each candidate must show:

- Files
- Problem
- Deepening direction
- Benefits stated as locality, leverage, and test improvements
- Before and after diagram
- Recommendation strength
- Dependency category

Finish with one top recommendation and a concrete reason it should go first.

Do not propose final interfaces in the report. Ask: "Which candidate would you like to explore?"

## 5. Explore the selected candidate

Once the user chooses, work through the decision in small steps:

1. Confirm the pain with a concrete recent or representative change.
2. Identify callers and the behavior each currently coordinates.
3. Classify dependencies and decide which seams are external or internal.
4. Decide what behavior belongs behind the deepened interface.
5. Identify constraints, failure modes, ordering rules, and performance requirements.
6. Decide which current modules and tests should disappear.
7. Define migration stages and rollback points.
8. Specify tests through observable behavior at the new interface.

Ask focused questions only where the answer changes the design. Do not turn the process into a generic questionnaire.

If alternative interfaces would help, read [`DESIGN-IT-TWICE.md`](DESIGN-IT-TWICE.md). Otherwise propose one interface and explain why it offers depth, locality, and a useful seam.

## 6. Implementation handoff

Before editing code, provide:

- Chosen interface and complete behavioral contract
- What moves behind the seam
- Dependency and adapter plan
- Caller migration order
- Tests to add, replace, and delete
- Old modules and compatibility code to remove
- Risks and verification commands

Implement only when the user asks. The review itself may stop after the report or design recommendation.
