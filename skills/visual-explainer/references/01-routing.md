# Routing

Use this skill when the best answer is a browser-readable artifact instead of a wall of text.

## Good Triggers

- Architecture overview
- System or workflow diagram
- Visual implementation plan
- Diff review or RFC review
- Project recap after context switching
- Fact-checking a document against code
- Feature matrix, audit table, comparison grid, or other dense structured output
- Slide deck or presentation-style explanation

## Do Not Force HTML

- The answer is short and naturally readable in plain text.
- The user explicitly wants raw Mermaid, Markdown, or source code only.
- The task is exploratory and the cost of producing HTML is higher than the value.

## Artifact Types

- `diagram page`: A system, flow, sequence, architecture, or concept explainer.
- `comparison page`: Tables, requirement audits, feature matrices, or status dashboards.
- `review page`: Diff reviews, plan reviews, fact checks, and similar evidence-heavy analysis.
- `recap page`: A project state snapshot with architecture, activity, and cognitive debt.
- `slide deck`: A presentation-style artifact where each section is one viewport tall.

Choose one primary artifact type before writing any HTML. If the content mixes modes, keep one dominant mode and use the others as supporting sections.

## Data Gathering

Before writing HTML:

1. Identify the audience and the decision the page should support.
2. Gather every fact you plan to show.
3. Verify names, numbers, and behavior descriptions against code, docs, or command output.
4. Mark uncertain claims as uncertain instead of presenting them as facts.

## Output Path

- Prefer `.artifacts/visual-explainer/` in the current workspace when it is writable and appropriate.
- Otherwise use another stable user-visible local path such as a temp artifact directory.
- Keep filenames descriptive: `auth-flow.html`, `diff-review-sync-engine.html`, `project-recap-mobile-app.html`.
- Always tell the user where the file lives.

## Opening The Artifact

- If the environment clearly supports opening local HTML files, do it after writing the file.
- If not, stop at file creation and tell the user how to open the path manually.
- Never treat browser opening as required for success; the file itself is the deliverable.
