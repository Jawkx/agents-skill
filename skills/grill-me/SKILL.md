---
name: grill-me
description: A relentless, user-invoked interview that sharpens a loose plan, decision, design, or idea before action.
---

# Grill Me

Interview the user relentlessly until you reach a shared understanding. This is a stateless inquiry: do not write files, produce a plan unprompted, or begin implementation.

The user may begin with a loose idea. Sharpening it is the purpose of the session; do not require a worked-out plan first.

## Design tree

Map the subject as a **design tree**: every decision branches into the decisions that depend on it.

Work the tree in **rounds**. The **frontier** is every unresolved decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you have not heard yet.

For each round:

1. Recompute the frontier from everything settled so far.
2. Ask the whole frontier, but never put two questions in the same round if one answer could affect the other.
3. Number every question and include your recommended answer.
4. Wait for the user's answers before recomputing and asking the next round.

Use this format:

```text
❓ **Q1** - **<question title>**: <question body, including choices when useful>

➡️ <your recommended answer>
```

If the harness provides a structured question tool, use it when it can preserve the frontier, choices, recommendations, and free-form answers. Otherwise ask in the format above. Do not split a frontier merely to force it into a tool's item limit.

## Facts and decisions

Finding **facts** is your job, never the user's. Inspect the available environment, files, tools, or sources for anything you can determine yourself. If parallel/background exploration is available, use it without stalling unrelated frontier questions; only questions downstream of an unsettled fact should wait.

The **decisions** are the user's. Put each decision to them and wait. Never answer a decision on their behalf. "I don't know" is a valid answer and may reveal that evidence or a prototype is needed.

## Steering and scope

The user owns the scope. Treat disagreement, corrections, uncertainty, and requests to narrow or stop as useful steering. Do not turn the session into a ritual where the user merely approves agent-authored conclusions.

If the interview grows excessively long, say that the scope may be too large and recommend splitting it into smaller subjects rather than silently truncating important branches.

Some questions are not grillable through conversation, especially questions about how an interaction should look or feel. When talking cannot settle a branch, identify it clearly and recommend building or gathering something concrete to react to. Do not keep rephrasing the same unanswerable question.

## Completion gate

The frontier is empty only when every relevant branch has been visited and nothing remains silently assumed. Summarize the resulting shared understanding, including unresolved items and any branches that need evidence or prototyping.

Then explicitly ask the user to confirm that the understanding is shared. Do not act on the result, write a specification, create files, or implement anything until the user confirms and separately asks for that action.
